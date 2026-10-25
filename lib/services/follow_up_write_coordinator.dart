import '../follow_up_repository.dart';
import '../models/task.dart';

/// Persists FollowUp history only. FollowUp writes never schedule notifications;
/// all delivery is driven by canonical TaskReminder records.
class FollowUpWriteCoordinator {
  const FollowUpWriteCoordinator({required this.repository});

  final FollowUpRepository repository;

  Future<void> add(String taskId, FollowUp followUp) =>
      repository.add(taskId, followUp);

  Future<void> update(String taskId, FollowUp followUp) =>
      repository.update(taskId, followUp);

  Future<FollowUp> setCompleted(
    String taskId,
    String followUpId,
    bool completed,
  ) =>
      repository.setCompleted(taskId, followUpId, completed);
}
