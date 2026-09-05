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
    300,
    scrollable: find.byType(Scrollable).first,
  );
  expect(finder, findsOneWidget);
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
