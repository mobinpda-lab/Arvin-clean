import '../backup_manager.dart';
import '../models/goal_project.dart';
import '../models/task.dart';
import 'project_store.dart';
import 'external_calendar_link_store.dart';
import 'task_store.dart';

/// Thin bridge that keeps Home/backup UI from duplicating Project persistence
/// rules. Tasks remain owned by the existing backup document; Projects are
/// loaded/saved through the canonical ProjectStore only.
class ProjectBackupBridge {
  ProjectBackupBridge({
    ProjectStore? projectStore,
    ArvinBackupManager? backupManager,
    TaskStore? taskStore,
  })  : projectStore = projectStore ?? ProjectStore(),
        backupManager = backupManager ?? ArvinBackupManager(),
        taskStore = taskStore ?? TaskStore();

  final ProjectStore projectStore;
  final ArvinBackupManager backupManager;
  final TaskStore taskStore;

  Future<String?> backup(
    Iterable<Task> tasks, {
    Map<String, dynamic>? settings,
    String? encryptionPassphrase,
  }) async {
    final projects = await projectStore.load();
    final calendarLinks = await ExternalCalendarLinkStore().load();
    final categories = await taskStore.loadCategories();
    final tags = await taskStore.loadTags();
    return backupManager.backupCanonicalTasks(
      tasks,
      settings: settings,
      projects: projects,
      calendarLinks: calendarLinks,
      categories: categories,
      tags: tags,
      encryptionPassphrase: encryptionPassphrase,
    );
  }

  Future<void> restoreProjects(CanonicalBackupCandidate candidate) =>
      projectStore.save(candidate.projects);

  Future<List<ProjectPlan>> loadProjects() => projectStore.load();
}
