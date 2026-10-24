import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = FollowUpReminderAlarmPlanner();

  test('selects nearest undelivered canonical TaskReminder', () {
    final now = DateTime(2026, 9, 8, 12);
    final task = Task(
      id: 'task-1',
      title: 'Task',
      taskReminders: [
        TaskReminder(id: 'later', title: 'بعدتر', date: DateTime(2026, 9, 8, 15), sequence: 1),
        TaskReminder(id: 'nearest', title: 'نزدیک', date: DateTime(2026, 9, 8, 13), sequence: 2),
      ],
    );
    expect(planner.nextAlarmAt([task], deliveredState: const {}, now: now), DateTime(2026, 9, 8, 13));
  });

  test('overdue undelivered canonical Reminder is retried after bounded floor', () {
    final now = DateTime(2026, 9, 8, 12);
    final task = Task(
      id: 'task-1',
      title: 'Task',
      taskReminders: [TaskReminder(id: 'r1', title: 'گذشته', date: DateTime(2026, 9, 8, 11), sequence: 1)],
    );
    expect(planner.nextAlarmAt([task], deliveredState: const {}, now: now), DateTime(2026, 9, 8, 12, 1));
  });

  test('delivered Reminder identity is skipped while a different sibling remains eligible', () {
    final now = DateTime(2026, 9, 8, 12);
    final old = DateTime(2026, 9, 8, 13);
    final later = DateTime(2026, 9, 8, 14);
    final task = Task(
      id: 'task-1',
      title: 'Task',
      taskReminders: [
        TaskReminder(id: 'r1', title: 'اول', date: old, sequence: 1),
        TaskReminder(id: 'r2', title: 'دوم', date: later, sequence: 2),
      ],
    );
    expect(
      planner.nextAlarmAt(
        [task],
        deliveredState: {'task:task-1:reminder:r1': 'task:task-1:reminder:r1@\${old.toIso8601String()}'},
        now: now,
      ),
      later,
    );
  });

  test('legacy Next Follow-up and nested Follow-up reminder do not schedule notifications', () {
    final now = DateTime(2026, 9, 8, 12);
    final task = Task(
      id: 'legacy',
      title: 'Legacy',
      reminderDate: DateTime(2026, 9, 8, 13),
      followUps: [
        FollowUp(
          id: 'fu',
          dateTime: now,
          nextFollowUp: DateTime(2026, 9, 8, 14),
          reminderDate: DateTime(2026, 9, 8, 15),
        ),
      ],
    );
    expect(planner.nextAlarmAt([task], deliveredState: const {}, now: now), isNull);
  });

  test('all-day Reminder is scheduled at the explicit morning delivery time', () {
    final now = DateTime(2026, 9, 8, 8);
    final task = Task(
      id: 'all-day',
      title: 'تمام‌روز',
      taskReminders: [
        TaskReminder(id: 'r1', title: 'تمام‌روز', date: DateTime(2026, 9, 8), isAllDay: true, sequence: 1),
      ],
    );
    expect(planner.nextAlarmAt([task], deliveredState: const {}, now: now), DateTime(2026, 9, 8, 9));
  });
}
