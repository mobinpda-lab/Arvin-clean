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
      for (final followUp in task.followUps) {
        final linkedReminders = task.taskReminders.where(
          (reminder) => reminder.followUpId == followUp.id,
        ).toList(growable: false);
        final linkedReminder = linkedReminders.isEmpty ? null : linkedReminders.first;
        if ((linkedReminder != null || followUp.reminderDate != null) &&
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

  bool _sameInstant(DateTime a, DateTime b) =>
      a.toUtc().isAtSameMomentAs(b.toUtc());

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

      final taskDatesAlreadyProjected = <DateTime>[];

      for (final followUp in task.followUps) {
        final customTitle = followUp.title?.trim();
        final hasCustomTitle = customTitle != null && customTitle.isNotEmpty;
        final calendarTitle = hasCustomTitle
            ? customTitle
            : 'پیگیری ${task.title}';
        final parentSubtitle = hasCustomTitle ? 'پیگیری: ${task.title}' : null;
        final isCompleted = followUp.completed || task.completed;

        // nextFollowUp is an internal planned action, not a calendar event.
        // Only the explicitly configured reminderDate is projected.
        final linkedReminders = task.taskReminders.where(
          (reminder) => reminder.followUpId == followUp.id,
        ).toList(growable: false);
        final linkedReminder = linkedReminders.isEmpty ? null : linkedReminders.first;
        final reminderDate = linkedReminder?.date ?? followUp.reminderDate;
        if (reminderDate != null) {
          reminders.add(
            CalendarReminder(
              id: reminderIdFor(task, followUp),
              title: linkedReminder?.title.trim().isNotEmpty == true
                  ? linkedReminder!.title
                  : (customTitle != null && customTitle.isNotEmpty
                      ? customTitle
                      : task.title.trim().isNotEmpty
                          ? 'پیگیری — ${task.title.trim()}'
                          : 'پیگیری'),
              date: reminderDate,
              completed: isCompleted,
              description: parentSubtitle,
            ),
          );
          taskDatesAlreadyProjected.add(reminderDate);
        }
      }

      for (final reminder in task.taskReminders) {
        if (reminder.followUpId != null) continue;
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
