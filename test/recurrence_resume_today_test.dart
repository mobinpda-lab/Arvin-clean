import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/recurrence.dart';

void main() {
  test('resume from today advances daily recurrence without mutating history', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.daily);
    final scheduledFrom = DateTime(2026, 8, 10);
    final resumed = rule.resumeFromToday(
      scheduledFrom: scheduledFrom,
      target: DateTime(2026, 8, 15),
    );

    expect(resumed, DateTime(2026, 8, 15));
    expect(scheduledFrom, DateTime(2026, 8, 10));
  });

  test('resume from today respects recurrence interval', () {
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 3,
    );

    expect(
      rule.resumeFromToday(
        scheduledFrom: DateTime(2026, 8, 10),
        target: DateTime(2026, 8, 15),
      ),
      DateTime(2026, 8, 16),
    );
  });

  test('resume keeps an already-current occurrence unchanged', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.monthly);

    expect(
      rule.resumeFromToday(
        scheduledFrom: DateTime(2026, 8, 15),
        target: DateTime(2026, 8, 15),
      ),
      DateTime(2026, 8, 15),
    );
  });
}
