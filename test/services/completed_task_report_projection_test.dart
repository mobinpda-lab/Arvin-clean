import 'package:arvin/models/task.dart';
import 'package:arvin/services/completed_task_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily completion report uses the exact half-open local day interval', () {
    final day = DateTime(2026, 10, 30);
    final tasks = <Task>[
      Task(id: 'at-start', title: 'Start', completed: true, completedAt: day),
      Task(
        id: 'last-microsecond',
        title: 'End minus one microsecond',
        completed: true,
        completedAt: DateTime(2026, 10, 30, 23, 59, 59, 999, 999),
      ),
      Task(
        id: 'at-next-day',
        title: 'Next day',
        completed: true,
        completedAt: DateTime(2026, 10, 31),
      ),
      Task(
        id: 'before',
        title: 'Before',
        completed: true,
        completedAt: DateTime(2026, 10, 29, 23, 59, 59, 999, 999),
      ),
      Task(
        id: 'no-timestamp',
        title: 'Due today only',
        completed: true,
        dueDate: day,
      ),
      Task(
        id: 'incomplete',
        title: 'Incomplete despite stale timestamp',
        completed: false,
        completedAt: DateTime(2026, 10, 30, 12),
        reminderDate: day,
      ),
    ];

    final result = const CompletedTaskReportProjection().forJalaliDay(tasks, day);

    expect(result.map((task) => task.id), ['at-start', 'last-microsecond']);
  });

  test('daily report does not infer completion from due dates or reminders', () {
    final day = DateTime(2026, 10, 30);
    final tasks = <Task>[
      Task(id: 'due', title: 'Due only', dueDate: day),
      Task(id: 'reminder', title: 'Reminder only', reminderDate: day),
    ];

    expect(
      const CompletedTaskReportProjection().forJalaliDay(tasks, day),
      isEmpty,
    );
  });
}
