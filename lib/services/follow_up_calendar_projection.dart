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

  String reminderIdFor(Task task, FollowUp followUp) =>
      'followup:${task.id}:${followUp.id}';

  String dueDateReminderIdFor(Task task) => 'task-due:${task.id}';

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

  List<CalendarReminder> project(Iterable<Task> tasks) {
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
            completed: task.completed,
          ),
        );
        taskDatesAlreadyProjected.add(followUp.dateTime);
      }

      final dueDate = task.dueDate;
      if (dueDate != null &&
          !taskDatesAlreadyProjected.any((date) => _sameInstant(date, dueDate))) {
        reminders.add(
          CalendarReminder(
            id: dueDateReminderIdFor(task),
            title: task.title,
            date: dueDate,
            completed: task.completed,
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
