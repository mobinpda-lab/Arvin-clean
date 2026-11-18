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
      if (task.completed || task.archived || task.trashed) continue;

      final taskReminder = task.reminderDate;
      // Before migration, retain the legacy delivery identity. Once the
      // legacy date has been migrated into TaskReminder, do not schedule the
      // singular field a second time.
      if (task.legacyTaskReminderMigrationVersion < 1 && taskReminder != null) {
        final identity = 'task:${task.id}@${taskReminder.toIso8601String()}';
        if (!delivered.contains(identity)) candidates.add(taskReminder);
      }

      for (final reminder in task.taskReminders) {
        final scheduledAt = reminder.isAllDay
            ? DateTime(reminder.date.year, reminder.date.month, reminder.date.day, 9)
            : reminder.date;
        // The migrated legacy reminder must continue to use the old delivery
        // identity so already-delivered state remains effective after upgrade.
        final identity = reminder.isLegacyTaskReminder
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
