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

  test('round-trips bounded repeat definition with backward-compatible fields', () {
    final rule = RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      interval: 1,
      startDate: DateTime(2026, 10, 1, 9),
      endDate: DateTime(2027, 10, 1, 9),
      count: 12,
      active: true,
    );

    final restored = RecurrenceRule.fromJson(rule.toJson());

    expect(restored.startDate, rule.startDate);
    expect(restored.endDate, rule.endDate);
    expect(restored.count, 12);
    expect(restored.active, isTrue);
  });

  test('legacy repeat JSON defaults new lifecycle fields safely', () {
    final restored = RecurrenceRule.fromJson(<String, dynamic>{
      'frequency': 'weekly',
      'interval': 2,
    });

    expect(restored.frequency, RecurrenceFrequency.weekly);
    expect(restored.interval, 2);
    expect(restored.startDate, isNull);
    expect(restored.endDate, isNull);
    expect(restored.count, isNull);
    expect(restored.active, isTrue);
  });

  test('bounded repeat stops at count without creating extra occurrences', () {
    final rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: DateTime(2026, 10, 1, 9),
      count: 3,
    );

    expect(
      rule.occurrencesBetween(
        anchor: DateTime(2026, 10, 1, 9),
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 10),
      ),
      <DateTime>[
        DateTime(2026, 10, 1, 9),
        DateTime(2026, 10, 2, 9),
        DateTime(2026, 10, 3, 9),
      ],
    );
  });

  test('inactive repeat produces no projected occurrences', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      active: false,
    );

    expect(
      rule.occurrencesBetween(
        anchor: DateTime(2026, 10, 1, 9),
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 3),
      ),
      isEmpty,
    );
  });

}
