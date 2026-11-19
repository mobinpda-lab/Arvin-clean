import 'package:arvin/services/calendar_swipe_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('legacy Calendar swipe edit/delete settings retire to no action', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.settings.calendarSwipeRightAction': 'edit',
      'arvin.settings.calendarSwipeLeftAction': 'trash',
    });
    final loaded = await CalendarSwipeSettingsService().load();
    expect(loaded.right, CalendarSwipeAction.none);
    expect(loaded.left, CalendarSwipeAction.none);
  });

  test('only explicit Device Calendar sync survives swipe persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final service = CalendarSwipeSettingsService();
    await service.save(const CalendarSwipeSettings(
      right: CalendarSwipeAction.sync,
      left: CalendarSwipeAction.edit,
    ));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('arvin.settings.calendarSwipeRightAction'), 'sync');
    expect(prefs.getString('arvin.settings.calendarSwipeLeftAction'), 'none');
    final loaded = await service.load();
    expect(loaded.right, CalendarSwipeAction.sync);
    expect(loaded.left, CalendarSwipeAction.none);
  });
}
