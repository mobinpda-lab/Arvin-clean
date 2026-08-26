import '../automatic_follow_up_scheduler_adapter.dart';
import '../follow_up_repository.dart';
import '../models/task.dart';

/// Keeps canonical FollowUp persistence separate from Android scheduling while
/// ensuring successful user writes request a fresh automatic-follow-up alarm.
class FollowUpWriteCoordinator {
  const FollowUpWriteCoordinator({
    required this.repository,
    required this.scheduler,
  });

  final FollowUpRepository repository;
  final AutomaticFollowUpSchedulerAdapter scheduler;

  Future<void> add(String taskId, FollowUp followUp) async {
    await repository.add(taskId, followUp);
    await _rescheduleBestEffort();
  }

  Future<void> update(String taskId, FollowUp followUp) async {
    await repository.update(taskId, followUp);
    await _rescheduleBestEffort();
  }

  Future<void> _rescheduleBestEffort() async {
    try {
      await scheduler.reschedule();
    } catch (_) {
      // Persistence already succeeded. A platform scheduling failure must not
      // turn a saved user edit into a false write failure; the next app/runtime
      // scheduling opportunity can retry from canonical Task/FollowUp data.
    }
  }
}
