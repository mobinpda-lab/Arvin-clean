import '../models/goal_project.dart';

/// OR semantics for selections within Home's Project and Category dimensions.
/// The caller composes these dimension predicates with AND.
class HomeFilterMembership {
  const HomeFilterMembership._();

  static const String noProjectId = '__no_project__';

  static bool matchesProjectDimension({
    required String taskId,
    required Iterable<ProjectPlan> projects,
    required Set<String> selectedProjectIds,
  }) {
    if (selectedProjectIds.isEmpty) return true;

    final selectedProjectMatch = projects.any(
      (project) =>
          selectedProjectIds.contains(project.id) &&
          project.itemIds.contains(taskId),
    );
    if (selectedProjectMatch) return true;

    if (!selectedProjectIds.contains(noProjectId)) return false;

    final assignedToAnyProject = projects.any(
      (project) => project.itemIds.contains(taskId),
    );
    return !assignedToAnyProject;
  }

  static bool matchesCategoryDimension({
    required String? taskCategory,
    required Set<String> selectedCategoryNames,
  }) {
    if (selectedCategoryNames.isEmpty) return true;
    final normalized = taskCategory?.trim();
    return normalized != null &&
        normalized.isNotEmpty &&
        selectedCategoryNames.contains(normalized);
  }
}
