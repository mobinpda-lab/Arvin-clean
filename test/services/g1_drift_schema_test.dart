import 'dart:convert';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  test('creates the complete G1 relational schema', () async {
    await G1DriftSchema.install(database);

    final tables = await database.runSelect(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
      "ORDER BY name",
      const [],
    );

    final taskColumns = await database.runSelect(
      "PRAGMA table_info('tasks')",
      const [],
    );
    expect(
      taskColumns.map((row) => row['name']),
      contains('legacy_payload_json'),
    );

    final projectColumns = await database.runSelect(
      "PRAGMA table_info('projects')",
      const [],
    );
    expect(
      projectColumns.map((row) => row['name']),
      containsAll(<String>[
        'color_value',
        'is_archived',
        'legacy_payload_json',
      ]),
    );

    expect(
      tables.map((row) => row['name']),
      containsAll(<String>[
        'tasks',
        'follow_ups',
        'projects',
        'project_items',
        'tags',
        'task_tags',
        'checklist_items',
        'task_people',
      ]),
    );

    final foreignKeys = await database.runSelect(
      'PRAGMA foreign_keys',
      const [],
    );
    expect(foreignKeys.single['foreign_keys'], 1);
  });

  test('backfills Follow-up title waiting state and Person links from retained envelope', () async {
    await G1DriftSchema.install(database);
    await database.runInsert(
      '''INSERT INTO tasks (
        id, storage_ordinal, title, description, follow_up_enabled,
        priority, archived, trashed, completed, legacy_payload_json
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'task-backfill',
        0,
        'کار',
        '',
        1,
        'none',
        0,
        0,
        0,
        jsonEncode({
          'id': 'task-backfill',
          'followUps': [
            {
              'id': 'followup-backfill',
              'dateTime': '2026-10-15T10:00:00.000',
              'title': 'تماس با آنا',
              'waitingForResponse': true,
              'personIds': ['ana', 'reza'],
            },
          ],
        }),
      ],
    );
    await database.runInsert(
      '''INSERT INTO follow_ups (
        id, task_id, date_time, note, completed, waiting_for_response, ordinal
      ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'followup-backfill',
        'task-backfill',
        '2026-10-15T10:00:00.000',
        '',
        0,
        0,
        0,
      ],
    );

    await G1DriftSchema.migrateFollowUpMetadata(database);
    await G1DriftSchema.migrateFollowUpMetadata(database);

    final followUp = await database.runSelect(
      'SELECT title, waiting_for_response FROM follow_ups WHERE id = ?',
      <Object?>['followup-backfill'],
    );
    expect(followUp.single['title'], 'تماس با آنا');
    expect(followUp.single['waiting_for_response'], 1);

    final people = await database.runSelect(
      'SELECT person_id FROM follow_up_people WHERE follow_up_id = ? ORDER BY ordinal',
      <Object?>['followup-backfill'],
    );
    expect(people.map((row) => row['person_id']), ['ana', 'reza']);
  });

  test('schema installation is idempotent', () async {
    await G1DriftSchema.install(database);
    await G1DriftSchema.install(database);

    final taskTable = await database.runSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'tasks'",
      const [],
    );
    expect(taskTable, hasLength(1));
  });

  test('follow-up ordering and relationship duplicates fail closed', () async {
    await G1DriftSchema.install(database);

    await database.runCustom(
      "INSERT INTO tasks "
      "(id, title, description, follow_up_enabled, priority, archived, trashed, completed) "
      "VALUES ('task-1', 'عنوان', '', 1, 'none', 0, 0, 0)",
    );

    await database.runCustom(
      "INSERT INTO follow_ups "
      "(id, task_id, date_time, note, completed, ordinal) "
      "VALUES ('fu-1', 'task-1', '2026-09-22T10:00:00Z', 'اول', 0, 0)",
    );

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_ups "
        "(id, task_id, date_time, note, completed, ordinal) "
        "VALUES ('fu-2', 'task-1', '2026-09-22T11:00:00Z', 'تکراری', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );

    final ordered = await database.runSelect(
      'SELECT ordinal FROM follow_ups WHERE task_id = ? ORDER BY ordinal',
      <Object?>['task-1'],
    );
    expect(ordered.single['ordinal'], 0);
  });

  test('foreign-key references prevent orphan relationship rows', () async {
    await G1DriftSchema.install(database);

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_ups "
        "(id, task_id, date_time, note, completed, ordinal) "
        "VALUES ('fu-orphan', 'missing', '2026-09-22T10:00:00Z', '', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );
  });
  test('upgrades an existing pre-taxonomy schema without losing task data', () async {
    await database.ensureOpen(G1DriftSchema());
    await database.runCustom("CREATE TABLE tasks (id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL, updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL, follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL, reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL, trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL)");
    await database.runCustom("INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES ('legacy-task', 'قدیمی', '', 0, 'none', 0, 0, 0)");
    await G1DriftSchema.install(database);
    final taxonomyTables = await database.runSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'taxonomy_categories'", const []);
    expect(taxonomyTables, hasLength(1));
    final tasks = await database.runSelect("SELECT id, title FROM tasks WHERE id = ?", <Object?>['legacy-task']);
    expect(tasks, hasLength(1));
    expect(tasks.single['title'], 'قدیمی');
    final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
    expect(columns.map((row) => row['name']), contains('legacy_payload_json'));
  });
}
