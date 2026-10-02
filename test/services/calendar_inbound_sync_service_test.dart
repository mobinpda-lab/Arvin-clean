import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import '../lib/models/task.dart';
import '../lib/services/calendar_inbound_sync_service.dart';
import '../lib/services/calendar_sync_plan_service.dart';
import '../lib/services/external_calendar_link_store.dart';
import '../lib/services/system_calendar_bridge.dart';
import '../lib/services/task_store.dart';

void main() {
  late NativeDatabase database;

  setUp(() async {
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
    expect((await taskStore.load()).single.dueDate, DateTime(2026, 10, 9, 11));
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
