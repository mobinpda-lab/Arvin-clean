import '../models/task.dart';
import 'reminder_notification_policy.dart';

/// Immutable projection consumed by the existing Android reminder/scheduler
/// foundation. It intentionally carries no persistence or platform behavior.
class FollowUpReminderCandidate {
  const FollowUpReminderCandidate({
    required this.taskId,
    required this.taskTitle,
    required this.followUpId,
    required this.label,
    required this.scheduledAt,
  }) : taskReminderId = null;

  const FollowUpReminderCandidate.task({
    required this.taskId,
    required this.taskTitle,
    required this.scheduledAt,
  })  : followUpId = null,
        taskReminderId = null,
        label = 'یادآوری';

  const FollowUpReminderCandidate.taskReminder({
    required this.taskId,
    required this.taskTitle,
    required this.taskReminderId,
    required this.label,
    required this.scheduledAt,
  }) : followUpId = null;

  final String taskId;
  final String taskTitle;
  final String? followUpId;
  final String? taskReminderId;
  final String label;
  final DateTime scheduledAt;

  bool get isTaskReminder => followUpId == null;

  String get stableKey {
    final reminderId = taskReminderId;
    if (reminderId != null) {
      if (reminderId == 'legacy-task-reminder:$taskId') return 'task:$taskId';
      return 'task-reminder-item:$taskId:$reminderId';
    }
    return isTaskReminder ? 'task:$taskId' : '$taskId:$followUpId';
  }
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
    int allDayReminderNotificationMinutes = defaultAllDayReminderNotificationMinutes,
  }) {
    final result = <FollowUpReminderCandidate>[];

    for (final task in tasks) {
      if (task.completed || task.archived || task.trashed) continue;

      final taskReminder = task.reminderDate;
      if (!task.legacyReminderMigrationCompleted &&
          taskReminder != null &&
          !taskReminder.isBefore(now)) {
        result.add(
          FollowUpReminderCandidate.task(
            taskId: task.id,
            taskTitle: task.title,
            scheduledAt: taskReminder,
          ),
        );
      }

      for (final reminder in task.taskReminders) {
        if (reminder.status != 'active') continue;
        final scheduledAt = taskReminderNotificationTime(reminder, allDayNotificationMinutes: allDayReminderNotificationMinutes);
        if (scheduledAt.isBefore(now)) continue;
        result.add(
          FollowUpReminderCandidate.taskReminder(
            taskId: task.id,
            taskTitle: task.title,
            taskReminderId: reminder.id,
            label: reminder.title,
            scheduledAt: scheduledAt,
          ),
        );
      }

      for (final followUp in task.followUps) {
        if (followUp.completed) continue;
        final reminderDate = followUp.reminderDate;
        if (reminderDate == null || reminderDate.isBefore(now)) continue;

        final note = followUp.note.trim();
        result.add(
          FollowUpReminderCandidate(
            taskId: task.id,
            taskTitle: task.title,
            followUpId: followUp.id,
            label: note.isEmpty ? 'پیگیری' : note,
            scheduledAt: reminderDate,
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

/// Date-only reminders remain all-day calendar events. Notifications use the
/// user's configured local time (09:00 by default) without changing the date.
DateTime taskReminderNotificationTime(
  TaskReminder reminder, {
  int allDayNotificationMinutes = defaultAllDayReminderNotificationMinutes,
}) {
  if (!reminder.isAllDay) return reminder.date;
  final minutes = normalizeAllDayReminderNotificationMinutes(
    allDayNotificationMinutes,
  );
  return DateTime(
    reminder.date.year,
    reminder.date.month,
    reminder.date.day,
    minutes ~/ 60,
    minutes % 60,
  );
}
