import '../models/task.dart';

/// Immutable projection consumed by the existing Android reminder/scheduler
/// foundation. It intentionally carries no persistence or platform behavior.
class FollowUpReminderCandidate {
  const FollowUpReminderCandidate({
    required this.taskId,
    required this.taskTitle,
    required this.followUpId,
    required this.label,
    required this.scheduledAt,
    this.taskReminderId,
  });

  const FollowUpReminderCandidate.task({
    required this.taskId,
    required this.taskTitle,
    required this.scheduledAt,
    this.taskReminderId,
    this.label = 'یادآوری',
  }) : followUpId = null;

  final String taskId;
  final String taskTitle;
  final String? followUpId;
  final String? taskReminderId;
  final String label;
  final DateTime scheduledAt;

  bool get isTaskReminder => followUpId == null;

  String get stableKey => followUpId != null
      ? '$taskId:$followUpId'
      : taskReminderId == null
          ? 'task:$taskId'
          : 'task:$taskId:reminder:$taskReminderId';
}

/// Projects canonical FollowUp reminder state into deterministic pending work.
///
/// This is deliberately transport-neutral: reboot rescheduling and Android
/// alarm delivery can reuse the existing scheduler without introducing a
/// second store, alarm engine, or notification model.
class FollowUpReminderProjection {
  const FollowUpReminderProjection();

  List<FollowUpReminderCandidate> pending(
    Iterable<Task> tasks, {
    required DateTime now,
  }) {
    final result = <FollowUpReminderCandidate>[];

    for (final task in tasks) {
      if (task.completed || task.archived || task.trashed) continue;

      for (final reminder in task.taskReminders) {
        final scheduledAt = reminder.isAllDay
            ? DateTime(reminder.date.year, reminder.date.month, reminder.date.day, 9)
            : reminder.date;
        if (scheduledAt.isBefore(now)) continue;
        result.add(
          FollowUpReminderCandidate.task(
            taskId: task.id,
            taskTitle: task.title,
            taskReminderId: reminder.isLegacyTaskReminder ? null : reminder.id,
            label: reminder.title.trim().isEmpty
                ? 'یادآور ${reminder.sequence}'
                : reminder.title,
            scheduledAt: scheduledAt,
          ),
        );
      }

    }

    result.sort((a, b) {
      final byTime = a.scheduledAt.compareTo(b.scheduledAt);
      if (byTime != 0) return byTime;
      return a.stableKey.compareTo(b.stableKey);
    });
    return result;
  }
}
