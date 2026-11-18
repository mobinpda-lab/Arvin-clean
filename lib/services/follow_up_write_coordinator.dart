import '../follow_up_repository.dart';
import '../models/task.dart';

/// Persists canonical FollowUp records and refreshes the independent Reminder
/// schedule after successful writes.
class FollowUpWriteCoordinator {
  const FollowUpWriteCoordinator({
    required this.repository,
    this.reminderReschedule,
  });

  final FollowUpRepository repository;
  final Future<void> Function()? reminderReschedule;

  Future<void> add(String taskId, FollowUp followUp) async {
    await repository.add(taskId, followUp);
    await _rescheduleReminderBestEffort();
  }

  Future<void> update(String taskId, FollowUp followUp) async {
    await repository.update(taskId, followUp);
    await _rescheduleReminderBestEffort();
  }

  Future<FollowUp> setCompleted(
    String taskId,
    String followUpId,
    bool completed,
  ) async {
    final followUp = await repository.setCompleted(
      taskId,
      followUpId,
      completed,
    );
    await _rescheduleReminderBestEffort();
    return followUp;
  }

  Future<void> _rescheduleReminderBestEffort() async {
    final reminder = reminderReschedule;
    if (reminder == null) return;

    try {
      await reminder();
    } catch (_) {
      // Reminder scheduling is best-effort after the canonical write and will
      // be reconstructed from TaskStore. Never roll back a successful write.
    }
  }
}
