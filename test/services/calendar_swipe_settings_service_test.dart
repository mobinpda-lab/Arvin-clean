import 'package:arvin/services/calendar_swipe_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('calendar swipe sides persist independently', () async {
    final service = CalendarSwipeSettingsService();
    final defaults = await service.load();
    expect(defaults.right, CalendarSwipeAction.none);
    expect(defaults.left, CalendarSwipeAction.none);

    await service.save(const CalendarSwipeSettings(
      right: CalendarSwipeAction.edit,
      left: CalendarSwipeAction.sync,
    ));

    final loaded = await service.load();
    expect(loaded.right, CalendarSwipeAction.edit);
    expect(loaded.left, CalendarSwipeAction.sync);
  });

  test('unknown legacy calendar swipe settings safely default to none', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.settings.calendarSwipeRightAction': 'unknown',
      'arvin.settings.calendarSwipeLeftAction': 'delete-forever',
    });
    final loaded = await CalendarSwipeSettingsService().load();
    expect(loaded.right, CalendarSwipeAction.none);
    expect(loaded.left, CalendarSwipeAction.none);
  });
}
