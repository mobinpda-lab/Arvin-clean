import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_due_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskDueStatus', () {
    test('timed task becomes overdue only after its exact datetime', () {
      final task = Task(
        id: 'timed-due',
        title: 'موعد ساعت‌دار',
        dueDate: DateTime(2026, 11, 7, 11, 0),
      );

      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 7, 10, 59, 59)),
        isFalse,
      );
      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 7, 11, 0)),
        isFalse,
      );
      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 7, 11, 0, 1)),
        isTrue,
      );
    });

    test('all-day task remains current through 23:59:59 and expires at next day', () {
      final task = Task(
        id: 'all-day-due',
        title: 'موعد بدون ساعت',
        dueDate: DateTime(2026, 11, 7),
        allDay: true,
      );

      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 7, 23, 59, 59)),
        isFalse,
      );
      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 8)),
        isTrue,
      );
    });

    test('completed task is never overdue, including after all-day expiry', () {
      final task = Task(
        id: 'completed-all-day',
        title: 'کار انجام‌شده',
        dueDate: DateTime(2026, 11, 7),
        allDay: true,
        completed: true,
      );

      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 9)),
        isFalse,
      );
    });

    test('task without a due date is never overdue', () {
      final task = Task(id: 'undated', title: 'بدون موعد');
      expect(
        TaskDueStatus.isOverdue(task, now: DateTime(2026, 11, 9)),
        isFalse,
      );
    });
  });
}
