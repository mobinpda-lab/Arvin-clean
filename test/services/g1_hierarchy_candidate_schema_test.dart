import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/g1_hierarchy_candidate_schema.dart';

Future<void> _insertTask(
  NativeDatabase db,
  String id, {
  String? centerId,
  String? projectId,
  String? categoryId,
}) async {
  await db.runInsert(
    '''INSERT INTO tasks
       (id, title, description, priority, archived, trashed, completed,
        center_id, project_id, category_id)
       VALUES (?, ?, '', 'none', 0, 0, 0, ?, ?, ?)''',
    <Object?>[id, id, centerId, projectId, categoryId],
  );
}

Future<({Directory directory, File file, NativeDatabase db})> _openCandidate() async {
  final directory = await Directory.systemTemp.createTemp('arvin-g1-hierarchy-');
  final file = File(directory.path + '/candidate.sqlite');
  final db = NativeDatabase(file);
  await G1DriftSchema.install(db);

  final timestamp = DateTime.utc(2026).toIso8601String();
  for (final row in [
    ['center-a', 'مرکز الف'],
    ['center-b', 'مرکز ب'],
  ]) {
    await db.runInsert(
      'INSERT INTO centers(id, name, is_archived, created_at) VALUES (?, ?, 0, ?)',
      [row[0], row[1], timestamp],
    );
  }

  await db.runInsert(
    '''INSERT INTO projects
       (id, storage_ordinal, name, color_value, is_archived, center_id)
       VALUES ('legacy-null-center', 0, 'پروژه تاریخی', 0, 0, NULL)''',
    const [],
  );
  await db.runInsert(
    '''INSERT INTO projects
       (id, storage_ordinal, name, color_value, is_archived, center_id)
       VALUES ('project-a', 1, 'پروژه الف', 0, 0, 'center-a')''',
    const [],
  );
  await db.runInsert(
    '''INSERT INTO projects
       (id, storage_ordinal, name, color_value, is_archived, center_id)
       VALUES ('project-b', 2, 'پروژه ب', 0, 0, 'center-b')''',
    const [],
  );
  await db.runInsert(
    '''INSERT INTO tasks
       (id, storage_ordinal, title, description, priority, archived, trashed, completed, category)
       VALUES ('legacy-multi', 0, 'کار مبهم', '', 'none', 0, 0, 0, 'عملیات')''',
    const [],
  );
  await db.runInsert(
    'INSERT INTO project_items(project_id, task_id, ordinal) VALUES (?, ?, ?)',
    const ['project-a', 'legacy-multi', 0],
  );
  await db.runInsert(
    'INSERT INTO project_items(project_id, task_id, ordinal) VALUES (?, ?, ?)',
    const ['project-b', 'legacy-multi', 0],
  );
  await db.runInsert(
    'INSERT OR IGNORE INTO taxonomy_categories(name, created_at) VALUES (?, ?)',
    ['عملیات', timestamp],
  );

  await const G1HierarchyCandidateSchema().install(db);
  return (directory: directory, file: file, db: db);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('candidate adds hierarchy to the real G1 schema and records ambiguity', () async {
    final f = await _openCandidate();
    try {
      final columns = await f.db.runSelect("PRAGMA table_info('tasks')", const []);
      for (final name in ['center_id', 'project_id', 'category_id']) {
        final column = columns.singleWhere((row) => row['name'] == name);
        expect(column['notnull'], 0, reason: '$name must be nullable');
      }
      final projects = await f.db.runSelect('SELECT id, center_id FROM projects ORDER BY id', const []);
      expect(projects, hasLength(3));
      expect(projects.singleWhere((row) => row['id'] == 'legacy-null-center')['center_id'], isNull);

      final exceptions = await f.db.runSelect(
        'SELECT entity_type, entity_id, issue_code FROM arvin_hierarchy_migration_exceptions',
        const [],
      );
      expect(exceptions.any((r) => r['entity_id'] == 'legacy-null-center' && r['issue_code'] == 'PROJECT_CENTER_MISSING'), isTrue);
      expect(exceptions.any((r) => r['entity_id'] == 'legacy-multi' && r['issue_code'] == 'TASK_MULTIPLE_PROJECTS'), isTrue);
      expect(exceptions.any((r) => r['entity_id'] == 'عملیات' && r['issue_code'] == 'CATEGORY_PROJECT_OWNER_UNKNOWN'), isTrue);
      expect(await f.db.runSelect('SELECT * FROM project_items WHERE task_id = ?', const ['legacy-multi']), hasLength(2));
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('all-null and independent partial Task links are valid', () async {
    final f = await _openCandidate();
    try {
      final timestamp = DateTime.utc(2026).toIso8601String();
      await f.db.runInsert(
        '''INSERT INTO categories(id, project_id, name, storage_ordinal, is_archived, created_at, updated_at)
           VALUES ('category-a', 'project-a', 'عملیات', 0, 0, ?, ?)''',
        [timestamp, timestamp],
      );
      await _insertTask(f.db, 'task-null');
      await _insertTask(f.db, 'task-center', centerId: 'center-a');
      await _insertTask(f.db, 'task-project', projectId: 'project-a');
      await _insertTask(f.db, 'task-category', categoryId: 'category-a');
      await f.db.runInsert('INSERT INTO tags(id, name) VALUES (?, ?)', const ['tag-a', 'مهم']);
      await _insertTask(f.db, 'task-tag-only');
      await f.db.runInsert('INSERT INTO task_tags(task_id, tag_id, ordinal) VALUES (?, ?, ?)', const ['task-tag-only', 'tag-a', 0]);

      final rows = await f.db.runSelect(
        "SELECT id, center_id, project_id, category_id FROM tasks WHERE id LIKE 'task-%' ORDER BY id",
        const [],
      );
      expect(rows, hasLength(5));
      final noLinks = rows.singleWhere((r) => r['id'] == 'task-null');
      expect(noLinks['center_id'], isNull);
      expect(noLinks['project_id'], isNull);
      expect(noLinks['category_id'], isNull);
      expect(rows.singleWhere((r) => r['id'] == 'task-center')['center_id'], 'center-a');
      expect(rows.singleWhere((r) => r['id'] == 'task-project')['project_id'], 'project-a');
      expect(rows.singleWhere((r) => r['id'] == 'task-category')['category_id'], 'category-a');
      expect(await f.db.runSelect('SELECT * FROM task_tags WHERE task_id = ?', const ['task-tag-only']), hasLength(1));
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('SQL rejects inconsistent ownership combinations and unknown targets', () async {
    final f = await _openCandidate();
    try {
      final timestamp = DateTime.utc(2026).toIso8601String();
      await f.db.runInsert(
        '''INSERT INTO categories(id, project_id, name, created_at, updated_at)
           VALUES ('category-b', 'project-b', 'عملیات', ?, ?)''',
        [timestamp, timestamp],
      );
      await expectLater(_insertTask(f.db, 'bad-center-project', centerId: 'center-a', projectId: 'project-b'), throwsA(anything));
      await expectLater(_insertTask(f.db, 'bad-project-category', projectId: 'project-a', categoryId: 'category-b'), throwsA(anything));
      await expectLater(_insertTask(f.db, 'bad-center-category', centerId: 'center-a', categoryId: 'category-b'), throwsA(anything));
      await expectLater(_insertTask(f.db, 'bad-fk', projectId: 'missing-project'), throwsA(anything));
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('new Project and Category ownership is mandatory in SQLite', () async {
    final f = await _openCandidate();
    try {
      await expectLater(
        f.db.runInsert(
          '''INSERT INTO projects(id, storage_ordinal, name, color_value, is_archived, center_id)
             VALUES ('new-no-center', 3, 'بدون مرکز', 0, 0, NULL)''',
          const [],
        ),
        throwsA(anything),
      );
      final timestamp = DateTime.utc(2026).toIso8601String();
      await expectLater(
        f.db.runInsert(
          '''INSERT INTO categories(id, project_id, name, created_at, updated_at)
             VALUES ('category-no-project', NULL, 'بدون پروژه', ?, ?)''',
          [timestamp, timestamp],
        ),
        throwsA(anything),
      );
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('candidate installation is idempotent and survives five reopen cycles', () async {
    final f = await _openCandidate();
    var db = f.db;
    try {
      final before = await db.runSelect('SELECT exception_key FROM arvin_hierarchy_migration_exceptions ORDER BY exception_key', const []);
      for (var i = 0; i < 5; i++) {
        await db.close();
        db = NativeDatabase(f.file);
        await db.ensureOpen(G1DriftSchema());
        await db.runCustom('PRAGMA foreign_keys = ON');
        await const G1HierarchyCandidateSchema().install(db);
        final after = await db.runSelect('SELECT exception_key FROM arvin_hierarchy_migration_exceptions ORDER BY exception_key', const []);
        expect(after, before, reason: 'reopen cycle $i changed exception identities');
        expect(await db.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
        expect((await db.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
      }
    } finally {
      await db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('database restricts deletion of referenced Center and Category', () async {
    final f = await _openCandidate();
    try {
      final timestamp = DateTime.utc(2026).toIso8601String();
      await f.db.runInsert(
        '''INSERT INTO categories(id, project_id, name, created_at, updated_at)
           VALUES ('category-a', 'project-a', 'عملیات', ?, ?)''',
        [timestamp, timestamp],
      );
      await _insertTask(f.db, 'task-category-ref', categoryId: 'category-a');
      await expectLater(f.db.runDelete('DELETE FROM categories WHERE id = ?', const ['category-a']), throwsA(anything));
      await expectLater(f.db.runDelete('DELETE FROM centers WHERE id = ?', const ['center-a']), throwsA(anything));
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });
}
