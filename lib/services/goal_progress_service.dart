import '../models/goal_project.dart';
import '../models/task.dart';

class ProjectProgress {
  ProjectProgress({
    required this.projectId,
    required this.totalItems,
    required this.completedItems,
    required Iterable<String> missingItemIds,
  }) : missingItemIds = List.unmodifiable(missingItemIds);

  final String projectId;
  final int totalItems;
  final int completedItems;
  final List<String> missingItemIds;

  double get ratio => totalItems == 0 ? 0 : completedItems / totalItems;

  bool get isComplete =>
      totalItems > 0 &&
      missingItemIds.isEmpty &&
      completedItems == totalItems;
}

class GoalProgress {
  GoalProgress({
    required this.goalId,
    required this.totalItems,
    required this.completedItems,
    required this.validation,
    required Iterable<ProjectProgress> projects,
  }) : projects = List.unmodifiable(projects);

  final String goalId;
  final int totalItems;
  final int completedItems;
  final GoalProjectValidation validation;
  final List<ProjectProgress> projects;

  double get ratio => totalItems == 0 ? 0 : completedItems / totalItems;

  bool get isComplete =>
      validation.isValid && totalItems > 0 && completedItems == totalItems;
}

/// Projects Goal -> Project progress from the existing canonical Task state.
///
/// No Task payload is copied into the planning model and no persistence is
/// owned here. Missing or duplicate references remain explicit validation
/// evidence instead of being silently ignored.
class GoalProgressService {
  const GoalProgressService({
    GoalProjectService goalProjectService = const GoalProjectService(),
  }) : _goalProjectService = goalProjectService;

  final GoalProjectService _goalProjectService;

  GoalProgress project(
    GoalPlan goal, {
    required Iterable<Task> canonicalTasks,
  }) {
    final tasksById = <String, Task>{};
    final duplicateCanonicalIds = <String>{};
    for (final task in canonicalTasks) {
      if (tasksById.containsKey(task.id)) {
        duplicateCanonicalIds.add(task.id);
      } else {
        tasksById[task.id] = task;
      }
    }
    if (duplicateCanonicalIds.isNotEmpty) {
      final ids = duplicateCanonicalIds.toList()..sort();
      throw ArgumentError('Duplicate canonical Task ids: ${ids.join(', ')}');
    }

    final validation = _goalProjectService.validate(
      goal,
      canonicalItemIds: tasksById.keys,
    );

    final projectProgress = <ProjectProgress>[];
    final allReferencedIds = <String>{};

    for (final project in goal.projects) {
      final missing = <String>[];
      var completed = 0;

      for (final itemId in project.itemIds) {
        allReferencedIds.add(itemId);
        final task = tasksById[itemId];
        if (task == null) {
          missing.add(itemId);
        } else if (task.completed) {
          completed += 1;
        }
      }

      missing.sort();
      projectProgress.add(
        ProjectProgress(
          projectId: project.id,
          totalItems: project.itemIds.length,
          completedItems: completed,
          missingItemIds: missing,
        ),
      );
    }

    var overallCompleted = 0;
    for (final itemId in allReferencedIds) {
      if (tasksById[itemId]?.completed == true) {
        overallCompleted += 1;
      }
    }

    return GoalProgress(
      goalId: goal.id,
      totalItems: allReferencedIds.length,
      completedItems: overallCompleted,
      validation: validation,
      projects: projectProgress,
    );
  }
}
