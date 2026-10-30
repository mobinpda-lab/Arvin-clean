import '../automatic_follow_up_scheduler_adapter.dart';
import '../follow_up_repository.dart';
import '../models/task.dart';

/// Keeps canonical FollowUp persistence separate from Android scheduling while
/// ensuring successful user writes request a fresh automatic-follow-up alarm.
class FollowUpWriteCoordinator {
  const FollowUpWriteCoordinator({
    required this.repository,
    @Deprecated(
      'Legacy Next Follow-up scheduling is retired; use reminderReschedule '
      'for independent reminder scheduling.',
    )
    AutomaticFollowUpSchedulerAdapter? scheduler,
    this.reminderReschedule,
  }) : scheduler = scheduler;

  final FollowUpRepository repository;

  /// Optional compatibility hook for callers not yet migrated from the
  /// retired Next Follow-up scheduler. New consumers must omit this field.
  final AutomaticFollowUpSchedulerAdapter? scheduler;
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
    final legacyScheduler = scheduler;
    if (legacyScheduler != null) {
      try {
        await legacyScheduler.reschedule();
      } catch (_) {
        // Compatibility scheduling is best-effort after canonical persistence.
      }
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
