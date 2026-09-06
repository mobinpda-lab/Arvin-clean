import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'daily_content.dart';

abstract interface class DailyContentNotificationSink {
  Future<void> show(DailyContentItem item);
}

class DailyContentNotificationService implements DailyContentNotificationSink {
  DailyContentNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'arvin_daily_content',
    'پیام روز آروین',
    description: 'آیه، حدیث و سخن روز در تقویم آروین',
    importance: Importance.defaultImportance,
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

  int notificationIdFor(DailyContentItem item) {
    var hash = 17;
    for (final codeUnit in item.id.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 43001 : hash;
  }

  @override
  Future<void> show(DailyContentItem item) async {
    if (!item.isPublishable) return;
    await _ensureInitialized();
    await _plugin.show(
      id: notificationIdFor(item),
      title: 'پیام روز',
      body: item.text,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'arvin_daily_content',
          'پیام روز آروین',
          channelDescription: 'آیه، حدیث و سخن روز در تقویم آروین',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      payload: 'daily-content:${item.id}',
    );
  }
}
