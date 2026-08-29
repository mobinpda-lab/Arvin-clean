import 'package:arvin/services/app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('device calendar integration is opt-in and conservative by default', () async {
    final settings = await AppSettingsService().load();
    final calendar = settings.calendarIntegration;

    expect(calendar.enabled, isFalse);
    expect(calendar.showExternalEvents, isFalse);
    expect(calendar.syncArvinToDevice, isFalse);
    expect(calendar.visibleCalendarIds, isEmpty);
    expect(calendar.targetCalendarId, isNull);
    expect(calendar.autoSync, isFalse);
    expect(calendar.deleteLinkedEventWithTask, isFalse);
    expect(calendar.syncDueDates, isTrue);
    expect(calendar.syncTaskReminders, isTrue);
    expect(calendar.syncFollowUps, isTrue);
    expect(calendar.syncFollowUpReminders, isTrue);
    expect(calendar.syncRecurrence, isFalse);
  });

  test('calendar preferences persist through the existing settings service', () async {
    final service = AppSettingsService();
    const calendar = CalendarIntegrationSettings(
      enabled: true,
      showExternalEvents: true,
      syncArvinToDevice: true,
      visibleCalendarIds: {'google-work', 'samsung-local'},
      targetCalendarId: 'google-work',
      syncDueDates: true,
      syncTaskReminders: false,
      syncFollowUps: true,
      syncFollowUpReminders: true,
      syncRecurrence: true,
      autoSync: true,
      deleteLinkedEventWithTask: false,
    );

    await service.saveCalendarIntegrationSettings(calendar);
    final restored = (await service.load()).calendarIntegration;

    expect(restored.enabled, isTrue);
    expect(restored.showExternalEvents, isTrue);
    expect(restored.syncArvinToDevice, isTrue);
    expect(restored.visibleCalendarIds, {'google-work', 'samsung-local'});
    expect(restored.targetCalendarId, 'google-work');
    expect(restored.syncTaskReminders, isFalse);
    expect(restored.syncRecurrence, isTrue);
    expect(restored.autoSync, isTrue);
    expect(restored.deleteLinkedEventWithTask, isFalse);
  });

  test('portable restore keeps device-specific calendar preferences local', () async {
    final service = AppSettingsService();
    await service.saveCalendarIntegrationSettings(
      const CalendarIntegrationSettings(
        enabled: true,
        showExternalEvents: true,
        targetCalendarId: 'device-calendar-7',
      ),
    );

    final restored = await service.restorePortableJson(<String, dynamic>{
      'themeMode': ThemeMode.dark.name,
      'usePersianDate': false,
      'swipeRightAction': TaskSwipeAction.archive.name,
      'swipeLeftAction': TaskSwipeAction.none.name,
    });

    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.calendarIntegration.enabled, isTrue);
    expect(restored.calendarIntegration.showExternalEvents, isTrue);
    expect(restored.calendarIntegration.targetCalendarId, 'device-calendar-7');
    expect(
      service.toPortableJson(restored).containsKey('calendarIntegration'),
      isFalse,
    );
  });
}
