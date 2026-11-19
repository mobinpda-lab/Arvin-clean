import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/follow_up_reminder_projection.dart';

abstract interface class FollowUpReminderNotificationSink {
  Future<void> showDue(FollowUpReminderCandidate candidate);
}

class FollowUpReminderNotificationService
    implements FollowUpReminderNotificationSink {
  FollowUpReminderNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    void Function(NotificationResponse response)? onNotificationResponse,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _onNotificationResponse = onNotificationResponse;

  final FlutterLocalNotificationsPlugin _plugin;
  final void Function(NotificationResponse response)? _onNotificationResponse;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'arvin_followup_reminder',
    'یادآور پیگیری‌های آروین',
    description: 'یادآور مستقل هر پیگیری آروین',
    importance: Importance.high,
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const settings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: settings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    _initialized = true;
  }

  Future<NotificationAppLaunchDetails?> initializeForForeground() async {
    await _ensureInitialized();
    return _plugin.getNotificationAppLaunchDetails();
  }

  int notificationIdFor(FollowUpReminderCandidate candidate) {
    final value = candidate.stableKey;
    var hash = 23;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 42002 : hash;
  }

  @override
  Future<void> showDue(FollowUpReminderCandidate candidate) async {
    await _ensureInitialized();
    await _plugin.show(
      id: notificationIdFor(candidate),
      title: candidate.label,
      body: candidate.taskTitle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'arvin_followup_reminder',
          'یادآور پیگیری‌های آروین',
          channelDescription: 'یادآور مستقل هر پیگیری آروین',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(<String, Object?>{
        'taskId': candidate.taskId,
        'taskReminderId': candidate.taskReminderId,
        'scheduledAt': candidate.scheduledAt.toIso8601String(),
        'notificationId': notificationIdFor(candidate),
      }),
    );
  }
}
