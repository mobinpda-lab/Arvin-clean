import 'dart:io';

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
    Future<void> Function()? notificationPermissionRequester,
    Future<bool> Function()? calendarPermissionRequester,
  })  : _preferences = preferences,
        _notifications = notifications ?? FlutterLocalNotificationsPlugin(),
        _calendarChannel =
            calendarChannel ?? const MethodChannel('arvin/system_calendar'),
        _notificationPermissionRequester = notificationPermissionRequester,
        _calendarPermissionRequester = calendarPermissionRequester;

  static const _promptedKey = 'startup_permissions_prompted_v1';
  static Future<void>? _inFlightRequest;

  final SharedPreferences? _preferences;
  final FlutterLocalNotificationsPlugin _notifications;
  final MethodChannel _calendarChannel;
  final Future<void> Function()? _notificationPermissionRequester;
  final Future<bool> Function()? _calendarPermissionRequester;

  Future<void> requestOnStartup() {
    final inFlight = _inFlightRequest;
    if (inFlight != null) return inFlight;
    final request = _requestOnStartup();
    _inFlightRequest = request;
    return request.whenComplete(() {
      if (identical(_inFlightRequest, request)) {
        _inFlightRequest = null;
      }
    });
  }

  Future<void> _requestOnStartup() async {
    final preferences =
        _preferences ?? await SharedPreferences.getInstance();
    if (preferences.getBool(_promptedKey) == true) return;

    try {
      // Production permission APIs are Android-only. Injected requesters are
      // also allowed on the host so the permission lifecycle remains testable.
      if (Platform.isAndroid ||
          _notificationPermissionRequester != null ||
          _calendarPermissionRequester != null) {
        try {
          await _requestNotificationPermission();
        } on MissingPluginException {
          // The Android permission API is unavailable in a non-plugin host.
        } on PlatformException catch (error) {
          if (error.code != 'permissionRequestInProgress') rethrow;
        }
        try {
          await _requestCalendarPermission();
        } on MissingPluginException {
          // The Android calendar permission API is unavailable in a non-plugin host.
        } on PlatformException catch (error) {
          if (error.code != 'permissionRequestInProgress') rethrow;
        }
      }
    } finally {
      // A single startup attempt must never trap the user in a prompt loop.
      await preferences.setBool(_promptedKey, true);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final requester = _notificationPermissionRequester;
    if (requester != null) {
      await requester();
      return;
    }
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> _requestCalendarPermission() async {
    final requester = _calendarPermissionRequester;
    if (requester != null) {
      await requester();
      return;
    }
    await _calendarChannel.invokeMethod<bool>(
      'requestCalendarAccessPermissions',
    );
  }
}
