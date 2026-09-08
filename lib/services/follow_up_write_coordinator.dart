import '../automatic_follow_up_scheduler_adapter.dart';
import '../follow_up_repository.dart';
import '../models/task.dart';

/// Keeps canonical FollowUp persistence separate from Android scheduling while
/// ensuring successful user writes request a fresh automatic-follow-up alarm.
class FollowUpWriteCoordinator {
  const FollowUpWriteCoordinator({
    required this.repository,
    required this.scheduler,
    this.reminderReschedule,
  });

  final FollowUpRepository repository;
  final AutomaticFollowUpSchedulerAdapter scheduler;
  final Future<void> Function()? reminderReschedule;

  Future<void> add(String taskId, FollowUp followUp) async {
    await repository.add(taskId, followUp);
    await _rescheduleBestEffort();
  }

  Future<void> update(String taskId, FollowUp followUp) async {
    await repository.update(taskId, followUp);
    await _rescheduleBestEffort();
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
    await _rescheduleBestEffort();
    return followUp;
  }

  Future<void> _rescheduleBestEffort() async {
    try {
      await scheduler.reschedule();
    } catch (_) {
      // Canonical persistence already succeeded; runtime can retry later.
    }
    final reminder = reminderReschedule;
    if (reminder != null) {
      try {
        await reminder();
      } catch (_) {
        // Independent FollowUp reminder scheduling is also best-effort after
        // the canonical write and will be reconstructed from TaskStore.
      }
    }
  }
}
