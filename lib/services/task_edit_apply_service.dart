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
    target.followUpEnabled = edited.followUpEnabled;
    target.followUpDate = edited.followUpDate;
    target.tags = List<String>.of(edited.tags);
    target.category = edited.category;
    target.checklist = List<String>.of(edited.checklist);
    target.reminderDate = edited.reminderDate;
    target.recurrence = edited.recurrence;
    target.updatedAt = _now();
  }
}
