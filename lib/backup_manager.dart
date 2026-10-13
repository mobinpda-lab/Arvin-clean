import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';
import 'models/goal_project.dart';
import 'models/task.dart';
import 'models/person_reference.dart';
import 'services/project_plan_codec.dart';
import 'services/calendar_sync_plan_service.dart';

typedef CanonicalBackupCandidate = ({
  List<Task> tasks,
  Map<String, dynamic>? settings,
  List<ProjectPlan> projects,
  bool hasProjects,
  List<ExternalCalendarEventLink>? calendarLinks,
  List<String>? categories,
  List<String>? tags,
  List<PersonReference>? people,
});

/// Coordinates the portable backup format with Arvin's local task storage.
///
/// This class deliberately keeps the backup document independent from the UI,
/// so the same format can later be used by scheduled backups and restore on a
/// different device.
/// Wraps a multi-store restore so a failed later stage triggers restoration
/// of the pre-restore snapshot. The emergency backup remains available if that
/// restoration itself fails.
class RestoreExecutionFailure implements Exception {
  const RestoreExecutionFailure({
    required this.recoveryBackup,
    required this.restoreError,
    this.rollbackError,
  });

  final String recoveryBackup;
  final Object restoreError;
  final Object? rollbackError;

  bool get rolledBack => rollbackError == null;

  @override
  String toString() => rolledBack
      ? 'Restore failed; the previous state was restored.'
      : 'Restore and automatic rollback failed; recovery backup: $recoveryBackup';
}

Future<T> runRestoreWithRollback<T>({
  required String recoveryBackup,
  required Future<T> Function() apply,
  required Future<void> Function() rollback,
}) async {
  try {
    return await apply();
  } catch (restoreError) {
    try {
      await rollback();
    } catch (rollbackError) {
      throw RestoreExecutionFailure(
        recoveryBackup: recoveryBackup,
        restoreError: restoreError,
        rollbackError: rollbackError,
      );
    }
    throw RestoreExecutionFailure(
      recoveryBackup: recoveryBackup,
      restoreError: restoreError,
    );
  }
}

class ArvinBackupManager {
  ArvinBackupManager({
    ArvinBackupService? service,
    this.projectCodec = const ProjectPlanCodec(),
  }) : service = service ?? ArvinBackupService();

  static const String directoryKey = 'arvin.backup.directory';
  final ArvinBackupService service;
  final ProjectPlanCodec projectCodec;

  /// Reconciles backup records by canonical Task ID. Matching records are
  /// updated from the backup; backup-only records are appended; local-only
  /// records remain untouched. Titles and dates are never used as identity.
  static List<Task> reconcileTasksById({
    required Iterable<Task> current,
    required Iterable<Task> backup,
  }) {
    final result = List<Task>.of(current);
    final indexById = <String, int>{};
    for (var index = 0; index < result.length; index++) {
      indexById[result[index].id] = index;
    }
    for (final incoming in backup) {
      final existingIndex = indexById[incoming.id];
      if (existingIndex == null) {
        indexById[incoming.id] = result.length;
        result.add(incoming);
      } else {
        result[existingIndex] = incoming;
      }
    }
    return List<Task>.unmodifiable(result);
  }

  /// Merges Projects by canonical ID while retaining local-only Projects.
  /// For a matching Project, backup fields win, but memberships of local-only
  /// Tasks are retained so importing another device cannot orphan local work.
  static List<ProjectPlan> reconcileProjectsById({
    required Iterable<ProjectPlan> current,
    required Iterable<ProjectPlan> backup,
    required Set<String> localOnlyTaskIds,
  }) {
    final currentById = <String, ProjectPlan>{
      for (final project in current) project.id: project,
    };
    final result = <ProjectPlan>[];
    final seen = <String>{};
    for (final incoming in backup) {
      final existing = currentById[incoming.id];
      final merged = existing == null
          ? incoming
          : incoming.copyWith(
              itemIds: <String>{
                ...incoming.itemIds,
                ...existing.itemIds.where(localOnlyTaskIds.contains),
              },
            );
      result.add(merged);
      seen.add(incoming.id);
    }
    for (final existing in current) {
      if (seen.add(existing.id)) result.add(existing);
    }
    return List<ProjectPlan>.unmodifiable(result);
  }

  Future<void> setDirectory(String? uri) async {
    final prefs = await SharedPreferences.getInstance();
    if (uri == null || uri.isEmpty) {
      await prefs.remove(directoryKey);
    } else {
      await prefs.setString(directoryKey, uri);
    }
  }

  Future<String?> getDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(directoryKey);
  }

  Future<String?> chooseAndRememberDirectory() async {
    final uri = await service.chooseDirectory();
    if (uri == null || uri.isEmpty) return null;
    await setDirectory(uri);
    return uri;
  }

  Future<String?> backupTasks(
    List<Map<String, dynamic>> tasks, {
    Map<String, dynamic>? settings,
    List<Map<String, dynamic>>? projects,
    List<Map<String, dynamic>>? calendarLinks,
    List<String>? categories,
    List<String>? tags,
    List<PersonReference>? people,
    String? encryptionPassphrase,
  }) async {
    final directory = await getDirectory();
    if (directory == null || directory.isEmpty) return null;

    final fileName = service.createBackupFileName(DateTime.now());
    await service.writeBackup(
      directoryUri: directory,
      payload: <String, dynamic>{
        'tasks': tasks,
        if (settings != null) 'settings': Map<String, dynamic>.from(settings),
        if (projects != null) 'projects': projects,
        if (calendarLinks != null) 'calendarLinks': calendarLinks,
        if (categories != null) 'categories': categories,
        if (tags != null) 'tags': tags,
        if (people != null) 'people': people.map((person) => person.toJson()).toList(growable: false),
      },
      fileName: fileName,
      encryptionPassphrase: encryptionPassphrase,
    );
    return fileName;
  }

  /// Serializes the complete canonical Task shape into the existing Arvin
  /// backup document. Optional settings, Projects, and Calendar link metadata
  /// ride in the same backward-compatible document; no second backup format is created.
  Future<String?> backupCanonicalTasks(
    Iterable<Task> tasks, {
    Map<String, dynamic>? settings,
    Iterable<ProjectPlan>? projects,
    Iterable<ExternalCalendarEventLink>? calendarLinks,
    Iterable<String>? categories,
    Iterable<String>? tags,
    Iterable<PersonReference>? people,
    String? encryptionPassphrase,
  }) {
    return backupTasks(
      tasks.map((task) => task.toJson()).toList(growable: false),
      settings: settings,
      projects: projects == null ? null : projectCodec.encodeList(projects),
      calendarLinks: calendarLinks?.map(_encodeCalendarLink).toList(growable: false),
      categories: categories?.toList(growable: false),
      tags: tags?.toList(growable: false),
      people: people?.toList(growable: false),
      encryptionPassphrase: encryptionPassphrase,
    );
  }

  Future<Map<String, dynamic>?> restoreBackup({String? passphrase}) =>
      service.readBackup(passphrase: passphrase);

  /// Decodes one portable backup selection into a candidate without mutating
  /// local storage. The same read yields canonical tasks, optional settings,
  /// and canonical Projects so the UI can validate and confirm restore once.
  Future<CanonicalBackupCandidate?> restoreCanonicalBackup({
    String? passphrase,
  }) async {
    final document = await restoreBackup(passphrase: passphrase);
    if (document == null) return null;

    final tasks = _decodeCanonicalTasks(document);
    final projects = _decodeCanonicalProjects(document);
    final calendarLinks = _decodeCalendarLinks(document);
    final categories = _decodeCatalog(document, 'categories', 'Category');
    final tags = _decodeCatalog(document, 'tags', 'Tag');
    final people = _decodePeople(document);
    final rawSettings = document['settings'];
    if (rawSettings != null && rawSettings is! Map) {
      throw const FormatException('Arvin backup settings are invalid');
    }

    return (
      tasks: tasks,
      settings: rawSettings is Map
          ? Map<String, dynamic>.from(rawSettings)
          : null,
      projects: projects,
      hasProjects: document['projects'] is List,
      calendarLinks: calendarLinks,
      categories: categories,
      tags: tags,
      people: people,
    );
  }

  /// Compatibility helper for callers that only need tasks.
  Future<List<Task>?> restoreCanonicalTasks({String? passphrase}) async {
    final candidate = await restoreCanonicalBackup(passphrase: passphrase);
    return candidate?.tasks;
  }

  List<Task> _decodeCanonicalTasks(Map<String, dynamic> document) {
    final rawTasks = document['tasks'];
    if (rawTasks is! List) {
      throw const FormatException('Arvin backup tasks are invalid');
    }

    final ids = <String>{};
    final tasks = <Task>[];
    for (final raw in rawTasks) {
      if (raw is! Map) {
        throw const FormatException('Arvin backup task entry is invalid');
      }
      final task = Task.fromJson(Map<String, dynamic>.from(raw));
      if (task.id.trim().isEmpty) {
        throw const FormatException('Arvin backup contains an empty task id');
      }
      if (!ids.add(task.id)) {
        throw FormatException(
          'Arvin backup contains duplicate task id: ${task.id}',
        );
      }
      tasks.add(task);
    }

    return List<Task>.unmodifiable(tasks);
  }

  Map<String, dynamic> _encodeCalendarLink(ExternalCalendarEventLink link) =>
      link.toJson();

  /// Old backups may not contain Calendar link metadata. Keep that distinction
  /// explicit so restore does not silently replace a current device's links
  /// with an invented empty list.
  List<ExternalCalendarEventLink>? _decodeCalendarLinks(
    Map<String, dynamic> document,
  ) {
    if (!document.containsKey('calendarLinks')) return null;
    final rawLinks = document['calendarLinks'];
    if (rawLinks is! List) {
      throw const FormatException('Arvin backup Calendar links are invalid');
    }

    final ids = <String>{};
    final links = <ExternalCalendarEventLink>[];
    for (final raw in rawLinks) {
      if (raw is! Map) {
        throw const FormatException('Arvin backup Calendar link entry is invalid');
      }
      try {
        final value = Map<String, dynamic>.from(raw);
        final link = ExternalCalendarEventLink(
          reminderId: value['reminderId'] as String? ?? '',
          calendarId: value['calendarId'] as String? ?? '',
          eventId: value['eventId'] as String? ?? '',
          lastSyncedFingerprint:
              value['lastSyncedFingerprint'] as String? ?? '',
        );
        if (!ids.add(link.reminderId)) {
          throw FormatException(
            'Arvin backup contains duplicate Calendar link: ${link.reminderId}',
          );
        }
        links.add(link);
      } on FormatException {
        rethrow;
      } catch (_) {
        throw const FormatException(
          'Arvin backup Calendar link fields are invalid',
        );
      }
    }
    return List<ExternalCalendarEventLink>.unmodifiable(links);
  }

  /// Catalogs are optional so older backup documents remain valid. When
  /// present, validate the entire list before the UI mutates any local store.
  List<String>? _decodeCatalog(
    Map<String, dynamic> document,
    String key,
    String label,
  ) {
    if (!document.containsKey(key)) return null;
    final rawValues = document[key];
    if (rawValues is! List) {
      throw FormatException('Arvin backup $label catalog is invalid');
    }

    final seen = <String>{};
    final values = <String>[];
    for (final raw in rawValues) {
      if (raw is! String || raw.trim().isEmpty) {
        throw FormatException('Arvin backup $label catalog entry is invalid');
      }
      final value = raw.trim();
      if (!seen.add(value)) {
        throw FormatException('Arvin backup contains duplicate $label: $value');
      }
      values.add(value);
    }
    return List<String>.unmodifiable(values);
  }

  /// Missing Person data means a legacy backup; callers must preserve the local directory.
  List<PersonReference>? _decodePeople(Map<String, dynamic> document) {
    if (!document.containsKey('people')) return null;
    final rawPeople = document['people'];
    if (rawPeople is! List) {
      throw const FormatException('Arvin backup Person directory is invalid');
    }
    final ids = <String>{};
    final names = <String>{};
    final people = <PersonReference>[];
    for (final raw in rawPeople) {
      if (raw is! Map) {
        throw const FormatException('Arvin backup Person directory entry is invalid');
      }
      final person = PersonReference.fromJson(Map<String, dynamic>.from(raw));
      if (!ids.add(person.id)) {
        throw FormatException('Arvin backup contains duplicate Person id: ${person.id}');
      }
      final normalizedName = person.displayName.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک').replaceAll(RegExp(r'\\s+'), ' ');
      if (!names.add(normalizedName)) {
        throw FormatException('Arvin backup contains duplicate Person name: ${person.displayName}');
      }
      people.add(person);
    }
    return List<PersonReference>.unmodifiable(people);
  }

  List<ProjectPlan> _decodeCanonicalProjects(Map<String, dynamic> document) {
    final rawProjects = document['projects'];
    if (rawProjects == null) return const <ProjectPlan>[];

    final projects = projectCodec.decodeList(rawProjects);
    final ids = <String>{};
    for (final project in projects) {
      if (!ids.add(project.id)) {
        throw FormatException(
          'Arvin backup contains duplicate project id: ${project.id}',
        );
      }
    }
    return projects;
  }
}
