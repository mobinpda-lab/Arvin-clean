import '../models/task.dart';

enum TaskListScope { all, simpleNotes, followUpEnabled }

/// Pure projection for the owner-approved non-date Home/list scopes.
///
/// Archived and trashed records stay outside normal list scopes. Completed
/// records remain visible in `all`/type scopes so completion history is not
/// silently hidden. Date scopes are owned by [TaskDueScopeService].
class TaskListScopeService {
  const TaskListScopeService();

  List<Task> project(
    Iterable<Task> tasks, {
    required TaskListScope scope,
  }) {
    return tasks.where((task) {
      if (task.archived || task.trashed) return false;

      return switch (scope) {
        TaskListScope.all => true,
        TaskListScope.simpleNotes => task.isSimpleNote,
        TaskListScope.followUpEnabled =>
          task.followUpEnabled || task.followUps.isNotEmpty,
      };
    }).toList(growable: false);
  }
}
