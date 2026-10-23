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

/// Read-only projection from canonical tasks/follow-up history into the
/// calendar presentation model. It owns no storage and does not mutate tasks.
class FollowUpCalendarProjection {
  const FollowUpCalendarProjection();

  String reminderIdFor(Task task, FollowUp followUp) =>
      'followup:${task.id}:${followUp.id}';

  String dueDateReminderIdFor(Task task) => 'task-due:${task.id}';

  String taskReminderIdFor(Task task) => 'task-reminder:${task.id}';

  String independentTaskReminderIdFor(Task task, TaskReminder reminder) =>
      'task-reminder-item:${Uri.encodeComponent(task.id)}:${Uri.encodeComponent(reminder.id)}';

  String legacyFollowUpReminderIdFor(Task task) =>
      'task-followup:${task.id}';

  FollowUpCalendarTarget? resolveTarget(
    Iterable<Task> tasks,
    String reminderId,
  ) {
    for (final task in tasks) {
      if (task.trashed) continue;
      // Follow-up records and their own dates remain in canonical Task data.
      // They are not Calendar events; only explicit Task reminders, Task due
      // dates and recurrence occurrences are projected below.

      for (final reminder in task.taskReminders) {
        reminders.add(
          CalendarReminder(
            // The migrated legacy reminder keeps its old external identity so
            // provider sync updates the existing event instead of creating a
            // second event under the new collection namespace.
            id: reminder.isLegacyTaskReminder
                ? taskReminderIdFor(task)
                : independentTaskReminderIdFor(task, reminder),
            title: reminder.title,
            date: reminder.date,
            completed: task.completed,
            isAllDay: reminder.isAllDay,
          ),
        );
        if (reminder.isLegacyTaskReminder) {
          // Preserve the legacy projection's due-date de-duplication behavior.
          taskDatesAlreadyProjected.add(reminder.date);
        }
      }

      final taskReminderDate = task.reminderDate;
      if (task.legacyTaskReminderMigrationVersion < 1 &&
          taskReminderDate != null &&
          !taskDatesAlreadyProjected.any((date) => _sameInstant(date, taskReminderDate))) {
        reminders.add(
          CalendarReminder(
            id: taskReminderIdFor(task),
            title: 'یادآوری: ${task.title}',
            date: taskReminderDate,
            completed: task.completed,
          ),
        );
        taskDatesAlreadyProjected.add(taskReminderDate);
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
          if (taskDatesAlreadyProjected.any((date) => _sameInstant(date, occurrence))) continue;
          final state = task.occurrenceHistory[occurrence.toIso8601String()];
          final completed = state?['status'] == RecurrenceOccurrenceStatus.completed.name;
          reminders.add(CalendarReminder(
            id: 'task-due:${task.id}:${occurrence.toIso8601String()}',
            title: task.title,
            date: occurrence,
            completed: completed,
          ));
          taskDatesAlreadyProjected.add(occurrence);
        }
      } else if (dueDate != null &&
          !taskDatesAlreadyProjected.any((date) => _sameInstant(date, dueDate))) {
        reminders.add(
          CalendarReminder(
            id: dueDateReminderIdFor(task),
            title: task.title,
            date: dueDate,
            completed: task.completed,
            isAllDay: _isDateOnly(dueDate),
          ),
        );
        taskDatesAlreadyProjected.add(dueDate);
      }

      // Legacy followUpDate is a schedule/history value, not proof that an
      // independent reminder exists. Do not project it into Calendar.
    }

    reminders.sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(reminders);
  }
}
