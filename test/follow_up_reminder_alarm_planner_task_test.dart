import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = FollowUpReminderAlarmPlanner();
  final now = DateTime(2026, 10, 6, 8);

  test('selects Task reminder through the existing alarm planner', () {
    final at = now.add(const Duration(hours: 2));
    final task = Task(
      id: 'task-1',
      title: 'کار',
      reminderDate: at,
    );

    expect(
      planner.nextAlarmAt(
        [task],
        deliveredState: const {},
        now: now,
      ),
      at,
    );
  });

  test('does not schedule a delivered Task reminder but still schedules FollowUp work', () {
    final taskReminder = now.add(const Duration(hours: 1));
    final followUpReminder = now.add(const Duration(hours: 2));
    final task = Task(
      id: 'task-1',
      title: 'کار',
      reminderDate: taskReminder,
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: now,
          reminderDate: followUpReminder,
        ),
      ],
    );

    final result = planner.nextAlarmAt(
      [task],
      deliveredState: {
        'task:task-1': 'task:task-1@${taskReminder.toIso8601String()}',
      },
      now: now,
    );

    expect(result, followUpReminder);
  });

  test('completed Task does not schedule its reminder', () {
    final task = Task(
      id: 'task-1',
      title: 'کار',
      completed: true,
      reminderDate: now.add(const Duration(hours: 1)),
    );

    expect(
      planner.nextAlarmAt(
        [task],
        deliveredState: const {},
        now: now,
      ),
      isNull,
    );
  });

  test('plans all-day Task reminder at 09:00 local time', () {
    final createdAt = DateTime(2026, 10, 1, 10);
    final reminder = TaskReminder(
      id: 'all-day',
      taskId: 'task-all-day',
      title: 'یادآور تمام‌روز',
      date: DateTime(2026, 10, 6),
      createdAt: createdAt,
      updatedAt: createdAt,
      isAllDay: true,
      sequence: 1,
    );
    final task = Task(
      id: 'task-all-day',
      title: 'کار',
      taskReminders: [reminder],
      nextReminderSequence: 2,
    );

    expect(
      planner.nextAlarmAt(
        [task],
        deliveredState: const {},
        now: DateTime(2026, 10, 6, 8),
      ),
      DateTime(2026, 10, 6, 9),
    );
    expect(task.taskReminders.single.date, DateTime(2026, 10, 6));
  });

  test('migrated legacy reminder retains delivery identity across migration', () {
    final at = now.add(const Duration(hours: 2));
    final task = Task.fromJson(<String, dynamic>{
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'reminderDate': at.toIso8601String(),
    });

    expect(
      planner.nextAlarmAt(
        [task],
        deliveredState: {
          'task:legacy-task': 'task:legacy-task@${at.toIso8601String()}',
        },
        now: now,
      ),
      isNull,
    );
  });

}
