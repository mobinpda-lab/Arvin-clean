import 'dart:io';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _seedCategory(NativeDatabase db, String id) async {
  await db.runInsert(
    '''INSERT INTO categories
       (id, name, legacy_name, storage_ordinal, is_archived, created_at, updated_at)
       VALUES (?, ?, NULL, 0, 0, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')''',
    <Object?>[id, id],
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Project Upsert preserves stable identity and unknown creation metadata', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final store = ProjectStore(executor: db);
    await store.save([
      ProjectPlan(
        id: 'stable-project',
        title: 'نسخه اول',
        legacyFields: const {'createdAt': '2026-01-02T03:04:05.000Z', 'customFlag': 7},
      ),
    ]);
    await store.save([ProjectPlan(id: 'stable-project', title: 'نسخه دوم')]);

    final rows = await db.runSelect('SELECT id, COUNT(*) AS count FROM projects GROUP BY id', const []);
    expect(rows, hasLength(1));
    expect(rows.single['id'], 'stable-project');
    final restored = (await store.load()).single;
    expect(restored.title, 'نسخه دوم');
    expect(restored.legacyFields['createdAt'], '2026-01-02T03:04:05.000Z');
    expect(restored.legacyFields['customFlag'], 7);
  });

  test('multiple Center and Category edges survive partial Project update', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final centers = CenterStore(executor: db);
    await centers.create(id: 'center-a', name: 'مرکز الف');
    await centers.create(id: 'center-b', name: 'مرکز ب');
    await _seedCategory(db, 'category-a');
    final store = ProjectStore(executor: db);

    await store.save([
      ProjectPlan(
        id: 'project-a',
        title: 'اول',
        centerIds: const ['center-a', 'center-b'],
        categoryIds: const ['category-a'],
      ),
    ]);
    await store.save([ProjectPlan(id: 'project-a', title: 'ویرایش جزئی')]);

    final project = (await store.load()).single;
    expect(project.centerIds, ['center-a', 'center-b']);
    expect(project.categoryIds, ['category-a']);
    expect(project.title, 'ویرایش جزئی');
  });

  test('one Center or Category edge can be removed without deleting Project', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final centers = CenterStore(executor: db);
    await centers.create(id: 'center-a', name: 'مرکز الف');
    await centers.create(id: 'center-b', name: 'مرکز ب');
    await _seedCategory(db, 'category-a');
    await _seedCategory(db, 'category-b');
    final store = ProjectStore(executor: db);
    await store.save([
      ProjectPlan(
        id: 'project-a',
        title: 'پروژه',
        centerIds: const ['center-a', 'center-b'],
        categoryIds: const ['category-a', 'category-b'],
      ),
    ]);

    final current = (await store.load()).single;
    await store.save([current.removeCenter('center-a').removeCategory('category-a')]);

    final restored = (await store.load()).single;
    expect(restored.centerIds, ['center-b']);
    expect(restored.categoryIds, ['category-b']);
    expect(await db.runSelect('SELECT id FROM projects', const []), hasLength(1));
  });

  test('Task historical references and project_items survive omitted membership update', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final tasks = TaskStore(executor: db);
    await tasks.save([Task(id: 'task-a', title: 'کار تاریخی')]);
    final store = ProjectStore(executor: db);
    await store.save([
      ProjectPlan(id: 'project-a', title: 'پروژه', itemIds: const ['task-a']),
    ]);

    await store.save([ProjectPlan(id: 'project-a', title: 'ویرایش بدون عضویت')]);

    expect((await store.load()).single.itemIds, ['task-a']);
    expect((await tasks.load()).single.id, 'task-a');
    expect(await db.runSelect(
      'SELECT task_id FROM project_items WHERE project_id = ?',
      const ['project-a'],
    ), hasLength(1));
  });

  test('controlled failure rolls back all Project and relationship writes', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final centers = CenterStore(executor: db);
    await centers.create(id: 'center-a', name: 'مرکز الف');
    final failing = ProjectStore(
      executor: db,
      failureInjector: (stage) {
        if (stage == 'after_project_project-a') throw StateError('controlled failure');
      },
    );

    await expectLater(
      failing.save([
        ProjectPlan(id: 'project-a', title: 'پروژه', centerIds: const ['center-a']),
      ]),
      throwsStateError,
    );
    expect(await db.runSelect('SELECT id FROM projects', const []), isEmpty);
    expect(await db.runSelect('SELECT project_id FROM center_projects', const []), isEmpty);
  });

  test('repeated Upsert is idempotent and does not duplicate relation rows', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final centers = CenterStore(executor: db);
    await centers.create(id: 'center-a', name: 'مرکز الف');
    final store = ProjectStore(executor: db);
    final project = ProjectPlan(id: 'project-a', title: 'پروژه', centerIds: const ['center-a']);
    await store.save([project]);
    await store.save([project]);
    expect(await db.runSelect('SELECT id FROM projects', const []), hasLength(1));
    expect(await db.runSelect('SELECT * FROM center_projects', const []), hasLength(1));
  });

  test('file-backed Project relationships survive database close and reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-project-store-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/arvin.sqlite');
    final firstDb = NativeDatabase(file);
    final centers = CenterStore(executor: firstDb);
    await centers.create(id: 'center-a', name: 'مرکز الف');
    final firstStore = ProjectStore(executor: firstDb);
    await firstStore.save([
      ProjectPlan(id: 'project-a', title: 'ماندگار', centerIds: const ['center-a']),
    ]);
    await firstDb.close();

    final reopenedDb = NativeDatabase(file);
    addTearDown(reopenedDb.close);
    final reopened = ProjectStore(executor: reopenedDb);
    final restored = (await reopened.load()).single;
    expect(restored.id, 'project-a');
    expect(restored.centerIds, ['center-a']);
  });

  test('Upsert preserves template_task_applications independently', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final tasks = TaskStore(executor: db);
    await tasks.save([Task(id: 'task-template', title: 'کار الگو')]);
    final store = ProjectStore(executor: db);
    await store.save([
      ProjectPlan(id: 'project-template', title: 'پروژه', itemIds: const ['task-template']),
    ]);
    await db.runInsert(
      '''INSERT INTO template_task_applications
         (template_task_id, project_id, task_id)
         VALUES ('template-task-a', 'project-template', 'task-template')''',
      const [],
    );

    await store.save([ProjectPlan(id: 'project-template', title: 'ویرایش')]);

    expect(await db.runSelect(
      'SELECT template_task_id FROM template_task_applications WHERE project_id = ?',
      const ['project-template'],
    ), hasLength(1));
  });

  test('rollback snapshot removes only Projects introduced by failed restore', () async {
    final db = NativeDatabase.memory();
    addTearDown(db.close);
    final tasks = TaskStore(executor: db);
    await tasks.save([Task(id: 'task-extra', title: 'کار محفوظ')]);
    final store = ProjectStore(executor: db);
    await store.save([ProjectPlan(id: 'before', title: 'قبل')]);
    final snapshot = await store.load();
    await store.save([
      ProjectPlan(id: 'extra', title: 'افزوده ناموفق', itemIds: const ['task-extra']),
    ]);

    await store.restoreSnapshot(snapshot);

    expect((await store.load()).map((project) => project.id), ['before']);
    expect((await tasks.load()).map((task) => task.id), ['task-extra']);
    expect(await db.runSelect(
      'SELECT * FROM project_items WHERE project_id = ?',
      const ['extra'],
    ), isEmpty);
  });
}
