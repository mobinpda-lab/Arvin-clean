import '../models/task.dart';

/// Returns true when no tag filter is selected or at least one selected tag
/// matches the Task. Different Home filter dimensions remain AND-combined.
bool homeTaskMatchesAnySelectedTag(Task task, Set<String> selectedTags) {
  if (selectedTags.isEmpty) return true;
  final taskTags = task.tags
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet();
  return selectedTags.any(taskTags.contains);
}
