import 'package:shared_preferences/shared_preferences.dart';

enum CalendarSwipeAction { edit, trash, sync, none }

class CalendarSwipeSettings {
  const CalendarSwipeSettings({
    this.right = CalendarSwipeAction.none,
    this.left = CalendarSwipeAction.none,
  });

  final CalendarSwipeAction right;
  final CalendarSwipeAction left;

  CalendarSwipeSettings copyWith({
    CalendarSwipeAction? right,
    CalendarSwipeAction? left,
  }) => CalendarSwipeSettings(
        right: right ?? this.right,
        left: left ?? this.left,
      );
}

class CalendarSwipeSettingsService {
  static const _rightKey = 'arvin.settings.calendarSwipeRightAction';
  static const _leftKey = 'arvin.settings.calendarSwipeLeftAction';

  Future<CalendarSwipeSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return CalendarSwipeSettings(
      right: _decode(preferences.getString(_rightKey)),
      left: _decode(preferences.getString(_leftKey)),
    );
  }

  Future<void> save(CalendarSwipeSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_rightKey, settings.right.name);
    await preferences.setString(_leftKey, settings.left.name);
  }

  CalendarSwipeAction _decode(String? raw) =>
      CalendarSwipeAction.values.firstWhere(
        (action) => action.name == raw,
        orElse: () => CalendarSwipeAction.none,
      );
}
