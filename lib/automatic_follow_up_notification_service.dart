import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/automatic_follow_up_service.dart';

abstract interface class AutomaticFollowUpNotificationSink {
  Future<void> showDue(AutomaticFollowUpCandidate candidate);
}

class AutomaticFollowUpNotificationService
    implements AutomaticFollowUpNotificationSink {
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

  int notificationIdFor(AutomaticFollowUpCandidate candidate) {
    final value = '${candidate.taskId}:${candidate.followUpId}';
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
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'arvin_followup',
          'پیگیری‌های آروین',
          channelDescription: 'هشدار پیگیری‌های موعدرسیده آروین',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: candidate.taskId,
    );
  }
}
