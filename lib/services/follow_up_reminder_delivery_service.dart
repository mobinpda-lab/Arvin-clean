import '../models/task.dart';
import 'follow_up_reminder_projection.dart';

/// Projects independent canonical TaskReminder timestamps ready for delivery.
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
      for (final reminder in task.taskReminders) {
        if (!isTaskReminderEligible(task, reminder)) continue;
        final scheduledAt = taskReminderScheduledAt(reminder);
        if (scheduledAt.isAfter(now)) continue;
        final candidate = FollowUpReminderCandidate.task(
          taskId: task.id,
          taskTitle: task.title,
          taskReminderId: isMigratedTaskReminder(task, reminder) ? null : reminder.id,
          label: reminder.title.trim().isEmpty
              ? 'یادآور ${reminder.sequence}'
              : reminder.title,
          scheduledAt: scheduledAt,
        );
        if (!deliveredIdentities.contains(deliveryIdentity(candidate))) {
          result.add(candidate);
        }
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
