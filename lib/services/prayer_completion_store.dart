import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_completion_projection.dart';

/// Persists only user-owned prayer completion state.
///
/// Calculated prayer times remain read-only official Calendar data and are
/// never copied into Task storage.
class PrayerCompletionStore {
  const PrayerCompletionStore();

  static const key = 'arvin.prayer_completion.v1';

  Future<List<PrayerCompletionRecord>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return decode(preferences.getString(key));
  }

  Future<void> setStatus({
    required DateTime day,
    required String prayerId,
    required PrayerCompletionStatus status,
    DateTime? updatedAt,
  }) async {
    final records = await load();
    final next = <PrayerCompletionRecord>[
      ...records,
      PrayerCompletionRecord(
        day: DateTime(day.year, day.month, day.day),
        prayerId: prayerId,
        status: status,
        updatedAt: updatedAt ?? DateTime.now(),
      ),
    ];
    final latest = const PrayerCompletionProjection().latestRecords(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, encode(latest));
  }

  String encode(Iterable<PrayerCompletionRecord> records) => jsonEncode([
        for (final record in records)
          {
            'day': record.localDay.toIso8601String(),
            'prayerId': record.prayerId,
            'status': record.status.name,
            'updatedAt': record.updatedAt.toIso8601String(),
          },
      ]);

  List<PrayerCompletionRecord> decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final payload = jsonDecode(raw);
      if (payload is! List) return const [];
      final records = <PrayerCompletionRecord>[];
      for (final item in payload) {
        if (item is! Map) continue;
        final prayerId = item['prayerId'];
        final day = DateTime.tryParse(item['day']?.toString() ?? '');
        final updatedAt =
            DateTime.tryParse(item['updatedAt']?.toString() ?? '');
        final statusName = item['status']?.toString();
        PrayerCompletionStatus? status;
        for (final value in PrayerCompletionStatus.values) {
          if (value.name == statusName) {
            status = value;
            break;
          }
        }
        if (prayerId is! String ||
            prayerId.isEmpty ||
            day == null ||
            updatedAt == null ||
            status == null) {
          continue;
        }
        records.add(PrayerCompletionRecord(
          day: day,
          prayerId: prayerId,
          status: status,
          updatedAt: updatedAt,
        ));
      }
      return const PrayerCompletionProjection().latestRecords(records);
    } catch (_) {
      return const [];
    }
  }
}
