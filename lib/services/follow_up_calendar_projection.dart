import '../calendar_page.dart';
import '../models/recurrence.dart';
import '../models/task.dart';

class FollowUpCalendarTarget {
  const FollowUpCalendarTarget({
    required this.taskId,
    required this.followUp,
  });

  final String taskId;
  final FollowUp followUp;
}

/// Read-only projection of canonical Task due dates and TaskReminder records.
/// It owns no storage and does not mutate Tasks or Reminder history.
class FollowUpCalendarProjection {
  const FollowUpCalendarProjection();

  String reminderIdFor(Task task, FollowUp followUp) =>
      'followup:${task.id}:${followUp.id}';

  String dueDateReminderIdFor(Task task) => 'task-due:${task.id}';

  String taskReminderIdFor(Task task) => 'task-reminder:${task.id}';

  String independentTaskReminderIdFor(Task task, TaskReminder reminder) =>
      'task-reminder-item:${Uri.encodeComponent(task.id)}:${Uri.encodeComponent(reminder.id)}';

  FollowUpCalendarTarget? resolveTarget(
    Iterable<Task> tasks,
    String reminderId,
  ) {
    for (final task in tasks) {
      if (task.trashed) continue;
      for (final followUp in task.followUps) {
        if (followUp.reminderDate != null &&
            reminderIdFor(task, followUp) == reminderId) {
          return FollowUpCalendarTarget(
            taskId: task.id,
            followUp: followUp,
          );
        }
      }
    }
    return null;
  }

  bool _isDateOnly(DateTime value) =>
      value.hour == 0 &&
      value.minute == 0 &&
      value.second == 0 &&
      value.millisecond == 0 &&
      value.microsecond == 0;

  List<CalendarReminder> project(
    Iterable<Task> tasks, {
    DateTime? visibleFrom,
    DateTime? visibleTo,
    DateTime? now,
  }) {
    final reminders = <CalendarReminder>[];

    for (final task in tasks) {
      if (task.trashed) continue;

      // Legacy FollowUp scheduling fields are historical data only. The
      // active calendar is driven by Task due dates and canonical TaskReminder
      // records; nested FollowUp.reminderDate and nextFollowUp never project.
      for (final reminder in task.taskReminders) {
        reminders.add(
          CalendarReminder(
            // A previously migrated singular Task reminder retains its
            // provider identity. All newly created reminders use their own
            // stable Task + Reminder identity.
            id: reminder.isLegacyTaskReminder
                ? taskReminderIdFor(task)
                : independentTaskReminderIdFor(task, reminder),
            title: reminder.title,
            date: reminder.date,
            completed: task.completed,
            isAllDay: reminder.isAllDay,
          ),
        );
      }

      final dueDate = task.dueDate;
      final recurrence = task.recurrence;
      if (recurrence != null &&
          dueDate != null &&
          visibleFrom != null &&
          visibleTo != null) {
        // Project the canonical recurrence into the full visible Calendar
        // range. Past/today/future occurrences must all remain discoverable
        // when the user navigates to their scheduled dates; no occurrence is
        // persisted as an independent Task.
        for (final occurrence in recurrence.occurrencesBetween(
          anchor: dueDate,
          from: visibleFrom,
          to: visibleTo,
        )) {
          if (occurrence.isBefore(visibleFrom) || !occurrence.isBefore(visibleTo)) continue;
          final state = task.occurrenceHistory[occurrence.toIso8601String()];
          final completed = state?['status'] == RecurrenceOccurrenceStatus.completed.name;
          reminders.add(CalendarReminder(
            id: 'task-due:${task.id}:${occurrence.toIso8601String()}',
            title: task.title,
            date: occurrence,
            completed: completed,
          ));
        }
      } else if (dueDate != null) {
        reminders.add(
          CalendarReminder(
            id: dueDateReminderIdFor(task),
            title: task.title,
            date: dueDate,
            completed: task.completed,
            isAllDay: _isDateOnly(dueDate),
          ),
        );
      }

      // Legacy followUpDate is a schedule/history value, not proof that an
      // independent reminder exists. Do not project it into Calendar.
    }

    reminders.sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(reminders);
  }
}
