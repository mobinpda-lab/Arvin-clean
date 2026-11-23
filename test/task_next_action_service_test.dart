import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_next_action_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskNextActionService();
  final now = DateTime(2026, 8, 26, 12);

  test('ranks overdue, future, then unscheduled active tasks', () {
    final tasks = [
      Task(id: 'plain', title: 'بدون زمان'),
      Task(
        id: 'future',
        title: 'آینده',
        reminderDate: DateTime(2026, 8, 26, 14),
      ),
      Task(
        id: 'overdue',
        title: 'عقب افتاده',
        reminderDate: DateTime(2026, 8, 26, 9),
      ),
    ];

    final result = service.rank(tasks, now: now);

    expect(result.map((item) => item.task.id).toList(), [
      'overdue',
      'future',
      'plain',
    ]);
    expect(result.map((item) => item.reason).toList(), [
      TaskNextActionReason.overdue,
      TaskNextActionReason.scheduled,
      TaskNextActionReason.unscheduled,
    ]);
  });

  test('excludes completed archived and trashed tasks', () {
    final tasks = [
      Task(id: 'active', title: 'فعال'),
      Task(id: 'done', title: 'انجام شده', completed: true),
      Task(id: 'archive', title: 'بایگانی', archived: true),
      Task(id: 'trash', title: 'سطل', trashed: true),
    ];

    expect(
      service.rank(tasks, now: now).map((item) => item.task.id).toList(),
      ['active'],
    );
  });

  test('legacy nextFollowUp and followUpDate never schedule next action', () {
    final task = Task(
      id: 'legacy',
      title: 'قدیمی',
      followUpDate: DateTime(2026, 8, 26, 13),
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 25),
          nextFollowUp: DateTime(2026, 8, 26, 12, 30),
        ),
      ],
    );

    final result = service.rank([task], now: now).single;
    expect(result.dueAt, isNull);
    expect(result.reason, TaskNextActionReason.unscheduled);
  });

  test('orders unscheduled items by recent activity then stable id', () {
    final tasks = [
      Task(
        id: 'older',
        title: 'قدیمی‌تر',
        updatedAt: DateTime(2026, 8, 24),
      ),
      Task(
        id: 'newer',
        title: 'جدیدتر',
        createdAt: DateTime(2026, 8, 25),
      ),
      Task(id: 'b', title: 'B'),
      Task(id: 'a', title: 'A'),
    ];

    expect(
      service.rank(tasks, now: now).map((item) => item.task.id).toList(),
      ['newer', 'older', 'a', 'b'],
    );
  });
}
