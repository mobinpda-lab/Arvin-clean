import '../models/task.dart';

/// Central overdue semantics for every Task projection and report.
abstract final class TaskDueStatus {
  static bool isOverdue(Task task, {required DateTime now}) {
    final due = task.dueDate;
    if (due == null || task.completed) return false;

    final localDue = due.toLocal();
    final localNow = now.toLocal();
    if (task.allDay) {
      // A date-only task becomes overdue at the first instant of the next
      // local calendar day; midnight is never stored as a synthetic due time.
      final nextDay = DateTime(
        localDue.year,
        localDue.month,
        localDue.day + 1,
      );
      return !localNow.isBefore(nextDay);
    }
    return localDue.isBefore(localNow);
  }
}
