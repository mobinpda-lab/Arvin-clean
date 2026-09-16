import '../calendar_page.dart';
import 'calendar_sync_plan_service.dart';
import 'system_calendar_bridge.dart';

/// Read-only projection of Android Calendar Provider events into Arvin's
/// existing calendar presentation model.
///
/// This does not create or mutate Task/FollowUp data. Events already linked to
/// Arvin-owned outbound sync are excluded so the same Arvin item is not shown
/// twice after it has been synchronized to the device calendar.
class ExternalCalendarEventProjection {
  const ExternalCalendarEventProjection();

  List<CalendarReminder> project(
    Iterable<DeviceCalendarEvent> events, {
    Iterable<ExternalCalendarEventLink> linkedEvents = const [],
  }) {
    final linkedKeys = linkedEvents
        .map((link) => _providerKey(link.calendarId, link.eventId))
        .toSet();

    final reminders = <CalendarReminder>[];
    final seenInstances = <String>{};

    for (final event in events) {
      final instanceId = event.instanceId.trim();
      final calendarId = event.calendarId.trim();
      final eventId = event.eventId.trim();
      if (instanceId.isEmpty || calendarId.isEmpty || eventId.isEmpty) continue;
      if (linkedKeys.contains(_providerKey(calendarId, eventId))) continue;

      final stableInstanceKey = '$calendarId:$instanceId';
      if (!seenInstances.add(stableInstanceKey)) continue;

      final rawTitle = event.title.trim();
      final calendarName = event.calendarName?.trim();
      final source = calendarName == null || calendarName.isEmpty
          ? 'تقویم دستگاه'
          : calendarName;
      final title = rawTitle.isEmpty ? 'رویداد بدون عنوان' : rawTitle;

      reminders.add(
        CalendarReminder(
          id: 'external-calendar:$calendarId:$instanceId',
          title: '$title • $source',
          date: event.start,
          isAllDay: event.allDay,
        ),
      );
    }

    reminders.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return List<CalendarReminder>.unmodifiable(reminders);
  }

  String _providerKey(String calendarId, String eventId) =>
      '${calendarId.trim()}:${eventId.trim()}';
}
