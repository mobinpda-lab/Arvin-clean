import 'dart:convert';

import 'backup_notification_service.dart';
import 'backup_service.dart';
import 'services/task_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs the scheduled backup without depending on Flutter UI state.
class BackupBackgroundRunner {
  const BackupBackgroundRunner({
    ArvinBackupService? backupService,
    BackupNotificationSink? notificationSink,
    TaskStore? taskStore,
  })  : _backupService = backupService,
        _notificationSink = notificationSink,
        _taskStore = taskStore;

  final ArvinBackupService? _backupService;
  final BackupNotificationSink? _notificationSink;
  final TaskStore? _taskStore;

  static const String directoryUriKey = 'arvin.backup.directoryUri';

  // Kept for backward compatibility with existing scheduled-backup settings.
  // The runner no longer uses this snapshot when creating a backup.
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

    if (directoryUri == null || directoryUri.isEmpty) {
      return false;
    }

    try {
      final tasks = await (_taskStore ?? TaskStore()).load();
      final payload = <String, dynamic>{
        'tasks': tasks
            .map(
              (task) => <String, dynamic>{
                'id': task.id,
                'title': task.title,
                'description': task.description,
                'followUpDate': task.followUpDate?.toIso8601String(),
                'tags': task.tags,
                'archived': task.archived,
                'trashed': task.trashed,
                'completed': task.completed,
              },
            )
            .toList(),
      };

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
