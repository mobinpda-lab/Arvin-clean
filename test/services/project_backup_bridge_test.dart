import 'package:arvin/backup_manager.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_backup_bridge.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

class _RecordingBackupManager extends ArvinBackupManager {
  List<ProjectPlan>? capturedProjects;
  List<Task>? capturedTasks;
  List<ExternalCalendarEventLink>? capturedCalendarLinks;
  List<String>? capturedCategories;
  List<String>? capturedTags;

  @override
  Future<String?> backupCanonicalTasks(
    Iterable<Task> tasks, {
    Map<String, dynamic>? settings,
    Iterable<ProjectPlan>? projects,
    Iterable<ExternalCalendarEventLink>? calendarLinks,
    Iterable<String>? categories,
    Iterable<String>? tags,
    String? encryptionPassphrase,
  }) async {
    capturedTasks = List<Task>.of(tasks);
    capturedProjects = projects == null ? null : List<ProjectPlan>.of(projects);
    capturedCalendarLinks = calendarLinks == null
        ? null
        : List<ExternalCalendarEventLink>.of(calendarLinks);
    capturedCategories = categories == null ? null : List<String>.of(categories);
    capturedTags = tags == null ? null : List<String>.of(tags);
    return 'arvin-test-backup.json';
  }
}

void main() {
  late NativeDatabase database;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = NativeDatabase.memory();
  });

  tearDown(() async => database.close());

  test('backup always includes Projects from canonical ProjectStore', () async {
    final store = ProjectStore(executor: database);
    await TaskStore(executor: database).save([Task(id: 't1', title: 'کار')]);
    await store.save([
      ProjectPlan(id: 'p1', title: 'پروژه', itemIds: ['t1']),
    ]);
    final link = ExternalCalendarEventLink(
      reminderId: 'task-due:t1',
      calendarId: '42',
      eventId: 'event-t1',
      lastSyncedFingerprint: 'fingerprint-t1',
    );
    await ExternalCalendarLinkStore().save([link]);
    final manager = _RecordingBackupManager();
    final bridge = ProjectBackupBridge(
      projectStore: store,
      backupManager: manager,
      taskStore: TaskStore(executor: database),
    );
    final task = Task(id: 't1', title: 'کار');

    final fileName = await bridge.backup([task]);

    expect(fileName, 'arvin-test-backup.json');
    expect(manager.capturedTasks?.single.id, 't1');
    expect(manager.capturedProjects?.single.id, 'p1');
    expect(manager.capturedProjects?.single.itemIds, ['t1']);
    expect(manager.capturedCalendarLinks?.single.eventId, 'event-t1');
    expect(manager.capturedCategories, isNotNull);
    expect(manager.capturedTags, isNotNull);
  });

  test('restore writes candidate Projects through canonical ProjectStore', () async {
    final store = ProjectStore(executor: database);
    final bridge = ProjectBackupBridge(projectStore: store);
    final candidate = (
      tasks: <Task>[],
      settings: null,
      projects: [ProjectPlan(id: 'p2', title: 'بازیابی')],
      calendarLinks: null,
      categories: null,
      tags: null,
    );

    await bridge.restoreProjects(candidate);

    final restored = await store.load();
    expect(restored, hasLength(1));
    expect(restored.single.id, 'p2');
    expect(restored.single.title, 'بازیابی');
  });
}
