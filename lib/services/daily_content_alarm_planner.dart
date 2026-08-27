import 'daily_content_preferences_service.dart';

class DailyContentAlarmPlanner {
  const DailyContentAlarmPlanner();

  /// Returns the next local wall-clock delivery time.
  ///
  /// Planning is intentionally pure: it does not touch Android AlarmManager,
  /// content storage or notification plugins. The platform adapter can safely
  /// reuse this contract once a verified cached item is available.
  DateTime? nextAlarmAt({
    required DailyContentPreferences preferences,
    required DateTime now,
  }) {
    if (!preferences.enabled || !preferences.notificationEnabled) return null;
    if (preferences.enabledKinds.isEmpty) return null;

    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
      preferences.notificationHour,
      preferences.notificationMinute,
    );
    if (!candidate.isAfter(now)) {
      final tomorrow = now.add(const Duration(days: 1));
      candidate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        preferences.notificationHour,
        preferences.notificationMinute,
      );
    }
    return candidate;
  }
}
