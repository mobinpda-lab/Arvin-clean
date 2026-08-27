import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/daily_content.dart';
import 'package:arvin/services/daily_content_alarm_planner.dart';
import 'package:arvin/services/daily_content_preferences_service.dart';

DailyContentPreferences _preferences({
  bool enabled = true,
  bool notificationEnabled = true,
  int hour = 8,
  int minute = 0,
  Set<DailyContentKind>? kinds,
}) {
  return DailyContentPreferences(
    enabled: enabled,
    notificationEnabled: notificationEnabled,
    notificationHour: hour,
    notificationMinute: minute,
    enabledKinds: kinds ?? DailyContentKind.values.toSet(),
  );
}

void main() {
  const planner = DailyContentAlarmPlanner();

  test('plans later today when daily time is still ahead', () {
    final next = planner.nextAlarmAt(
      preferences: _preferences(hour: 8, minute: 30),
      now: DateTime(2026, 8, 27, 7, 0),
    );

    expect(next, DateTime(2026, 8, 27, 8, 30));
  });

  test('plans tomorrow when today time has passed', () {
    final next = planner.nextAlarmAt(
      preferences: _preferences(hour: 8, minute: 0),
      now: DateTime(2026, 8, 27, 9, 15),
    );

    expect(next, DateTime(2026, 8, 28, 8, 0));
  });

  test('exact current minute rolls to tomorrow', () {
    final next = planner.nextAlarmAt(
      preferences: _preferences(hour: 8, minute: 0),
      now: DateTime(2026, 8, 27, 8, 0),
    );

    expect(next, DateTime(2026, 8, 28, 8, 0));
  });

  test('disabled calendar content does not plan notification', () {
    expect(
      planner.nextAlarmAt(
        preferences: _preferences(enabled: false),
        now: DateTime(2026, 8, 27, 7, 0),
      ),
      isNull,
    );
  });

  test('notification opt-out and empty category set fail closed', () {
    expect(
      planner.nextAlarmAt(
        preferences: _preferences(notificationEnabled: false),
        now: DateTime(2026, 8, 27, 7, 0),
      ),
      isNull,
    );
    expect(
      planner.nextAlarmAt(
        preferences: _preferences(kinds: <DailyContentKind>{}),
        now: DateTime(2026, 8, 27, 7, 0),
      ),
      isNull,
    );
  });
}
