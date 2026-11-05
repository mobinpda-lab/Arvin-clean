// G1 current-main validation checkpoint: this test must run against the live main base before merge.
import 'dart:io';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await ProjectStore.resetTestDatabase();
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saves and restores canonical project identity color and membership', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final taskStore = TaskStore(executor: database);
    await taskStore.save([
      Task(id: 'task-1', title: 'یک'),
      Task(id: 'task-2', title: 'دو'),
    ]);
    final store = ProjectStore(executor: database);
    final projects = [
      ProjectPlan(
        id: 'project-1',
        title: 'کاری',
        colorValue: 0xFF2F80ED,
        itemIds: const ['task-1', 'task-2'],
      ),
    ];

    await store.save(projects);
    final restored = await store.load();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'project-1');
    expect(restored.single.title, 'کاری');
    expect(restored.single.colorValue, 0xFF2F80ED);
    expect(restored.single.itemIds, ['task-1', 'task-2']);
  });

  test('file-backed database preserves Project and Task membership after a fresh reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-project-persistence-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/arvin.sqlite');

    final firstDatabase = NativeDatabase(file);
    final firstTasks = TaskStore(executor: firstDatabase);
    final firstProjects = ProjectStore(executor: firstDatabase);
    await firstTasks.save([
      Task(id: 'durable-task-1', title: 'کار پایدار یک'),
      Task(id: 'durable-task-2', title: 'کار پایدار دو'),
    ]);
    await firstProjects.save([
      ProjectPlan(
        id: 'durable-project',
        title: 'پروژه پایدار',
        colorValue: 0xFF2F80ED,
        isArchived: true,
        itemIds: const ['durable-task-1', 'durable-task-2'],
      ),
    ]);

    await firstDatabase.close();

    // A new executor and new Store instances must recover the same file-backed
    // records. Reusing the first executor would only prove in-process state.
    final reopenedDatabase = NativeDatabase(file);
    addTearDown(reopenedDatabase.close);
    final reopenedTasks = await TaskStore(executor: reopenedDatabase).load();
    final reopenedProjects = await ProjectStore(executor: reopenedDatabase).load();

    expect(reopenedTasks.map((task) => task.id),
        containsAll(['durable-task-1', 'durable-task-2']));
    expect(reopenedProjects, hasLength(1));
    expect(reopenedProjects.single.id, 'durable-project');
    expect(reopenedProjects.single.title, 'پروژه پایدار');
    expect(reopenedProjects.single.colorValue, 0xFF2F80ED);
    expect(reopenedProjects.single.isArchived, isTrue);
    expect(reopenedProjects.single.itemIds, ['durable-task-1', 'durable-task-2']);
  });

  test('empty storage loads safely and clear removes project collection', () async {
    final store = ProjectStore();
    expect(await store.load(), isEmpty);

    await store.save([ProjectPlan(id: 'p', title: 'پروژه')]);
    expect(await store.load(), hasLength(1));

    await store.clear();
    expect(await store.load(), isEmpty);
  });

  test('legacy project membership migrates after canonical task migration', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      TaskStore.key: '[{"id":"legacy-task","title":"کار قدیمی"}]',
      ProjectStore.key: '[{"id":"legacy-project","title":"پروژه قدیمی","itemIds":["legacy-task"]}]',
    });

    final projects = await ProjectStore().load();
    final tasks = await TaskStore().load();

    expect(tasks.map((task) => task.id), contains('legacy-task'));
    expect(projects.single.id, 'legacy-project');
    expect(projects.single.itemIds, ['legacy-task']);
  });

  test('legacy project json migrates into SQL and stays canonical', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ProjectStore.key: '[{"id":"legacy","title":"قدیمی"}]',
    });

    final restored = await ProjectStore().load();

    expect(restored.single.id, 'legacy');
    expect(restored.single.itemIds, isEmpty);

    SharedPreferences.setMockInitialValues(<String, Object>{
      ProjectStore.key: '[{"id":"legacy","title":"تغییر قدیمی"}]',
    });
    final fresh = await ProjectStore().load();
    expect(fresh.single.title, 'قدیمی');
  });
}
