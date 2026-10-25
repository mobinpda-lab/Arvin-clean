import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
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

  test('alarm and delivery honor alarmEnabled independently from calendar sync', () {
    final tasks = [
      Task(id: 'channels', title: 'کانال‌ها', taskReminders: [
        TaskReminder(id: 'alarm-off-calendar-on', title: 'تقویم فقط', date: now.add(const Duration(hours: 1)), alarmEnabled: false, calendarSyncEnabled: true, sequence: 1),
        TaskReminder(id: 'alarm-on-calendar-off', title: 'آلارم فقط', date: now.add(const Duration(hours: 2)), alarmEnabled: true, calendarSyncEnabled: false, sequence: 2),
        TaskReminder(id: 'both-off', title: 'خاموش', date: now.add(const Duration(hours: 3)), alarmEnabled: false, calendarSyncEnabled: false, sequence: 3),
        TaskReminder(id: 'both-on', title: 'هر دو', date: now.add(const Duration(hours: 4)), alarmEnabled: true, calendarSyncEnabled: true, sequence: 4),
      ]),
    ];

    expect(
      planner.nextAlarmAt(tasks, deliveredState: const {}, now: now),
      now.add(const Duration(hours: 2)),
    );
    final due = const FollowUpReminderDeliveryService().due(
      tasks,
      now: now.add(const Duration(hours: 5)),
    );
    expect(due.map((item) => item.taskReminderId), ['alarm-on-calendar-off', 'both-on']);
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
        deliveredState: {'task:legacy-task': 'task:legacy-task@${at.toIso8601String()}'},
        now: now,
      ),
      isNull,
    );
  });
}
