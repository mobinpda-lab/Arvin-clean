import 'dart:convert';

import 'backup_notification_service.dart';
import 'backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs the scheduled backup without depending on Flutter UI state.
class BackupBackgroundRunner {
  const BackupBackgroundRunner({
    ArvinBackupService? backupService,
    BackupNotificationSink? notificationSink,
  })  : _backupService = backupService,
        _notificationSink = notificationSink;

  final ArvinBackupService? _backupService;
  final BackupNotificationSink? _notificationSink;

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

  Future<BackupNotificationSink> _notifications() async {
    return _notificationSink ?? BackupNotificationService();
  }

  Future<void> _notifyFailure(String message) async {
    try {
      final notifications = await _notifications();
      await notifications.showFailure(message);
    } catch (_) {
      // A notification failure must never turn a completed backup into a failure.
    }
  }

  Future<bool> run() async {
    final prefs = await SharedPreferences.getInstance();
    final directoryUri = prefs.getString(directoryUriKey);
    final encodedPayload = prefs.getString(payloadKey);

    if (directoryUri == null || directoryUri.isEmpty || encodedPayload == null) {
      return false;
    }

    try {
      final decoded = jsonDecode(encodedPayload);
      if (decoded is! Map) {
        await _notifyFailure('تنظیمات پشتیبان‌گیری نامعتبر است.');
        return false;
      }

      final payload = Map<String, dynamic>.from(decoded);
      final service = _backupService ?? ArvinBackupService();
      final fileName = service.createBackupFileName(DateTime.now());
      await service.writeBackup(
        directoryUri: directoryUri,
        payload: payload,
        fileName: fileName,
      );

      try {
        final notifications = await _notifications();
        await notifications.showSuccess(fileName);
      } catch (_) {
        // The backup itself succeeded; notification delivery is best effort.
      }
      return true;
    } catch (error) {
      await _notifyFailure('پشتیبان‌گیری انجام نشد: $error');
      return false;
    }
  }
}
