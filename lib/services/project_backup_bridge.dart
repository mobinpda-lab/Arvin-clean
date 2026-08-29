import '../backup_manager.dart';
import '../models/goal_project.dart';
import '../models/task.dart';
import 'project_store.dart';

/// Thin bridge that keeps Home/backup UI from duplicating Project persistence
/// rules. Tasks remain owned by the existing backup document; Projects are
/// loaded/saved through the canonical ProjectStore only.
class ProjectBackupBridge {
  ProjectBackupBridge({
    ProjectStore? projectStore,
    ArvinBackupManager? backupManager,
  })  : projectStore = projectStore ?? ProjectStore(),
        backupManager = backupManager ?? ArvinBackupManager();

  final ProjectStore projectStore;
  final ArvinBackupManager backupManager;

  Future<String?> backup(
    Iterable<Task> tasks, {
    Map<String, dynamic>? settings,
    String? encryptionPassphrase,
  }) async {
    final projects = await projectStore.load();
    return backupManager.backupCanonicalTasks(
      tasks,
      settings: settings,
      projects: projects,
      encryptionPassphrase: encryptionPassphrase,
    );
  }

  Future<void> restoreProjects(CanonicalBackupCandidate candidate) =>
      projectStore.save(candidate.projects);

  Future<List<ProjectPlan>> loadProjects() => projectStore.load();
}
