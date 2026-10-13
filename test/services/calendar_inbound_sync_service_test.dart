import 'package:arvin/calendar_page.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_inbound_sync_service.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NativeDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = NativeDatabase.memory();
    await TaskStore(executor: database).save([
      Task(
        id: 'task-1',
        title: 'کار',
        dueDate: DateTime(2026, 10, 8, 10),
      ),
    ]);
  });

  tearDown(() async {
    await database.close();
  });

  test('provider edit of FollowUp preserves independent fields and Person association', () async {
    final taskStore = TaskStore(executor: database);
    final initial = (await taskStore.load()).single;
    initial.followUps = <FollowUp>[
      FollowUp(
        id: 'f1',
        dateTime: DateTime(2026, 10, 8, 10),
        note: 'تماس',
        reminderDate: DateTime(2026, 10, 12, 9),
        nextFollowUp: DateTime(2026, 10, 14, 11),
        waitingForResponse: true,
        personIds: const ['person-1'],
      ),
    ];
    await taskStore.save([initial]);

    const reminderId = 'followup:task-1:f1';
    final canonical = CalendarReminder(
      id: reminderId,
      title: 'پیگیری: تماس',
      date: DateTime(2026, 10, 8, 10),
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: reminderId,
        calendarId: '7',
        eventId: 'followup-event-1',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge([
        DeviceCalendarEvent(
          instanceId: '99',
          eventId: 'followup-event-1',
          calendarId: '7',
          title: 'پیگیری: تماس',
          start: DateTime(2026, 10, 9, 12),
          end: DateTime(2026, 10, 9, 12, 30),
          allDay: false,
        ),
      ]),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.updated, 1);
    final refreshed = (await taskStore.load()).single.followUps.single;
    expect(refreshed.dateTime, DateTime(2026, 10, 9, 12));
    expect(refreshed.reminderDate, DateTime(2026, 10, 12, 9));
    expect(refreshed.nextFollowUp, DateTime(2026, 10, 14, 11));
    expect(refreshed.waitingForResponse, isTrue);
    expect(refreshed.personIds, ['person-1']);
  });

  test('provider edit updates linked canonical due date', () async {
    final taskStore = TaskStore(executor: database);
    final canonical = CalendarReminder(
      id: 'task-due:task-1',
      title: 'کار',
      date: DateTime(2026, 10, 8, 10),
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);

    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: 'task-due:task-1',
        calendarId: '7',
        eventId: '42',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final bridge = _Bridge([
      DeviceCalendarEvent(
        instanceId: '99',
        eventId: '42',
        calendarId: '7',
        title: 'کار تغییر یافته',
        start: DateTime(2026, 10, 9, 11),
        end: DateTime(2026, 10, 9, 11, 30),
        allDay: false,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: bridge,
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.updated, 1);
    expect(result.conflicts, 0);
    final refreshed = (await taskStore.load()).single;
    expect(refreshed.dueDate, DateTime(2026, 10, 9, 11));
    expect(refreshed.title, 'کار تغییر یافته');
  });

  test('provider edit of task reminder reschedules existing reminder foundation', () async {
    final taskStore = TaskStore(executor: database);
    final tasks = await taskStore.load();
    tasks.single.reminderDate = DateTime(2026, 10, 8, 10);
    await taskStore.save(tasks);

    final canonical = CalendarReminder(
      id: 'task-reminder:task-1',
      title: 'یادآوری: کار',
      date: DateTime(2026, 10, 8, 10),
    );
    final fingerprint =
        await CalendarSyncRevisionService().fromReminder(canonical);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: 'task-reminder:task-1',
        calendarId: '7',
        eventId: '42',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    var rescheduled = 0;
    final result = await CalendarInboundSyncService(
      bridge: _Bridge([
        DeviceCalendarEvent(
          instanceId: '99',
          eventId: '42',
          calendarId: '7',
          title: 'یادآوری: کار تغییر یافته',
          start: DateTime(2026, 10, 9, 11),
          end: DateTime(2026, 10, 9, 11, 30),
          allDay: false,
        ),
      ]),
      linkStore: links,
      taskStore: taskStore,
      reminderReschedule: () async => rescheduled++,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.updated, 1);
    expect(rescheduled, 1);
    final refreshed = (await taskStore.load()).single;
    expect(refreshed.reminderDate, DateTime(2026, 10, 9, 11));
  });

  test('provider deletion clears linked canonical due date', () async {
    final taskStore = TaskStore(executor: database);
    final canonical = CalendarReminder(
      id: 'task-due:task-1',
      title: 'کار',
      date: DateTime(2026, 10, 8, 10),
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);

    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: 'task-due:task-1',
        calendarId: '7',
        eventId: '42',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge(const []),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.deleted, 1);
    expect((await taskStore.load()).single.dueDate, isNull);
    expect(await links.load(), isEmpty);
  });

  test('conflicting Arvin and provider edits are not overwritten silently', () async {
    final taskStore = TaskStore(executor: database);
    final oldRevision = await CalendarSyncRevisionService().fromReminder(
      CalendarReminder(
        id: 'task-due:task-1',
        title: 'کار',
        date: DateTime(2026, 10, 8, 10),
      ),
    );
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: 'task-due:task-1',
        calendarId: '7',
        eventId: '42',
        lastSyncedFingerprint: oldRevision.fingerprint,
      ),
    ]);

    final tasks = await taskStore.load();
    tasks.single.dueDate = DateTime(2026, 10, 8, 12);
    await taskStore.save(tasks);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge([
        DeviceCalendarEvent(
          instanceId: '99',
          eventId: '42',
          calendarId: '7',
          title: 'کار',
          start: DateTime(2026, 10, 8, 11),
          end: DateTime(2026, 10, 8, 11, 30),
          allDay: false,
        ),
      ]),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.conflicts, 1);
    expect((await taskStore.load()).single.dueDate, DateTime(2026, 10, 8, 12));
  });

  test('provider edit updates one TaskReminder by stable ID without mutating Task title', () async {
    final taskStore = TaskStore(executor: database);
    final tasks = await taskStore.load();
    final createdAt = DateTime(2026, 10, 1, 10);
    tasks.single.taskReminders = <TaskReminder>[
      TaskReminder(
        id: 'r1',
        taskId: 'task-1',
        title: 'کار — یادآور ۱',
        date: DateTime(2026, 10, 8, 10),
        createdAt: createdAt,
        updatedAt: createdAt,
        sequence: 1,
      ),
      TaskReminder(
        id: 'r2',
        taskId: 'task-1',
        title: 'کار — یادآور ۲',
        date: DateTime(2026, 10, 8, 10),
        createdAt: createdAt,
        updatedAt: createdAt,
        sequence: 2,
      ),
    ];
    tasks.single.nextReminderSequence = 3;
    await taskStore.save(tasks);

    final canonical = CalendarReminder(
      id: 'task-reminder-item:task-1:r1',
      title: 'کار — یادآور ۱',
      date: DateTime(2026, 10, 8, 10),
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: canonical.id,
        calendarId: '7',
        eventId: 'reminder-event-1',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge([
        DeviceCalendarEvent(
          instanceId: '99',
          eventId: 'reminder-event-1',
          calendarId: '7',
          title: 'عنوان ویرایش‌شده',
          start: DateTime(2026, 10, 9, 11),
          end: DateTime(2026, 10, 9, 11, 30),
          allDay: false,
        ),
      ]),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.updated, 1);
    final refreshed = (await taskStore.load()).single;
    expect(refreshed.title, 'کار');
    expect(refreshed.taskReminders, hasLength(2));
    final first = refreshed.taskReminders.singleWhere((item) => item.id == 'r1');
    final second = refreshed.taskReminders.singleWhere((item) => item.id == 'r2');
    expect(first.title, 'عنوان ویرایش‌شده');
    expect(first.date, DateTime(2026, 10, 9, 11));
    expect(second.title, 'کار — یادآور ۲');
    expect(second.date, DateTime(2026, 10, 8, 10));
  });

  test('provider deletion removes only the linked TaskReminder', () async {
    final taskStore = TaskStore(executor: database);
    final tasks = await taskStore.load();
    final createdAt = DateTime(2026, 10, 1, 10);
    tasks.single.taskReminders = <TaskReminder>[
      TaskReminder(
        id: 'r1',
        taskId: 'task-1',
        title: 'کار — یادآور ۱',
        date: DateTime(2026, 10, 8, 10),
        createdAt: createdAt,
        updatedAt: createdAt,
        sequence: 1,
      ),
      TaskReminder(
        id: 'r2',
        taskId: 'task-1',
        title: 'کار — یادآور ۲',
        date: DateTime(2026, 10, 8, 10),
        createdAt: createdAt,
        updatedAt: createdAt,
        sequence: 2,
      ),
    ];
    tasks.single.nextReminderSequence = 3;
    await taskStore.save(tasks);

    final canonical = CalendarReminder(
      id: 'task-reminder-item:task-1:r1',
      title: 'کار — یادآور ۱',
      date: DateTime(2026, 10, 8, 10),
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: canonical.id,
        calendarId: '7',
        eventId: 'reminder-event-1',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge(const []),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.deleted, 1);
    final refreshed = (await taskStore.load()).single;
    expect(refreshed.title, 'کار');
    expect(refreshed.taskReminders, hasLength(1));
    expect(refreshed.taskReminders.single.id, 'r2');
    expect(refreshed.nextReminderSequence, 3);
    expect(await links.load(), isEmpty);
  });

  test('migrated legacy provider edit keeps old identity and does not rename Task', () async {
    final taskStore = TaskStore(executor: database);
    final legacyDate = DateTime(2026, 10, 8, 10);
    final legacyTask = Task.fromJson(<String, dynamic>{
      'id': 'task-1',
      'title': 'کار',
      'reminderDate': legacyDate.toIso8601String(),
    });
    await taskStore.save([legacyTask]);

    final canonical = CalendarReminder(
      id: 'task-reminder:task-1',
      title: 'کار — یادآور ۱',
      date: legacyDate,
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: canonical.id,
        calendarId: '7',
        eventId: 'legacy-event-1',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge([
        DeviceCalendarEvent(
          instanceId: '99',
          eventId: 'legacy-event-1',
          calendarId: '7',
          title: 'یادآور قدیمی ویرایش‌شده',
          start: DateTime(2026, 10, 9, 11),
          end: DateTime(2026, 10, 9, 11, 30),
          allDay: false,
        ),
      ]),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.updated, 1);
    final refreshed = (await taskStore.load()).single;
    expect(refreshed.title, 'کار');
    expect(refreshed.reminderDate, legacyDate);
    expect(refreshed.legacyReminderMigrationCompleted, isTrue);
    expect(refreshed.taskReminders.single.title, 'یادآور قدیمی ویرایش‌شده');
    expect(refreshed.taskReminders.single.date, DateTime(2026, 10, 9, 11));
  });


  test('provider deletion of migrated legacy reminder clears legacy mirror', () async {
    final taskStore = TaskStore(executor: database);
    final legacyDate = DateTime(2026, 10, 8, 10);
    await taskStore.save([
      Task.fromJson(<String, dynamic>{
        'id': 'task-1',
        'title': 'کار',
        'reminderDate': legacyDate.toIso8601String(),
      }),
    ]);

    final canonical = CalendarReminder(
      id: 'task-reminder:task-1',
      title: 'کار — یادآور ۱',
      date: legacyDate,
    );
    final fingerprint = await CalendarSyncRevisionService().fromReminder(canonical);
    final links = _Links([
      ExternalCalendarEventLink(
        reminderId: canonical.id,
        calendarId: '7',
        eventId: 'legacy-event-1',
        lastSyncedFingerprint: fingerprint.fingerprint,
      ),
    ]);

    final result = await CalendarInboundSyncService(
      bridge: _Bridge(const []),
      linkStore: links,
      taskStore: taskStore,
    ).reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.deleted, 1);
    final refreshed = (await taskStore.load()).single;
    expect(refreshed.reminderDate, isNull);
    expect(refreshed.taskReminders, isEmpty);
    expect(refreshed.legacyReminderMigrationCompleted, isTrue);
    expect(await links.load(), isEmpty);
  });

}

class _Links extends ExternalCalendarLinkStore {
  _Links(this.value);

  List<ExternalCalendarEventLink> value;

  @override
  Future<List<ExternalCalendarEventLink>> load() async =>
      List<ExternalCalendarEventLink>.of(value);

  @override
  Future<void> save(Iterable<ExternalCalendarEventLink> links) async {
    value = List<ExternalCalendarEventLink>.of(links);
  }
}

class _Bridge extends SystemCalendarBridge {
  _Bridge(this.events) : super(channel: const MethodChannel('test/calendar'));

  final List<DeviceCalendarEvent> events;

  @override
  Future<bool> hasReadPermission() async => true;

  @override
  Future<List<DeviceCalendarEvent>> listDeviceCalendarEvents({
    required Iterable<String> calendarIds,
    required DateTime start,
    required DateTime end,
  }) async => events;
}
