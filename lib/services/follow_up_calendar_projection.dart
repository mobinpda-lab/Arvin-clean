import 'package:flutter/foundation.dart';
import '../calendar_page.dart';
import '../models/recurrence.dart';
import '../models/task.dart';

class TaskReminderCalendarTarget {
  const TaskReminderCalendarTarget({required this.taskId, required this.reminder});
  final String taskId;
  final TaskReminder reminder;
}

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

  /// Retired legacy Follow-up reminder IDs are never active Calendar targets.
  FollowUpCalendarTarget? resolveTarget(
    Iterable<Task> tasks,
    String reminderId,
  ) => null;

  /// Resolves only an independent canonical TaskReminder.
  TaskReminderCalendarTarget? resolveTaskReminderTarget(Iterable<Task> tasks, String reminderId) {
    String? taskId;
    String? reminderRecordId;
    if (reminderId.startsWith('task-reminder-item:')) {
      final suffix = reminderId.substring('task-reminder-item:'.length);
      final separator = suffix.indexOf(':');
      if (separator <= 0 || separator == suffix.length - 1) return null;
      taskId = Uri.decodeComponent(suffix.substring(0, separator));
      reminderRecordId = Uri.decodeComponent(suffix.substring(separator + 1));
    } else if (reminderId.startsWith('task-reminder:')) {
      taskId = reminderId.substring('task-reminder:'.length);
    } else { return null; }
    for (final task in tasks) {
      if (task.id != taskId || task.completed || task.archived || task.trashed) continue;
      TaskReminder? target;
      if (reminderRecordId != null) {
        for (final reminder in task.taskReminders) {
          if (reminder.id == reminderRecordId) { target = reminder; break; }
        }
      } else {
        for (final reminder in task.taskReminders) {
          if (!reminder.isLegacyTaskReminder) continue;
          if (target != null) return null;
          target = reminder;
        }
      }
      if (target != null) return TaskReminderCalendarTarget(taskId: task.id, reminder: target);
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

    final taskList = tasks.toList(growable: false);
    debugPrint(
      'CALENDAR_DIAG_B: inputContainsSmokeTask=${taskList.any((task) => task.id == 'calendar-smoke-task')} '
      'inputTaskIds=${taskList.where((task) => task.id == 'calendar-smoke-task').map((task) => task.id).toList()}',
    );

    for (final task in taskList) {
      if (task.trashed) {
        if (task.id == 'calendar-smoke-task') {
          for (final reminder in task.taskReminders) {
            debugPrint(
              'CALENDAR_DIAG_B: taskId=${task.id} reminderId=${reminder.id} '
              'type=${reminder.isLegacyTaskReminder ? 'legacy' : 'independent'} '
              'date=${reminder.date.toIso8601String()} DROP_REASON=task_trashed',
            );
          }
        }
        continue;
      }

      final taskDatesAlreadyProjected = <DateTime>[];

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
        if (task.id == 'calendar-smoke-task') {
          debugPrint(
            'CALENDAR_DIAG_B: taskId=${task.id} '
            'outputReminderId=${reminder.isLegacyTaskReminder ? taskReminderIdFor(task) : independentTaskReminderIdFor(task, reminder)} '
            'type=${reminder.isLegacyTaskReminder ? 'legacy' : 'independent'} '
            'date=${reminder.date.toIso8601String()} RESULT=PROJECTED',
          );
        }
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
    debugPrint(
      'CALENDAR_DIAG_B: outputSmokeReminderIdsAndDates=${reminders.where((item) => item.id.contains('calendar-smoke-task')).map((item) => '${item.id}@${item.date.toIso8601String()}').toList()}',
    );
    return List<CalendarReminder>.unmodifiable(reminders);
  }
}
