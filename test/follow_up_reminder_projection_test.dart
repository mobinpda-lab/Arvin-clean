import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = FollowUpReminderProjection();
  final now = DateTime(2026, 8, 28, 16);

  test('projects future canonical TaskReminders with stable identity and labels', () {
    final task = Task(id: 'task-1', title: 'قرارداد', taskReminders: [
      TaskReminder(id: 'r1', title: 'تماس با مشتری', date: DateTime(2026, 8, 28, 17, 30), sequence: 1),
      TaskReminder(id: 'r2', title: 'یادآور دوم', date: DateTime(2026, 8, 28, 18), sequence: 2),
    ]);
    final result = projection.pending([task], now: now);
    expect(result, hasLength(2));
    expect(result.map((item) => item.stableKey), ['task:task-1:reminder:r1', 'task:task-1:reminder:r2']);
    expect(result.first.label, 'تماس با مشتری');
    expect(result.first.scheduledAt, DateTime(2026, 8, 28, 17, 30));
  });

  test('only alarm-enabled Reminders schedule, independent of calendar sync', () {
    final at = DateTime(2026, 8, 28, 17);
    final task = Task(id: 'four-modes', title: 'چهار حالت', taskReminders: [
      TaskReminder(id: '00', title: 'خاموش/خاموش', date: at, alarmEnabled: false, calendarSyncEnabled: false, sequence: 1),
      TaskReminder(id: '01', title: 'خاموش/روشن', date: at, alarmEnabled: false, calendarSyncEnabled: true, sequence: 2),
      TaskReminder(id: '10', title: 'روشن/خاموش', date: at, alarmEnabled: true, calendarSyncEnabled: false, sequence: 3),
      TaskReminder(id: '11', title: 'روشن/روشن', date: at, alarmEnabled: true, calendarSyncEnabled: true, sequence: 4),
    ]);
    final result = projection.pending([task], now: now);
    expect(result.map((item) => item.taskReminderId), ['10', '11']);
  });

  test('legacy Next Follow-up and nested Follow-up reminders never schedule', () {
    final task = Task(id: 'legacy', title: 'قدیمی', reminderDate: DateTime(2026, 8, 28, 17),
      followUps: [FollowUp(id: 'fu-1', dateTime: DateTime(2026, 8, 28, 15),
        nextFollowUp: DateTime(2026, 8, 28, 18), reminderDate: DateTime(2026, 8, 28, 19))]);
    expect(projection.pending([task], now: now), isEmpty);
  });

  test('ignores completed archived and trashed Tasks', () {
    final at = now.add(const Duration(hours: 1));
    final tasks = [
      Task(id: 'done', title: 'انجام‌شده', completed: true, taskReminders: [TaskReminder(id: 'r1', title: 'x', date: at, sequence: 1)]),
      Task(id: 'archived', title: 'بایگانی', archived: true, taskReminders: [TaskReminder(id: 'r2', title: 'x', date: at, sequence: 1)]),
      Task(id: 'trashed', title: 'حذف‌شده', trashed: true, taskReminders: [TaskReminder(id: 'r3', title: 'x', date: at, sequence: 1)]),
    ];
    expect(projection.pending(tasks, now: now), isEmpty);
  });

  test('all-day Reminder uses explicit morning time and preserves siblings', () {
    final task = Task(id: 'multi', title: 'کار', taskReminders: [
      TaskReminder(id: 'r1', title: 'تمام‌روز', date: DateTime(2026, 8, 29), isAllDay: true, sequence: 1),
      TaskReminder(id: 'r2', title: 'ساعت‌دار نیمه‌شب', date: DateTime(2026, 8, 29), isAllDay: false, sequence: 2),
    ]);
    final result = projection.pending([task], now: now);
    expect(result, hasLength(2));
    expect(result[0].scheduledAt, DateTime(2026, 8, 29, 9));
    expect(result[1].scheduledAt, DateTime(2026, 8, 29));
    expect(result.map((item) => item.stableKey).toSet(), {'task:multi:reminder:r1', 'task:multi:reminder:r2'});
  });

  test('migrated legacy Task reminder uses the canonical collection and existing key', () {
    final at = DateTime(2026, 10, 20, 9, 30);
    final task = Task.fromJson({'id': 'legacy-task', 'title': 'کار قدیمی', 'reminderDate': at.toIso8601String()});
    final result = projection.pending([task], now: now);
    expect(result, hasLength(1));
    expect(result.single.stableKey, 'task:legacy-task');
    expect(result.single.scheduledAt, at);
  });
}
