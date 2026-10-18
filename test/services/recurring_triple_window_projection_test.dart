import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/recurring_triple_window_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = RecurringTripleWindowProjection();
  final today = DateTime(2026, 10, 17);

  Task dailyTask({
    String id = 'task',
    DateTime? anchor,
    RecurrenceRule? rule,
    bool completed = false,
    bool allDay = false,
    Map<String, Map<String, dynamic>> history = const {},
    bool archived = false,
    bool trashed = false,
  }) =>
      Task(
        id: id,
        title: id,
        reminderDate: anchor ?? DateTime(2026, 10, 15),
        recurrence: rule ?? const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        completed: completed,
        allDay: allDay,
        occurrenceHistory: history,
        archived: archived,
        trashed: trashed,
      );

  test('projects past, today, and upcoming with exclusive midnight boundaries', () {
    final task = dailyTask(anchor: DateTime(2026, 10, 15));
    final result = projection.project(
      [task],
      localAnchorDate: DateTime(2026, 10, 17, 14, 45),
      horizonDays: 4,
    );

    expect(result.past.map((item) => item.scheduledDate).toList(), [
      DateTime(2026, 10, 15),
      DateTime(2026, 10, 16),
    ]);
    expect(result.today.map((item) => item.scheduledDate).toList(), [
      DateTime(2026, 10, 17),
    ]);
    expect(result.upcoming.map((item) => item.scheduledDate).toList(), [
      DateTime(2026, 10, 18),
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 20),
    ]);
    expect(result.upcoming.any((item) => item.scheduledDate == DateTime(2026, 10, 21)), isFalse);
  });

  test('unrecorded past occurrences are missed and unrecorded future ones pending', () {
    final result = projection.project(
      [dailyTask()],
      localAnchorDate: today,
      horizonDays: 3,
    );

    expect(result.past.map((item) => item.status).toList(), [
      RecurrenceOccurrenceStatus.missed,
      RecurrenceOccurrenceStatus.missed,
    ]);
    expect(result.today.single.status, RecurrenceOccurrenceStatus.pending);
    expect(result.upcoming.every((item) => item.status == RecurrenceOccurrenceStatus.pending), isTrue);
  });

  test('past completed, skipped, and cancelled occurrences are excluded', () {
    final task = dailyTask(
      history: {
        DateTime(2026, 10, 15).toIso8601String(): {'status': 'completed'},
        DateTime(2026, 10, 16).toIso8601String(): {'status': 'skipped'},
        DateTime(2026, 10, 17).toIso8601String(): {'status': 'cancelled'},
      },
    );
    final result = projection.project([task], localAnchorDate: today, horizonDays: 2);

    expect(result.past, isEmpty);
    // The exclusion rule is specific to the past window; today's state remains
    // visible to the caller so it can render the explicit occurrence outcome.
    expect(result.today.single.status, RecurrenceOccurrenceStatus.cancelled);
  });

  test('preserves stored missed and pending history statuses', () {
    final task = dailyTask(
      history: {
        DateTime(2026, 10, 15).toIso8601String(): {'status': 'missed'},
        DateTime(2026, 10, 16).toIso8601String(): {'status': 'pending'},
      },
    );
    final result = projection.project([task], localAnchorDate: today, horizonDays: 2);

    expect(result.past.map((item) => item.status).toList(), [
      RecurrenceOccurrenceStatus.missed,
      RecurrenceOccurrenceStatus.pending,
    ]);
  });

  test('Task.completed does not mark every recurrence completed or suppress occurrences', () {
    final task = dailyTask(completed: true);
    final result = projection.project([task], localAnchorDate: today, horizonDays: 3);

    expect(result.past, hasLength(2));
    expect(result.today, hasLength(1));
    expect(result.upcoming, hasLength(2));
    expect(result.today.single.status, RecurrenceOccurrenceStatus.pending);
  });

  test('does not mutate reminder, completion, or occurrence history', () {
    final history = <String, Map<String, dynamic>>{
      DateTime(2026, 10, 15).toIso8601String(): {
        'status': 'completed',
        'completionDate': DateTime(2026, 10, 15, 8).toIso8601String(),
      },
    };
    final task = dailyTask(
      anchor: DateTime(2026, 10, 15, 9),
      completed: false,
      history: history,
    );
    final reminderBefore = task.reminderDate;
    final historyBefore = {
      for (final entry in task.occurrenceHistory.entries)
        entry.key: Map<String, dynamic>.from(entry.value),
    };

    projection.project([task], localAnchorDate: today, horizonDays: 5);

    expect(task.reminderDate, reminderBefore);
    expect(task.completed, isFalse);
    expect(task.occurrenceHistory, historyBefore);
  });

  test('all-day occurrence exposes date-only intent without changing its anchor', () {
    final task = dailyTask(allDay: true, anchor: DateTime(2026, 10, 15));
    final result = projection.project([task], localAnchorDate: today, horizonDays: 2);

    expect(result.today.single.isAllDay, isTrue);
    expect(result.today.single.scheduledDate, DateTime(2026, 10, 17));
    expect(task.reminderDate, DateTime(2026, 10, 15));
  });

  test('respects inactive, count, and endDate recurrence constraints', () {
    final inactive = dailyTask(
      id: 'inactive',
      rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily, active: false),
    );
    final counted = dailyTask(
      id: 'counted',
      rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 2),
    );
    final ended = dailyTask(
      id: 'ended',
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        endDate: DateTime(2026, 10, 17),
      ),
    );

    final result = projection.project(
      [inactive, counted, ended],
      localAnchorDate: today,
      horizonDays: 5,
    );

    expect(result.past.map((item) => item.task.id).toSet(), {'counted', 'ended'});
    expect(result.today.map((item) => item.task.id).toSet(), {'counted'});
    expect(result.upcoming, isEmpty);
  });

  test('uses bounded windows for unbounded recurrence and rejects invalid horizon', () {
    final result = projection.project(
      [dailyTask(rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily))],
      localAnchorDate: today,
      horizonDays: 7,
    );

    expect(result.upcoming, hasLength(6));
    expect(
      () => projection.project([dailyTask()], localAnchorDate: today, horizonDays: 0),
      throwsArgumentError,
    );
  });

  test('sorts deterministically by occurrence date and then Task id', () {
    final laterId = dailyTask(id: 'z-task', anchor: DateTime(2026, 10, 15));
    final earlierId = dailyTask(id: 'a-task', anchor: DateTime(2026, 10, 15));
    final result = projection.project(
      [laterId, earlierId],
      localAnchorDate: today,
      horizonDays: 2,
    );

    expect(result.past.map((item) => item.task.id).toList(), [
      'a-task',
      'z-task',
      'a-task',
      'z-task',
    ]);
    expect(result.today.map((item) => item.task.id).toList(), ['a-task', 'z-task']);
  });

  test('returns unmodifiable lists and excludes archived or trashed tasks', () {
    final result = projection.project(
      [
        dailyTask(id: 'active'),
        dailyTask(id: 'archived', archived: true),
        dailyTask(id: 'trashed', trashed: true),
      ],
      localAnchorDate: today,
      horizonDays: 2,
    );

    expect(result.today.map((item) => item.task.id).toList(), ['active']);
    expect(() => result.past.add(result.today.single), throwsUnsupportedError);
    expect(() => result.today.clear(), throwsUnsupportedError);
    expect(() => result.upcoming.add(result.today.single), throwsUnsupportedError);
  });
}
