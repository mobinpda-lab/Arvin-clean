import 'package:arvin/calendar_page.dart';
import 'package:arvin/models/task.dart';
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
  _Links([this.links = const []]);
  final List<ExternalCalendarEventLink> links;

  @override
  Future<List<ExternalCalendarEventLink>> load() async => links;
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
          syncArvinToDevice: true,
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

  test('task auto-sync scopes planning to the same Task link', () async {
    final otherLink = ExternalCalendarEventLink(
      reminderId: 'task-due:other-task',
      calendarId: 'calendar-7',
      eventId: 'event-other',
      lastSyncedFingerprint: 'fingerprint-other',
    );
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          syncArvinToDevice: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links([otherLink]),
    );

    final task = Task(
      id: 'task-42',
      title: 'کار مهم',
      dueDate: DateTime(2026, 9, 29, 14, 30),
    );

    final result = await service.syncTask(task);

    expect(result?.created, 1);
    expect(executor.receivedPlan?.items.length, 1);
    expect(executor.receivedPlan?.items.single.reminderId, 'task-due:task-42');
  });

  test('canonical Task with due date is auto-sync eligible', () async {
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          syncArvinToDevice: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links(),
    );

    final task = Task(
      id: 'task-42',
      title: 'کار مهم',
      description: 'توضیح کار',
      dueDate: DateTime(2026, 9, 29, 14, 30),
    );

    final result = await service.syncTask(task);

    expect(result?.created, 1);
    expect(executor.receivedTarget, 'calendar-7');
    expect(executor.receivedPlan?.items.single.reminderId, 'task-due:task-42');
  });

  test('task with changed due date updates the existing event without duplicate create', () async {
    final task = Task(
      id: 'task-42',
      title: 'کار مهم',
      dueDate: DateTime(2026, 9, 30, 15, 0),
    );
    final reminder = CalendarReminder(
      id: 'task-due:task-42',
      title: task.title,
      description: task.description,
      date: DateTime(2026, 9, 29, 14, 0),
      completed: false,
    );
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          syncArvinToDevice: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links([
        ExternalCalendarEventLink(
          reminderId: 'task-due:task-42',
          calendarId: 'calendar-7',
          eventId: 'event-42',
          lastSyncedFingerprint: revision.fingerprint,
        ),
      ]),
    );

    final result = await service.syncTask(task);

    expect(result?.updated, 1);
    expect(result?.created, 0);
    expect(result?.deleted, 0);
    expect(executor.receivedPlan?.items.single.reminderId, 'task-due:task-42');
  });

  test('removing a Task due date deletes only that Task calendar event', () async {
    final target = ExternalCalendarEventLink(
      reminderId: 'task-due:task-42',
      calendarId: 'calendar-7',
      eventId: 'event-42',
      lastSyncedFingerprint: 'fingerprint-42',
    );
    final other = ExternalCalendarEventLink(
      reminderId: 'task-due:other-task',
      calendarId: 'calendar-7',
      eventId: 'event-other',
      lastSyncedFingerprint: 'fingerprint-other',
    );
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          syncArvinToDevice: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links([target, other]),
    );

    final result = await service.syncTask(
      Task(id: 'task-42', title: 'کار مهم'),
    );

    expect(result?.deleted, 1);
    expect(result?.created, 0);
    expect(executor.receivedPlan?.items.single.reminderId, 'task-due:task-42');
  });

  test('completing a Task with a due date removes its calendar event', () async {
    final reminder = CalendarReminder(
      id: 'task-due:task-42',
      title: 'کار مهم',
      date: DateTime(2026, 9, 29, 14),
      completed: false,
    );
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          syncArvinToDevice: true,
          targetCalendarId: 'calendar-7',
        ),
      ),
      executor: executor,
      linkStore: _Links([
        ExternalCalendarEventLink(
          reminderId: 'task-due:task-42',
          calendarId: 'calendar-7',
          eventId: 'event-42',
          lastSyncedFingerprint: revision.fingerprint,
        ),
      ]),
    );

    final result = await service.syncTask(
      Task(
        id: 'task-42',
        title: 'کار مهم',
        dueDate: reminder.date,
        completed: true,
      ),
    );

    expect(result?.deleted, 1);
    expect(result?.created, 0);
  });

  test('Task auto-sync does nothing when outbound sync is disabled', () async {
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(const CalendarIntegrationSettings()),
      executor: executor,
      linkStore: _Links(),
    );

    final result = await service.syncTask(
      Task(
        id: 'task-42',
        title: 'کار مهم',
        dueDate: DateTime(2026, 9, 29, 14),
      ),
    );

    expect(result, isNull);
    expect(executor.receivedPlan, isNull);
  });

  test('existing link produces idempotent update/no-op planning, not duplicate create', () async {
    final reminder = followUp('f1');
    final revision = await CalendarSyncRevisionService().fromReminder(reminder);
    final executor = _Executor();
    final service = CalendarOutboundSyncService(
      settingsService: _Settings(
        const CalendarIntegrationSettings(
          enabled: true,
          syncArvinToDevice: true,
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
}
