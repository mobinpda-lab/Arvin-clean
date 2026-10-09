import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/calendar_outbound_sync_service.dart';
import 'package:arvin/services/calendar_provider_sync_executor.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Settings extends AppSettingsService {
  _Settings(this.integration);
  final CalendarIntegrationSettings integration;

  @override
  Future<AppSettings> load() async => AppSettings(
        themeMode: ThemeMode.system,
        usePersianDate: true,
        fontFamily: null,
        calendarIntegration: integration,
      );
}

class _Links extends ExternalCalendarLinkStore {
  _Links([List<ExternalCalendarEventLink>? links])
      : links = List<ExternalCalendarEventLink>.of(links ?? const []);
  final List<ExternalCalendarEventLink> links;

  @override
  Future<List<ExternalCalendarEventLink>> load() async => List.unmodifiable(links);

  @override
  Future<void> removeByReminderIds(Iterable<String> reminderIds) async {
    final ids = reminderIds.toSet();
    links.removeWhere((link) => ids.contains(link.reminderId));
  }

  @override
  Future<void> save(Iterable<ExternalCalendarEventLink> values) async {
    links
      ..clear()
      ..addAll(values);
  }
}

class _Executor extends CalendarProviderSyncExecutor {
  CalendarSyncPlan? receivedPlan;
  String? receivedTarget;

  @override
  Future<CalendarProviderSyncResult> execute({
    required CalendarSyncPlan plan,
    required String targetCalendarId,
  }) async {
    receivedPlan = plan;
    receivedTarget = targetCalendarId;
    return CalendarProviderSyncResult(
      created: plan.count(CalendarSyncAction.create),
      updated: plan.count(CalendarSyncAction.update),
      deleted: plan.count(CalendarSyncAction.delete),
      noOp: plan.count(CalendarSyncAction.noOp),
    );
  }
}

void main() {
  CalendarReminder followUp(String id) => CalendarReminder(
        id: 'followup:task-1:$id',
        title: 'پیگیری مشتری',
        date: DateTime(2026, 9, 16, 10),
      );

  test('does nothing while outbound sync is disabled', () async {
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(const CalendarIntegrationSettings()),
      executor: executor,
      linkStore: _Links(),
    );

    expect(await service.sync([followUp('f1')]), isNull);
    expect(executor.receivedPlan, isNull);
  });

  test('plans canonical follow-ups and executes against selected target', () async {
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
              autoSync: true,
targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links(),
    );

    final result = await service.sync([
      followUp('f1'),
      CalendarReminder(
        id: 'official:holiday',
        title: 'تعطیل رسمی',
        date: DateTime(2026, 9, 16),
        isAllDay: true,
      ),
    ]);

    expect(result?.created, 1);
    expect(executor.receivedTarget, 'calendar-7');
    expect(executor.receivedPlan?.items.single.reminderId, 'followup:task-1:f1');
  });

  test('existing link produces idempotent update/no-op planning, not duplicate create', () async {
    final reminder = followUp('f1');
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
              autoSync: true,
targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links([
        ExternalCalendarEventLink(
          reminderId: reminder.id,
          calendarId: 'calendar-7',
          eventId: 'event-9',
          lastSyncedFingerprint: revision.fingerprint,
        ),
      ]),
    );

    final result = await service.sync([reminder]);
    expect(result?.noOp, 1);
    expect(result?.created, 0);
  });

  test('honors per-source sync settings before planning provider writes', () async {
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          autoSync: true,
          targetCalendarId: 'calendar-7',
          syncDueDates: false,
          syncTaskReminders: true,
          syncFollowUps: false,
          syncFollowUpReminders: false,
          syncRecurrence: false,
        ),
      ),
      executor: executor,
      linkStore: _Links(),
    );

    final result = await service.sync([
      CalendarReminder(
        id: 'task-due:task-1',
        title: 'موعد',
        date: DateTime(2026, 9, 16, 10),
      ),
      CalendarReminder(
        id: 'task-reminder:task-1',
        title: 'یادآوری',
        date: DateTime(2026, 9, 16, 9),
      ),
      followUp('f1'),
    ]);

    expect(result?.created, 1);
    expect(executor.receivedPlan?.items.single.reminderId, 'task-reminder:task-1');
  });

  test('disabled source does not delete its existing external link', () async {
    final reminder = followUp('f1');
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          autoSync: true,
          syncFollowUps: false,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links([
        ExternalCalendarEventLink(
          reminderId: reminder.id,
          calendarId: 'calendar-7',
          eventId: 'event-9',
          lastSyncedFingerprint: revision.fingerprint,
        ),
      ]),
    );

    final result = await service.sync(const <CalendarReminder>[]);
    expect(result?.deleted, 0);
    expect(executor.receivedPlan?.items, isEmpty);
  });

  test('delete policy off preserves provider event and clears stale link metadata', () async {
    final reminder = followUp('f1');
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: reminder.id,
        calendarId: 'calendar-7',
        eventId: 'event-9',
        lastSyncedFingerprint: revision.fingerprint,
      ),
    ]);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          autoSync: true,
          targetCalendarId: 'calendar-7',
          deleteLinkedEventWithTask: false,
        ),
      ),
      executor: executor,
      linkStore: links,
    );

    final result = await service.sync(const <CalendarReminder>[]);
    expect(result?.deleted, 0);
    expect(executor.receivedPlan?.items, isEmpty);
    expect(links.links, isEmpty);
  });

  test('delete policy on schedules deletion of a missing canonical reminder', () async {
    final reminder = followUp('f1');
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: reminder.id,
        calendarId: 'calendar-7',
        eventId: 'event-9',
        lastSyncedFingerprint: revision.fingerprint,
      ),
    ]);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          autoSync: true,
          targetCalendarId: 'calendar-7',
          deleteLinkedEventWithTask: true,
        ),
      ),
      executor: executor,
      linkStore: links,
    );

    final result = await service.sync(const <CalendarReminder>[]);
    expect(result?.deleted, 1);
    expect(executor.receivedPlan?.items.single.action, CalendarSyncAction.delete);
  });

  test('never exports a Task that originated from a device-calendar event', () async {
    final executor = _Executor();
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: 'external-calendar:calendar-7:instance-1',
        calendarId: 'calendar-7',
        eventId: 'instance-1',
        lastSyncedFingerprint: 'imported-task:task-1',
      ),
    ]);
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          autoSync: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: links,
    );

    final result = await service.sync([
      CalendarReminder(
        id: 'task-due:task-1',
        title: 'رویداد واردشده',
        date: DateTime(2026, 9, 16, 10),
      ),
      CalendarReminder(
        id: 'followup:task-1:f1',
        title: 'پیگیری واردشده',
        date: DateTime(2026, 9, 16, 11),
      ),
    ]);

    expect(result?.created, 0);
    expect(executor.receivedPlan?.items, isEmpty);
  });

  test('task reminder uses the canonical task-reminder source setting', () async {
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          autoSync: true,
          syncTaskReminders: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links(),
    );

    final result = await service.sync([
      CalendarReminder(
        id: 'task-reminder:task-1',
        title: 'یادآوری: خرید',
        date: DateTime(2026, 9, 16, 10),
      ),
    ]);

    expect(result?.created, 1);
    expect(executor.receivedPlan?.items.single.reminderId, 'task-reminder:task-1');
  });
}
