import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/prayer_completion_projection.dart';
import 'package:arvin/services/prayer_completion_report_projection.dart';

PrayerCompletionRecord _record({
  required DateTime day,
  required String prayerId,
  required PrayerCompletionStatus status,
  required DateTime updatedAt,
}) =>
    PrayerCompletionRecord(
      day: day,
      prayerId: prayerId,
      status: status,
      updatedAt: updatedAt,
    );

void main() {
  const projection = PrayerCompletionReportProjection();

  test('report uses latest status and inclusive date range', () {
    final records = [
      _record(
        day: DateTime(2026, 9, 14),
        prayerId: 'prayer-tehran-2026-09-14-fajr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 9, 14, 8),
      ),
      _record(
        day: DateTime(2026, 9, 15),
        prayerId: 'prayer-tehran-2026-09-15-fajr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 9, 15, 8),
      ),
      _record(
        day: DateTime(2026, 9, 15),
        prayerId: 'prayer-tehran-2026-09-15-fajr',
        status: PrayerCompletionStatus.completed,
        updatedAt: DateTime(2026, 9, 15, 9),
      ),
      _record(
        day: DateTime(2026, 9, 15),
        prayerId: 'prayer-tehran-2026-09-15-dhuhr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 9, 15, 13),
      ),
    ];

    final summary = projection.build(
      records,
      startDay: DateTime(2026, 9, 15),
      endDay: DateTime(2026, 9, 15, 23, 59),
    );

    expect(summary.completedCount, 1);
    expect(summary.notCompletedCount, 1);
    expect(summary.decidedCount, 2);
    expect(summary.missed.single.prayerId, endsWith('-dhuhr'));
  });

  test('report keeps different days distinct and rejects reversed range', () {
    final records = [
      _record(
        day: DateTime(2026, 9, 14),
        prayerId: 'prayer-tehran-2026-09-14-isha',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 9, 14, 22),
      ),
      _record(
        day: DateTime(2026, 9, 15),
        prayerId: 'prayer-tehran-2026-09-15-isha',
        status: PrayerCompletionStatus.completed,
        updatedAt: DateTime(2026, 9, 15, 22),
      ),
    ];

    final summary = projection.build(
      records,
      startDay: DateTime(2026, 9, 14),
      endDay: DateTime(2026, 9, 15),
    );
    expect(summary.completedCount, 1);
    expect(summary.notCompletedCount, 1);

    expect(
      () => projection.build(
        records,
        startDay: DateTime(2026, 9, 16),
        endDay: DateTime(2026, 9, 15),
      ),
      throwsArgumentError,
    );
  });
}
