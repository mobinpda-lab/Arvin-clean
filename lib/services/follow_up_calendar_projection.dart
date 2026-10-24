import '../calendar_page.dart';
import '../models/recurrence.dart';
import '../models/task.dart';

/// Read-only projection of canonical Task due dates and TaskReminder records.
/// It owns no storage and does not mutate Tasks or Reminder history.
class FollowUpCalendarProjection {
  const FollowUpCalendarProjection();

  String dueDateReminderIdFor(Task task) => 'task-due:${task.id}';

  String taskReminderIdFor(Task task) => 'task-reminder:${task.id}';

  String independentTaskReminderIdFor(Task task, TaskReminder reminder) =>
      'task-reminder-item:${Uri.encodeComponent(task.id)}:${Uri.encodeComponent(reminder.id)}';

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
            syncToDevice: reminder.calendarSyncEnabled,
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
            isAllDay: task.allDay,
          ));
        }
      } else if (dueDate != null) {
        reminders.add(
          CalendarReminder(
            id: dueDateReminderIdFor(task),
            title: task.title,
            date: dueDate,
            completed: task.completed,
            isAllDay: task.allDay,
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
