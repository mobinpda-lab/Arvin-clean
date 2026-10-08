enum RecurrenceOccurrenceStatus {
  pending,
  completed,
  missed,
  skipped,
  cancelled,
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  oncePerDay,
  minutes,
  hours,
}

class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.startDate,
    this.endDate,
    this.count,
    this.active = true,
  })  : assert(interval > 0),
        assert(count == null || count > 0);

  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? count;
  final bool active;

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'interval': interval,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (count != null) 'count': count,
        'active': active,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    final frequencyName = json['frequency'] as String?;
    final frequency = RecurrenceFrequency.values.firstWhere(
      (value) => value.name == frequencyName,
      orElse: () => RecurrenceFrequency.daily,
    );
    final interval = (json['interval'] as num?)?.toInt() ?? 1;
    final count = (json['count'] as num?)?.toInt();
    return RecurrenceRule(
      frequency: frequency,
      interval: interval > 0 ? interval : 1,
      startDate: json['startDate'] == null
          ? null
          : DateTime.tryParse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.tryParse(json['endDate'] as String),
      count: count != null && count > 0 ? count : null,
      active: json['active'] as bool? ?? true,
    );
  }

  DateTime nextOccurrence(DateTime from) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
      case RecurrenceFrequency.oncePerDay:
        return from.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return from.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.monthly:
        final targetMonth = from.month - 1 + interval;
        final year = from.year + targetMonth ~/ 12;
        final month = targetMonth % 12 + 1;
        final day = from.day;
        final lastDay = DateTime(year, month + 1, 0).day;
        return DateTime(
          year,
          month,
          day > lastDay ? lastDay : day,
          from.hour,
          from.minute,
          from.second,
          from.millisecond,
          from.microsecond,
        );
      case RecurrenceFrequency.yearly:
        final year = from.year + interval;
        final lastDay = DateTime(year, from.month + 1, 0).day;
        return DateTime(
          year,
          from.month,
          from.day > lastDay ? lastDay : from.day,
          from.hour,
          from.minute,
          from.second,
          from.millisecond,
          from.microsecond,
        );
      case RecurrenceFrequency.minutes:
        return from.add(Duration(minutes: interval));
      case RecurrenceFrequency.hours:
        return from.add(Duration(hours: interval));
    }
  }

  /// Returns every recurrence occurrence intersecting [from, to).
  ///
  /// [anchor] is the original canonical scheduled instant. The canonical
  /// Task is never mutated and no occurrence is persisted.
  List<DateTime> occurrencesBetween({
    required DateTime anchor,
    required DateTime from,
    required DateTime to,
  }) {
    if (!active || !from.isBefore(to)) return const [];

    final cycleStart = startDate ?? anchor;
    final cycleEnd = endDate;
    if (cycleEnd != null && !cycleStart.isBefore(cycleEnd)) return const [];
    if (cycleEnd != null && !from.isBefore(cycleEnd)) return const [];
    if (to.isBefore(cycleStart)) return const [];

    var first = cycleStart;
    if (first.isBefore(from)) {
      first = resumeFromToday(scheduledFrom: anchor, target: from);
    }

    final result = <DateTime>[];
    var occurrence = first;
    var index = 0;
    while (occurrence.isBefore(to)) {
      if (count != null && index >= count) break;
      if (cycleEnd != null && !occurrence.isBefore(cycleEnd)) break;
      if (!occurrence.isBefore(from)) {
        result.add(occurrence);
      }
      final next = nextOccurrence(occurrence);
      if (!next.isAfter(occurrence)) break;
      occurrence = next;
      index++;
    }
    return List<DateTime>.unmodifiable(result);
  }

  /// Returns the first occurrence on or after [target].
  /// The original scheduled date is never mutated.
  DateTime resumeFromToday({
    required DateTime scheduledFrom,
    required DateTime target,
  }) {
    var occurrence = scheduledFrom;
    if (!occurrence.isBefore(target)) return occurrence;

    while (occurrence.isBefore(target)) {
      occurrence = nextOccurrence(occurrence);
    }
    return occurrence;
  }
}
