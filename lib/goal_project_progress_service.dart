import 'models/goal_project.dart';
import 'models/task.dart';

class ProjectProgressSnapshot {
  const ProjectProgressSnapshot({
    required this.projectId,
    required this.totalItems,
    required this.completedItems,
    required this.isValid,
  });

  final String projectId;
  final int totalItems;
  final int completedItems;
  final bool isValid;

  double? get completionRatio {
    if (!isValid) return null;
    if (totalItems == 0) return 0;
    return completedItems / totalItems;
  }
}

class GoalProgressSnapshot {
  GoalProgressSnapshot({
    required this.validation,
    required Iterable<ProjectProgressSnapshot> projects,
  }) : projects = List.unmodifiable(projects);

  final GoalProjectValidation validation;
  final List<ProjectProgressSnapshot> projects;

  int get totalItems =>
      projects.fold(0, (sum, project) => sum + project.totalItems);

  int get completedItems =>
      projects.fold(0, (sum, project) => sum + project.completedItems);

  double? get completionRatio {
    if (!validation.isValid) return null;
    if (totalItems == 0) return 0;
    return completedItems / totalItems;
  }
}

/// Read-only progress projection for Goal -> Project -> Item.
///
/// Task remains the executable source of truth. This service stores nothing,
/// copies no Task payload, and derives progress only from referenced canonical
/// Task ids and their current `completed` state.
class GoalProjectProgressService {
  const GoalProjectProgressService();

  GoalProgressSnapshot project(
    GoalPlan goal, {
    required Iterable<Task> canonicalTasks,
  }) {
    final tasksById = <String, Task>{};
    for (final task in canonicalTasks) {
      if (task.id.isNotEmpty) {
        tasksById[task.id] = task;
      }
    }

    final validation = const GoalProjectService().validate(
      goal,
      canonicalItemIds: tasksById.keys,
    );

    final invalidItems = validation.duplicateItemIds.toSet();
    final invalidProjects = validation.duplicateProjectIds.toSet();

    final projects = goal.projects.map((project) {
      var completedItems = 0;
      var hasMissingItem = false;
      var hasDuplicateItem = false;

      for (final itemId in project.itemIds) {
        final task = tasksById[itemId];
        if (task == null) {
          hasMissingItem = true;
          continue;
        }
        if (task.completed) {
          completedItems++;
        }
        if (invalidItems.contains(itemId)) {
          hasDuplicateItem = true;
        }
      }

      return ProjectProgressSnapshot(
        projectId: project.id,
        totalItems: project.itemIds.length,
        completedItems: completedItems,
        isValid: !hasMissingItem &&
            !hasDuplicateItem &&
            !invalidProjects.contains(project.id),
      );
    });

    return GoalProgressSnapshot(
      validation: validation,
      projects: projects,
    );
  }
}
