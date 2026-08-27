import '../calendar_page.dart';
import '../models/task.dart';

class FollowUpCalendarTarget {
  const FollowUpCalendarTarget({
    required this.task,
    required this.followUp,
  });

  final Task task;
  final FollowUp followUp;
}

/// Read-only projection from canonical task follow-up history into the
/// calendar presentation model. It owns no storage and does not mutate tasks.
class FollowUpCalendarProjection {
  const FollowUpCalendarProjection();

  String reminderIdFor(Task task, FollowUp followUp) =>
      'followup:${task.id}:${followUp.id}';

  FollowUpCalendarTarget? resolveTarget(
    Iterable<Task> tasks,
    String reminderId,
  ) {
    for (final task in tasks) {
      if (task.trashed) continue;
      for (final followUp in task.followUps) {
        if (reminderIdFor(task, followUp) == reminderId) {
          return FollowUpCalendarTarget(task: task, followUp: followUp);
        }
      }
    }
    return null;
  }

  List<CalendarReminder> project(Iterable<Task> tasks) {
    final reminders = <CalendarReminder>[];

    for (final task in tasks) {
      if (task.trashed) continue;

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
      }
    }

    reminders.sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(reminders);
  }
}
