import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_event_projection.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = ExternalCalendarEventProjection();

  DeviceCalendarEvent event({
    required String instanceId,
    required String eventId,
    String calendarId = 'device-calendar',
    String title = 'جلسه بیرونی',
    String? calendarName = 'تقویم شخصی',
    bool allDay = false,
    DateTime? start,
  }) {
    final eventStart = start ?? DateTime(2026, 9, 14, 10);
    return DeviceCalendarEvent(
      instanceId: instanceId,
      eventId: eventId,
      calendarId: calendarId,
      calendarName: calendarName,
      title: title,
      start: eventStart,
      end: eventStart.add(const Duration(hours: 1)),
      allDay: allDay,
    );
  }

  test('projects provider events without creating canonical task identity', () {
    final result = projection.project([
      event(instanceId: 'instance-1', eventId: 'event-1'),
    ]);

    expect(result, hasLength(1));
    expect(result.single.id, 'external-calendar:device-calendar:instance-1');
    expect(result.single.title, 'جلسه بیرونی • تقویم شخصی');
    expect(result.single.date, DateTime(2026, 9, 14, 10));
    expect(result.single.date.hour, 10);
    expect(result.single.date.minute, 0);
    expect(result.single.end, DateTime(2026, 9, 14, 11));
    expect(result.single.description, isNull);
    expect(result.single.completed, isFalse);
  });

  test('filters Arvin-owned linked provider events to prevent duplicates', () {
    final result = projection.project(
      [
        event(instanceId: 'instance-1', eventId: 'event-linked'),
        event(instanceId: 'instance-2', eventId: 'event-external'),
      ],
      linkedEvents: [
        ExternalCalendarEventLink(
          reminderId: 'followup:task-1:followup-1',
          calendarId: 'device-calendar',
          eventId: 'event-linked',
          lastSyncedFingerprint: 'fingerprint',
        ),
      ],
    );

    expect(result, hasLength(1));
    expect(result.single.id, contains('instance-2'));
  });

  test('deduplicates provider instances and preserves all-day semantics', () {
    final same = event(
      instanceId: 'instance-all-day',
      eventId: 'event-all-day',
      allDay: true,
      title: '',
      calendarName: null,
    );
    final result = projection.project([same, same]);

    expect(result, hasLength(1));
    expect(result.single.isAllDay, isTrue);
    expect(result.single.title, 'رویداد بدون عنوان • تقویم دستگاه');
  });
}
