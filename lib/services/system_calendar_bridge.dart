import 'package:flutter/services.dart';

import '../calendar_page.dart';

/// Android boundary for user-approved export of canonical FollowUp reminders.
///
/// The system calendar remains an external destination, never an Arvin source
/// of truth. Only canonical FollowUp projections are eligible; official prayer
/// times and holidays stay read-only inside Arvin.
class SystemCalendarBridge {
  SystemCalendarBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'arvin/system_calendar';
  static const String insertMethod = 'insertSystemCalendarEvent';

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
}
