import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_next_action_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskNextActionService();
  final now = DateTime(2026, 8, 26, 12);

  test('ranks overdue canonical Reminder, future due time, then unscheduled Task', () {
    final tasks = [
      Task(id: 'plain', title: 'بدون زمان'),
      Task(id: 'future', title: 'آینده', taskReminders: [
        TaskReminder(id: 'r-future', title: 'بعداً', date: DateTime(2026, 8, 26, 14), sequence: 1),
      ]),
      Task(id: 'overdue', title: 'عقب افتاده', taskReminders: [
        TaskReminder(id: 'r-overdue', title: 'گذشته', date: DateTime(2026, 8, 26, 9), sequence: 1),
      ]),
    ];
    final result = service.rank(tasks, now: now);
    expect(result.map((item) => item.task.id).toList(), ['overdue', 'future', 'plain']);
    expect(result.map((item) => item.reason).toList(), [
      TaskNextActionReason.overdue, TaskNextActionReason.scheduled, TaskNextActionReason.unscheduled,
    ]);
  });

  test('excludes completed archived and trashed tasks', () {
    final tasks = [
      Task(id: 'active', title: 'فعال'),
      Task(id: 'done', title: 'انجام شده', completed: true),
      Task(id: 'archive', title: 'بایگانی', archived: true),
      Task(id: 'trash', title: 'سطل', trashed: true),
    ];
    expect(service.rank(tasks, now: now).map((item) => item.task.id).toList(), ['active']);
  });

  test('Next Follow-up history fields do not create scheduled next actions', () {
    final task = Task(id: 'followup', title: 'پیگیری تاریخی', followUpDate: DateTime(2026, 8, 20),
      followUps: [
        FollowUp(id: 'old', dateTime: DateTime(2026, 8, 20), nextFollowUp: DateTime(2026, 8, 27, 10)),
        FollowUp(id: 'latest', dateTime: DateTime(2026, 8, 25), nextFollowUp: DateTime(2026, 8, 26, 16)),
      ]);
    final result = service.rank([task], now: now).single;
    expect(result.dueAt, isNull);
    expect(result.reason, TaskNextActionReason.unscheduled);
  });

  test('chooses earliest canonical due or Reminder time without cross-coupling', () {
    final task = Task(id: 'both', title: 'دو موعد مستقل',
      dueDate: DateTime(2026, 8, 26, 15),
      taskReminders: [TaskReminder(id: 'r1', title: 'یادآوری', date: DateTime(2026, 8, 26, 14), sequence: 1)],
      followUps: [FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 25), nextFollowUp: DateTime(2026, 8, 26, 13))]);
    expect(service.rank([task], now: now).single.dueAt, DateTime(2026, 8, 26, 14));
  });

  test('legacy Follow-up dates do not influence rank', () {
    final tasks = [
      Task(id: 'legacy', title: 'قدیمی', followUpDate: DateTime(2026, 8, 26, 13)),
      Task(id: 'history', title: 'تاریخچه', followUpDate: DateTime(2026, 8, 26, 13),
        followUps: [FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 25))]),
    ];
    final result = service.rank(tasks, now: now);
    expect(result.every((item) => item.dueAt == null), isTrue);
    expect(result.every((item) => item.reason == TaskNextActionReason.unscheduled), isTrue);
  });

  test('orders unscheduled items by recent activity then stable id', () {
    final tasks = [
      Task(id: 'older', title: 'قدیمی‌تر', updatedAt: DateTime(2026, 8, 24)),
      Task(id: 'newer', title: 'جدیدتر', createdAt: DateTime(2026, 8, 25)),
      Task(id: 'b', title: 'B'), Task(id: 'a', title: 'A'),
    ];
    expect(service.rank(tasks, now: now).map((item) => item.task.id).toList(), ['newer', 'older', 'a', 'b']);
  });
}
