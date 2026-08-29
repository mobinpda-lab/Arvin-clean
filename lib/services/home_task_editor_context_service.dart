import '../models/goal_project.dart';
import '../models/task.dart';
import 'task_project_assignment_service.dart';

class HomeTaskEditorContext {
  const HomeTaskEditorContext({
    required this.projects,
    required this.selectedProjectId,
    required this.knownCategories,
  });

  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final List<String> knownCategories;
}

/// Thin Home-facing adapter for preparing the canonical Task editor inputs.
///
/// It reuses TaskProjectAssignmentService/ProjectStore for Project membership
/// and derives category suggestions from the already-loaded canonical Tasks.
/// It owns no persistence and does not add projectId to Task.
class HomeTaskEditorContextService {
  HomeTaskEditorContextService({
    TaskProjectAssignmentService? assignmentService,
  }) : assignmentService = assignmentService ?? TaskProjectAssignmentService();

  final TaskProjectAssignmentService assignmentService;

  Future<HomeTaskEditorContext> load({
    required Iterable<Task> tasks,
    Task? task,
  }) async {
    final projects = await assignmentService.loadProjects();
    final selectedProjectId = task == null
        ? null
        : await assignmentService.projectIdForTask(task.id);

    final categories = tasks
        .map((item) => item.category?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return HomeTaskEditorContext(
      projects: List<ProjectPlan>.unmodifiable(projects),
      selectedProjectId: selectedProjectId,
      knownCategories: List<String>.unmodifiable(categories),
    );
  }
}
