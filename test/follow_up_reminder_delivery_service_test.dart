import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FollowUpReminderDeliveryService();
  final now = DateTime(2026, 8, 28, 18, 15);

  Task task(
    String id, {
    bool completed = false,
    bool archived = false,
    bool trashed = false,
    DateTime? taskReminder,
    List<FollowUp> followUps = const <FollowUp>[],
    List<TaskReminder> taskReminders = const <TaskReminder>[],
  }) =>
      Task(
        id: id,
        title: 'Task $id',
        completed: completed,
        archived: archived,
        trashed: trashed,
        reminderDate: taskReminder,
        taskReminders: taskReminders,
        followUps: followUps,
      );

  FollowUp followUp(
    String id,
    DateTime? reminder, {
    String note = '',
  }) =>
      FollowUp(
        id: id,
        dateTime: DateTime(2026, 8, 28, 10),
        note: note,
        reminderDate: reminder,
      );

  test('legacy FollowUp reminder dates never create notifications', () {
    final result = service.due(
      [
        task(
          'one',
          followUps: [
            followUp('past', now.subtract(const Duration(minutes: 5))),
            followUp('now', now, note: 'تماس'),
            followUp('future', now.add(const Duration(minutes: 1))),
          ],
        ),
      ],
      now: now,
    );

    expect(result, isEmpty);
  });

  test('legacy FollowUp reminder timestamps cannot become delivery identities', () {
    final tasks = [
      task('one', followUps: [
        followUp('fu', now.subtract(const Duration(minutes: 10))),
      ]),
    ];
    expect(service.due(tasks, now: now), isEmpty);
  });

  test('inactive Tasks never produce FollowUp reminder delivery', () {
    final reminder = now.subtract(const Duration(minutes: 1));
    final result = service.due(
      [
        task('done', completed: true, followUps: [followUp('a', reminder)]),
        task('archive', archived: true, followUps: [followUp('b', reminder)]),
        task('trash', trashed: true, followUps: [followUp('c', reminder)]),
      ],
      now: now,
    );

    expect(result, isEmpty);
  });

  test('Task-level reminder is delivered by the canonical reminder service', () {
    final result = service.due(
      [
        task(
          'one',
          taskReminder: now.subtract(const Duration(minutes: 1)),
          followUps: [followUp('no-reminder', null)],
        ),
      ],
      now: now,
    );

    expect(result, hasLength(1));
    expect(result.single.isTaskReminder, isTrue);
    expect(result.single.stableKey, 'task:one');
    expect(result.single.followUpId, isNull);
    expect(result.single.scheduledAt, now.subtract(const Duration(minutes: 1)));
  });

  test('canonical Task reminder is delivered without legacy FollowUp reminder', () {
    final result = service.due(
      [
        task(
          'one',
          taskReminder: now.subtract(const Duration(minutes: 2)),
          followUps: [followUp('fu', now.subtract(const Duration(minutes: 1)))],
        ),
      ],
      now: now,
    );

    expect(result.map((item) => item.stableKey), ['task:one']);
  });

  test('legacy FollowUp notes do not produce notification candidates', () {
    final sameTime = now.subtract(const Duration(minutes: 1));
    final result = service.due([
      task('a', followUps: [followUp('y', sameTime)]),
      task('b', followUps: [followUp('z', sameTime)]),
    ], now: now);
    expect(result, isEmpty);
  });

  test('delivers multiple Task reminders with distinct stable identities', () {
    final at = now.subtract(const Duration(minutes: 2));
    final result = service.due(
      [
        task(
          'multi',
          taskReminders: [
            TaskReminder(id: 'r1', title: 'یادآور اول', date: at, sequence: 1),
            TaskReminder(id: 'r2', title: 'یادآور دوم', date: at, sequence: 2),
          ],
        ),
      ],
      now: now,
    );

    expect(result, hasLength(2));
    expect(result.map((item) => item.stableKey).toSet(), {
      'task:multi:reminder:r1',
      'task:multi:reminder:r2',
    });
    expect(result.map((item) => item.label), ['یادآور اول', 'یادآور دوم']);
  });

  test('date-only reminder notification uses 9 AM, not an inferred midnight time', () {
    final result = service.due(
      [
        task(
          'all-day',
          taskReminders: [
            TaskReminder(
              id: 'r-all-day',
              title: 'یادآور تمام‌روز',
              date: DateTime(2026, 8, 28),
              isAllDay: true,
              sequence: 1,
            ),
          ],
        ),
      ],
      now: DateTime(2026, 8, 28, 9),
    );

    expect(result, hasLength(1));
    expect(result.single.scheduledAt, DateTime(2026, 8, 28, 9));
  });
}
