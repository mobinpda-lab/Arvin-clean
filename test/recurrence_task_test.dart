import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('daily recurrence advances by one day', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.daily);
    expect(rule.nextOccurrence(DateTime(2026, 8, 15)), DateTime(2026, 8, 16));
  });

  test('monthly recurrence clamps to the last day of the target month', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.monthly);
    expect(rule.nextOccurrence(DateTime(2026, 1, 31)), DateTime(2026, 2, 28));
  });

  test('yearly recurrence clamps leap day in a non-leap year', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.yearly);
    expect(rule.nextOccurrence(DateTime(2028, 2, 29)), DateTime(2029, 2, 28));
  });

  test('recurrence is optional and legacy Task JSON remains compatible', () {
    final legacy = Task.fromJson({'id': '1', 'title': 'قدیمی'});
    expect(legacy.recurrence, isNull);

    final task = Task(
      id: '2',
      title: 'کار روزانه',
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );
    final restored = Task.fromJson(task.toJson());
    expect(restored.recurrence?.frequency, RecurrenceFrequency.daily);
    expect(restored.recurrence?.interval, 1);
  });

  test('once-per-day remains time-agnostic and uses the same recurrence rule', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.oncePerDay);
    final from = DateTime(2026, 8, 15, 9, 30);
    expect(rule.nextOccurrence(from), DateTime(2026, 8, 16, 9, 30));
  });
}
