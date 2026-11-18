import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/prayer_completion_projection.dart';

void main() {
  const projection = PrayerCompletionProjection();

  PrayerCompletionRecord record({
    required String prayerId,
    required PrayerCompletionStatus status,
    required DateTime updatedAt,
    DateTime? day,
  }) =>
      PrayerCompletionRecord(
        day: day ?? DateTime(2026, 8, 29, 12),
        prayerId: prayerId,
        status: status,
        updatedAt: updatedAt,
      );

  test('latest status wins for the same local day and prayer identity', () {
    final records = [
      record(
        prayerId: 'dhuhr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 8, 29, 13),
      ),
      record(
        prayerId: 'dhuhr',
        status: PrayerCompletionStatus.completed,
        updatedAt: DateTime(2026, 8, 29, 14),
      ),
    ];

    expect(
      projection.statusFor(
        records,
        day: DateTime(2026, 8, 29, 23, 59),
        prayerId: 'dhuhr',
      ),
      PrayerCompletionStatus.completed,
    );
  });

  test('completed and not-completed report scopes use only latest record', () {
    final records = [
      record(
        prayerId: 'fajr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 8, 29, 6),
      ),
      record(
        prayerId: 'fajr',
        status: PrayerCompletionStatus.completed,
        updatedAt: DateTime(2026, 8, 29, 7),
      ),
      record(
        prayerId: 'maghrib',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 8, 29, 20),
      ),
    ];

    expect(projection.completed(records).map((item) => item.prayerId), ['fajr']);
    expect(
      projection.notCompleted(records).map((item) => item.prayerId),
      ['maghrib'],
    );
  });

  test('different days remain distinct even for the same prayer id', () {
    final records = [
      record(
        day: DateTime(2026, 8, 28, 8),
        prayerId: 'fajr',
        status: PrayerCompletionStatus.completed,
        updatedAt: DateTime(2026, 8, 28, 8),
      ),
      record(
        day: DateTime(2026, 8, 29, 8),
        prayerId: 'fajr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 8, 29, 8),
      ),
    ];

    expect(projection.latestRecords(records), hasLength(2));
    expect(projection.completed(records), hasLength(1));
    expect(projection.notCompleted(records), hasLength(1));
  });

  test('projection is read-only and deterministic', () {
    final records = [
      record(
        prayerId: 'isha',
        status: PrayerCompletionStatus.completed,
        updatedAt: DateTime(2026, 8, 29, 22),
      ),
      record(
        prayerId: 'asr',
        status: PrayerCompletionStatus.notCompleted,
        updatedAt: DateTime(2026, 8, 29, 17),
      ),
    ];

    final projected = projection.latestRecords(records);
    expect(projected.map((item) => item.prayerId), ['asr', 'isha']);
    expect(records.map((item) => item.prayerId), ['isha', 'asr']);
  });
}
