import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/calendar_rescheduling_advisor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const advisor = CalendarReschedulingAdvisor();

  CalendarReminder reminder(
    String id,
    int hour, [
    int minute = 0,
    bool completed = false,
    bool isAllDay = false,
  ]) {
    return CalendarReminder(
      id: id,
      title: id,
      date: DateTime(2026, 8, 27, hour, minute),
      completed: completed,
      isAllDay: isAllDay,
    );
  }

  test('returns deterministic replacement times for a conflicting reminder', () {
    final advice = advisor.advise(
      reminders: [
        reminder('target', 9),
        reminder('busy', 9, 15),
      ],
      reminderId: 'target',
      windowStart: DateTime(2026, 8, 27, 9),
      windowEnd: DateTime(2026, 8, 27, 11),
      step: const Duration(minutes: 15),
      limit: 2,
    );

    expect(advice.state, CalendarReschedulingAdviceState.conflict);
    expect(advice.hasConflict, isTrue);
    expect(advice.target?.ownerId, 'target');
    expect(advice.conflicts, hasLength(1));
    expect(advice.conflicts.single.overlap, const Duration(minutes: 15));
    expect(
      advice.suggestions.map((item) => item.start).toList(),
      [
        DateTime(2026, 8, 27, 9, 45),
        DateTime(2026, 8, 27, 10),
      ],
    );
    expect(
      advice.suggestions.every(
        (item) => item.end.difference(item.start) == const Duration(minutes: 30),
      ),
      isTrue,
    );
  });

  test('returns no-conflict without inventing replacement suggestions', () {
    final advice = advisor.advise(
      reminders: [
        reminder('target', 9),
        reminder('later', 10),
      ],
      reminderId: 'target',
      windowStart: DateTime(2026, 8, 27, 9),
      windowEnd: DateTime(2026, 8, 27, 12),
    );

    expect(advice.state, CalendarReschedulingAdviceState.noConflict);
    expect(advice.hasConflict, isFalse);
    expect(advice.target?.ownerId, 'target');
    expect(advice.conflicts, isEmpty);
    expect(advice.suggestions, isEmpty);
  });

  test('completed, all-day, and missing targets are explicitly unavailable', () {
    for (final reminders in <List<CalendarReminder>>[
      [reminder('target', 9, 0, true)],
      [reminder('target', 9, 0, false, true)],
      [reminder('other', 9)],
    ]) {
      final advice = advisor.advise(
        reminders: reminders,
        reminderId: 'target',
        windowStart: DateTime(2026, 8, 27, 9),
        windowEnd: DateTime(2026, 8, 27, 12),
      );

      expect(advice.state, CalendarReschedulingAdviceState.targetUnavailable);
      expect(advice.target, isNull);
      expect(advice.conflicts, isEmpty);
      expect(advice.suggestions, isEmpty);
    }
  });

  test('only conflicts involving the selected reminder are reported', () {
    final advice = advisor.advise(
      reminders: [
        reminder('target', 9),
        reminder('target-busy', 9, 15),
        reminder('other-a', 11),
        reminder('other-b', 11, 15),
      ],
      reminderId: 'target',
      windowStart: DateTime(2026, 8, 27, 9),
      windowEnd: DateTime(2026, 8, 27, 13),
      limit: 1,
    );

    expect(advice.conflicts, hasLength(1));
    final conflict = advice.conflicts.single;
    expect(
      {conflict.first.ownerId, conflict.second.ownerId},
      {'target', 'target-busy'},
    );
  });

  test('rejects an empty selected reminder id', () {
    expect(
      () => advisor.advise(
        reminders: const [],
        reminderId: '',
        windowStart: DateTime(2026, 8, 27, 9),
        windowEnd: DateTime(2026, 8, 27, 12),
      ),
      throwsArgumentError,
    );
  });
}
