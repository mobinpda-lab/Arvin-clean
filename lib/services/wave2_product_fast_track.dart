import '../models/task.dart';
import '../models/goal_project.dart';
import 'project_store.dart';
import 'home_task_editor_context_service.dart';
import 'task_project_assignment_service.dart';

/// Product-only coordinator for the first Wave 2 canonical Task entry slice.
///
/// It deliberately composes the existing context and project-assignment
/// services instead of introducing another Task model or persistence store.
class Wave2ProductFastTrack {
  Wave2ProductFastTrack({
    HomeTaskEditorContextService? contextService,
    TaskProjectAssignmentService? assignmentService,
  })  : contextService = contextService ?? HomeTaskEditorContextService(),
        assignmentService =
            assignmentService ?? TaskProjectAssignmentService();

  final HomeTaskEditorContextService contextService;
  final TaskProjectAssignmentService assignmentService;

  Future<String> createProject(String title) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw ArgumentError.value(title, 'title');
    final store = ProjectStore();
    final projects = await store.load();
    final project = ProjectPlan(
      id: 'project_${DateTime.now().microsecondsSinceEpoch}',
      title: cleanTitle,
    );
    await store.save([...projects, project]);
    return project.id;
  }

  Future<HomeTaskEditorContext> prepareEditor({
    required Iterable<Task> tasks,
    Task? task,
  }) {
    return contextService.load(tasks: tasks, task: task);
  }

  Future<void> persistProjectSelection({
    required String taskId,
    required String? projectId,
  }) async {
    await assignmentService.assign(taskId: taskId, projectId: projectId);
  }
}
