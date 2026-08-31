import 'package:arvin/calendar_integration_settings_page.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/settings_page.dart';
import 'package:flutter/material.dart';
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
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
    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('calendar-delete-linked')),
      ).value,
      isFalse,
    );
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
    expect(entry, findsOneWidget);
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.text('تقویم و همگام‌سازی'), findsWidgets);
    expect(
      find.byKey(const ValueKey('calendar-integration-enabled')),
      findsOneWidget,
    );
  });

  testWidgets('existing provider ids are presented without inventing discovery',
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
    expect(service.calendarSaveCount, 0);
  });
}
