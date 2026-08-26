import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';
import 'models/task.dart';

/// Coordinates the portable backup format with Arvin's local task storage.
///
/// This class deliberately keeps the backup document independent from the UI,
/// so the same format can later be used by scheduled backups and restore on a
/// different device.
class ArvinBackupManager {
  ArvinBackupManager({ArvinBackupService? service})
      : service = service ?? ArvinBackupService();

  static const String directoryKey = 'arvin.backup.directory';
  final ArvinBackupService service;

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

  Future<String?> backupTasks(List<Map<String, dynamic>> tasks) async {
    final directory = await getDirectory();
    if (directory == null || directory.isEmpty) return null;

    final fileName = service.createBackupFileName(DateTime.now());
    await service.writeBackup(
      directoryUri: directory,
      payload: <String, dynamic>{'tasks': tasks},
      fileName: fileName,
    );
    return fileName;
  }

  /// Serializes the complete canonical Task shape into the existing Arvin
  /// backup document. This intentionally reuses the current SAF/Dropbox bytes
  /// and format rather than creating a second backup representation.
  Future<String?> backupCanonicalTasks(Iterable<Task> tasks) {
    return backupTasks(
      tasks.map((task) => task.toJson()).toList(growable: false),
    );
  }

  Future<Map<String, dynamic>?> restoreBackup() => service.readBackup();

  /// Decodes an existing Arvin backup into the canonical Task model without
  /// mutating local storage. The caller can show a confirmation UI before the
  /// returned candidate list is written through the canonical TaskStore.
  Future<List<Task>?> restoreCanonicalTasks() async {
    final document = await restoreBackup();
    if (document == null) return null;

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
        throw FormatException('Arvin backup contains duplicate task id: ${task.id}');
      }
      tasks.add(task);
    }

    return List<Task>.unmodifiable(tasks);
  }
}
