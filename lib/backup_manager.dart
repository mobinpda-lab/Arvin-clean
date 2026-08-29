import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';
import 'models/goal_project.dart';
import 'models/task.dart';
import 'services/project_plan_codec.dart';

typedef CanonicalBackupCandidate = ({
  List<Task> tasks,
  Map<String, dynamic>? settings,
  List<ProjectPlan> projects,
});

/// Coordinates the portable backup format with Arvin's local task storage.
///
/// This class deliberately keeps the backup document independent from the UI,
/// so the same format can later be used by scheduled backups and restore on a
/// different device.
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
      },
      fileName: fileName,
      encryptionPassphrase: encryptionPassphrase,
    );
    return fileName;
  }

  /// Serializes the complete canonical Task shape into the existing Arvin
  /// backup document. Optional settings and Projects ride in the same backward-
  /// compatible document; no second backup representation is created.
  Future<String?> backupCanonicalTasks(
    Iterable<Task> tasks, {
    Map<String, dynamic>? settings,
    Iterable<ProjectPlan>? projects,
    String? encryptionPassphrase,
  }) {
    return backupTasks(
      tasks.map((task) => task.toJson()).toList(growable: false),
      settings: settings,
      projects: projects == null ? null : projectCodec.encodeList(projects),
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
