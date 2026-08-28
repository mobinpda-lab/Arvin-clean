class ProjectPlan {
  ProjectPlan({
    required this.id,
    required this.title,
    this.colorValue = 0xFF4A4CAB,
    Iterable<String> itemIds = const [],
  }) : itemIds = List.unmodifiable(itemIds);

  final String id;
  final String title;

  /// Persistable ARGB color value owned by the Project itself.
  ///
  /// This deliberately stays a plain integer so the planning model remains
  /// Flutter/presentation independent. UI can render it as a Color.
  final int colorValue;

  /// References existing canonical Task ids. Item payloads are never copied
  /// into this planning domain, preserving Task as the executable source of
  /// truth.
  final List<String> itemIds;

  bool get hasItems => itemIds.isNotEmpty;

  /// Owner contract: a non-empty Project cannot be deleted.
  bool get canDelete => itemIds.isEmpty;

  ProjectPlan copyWith({
    String? title,
    int? colorValue,
    Iterable<String>? itemIds,
  }) {
    return ProjectPlan(
      id: id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      itemIds: itemIds ?? this.itemIds,
    );
  }
}

class GoalPlan {
  GoalPlan({
    required this.id,
    required this.title,
    Iterable<ProjectPlan> projects = const [],
  }) : projects = List.unmodifiable(projects);

  final String id;
  final String title;
  final List<ProjectPlan> projects;
}

class ProjectDeleteBlocked implements Exception {
  const ProjectDeleteBlocked(this.projectId);

  final String projectId;

  @override
  String toString() =>
      'ProjectDeleteBlocked: project $projectId still contains canonical Tasks';
}

/// Pure lifecycle operations for Arvin's first-class Project menu.
///
/// Project remains independent from Task category/tags and stores only
/// canonical Task ids. FollowUp state belongs to Task and is never interpreted
/// here, so both FollowUp-enabled and simple Tasks can belong to a Project.
class ProjectLifecycleService {
  const ProjectLifecycleService();

  List<ProjectPlan> add(
    Iterable<ProjectPlan> projects,
    ProjectPlan project,
  ) {
    final current = List<ProjectPlan>.of(projects);
    if (current.any((item) => item.id == project.id)) {
      throw ArgumentError.value(project.id, 'project.id', 'Duplicate Project id');
    }
    return List.unmodifiable([...current, project]);
  }

  List<ProjectPlan> edit(
    Iterable<ProjectPlan> projects, {
    required String projectId,
    String? title,
    int? colorValue,
  }) {
    var found = false;
    final next = projects.map((project) {
      if (project.id != projectId) return project;
      found = true;
      return project.copyWith(title: title, colorValue: colorValue);
    }).toList(growable: false);
    if (!found) {
      throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    }
    return List.unmodifiable(next);
  }

  List<ProjectPlan> delete(
    Iterable<ProjectPlan> projects, {
    required String projectId,
  }) {
    final current = List<ProjectPlan>.of(projects);
    final index = current.indexWhere((project) => project.id == projectId);
    if (index < 0) {
      throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    }
    final project = current[index];
    if (!project.canDelete) {
      throw ProjectDeleteBlocked(projectId);
    }
    current.removeAt(index);
    return List.unmodifiable(current);
  }

  List<ProjectPlan> assignTask(
    Iterable<ProjectPlan> projects, {
    required String taskId,
    required String? projectId,
  }) {
    final current = List<ProjectPlan>.of(projects);
    if (projectId != null && !current.any((project) => project.id == projectId)) {
      throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    }

    return List.unmodifiable(
      current.map((project) {
        final nextIds = project.itemIds.where((id) => id != taskId).toList();
        if (project.id == projectId) {
          nextIds.add(taskId);
        }
        return project.copyWith(itemIds: nextIds);
      }).toList(growable: false),
    );
  }
}

class GoalProjectValidation {
  GoalProjectValidation({
    required Iterable<String> missingItemIds,
    required Iterable<String> duplicateItemIds,
    required Iterable<String> duplicateProjectIds,
  })  : missingItemIds = List.unmodifiable(missingItemIds),
        duplicateItemIds = List.unmodifiable(duplicateItemIds),
        duplicateProjectIds = List.unmodifiable(duplicateProjectIds);

  final List<String> missingItemIds;
  final List<String> duplicateItemIds;
  final List<String> duplicateProjectIds;

  bool get isValid =>
      missingItemIds.isEmpty &&
      duplicateItemIds.isEmpty &&
      duplicateProjectIds.isEmpty;
}

/// Validates Goal -> Project -> Item references against canonical Task ids.
///
/// The service owns no persistence and deliberately refuses to duplicate Task
/// payloads. Each canonical item can belong to at most one project inside a
/// goal in this first contract, keeping progress aggregation deterministic.
class GoalProjectService {
  const GoalProjectService();

  GoalProjectValidation validate(
    GoalPlan goal, {
    required Iterable<String> canonicalItemIds,
  }) {
    final knownItems = canonicalItemIds.toSet();
    final seenItems = <String>{};
    final duplicateItems = <String>{};
    final missingItems = <String>{};
    final seenProjects = <String>{};
    final duplicateProjects = <String>{};

    for (final project in goal.projects) {
      if (!seenProjects.add(project.id)) {
        duplicateProjects.add(project.id);
      }

      for (final itemId in project.itemIds) {
        if (!knownItems.contains(itemId)) {
          missingItems.add(itemId);
        }
        if (!seenItems.add(itemId)) {
          duplicateItems.add(itemId);
        }
      }
    }

    return GoalProjectValidation(
      missingItemIds: missingItems.toList()..sort(),
      duplicateItemIds: duplicateItems.toList()..sort(),
      duplicateProjectIds: duplicateProjects.toList()..sort(),
    );
  }
}
