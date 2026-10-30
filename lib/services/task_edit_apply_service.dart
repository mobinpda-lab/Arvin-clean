import '../models/task.dart';

/// Applies the editable Task payload returned by an editor onto the existing
/// canonical Task instance without replacing identity or FollowUp history.
///
/// Persistence remains owned by the existing TaskStore/Home write path.
class TaskEditApplyService {
  TaskEditApplyService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  void apply(Task target, Task edited) {
    target.title = edited.title;
    target.description = edited.description;
    target.dueDate = edited.dueDate;
    target.allDay = edited.allDay;
    target.tags = List<String>.of(edited.tags);
    target.category = edited.category;
    target.checklist = List<String>.of(edited.checklist);
    target.checklistEnabled = edited.checklistEnabled;
    // Per-occurrence checklist ticks belong to the existing canonical Task;
    // editing the template must not reset prior occurrence state.
    target.reminderDate = edited.reminderDate;
    target.taskReminders = List<TaskReminder>.of(edited.taskReminders);
    target.nextReminderSequence = edited.nextReminderSequence;
    target.legacyTaskReminderMigrationVersion =
        edited.legacyTaskReminderMigrationVersion;
    target.priority = edited.priority;
    // The editor initializes this value from the canonical Task; only an
    // explicit user toggle changes it. Metadata-only edits therefore preserve
    // completion and completedAt, while an explicit reopen clears the stamp.
    if (edited.completed != target.completed) {
      target.setCompleted(edited.completed, at: _now());
    }
    target.recurrence = edited.recurrence;
    target.updatedAt = _now();
  }
}
