import 'prayer_completion_projection.dart';

class PrayerCompletionReportSummary {
  const PrayerCompletionReportSummary({
    required this.startDay,
    required this.endDay,
    required this.completedCount,
    required this.notCompletedCount,
    required this.missed,
  });

  final DateTime startDay;
  final DateTime endDay;
  final int completedCount;
  final int notCompletedCount;
  final List<PrayerCompletionRecord> missed;

  int get decidedCount => completedCount + notCompletedCount;
}

class PrayerCompletionReportProjection {
  const PrayerCompletionReportProjection({
    this.completionProjection = const PrayerCompletionProjection(),
  });

  final PrayerCompletionProjection completionProjection;

  PrayerCompletionReportSummary build(
    Iterable<PrayerCompletionRecord> records, {
    required DateTime startDay,
    required DateTime endDay,
  }) {
    final start = _day(startDay);
    final end = _day(endDay);
    if (end.isBefore(start)) {
      throw ArgumentError.value(endDay, 'endDay', 'must not be before startDay');
    }

    final ranged = completionProjection
        .latestRecords(records)
        .where(
          (record) =>
              !record.localDay.isBefore(start) && !record.localDay.isAfter(end),
        )
        .toList(growable: false);
    final completed = ranged
        .where((record) => record.status == PrayerCompletionStatus.completed)
        .length;
    final missed = ranged
        .where((record) => record.status == PrayerCompletionStatus.notCompleted)
        .toList(growable: false);

    return PrayerCompletionReportSummary(
      startDay: start,
      endDay: end,
      completedCount: completed,
      notCompletedCount: missed.length,
      missed: List<PrayerCompletionRecord>.unmodifiable(missed),
    );
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}
