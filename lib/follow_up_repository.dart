import 'models/task.dart';
import 'services/task_store.dart';

/// Canonical persistence boundary for FollowUp data.
///
/// FollowUps remain embedded in the canonical Task document. All mutations are
/// routed through [TaskStore.mutate] so FollowUp writes cannot race with Home,
/// Notebook, recurrence, People, or Sync writes to `arvin.tasks`.
class FollowUpRepository {
  const FollowUpRepository();

  TaskStore get _store => TaskStore();

  Future<List<FollowUp>> loadForTask(String taskId) async {
    final tasks = await _store.load();
    for (final task in tasks) {
      if (task.id == taskId) return _decodeFollowUps(task);
    }
    return const [];
  }

  Future<void> add(String taskId, FollowUp followUp) async {
    await _store.mutate<void>((tasks) {
      final task = _requiredTask(tasks, taskId);
      task.followUps = [..._decodeFollowUps(task), followUp];
      _reconcileReminder(task, followUp);
      task.followUpEnabled = true;
      task.updatedAt = DateTime.now();
    });
  }

  Future<void> update(String taskId, FollowUp followUp) async {
    await _store.mutate<void>((tasks) {
      final task = _requiredTask(tasks, taskId);
      final existing = _decodeFollowUps(task);
      final index = existing.indexWhere((item) => item.id == followUp.id);
      if (index < 0) {
        throw StateError('FollowUp not found: ${followUp.id}');
      }

      final updated = List<FollowUp>.of(existing)..[index] = followUp;
      task.followUps = updated;
      _reconcileReminder(task, followUp);
      task.followUpEnabled = true;
      task.updatedAt = DateTime.now();
    });
  }

  Future<FollowUp> setCompleted(
    String taskId,
    String followUpId,
    bool completed,
  ) {
    return _store.mutate<FollowUp>((tasks) {
      final task = _requiredTask(tasks, taskId);
      final existing = _decodeFollowUps(task);
      final index = existing.indexWhere((item) => item.id == followUpId);
      if (index < 0) {
        throw StateError('FollowUp not found: $followUpId');
      }

      final current = existing[index];
      final updatedFollowUp = FollowUp(
        id: current.id,
        dateTime: current.dateTime,
        title: current.title,
        note: current.note,
        result: current.result,
        reminderDate: current.reminderDate,
        nextFollowUp: current.nextFollowUp,
        completed: completed,
        waitingForResponse: current.waitingForResponse,
        personIds: List<String>.of(current.personIds),
      );
      final updated = List<FollowUp>.of(existing)..[index] = updatedFollowUp;
      task.followUps = updated;
      task.followUpEnabled = true;
      task.updatedAt = DateTime.now();
      return updatedFollowUp;
    });
  }

  /// Mirrors the optional FollowUp reminder into the canonical TaskReminder
  /// collection. The stable ID is preserved on edits; clearing the time removes
  /// only the reminder explicitly linked to this FollowUp.
  void _reconcileReminder(Task task, FollowUp followUp) {
    final linked = task.taskReminders
        .where((item) => item.followUpId == followUp.id)
        .toList(growable: false);

    if (followUp.reminderDate == null) {
      if (linked.isNotEmpty) {
        task.taskReminders = task.taskReminders
            .where((item) => item.followUpId != followUp.id)
            .toList();
      }
      return;
    }

    final rawFollowUpTitle = followUp.title?.trim() ?? '';
    final rawTaskTitle = task.title.trim();
    final reminderTitle = rawFollowUpTitle.isNotEmpty
        ? rawFollowUpTitle
        : rawTaskTitle.isNotEmpty
            ? 'پیگیری — $rawTaskTitle'
            : 'پیگیری';

    if (linked.isNotEmpty) {
      final primary = linked.first;
      final updated = primary.copyWith(
        title: reminderTitle,
        date: followUp.reminderDate!,
      );
      task.taskReminders = [
        for (final reminder in task.taskReminders)
          if (reminder.followUpId != followUp.id) reminder,
        updated,
      ];
      return;
    }

    final sequence = task.nextReminderSequence < 1 ? 1 : task.nextReminderSequence;
    task.taskReminders = [
      ...task.taskReminders,
      TaskReminder(
        id: 'follow-up-reminder-${followUp.id}',
        title: reminderTitle,
        date: followUp.reminderDate!,
        sequence: sequence,
        followUpId: followUp.id,
      ),
    ];
    task.nextReminderSequence = sequence + 1;
  }

  Task _requiredTask(List<Task> tasks, String taskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) throw StateError('Task not found: $taskId');
    return tasks[index];
  }

  List<FollowUp> _decodeFollowUps(Task task) {
    if (task.followUps.isNotEmpty) {
      return List<FollowUp>.of(task.followUps);
    }

    final legacy = task.followUpDate;
    if (legacy == null) return const [];
    return <FollowUp>[
      FollowUp(
        id: legacy.microsecondsSinceEpoch.toString(),
        dateTime: legacy,
        note: 'مهاجرت خودکار از تاریخ پیگیری قبلی',
      ),
    ];
  }
}
