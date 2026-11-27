import 'dart:convert';
import 'dart:io';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _LegacyV7Schema implements QueryExecutorUser {
  const _LegacyV7Schema();

  @override
  int get schemaVersion => 7;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

Future<void> _createActualV7File(NativeDatabase database) async {
  await database.ensureOpen(const _LegacyV7Schema());
  await database.runCustom('PRAGMA foreign_keys = ON');

  const statements = <String>[
    '''CREATE TABLE tasks (
      id TEXT NOT NULL PRIMARY KEY,
      storage_ordinal INTEGER NOT NULL DEFAULT 0,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      created_at TEXT NULL,
      updated_at TEXT NULL,
      due_date TEXT NULL,
      follow_up_enabled INTEGER NOT NULL,
      follow_up_date TEXT NULL,
      category TEXT NULL,
      notebook_kind TEXT NULL,
      reminder_date TEXT NULL,
      priority TEXT NOT NULL,
      archived INTEGER NOT NULL,
      trashed INTEGER NOT NULL,
      completed INTEGER NOT NULL,
      completed_at TEXT NULL,
      recurrence_json TEXT NULL,
      legacy_payload_json TEXT NULL
    )''',
    '''CREATE TABLE follow_ups (
      id TEXT NOT NULL PRIMARY KEY,
      task_id TEXT NOT NULL REFERENCES tasks(id),
      date_time TEXT NOT NULL,
      title TEXT NULL,
      note TEXT NOT NULL,
      result TEXT NULL,
      reminder_date TEXT NULL,
      next_follow_up TEXT NULL,
      completed INTEGER NOT NULL,
      waiting_for_response INTEGER NOT NULL DEFAULT 0,
      ordinal INTEGER NOT NULL,
      UNIQUE (task_id, ordinal)
    )''',
    '''CREATE TABLE projects (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      color_value INTEGER NOT NULL DEFAULT 4283059371,
      is_archived INTEGER NOT NULL DEFAULT 0,
      legacy_payload_json TEXT NULL
    )''',
    '''CREATE TABLE project_items (
      project_id TEXT NOT NULL REFERENCES projects(id),
      task_id TEXT NOT NULL REFERENCES tasks(id),
      ordinal INTEGER NOT NULL,
      PRIMARY KEY (project_id, task_id)
    )''',
    '''CREATE TABLE taxonomy_categories (
      name TEXT NOT NULL PRIMARY KEY,
      created_at TEXT NOT NULL
    )''',
    '''CREATE TABLE tags (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL
    )''',
    '''CREATE TABLE task_tags (
      task_id TEXT NOT NULL REFERENCES tasks(id),
      tag_id TEXT NOT NULL REFERENCES tags(id),
      ordinal INTEGER NOT NULL,
      PRIMARY KEY (task_id, tag_id)
    )''',
    '''CREATE TABLE checklist_items (
      task_id TEXT NOT NULL REFERENCES tasks(id),
      ordinal INTEGER NOT NULL,
      value TEXT NOT NULL,
      PRIMARY KEY (task_id, ordinal)
    )''',
    '''CREATE TABLE task_people (
      task_id TEXT NOT NULL REFERENCES tasks(id),
      person_id TEXT NOT NULL,
      person_json TEXT NOT NULL,
      ordinal INTEGER NOT NULL,
      PRIMARY KEY (task_id, person_id)
    )''',
    '''CREATE TABLE people (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''',
    '''CREATE TABLE follow_up_people (
      follow_up_id TEXT NOT NULL REFERENCES follow_ups(id),
      person_id TEXT NOT NULL,
      ordinal INTEGER NOT NULL,
      PRIMARY KEY (follow_up_id, person_id)
    )''',
    '''CREATE TABLE arvin_storage_meta (
      key TEXT NOT NULL PRIMARY KEY,
      value TEXT NOT NULL
    )''',
  ];

  for (final statement in statements) {
    await database.runCustom(statement);
  }

  await database.runInsert(
    '''INSERT INTO tasks (
      id, storage_ordinal, title, description, created_at, updated_at,
      due_date, follow_up_enabled, follow_up_date, category, notebook_kind,
      reminder_date, priority, archived, trashed, completed, completed_at,
      recurrence_json, legacy_payload_json
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
    <Object?>[
      'task-null', 0, 'کار با NULL', '', null, null, null, 0, null, null,
      null, null, 'none', 0, 0, 0, null, null,
      jsonEncode(<String, Object?>{
        'unknownTaskField': <String, Object?>{'keep': true},
        'explicitUnknownNull': null,
      }),
    ],
  );
  await database.runInsert(
    '''INSERT INTO tasks (
      id, storage_ordinal, title, description, created_at, updated_at,
      due_date, follow_up_enabled, follow_up_date, category, notebook_kind,
      reminder_date, priority, archived, trashed, completed, completed_at,
      recurrence_json, legacy_payload_json
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
    <Object?>[
      'task-single', 1, 'کار تک‌پروژه', 'توضیح', '2026-11-01T08:00:00Z',
      '2026-11-02T08:00:00Z', '2026-11-30T09:00:00Z', 1, null, 'شخصی',
      null, '2026-11-29T08:00:00Z', 'high', 0, 0, 0, null, null,
      jsonEncode(<String, Object?>{'unknownTaskField': 'preserve-me'}),
    ],
  );
  await database.runInsert(
    '''INSERT INTO tasks (
      id, storage_ordinal, title, description, created_at, updated_at,
      due_date, follow_up_enabled, follow_up_date, category, notebook_kind,
      reminder_date, priority, archived, trashed, completed, completed_at,
      recurrence_json, legacy_payload_json
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
    <Object?>[
      'task-multi', 2, 'کار چندپروژه', '', null, null, null, 0, null, 'کاری',
      null, null, 'none', 0, 0, 0, null, null, null,
    ],
  );

  await database.runInsert(
    'INSERT INTO projects (id, name, legacy_payload_json) VALUES (?, ?, ?)',
    <Object?>[
      'project-a', 'پروژه الف',
      jsonEncode(<String, Object?>{'unknownProjectField': 42}),
    ],
  );
  await database.runInsert(
    'INSERT INTO projects (id, name) VALUES (?, ?)',
    const <Object?>['project-b', 'پروژه ب'],
  );
  await database.runInsert(
    'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
    const <Object?>['project-a', 'task-single', 0],
  );
  await database.runInsert(
    'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
    const <Object?>['project-a', 'task-multi', 0],
  );
  await database.runInsert(
    'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
    const <Object?>['project-b', 'task-multi', 1],
  );

  for (final category in ['شخصی', 'کاری']) {
    await database.runInsert(
      'INSERT INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
      <Object?>[category, '2026-01-01T00:00:00Z'],
    );
  }
  await database.runInsert(
    'INSERT INTO tags (id, name) VALUES (?, ?)',
    const <Object?>['tag-one', 'مهم'],
  );
  await database.runInsert(
    'INSERT INTO task_tags (task_id, tag_id, ordinal) VALUES (?, ?, ?)',
    const <Object?>['task-single', 'tag-one', 0],
  );
  await database.runInsert(
    'INSERT INTO checklist_items (task_id, ordinal, value) VALUES (?, ?, ?)',
    const <Object?>['task-single', 0, 'آماده‌سازی'],
  );
  await database.runInsert(
    '''INSERT INTO follow_ups (
      id, task_id, date_time, title, note, result, reminder_date,
      next_follow_up, completed, waiting_for_response, ordinal
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
    const <Object?>[
      'follow-up-one', 'task-single', '2026-11-03T09:00:00Z',
      'پیگیری تاریخی', 'یادداشت', 'نتیجه', null, null, 0, 1, 0,
    ],
  );
  await database.runInsert(
    'INSERT INTO people (id, name, created_at, updated_at) VALUES (?, ?, ?, ?)',
    const <Object?>[
      'person-one', 'نام قدیمی', '2026-01-01T00:00:00Z',
      '2026-01-01T00:00:00Z',
    ],
  );
  await database.runInsert(
    'INSERT INTO task_people (task_id, person_id, person_json, ordinal) VALUES (?, ?, ?, ?)',
    <Object?>[
      'task-single', 'person-one',
      jsonEncode(<String, Object?>{
        'displayName': 'مریم',
        'unknownPersonField': <String>['keep'],
      }),
      0,
    ],
  );
  await database.runInsert(
    'INSERT INTO follow_up_people (follow_up_id, person_id, ordinal) VALUES (?, ?, ?)',
    const <Object?>['follow-up-one', 'person-one', 0],
  );
  await database.runInsert(
    'INSERT INTO arvin_storage_meta (key, value) VALUES (?, ?)',
    const <Object?>['legacy_custom_key', 'preserve-metadata'],
  );
  await database.runCustom('PRAGMA user_version = 7');
}

Future<void> main() async {
  test(
    'real file-backed v7 database migrates to v9, rolls back, retries and reopens',
    () async {
      final directory = await Directory.systemTemp.createTemp('arvin-v7-v9-');
      final file = File('${directory.path}/arvin-v7.sqlite');
      NativeDatabase? legacy;
      NativeDatabase? migrated;
      NativeDatabase? reopened;

      try {
        legacy = NativeDatabase(file);
        await _createActualV7File(legacy);
        final sourceVersion = await legacy.runSelect(
          'PRAGMA user_version',
          const [],
        );
        expect(sourceVersion.single.values.first, 7);
        await legacy.close();
        legacy = null;

        migrated = NativeDatabase(file);
        await expectLater(
          G1DriftSchema.install(
            migrated,
            failureInjector: (stage) {
              if (stage == 'after_legacy_relationship_transfer') {
                throw StateError('injected v7-to-v9 migration failure');
              }
            },
          ),
          throwsStateError,
        );

        final markerAfterRollback = await migrated.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const ['rev10_hierarchy_schema_version'],
        );
        expect(markerAfterRollback, isEmpty);
        final columnsAfterRollback = await migrated.runSelect(
          "PRAGMA table_info('tasks')",
          const [],
        );
        expect(
          columnsAfterRollback.map((row) => row['name']),
          isNot(contains('project_id')),
        );
        final centersAfterRollback = await migrated.runSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'centers'",
          const [],
        );
        expect(centersAfterRollback, isEmpty);

        await G1DriftSchema.install(migrated);
        final marker = await migrated.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const ['rev10_hierarchy_schema_version'],
        );
        expect(marker.single['value'], '9');

        final nullTask = await migrated.runSelect(
          'SELECT due_date, reminder_date, legacy_payload_json FROM tasks WHERE id = ?',
          const ['task-null'],
        );
        expect(nullTask.single['due_date'], isNull);
        expect(nullTask.single['reminder_date'], isNull);
        final nullPayload = jsonDecode(
          nullTask.single['legacy_payload_json']! as String,
        ) as Map<String, dynamic>;
        expect(nullPayload['unknownTaskField']['keep'], isTrue);
        expect(nullPayload.containsKey('explicitUnknownNull'), isTrue);
        expect(nullPayload['explicitUnknownNull'], isNull);

        final single = await migrated.runSelect(
          'SELECT project_id, category_id FROM tasks WHERE id = ?',
          const ['task-single'],
        );
        expect(single.single['project_id'], 'project-a');
        // A legacy Task category does not prove a Project↔Category edge.
        // Keep the original category text and record the unresolved edge.
        expect(single.single['category_id'], isNull);
        final multi = await migrated.runSelect(
          'SELECT project_id, category_id FROM tasks WHERE id = ?',
          const ['task-multi'],
        );
        expect(multi.single['project_id'], isNull);
        expect(multi.single['category_id'], isNotNull);

        final projectPayload = await migrated.runSelect(
          'SELECT legacy_payload_json FROM projects WHERE id = ?',
          const ['project-a'],
        );
        expect(
          jsonDecode(projectPayload.single['legacy_payload_json']! as String)
              ['unknownProjectField'],
          42,
        );
        expect(
          await migrated.runSelect(
            'SELECT task_id FROM project_items ORDER BY task_id, project_id',
            const [],
          ),
          hasLength(3),
        );
        expect(
          await migrated.runSelect(
            'SELECT tag_id FROM task_tags WHERE task_id = ?',
            const ['task-single'],
          ),
          hasLength(1),
        );
        expect(
          await migrated.runSelect(
            'SELECT value FROM checklist_items WHERE task_id = ?',
            const ['task-single'],
          ),
          hasLength(1),
        );
        expect(
          await migrated.runSelect(
            'SELECT id FROM follow_ups WHERE id = ?',
            const ['follow-up-one'],
          ),
          hasLength(1),
        );
        expect(
          await migrated.runSelect(
            'SELECT person_id FROM follow_up_people WHERE follow_up_id = ?',
            const ['follow-up-one'],
          ),
          hasLength(1),
        );
        final person = await migrated.runSelect(
          'SELECT name FROM people WHERE id = ?',
          const ['person-one'],
        );
        expect(person.single['name'], 'مریم');
        expect(
          await migrated.runSelect(
            'SELECT value FROM arvin_storage_meta WHERE key = ?',
            const ['legacy_custom_key'],
          ),
          hasLength(1),
        );
        final exceptions = await migrated.runSelect(
          'SELECT code FROM arvin_migration_exceptions ORDER BY code',
          const [],
        );
        expect(
          exceptions.map((row) => row['code']),
          containsAll([
            'TASK_MULTIPLE_LEGACY_PROJECTS',
            'TASK_PROJECT_CATEGORY_EDGE_UNRESOLVED',
          ]),
        );
        expect(
          await migrated.runSelect('PRAGMA foreign_key_check', const []),
          isEmpty,
        );
        expect(
          (await migrated.runSelect('PRAGMA integrity_check', const []))
              .single.values.first,
          'ok',
        );

        await migrated.close();
        migrated = null;
        reopened = NativeDatabase(file);
        await G1DriftSchema.install(reopened);
        final afterReopen = await reopened.runSelect(
          'SELECT id, due_date, reminder_date FROM tasks ORDER BY id',
          const [],
        );
        expect(afterReopen, hasLength(3));
        expect(
          afterReopen.firstWhere((row) => row['id'] == 'task-null')['due_date'],
          isNull,
        );
        final duplicateMarker = await reopened.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const ['rev10_hierarchy_schema_version'],
        );
        expect(duplicateMarker, hasLength(1));
        expect(
          (await reopened.runSelect('PRAGMA integrity_check', const []))
              .single.values.first,
          'ok',
        );
      } finally {
        await legacy?.close();
        await migrated?.close();
        await reopened?.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
