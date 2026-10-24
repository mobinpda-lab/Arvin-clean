import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = FollowUpReminderAlarmPlanner();
  final now = DateTime(2026, 10, 6, 8);

  test('does not schedule a Task legacy reminder field without canonical migration', () {
    final task = Task(id: 'task-1', title: 'کار', reminderDate: now.add(const Duration(hours: 1)));
    expect(planner.nextAlarmAt([task], deliveredState: const {}, now: now), isNull);
  });

  test('completed archived and trashed Tasks do not schedule canonical reminders', () {
    final at = now.add(const Duration(hours: 1));
    final tasks = [
      Task(id: 'completed', title: 'تمام', completed: true, taskReminders: [TaskReminder(id: 'r1', title: 'x', date: at, sequence: 1)]),
      Task(id: 'archived', title: 'بایگانی', archived: true, taskReminders: [TaskReminder(id: 'r2', title: 'x', date: at, sequence: 1)]),
      Task(id: 'trashed', title: 'سطل', trashed: true, taskReminders: [TaskReminder(id: 'r3', title: 'x', date: at, sequence: 1)]),
    ];
    expect(planner.nextAlarmAt(tasks, deliveredState: const {}, now: now), isNull);
  });

  test('migrated legacy Task reminder uses canonical collection identity once', () {
    final at = now.add(const Duration(hours: 1));
    final migrated = Task.fromJson({
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'reminderDate': at.toIso8601String(),
    });
    expect(migrated.taskReminders, hasLength(1));
    expect(planner.nextAlarmAt([migrated], deliveredState: const {}, now: now), at);
    expect(
      planner.nextAlarmAt(
        [migrated],
        deliveredState: {'task:legacy-task': 'task:legacy-task@\${at.toIso8601String()}'},
        now: now,
      ),
      isNull,
    );
  });
}
