import '../models/task.dart';

enum TaskNextActionReason {
  overdue,
  scheduled,
  unscheduled,
}

class TaskNextActionSuggestion {
  const TaskNextActionSuggestion({
    required this.task,
    required this.reason,
    this.dueAt,
  });

  final Task task;
  final TaskNextActionReason reason;
  final DateTime? dueAt;
}

/// Produces a deterministic local Next Action ordering from fields that already
/// exist on the canonical [Task] model.
///
/// It owns no storage, AI model, or UI state. Archived, trashed, and completed
/// tasks are excluded. Scheduled tasks are ordered before unscheduled tasks;
/// overdue items come first, then future items by due time.
class TaskNextActionService {
  const TaskNextActionService();

  List<TaskNextActionSuggestion> rank(
    Iterable<Task> tasks, {
    required DateTime now,
  }) {
    final suggestions = tasks
        .where((task) => !task.archived && !task.trashed && !task.completed)
        .map((task) {
      final dueAt = _dueAt(task);
      final reason = dueAt == null
          ? TaskNextActionReason.unscheduled
          : dueAt.isBefore(now)
              ? TaskNextActionReason.overdue
              : TaskNextActionReason.scheduled;
      return TaskNextActionSuggestion(
        task: task,
        reason: reason,
        dueAt: dueAt,
      );
    }).toList();

    suggestions.sort((a, b) {
      final byReason = _priority(a.reason).compareTo(_priority(b.reason));
      if (byReason != 0) return byReason;

      if (a.dueAt != null && b.dueAt != null) {
        final byDue = a.dueAt!.compareTo(b.dueAt!);
        if (byDue != 0) return byDue;
      }

      final aActivity = a.task.updatedAt ?? a.task.createdAt;
      final bActivity = b.task.updatedAt ?? b.task.createdAt;
      if (aActivity != null && bActivity != null) {
        final byActivity = bActivity.compareTo(aActivity);
        if (byActivity != 0) return byActivity;
      } else if (aActivity != null) {
        return -1;
      } else if (bActivity != null) {
        return 1;
      }

      return a.task.id.compareTo(b.task.id);
    });

    return suggestions;
  }

  DateTime? _dueAt(Task task) {
    final candidates = <DateTime>[];

    if (task.reminderDate != null) {
      candidates.add(task.reminderDate!);
    }

    final nextFollowUp = task.lastFollowUp?.nextFollowUp;
    if (nextFollowUp != null) {
      candidates.add(nextFollowUp);
    } else if (task.followUps.isEmpty && task.followUpDate != null) {
      // Transitional compatibility: persisted legacy JSON is migrated into
      // FollowUps[], but an in-memory legacy-only Task may still carry this.
      candidates.add(task.followUpDate!);
    }

    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.first;
  }

  int _priority(TaskNextActionReason reason) => switch (reason) {
        TaskNextActionReason.overdue => 0,
        TaskNextActionReason.scheduled => 1,
        TaskNextActionReason.unscheduled => 2,
      };
}
