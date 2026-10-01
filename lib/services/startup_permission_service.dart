import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Requests the two Android permissions that unlock Arvin's startup-dependent
/// reminder and device-calendar features.
///
/// The startup prompt is intentionally attempted at most once per installation.
/// Existing feature flows remain responsible for requesting a permission later
/// when a user explicitly enables/uses that feature.
class StartupPermissionService {
  StartupPermissionService({
    SharedPreferences? preferences,
    FlutterLocalNotificationsPlugin? notifications,
    MethodChannel? calendarChannel,
  })  : _preferences = preferences,
        _notifications = notifications ?? FlutterLocalNotificationsPlugin(),
        _calendarChannel =
            calendarChannel ?? const MethodChannel('arvin/system_calendar');

  static const _promptedKey = 'startup_permissions_prompted_v1';

  final SharedPreferences? _preferences;
  final FlutterLocalNotificationsPlugin _notifications;
  final MethodChannel _calendarChannel;

  Future<void> requestOnStartup() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    if (preferences.getBool(_promptedKey) == true) return;

    try {
      try {
        await _requestNotificationPermission();
      } on MissingPluginException {
        // Non-Android/widget-test environments have no Android permission API.
      }
      try {
        await _requestCalendarPermission();
      } on MissingPluginException {
        // Non-Android/widget-test environments have no Android permission API.
      }
    } finally {
      // A single startup attempt must never trap the user in a prompt loop.
      await preferences.setBool(_promptedKey, true);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> _requestCalendarPermission() async {
    await _calendarChannel.invokeMethod<bool>(
      'requestCalendarAccessPermissions',
    );
  }
}
