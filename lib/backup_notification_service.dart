import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract interface class BackupNotificationSink {
  Future<void> showSuccess(String fileName);
  Future<void> showFailure(String message);
}

class BackupNotificationService implements BackupNotificationSink {
  BackupNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'arvin_backup',
    'پشتیبان‌گیری آروین',
    description: 'نتیجه پشتیبان‌گیری خودکار آروین',
    importance: Importance.defaultImportance,
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const settings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: settings));

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    _initialized = true;
  }

  @override
  Future<void> showSuccess(String fileName) async {
    await _ensureInitialized();
    await _plugin.show(
      41002,
      'پشتیبان‌گیری آروین',
      'پشتیبان با موفقیت ساخته شد: $fileName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'arvin_backup',
          'پشتیبان‌گیری آروین',
          channelDescription: 'نتیجه پشتیبان‌گیری خودکار آروین',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  @override
  Future<void> showFailure(String message) async {
    await _ensureInitialized();
    await _plugin.show(
      41003,
      'خطا در پشتیبان‌گیری آروین',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'arvin_backup',
          'پشتیبان‌گیری آروین',
          channelDescription: 'نتیجه پشتیبان‌گیری خودکار آروین',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
