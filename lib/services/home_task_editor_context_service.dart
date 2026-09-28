import '../models/goal_project.dart';
import '../models/task.dart';
import 'task_project_assignment_service.dart';
import 'task_store.dart';

class HomeTaskEditorContext {
  const HomeTaskEditorContext({
    required this.projects,
    required this.selectedProjectId,
    required this.knownCategories,
    required this.knownTags,
  });

  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final List<String> knownCategories;
  final List<String> knownTags;
}

/// Thin Home-facing adapter for preparing the canonical Task editor inputs.
///
/// It reuses TaskProjectAssignmentService/ProjectStore for Project membership
/// and derives category suggestions from the already-loaded canonical Tasks.
/// It owns no persistence and does not add projectId to Task.
class HomeTaskEditorContextService {
  HomeTaskEditorContextService({
    TaskProjectAssignmentService? assignmentService,
    TaskStore? taskStore,
  }) : assignmentService = assignmentService ?? TaskProjectAssignmentService(),
       taskStore = taskStore ?? TaskStore();

  final TaskProjectAssignmentService assignmentService;
  final TaskStore taskStore;

  Future<HomeTaskEditorContext> load({
    required Iterable<Task> tasks,
    Task? task,
  }) async {
    final projects = await assignmentService.loadProjects();
    final selectedProjectId = task == null
        ? null
        : await assignmentService.projectIdForTask(task.id);

    final storedTags = await taskStore.loadTags();
    final storedCategories = await taskStore.loadCategories();

    final tags = <String>{
      ...storedTags,
      ...tasks.expand((item) => item.tags),
    }
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
      ..sort();

    final categories = <String>{
      ...storedCategories,
      ...tasks.map((item) => item.category ?? ''),
    }
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
      ..sort();

    return HomeTaskEditorContext(
      projects: List<ProjectPlan>.unmodifiable(projects),
      selectedProjectId: selectedProjectId,
      knownCategories: List<String>.unmodifiable(categories),
      knownTags: List<String>.unmodifiable(tags),
    );
  }
}
