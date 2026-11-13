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

  // Existing normalized relations must remain intact during schema expansion.
  await db.runInsert(
    '''INSERT INTO tasks
       (id, storage_ordinal, title, description, priority, archived, trashed, completed)
       VALUES ('task-history', 1, 'کار تاریخی', '', 'none', 0, 0, 0)''',
    const [],
  );
  await db.runInsert('INSERT INTO tags(id, name) VALUES (?, ?)', const ['tag-history', 'مهم']);
  await db.runInsert('INSERT INTO task_tags(task_id, tag_id, ordinal) VALUES (?, ?, ?)', const ['task-history', 'tag-history', 0]);
  await db.runInsert('INSERT INTO persons(id, name, created_at, updated_at) VALUES (?, ?, ?, ?)', ['person-history', 'شخص تاریخی', timestamp, timestamp]);
  await db.runInsert('INSERT INTO person_directory(person_id) VALUES (?)', const ['person-history']);
  await db.runInsert('INSERT INTO task_persons(task_id, person_id, ordinal) VALUES (?, ?, ?)', const ['task-history', 'person-history', 0]);
  await db.runInsert(
    '''INSERT INTO follow_up_records
       (id, task_id, completed_at, title, note, result, completed, waiting_for_response, ordinal)
       VALUES ('followup-history', 'task-history', ?, 'پیگیری', 'یادداشت', NULL, 0, 1, 0)''',
    [timestamp],
  );
  await db.runInsert('INSERT INTO follow_up_record_people(follow_up_id, person_id, ordinal) VALUES (?, ?, ?)', const ['followup-history', 'person-history', 0]);

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
        "SELECT id, center_id, project_id, category_id FROM tasks WHERE id IN ('task-null', 'task-center', 'task-project', 'task-category', 'task-tag-only') ORDER BY id",
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

  test('Tag, Person and Follow-up identities survive candidate migration', () async {
    final f = await _openCandidate();
    try {
      expect(await f.db.runSelect('SELECT id FROM tags WHERE id = ?', const ['tag-history']), hasLength(1));
      expect(await f.db.runSelect('SELECT task_id, tag_id FROM task_tags WHERE task_id = ?', const ['task-history']), hasLength(1));
      expect(await f.db.runSelect('SELECT id, name FROM persons WHERE id = ?', const ['person-history']), hasLength(1));
      expect(await f.db.runSelect('SELECT person_id FROM person_directory WHERE person_id = ?', const ['person-history']), hasLength(1));
      expect(await f.db.runSelect('SELECT person_id FROM task_persons WHERE task_id = ?', const ['task-history']), hasLength(1));
      expect(await f.db.runSelect('SELECT id FROM follow_up_records WHERE id = ?', const ['followup-history']), hasLength(1));
      expect(await f.db.runSelect('SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?', const ['followup-history']), hasLength(1));
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('consistent partial and full hierarchy links are valid and can be cleared', () async {
    final f = await _openCandidate();
    try {
      final timestamp = DateTime.utc(2026).toIso8601String();
      await f.db.runInsert(
        '''INSERT INTO categories(id, project_id, name, created_at, updated_at)
           VALUES ('category-a', 'project-a', 'عملیات', ?, ?)''',
        [timestamp, timestamp],
      );
      await _insertTask(f.db, 'task-center-project', centerId: 'center-a', projectId: 'project-a');
      await _insertTask(f.db, 'task-project-category', projectId: 'project-a', categoryId: 'category-a');
      await _insertTask(f.db, 'task-full-chain', centerId: 'center-a', projectId: 'project-a', categoryId: 'category-a');
      await f.db.runUpdate('UPDATE tasks SET center_id = NULL, project_id = NULL, category_id = NULL WHERE id = ?', const ['task-full-chain']);
      final cleared = (await f.db.runSelect('SELECT center_id, project_id, category_id FROM tasks WHERE id = ?', const ['task-full-chain'])).single;
      expect(cleared['center_id'], isNull);
      expect(cleared['project_id'], isNull);
      expect(cleared['category_id'], isNull);
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('Task UPDATE trigger rejects an invalid parent combination', () async {
    final f = await _openCandidate();
    try {
      await _insertTask(f.db, 'task-valid', centerId: 'center-a', projectId: 'project-a');
      await expectLater(
        f.db.runUpdate('UPDATE tasks SET project_id = ? WHERE id = ?', const ['project-b', 'task-valid']),
        throwsA(anything),
      );
      final row = (await f.db.runSelect('SELECT center_id, project_id FROM tasks WHERE id = ?', const ['task-valid'])).single;
      expect(row['center_id'], 'center-a');
      expect(row['project_id'], 'project-a');
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('Project and Category parent changes are blocked while dependents exist', () async {
    final f = await _openCandidate();
    try {
      final timestamp = DateTime.utc(2026).toIso8601String();
      await f.db.runInsert(
        '''INSERT INTO categories(id, project_id, name, created_at, updated_at)
           VALUES ('category-a', 'project-a', 'عملیات', ?, ?)''',
        [timestamp, timestamp],
      );
      await _insertTask(f.db, 'task-category-ref', categoryId: 'category-a');
      await expectLater(
        f.db.runUpdate('UPDATE projects SET center_id = ? WHERE id = ?', const ['center-b', 'project-a']),
        throwsA(anything),
      );
      await expectLater(
        f.db.runUpdate('UPDATE categories SET project_id = ? WHERE id = ?', const ['project-b', 'category-a']),
        throwsA(anything),
      );
    } finally {
      await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('injected migration interruption rolls back and a retry recovers', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-g1-hierarchy-rollback-');
    final file = File(directory.path + '/rollback.sqlite');
    final db = NativeDatabase(file);
    try {
      await G1DriftSchema.install(db);
      await db.runCustom('''
        CREATE TRIGGER inject_rev10_failure
        BEFORE INSERT ON arvin_storage_meta
        WHEN NEW.key = 'rev10_hierarchy_candidate_v1'
        BEGIN SELECT RAISE(ABORT, 'injected migration interruption'); END
      ''');
      await expectLater(const G1HierarchyCandidateSchema().install(db), throwsA(anything));
      expect(await db.runSelect("SELECT name FROM sqlite_master WHERE type='table' AND name='categories'", const []), isEmpty);
      final columns = await db.runSelect("PRAGMA table_info('tasks')", const []);
      expect(columns.any((row) => row['name'] == 'center_id'), isFalse);
      expect(await db.runSelect("SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'rev10_%'", const []), isEmpty);
      await db.runCustom('DROP TRIGGER inject_rev10_failure');
      await const G1HierarchyCandidateSchema().install(db);
      expect(await db.runSelect("SELECT name FROM sqlite_master WHERE type='table' AND name='categories'", const []), hasLength(1));
      expect(await db.runSelect('SELECT value FROM arvin_storage_meta WHERE key = ?', const ['rev10_hierarchy_candidate_v1']), hasLength(1));
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });

  test('physical SQLite backup restores into an independent file', () async {
    final f = await _openCandidate();
    final backup = File(f.directory.path + '/restored.sqlite');
    try {
      await _insertTask(f.db, 'task-backup', centerId: 'center-a');
      await f.db.close();
      await f.file.copy(backup.path);
      final restored = NativeDatabase(backup);
      await restored.ensureOpen(G1DriftSchema());
      await restored.runCustom('PRAGMA foreign_keys = ON');
      await const G1HierarchyCandidateSchema().install(restored);
      expect(await restored.runSelect('SELECT id FROM tasks WHERE id = ?', const ['task-backup']), hasLength(1));
      expect(await restored.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
      expect((await restored.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
      await restored.close();
    } finally {
      if (f.db.isOpen) await f.db.close();
      await f.directory.delete(recursive: true);
    }
  });

  test('candidate indexes and ownership triggers are installed', () async {
    final f = await _openCandidate();
    try {
      final indexes = await f.db.runSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'", const []);
      final triggers = await f.db.runSelect("SELECT name FROM sqlite_master WHERE type = 'trigger' AND name LIKE 'rev10_%'", const []);
      for (final name in ['idx_projects_center_archive_order', 'idx_categories_project_archive_order', 'idx_tasks_center_id', 'idx_tasks_project_id', 'idx_tasks_category_id', 'idx_task_tags_tag_task']) {
        expect(indexes.any((row) => row['name'] == name), isTrue);
      }
      expect(triggers.length, greaterThanOrEqualTo(6));
    } finally {
      await f.db.close();
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
