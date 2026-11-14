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
    await db.runCustom('PRAGMA foreign_keys = OFF');
    await db.runInsert(
      '''INSERT INTO projects(id, storage_ordinal, name, color_value, is_archived, center_id)
         VALUES ('project-orphan', 2, 'پروژه با مرکز ناموجود', 0, 0, 'missing-center')''',
      const [],
    );
    await db.runCustom('PRAGMA foreign_keys = ON');
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

    final legacyCategoryId = categories.single['id'] as String;
    await db.runInsert(
      'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
      const ['center-b', 'project-a'],
    );
    await db.runInsert(
      'INSERT INTO project_categories(project_id, category_id) VALUES (?, ?)',
      <Object?>['project-a', legacyCategoryId],
    );
    await db.runInsert(
      'INSERT INTO project_categories(project_id, category_id) VALUES (?, ?)',
      <Object?>['project-b', legacyCategoryId],
    );
    await db.runInsert(
      '''INSERT INTO categories(id, name, storage_ordinal, is_archived, created_at, updated_at)
         VALUES ('category-second', 'مالی', 1, 0, ?, ?)''',
      [now, now],
    );
    await db.runInsert(
      'INSERT INTO project_categories(project_id, category_id) VALUES (?, ?)',
      const ['project-a', 'category-second'],
    );
    expect(
      (await db.runSelect(
        'SELECT COUNT(*) AS count FROM center_projects WHERE project_id = ?',
        const ['project-a'],
      )).single['count'],
      2,
      reason: 'One Project must be linkable to multiple Centers.',
    );
    expect(
      (await db.runSelect(
        'SELECT COUNT(*) AS count FROM center_projects WHERE center_id = ?',
        const ['center-b'],
      )).single['count'],
      2,
      reason: 'One Center must be linkable to multiple Projects.',
    );
    expect(
      (await db.runSelect(
        'SELECT COUNT(*) AS count FROM project_categories WHERE project_id = ?',
        const ['project-a'],
      )).single['count'],
      2,
      reason: 'One Project must contain multiple Categories.',
    );
    expect(
      (await db.runSelect(
        'SELECT COUNT(*) AS count FROM project_categories WHERE category_id = ?',
        <Object?>[legacyCategoryId],
      )).single['count'],
      2,
      reason: 'One Category must belong to multiple Projects.',
    );
    await expectLater(
      db.runInsert(
        'INSERT INTO center_projects(center_id, project_id) VALUES (?, ?)',
        const ['center-b', 'project-a'],
      ),
      throwsA(anything),
    );
    await db.runDelete(
      'DELETE FROM center_projects WHERE center_id = ? AND project_id = ?',
      const ['center-b', 'project-a'],
    );
    expect(
      await db.runSelect('SELECT id FROM centers WHERE id = ?', const ['center-b']),
      hasLength(1),
    );
    expect(
      await db.runSelect('SELECT id FROM projects WHERE id = ?', const ['project-a']),
      hasLength(1),
    );
    await db.runDelete(
      'DELETE FROM project_categories WHERE project_id = ? AND category_id = ?',
      const ['project-a', 'category-second'],
    );
    expect(
      await db.runSelect('SELECT id FROM categories WHERE id = ?', const ['category-second']),
      hasLength(1),
    );

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
      '''SELECT issue_code FROM rev10_hierarchy_migration_exceptions
         WHERE entity_type = 'task' AND entity_id = ?''',
      const ['task-ambiguous'],
    );
    expect(exceptions.map((r) => r['issue_code']), contains('TASK_MULTIPLE_LEGACY_PROJECTS'));
    final projectExceptions = await db.runSelect(
      '''SELECT issue_code FROM rev10_hierarchy_migration_exceptions
         WHERE entity_type = 'project' AND entity_id = 'project-orphan' ''',
      const [],
    );
    expect(projectExceptions.map((r) => r['issue_code']),
        contains('PROJECT_CENTER_REFERENCE_MISSING'));

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
    for (final table in ['center_projects', 'project_categories', 'tasks']) {
      expect(await db.runSelect('PRAGMA foreign_key_check($table)', const []), isEmpty);
    }
    expect(await db.runSelect("PRAGMA foreign_key_check('projects')", const []), hasLength(1),
        reason: 'The broken legacy projects.center_id value remains intact and is explicitly recorded.');
  });

  test('failed migration rolls back every created relation and added Task column', () async {
    await db.runInsert(
      '''INSERT INTO tasks(id, title, description, priority, archived, trashed, completed)
         VALUES ('rollback-task', 'کار آزمایشی', '', 'none', 0, 0, 0)''',
      const [],
    );
    // Inject a failure after the new tables and columns have been created but
    // while the migration is copying Task assignments. SQLite must roll back
    // the whole DDL+DML transaction, not leave a half-installed schema.
    await db.runCustom('''
      CREATE TRIGGER inject_rev10_migration_failure
      BEFORE UPDATE ON tasks
      BEGIN SELECT RAISE(ABORT, 'injected migration failure'); END
    ''');

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
