import 'dart:io';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<({Directory directory, File file, NativeDatabase database})>
    _openCanonicalFixture() async {
  final directory = await Directory.systemTemp.createTemp('arvin-v20-m2m-');
  final file = File('${directory.path}/canonical.sqlite');
  final database = NativeDatabase(file);
  await G1DriftSchema.install(database);

  final timestamp = DateTime.utc(2026, 11, 14).toIso8601String();
  for (final row in [
    ['center-a', 'مرکز الف'],
    ['center-b', 'مرکز ب'],
  ]) {
    await database.runInsert(
      'INSERT INTO centers(id, name, is_archived, created_at) VALUES (?, ?, 0, ?)',
      [row[0], row[1], timestamp],
    );
  }
  for (final row in [
    ['project-a', 'پروژه الف'],
    ['project-b', 'پروژه ب'],
  ]) {
    await database.runInsert(
      'INSERT INTO projects(id, name) VALUES (?, ?)',
      row,
    );
  }
  for (final row in [
    ['category-a', 'عملیات'],
    ['category-b', 'مالی'],
  ]) {
    await database.runInsert(
      '''INSERT INTO categories
         (id, name, storage_ordinal, is_archived, created_at, updated_at)
         VALUES (?, ?, 0, 0, ?, ?)''',
      [row[0], row[1], timestamp, timestamp],
    );
  }

  // Canonical Many-to-Many edges: a Project can belong to multiple Centers,
  // and one Center can contain multiple Projects.
  await database.runInsert(
    'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
    const ['center-a', 'project-a'],
  );
  await database.runInsert(
    'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
    const ['center-b', 'project-a'],
  );
  await database.runInsert(
    'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
    const ['center-b', 'project-b'],
  );

  // Category membership is independent of Task text labels.
  for (final edge in [
    ['project-a', 'category-a'],
    ['project-a', 'category-b'],
    ['project-b', 'category-a'],
  ]) {
    await database.runInsert(
      'INSERT INTO project_categories(project_id, category_id) VALUES (?, ?)',
      edge,
    );
  }

  for (final row in [
    ['tag-a', 'مهم'],
    ['tag-b', 'فوری'],
  ]) {
    await database.runInsert('INSERT INTO tags(id, name) VALUES (?, ?)', row);
  }
  return (directory: directory, file: file, database: database);
}

Future<void> _insertTask(
  NativeDatabase database,
  String id, {
  String? centerId,
  String? projectId,
  String? categoryId,
}) async {
  await database.runInsert(
    '''INSERT INTO tasks
       (id, title, description, priority, archived, trashed, completed,
        center_id, project_id, category_id)
       VALUES (?, ?, '', 'none', 0, 0, 0, ?, ?, ?)''',
    <Object?>[id, id, centerId, projectId, categoryId],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('canonical v20 uses M2M junctions, not single-parent Category ownership', () async {
    final fixture = await _openCanonicalFixture();
    try {
      final categoryColumns = await fixture.database.runSelect(
        "PRAGMA table_info('categories')",
        const [],
      );
      expect(categoryColumns.map((row) => row['name']), isNot(contains('project_id')));
      expect(
        await fixture.database.runSelect('PRAGMA foreign_key_list(project_categories)', const []),
        hasLength(2),
      );
      expect(
        await fixture.database.runSelect('PRAGMA foreign_key_list(center_projects)', const []),
        hasLength(2),
      );
      expect(
        await fixture.database.runSelect(
          "SELECT value FROM arvin_storage_meta WHERE key = 'rev10_hierarchy_candidate_v1'",
          const [],
        ),
        isEmpty,
        reason: 'The superseded single-parent candidate must not be installed.',
      );
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('Center-Project and Project-Category cardinalities are genuinely many-to-many', () async {
    final fixture = await _openCanonicalFixture();
    try {
      expect(
        (await fixture.database.runSelect(
          'SELECT COUNT(*) AS count FROM center_projects WHERE project_id = ?',
          const ['project-a'],
        )).single['count'],
        2,
      );
      expect(
        (await fixture.database.runSelect(
          'SELECT COUNT(*) AS count FROM center_projects WHERE center_id = ?',
          const ['center-b'],
        )).single['count'],
        2,
      );
      expect(
        (await fixture.database.runSelect(
          'SELECT COUNT(*) AS count FROM project_categories WHERE project_id = ?',
          const ['project-a'],
        )).single['count'],
        2,
      );
      expect(
        (await fixture.database.runSelect(
          'SELECT COUNT(*) AS count FROM project_categories WHERE category_id = ?',
          const ['category-a'],
        )).single['count'],
        2,
      );
      await expectLater(
        fixture.database.runInsert(
          'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
          const ['center-a', 'project-a'],
        ),
        throwsA(anything),
      );
      await expectLater(
        fixture.database.runInsert(
          'INSERT INTO project_categories(project_id, category_id) VALUES (?, ?)',
          const ['project-a', 'category-a'],
        ),
        throwsA(anything),
      );
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('Task organization links remain independently optional and Tag remains M2M', () async {
    final fixture = await _openCanonicalFixture();
    try {
      await _insertTask(fixture.database, 'task-none');
      await _insertTask(fixture.database, 'task-center', centerId: 'center-a');
      await _insertTask(fixture.database, 'task-project', projectId: 'project-a');
      await _insertTask(fixture.database, 'task-category', categoryId: 'category-a');
      await _insertTask(fixture.database, 'task-tag-only');
      await _insertTask(
        fixture.database,
        'task-center-project',
        centerId: 'center-a',
        projectId: 'project-a',
      );
      await _insertTask(
        fixture.database,
        'task-project-category',
        projectId: 'project-a',
        categoryId: 'category-a',
      );
      await _insertTask(
        fixture.database,
        'task-center-category',
        centerId: 'center-a',
        categoryId: 'category-a',
      );
      await _insertTask(
        fixture.database,
        'task-full',
        centerId: 'center-a',
        projectId: 'project-a',
        categoryId: 'category-a',
      );
      for (final tag in ['tag-a', 'tag-b']) {
        await fixture.database.runInsert(
          'INSERT INTO task_tags(task_id, tag_id, ordinal) VALUES (?, ?, ?)',
          ['task-tag-only', tag, tag == 'tag-a' ? 0 : 1],
        );
      }

      final rows = await fixture.database.runSelect(
        '''SELECT id, center_id, project_id, category_id FROM tasks
           WHERE id IN ('task-none', 'task-center', 'task-project', 'task-category',
                         'task-tag-only', 'task-center-project', 'task-project-category',
                         'task-center-category', 'task-full')
           ORDER BY id''',
        const [],
      );
      expect(rows, hasLength(9));
      final none = rows.singleWhere((row) => row['id'] == 'task-none');
      expect(none['center_id'], isNull);
      expect(none['project_id'], isNull);
      expect(none['category_id'], isNull);
      expect(rows.singleWhere((row) => row['id'] == 'task-center')['center_id'], 'center-a');
      expect(rows.singleWhere((row) => row['id'] == 'task-project')['project_id'], 'project-a');
      expect(rows.singleWhere((row) => row['id'] == 'task-category')['category_id'], 'category-a');
      expect(
        await fixture.database.runSelect(
          'SELECT tag_id FROM task_tags WHERE task_id = ? ORDER BY tag_id',
          const ['task-tag-only'],
        ),
        [{'tag_id': 'tag-a'}, {'tag_id': 'tag-b'}],
      );
      expect(await fixture.database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('canonical M2M links and Task direct assignments survive ordinary database reopen', () async {
    final fixture = await _openCanonicalFixture();
    final file = fixture.file;
    await _insertTask(
      fixture.database,
      'task-reopen',
      centerId: 'center-b',
      projectId: 'project-a',
      categoryId: 'category-a',
    );
    await fixture.database.runInsert(
      'INSERT INTO task_tags(task_id, tag_id, ordinal) VALUES (?, ?, ?)',
      const ['task-reopen', 'tag-b', 0],
    );
    await fixture.database.close();

    final reopened = NativeDatabase(file);
    try {
      await G1DriftSchema.install(reopened);
      expect(
        await reopened.runSelect('SELECT * FROM center_projects ORDER BY center_id, project_id', const []),
        hasLength(3),
      );
      expect(
        await reopened.runSelect('SELECT * FROM project_categories ORDER BY project_id, category_id', const []),
        hasLength(3),
      );
      expect(
        await reopened.runSelect(
          'SELECT center_id, project_id, category_id FROM tasks WHERE id = ?',
          const ['task-reopen'],
        ),
        [{'center_id': 'center-b', 'project_id': 'project-a', 'category_id': 'category-a'}],
      );
      expect(
        await reopened.runSelect('SELECT tag_id FROM task_tags WHERE task_id = ?', const ['task-reopen']),
        [{'tag_id': 'tag-b'}],
      );
      expect(await reopened.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
    } finally {
      await reopened.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('relationship deletion preserves entities and invalid references are rejected', () async {
    final fixture = await _openCanonicalFixture();
    try {
      await fixture.database.runDelete(
        'DELETE FROM center_projects WHERE center_id = ? AND project_id = ?',
        const ['center-a', 'project-a'],
      );
      expect(
        await fixture.database.runSelect('SELECT id FROM centers WHERE id = ?', const ['center-a']),
        hasLength(1),
      );
      expect(
        await fixture.database.runSelect('SELECT id FROM projects WHERE id = ?', const ['project-a']),
        hasLength(1),
      );
      await expectLater(
        fixture.database.runInsert(
          'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
          const ['missing-center', 'project-a'],
        ),
        throwsA(anything),
      );
      await expectLater(
        fixture.database.runInsert(
          'INSERT INTO project_categories(project_id, category_id) VALUES (?, ?)',
          const ['project-a', 'missing-category'],
        ),
        throwsA(anything),
      );
      await expectLater(
        _insertTask(
          fixture.database,
          'task-invalid-pair',
          centerId: 'center-a',
          projectId: 'project-b',
        ),
        throwsA(anything),
      );
      expect(await fixture.database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('Task insert and update triggers enforce valid Many-to-Many paths', () async {
    final fixture = await _openCanonicalFixture();
    try {
      await _insertTask(
        fixture.database,
        'task-valid-m2m-path',
        centerId: 'center-a',
        projectId: 'project-a',
        categoryId: 'category-b',
      );
      await expectLater(
        _insertTask(
          fixture.database,
          'task-invalid-center-project',
          centerId: 'center-a',
          projectId: 'project-b',
        ),
        throwsA(anything),
      );
      await expectLater(
        _insertTask(
          fixture.database,
          'task-invalid-project-category',
          projectId: 'project-b',
          categoryId: 'category-b',
        ),
        throwsA(anything),
      );

      final timestamp = DateTime.utc(2026, 11, 14).toIso8601String();
      await fixture.database.runInsert(
        '''INSERT INTO categories
           (id, name, storage_ordinal, is_archived, created_at, updated_at)
           VALUES (?, ?, 2, 0, ?, ?)''',
        ['category-unlinked', 'بدون پیوند', timestamp, timestamp],
      );
      await expectLater(
        _insertTask(
          fixture.database,
          'task-invalid-center-category-path',
          centerId: 'center-a',
          categoryId: 'category-unlinked',
        ),
        throwsA(anything),
      );

      await expectLater(
        fixture.database.runUpdate(
          'UPDATE tasks SET project_id = ? WHERE id = ?',
          const ['project-b', 'task-valid-m2m-path'],
        ),
        throwsA(anything),
      );
      await expectLater(
        fixture.database.runUpdate(
          'UPDATE tasks SET category_id = ? WHERE id = ?',
          const ['category-unlinked', 'task-valid-m2m-path'],
        ),
        throwsA(anything),
      );
      await _insertTask(fixture.database, 'task-update-path');
      await expectLater(
        fixture.database.runUpdate(
          'UPDATE tasks SET center_id = ?, category_id = ? WHERE id = ?',
          const ['center-a', 'category-unlinked', 'task-update-path'],
        ),
        throwsA(anything),
      );
      expect(
        await fixture.database.runSelect('PRAGMA foreign_key_check', const []),
        isEmpty,
      );
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('endpoint deletion is restricted while canonical M2M edges exist', () async {
    final fixture = await _openCanonicalFixture();
    try {
      await expectLater(
        fixture.database.runDelete(
          'DELETE FROM centers WHERE id = ?',
          const ['center-a'],
        ),
        throwsA(anything),
      );
      await expectLater(
        fixture.database.runDelete(
          'DELETE FROM projects WHERE id = ?',
          const ['project-a'],
        ),
        throwsA(anything),
      );
      await expectLater(
        fixture.database.runDelete(
          'DELETE FROM categories WHERE id = ?',
          const ['category-a'],
        ),
        throwsA(anything),
      );
      await fixture.database.runDelete(
        'DELETE FROM project_categories WHERE category_id = ?',
        const ['category-a'],
      );
      await _insertTask(
        fixture.database,
        'task-direct-category-reference',
        categoryId: 'category-a',
      );
      await expectLater(
        fixture.database.runDelete(
          'DELETE FROM categories WHERE id = ?',
          const ['category-a'],
        ),
        throwsA(anything),
      );
      expect(
        await fixture.database.runSelect('PRAGMA foreign_key_check', const []),
        isEmpty,
      );
      expect(
        await fixture.database.runSelect('SELECT id FROM centers WHERE id = ?', const ['center-a']),
        hasLength(1),
      );
      expect(
        await fixture.database.runSelect('SELECT id FROM projects WHERE id = ?', const ['project-a']),
        hasLength(1),
      );
      expect(
        await fixture.database.runSelect('SELECT id FROM categories WHERE id = ?', const ['category-a']),
        hasLength(1),
      );
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('canonical M2M indexes and Task hierarchy guard triggers are installed', () async {
    final fixture = await _openCanonicalFixture();
    try {
      final objects = (await fixture.database.runSelect(
        "SELECT name, type FROM sqlite_master WHERE type IN ('index', 'trigger')",
        const [],
      )).map((row) => row['type'].toString() + ':' + row['name'].toString()).toSet();

      expect(objects, contains('index:idx_center_projects_project_center'));
      expect(objects, contains('index:idx_project_categories_category_project'));
      expect(objects, contains('index:idx_tasks_center_id'));
      expect(objects, contains('index:idx_tasks_project_id'));
      expect(objects, contains('index:idx_tasks_category_id'));
      expect(objects, contains('trigger:rev10_m2m_task_hierarchy_insert'));
      expect(objects, contains('trigger:rev10_m2m_task_hierarchy_update'));
    } finally {
      await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });

  test('M2M relations, Task, Tag, Person, Follow-up and Reminder survive independent physical restore', () async {
    final fixture = await _openCanonicalFixture();
    final backupFile = File('${fixture.directory.path}/restored.sqlite');
    var sourceClosed = false;
    try {
      await _insertTask(
        fixture.database,
        'task-backup',
        centerId: 'center-b',
        projectId: 'project-a',
        categoryId: 'category-a',
      );
      await fixture.database.runInsert(
        'INSERT INTO task_tags(task_id, tag_id, ordinal) VALUES (?, ?, ?)',
        const ['task-backup', 'tag-a', 0],
      );
      final timestamp = DateTime.utc(2026, 11, 14).toIso8601String();
      await fixture.database.runInsert(
        'INSERT INTO persons(id, name, created_at, updated_at) VALUES (?, ?, ?, ?)',
        ['person-backup', 'شخص پشتیبان', timestamp, timestamp],
      );
      await fixture.database.runInsert(
        'INSERT INTO person_directory(person_id) VALUES (?)',
        const ['person-backup'],
      );
      await fixture.database.runInsert(
        'INSERT INTO task_persons(task_id, person_id, ordinal) VALUES (?, ?, ?)',
        const ['task-backup', 'person-backup', 0],
      );
      await fixture.database.runInsert(
        '''INSERT INTO follow_up_records
           (id, task_id, completed_at, title, note, result, completed, waiting_for_response, ordinal)
           VALUES (?, ?, ?, ?, ?, ?, 0, 1, 0)''',
        const ['followup-backup', 'task-backup', '2026-11-13T10:00:00.000',
          'پیگیری تاریخی', 'یادداشت', null],
      );
      await fixture.database.runInsert(
        'INSERT INTO follow_up_record_people(follow_up_id, person_id, ordinal) VALUES (?, ?, ?)',
        const ['followup-backup', 'person-backup', 0],
      );
      await fixture.database.runInsert(
        '''INSERT INTO task_reminders
           (id, task_id, title, remind_at, is_all_day, sequence, is_enabled)
           VALUES (?, ?, ?, ?, 0, 0, 1)''',
        const ['reminder-backup', 'task-backup', 'یادآور', '2026-11-15T09:00:00.000'],
      );

      await fixture.database.close();
      sourceClosed = true;
      await fixture.file.copy(backupFile.path);
      expect(await fixture.file.exists(), isTrue);
      expect(await backupFile.exists(), isTrue);
      expect(fixture.file.path == backupFile.path, isFalse);

      final restored = NativeDatabase(backupFile);
      try {
        await G1DriftSchema.install(restored);
        expect((await restored.runSelect('PRAGMA user_version', const [])).single.values.first, 20);
        expect(await restored.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
        expect((await restored.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
        expect(await restored.runSelect('SELECT * FROM center_projects ORDER BY center_id, project_id', const []),
          hasLength(3));
        expect(await restored.runSelect('SELECT * FROM project_categories ORDER BY project_id, category_id', const []),
          hasLength(3));
        expect(await restored.runSelect('SELECT id FROM tasks WHERE id = ?', const ['task-backup']), hasLength(1));
        expect(await restored.runSelect('SELECT * FROM task_tags WHERE task_id = ?', const ['task-backup']), hasLength(1));
        expect(await restored.runSelect('SELECT id, name FROM persons WHERE id = ?', const ['person-backup']),
          [{'id': 'person-backup', 'name': 'شخص پشتیبان'}]);
        expect(await restored.runSelect('SELECT id FROM follow_up_records WHERE id = ?', const ['followup-backup']),
          hasLength(1));
        expect(await restored.runSelect('SELECT id FROM task_reminders WHERE id = ?', const ['reminder-backup']),
          hasLength(1));
      } finally {
        await restored.close();
      }
    } finally {
      if (!sourceClosed) await fixture.database.close();
      await fixture.directory.delete(recursive: true);
    }
  });
}
