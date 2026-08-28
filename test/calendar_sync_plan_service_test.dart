import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';

void main() {
  CalendarReminder reminder({
    required String id,
    String title = 'پیگیری',
    DateTime? date,
    bool completed = false,
    bool allDay = false,
  }) {
    return CalendarReminder(
      id: id,
      title: title,
      date: date ?? DateTime(2026, 8, 27, 10),
      completed: completed,
      isAllDay: allDay,
    );
  }

  test('revision fingerprint is stable and changes with event payload', () async {
    final service = CalendarSyncRevisionService();
    final first = await service.fromReminder(reminder(id: 'followup:t1:f1'));
    final same = await service.fromReminder(reminder(id: 'followup:t1:f1'));
    final changed = await service.fromReminder(
      reminder(id: 'followup:t1:f1', title: 'پیگیری تغییر یافته'),
    );

    expect(first.fingerprint, same.fingerprint);
    expect(changed.fingerprint, isNot(first.fingerprint));
    expect(first.end.difference(first.start), const Duration(minutes: 30));
  });

  test('all-day revision ends at next local day', () async {
    final revision = await CalendarSyncRevisionService().fromReminder(
      reminder(
        id: 'followup:t1:f2',
        date: DateTime(2026, 8, 27),
        allDay: true,
      ),
    );

    expect(revision.allDay, isTrue);
    expect(revision.end, DateTime(2026, 8, 28));
  });

  test('rejects official/non-followup and completed reminders', () async {
    final service = CalendarSyncRevisionService();

    await expectLater(
      service.fromReminder(reminder(id: 'official:holiday:1')),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      service.fromReminder(
        reminder(id: 'followup:t1:f1', completed: true),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('planner emits create no-op update and delete deterministically',
      () async {
    final revisions = CalendarSyncRevisionService();
    final create = await revisions.fromReminder(reminder(id: 'followup:t:c'));
    final stable = await revisions.fromReminder(reminder(id: 'followup:t:n'));
    final update = await revisions.fromReminder(
      reminder(id: 'followup:t:u', title: 'نسخه جدید'),
    );

    final plan = const CalendarSyncPlanService().plan(
      revisions: <CalendarSyncRevision>[create, stable, update],
      links: <ExternalCalendarEventLink>[
        ExternalCalendarEventLink(
          reminderId: 'followup:t:d',
          calendarId: 'google-account-calendar',
          eventId: 'event-d',
          lastSyncedFingerprint: 'old-d',
        ),
        ExternalCalendarEventLink(
          reminderId: 'followup:t:n',
          calendarId: 'google-account-calendar',
          eventId: 'event-n',
          lastSyncedFingerprint: stable.fingerprint,
        ),
        ExternalCalendarEventLink(
          reminderId: 'followup:t:u',
          calendarId: 'google-account-calendar',
          eventId: 'event-u',
          lastSyncedFingerprint: 'old-u',
        ),
      ],
    );

    expect(
      plan.items.map((item) => item.reminderId),
      <String>[
        'followup:t:c',
        'followup:t:d',
        'followup:t:n',
        'followup:t:u',
      ],
    );
    expect(plan.count(CalendarSyncAction.create), 1);
    expect(plan.count(CalendarSyncAction.delete), 1);
    expect(plan.count(CalendarSyncAction.noOp), 1);
    expect(plan.count(CalendarSyncAction.update), 1);
  });

  test('planner rejects duplicate revisions and duplicate links', () async {
    final revision = await CalendarSyncRevisionService().fromReminder(
      reminder(id: 'followup:t:dup'),
    );
    final link = ExternalCalendarEventLink(
      reminderId: revision.reminderId,
      calendarId: 'calendar',
      eventId: 'event',
      lastSyncedFingerprint: revision.fingerprint,
    );

    expect(
      () => const CalendarSyncPlanService().plan(
        revisions: <CalendarSyncRevision>[revision, revision],
        links: const <ExternalCalendarEventLink>[],
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => const CalendarSyncPlanService().plan(
        revisions: <CalendarSyncRevision>[revision],
        links: <ExternalCalendarEventLink>[link, link],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
