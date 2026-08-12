import 'package:shared_preferences/shared_preferences.dart';

/// User-facing schedule configuration for automatic backups.
///
/// This layer stores the schedule without binding the app to a specific
/// background scheduler. That keeps the backup format and preferences stable
/// while the Android background execution mechanism is added and tested next.
class BackupSchedule {
  const BackupSchedule({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;

  static const int defaultHour = 3;
  static const int defaultMinute = 0;
  static const String enabledKey = 'arvin.backup.schedule.enabled';
  static const String hourKey = 'arvin.backup.schedule.hour';
  static const String minuteKey = 'arvin.backup.schedule.minute';

  factory BackupSchedule.disabled() => const BackupSchedule(
        enabled: false,
        hour: defaultHour,
        minute: defaultMinute,
      );

  BackupSchedule copyWith({bool? enabled, int? hour, int? minute}) {
    return BackupSchedule(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  DateTime nextRun([DateTime? now]) {
    final current = now ?? DateTime.now();
    var next = DateTime(
      current.year,
      current.month,
      current.day,
      hour,
      minute,
    );
    if (!next.isAfter(current)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, enabled);
    await prefs.setInt(hourKey, hour);
    await prefs.setInt(minuteKey, minute);
  }

  static Future<BackupSchedule> load() async {
    final prefs = await SharedPreferences.getInstance();
    return BackupSchedule(
      enabled: prefs.getBool(enabledKey) ?? false,
      hour: _validHour(prefs.getInt(hourKey) ?? defaultHour),
      minute: _validMinute(prefs.getInt(minuteKey) ?? defaultMinute),
    );
  }

  static int _validHour(int value) => value.clamp(0, 23);

  static int _validMinute(int value) => value.clamp(0, 59);
}
