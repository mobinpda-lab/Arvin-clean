import '../calendar_page.dart';
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

  static const int _maxProjectedRepeatOccurrences = 5;

  List<DateTime> _nextRepeatOccurrences({
    required Task task,
    required DateTime now,
  }) {
    final recurrence = task.recurrence;
    final anchor = task.dueDate;
    if (recurrence == null || anchor == null || !recurrence.active) return const [];
    var occurrence = recurrence.resumeFromToday(scheduledFrom: recurrence.startDate ?? anchor, target: now);
    final result = <DateTime>[];
    var index = 0;
    while (result.length < _maxProjectedRepeatOccurrences) {
      if (recurrence.endDate != null && !occurrence.isBefore(recurrence.endDate!)) break;
      if (recurrence.count != null && index >= recurrence.count!) break;
      result.add(occurrence);
      occurrence = recurrence.nextOccurrence(occurrence);
      index++;
      if (!occurrence.isAfter(result.last)) break;
    }
    return List<DateTime>.unmodifiable(result);
  }
}

  String reminderIdFor(Task task, FollowUp followUp) =>
      'followup:${task.id}:${followUp.id}';

  String dueDateReminderIdFor(Task task) => 'task-due:${task.id}';

  String taskReminderIdFor(Task task) => 'task-reminder:${task.id}';

  String legacyFollowUpReminderIdFor(Task task) =>
      'task-followup:${task.id}';

  FollowUpCalendarTarget? resolveTarget(
    Iterable<Task> tasks,
    String reminderId,
  ) {
    for (final task in tasks) {
      if (task.trashed) continue;
      for (final followUp in task.followUps) {
        if (reminderIdFor(task, followUp) == reminderId) {
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
        final note = followUp.note.trim();
        reminders.add(
          CalendarReminder(
            id: reminderIdFor(task, followUp),
            title: note.isEmpty ? task.title : '${task.title} — $note',
            date: followUp.dateTime,
            completed: followUp.completed || task.completed,
          ),
        );
        taskDatesAlreadyProjected.add(followUp.dateTime);
      }

      final taskReminderDate = task.reminderDate;
      if (taskReminderDate != null &&
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
        // Keep the calendar intentionally light: only the next five future
        // occurrences are projected. The window is recalculated after each
        // occurrence passes; no occurrence is persisted.
        final projectionNow = now ?? DateTime.now();
        for (final occurrence in _nextRepeatOccurrences(task: task, now: projectionNow)) {
          if (occurrence.isBefore(visibleFrom) || !occurrence.isBefore(visibleTo)) continue;
          if (taskDatesAlreadyProjected.any((date) => _sameInstant(date, occurrence))) continue;
          final state = task.occurrenceHistory[occurrence.toIso8601String()];
          final completed = state?['status'] == RecurrenceOccurrenceStatus.completed.name;
          reminders.add(CalendarReminder(
            id: 'task-due:' + task.id + ':' + occurrence.toIso8601String(),
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

      // Older persisted tasks may still carry only the legacy single
      // followUpDate. Keep them visible until migration is complete, but do
      // not duplicate an equivalent canonical follow-up or due date.
      final legacyFollowUpDate = task.followUpDate;
      if (task.followUpEnabled &&
          legacyFollowUpDate != null &&
          !taskDatesAlreadyProjected
              .any((date) => _sameInstant(date, legacyFollowUpDate))) {
        reminders.add(
          CalendarReminder(
            id: legacyFollowUpReminderIdFor(task),
            title: task.title,
            date: legacyFollowUpDate,
            completed: task.completed,
          ),
        );
      }
    }

    reminders.sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(reminders);
  }
}
