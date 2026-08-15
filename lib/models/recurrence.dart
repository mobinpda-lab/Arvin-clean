enum RecurrenceFrequency { daily, monthly, yearly, oncePerDay }

class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
  }) : assert(interval > 0);

  final RecurrenceFrequency frequency;
  final int interval;

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'interval': interval,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final frequencyName = json['frequency'] as String?;
    final frequency = RecurrenceFrequency.values.firstWhere(
      (value) => value.name == frequencyName,
      orElse: () => RecurrenceFrequency.daily,
    );
    final interval = (json['interval'] as num?)?.toInt() ?? 1;
    return RecurrenceRule(
      frequency: frequency,
      interval: interval > 0 ? interval : 1,
    );
  }

  DateTime nextOccurrence(DateTime from) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
      case RecurrenceFrequency.oncePerDay:
        return from.add(Duration(days: interval));
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
    }
  }
}
