import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/calendar_provider_sync_executor.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
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

    final calendars = await bridge.listDeviceCalendars();
    final writable = calendars
        .where((item) => item.accessLevel >= 500)
        .toList(growable: false);

    if (writable.isEmpty) {
      debugPrint(
        'CALENDAR_PROVIDER_ACCEPTANCE=LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR',
      );
      return;
    }

    final calendar = writable.first;
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
      id: 'followup:acceptance-task:acceptance-followup',
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

    final noOpPlan = planner.plan(revisions: [revision], links: links);
    final noOpResult = await executor.execute(
      plan: noOpPlan,
      targetCalendarId: calendar.id,
    );
    expect(noOpResult.noOp, 1);
    expect(noOpResult.created, 0);

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
    expect(updatedEvent.single.title, updatedReminder.title);

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
      reason: 'deleted event must no longer be visible',
    );

    debugPrint(
      'CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=${calendar.id}',
    );
  });
}
