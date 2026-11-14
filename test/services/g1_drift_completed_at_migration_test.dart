import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/services/g1_drift_schema.dart';

void main() {
  test('schema installer adds nullable completed_at to an existing task table', () async {
    final database = NativeDatabase.memory();
    await database.ensureOpen(G1DriftSchema());
    try {
      await database.runCustom('''CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
        updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL,
        follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL,
        reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )''');
      await database.runInsert(
        'INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        ['old-task', 'قدیمی', '', 0, 'none', 0, 0, 1],
      );
      await G1DriftSchema.install(database);
      final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
      final completedAt = columns.singleWhere((row) => row['name'] == 'completed_at');
      expect(completedAt['notnull'], 0);
      final rows = await database.runSelect('SELECT id, completed, completed_at FROM tasks WHERE id = ?', ['old-task']);
      expect(rows.single['completed'], 1);
      expect(rows.single['completed_at'], isNull);
      expect(columns.map((row) => row['name']), isNot(contains('follow_up_enabled')));
      expect(columns.map((row) => row['name']), isNot(contains('follow_up_date')));
      expect(columns.map((row) => row['name']), isNot(contains('reminder_date')));
    } finally { await database.close(); }
  });

  test('defers only legacy Task column retirement when an unknown index exists', () async {
    final database = NativeDatabase.memory();
    await database.ensureOpen(G1DriftSchema());
    try {
      await database.runCustom('''CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
        updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL,
        follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL,
        reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )''');
      await database.runCustom('CREATE INDEX idx_tasks_custom_title ON tasks(title)');
      await database.runCustom(
        "INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) "
        "VALUES ('guarded-task', 'محافظت‌شده', '', 0, 'none', 0, 0, 0)",
      );

      await G1DriftSchema.install(database);

      final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
      expect(columns.map((row) => row['name']), contains('follow_up_enabled'));
      final index = await database.runSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
        const <Object?>['idx_tasks_custom_title'],
      );
      expect(index, hasLength(1));
      final row = await database.runSelect(
        'SELECT id, title, legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>['guarded-task'],
      );
      expect(row, hasLength(1));
      expect(row.single['title'], 'محافظت‌شده');
      final payload = jsonDecode(row.single['legacy_payload_json'] as String) as Map;
      expect((payload['legacyFollowUpMetadata'] as Map)['taskLevel'], {
        'followUpEnabled': false,
        'followUpDate': null,
        'reminderDate': null,
      });
      final deferred = await database.runSelect(
        'SELECT value FROM arvin_storage_meta WHERE key = ?',
        const <Object?>['legacy_task_columns_retirement_deferred_v19'],
      );
      expect(deferred, hasLength(1));
      expect(deferred.single['value'], contains('custom indexes'));
    } finally {
      await database.close();
    }
  });
  test('defers legacy Task column retirement when a custom trigger exists', () async {
    final database = NativeDatabase.memory();
    await database.ensureOpen(G1DriftSchema());
    try {
      await database.runCustom('''CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
        updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL,
        follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL,
        reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )''');
      await database.runCustom('''
        CREATE TRIGGER custom_task_update_guard
        AFTER UPDATE ON tasks
        BEGIN
          SELECT 1;
        END
      ''');
      await database.runInsert(
        'INSERT INTO tasks (id, title, description, follow_up_enabled, follow_up_date, reminder_date, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          'trigger-task',
          'محافظت‌شده با Trigger',
          '',
          1,
          '2026-10-20T10:00:00.000Z',
          '2026-10-21T11:00:00.000Z',
          'none',
          0,
          0,
          0,
        ],
      );

      await G1DriftSchema.install(database);

      final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
      expect(columns.map((row) => row['name']), contains('follow_up_enabled'));
      final trigger = await database.runSelect(
        "SELECT name FROM sqlite_master WHERE type = 'trigger' AND name = ?",
        const <Object?>['custom_task_update_guard'],
      );
      expect(trigger, hasLength(1));
      final row = await database.runSelect(
        'SELECT id, title, follow_up_enabled, follow_up_date, reminder_date, legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>['trigger-task'],
      );
      expect(row, hasLength(1));
      expect(row.single['title'], 'محافظت‌شده با Trigger');
      expect(row.single['follow_up_enabled'], 1);
      final payload = jsonDecode(row.single['legacy_payload_json'] as String) as Map;
      expect((payload['legacyFollowUpMetadata'] as Map)['taskLevel'], {
        'followUpEnabled': true,
        'followUpDate': '2026-10-20T10:00:00.000Z',
        'reminderDate': '2026-10-21T11:00:00.000Z',
      });
      final deferred = await database.runSelect(
        'SELECT value FROM arvin_storage_meta WHERE key = ?',
        const <Object?>['legacy_task_columns_retirement_deferred_v19'],
      );
      expect(deferred, hasLength(1));
      expect(deferred.single['value'], contains('triggers'));
      expect(await database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
    } finally {
      await database.close();
    }
  });

  test('defers legacy Task column retirement when an outgoing foreign key exists', () async {
    final database = NativeDatabase.memory();
    await database.ensureOpen(G1DriftSchema());
    try {
      await database.runCustom('CREATE TABLE custom_refs (id TEXT NOT NULL PRIMARY KEY)');
      await database.runInsert(
        'INSERT INTO custom_refs (id) VALUES (?)',
        const <Object?>['foreign-task'],
      );
      await database.runCustom('''CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY REFERENCES custom_refs(id),
        storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
        updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL,
        follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL,
        reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )''');
      await database.runInsert(
        'INSERT INTO tasks (id, title, description, follow_up_enabled, follow_up_date, reminder_date, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          'foreign-task',
          'محافظت‌شده با Foreign Key',
          '',
          0,
          null,
          null,
          'none',
          0,
          0,
          0,
        ],
      );

      await G1DriftSchema.install(database);

      final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
      expect(columns.map((row) => row['name']), contains('follow_up_enabled'));
      final foreignKeys = await database.runSelect(
        "PRAGMA foreign_key_list('tasks')",
        const [],
      );
      expect(foreignKeys, hasLength(1));
      expect(foreignKeys.single['table'], 'custom_refs');
      final row = await database.runSelect(
        'SELECT id, title, legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>['foreign-task'],
      );
      expect(row, hasLength(1));
      expect(row.single['title'], 'محافظت‌شده با Foreign Key');
      final payload = jsonDecode(row.single['legacy_payload_json'] as String) as Map;
      expect((payload['legacyFollowUpMetadata'] as Map)['taskLevel'], {
        'followUpEnabled': false,
        'followUpDate': null,
        'reminderDate': null,
      });
      expect(await database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
      final deferred = await database.runSelect(
        'SELECT value FROM arvin_storage_meta WHERE key = ?',
        const <Object?>['legacy_task_columns_retirement_deferred_v19'],
      );
      expect(deferred, hasLength(1));
      expect(deferred.single['value'], contains('outgoing foreign keys'));
    } finally {
      await database.close();
    }
  });

}
