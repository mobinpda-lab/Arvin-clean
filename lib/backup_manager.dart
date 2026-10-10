import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';
import 'models/goal_project.dart';
import 'models/task.dart';
import 'services/project_plan_codec.dart';
import 'services/calendar_sync_plan_service.dart';

typedef CanonicalBackupCandidate = ({
  List<Task> tasks,
  Map<String, dynamic>? settings,
  List<ProjectPlan> projects,
  List<ExternalCalendarEventLink>? calendarLinks,
  List<String>? categories,
  List<String>? tags,
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
    String? encryptionPassphrase,
  }) {
    return backupTasks(
      tasks.map((task) => task.toJson()).toList(growable: false),
      settings: settings,
      projects: projects == null ? null : projectCodec.encodeList(projects),
      calendarLinks: calendarLinks?.map(_encodeCalendarLink).toList(growable: false),
      categories: categories?.toList(growable: false),
      tags: tags?.toList(growable: false),
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
      calendarLinks: calendarLinks,
      categories: categories,
      tags: tags,
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
