import '../models/task.dart';
import 'follow_up_reminder_projection.dart';

class FollowUpReminderAlarmPlan {
  const FollowUpReminderAlarmPlan({
    required this.candidate,
    required this.deliveryKey,
  });

  final FollowUpReminderCandidate candidate;
  final String deliveryKey;

  DateTime get alarmAt => candidate.scheduledAt;
}

/// Selects exactly one nearest canonical FollowUp reminder for the existing
/// Android alarm foundation. It owns no storage, platform alarm, or notification
/// side effect.
class FollowUpReminderAlarmPlanner {
  const FollowUpReminderAlarmPlanner({
    this.projection = const FollowUpReminderProjection(),
  });

  final FollowUpReminderProjection projection;

  FollowUpReminderAlarmPlan? next(
    Iterable<Task> tasks, {
    required DateTime now,
    Set<String> deliveredKeys = const <String>{},
  }) {
    final candidates = projection.pending(tasks, now: now);
    for (final candidate in candidates) {
      final key = deliveryKeyFor(candidate);
      if (!deliveredKeys.contains(key)) {
        return FollowUpReminderAlarmPlan(
          candidate: candidate,
          deliveryKey: key,
        );
      }
    }
    return null;
  }

  String deliveryKeyFor(FollowUpReminderCandidate candidate) =>
      '${candidate.stableKey}@${candidate.scheduledAt.toIso8601String()}';
}
