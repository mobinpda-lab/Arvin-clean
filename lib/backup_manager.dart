import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';
import 'cloud_backup_provider.dart';

/// Coordinates the portable backup format with Arvin's local task storage.
///
/// This class deliberately keeps the backup document independent from the UI,
/// so the same format can later be used by scheduled backups and restore on a
/// different device.
class ArvinBackupManager {
  ArvinBackupManager({
    ArvinBackupService? service,
    CloudBackupProvider? cloudProvider,
  }) : service = service ?? ArvinBackupService(cloudProvider: cloudProvider);

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

  Future<Map<String, dynamic>?> restoreBackup() => service.readBackup();
}
