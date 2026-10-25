import '../models/task.dart';

enum TaskTimelineEntryKind {
  created,
  reminder,
  followUp,
  updated,
}

class TaskTimelineEntry {
  const TaskTimelineEntry({
    required this.id,
    required this.kind,
    required this.dateTime,
    this.note = '',
    this.result,
  });

  final String id;
  final TaskTimelineEntryKind kind;
  final DateTime dateTime;
  final String note;
  final String? result;
}

/// Builds a read-only chronological projection from timestamps that already
/// exist on the canonical [Task] model.
///
/// This service deliberately owns no persistence and does not create a second
/// history source. It can therefore feed a future Timeline UI while keeping
/// Task + FollowUps[] as the single source of truth.
class TaskTimelineService {
  const TaskTimelineService();

  List<TaskTimelineEntry> build(Task task) {
    final entries = <TaskTimelineEntry>[];

    if (task.createdAt != null) {
      entries.add(
        TaskTimelineEntry(
          id: 'task:${task.id}:created',
          kind: TaskTimelineEntryKind.created,
          dateTime: task.createdAt!,
        ),
      );
    }

    for (final reminder in task.taskReminders) {
      entries.add(
        TaskTimelineEntry(
          id: 'task:${task.id}:reminder:${reminder.id}',
          kind: TaskTimelineEntryKind.reminder,
          dateTime: reminder.date,
          note: reminder.title,
        ),
      );
    }

    if (task.followUps.isNotEmpty) {
      for (final followUp in task.followUps) {
        entries.add(
          TaskTimelineEntry(
            id: 'followup:${followUp.id}',
            kind: TaskTimelineEntryKind.followUp,
            dateTime: followUp.dateTime,
            note: followUp.note,
            result: followUp.result,
          ),
        );
      }
    }
    if (task.updatedAt != null) {
      entries.add(
        TaskTimelineEntry(
          id: 'task:${task.id}:updated',
          kind: TaskTimelineEntryKind.updated,
          dateTime: task.updatedAt!,
        ),
      );
    }

    entries.sort((a, b) {
      final byDate = a.dateTime.compareTo(b.dateTime);
      if (byDate != 0) return byDate;

      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;

      return a.id.compareTo(b.id);
    });

    return entries;
  }
}
