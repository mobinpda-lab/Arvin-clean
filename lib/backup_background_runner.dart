import 'dart:convert';

import 'backup_schedule.dart';
import 'backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs the scheduled backup without depending on Flutter UI state.
class BackupBackgroundRunner {
  const BackupBackgroundRunner({ArvinBackupService? backupService})
      : _backupService = backupService;

  final ArvinBackupService? _backupService;

  static const String directoryUriKey = 'arvin.backup.directoryUri';
  static const String payloadKey = 'arvin.backup.payload';

  static Future<void> saveConfiguration({
    required String directoryUri,
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(directoryUriKey, directoryUri);
    await prefs.setString(payloadKey, jsonEncode(payload));
  }

  static Future<void> clearConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(directoryUriKey);
    await prefs.remove(payloadKey);
  }

  Future<bool> run() async {
    final prefs = await SharedPreferences.getInstance();
    final directoryUri = prefs.getString(directoryUriKey);
    final encodedPayload = prefs.getString(payloadKey);

    if (directoryUri == null || directoryUri.isEmpty || encodedPayload == null) {
      return false;
    }

    final decoded = jsonDecode(encodedPayload);
    if (decoded is! Map) return false;

    final payload = Map<String, dynamic>.from(decoded);
    final service = _backupService ?? ArvinBackupService();
    final fileName = service.createBackupFileName(DateTime.now());
    await service.writeBackup(
      directoryUri: directoryUri,
      payload: payload,
      fileName: fileName,
    );
    return true;
  }
}
