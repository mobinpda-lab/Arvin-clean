enum RecurrenceFrequency {
  daily,
  weekly,
  weeklyDays,
  monthly,
  yearly,
  custom,
  oncePerDay,
}

enum RecurrenceCustomUnit { days, weeks }

class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.weekdays = const [],
    this.customUnit = RecurrenceCustomUnit.days,
  });

  final RecurrenceFrequency frequency;
  final int interval;

  /// ISO weekdays: Monday=1 ... Sunday=7. Used by [weeklyDays].
  final List<int> weekdays;

  /// Used by [custom] to express every N days or every N weeks.
  final RecurrenceCustomUnit customUnit;

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'interval': interval,
        if (weekdays.isNotEmpty) 'weekdays': weekdays,
        if (frequency == RecurrenceFrequency.custom)
          'customUnit': customUnit.name,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final frequencyName = json['frequency'] as String?;
    final frequency = RecurrenceFrequency.values.firstWhere(
      (value) => value.name == frequencyName,
      orElse: () => RecurrenceFrequency.daily,
    );
    final interval = (json['interval'] as num?)?.toInt() ?? 1;
    final rawWeekdays = json['weekdays'];
    final weekdays = rawWeekdays is List
        ? (rawWeekdays
              .whereType<num>()
              .map((value) => value.toInt())
              .where((day) => day >= 1 && day <= 7)
              .toSet()
              .toList()
            ..sort())
        : <int>[];
    final customUnitName = json['customUnit'] as String?;
    final customUnit = RecurrenceCustomUnit.values.firstWhere(
      (value) => value.name == customUnitName,
      orElse: () => RecurrenceCustomUnit.days,
    );
    return RecurrenceRule(
      frequency: frequency,
      interval: interval > 0 ? interval : 1,
      weekdays: weekdays,
      customUnit: customUnit,
    );
  }

  DateTime nextOccurrence(DateTime from) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
      case RecurrenceFrequency.oncePerDay:
        return from.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return from.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.weeklyDays:
        final selected = weekdays.toSet();
        if (selected.isEmpty) return from.add(const Duration(days: 7));
        for (var offset = 1; offset <= 7; offset++) {
          final candidate = from.add(Duration(days: offset));
          if (selected.contains(candidate.weekday)) return candidate;
        }
        return from.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        final targetMonth = from.month - 1 + interval;
        final year = from.year + targetMonth ~/ 12;
        final month = targetMonth % 12 + 1;
        final day = from.day;
        final lastDay = DateTime(year, month + 1, 0).day;
        return DateTime(year, month, day > lastDay ? lastDay : day,
            from.hour, from.minute, from.second, from.millisecond, from.microsecond);
      case RecurrenceFrequency.yearly:
        final year = from.year + interval;
        final lastDay = DateTime(year, from.month + 1, 0).day;
        return DateTime(year, from.month, from.day > lastDay ? lastDay : from.day,
            from.hour, from.minute, from.second, from.millisecond, from.microsecond);
      case RecurrenceFrequency.custom:
        return from.add(
          customUnit == RecurrenceCustomUnit.days
              ? Duration(days: interval)
              : Duration(days: 7 * interval),
        );
    }
  }

  /// Returns the first future occurrence on or after [target].
  /// The original scheduled date is never mutated.
  DateTime resumeFromToday({required DateTime scheduledFrom, required DateTime target}) {
    var occurrence = scheduledFrom;
    if (!occurrence.isBefore(target)) return occurrence;

    while (occurrence.isBefore(target)) {
      occurrence = nextOccurrence(occurrence);
    }
    return occurrence;
  }
}
