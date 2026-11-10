import '../models/task.dart';
import 'follow_up_reminder_delivery_state.dart';

class FollowUpReminderAlarmPlanner {
  const FollowUpReminderAlarmPlanner({
    this.stateService = const FollowUpReminderDeliveryState(),
    this.minimumDelay = const Duration(minutes: 1),
  });

  final FollowUpReminderDeliveryState stateService;
  final Duration minimumDelay;

  DateTime? nextAlarmAt(
    Iterable<Task> tasks, {
    required Map<String, String> deliveredState,
    required DateTime now,
  }) {
    final delivered = stateService.deliveredIdentities(deliveredState);
    final floor = now.add(minimumDelay);

    final candidates = <DateTime>[];
    for (final task in tasks) {
      // TaskReminder is the sole scheduling source. FollowUp history is
      // never treated as a future reminder. Eligibility is shared with the
      // foreground projection and background delivery service.
      for (final reminder in task.taskReminders) {
        if (!isTaskReminderEligible(task, reminder)) continue;
        final scheduledAt = taskReminderScheduledAt(reminder);
        // The migrated legacy reminder must continue to use the old delivery
        // identity so already-delivered state remains effective after upgrade.
        final identity = isMigratedTaskReminder(task, reminder)
            ? 'task:${task.id}@${scheduledAt.toIso8601String()}'
            : 'task:${task.id}:reminder:${reminder.id}@${scheduledAt.toIso8601String()}';
        if (!delivered.contains(identity)) candidates.add(scheduledAt);
      }

    }
    if (candidates.isEmpty) return null;
    candidates.sort();
    final next = candidates.first;
    return next.isAfter(floor) ? next : floor;
  }
}
