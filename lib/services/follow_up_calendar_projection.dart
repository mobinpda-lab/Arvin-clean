import '../calendar_page.dart';
import '../models/task.dart';

/// Read-only projection from canonical task follow-up history into the
/// calendar presentation model. It owns no storage and does not mutate tasks.
class FollowUpCalendarProjection {
  const FollowUpCalendarProjection();

  List<CalendarReminder> project(Iterable<Task> tasks) {
    final reminders = <CalendarReminder>[];

    for (final task in tasks) {
      if (task.trashed) continue;

      for (final followUp in task.followUps) {
        final note = followUp.note.trim();
        reminders.add(
          CalendarReminder(
            id: 'followup:${task.id}:${followUp.id}',
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
