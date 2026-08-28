import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/automatic_follow_up_service.dart';
import 'services/follow_up_reminder_projection.dart';

abstract interface class AutomaticFollowUpNotificationSink {
  Future<void> showDue(AutomaticFollowUpCandidate candidate);
}

abstract interface class FollowUpReminderNotificationSink {
  Future<void> showReminder(FollowUpReminderCandidate candidate);
}

class AutomaticFollowUpNotificationService
    implements AutomaticFollowUpNotificationSink, FollowUpReminderNotificationSink {
  AutomaticFollowUpNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'arvin_followup',
    'پیگیری‌های آروین',
    description: 'هشدار پیگیری‌های موعدرسیده آروین',
    importance: Importance.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'arvin_followup',
      'پیگیری‌های آروین',
      channelDescription: 'هشدار پیگیری‌های موعدرسیده آروین',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const settings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: settings),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    _initialized = true;
  }

  int notificationIdFor(AutomaticFollowUpCandidate candidate) =>
      _stableNotificationId('${candidate.taskId}:${candidate.followUpId}');

  int reminderNotificationIdFor(FollowUpReminderCandidate candidate) =>
      _stableNotificationId('reminder:${candidate.taskId}:${candidate.followUpId}');

  String reminderBodyFor(FollowUpReminderCandidate candidate) {
    final taskTitle = candidate.taskTitle.trim().isEmpty
        ? 'بدون عنوان'
        : candidate.taskTitle.trim();
    final label = candidate.label.trim().isEmpty ? 'پیگیری' : candidate.label.trim();
    return '$taskTitle • $label';
  }

  int _stableNotificationId(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 42001 : hash;
  }

  @override
  Future<void> showDue(AutomaticFollowUpCandidate candidate) async {
    await _ensureInitialized();
    await _plugin.show(
      id: notificationIdFor(candidate),
      title: 'پیگیری موعدرسیده',
      body: candidate.taskTitle,
      notificationDetails: _details,
      payload: candidate.taskId,
    );
  }

  @override
  Future<void> showReminder(FollowUpReminderCandidate candidate) async {
    await _ensureInitialized();
    await _plugin.show(
      id: reminderNotificationIdFor(candidate),
      title: 'یادآور پیگیری',
      body: reminderBodyFor(candidate),
      notificationDetails: _details,
      payload: candidate.taskId,
    );
  }
}
