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

class DeviceCalendarEvent {
  const DeviceCalendarEvent({
    required this.instanceId,
    required this.eventId,
    required this.calendarId,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    this.calendarName,
    this.description,
    this.eventTimezone,
    this.recurrenceRule,
  });

  final String instanceId;
  final String eventId;
  final String calendarId;
  final String? calendarName;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final String? eventTimezone;
  final String? recurrenceRule;

  factory DeviceCalendarEvent.fromMap(Map<Object?, Object?> value) {
    String? optionalString(String key) {
      final raw = value[key];
      if (raw is! String) return null;
      final normalized = raw.trim();
      return normalized.isEmpty ? null : normalized;
    }

    final startMillis = (value['startMillis'] as num?)?.toInt();
    final endMillis = (value['endMillis'] as num?)?.toInt();
    if (startMillis == null || endMillis == null || endMillis < startMillis) {
      throw const FormatException('Device calendar event has invalid dates');
    }

    return DeviceCalendarEvent(
      instanceId: optionalString('instanceId') ?? '',
      eventId: optionalString('eventId') ?? '',
      calendarId: optionalString('calendarId') ?? '',
      calendarName: optionalString('calendarName'),
      title: optionalString('title') ?? '',
      description: optionalString('description'),
      start: DateTime.fromMillisecondsSinceEpoch(startMillis),
      end: DateTime.fromMillisecondsSinceEpoch(endMillis),
      allDay: value['allDay'] == true,
      eventTimezone: optionalString('eventTimezone'),
      recurrenceRule: optionalString('recurrenceRule'),
    );
  }
}

/// Android boundary for user-approved system calendar access.
///
/// Existing FollowUp export remains intent-based and user-approved. Provider
/// discovery and external-event reads are read-only and share the existing
/// Android Calendar Provider boundary; no vendor-specific calendar engine is
/// introduced here.
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
  static const String listEventsMethod = 'listDeviceCalendarEvents';
  static const int maxEventQueryCalendars = 20;
  static const Duration maxEventQueryWindow = Duration(days: 93);

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

  Future<List<DeviceCalendarEvent>> listDeviceCalendarEvents({
    required Iterable<String> calendarIds,
    required DateTime start,
    required DateTime end,
  }) async {
    final ids = calendarIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const <DeviceCalendarEvent>[];
    if (ids.length > maxEventQueryCalendars) {
      throw ArgumentError.value(
        ids.length,
        'calendarIds',
        'At most $maxEventQueryCalendars calendars may be queried at once',
      );
    }

    final window = end.difference(start);
    if (!end.isAfter(start) || window > maxEventQueryWindow) {
      throw ArgumentError.value(
        window,
        'end',
        'Calendar event query window must be positive and at most ${maxEventQueryWindow.inDays} days',
      );
    }

    try {
      final raw = await _channel.invokeMethod<List<Object?>>(
        listEventsMethod,
        <String, Object?>{
          'calendarIds': ids,
          'startMillis': start.millisecondsSinceEpoch,
          'endMillis': end.millisecondsSinceEpoch,
        },
      );
      if (raw == null) return const <DeviceCalendarEvent>[];

      final events = <DeviceCalendarEvent>[];
      for (final item in raw) {
        if (item is! Map) continue;
        try {
          final event = DeviceCalendarEvent.fromMap(
            Map<Object?, Object?>.from(item),
          );
          if (
              event.instanceId.isNotEmpty &&
              event.eventId.isNotEmpty &&
              event.calendarId.isNotEmpty) {
            events.add(event);
          }
        } on FormatException {
          continue;
        }
      }
      return List<DeviceCalendarEvent>.unmodifiable(events);
    } on MissingPluginException {
      return const <DeviceCalendarEvent>[];
    } on PlatformException catch (error) {
      if (error.code == 'calendar_permission_denied') {
        return const <DeviceCalendarEvent>[];
      }
      rethrow;
    }
  }
}
