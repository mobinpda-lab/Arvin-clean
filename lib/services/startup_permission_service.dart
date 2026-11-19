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
    if (preferences.getBool(_promptedKey) == true) {
      await ensureCalendarProvisioned();
      return;
    }
    try {
      if (Platform.isAndroid ||
          _notificationPermissionRequester != null ||
          _calendarPermissionRequester != null) {
        try {
          await _requestNotificationPermission();
        } on MissingPluginException {
          // Permission channel is unavailable outside Android.
        } on PlatformException {
          // Notification permission is optional and must not block startup.
        }
        try {
          await _requestCalendarPermission();
        } on MissingPluginException {
          // Permission channel is unavailable outside Android.
        } on PlatformException {
          // Calendar access is optional. Permission/provider failures must not
          // escape the fire-and-forget startup path or block the Task store.
        }
      }
    } finally {
      await preferences.setBool(_promptedKey, true);
    }
  }

  Future<bool> _requestCalendarPermissionWith(
    Future<bool> Function() requester,
  ) async {
    try {
      return await requester();
    } on PlatformException {
      // An active or unavailable permission request is not a startup failure.
      return false;
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

  /// Re-checks the app-owned calendar on every launch, including upgrades
  /// where the one-time permission prompt was already acknowledged.
  Future<void> ensureCalendarProvisioned() async {
    try {
      final readGranted = await _calendarChannel.invokeMethod<bool>(
            'calendarReadPermissionGranted',
          ) ??
          false;
      if (!readGranted) return;

      final writeGranted = await _calendarChannel.invokeMethod<bool>(
            'calendarWritePermissionGranted',
          ) ??
          false;
      if (!writeGranted) return;

      // Native repeats both checks immediately before touching Calendar Provider.
      await _calendarChannel.invokeMethod<Map<Object?, Object?>>(
        'ensureArvinLocalCalendar',
      );
    } on MissingPluginException {
      // Native calendar integration is unavailable on this platform.
    } on PlatformException {
      // Permission denial, request contention and Provider failures must not
      // block the canonical Task store or app startup.
    }
  }

  Future<void> _requestCalendarPermission() async {
    final requester = _calendarPermissionRequester;
    final granted = requester != null
        ? await _requestCalendarPermissionWith(requester)
        : await _calendarChannel.invokeMethod<bool>(
              'requestCalendarAccessPermissions',
            ) ??
            false;
    if (granted) {
      await ensureCalendarProvisioned();
    }
  }
}
