enum PrayerCompletionStatus { completed, notCompleted }

class PrayerCompletionRecord {
  const PrayerCompletionRecord({
    required this.day,
    required this.prayerId,
    required this.status,
    required this.updatedAt,
  });

  final DateTime day;
  final String prayerId;
  final PrayerCompletionStatus status;
  final DateTime updatedAt;

  DateTime get localDay => DateTime(day.year, day.month, day.day);

  String get identity =>
      '${localDay.year.toString().padLeft(4, '0')}-'
      '${localDay.month.toString().padLeft(2, '0')}-'
      '${localDay.day.toString().padLeft(2, '0')}::$prayerId';
}

/// Read-only projection for the user-owned completion state of calculated
/// prayer-time entries.
///
/// This layer deliberately does not own prayer-time calculation, Calendar
/// source data, persistence or reporting infrastructure. It only keeps the
/// additive completion semantics required by the product contract so later
/// storage/UI/report lanes can reuse the existing Calendar and report paths.
class PrayerCompletionProjection {
  const PrayerCompletionProjection();

  PrayerCompletionStatus? statusFor(
    Iterable<PrayerCompletionRecord> records, {
    required DateTime day,
    required String prayerId,
  }) {
    final key = _identity(day, prayerId);
    PrayerCompletionRecord? latest;
    for (final record in records) {
      if (record.identity != key) continue;
      if (latest == null || record.updatedAt.isAfter(latest.updatedAt)) {
        latest = record;
      }
    }
    return latest?.status;
  }

  List<PrayerCompletionRecord> latestRecords(
    Iterable<PrayerCompletionRecord> records,
  ) {
    final latestByIdentity = <String, PrayerCompletionRecord>{};
    for (final record in records) {
      final current = latestByIdentity[record.identity];
      if (current == null || record.updatedAt.isAfter(current.updatedAt)) {
        latestByIdentity[record.identity] = record;
      }
    }

    final result = latestByIdentity.values.toList(growable: false)
      ..sort((a, b) {
        final dayCompare = a.localDay.compareTo(b.localDay);
        if (dayCompare != 0) return dayCompare;
        return a.prayerId.compareTo(b.prayerId);
      });
    return List<PrayerCompletionRecord>.unmodifiable(result);
  }

  List<PrayerCompletionRecord> completed(
    Iterable<PrayerCompletionRecord> records,
  ) =>
      _filter(records, PrayerCompletionStatus.completed);

  List<PrayerCompletionRecord> notCompleted(
    Iterable<PrayerCompletionRecord> records,
  ) =>
      _filter(records, PrayerCompletionStatus.notCompleted);

  List<PrayerCompletionRecord> _filter(
    Iterable<PrayerCompletionRecord> records,
    PrayerCompletionStatus status,
  ) =>
      List<PrayerCompletionRecord>.unmodifiable(
        latestRecords(records).where((record) => record.status == status),
      );

  String _identity(DateTime day, String prayerId) {
    final localDay = DateTime(day.year, day.month, day.day);
    return '${localDay.year.toString().padLeft(4, '0')}-'
        '${localDay.month.toString().padLeft(2, '0')}-'
        '${localDay.day.toString().padLeft(2, '0')}::$prayerId';
  }
}
