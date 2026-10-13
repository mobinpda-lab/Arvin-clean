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

      final legacyReminderId = 'legacy-task-reminder:${task.id}';
      final hasMigratedLegacyReminder =
          task.taskReminders.any((item) => item.id == legacyReminderId);
      final taskReminder = task.reminderDate;
      if (!hasMigratedLegacyReminder && taskReminder != null) {
        final identity = 'task:${task.id}@${taskReminder.toIso8601String()}';
        if (!delivered.contains(identity)) candidates.add(taskReminder);
      }

      for (final reminder in task.taskReminders) {
        if (reminder.status != 'active') continue;
        final at = reminder.isAllDay
            ? DateTime(reminder.date.year, reminder.date.month, reminder.date.day, 9)
            : reminder.date;
        final identity = reminder.id == legacyReminderId
            ? 'task:${task.id}@${task.reminderDate?.toIso8601String() ?? at.toIso8601String()}'
            : 'task:${task.id}:reminder:${reminder.id}@${at.toIso8601String()}';
        if (!delivered.contains(identity)) candidates.add(at);
      }

      for (final followUp in task.followUps) {
        if (followUp.completed) continue;
        final at = followUp.reminderDate;
        if (at == null) continue;
        final identity =
            '${task.id}:${followUp.id}@${at.toIso8601String()}';
        if (delivered.contains(identity)) continue;
        candidates.add(at);
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort();
    final next = candidates.first;
    return next.isAfter(floor) ? next : floor;
  }
}
