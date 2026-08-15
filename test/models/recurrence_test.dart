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
}
