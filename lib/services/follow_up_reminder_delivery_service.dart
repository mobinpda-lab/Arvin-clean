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

      final taskReminder = task.reminderDate;
      if (task.legacyTaskReminderMigrationVersion < 1 &&
          taskReminder != null &&
          !taskReminder.isAfter(now)) {
        final candidate = FollowUpReminderCandidate.task(
          taskId: task.id,
          taskTitle: task.title,
          scheduledAt: taskReminder,
        );
        if (!deliveredIdentities.contains(deliveryIdentity(candidate))) {
          result.add(candidate);
        }
      }

      for (final reminder in task.taskReminders) {
        if (reminder.followUpId != null) continue;
        final scheduledAt = reminder.isAllDay
            ? DateTime(reminder.date.year, reminder.date.month, reminder.date.day, 9)
            : reminder.date;
        if (scheduledAt.isAfter(now)) continue;
        final candidate = FollowUpReminderCandidate.task(
          taskId: task.id,
          taskTitle: task.title,
          taskReminderId: reminder.isLegacyTaskReminder ? null : reminder.id,
          label: reminder.title.trim().isEmpty
              ? 'یادآور ${reminder.sequence}'
              : reminder.title,
          scheduledAt: scheduledAt,
        );
        if (!deliveredIdentities.contains(deliveryIdentity(candidate))) {
          result.add(candidate);
        }
      }

      for (final followUp in task.followUps) {
        final linkedReminders = task.taskReminders.where(
          (reminder) => reminder.followUpId == followUp.id,
        ).toList(growable: false);
        final linkedReminder = linkedReminders.isEmpty ? null : linkedReminders.first;
        final reminderDate = linkedReminder?.date ?? followUp.reminderDate;
        if (reminderDate == null || reminderDate.isAfter(now)) continue;

        final candidate = FollowUpReminderCandidate(
          taskId: task.id,
          taskTitle: task.title,
          followUpId: followUp.id,
          label: linkedReminder?.title.trim().isNotEmpty == true
              ? linkedReminder!.title
              : FollowUpReminderCandidate.followUpLabel(
                  title: followUp.title,
                  taskTitle: task.title,
                ),
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
