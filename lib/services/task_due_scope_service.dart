import '../models/task.dart';

enum TaskDueScope { today, future, overdue }

/// Pure projection for the owner-approved Today / Future / Overdue task scopes.
///
/// Scope membership is derived only from [Task.dueDate]. Reminder timestamps
/// and FollowUp history are deliberately ignored so these concepts cannot drift
/// together again. This service never mutates Tasks or persistence.
class TaskDueScopeService {
  const TaskDueScopeService();

  List<Task> project(
    Iterable<Task> tasks, {
    required DateTime now,
    required TaskDueScope scope,
  }) {
    final today = _day(now);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((task) {
      if (task.archived || task.trashed || task.completed) return false;
      final due = task.dueDate;
      if (due == null) return false;
      final dueDay = _day(due);

      return switch (scope) {
        TaskDueScope.today => dueDay == today,
        TaskDueScope.future => !dueDay.isBefore(tomorrow),
        TaskDueScope.overdue => dueDay.isBefore(today),
      };
    }).toList(growable: false);
  }

  DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
