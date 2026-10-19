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

    final calendar = writable.firstWhere(
      (item) => item.displayName == 'ArvinAcceptance',
      orElse: () => writable.first,
    );
    final destinations = writable
        .where((item) => item.displayName == 'ArvinAcceptanceDestination')
        .toList(growable: false);
    final destinationCalendar =
        destinations.isEmpty ? null : destinations.first;
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

    Future<String> verifyUnrelatedEvent(
      String calendarId, {
      String? expectedEventId,
    }) async {
      final providerEvents = await bridge.listDeviceCalendarEvents(
        calendarIds: [calendarId],
        start: start.subtract(const Duration(hours: 1)),
        end: start.add(const Duration(hours: 4)),
      );
      final sentinelTitle =
          'ARVIN_UNRELATED_PRESERVATION_SENTINEL_$calendarId';
      final matching = providerEvents
          .where((event) => event.title == sentinelTitle)
          .toList(growable: false);
      expect(
        matching,
        hasLength(1),
        reason: 'The unrelated sentinel must remain in calendar $calendarId',
      );
      if (expectedEventId != null) {
        expect(
          matching.single.eventId,
          expectedEventId,
          reason: 'Unrelated event identity must remain stable',
        );
      }
      debugPrint(
        'PROVIDER_QUERY_UNRELATED calendarId=$calendarId '
        'count=${matching.length} '
        'eventIds=${matching.map((event) => event.eventId).join(",")}',
      );
      return matching.single.eventId;
    }

    final unrelatedEventId = await verifyUnrelatedEvent(calendar.id);
    final destinationUnrelatedEventId = destinationCalendar == null
        ? null
        : await verifyUnrelatedEvent(destinationCalendar.id);

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
    final createdEvents = events
        .where((event) => event.title == reminder.title)
        .toList(growable: false);
    expect(
      createdEvents,
      hasLength(1),
      reason: 'CREATE must insert exactly one matching real provider event',
    );
    expect(createdEvents.single.eventId, createdLink.eventId);
    debugPrint(
      'PROVIDER_QUERY_CREATE count=${createdEvents.length} '
      'eventIds=${createdEvents.map((event) => event.eventId).join(",")}',
    );
    await verifyUnrelatedEvent(
      calendar.id,
      expectedEventId: unrelatedEventId,
    );
    expect(
      createdEvents.any((event) => event.eventId == createdLink.eventId),
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

    events = await bridge.listDeviceCalendarEvents(
      calendarIds: [calendar.id],
      start: start.subtract(const Duration(hours: 1)),
      end: start.add(const Duration(hours: 4)),
    );
    final afterNoOpEvents = events
        .where((event) => event.title == reminder.title)
        .toList(growable: false);
    expect(
      afterNoOpEvents,
      hasLength(1),
      reason: 'NO-OP must leave exactly one matching provider event',
    );
    expect(
      afterNoOpEvents.single.eventId,
      createdLink.eventId,
      reason: 'NO-OP must preserve the real provider event identity',
    );
    debugPrint(
      'PROVIDER_QUERY_NOOP count=${afterNoOpEvents.length} '
      'eventIds=${afterNoOpEvents.map((event) => event.eventId).join(",")}',
    );
    await verifyUnrelatedEvent(
      calendar.id,
      expectedEventId: unrelatedEventId,
    );

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
    final updatedEvent = events
        .where((event) => event.eventId == createdLink.eventId)
        .toList(growable: false);
    final updatedEvents = events
        .where((event) => event.title == updatedReminder.title)
        .toList(growable: false);
    expect(updatedEvent, hasLength(1));
    expect(updatedEvent.single.title, updatedReminder.title);
    expect(updatedEvents, hasLength(1));
    expect(updatedEvents.single.eventId, createdLink.eventId);
    debugPrint(
      'PROVIDER_QUERY_UPDATE count=${updatedEvents.length} '
      'eventIds=${updatedEvents.map((event) => event.eventId).join(",")} '
      'title=${updatedEvents.single.title}',
    );
    await verifyUnrelatedEvent(
      calendar.id,
      expectedEventId: unrelatedEventId,
    );

    if (destinationCalendar != null) {
      final secondCalendar = destinationCalendar;
      final expectedDestinationUnrelatedEventId =
          destinationUnrelatedEventId!;
      // Keep the original linked event alive until destination migration is exercised.
      // The canonical executor requires the existing link to produce an update/move plan.
      final migrationRevision = CalendarReminder(
        id: reminder.id,
        title: updatedReminder.title,
        date: updatedReminder.date,
      );
      final migration = await revisionService.fromReminder(migrationRevision);
      links = await store.load();
      final migrationPlan = planner.plan(
        revisions: [migration],
        links: links,
      );
      final migrationResult = await executor.execute(
        plan: migrationPlan,
        targetCalendarId: secondCalendar.id,
      );
      expect(migrationResult.created, 0);
      expect(migrationResult.updated, 1);

      final migratedLinks = await store.load();
      expect(migratedLinks, hasLength(1));
      expect(migratedLinks.single.calendarId, secondCalendar.id);
      expect(migratedLinks.single.eventId, isNot(createdLink.eventId));

      final oldCalendarEvents = await bridge.listDeviceCalendarEvents(
        calendarIds: [calendar.id],
        start: start.subtract(const Duration(hours: 1)),
        end: start.add(const Duration(hours: 4)),
      );
      expect(
        oldCalendarEvents.any((event) => event.eventId == createdLink.eventId),
        isFalse,
        reason: 'destination migration must remove the old owned event',
      );
      await verifyUnrelatedEvent(
        calendar.id,
        expectedEventId: unrelatedEventId,
      );

      final newCalendarEvents = await bridge.listDeviceCalendarEvents(
        calendarIds: [secondCalendar.id],
        start: start.subtract(const Duration(hours: 1)),
        end: start.add(const Duration(hours: 4)),
      );
      final migratedEvents = newCalendarEvents
          .where((event) => event.title == updatedReminder.title)
          .toList(growable: false);
      expect(
        newCalendarEvents.any(
          (event) => event.eventId == migratedLinks.single.eventId,
        ),
        isTrue,
        reason: 'destination migration must expose the replacement event',
      );
      expect(migratedEvents, hasLength(1));
      expect(migratedEvents.single.eventId, migratedLinks.single.eventId);
      await verifyUnrelatedEvent(
        secondCalendar.id,
        expectedEventId: expectedDestinationUnrelatedEventId,
      );
      debugPrint(
        'PROVIDER_QUERY_MIGRATION destinationCalendarId=${secondCalendar.id} '
        'count=${migratedEvents.length} '
        'eventIds=${migratedEvents.map((event) => event.eventId).join(",")}',
      );
      debugPrint(
        'CALENDAR_PROVIDER_DESTINATION_MIGRATION=PASS from=${calendar.id} to=${secondCalendar.id}',
      );

      final cleanupPlan = planner.plan(
        revisions: const <CalendarSyncRevision>[],
        links: migratedLinks,
      );
      final cleanupResult = await executor.execute(
        plan: cleanupPlan,
        targetCalendarId: secondCalendar.id,
      );
      expect(cleanupResult.deleted, 1);
      expect(await store.load(), isEmpty);

      final eventsAfterMigrationDelete = await bridge.listDeviceCalendarEvents(
        calendarIds: [secondCalendar.id],
        start: start.subtract(const Duration(hours: 1)),
        end: start.add(const Duration(hours: 4)),
      );
      final migratedTargetPresent = eventsAfterMigrationDelete.any(
        (event) => event.eventId == migratedLinks.single.eventId,
      );
      expect(
        migratedTargetPresent,
        isFalse,
        reason: 'DELETE must remove the migrated event from the real provider',
      );
      debugPrint(
        'PROVIDER_QUERY_DELETE targetPresent=$migratedTargetPresent '
        'calendarId=${secondCalendar.id}',
      );
      await verifyUnrelatedEvent(
        calendar.id,
        expectedEventId: unrelatedEventId,
      );
      await verifyUnrelatedEvent(
        secondCalendar.id,
        expectedEventId: expectedDestinationUnrelatedEventId,
      );
    } else {
      // With one writable calendar, finish the ordinary create/update/delete acceptance.
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
      final deletedTargetPresent =
          events.any((event) => event.eventId == createdLink.eventId);
      expect(
        deletedTargetPresent,
        isFalse,
        reason: 'deleted event must no longer be visible',
      );
      debugPrint(
        'PROVIDER_QUERY_DELETE targetPresent=$deletedTargetPresent '
        'calendarId=${calendar.id}',
      );
      await verifyUnrelatedEvent(
        calendar.id,
        expectedEventId: unrelatedEventId,
      );

      debugPrint(
        'CALENDAR_PROVIDER_DESTINATION_MIGRATION=LIMITATION '
        'writableCalendars=${writable.length} '
        'seededDestination=${destinations.length}',
      );
    }

    debugPrint(
      'CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=${calendar.id}',
    );
  });
}
