// G1 current-main validation checkpoint: this test must run against the live main base before merge.
import 'dart:convert';

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

  test('empty storage loads safely and clear removes project collection', () async {
    final store = ProjectStore();
    expect(await store.load(), isEmpty);

    await store.save([ProjectPlan(id: 'p', title: 'پروژه')]);
    expect(await store.load(), hasLength(1));

    await store.clear();
    expect(await store.load(), isEmpty);
  });


  test('upsert preserves omitted Projects and existing membership when itemIds is absent', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final taskStore = TaskStore(executor: database);
    await taskStore.save([Task(id: 'task-keep', title: 'کار')]);
    final store = ProjectStore(executor: database);
    await store.save([
      ProjectPlan(id: 'keep', title: 'پروژه باقی', itemIds: const ['task-keep']),
      ProjectPlan(id: 'untouched', title: 'پروژه دیگر'),
    ]);

    await store.upsert([ProjectPlan(id: 'keep', title: 'عنوان تازه')]);

    final loaded = await store.load();
    expect(loaded.map((project) => project.id).toSet(), {'keep', 'untouched'});
    final kept = loaded.singleWhere((project) => project.id == 'keep');
    expect(kept.title, 'عنوان تازه');
    expect(kept.itemIds, ['task-keep']);
  });

  test('explicit empty membership removes only that Project relationship', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final taskStore = TaskStore(executor: database);
    await taskStore.save([
      Task(id: 'task-a', title: 'الف'),
      Task(id: 'task-b', title: 'ب'),
    ]);
    final store = ProjectStore(executor: database);
    await store.save([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-a']),
      ProjectPlan(id: 'b', title: 'ب', itemIds: const ['task-b']),
    ]);

    await store.upsert([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const []),
    ]);

    final loaded = await store.load();
    expect(loaded.singleWhere((project) => project.id == 'a').itemIds, isEmpty);
    expect(loaded.singleWhere((project) => project.id == 'b').itemIds, ['task-b']);
  });

  test('unknown Project metadata survives load and transactional upsert', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final store = ProjectStore(executor: database);
    await store.save([ProjectPlan(id: 'metadata', title: 'پروژه')]);
    await database.runUpdate(
      'UPDATE projects SET legacy_payload_json = ? WHERE id = ?',
      [jsonEncode({
        'id': 'metadata',
        'title': 'پروژه',
        'colorValue': 0xFF4A4CAB,
        'isArchived': false,
        'itemIds': [],
        'historicalMarker': {'source': 'legacy', 'revision': 3},
      }), 'metadata'],
    );

    final loaded = (await store.load()).single;
    expect(loaded.legacyFields['historicalMarker'], {
      'source': 'legacy',
      'revision': 3,
    });

    await store.upsert([loaded.copyWith(title: 'پروژه ویرایش‌شده')]);
    final stored = await database.runSelect(
      'SELECT legacy_payload_json FROM projects WHERE id = ?',
      const ['metadata'],
    );
    final envelope = jsonDecode(stored.single['legacy_payload_json'] as String) as Map;
    expect(envelope['historicalMarker'], {
      'source': 'legacy',
      'revision': 3,
    });
  });

  test('explicit deletion is transactional and blocks Projects with Task links', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final taskStore = TaskStore(executor: database);
    await taskStore.save([Task(id: 'linked-task', title: 'کار')]);
    final store = ProjectStore(executor: database);
    await store.save([
      ProjectPlan(id: 'linked', title: 'دارای کار', itemIds: const ['linked-task']),
      ProjectPlan(id: 'empty', title: 'خالی'),
    ]);

    await expectLater(
      store.upsert(const [], deleteProjectIds: const ['linked']),
      throwsA(isA<ProjectDeleteBlocked>()),
    );
    expect((await store.load()).map((project) => project.id).toSet(), {'linked', 'empty'});

    await store.upsert(const [], deleteProjectIds: const ['empty']);
    expect((await store.load()).map((project) => project.id).toSet(), {'linked'});
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
