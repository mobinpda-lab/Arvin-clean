import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/calendar_provider_sync_executor.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('calendar provider create no-op update delete acceptance',
      (tester) async {
    final bridge = SystemCalendarBridge();
    final readGranted =
        await bridge.hasReadPermission() || await bridge.requestReadPermission();
    final writeGranted =
        await bridge.hasWritePermission() || await bridge.requestWritePermission();

    expect(readGranted, isTrue, reason: 'READ_CALENDAR must be granted by CI');
    expect(writeGranted, isTrue, reason: 'WRITE_CALENDAR must be granted by CI');

    final calendar = await bridge.ensureArvinLocalCalendar();
    if (calendar == null ||
        !calendar.isArvinLocal ||
        calendar.accessLevel < 500) {
      debugPrint(
        'CALENDAR_PROVIDER_ACCEPTANCE=BLOCKED_ARVIN_LOCAL_CALENDAR_MISSING',
      );
      throw StateError(
        'Calendar Provider acceptance BLOCKED: the writable app-owned Arvin local calendar was not provisioned.',
      );
    }
    final store = ExternalCalendarLinkStore(
      preferencesKey: 'arvin.calendar.externalLinks.acceptance',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(store.preferencesKey);

    final executor = CalendarProviderSyncExecutor(
      bridge: bridge,
      linkStore: store,
    );
    final revisionService = CalendarSyncRevisionService();
    const planner = CalendarSyncPlanService();

    final start = DateTime.now().add(const Duration(hours: 3));
    final reminder = CalendarReminder(
      id: 'task-due:acceptance-task',
      title: 'ARVIN calendar provider acceptance',
      date: start,
    );
    final revision = await revisionService.fromReminder(reminder);

    final createPlan = planner.plan(revisions: [revision], links: const []);
    final createResult = await executor.execute(
      plan: createPlan,
      targetCalendarId: calendar.id,
    );
    expect(createResult.created, 1);
    expect(createResult.noOp, 0);

    var links = await store.load();
    expect(links, hasLength(1));
    final createdLink = links.single;

    var events = await bridge.listDeviceCalendarEvents(
      calendarIds: [calendar.id],
      start: start.subtract(const Duration(hours: 1)),
      end: start.add(const Duration(hours: 4)),
    );
    expect(
      events.any((event) => event.eventId == createdLink.eventId),
      isTrue,
      reason: 'created event must be visible through Android Calendar Provider',
    );
    debugPrint(
      'CALENDAR_PROVIDER_CREATE=PASS calendarId=${calendar.id} eventId=${createdLink.eventId} providerVisible=true',
    );

    final noOpPlan = planner.plan(revisions: [revision], links: links);
    final noOpResult = await executor.execute(
      plan: noOpPlan,
      targetCalendarId: calendar.id,
    );
    expect(noOpResult.noOp, 1);
    expect(noOpResult.created, 0);

    final eventsAfterNoOp = await bridge.listDeviceCalendarEvents(
      calendarIds: [calendar.id],
      start: start.subtract(const Duration(hours: 1)),
      end: start.add(const Duration(hours: 4)),
    );
    expect(
      eventsAfterNoOp.where((event) => event.eventId == createdLink.eventId),
      hasLength(1),
      reason: 'the original linked event must remain present exactly once',
    );
    expect(
      eventsAfterNoOp.where((event) => event.title == reminder.title),
      hasLength(1),
      reason: 'no-op update must not create a duplicate Calendar Provider event',
    );
    debugPrint(
      'CALENDAR_PROVIDER_NOOP_UPDATE=PASS calendarId=${calendar.id} eventId=${createdLink.eventId} providerEventCount=1 matchingTitleCount=1 created=${noOpResult.created}',
    );
    debugPrint('CALENDAR_PROVIDER_NOOP_NO_DUPLICATE=PASS');

    final updatedReminder = CalendarReminder(
      id: reminder.id,
      title: 'ARVIN calendar provider acceptance updated',
      date: start.add(const Duration(minutes: 15)),
    );
    final updatedRevision =
        await revisionService.fromReminder(updatedReminder);
    links = await store.load();
    final updatePlan =
        planner.plan(revisions: [updatedRevision], links: links);
    final updateResult = await executor.execute(
      plan: updatePlan,
      targetCalendarId: calendar.id,
    );
    expect(updateResult.updated, 1);

    events = await bridge.listDeviceCalendarEvents(
      calendarIds: [calendar.id],
      start: start.subtract(const Duration(hours: 1)),
      end: start.add(const Duration(hours: 4)),
    );
    final updatedEvent = events.where(
      (event) => event.eventId == createdLink.eventId,
    );
    expect(updatedEvent, hasLength(1));
    expect(updatedEvent.single.eventId, createdLink.eventId);
    expect(updatedEvent.single.title, updatedReminder.title);
    debugPrint(
      'CALENDAR_PROVIDER_UPDATE=PASS calendarId=${calendar.id} eventId=${updatedEvent.single.eventId} providerEventCount=1 title=${updatedEvent.single.title} updated=${updateResult.updated}',
    );

    links = await store.load();
    final deletePlan = planner.plan(
      revisions: const <CalendarSyncRevision>[],
      links: links,
    );
    final deleteResult = await executor.execute(
      plan: deletePlan,
      targetCalendarId: calendar.id,
    );
    expect(deleteResult.deleted, 1);
    expect(await store.load(), isEmpty);

    events = await bridge.listDeviceCalendarEvents(
      calendarIds: [calendar.id],
      start: start.subtract(const Duration(hours: 1)),
      end: start.add(const Duration(hours: 4)),
    );
    expect(
      events.any((event) => event.eventId == createdLink.eventId),
      isFalse,
      reason: 'deleted Arvin event must no longer be visible',
    );
    debugPrint(
      'CALENDAR_PROVIDER_DELETE=PASS calendarId=${calendar.id} eventId=${createdLink.eventId} providerVisible=false deleted=${deleteResult.deleted}',
    );

    debugPrint(
      'CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=${calendar.id}',
    );
  });

  testWidgets('provider event deletion never deletes the canonical Task', (tester) async {
    final bridge = SystemCalendarBridge();
    final writeGranted =
        await bridge.hasWritePermission() || await bridge.requestWritePermission();
    expect(writeGranted, isTrue);
    final calendar = await bridge.ensureArvinLocalCalendar();
    expect(calendar, isNotNull);
    expect(calendar!.isArvinLocal, isTrue);

    final taskStore = TaskStore();
    final before = await taskStore.load();
    final taskId = 'calendar-delete-survival-${DateTime.now().microsecondsSinceEpoch}';
    final task = Task(
      id: taskId,
      title: 'Calendar deletion survival acceptance',
      description: 'Canonical Task must survive provider-side event deletion.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    );
    await taskStore.save(<Task>[...before, task]);

    final reminderId = 'task-due:$taskId';
    final start = DateTime.now().add(const Duration(hours: 5));
    try {
      final eventId = await bridge.createProviderEvent(
        reminderId: reminderId,
        calendarId: calendar.id,
        title: task.title,
        start: start,
        end: start.add(const Duration(minutes: 30)),
        allDay: false,
        description: task.description,
      );
      expect(eventId, isNotNull);

      final deleted = await bridge.deleteProviderEvent(
        reminderId: reminderId,
        calendarId: calendar.id,
        eventId: eventId!,
      );
      expect(deleted, isTrue);

      final after = await taskStore.load();
      final persisted = after.singleWhere((item) => item.id == taskId);
      expect(persisted.title, task.title);
      expect(persisted.description, task.description);
      expect(persisted.dueDate, task.dueDate);
      debugPrint(
        'CALENDAR_TASK_SURVIVAL_AFTER_PROVIDER_DELETE=PASS taskId=$taskId eventId=$eventId',
      );
    } finally {
      await taskStore.save(before);
    }
  });

}
