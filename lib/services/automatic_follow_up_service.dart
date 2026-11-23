import '../models/task.dart';

/// Legacy compatibility facade. Automatic Follow-up scheduling is retired.
/// Future scheduling must come from canonical Task Reminders only.
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

  String get deliveryIdentity => '$followUpId@${dueAt.toIso8601String()}';
}

/// Retained temporarily so legacy callers can be safely drained without
/// reviving a retired product workflow.
class AutomaticFollowUpService {
  const AutomaticFollowUpService();

  List<AutomaticFollowUpCandidate> scheduledCandidates(
    Iterable<Task> tasks,
  ) => const <AutomaticFollowUpCandidate>[];

  List<AutomaticFollowUpCandidate> dueCandidates(
    Iterable<Task> tasks, {
    required DateTime now,
  }) => const <AutomaticFollowUpCandidate>[];
}
