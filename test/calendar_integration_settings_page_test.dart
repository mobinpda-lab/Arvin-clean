import 'package:arvin/calendar_integration_settings_page.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:arvin/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CountingSettingsService extends AppSettingsService {
  _CountingSettingsService(this.current);

  AppSettings current;
  int calendarSaveCount = 0;

  @override
  Future<AppSettings> load() async => current;

  @override
  Future<void> saveCalendarIntegrationSettings(
    CalendarIntegrationSettings settings,
  ) async {
    calendarSaveCount += 1;
    current = current.copyWith(calendarIntegration: settings);
  }
}

AppSettings _appSettings({
  CalendarIntegrationSettings calendar = const CalendarIntegrationSettings(),
}) {
  return AppSettings(
    themeMode: ThemeMode.system,
    usePersianDate: true,
    fontFamily: null,
    calendarIntegration: calendar,
  );
}

Future<void> _scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const calendarChannel = MethodChannel(SystemCalendarBridge.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    messenger.setMockMethodCallHandler(calendarChannel, null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(calendarChannel, null);
  });

  testWidgets('calendar settings load is non-mutating and delete stays off',
      (tester) async {
    final service = _CountingSettingsService(_appSettings());

    await tester.pumpWidget(
      MaterialApp(home: CalendarIntegrationSettingsPage(service: service)),
    );
    await tester.pumpAndSettle();

    expect(service.calendarSaveCount, 0);
    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('calendar-integration-enabled')),
      ).value,
      isFalse,
    );

    final deleteSwitch = find.byKey(const ValueKey('calendar-delete-linked'));
    await _scrollUntilVisible(tester, deleteSwitch);
    expect(
      tester.widget<SwitchListTile>(deleteSwitch).value,
      isFalse,
    );
    expect(service.calendarSaveCount, 0);
  });

  testWidgets('calendar toggles persist through canonical settings service',
      (tester) async {
    final service = AppSettingsService();

    await tester.pumpWidget(
      MaterialApp(home: CalendarIntegrationSettingsPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('calendar-integration-enabled')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('calendar-show-external-events')),
    );
    await tester.pumpAndSettle();

    final restored = (await service.load()).calendarIntegration;
    expect(restored.enabled, isTrue);
    expect(restored.showExternalEvents, isTrue);
    expect(restored.deleteLinkedEventWithTask, isFalse);
  });

  testWidgets('main Settings exposes calendar integration entry',
      (tester) async {
    final service = AppSettingsService();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          service: service,
          onSettingsChanged: (_) {},
          onOpenBackup: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final entry = find.byKey(
      const ValueKey('calendar-integration-settings-entry'),
    );
    await _scrollUntilVisible(tester, entry);
    expect(entry, findsOneWidget);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.text('تقویم و همگام‌سازی'), findsWidgets);
    expect(
      find.byKey(const ValueKey('calendar-integration-enabled')),
      findsOneWidget,
    );
  });

  testWidgets('existing provider ids remain visible before provider access',
      (tester) async {
    final service = _CountingSettingsService(
      _appSettings(
        calendar: const CalendarIntegrationSettings(
          targetCalendarId: 'google-work',
          visibleCalendarIds: {'google-work', 'samsung-local'},
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: CalendarIntegrationSettingsPage(service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('google-work'), findsWidgets);
    expect(find.textContaining('2 تقویم انتخاب شده'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calendar-request-provider-permission')),
      findsOneWidget,
    );
    expect(service.calendarSaveCount, 0);
  });

  testWidgets('discovered Google and Samsung calendars can be selected',
      (tester) async {
    messenger.setMockMethodCallHandler(calendarChannel, (call) async {
      switch (call.method) {
        case SystemCalendarBridge.requestPermissionMethod:
          return true;
        case SystemCalendarBridge.listCalendarsMethod:
          return <Map<String, Object?>>[
            <String, Object?>{
              'id': '12',
              'displayName': 'Personal',
              'accountName': 'user@example.com',
              'accountType': 'com.google',
              'visible': true,
              'syncEvents': true,
              'isPrimary': true,
            },
            <String, Object?>{
              'id': '21',
              'displayName': 'Samsung Calendar',
              'accountName': 'phone',
              'accountType': 'com.osp.app.signin',
              'visible': true,
              'syncEvents': true,
              'isPrimary': false,
            },
          ];
      }
      return null;
    });

    final service = _CountingSettingsService(_appSettings());
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarIntegrationSettingsPage(
          service: service,
          calendarBridge: SystemCalendarBridge(channel: calendarChannel),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final request = find.byKey(
      const ValueKey('calendar-request-provider-permission'),
    );
    await _scrollUntilVisible(tester, request);
    await tester.tap(request);
    await tester.pumpAndSettle();

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Samsung Calendar'), findsWidgets);
    expect(find.text('Google Calendar • user@example.com'), findsOneWidget);

    final target = find.byKey(const ValueKey('calendar-target-12'));
    await _scrollUntilVisible(tester, target);
    await tester.tap(target);
    await tester.pumpAndSettle();

    final visible = find.byKey(const ValueKey('calendar-visible-21'));
    await _scrollUntilVisible(tester, visible);
    await tester.tap(visible);
    await tester.pumpAndSettle();

    final saved = service.current.calendarIntegration;
    expect(saved.targetCalendarId, '12');
    expect(saved.visibleCalendarIds, contains('21'));
    expect(service.calendarSaveCount, 2);
  });

  testWidgets('selected target status shows discovered calendar label',
      (tester) async {
    messenger.setMockMethodCallHandler(calendarChannel, (call) async {
      switch (call.method) {
        case SystemCalendarBridge.requestPermissionMethod:
          return true;
        case SystemCalendarBridge.listCalendarsMethod:
          return <Map<String, Object?>>[
            <String, Object?>{
              'id': '12',
              'displayName': 'Personal',
              'accountName': 'user@example.com',
              'accountType': 'com.google',
              'visible': true,
              'syncEvents': true,
              'isPrimary': true,
            },
          ];
      }
      return null;
    });

    final service = _CountingSettingsService(
      _appSettings(
        calendar: const CalendarIntegrationSettings(targetCalendarId: '12'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarIntegrationSettingsPage(
          service: service,
          calendarBridge: SystemCalendarBridge(channel: calendarChannel),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final request = find.byKey(
      const ValueKey('calendar-request-provider-permission'),
    );
    await _scrollUntilVisible(tester, request);
    await tester.tap(request);
    await tester.pumpAndSettle();

    final status = find.byKey(const ValueKey('calendar-target-status'));
    await tester.ensureVisible(status);
    await tester.pumpAndSettle();
    final statusTile = tester.widget<ListTile>(status);
    expect(statusTile.subtitle, isA<Text>());
    expect((statusTile.subtitle! as Text).data, 'Personal • Google Calendar • user@example.com');
    expect(find.textContaining('شناسه فعلی: 12'), findsNothing);
    expect(service.calendarSaveCount, 0);
  });

  testWidgets('permission request reveals provider list without settings write',
      (tester) async {
    messenger.setMockMethodCallHandler(calendarChannel, (call) async {
      switch (call.method) {
        case SystemCalendarBridge.requestPermissionMethod:
          return true;
        case SystemCalendarBridge.listCalendarsMethod:
          return <Map<String, Object?>>[
            <String, Object?>{
              'id': '7',
              'displayName': 'Work',
              'accountType': 'com.google',
            },
          ];
      }
      return null;
    });

    final service = _CountingSettingsService(_appSettings());
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarIntegrationSettingsPage(
          service: service,
          calendarBridge: SystemCalendarBridge(channel: calendarChannel),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final request = find.byKey(
      const ValueKey('calendar-request-provider-permission'),
    );
    expect(request, findsOneWidget);
    await _scrollUntilVisible(tester, request);
    await tester.tap(request);
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(service.calendarSaveCount, 0);
  });
}
