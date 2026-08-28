import '../models/task.dart';
import 'follow_up_reminder_projection.dart';

/// Projects canonical FollowUp reminder timestamps that are ready for delivery.
///
/// This service is deliberately pure: it owns no storage, scheduler, Android
/// plugin, or notification side effect. Delivery-state persistence remains a
/// separate boundary and is represented here only by exact identity strings.
class FollowUpReminderDeliveryService {
  const FollowUpReminderDeliveryService();

  String deliveryIdentity(FollowUpReminderCandidate candidate) =>
      '${candidate.stableKey}@${candidate.scheduledAt.toIso8601String()}';

  List<FollowUpReminderCandidate> due(
    Iterable<Task> tasks, {
    required DateTime now,
    Set<String> deliveredIdentities = const <String>{},
  }) {
    final result = <FollowUpReminderCandidate>[];

    for (final task in tasks) {
      if (task.completed || task.archived || task.trashed) continue;

      for (final followUp in task.followUps) {
        final reminderDate = followUp.reminderDate;
        if (reminderDate == null || reminderDate.isAfter(now)) continue;

        final note = followUp.note.trim();
        final candidate = FollowUpReminderCandidate(
          taskId: task.id,
          taskTitle: task.title,
          followUpId: followUp.id,
          label: note.isEmpty ? 'پیگیری' : note,
          scheduledAt: reminderDate,
        );

        if (deliveredIdentities.contains(deliveryIdentity(candidate))) continue;
        result.add(candidate);
      }
    }

    result.sort((a, b) {
      final byTime = a.scheduledAt.compareTo(b.scheduledAt);
      if (byTime != 0) return byTime;
      return a.stableKey.compareTo(b.stableKey);
    });

    return List<FollowUpReminderCandidate>.unmodifiable(result);
  }
}
