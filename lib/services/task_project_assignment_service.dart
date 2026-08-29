import '../models/goal_project.dart';
import 'project_store.dart';

/// Canonical persistence coordinator for assigning an existing Task id to at
/// most one first-class Project.
///
/// Project membership remains owned exclusively by ProjectPlan.itemIds. This
/// service never writes a projectId into Task and never duplicates Task data.
class TaskProjectAssignmentService {
  TaskProjectAssignmentService({
    ProjectStore? store,
    this.lifecycle = const ProjectLifecycleService(),
  }) : store = store ?? ProjectStore();

  final ProjectStore store;
  final ProjectLifecycleService lifecycle;

  Future<List<ProjectPlan>> loadProjects() => store.load();

  Future<String?> projectIdForTask(String taskId) async {
    final projects = await store.load();
    for (final project in projects) {
      if (project.itemIds.contains(taskId)) return project.id;
    }
    return null;
  }

  Future<List<ProjectPlan>> assign({
    required String taskId,
    required String? projectId,
  }) async {
    final current = await store.load();
    final next = lifecycle.assignTask(
      current,
      taskId: taskId,
      projectId: projectId,
    );
    await store.save(next);
    return next;
  }
}
