import 'dart:convert';

import 'backup_notification_service.dart';
import 'backup_service.dart';
import 'services/app_settings_service.dart';
import 'services/project_plan_codec.dart';
import 'services/project_store.dart';
import 'services/task_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupBackgroundRunner {
  const BackupBackgroundRunner({
    ArvinBackupService? backupService,
    BackupNotificationSink? notificationSink,
    TaskStore? taskStore,
    ProjectStore? projectStore,
    AppSettingsService? settingsService,
  })  : _backupService = backupService,
        _notificationSink = notificationSink,
        _taskStore = taskStore,
        _projectStore = projectStore,
        _settingsService = settingsService;

  final ArvinBackupService? _backupService;
  final BackupNotificationSink? _notificationSink;
  final TaskStore? _taskStore;
  final ProjectStore? _projectStore;
  final AppSettingsService? _settingsService;

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

  Future<BackupNotificationSink> _notifications() async =>
      _notificationSink ?? BackupNotificationService();

  Future<void> _notifyFailure(String message) async {
    try {
      await (await _notifications()).showFailure(message);
    } catch (_) {}
  }

  Future<bool> run() async {
    final prefs = await SharedPreferences.getInstance();
    final directoryUri = prefs.getString(directoryUriKey);
    if (directoryUri == null || directoryUri.isEmpty) return false;

    try {
      final taskStore = _taskStore ?? TaskStore();
      final projectStore = _projectStore ?? ProjectStore();
      final settingsService = _settingsService ?? AppSettingsService();
      final tasks = await taskStore.load();
      final projects = await projectStore.load();
      final settings = await settingsService.load();
      final codec = const ProjectPlanCodec();
      final payload = <String, dynamic>{
        'tasks': tasks.map((task) => task.toJson()).toList(growable: false),
        'projects': projects.map(codec.encode).toList(growable: false),
        'settings': settingsService.toPortableJson(settings),
      };

      final service = _backupService ?? ArvinBackupService();
      final fileName = service.createBackupFileName(DateTime.now());
      await service.writeBackup(
        directoryUri: directoryUri,
        payload: payload,
        fileName: fileName,
      );

      try {
        await (await _notifications()).showSuccess(fileName);
      } catch (_) {}
      return true;
    } catch (error) {
      await _notifyFailure('پشتیبان‌گیری انجام نشد: $error');
      return false;
    }
  }
}
