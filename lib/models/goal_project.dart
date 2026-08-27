class ProjectPlan {
  ProjectPlan({
    required this.id,
    required this.title,
    Iterable<String> itemIds = const [],
  }) : itemIds = List.unmodifiable(itemIds);

  final String id;
  final String title;

  /// References existing canonical Task ids. Item payloads are never copied
  /// into this planning domain, preserving Task as the executable source of
  /// truth.
  final List<String> itemIds;
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
