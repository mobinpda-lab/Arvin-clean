import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupPermissionService {
  StartupPermissionService({
    SharedPreferences? preferences,
    FlutterLocalNotificationsPlugin? notifications,
    MethodChannel? calendarChannel,
    Future<void> Function()? notificationPermissionRequester,
    Future<bool> Function()? calendarPermissionRequester,
  })  : _preferences = preferences,
        _notifications = notifications ?? FlutterLocalNotificationsPlugin(),
        _calendarChannel = calendarChannel ?? const MethodChannel('arvin/system_calendar'),
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
      if (identical(_inFlightRequest, request)) _inFlightRequest = null;
    });
  }

  Future<void> _requestOnStartup() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    if (preferences.getBool(_promptedKey) == true) return;
    try {
      if (Platform.isAndroid ||
          _notificationPermissionRequester != null ||
          _calendarPermissionRequester != null) {
        try {
          await _requestNotificationPermission();
        } on MissingPluginException {
          // Permission channel is unavailable outside Android.
        } on PlatformException catch (error) {
          if (error.code != 'permissionRequestInProgress') rethrow;
        }
        try {
          await _requestCalendarPermission();
        } on MissingPluginException {
          // Permission channel is unavailable outside Android.
        } on PlatformException catch (error) {
          if (error.code != 'permissionRequestInProgress') rethrow;
        }
      }
    } finally {
      await preferences.setBool(_promptedKey, true);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final requester = _notificationPermissionRequester;
    if (requester != null) {
      await requester();
      return;
    }
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> _requestCalendarPermission() async {
    final requester = _calendarPermissionRequester;
    if (requester != null) {
      await requester();
      return;
    }
    await _calendarChannel.invokeMethod<bool>('requestCalendarAccessPermissions');
  }
}
