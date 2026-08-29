import 'package:arvin/backup_manager.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_backup_bridge.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingBackupManager extends ArvinBackupManager {
  List<ProjectPlan>? capturedProjects;
  List<Task>? capturedTasks;

  @override
  Future<String?> backupCanonicalTasks(
    Iterable<Task> tasks, {
    Map<String, dynamic>? settings,
    Iterable<ProjectPlan>? projects,
    String? encryptionPassphrase,
  }) async {
    capturedTasks = List<Task>.of(tasks);
    capturedProjects = projects == null ? null : List<ProjectPlan>.of(projects);
    return 'arvin-test-backup.json';
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('backup always includes Projects from canonical ProjectStore', () async {
    final store = ProjectStore();
    await store.save([
      ProjectPlan(id: 'p1', title: 'پروژه', itemIds: ['t1']),
    ]);
    final manager = _RecordingBackupManager();
    final bridge = ProjectBackupBridge(
      projectStore: store,
      backupManager: manager,
    );
    final task = Task(id: 't1', title: 'کار');

    final fileName = await bridge.backup([task]);

    expect(fileName, 'arvin-test-backup.json');
    expect(manager.capturedTasks?.single.id, 't1');
    expect(manager.capturedProjects?.single.id, 'p1');
    expect(manager.capturedProjects?.single.itemIds, ['t1']);
  });

  test('restore writes candidate Projects through canonical ProjectStore', () async {
    final store = ProjectStore();
    final bridge = ProjectBackupBridge(projectStore: store);
    final candidate = (
      tasks: <Task>[],
      settings: null,
      projects: [ProjectPlan(id: 'p2', title: 'بازیابی')],
    );

    await bridge.restoreProjects(candidate);

    final restored = await store.load();
    expect(restored, hasLength(1));
    expect(restored.single.id, 'p2');
    expect(restored.single.title, 'بازیابی');
  });
}
