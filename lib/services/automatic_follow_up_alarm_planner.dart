import '../models/task.dart';
import 'automatic_follow_up_service.dart';

/// Pure planner for the single Android alarm used by Automatic FollowUp.
///
/// Delivery markers are metadata only. Canonical Task/FollowUp data remains the
/// source of truth for which schedule is currently authoritative.
class AutomaticFollowUpAlarmPlanner {
  const AutomaticFollowUpAlarmPlanner({
    this.service = const AutomaticFollowUpService(),
    this.minimumDelay = const Duration(minutes: 5),
  });

  final AutomaticFollowUpService service;
  final Duration minimumDelay;

  DateTime? nextAlarmAt(
    Iterable<Task> tasks, {
    required Map<String, String> deliveredState,
    required DateTime now,
  }) {
    final floor = now.add(minimumDelay);

    for (final candidate in service.scheduledCandidates(tasks)) {
      if (deliveredState[candidate.taskId] == candidate.deliveryIdentity) {
        continue;
      }

      return candidate.dueAt.isAfter(floor) ? candidate.dueAt : floor;
    }

    return null;
  }
}
