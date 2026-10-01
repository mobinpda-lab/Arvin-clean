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

  test('supports minute intervals across midnight', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.minutes,
      interval: 90,
    );
    final from = DateTime(2026, 10, 1, 23);
    expect(rule.nextOccurrence(from), DateTime(2026, 10, 2, 0, 30));
  });

  test('supports hour intervals', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.hours,
      interval: 2,
    );
    final from = DateTime(2026, 10, 1, 23);
    expect(rule.nextOccurrence(from), DateTime(2026, 10, 2, 1));
  });

  test('projects all minute occurrences in a visible range', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.minutes,
      interval: 20,
    );
    final occurrences = rule.occurrencesBetween(
      anchor: DateTime(2026, 10, 1, 23, 40),
      from: DateTime(2026, 10, 2),
      to: DateTime(2026, 10, 2, 1, 1),
    );
    expect(
      occurrences,
      <DateTime>[
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 2, 0, 20),
        DateTime(2026, 10, 2, 0, 40),
        DateTime(2026, 10, 2, 1),
      ],
    );
  });

  test('does not mutate the canonical anchor while projecting', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 1,
    );
    final anchor = DateTime(2026, 10, 1, 14);
    final occurrences = rule.occurrencesBetween(
      anchor: anchor,
      from: DateTime(2026, 10, 3),
      to: DateTime(2026, 10, 5),
    );
    expect(anchor, DateTime(2026, 10, 1, 14));
    expect(occurrences, <DateTime>[
      DateTime(2026, 10, 3, 14),
      DateTime(2026, 10, 4, 14),
    ]);
  });

}
