import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/recurrence.dart';

void main() {
  group('RecurrenceRule weekly', () {
    test('serializes and deserializes weekly frequency', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
      );

      final restored = RecurrenceRule.fromJson(rule.toJson());

      expect(restored.frequency, RecurrenceFrequency.weekly);
      expect(restored.interval, 2);
    });

    test('calculates weekly next occurrence using interval', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
      );
      final from = DateTime(2026, 8, 15, 10, 30);

      expect(rule.nextOccurrence(from), DateTime(2026, 8, 29, 10, 30));
    });
  });

  test('calculates a custom five-day recurrence interval', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 5,
    );
    final from = DateTime(2026, 9, 28, 10, 30);
    expect(rule.nextOccurrence(from), DateTime(2026, 10, 3, 10, 30));
  });

  test('calculates a custom three-week recurrence interval', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      interval: 3,
    );
    final from = DateTime(2026, 9, 28, 10, 30);
    expect(rule.nextOccurrence(from), DateTime(2026, 10, 19, 10, 30));
  });

}
