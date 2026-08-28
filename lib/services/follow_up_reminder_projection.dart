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
  });

  final String taskId;
  final String taskTitle;
  final String followUpId;
  final String label;
  final DateTime scheduledAt;

  String get stableKey => '$taskId:$followUpId';
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
      if (task.trashed) continue;

      for (final followUp in task.followUps) {
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
