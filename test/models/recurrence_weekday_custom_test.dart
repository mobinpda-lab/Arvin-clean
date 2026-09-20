import 'package:arvin/models/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurrenceRule weekday schedules', () {
    test('selects the next configured weekday', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weeklyDays,
        weekdays: [1, 3],
      );
      expect(rule.nextOccurrence(DateTime(2026, 9, 21)), DateTime(2026, 9, 23));
    });

    test('round-trips selected weekdays', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weeklyDays,
        weekdays: [5, 1, 5],
      );
      final restored = RecurrenceRule.fromJson(rule.toJson());
      expect(restored.weekdays, [1, 5]);
    });
  });

  group('RecurrenceRule custom schedules', () {
    test('supports every N days', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.custom,
        interval: 3,
        customUnit: RecurrenceCustomUnit.days,
      );
      expect(rule.nextOccurrence(DateTime(2026, 9, 20)), DateTime(2026, 9, 23));
    });

    test('supports every N weeks', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.custom,
        interval: 2,
        customUnit: RecurrenceCustomUnit.weeks,
      );
      expect(rule.nextOccurrence(DateTime(2026, 9, 20)), DateTime(2026, 10, 4));
    });

    test('round-trips custom unit', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.custom,
        interval: 2,
        customUnit: RecurrenceCustomUnit.weeks,
      );
      final restored = RecurrenceRule.fromJson(rule.toJson());
      expect(restored.frequency, RecurrenceFrequency.custom);
      expect(restored.interval, 2);
      expect(restored.customUnit, RecurrenceCustomUnit.weeks);
    });
  });
}
