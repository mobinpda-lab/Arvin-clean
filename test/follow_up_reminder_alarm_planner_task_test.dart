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

  test('selects earliest independent Task reminder through the existing alarm planner', () {
    final first = now.add(const Duration(hours: 1));
    final second = now.add(const Duration(hours: 2));
    final task = Task(
      id: 'multi',
      title: 'کار',
      taskReminders: [
        TaskReminder(id: 'r1', title: 'اول', date: first, sequence: 1),
        TaskReminder(id: 'r2', title: 'دوم', date: second, sequence: 2),
      ],
    );

    expect(
      planner.nextAlarmAt([task], deliveredState: const {}, now: now),
      first,
    );
  });

  test('migrated legacy Task reminder keeps delivery identity and is not scheduled twice', () {
    final at = now.add(const Duration(hours: 1));
    final migrated = Task.fromJson({
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'reminderDate': at.toIso8601String(),
    });

    expect(migrated.legacyTaskReminderMigrationVersion, 1);
    expect(migrated.taskReminders, hasLength(1));
    expect(
      planner.nextAlarmAt([migrated], deliveredState: const {}, now: now),
      at,
    );
    expect(
      planner.nextAlarmAt(
        [migrated],
        deliveredState: {
          'task:legacy-task': 'task:legacy-task@${at.toIso8601String()}',
        },
        now: now,
      ),
      isNull,
      reason: 'the pre-migration delivery record must suppress the migrated reminder',
    );
  });


}
