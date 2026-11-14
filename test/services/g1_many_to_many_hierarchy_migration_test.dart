import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/g1_many_to_many_hierarchy_migration.dart';

void main() {
  late NativeDatabase db;

  setUp(() async {
    db = NativeDatabase.memory();
    await G1DriftSchema.install(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('v19 migration creates independent M2M junctions and preserves legacy evidence', () async {
    final now = DateTime.utc(2026, 11, 14).toIso8601String();
    for (final row in [
      ['center-a', 'مرکز الف'],
      ['center-b', 'مرکز ب'],
    ]) {
      await db.runInsert(
        'INSERT INTO centers(id, name, is_archived, created_at) VALUES (?, ?, 0, ?)',
        [row[0], row[1], now],
      );
    }
    await db.runInsert(
      '''INSERT INTO projects(id, storage_ordinal, name, color_value, is_archived, center_id)
         VALUES ('project-a', 0, 'پروژه الف', 0, 0, 'center-a')''',
      const [],
    );
    await db.runInsert(
      '''INSERT INTO projects(id, storage_ordinal, name, color_value, is_archived, center_id)
         VALUES ('project-b', 1, 'پروژه ب', 0, 0, 'center-b')''',
      const [],
    );
    await db.runInsert(
      '''INSERT INTO taxonomy_categories(name, created_at) VALUES ('عملیات', ?)''',
      [now],
    );
    await db.runInsert(
      '''INSERT INTO tasks(id, title, description, priority, archived, trashed, completed,
                           category, legacy_payload_json)
         VALUES ('task-one', 'کار یک', '', 'none', 0, 0, 0, 'عملیات',
                 '{"centerId":"center-a"}')''',
      const [],
    );
    await db.runInsert(
      '''INSERT INTO project_items(project_id, task_id, ordinal)
         VALUES ('project-a', 'task-one', 0)''',
      const [],
    );
    await db.runInsert(
      '''INSERT INTO tasks(id, title, description, priority, archived, trashed, completed)
         VALUES ('task-ambiguous', 'کار مبهم', '', 'none', 0, 0, 0)''',
      const [],
    );
    await db.runInsert(
      '''INSERT INTO project_items(project_id, task_id, ordinal)
         VALUES ('project-a', 'task-ambiguous', 0)''',
      const [],
    );
    await db.runInsert(
      '''INSERT INTO project_items(project_id, task_id, ordinal)
         VALUES ('project-b', 'task-ambiguous', 1)''',
      const [],
    );

    await const G1ManyToManyHierarchyMigration().migrate(db);

    final centerProjects = await db.runSelect(
      'SELECT center_id, project_id FROM center_projects ORDER BY center_id, project_id',
      const [],
    );
    expect(centerProjects, [
      {'center_id': 'center-a', 'project_id': 'project-a'},
      {'center_id': 'center-b', 'project_id': 'project-b'},
    ]);

    final categories = await db.runSelect('SELECT id, name FROM categories', const []);
    expect(categories, hasLength(1));
    expect(categories.single['name'], 'عملیات');
    expect(await db.runSelect('SELECT * FROM project_categories', const []), isEmpty,
        reason: 'A legacy Task category string is not proof of a Project↔Category edge.');

    final task = (await db.runSelect(
      'SELECT center_id, project_id, category_id FROM tasks WHERE id = ?',
      const ['task-one'],
    )).single;
    expect(task['center_id'], 'center-a');
    expect(task['project_id'], 'project-a');
    expect(task['category_id'], categories.single['id']);

    final ambiguous = (await db.runSelect(
      'SELECT project_id FROM tasks WHERE id = ?',
      const ['task-ambiguous'],
    )).single;
    expect(ambiguous['project_id'], isNull);
    final exceptions = await db.runSelect(
      'SELECT issue_code FROM rev10_hierarchy_migration_exceptions WHERE task_id = ?',
      const ['task-ambiguous'],
    );
    expect(exceptions.map((r) => r['issue_code']), contains('TASK_MULTIPLE_LEGACY_PROJECTS'));

    // The old relationship rows remain available as historical evidence.
    expect(
      await db.runSelect('SELECT project_id FROM project_items WHERE task_id = ?', const ['task-ambiguous']),
      hasLength(2),
    );
    expect(
      await db.runSelect(
        'SELECT value FROM arvin_storage_meta WHERE key = ?',
        const [G1ManyToManyHierarchyMigration.markerKey],
      ),
      [ {'value': '20'} ],
    );

    await const G1ManyToManyHierarchyMigration().migrate(db);
    expect(await db.runSelect('SELECT * FROM center_projects', const []), hasLength(2));
    expect(await db.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
  });

  test('failed migration rolls back every created relation and added Task column', () async {
    // The v19 installer leaves FK enforcement disabled during legacy repair.
    // An orphaned historical Center reference therefore models a corrupt
    // disposable fixture and forces the first junction-table copy to fail.
    await db.runInsert(
      '''INSERT INTO projects(id, storage_ordinal, name, color_value, is_archived, center_id)
         VALUES ('broken-project', 0, 'پروژه خراب', 0, 0, 'missing-center')''',
      const [],
    );

    await expectLater(
      const G1ManyToManyHierarchyMigration().migrate(db),
      throwsA(anything),
    );

    final tables = await db.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('center_projects', 'project_categories', 'categories')",
      const [],
    );
    expect(tables, isEmpty);
    final taskColumns = await db.runSelect("PRAGMA table_info('tasks')", const []);
    expect(taskColumns.any((row) => row['name'] == 'center_id'), isFalse);
    expect(taskColumns.any((row) => row['name'] == 'project_id'), isFalse);
    expect(taskColumns.any((row) => row['name'] == 'category_id'), isFalse);
    expect(
      await db.runSelect(
        'SELECT value FROM arvin_storage_meta WHERE key = ?',
        const [G1ManyToManyHierarchyMigration.markerKey],
      ),
      isEmpty,
    );
  });
}
