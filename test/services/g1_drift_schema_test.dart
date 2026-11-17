import 'dart:io';

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

    final followUpColumns = await database.runSelect("PRAGMA table_info('follow_ups')", const []);
    expect(followUpColumns.map((row) => row['name']), contains('extension_json'));

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
    await database.runCustom("INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES ('legacy-task', 'قدیمی', '', 0, 'none', 0, 0, 1)");
    await G1DriftSchema.install(database);
    final taxonomyTables = await database.runSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'taxonomy_categories'", const []);
    expect(taxonomyTables, hasLength(1));
    final tasks = await database.runSelect("SELECT id, title FROM tasks WHERE id = ?", <Object?>['legacy-task']);
    expect(tasks, hasLength(1));
    expect(tasks.single['title'], 'قدیمی');
    final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
    expect(columns.map((row) => row['name']), containsAll(<String>['legacy_payload_json', 'completed_at']));
    final migratedTask = await database.runSelect('SELECT completed, completed_at FROM tasks WHERE id = ?', <Object?>['legacy-task']);
    expect(migratedTask.single['completed'], 1);
    // A pre-timestamp completed task stays unknown; migration must not invent a time.
    expect(migratedTask.single['completed_at'], isNull);
  });

  test('file-backed v7 database preserves legacy identities and payloads after reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-v7-file-');
    final file = File('${directory.path}/arvin-v7.sqlite');
    NativeDatabase? fileDatabase;
    try {
      fileDatabase = NativeDatabase(file);
      await G1DriftSchema.install(fileDatabase);
      await fileDatabase.runCustom(
        '''INSERT INTO tasks (
          id, storage_ordinal, title, description, follow_up_enabled,
          priority, archived, trashed, completed, legacy_payload_json
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          'task-v7-001', 7, 'کار تاریخی', 'شرح تاریخی', 1,
          'high', 0, 0, 1,
          '{"unknownTaskField":{"source":"v7","revision":4}}',
        ],
      );
      await fileDatabase.runCustom(
        '''INSERT INTO projects (id, name, legacy_payload_json)
           VALUES (?, ?, ?)''',
        <Object?>[
          'project-v7-001', 'پروژه تاریخی',
          '{"unknownProjectField":"preserve-me"}',
        ],
      );
      await fileDatabase.runCustom(
        '''INSERT INTO project_items (project_id, task_id, ordinal)
           VALUES (?, ?, ?)''',
        <Object?>['project-v7-001', 'task-v7-001', 3],
      );
      await fileDatabase.runCustom(
        '''INSERT INTO follow_ups (
          id, task_id, date_time, note, completed, ordinal
        ) VALUES (?, ?, ?, ?, ?, ?)''',
        <Object?>[
          'follow-up-v7-001', 'task-v7-001',
          '2026-10-01T09:30:00.000Z', 'پیگیری تاریخی', 0, 2,
        ],
      );
      await fileDatabase.runCustom(
        'INSERT INTO tags (id, name) VALUES (?, ?)',
        <Object?>['tag-v7-001', 'برچسب تاریخی'],
      );
      await fileDatabase.runCustom(
        'INSERT INTO task_tags (task_id, tag_id, ordinal) VALUES (?, ?, ?)',
        <Object?>['task-v7-001', 'tag-v7-001', 1],
      );
      await fileDatabase.close();
      fileDatabase = null;

      fileDatabase = NativeDatabase(file);
      await G1DriftSchema.install(fileDatabase);
      await G1DriftSchema.install(fileDatabase);

      final taskRows = await fileDatabase.runSelect(
        'SELECT id, title, storage_ordinal, legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>['task-v7-001'],
      );
      expect(taskRows, hasLength(1));
      expect(taskRows.single['title'], 'کار تاریخی');
      expect(taskRows.single['storage_ordinal'], 7);
      expect(
        taskRows.single['legacy_payload_json'],
        '{"unknownTaskField":{"source":"v7","revision":4}}',
      );

      final projectRows = await fileDatabase.runSelect(
        'SELECT id, legacy_payload_json FROM projects WHERE id = ?',
        const <Object?>['project-v7-001'],
      );
      expect(projectRows, hasLength(1));
      expect(projectRows.single['legacy_payload_json'],
          '{"unknownProjectField":"preserve-me"}');

      final membershipRows = await fileDatabase.runSelect(
        'SELECT ordinal FROM project_items WHERE project_id = ? AND task_id = ?',
        const <Object?>['project-v7-001', 'task-v7-001'],
      );
      expect(membershipRows, hasLength(1));
      expect(membershipRows.single['ordinal'], 3);

      final followUpRows = await fileDatabase.runSelect(
        'SELECT id, note, ordinal FROM follow_ups WHERE task_id = ?',
        const <Object?>['task-v7-001'],
      );
      expect(followUpRows, hasLength(1));
      expect(followUpRows.single['id'], 'follow-up-v7-001');
      expect(followUpRows.single['note'], 'پیگیری تاریخی');
      expect(followUpRows.single['ordinal'], 2);

      final tagRows = await fileDatabase.runSelect(
        '''SELECT tags.id, tags.name, task_tags.ordinal
           FROM tags JOIN task_tags ON task_tags.tag_id = tags.id
           WHERE task_tags.task_id = ?''',
        const <Object?>['task-v7-001'],
      );
      expect(tagRows, hasLength(1));
      expect(tagRows.single['id'], 'tag-v7-001');
      expect(tagRows.single['name'], 'برچسب تاریخی');
      expect(tagRows.single['ordinal'], 1);
    } finally {
      await fileDatabase?.close();
      await directory.delete(recursive: true);
    }
  });

}
