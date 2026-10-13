/// Product policy for local notification time of date-only reminders.
/// Stored as minutes after local midnight so users can choose any minute.
const int defaultAllDayReminderNotificationMinutes = 9 * 60;

int normalizeAllDayReminderNotificationMinutes(int? value) {
  if (value == null || value < 0 || value >= 24 * 60) {
    return defaultAllDayReminderNotificationMinutes;
  }
  return value;
}
