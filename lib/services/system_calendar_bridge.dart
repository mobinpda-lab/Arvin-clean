import 'package:flutter/services.dart';

import '../calendar_page.dart';

class DeviceCalendarInfo {
  const DeviceCalendarInfo({
    required this.id,
    required this.displayName,
    this.accountName,
    this.accountType,
    this.ownerAccount,
    this.accessLevel = 0,
    this.visible = false,
    this.syncEvents = false,
    this.isPrimary = false,
  });

  final String id;
  final String displayName;
  final String? accountName;
  final String? accountType;
  final String? ownerAccount;
  final int accessLevel;
  final bool visible;
  final bool syncEvents;
  final bool isPrimary;

  factory DeviceCalendarInfo.fromMap(Map<Object?, Object?> value) {
    String? optionalString(String key) {
      final raw = value[key];
      if (raw is! String) return null;
      final normalized = raw.trim();
      return normalized.isEmpty ? null : normalized;
    }

    final id = optionalString('id') ?? '';
    return DeviceCalendarInfo(
      id: id,
      displayName: optionalString('displayName') ?? id,
      accountName: optionalString('accountName'),
      accountType: optionalString('accountType'),
      ownerAccount: optionalString('ownerAccount'),
      accessLevel: (value['accessLevel'] as num?)?.toInt() ?? 0,
      visible: value['visible'] == true,
      syncEvents: value['syncEvents'] == true,
      isPrimary: value['isPrimary'] == true,
    );
  }
}

/// Android boundary for user-approved system calendar access.
///
/// Existing FollowUp export remains intent-based and user-approved. Provider
/// discovery is read-only: it requests READ_CALENDAR and enumerates installed
/// Android Calendar Provider accounts so Settings can later offer Google,
/// Samsung, or other calendars without a second vendor-specific integration.
class SystemCalendarBridge {
  SystemCalendarBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'arvin/system_calendar';
  static const String insertMethod = 'insertSystemCalendarEvent';
  static const String permissionStatusMethod =
      'calendarReadPermissionGranted';
  static const String requestPermissionMethod =
      'requestCalendarReadPermission';
  static const String listCalendarsMethod = 'listDeviceCalendars';

  final MethodChannel _channel;

  static bool isEligible(CalendarReminder reminder) =>
      reminder.id.startsWith('followup:') && !reminder.completed;

  Future<bool> insert(CalendarReminder reminder) async {
    if (!isEligible(reminder)) return false;

    final start = reminder.date;
    final end = reminder.isAllDay
        ? DateTime(start.year, start.month, start.day + 1)
        : start.add(const Duration(minutes: 30));

    final inserted = await _channel.invokeMethod<bool>(
      insertMethod,
      <String, Object?>{
        'title': reminder.title,
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
        'allDay': reminder.isAllDay,
      },
    );
    return inserted ?? false;
  }

  Future<bool> hasReadPermission() async {
    try {
      return await _channel.invokeMethod<bool>(permissionStatusMethod) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> requestReadPermission() async {
    try {
      return await _channel.invokeMethod<bool>(requestPermissionMethod) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (error) {
      if (error.code == 'permission_request_in_progress') return false;
      rethrow;
    }
  }

  Future<List<DeviceCalendarInfo>> listDeviceCalendars() async {
    try {
      final raw = await _channel.invokeMethod<List<Object?>>(listCalendarsMethod);
      if (raw == null) return const <DeviceCalendarInfo>[];

      final calendars = <DeviceCalendarInfo>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final calendar = DeviceCalendarInfo.fromMap(
          Map<Object?, Object?>.from(item),
        );
        if (calendar.id.isNotEmpty) calendars.add(calendar);
      }
      return List<DeviceCalendarInfo>.unmodifiable(calendars);
    } on MissingPluginException {
      return const <DeviceCalendarInfo>[];
    } on PlatformException catch (error) {
      if (error.code == 'calendar_permission_denied') {
        return const <DeviceCalendarInfo>[];
      }
      rethrow;
    }
  }
}
