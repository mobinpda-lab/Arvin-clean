import 'package:shared_preferences/shared_preferences.dart';

enum BackupFrequency { daily, weekly, monthly }

class BackupSchedule {
  const BackupSchedule({
    required this.enabled,
    required this.hour,
    required this.minute,
    this.frequency = BackupFrequency.daily,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final BackupFrequency frequency;

  static const int defaultHour = 3;
  static const int defaultMinute = 0;
  static const String enabledKey = 'arvin.backup.schedule.enabled';
  static const String hourKey = 'arvin.backup.schedule.hour';
  static const String minuteKey = 'arvin.backup.schedule.minute';
  static const String frequencyKey = 'arvin.backup.schedule.frequency';

  factory BackupSchedule.disabled() => const BackupSchedule(
        enabled: false,
        hour: defaultHour,
        minute: defaultMinute,
      );

  BackupSchedule copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    BackupFrequency? frequency,
  }) =>
      BackupSchedule(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        frequency: frequency ?? this.frequency,
      );

  DateTime nextRun([DateTime? now]) {
    final current = now ?? DateTime.now();
    var next = DateTime(current.year, current.month, current.day, hour, minute);
    if (!next.isAfter(current)) {
      switch (frequency) {
        case BackupFrequency.daily:
          next = next.add(const Duration(days: 1));
        case BackupFrequency.weekly:
          next = next.add(const Duration(days: 7));
        case BackupFrequency.monthly:
          final nextMonth = next.month == 12 ? 1 : next.month + 1;
          final nextYear = next.month == 12 ? next.year + 1 : next.year;
          final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
          next = DateTime(
            nextYear,
            nextMonth,
            next.day > lastDay ? lastDay : next.day,
            hour,
            minute,
          );
      }
    }
    return next;
  }

  Map<String, dynamic> toPortableJson() => <String, dynamic>{
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'frequency': frequency.name,
      };

  static BackupSchedule decodePortableJson(Map<String, dynamic> json) {
    final enabled = json['enabled'];
    final hour = json['hour'];
    final minute = json['minute'];
    final rawFrequency = json['frequency'];
    if (enabled != null && enabled is! bool) {
      throw const FormatException('Arvin backup schedule enabled setting is invalid');
    }
    if (hour != null && hour is! int) {
      throw const FormatException('Arvin backup schedule hour setting is invalid');
    }
    if (minute != null && minute is! int) {
      throw const FormatException('Arvin backup schedule minute setting is invalid');
    }
    if (rawFrequency != null && rawFrequency is! String) {
      throw const FormatException('Arvin backup schedule frequency is invalid');
    }
    var frequency = BackupFrequency.daily;
    if (rawFrequency is String) {
      frequency = BackupFrequency.values.firstWhere(
        (item) => item.name == rawFrequency,
        orElse: () => throw const FormatException(
          'Arvin backup schedule frequency is unsupported',
        ),
      );
    }
    return BackupSchedule(
      enabled: enabled as bool? ?? false,
      hour: _validHour(hour as int? ?? defaultHour),
      minute: _validMinute(minute as int? ?? defaultMinute),
      frequency: frequency,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, enabled);
    await prefs.setInt(hourKey, hour);
    await prefs.setInt(minuteKey, minute);
    await prefs.setString(frequencyKey, frequency.name);
  }

  static Future<BackupSchedule> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(frequencyKey);
    final frequency = raw == null
        ? BackupFrequency.daily
        : BackupFrequency.values.firstWhere(
            (item) => item.name == raw,
            orElse: () => BackupFrequency.daily,
          );
    return BackupSchedule(
      enabled: prefs.getBool(enabledKey) ?? false,
      hour: _validHour(prefs.getInt(hourKey) ?? defaultHour),
      minute: _validMinute(prefs.getInt(minuteKey) ?? defaultMinute),
      frequency: frequency,
    );
  }

  static int _validHour(int value) => value.clamp(0, 23);
  static int _validMinute(int value) => value.clamp(0, 59);
}
