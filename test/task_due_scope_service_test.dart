import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_due_scope_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskDueScopeService();
  final now = DateTime(2026, 8, 28, 12, 0);

  Task task(
    String id, {
    DateTime? dueDate,
    DateTime? reminderDate,
    DateTime? followUpDate,
    bool archived = false,
    bool trashed = false,
    bool completed = false,
  }) {
    return Task(
      id: id,
      title: id,
      dueDate: dueDate,
      reminderDate: reminderDate,
      followUpDate: followUpDate,
      archived: archived,
      trashed: trashed,
      completed: completed,
    );
  }

  test('Today Future Overdue use dueDate only', () {
    final items = [
      task('today', dueDate: DateTime(2026, 8, 28, 23, 30)),
      task('future', dueDate: DateTime(2026, 8, 29, 8)),
      task('overdue', dueDate: DateTime(2026, 8, 27, 20)),
      task(
        'reminder-is-not-due',
        dueDate: DateTime(2026, 8, 30),
        reminderDate: DateTime(2026, 8, 28),
        followUpDate: DateTime(2026, 8, 28),
      ),
      task('undated'),
    ];

    expect(
      service
          .project(items, now: now, scope: TaskDueScope.today)
          .map((item) => item.id),
      ['today'],
    );
    expect(
      service
          .project(items, now: now, scope: TaskDueScope.future)
          .map((item) => item.id),
      ['future', 'reminder-is-not-due'],
    );
    expect(
      service
          .project(items, now: now, scope: TaskDueScope.overdue)
          .map((item) => item.id),
      ['overdue'],
    );
  });

  test('inactive or completed items do not enter active due scopes', () {
    final items = [
      task('archived', dueDate: DateTime(2026, 8, 28), archived: true),
      task('trashed', dueDate: DateTime(2026, 8, 27), trashed: true),
      task('completed', dueDate: DateTime(2026, 8, 27), completed: true),
      task('open', dueDate: DateTime(2026, 8, 27)),
    ];

    expect(
      service
          .project(items, now: now, scope: TaskDueScope.overdue)
          .map((item) => item.id),
      ['open'],
    );
  });

  test('projection is read-only and preserves input order', () {
    final first = task('first', dueDate: DateTime(2026, 8, 29));
    final second = task('second', dueDate: DateTime(2026, 8, 30));

    final result = service.project(
      [first, second],
      now: now,
      scope: TaskDueScope.future,
    );

    expect(result, [same(first), same(second)]);
    expect(first.dueDate, DateTime(2026, 8, 29));
    expect(second.dueDate, DateTime(2026, 8, 30));
  });
}
