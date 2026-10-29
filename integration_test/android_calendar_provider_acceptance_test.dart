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

    const emulatorSerial = String.fromEnvironment(
      'ARVIN_EMULATOR_SERIAL',
      defaultValue: 'unknown',
    );
    const androidSdk = String.fromEnvironment(
      'ARVIN_ANDROID_SDK',
      defaultValue: 'unknown',
    );
    final readPermissionNow = await bridge.hasReadPermission();
    final writePermissionNow = await bridge.hasWritePermission();
    late final List<DeviceCalendarInfo> calendars;
    try {
      calendars = await bridge.listDeviceCalendars();
    } catch (error, stackTrace) {
      debugPrint(
        'CALENDAR_PROVIDER_SNAPSHOT=C-before-zero-assertion '
        'device=$emulatorSerial sdk=$androidSdk '
        'readPermission=$readPermissionNow writePermission=$writePermissionNow '
        'rawRowCount=QUERY_ERROR matchingRowCount=QUERY_ERROR '
        'queryErrorType=${error.runtimeType} queryError=$error',
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
    final writable = calendars
        .where(
          (item) =>
              item.accountName == 'ARVIN CI Acceptance' &&
              item.accountType == 'com.example.arvin.calendarprovisioner.account' &&
              item.accessLevel >= 500,
        )
        .toList(growable: false);

    debugPrint(
      'CALENDAR_PROVIDER_SNAPSHOT=C-before-zero-assertion '
      'device=$emulatorSerial sdk=$androidSdk '
      'readPermission=$readPermissionNow writePermission=$writePermissionNow '
      'rawRowCount=${calendars.length} matchingRowCount=${writable.length}',
    );
    for (final item in calendars) {
      final nameMatches = item.accountName == 'ARVIN CI Acceptance';
      final typeMatches =
          item.accountType == 'com.example.arvin.calendarprovisioner.account';
      debugPrint(
        'CALENDAR_PROVIDER_ROW id=${item.id} '
        'accountName=${nameMatches ? item.accountName : '<redacted-or-mismatch>'} '
        'accountType=${typeMatches ? item.accountType : '<redacted-or-mismatch>'} '
        'displayName=${item.displayName == 'ARVIN CI Acceptance' ? item.displayName : '<redacted-or-mismatch>'} '
        'accessLevel=${item.accessLevel} '
        'matchAccountName=$nameMatches matchAccountType=$typeMatches '
        'matchAccessLevel=${item.accessLevel >= 500}',
      );
    }

    if (writable.length != 1) {
      debugPrint(
        'CALENDAR_PROVIDER_ACCEPTANCE=BLOCKED_PROVISIONED_CALENDAR_MISSING count=${writable.length}',
      );
      throw StateError(
        'Calendar Provider acceptance BLOCKED: expected exactly one writable ARVIN CI Acceptance calendar; CRUD was not executed.',
      );
    }

    final calendar = writable.single;
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
    expect(updatedEvent.single.title, updatedReminder.title);

    if (writable.length >= 2) {
      // Keep the original linked event alive until destination migration is exercised.
      // The canonical executor requires the existing link to produce an update/move plan.
      final secondCalendar = writable.firstWhere((item) => item.id != calendar.id);
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

      final newCalendarEvents = await bridge.listDeviceCalendarEvents(
        calendarIds: [secondCalendar.id],
        start: start.subtract(const Duration(hours: 1)),
        end: start.add(const Duration(hours: 4)),
      );
      expect(
        newCalendarEvents.any(
          (event) => event.eventId == migratedLinks.single.eventId,
        ),
        isTrue,
        reason: 'destination migration must expose the replacement event',
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
      expect(
        events.any((event) => event.eventId == createdLink.eventId),
        isFalse,
        reason: 'deleted event must no longer be visible',
      );

      debugPrint(
        'CALENDAR_PROVIDER_DESTINATION_MIGRATION=LIMITATION writableCalendars=${writable.length}',
      );
    }

    debugPrint(
      'CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=${calendar.id}',
    );
  });
}
