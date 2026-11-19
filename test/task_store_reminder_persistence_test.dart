import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/g1_drift_schema.dart';

void main() {
  test('TaskStore round-trip preserves reminderDate under arvin.tasks', () async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore();
    final reminder = DateTime.parse('2026-08-22T16:45:00.000');
    final task = Task.fromLegacyJson({'id': 'store-reminder-1', 'title': 'یادآوری ذخیره‌شده', 'reminderDate': reminder.toIso8601String()});

    await store.save([task]);
    final loaded = await store.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'store-reminder-1');
    expect(loaded.single.reminderDate, reminder);
  });

  test('SQL round-trip computes the earliest enabled reminder from taskReminders', () async {
    final executor = NativeDatabase.memory();
    addTearDown(executor.close);
    await G1DriftSchema.install(executor);
    await G1DriftSchema.markLegacyMigrationComplete(executor);
    final store = TaskStore(executor: executor);
    final task = Task(
      id: 'earliest-sql-reminder',
      title: 'یادآورهای چندگانه',
      dueDate: DateTime(2026, 11, 3, 12),
      taskReminders: [
        TaskReminder(
          id: 'later',
          title: 'دیرتر',
          date: DateTime(2026, 11, 3, 11),
          sequence: 1,
        ),
        TaskReminder(
          id: 'earlier',
          title: 'زودتر',
          date: DateTime(2026, 11, 3, 8),
          sequence: 2,
        ),
        TaskReminder(
          id: 'disabled',
          title: 'غیرفعال',
          date: DateTime(2026, 11, 3, 7),
          sequence: 3,
          isEnabled: false,
        ),
      ],
      nextReminderSequence: 4,
    );

    await store.save([task]);
    final loaded = (await store.load()).single;

    expect(loaded.taskReminders, hasLength(3));
    expect(loaded.reminderDate, DateTime(2026, 11, 3, 8));
    expect(loaded.dueDate, DateTime(2026, 11, 3, 12));
  });

  test('legacy reminder-table migration drops only its marker and preserves unknown data across reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'arvin-reminder-migration-',
    );
    final databaseFile = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    final executor = NativeDatabase(databaseFile);
    await executor.ensureOpen(G1DriftSchema());
    await executor.runCustom('''
      CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY,
        storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NULL,
        updated_at TEXT NULL,
        due_date TEXT NULL,
        category TEXT NULL,
        notebook_kind TEXT NULL,
        priority TEXT NOT NULL DEFAULT 'medium',
        archived INTEGER NOT NULL DEFAULT 0,
        trashed INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )
    ''');
    await executor.runCustom('''
      CREATE TABLE task_reminders (
        id TEXT NOT NULL PRIMARY KEY,
        task_id TEXT NOT NULL REFERENCES tasks(id),
        title TEXT NOT NULL,
        remind_at TEXT NOT NULL,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        sequence INTEGER NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        is_legacy_task_reminder INTEGER NOT NULL DEFAULT 0,
        future_extension TEXT NULL,
        UNIQUE (task_id, sequence)
      )
    ''');
    await executor.runInsert(
      'INSERT INTO tasks (id, title, description, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
      const <Object?>['schema-v15-task', 'یادآور قدیمی', '', 'medium', 0, 0, 0],
    );
    await executor.runInsert(
      '''INSERT INTO task_reminders
         (id, task_id, title, remind_at, is_all_day, sequence, is_enabled,
          is_legacy_task_reminder, future_extension)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'legacy-task-reminder-schema-v15-task',
        'schema-v15-task',
        'یادآوری قدیمی',
        '2026-10-20T09:30:00.000',
        0,
        1,
        1,
        1,
        'opaque-v15-value',
      ],
    );
    await executor.runInsert(
      '''INSERT INTO task_reminders
         (id, task_id, title, remind_at, is_all_day, sequence, is_enabled,
          is_legacy_task_reminder, future_extension)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'legacy-task-reminder-null-extension',
        'schema-v15-task',
        'یادآوری با مقدار تهی',
        '2026-10-21T09:30:00.000',
        1,
        2,
        0,
        1,
        null,
      ],
    );

    await G1DriftSchema.install(executor);

    Future<void> expectMigratedRows(NativeDatabase database) async {
      final columns = await database.runSelect(
        "PRAGMA table_info('task_reminders')",
        const [],
      );
      final names = columns.map((row) => row['name']).toList();
      expect(names, isNot(contains('is_legacy_task_reminder')));
      expect(names, contains('future_extension'));

      final rows = await database.runSelect(
        '''SELECT id, remind_at, sequence, is_enabled, future_extension
           FROM task_reminders WHERE task_id = ? ORDER BY sequence''',
        const <Object?>['schema-v15-task'],
      );
      expect(rows, hasLength(2));
      expect(rows[0]['id'], 'legacy-task-reminder-schema-v15-task');
      expect(rows[0]['remind_at'], '2026-10-20T09:30:00.000');
      expect(rows[0]['sequence'], 1);
      expect(rows[0]['is_enabled'], 1);
      expect(rows[0]['future_extension'], 'opaque-v15-value');
      expect(rows[1]['id'], 'legacy-task-reminder-null-extension');
      expect(rows[1]['sequence'], 2);
      expect(rows[1]['is_enabled'], 0);
      expect(rows[1]['future_extension'], isNull);

      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      expect(integrity.single['integrity_check'], 'ok');
      final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
      expect(foreignKeys, isEmpty);
    }

    await expectMigratedRows(executor);
    await executor.close();

    final reopened = NativeDatabase(databaseFile);
    addTearDown(reopened.close);
    await G1DriftSchema.install(reopened);
    await expectMigratedRows(reopened);
  });

  test('TaskStore stores All-Day due dates as date-only SQLite values', () async {
    SharedPreferences.setMockInitialValues({});
    final executor = NativeDatabase.memory();
    await G1DriftSchema.install(executor);
    await G1DriftSchema.markLegacyMigrationComplete(executor);
    final store = TaskStore(executor: executor);
    try {
      await store.save([
        Task(
          id: 'store-all-day-due',
          title: 'کار بدون ساعت',
          dueDate: DateTime(2026, 11, 8),
          allDay: true,
        ),
      ]);

      final rows = await executor.runSelect(
        'SELECT due_date FROM tasks WHERE id = ?',
        const <Object?>['store-all-day-due'],
      );
      expect(rows.single['due_date'], '2026-11-08');
      final loaded = (await store.load()).single;
      expect(loaded.allDay, isTrue);
      expect(loaded.dueDate?.year, 2026);
      expect(loaded.dueDate?.month, 11);
      expect(loaded.dueDate?.day, 8);
    } finally {
      await executor.close();
    }
  });

  test('TaskStore accepts legacy payloads without reminderDate', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"legacy-store-1","title":"قدیمی"}]',
    });
    final store = TaskStore();

    final loaded = await store.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'legacy-store-1');
    expect(loaded.single.title, 'قدیمی');
    expect(loaded.single.reminderDate, isNull);
  });

  test('TaskStore round-trip persists favorite state in the canonical SQLite column', () async {
    final executor = NativeDatabase.memory();
    await G1DriftSchema.install(executor);
    await G1DriftSchema.markLegacyMigrationComplete(executor);
    final store = TaskStore(executor: executor);
    try {
      final task = Task(id: 'store-favorite-1', title: 'کار موردعلاقه');
      expect(task.isFavorite, isFalse);
      task.isFavorite = true;

      await store.save([task]);

      final rows = await executor.runSelect(
        'SELECT is_favorite FROM tasks WHERE id = ?',
        const <Object?>['store-favorite-1'],
      );
      expect(rows.single['is_favorite'], 1);
      final loaded = (await store.load()).single;
      expect(loaded.isFavorite, isTrue);
    } finally {
      await executor.close();
    }
  });

  test('TaskStore updates and removes a migrated legacy reminder', () async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore();
    final original = DateTime.parse('2026-08-22T08:00:00.000');
    final updated = DateTime.parse('2026-08-23T09:15:00.000');
    final task = Task.fromLegacyJson({'id': 'store-reminder-remove', 'title': 'ویرایش و حذف یادآوری', 'reminderDate': original.toIso8601String()});

    await store.save([task]);
    task.taskReminders[0] = task.taskReminders[0].copyWith(date: updated);
    await store.save([task]);
    expect((await store.load()).single.reminderDate, updated);

    task.taskReminders.clear();
    await store.save([task]);
    final loaded = await store.load();
    expect(loaded.single.reminderDate, isNull);
    expect(loaded.single.legacyTaskReminderMigrationVersion, 1);
  });
}
