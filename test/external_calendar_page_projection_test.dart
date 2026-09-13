import 'package:arvin/calendar_official_reminders.dart';
import 'package:arvin/official_calendar_page.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SettingsService extends AppSettingsService {
  _SettingsService(this.integration);

  final CalendarIntegrationSettings integration;

  @override
  Future<AppSettings> load() async => AppSettings(
        themeMode: ThemeMode.system,
        usePersianDate: true,
        fontFamily: null,
        calendarIntegration: integration,
      );
}

class _CalendarBridge extends SystemCalendarBridge {
  _CalendarBridge({required this.permissionGranted, required this.events});

  final bool permissionGranted;
  final List<DeviceCalendarEvent> events;
  bool requestedPermission = false;
  bool listedEvents = false;
  List<String> queriedCalendarIds = const [];

  @override
  Future<bool> hasReadPermission() async => permissionGranted;

  @override
  Future<bool> requestReadPermission() async {
    requestedPermission = true;
    return permissionGranted;
  }

  @override
  Future<List<DeviceCalendarEvent>> listDeviceCalendarEvents({
    required Iterable<String> calendarIds,
    required DateTime start,
    required DateTime end,
  }) async {
    listedEvents = true;
    queriedCalendarIds = calendarIds.toList(growable: false);
    return events;
  }
}

class _LinkStore extends ExternalCalendarLinkStore {
  _LinkStore([this.links = const []]);

  final List<ExternalCalendarEventLink> links;

  @override
  Future<List<ExternalCalendarEventLink>> load() async => links;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows selected external device events without prompting permission',
      (tester) async {
    final now = DateTime.now();
    final eventStart = DateTime(now.year, now.month, now.day, 10)
        .add(const Duration(days: 1));
    final bridge = _CalendarBridge(
      permissionGranted: true,
      events: [
        DeviceCalendarEvent(
          instanceId: 'instance-1',
          eventId: 'event-1',
          calendarId: 'calendar-7',
          calendarName: 'Google شخصی',
          title: 'جلسه مشتری',
          start: eventStart,
          end: eventStart.add(const Duration(hours: 1)),
          allDay: false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OfficialCalendarPage(
          service: const OfficialCalendarReminderService([]),
          years: <int>[now.year],
          initialSelectedDay: eventStart,
          settingsService: _SettingsService(
            const CalendarIntegrationSettings(
              enabled: true,
              showExternalEvents: true,
              visibleCalendarIds: {'calendar-7'},
            ),
          ),
          calendarBridge: bridge,
          externalLinkStore: _LinkStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('جلسه مشتری • Google شخصی'), findsOneWidget);
    expect(bridge.listedEvents, isTrue);
    expect(bridge.queriedCalendarIds, ['calendar-7']);
    expect(bridge.requestedPermission, isFalse);
  });

  testWidgets('permission denial fails closed and keeps calendar usable',
      (tester) async {
    final now = DateTime.now();
    final bridge = _CalendarBridge(permissionGranted: false, events: const []);

    await tester.pumpWidget(
      MaterialApp(
        home: OfficialCalendarPage(
          service: const OfficialCalendarReminderService([]),
          years: <int>[now.year],
          initialSelectedDay: now,
          settingsService: _SettingsService(
            const CalendarIntegrationSettings(
              enabled: true,
              showExternalEvents: true,
              visibleCalendarIds: {'calendar-7'},
            ),
          ),
          calendarBridge: bridge,
          externalLinkStore: _LinkStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تقویم پیگیری'), findsOneWidget);
    expect(bridge.listedEvents, isFalse);
    expect(bridge.requestedPermission, isFalse);
  });
}
