import '../models/task.dart';

/// Read-only projection of a due automatic follow-up.
///
/// This deliberately carries identifiers/value data rather than mutating the
/// source [Task] or creating a second persistence model.
class AutomaticFollowUpCandidate {
  const AutomaticFollowUpCandidate({
    required this.taskId,
    required this.taskTitle,
    required this.followUpId,
    required this.dueAt,
  });

  final String taskId;
  final String taskTitle;
  final String followUpId;
  final DateTime dueAt;
}

/// Derives automatic follow-up work from the canonical `Task.followUps` chain.
///
/// Only the chronologically latest FollowUp is authoritative. Therefore a
/// newer FollowUp without `nextFollowUp` supersedes any older pending schedule.
class AutomaticFollowUpService {
  const AutomaticFollowUpService();

  List<AutomaticFollowUpCandidate> dueCandidates(
    Iterable<Task> tasks, {
    required DateTime now,
  }) {
    final result = <AutomaticFollowUpCandidate>[];

    for (final task in tasks) {
      if (task.completed || task.archived || task.trashed) continue;

      final latest = task.lastFollowUp;
      if (latest == null) continue;

      final dueAt = latest.nextFollowUp;
      if (dueAt == null || dueAt.isAfter(now)) continue;

      result.add(
        AutomaticFollowUpCandidate(
          taskId: task.id,
          taskTitle: task.title,
          followUpId: latest.id,
          dueAt: dueAt,
        ),
      );
    }

    result.sort((a, b) {
      final byDueAt = a.dueAt.compareTo(b.dueAt);
      if (byDueAt != 0) return byDueAt;
      return a.taskId.compareTo(b.taskId);
    });

    return List<AutomaticFollowUpCandidate>.unmodifiable(result);
  }
}
