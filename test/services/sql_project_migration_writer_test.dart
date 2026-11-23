import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/sql_project_migration_writer.dart';
import 'package:arvin/services/g1_drift_schema.dart';

void main() {
  late NativeDatabase database;

  setUp(() async {
    database = NativeDatabase.memory();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await database.close();
  });

  test('migrates project metadata and canonical Task-id membership', () async {
    final raw = jsonEncode([
      {
        'id': 'project-1',
        'title': 'فروش',
        'colorValue': 0xFF123456,
        'isArchived': true,
        'futureField': {'keep': true},
        'itemIds': ['task-1', 'task-2'],
      },
    ]);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.projects', raw);

    await G1DriftSchema.install(database);

    await database.runInsert(
      'INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      const ['task-1', 'کار اول', '', 0, 'none', 0, 0, 0],
    );
    await database.runInsert(
      'INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      const ['task-2', 'کار دوم', '', 0, 'none', 0, 0, 0],
    );

    final report = await const SqlProjectMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    expect(report.sourceCount, 1);
    expect(report.insertedCount, 1);
    expect(report.sqlProjectCount, 1);

    final project = (await database.runSelect(
      'SELECT id, name, color_value, is_archived, legacy_payload_json FROM projects WHERE id = ?',
      const ['project-1'],
    )).single;
    expect(project['name'], 'فروش');
    expect(project['color_value'], 0xFF123456);
    expect(project['is_archived'], 1);
    final envelope = jsonDecode(project['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(envelope['futureField'], {'keep': true});

    final memberships = await database.runSelect(
      'SELECT task_id, ordinal FROM project_items WHERE project_id = ? ORDER BY ordinal',
      const ['project-1'],
    );
    expect(memberships.map((row) => row['task_id']), ['task-1', 'task-2']);
    expect(memberships.map((row) => row['ordinal']), [0, 1]);
  });

  test('re-running the same project migration is idempotent', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'arvin.projects',
      '[{"id":"project-1","title":"یک پروژه","itemIds":[]}]',
    );

    final writer = const SqlProjectMigrationWriter();
    final first = await writer.migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );
    final second = await writer.migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    expect(first.insertedCount, 1);
    expect(second.insertedCount, 0);
    expect(second.skippedExistingCount, 1);

    final count = await database.runSelect(
      'SELECT COUNT(*) AS count FROM projects',
      const [],
    );
    expect(count.single['count'], 1);
  });

  test('rolls back project and membership rows when a referenced Task is missing',
      () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'arvin.projects',
      '[{"id":"project-1","title":"فروش","itemIds":["missing-task"]}]',
    );

    await expectLater(
      const SqlProjectMigrationWriter().migrateFromPreferences(
        executor: database,
        preferences: preferences,
      ),
      throwsA(anything),
    );

    final projects = await database.runSelect(
      'SELECT COUNT(*) AS count FROM projects',
      const [],
    );
    final memberships = await database.runSelect(
      'SELECT COUNT(*) AS count FROM project_items',
      const [],
    );
    expect(projects.single['count'], 0);
    expect(memberships.single['count'], 0);
  });
}
