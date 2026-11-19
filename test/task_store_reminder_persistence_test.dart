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

  test('legacy reminder-table migration removes its flag without losing reminder rows', () async {
    final executor = NativeDatabase.memory();
    addTearDown(executor.close);
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
        opaque_payload TEXT NULL,
        opaque_nullable TEXT NULL,
        UNIQUE (task_id, sequence)
      )
    ''');
    await executor.runInsert(
      'INSERT INTO tasks (id, title, description, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
      const <Object?>['schema-v15-task', 'یادآور قدیمی', '', 'medium', 0, 0, 0],
    );
    await executor.runInsert(
      '''INSERT INTO task_reminders
         (id, task_id, title, remind_at, is_all_day, sequence, is_enabled, is_legacy_task_reminder, opaque_payload, opaque_nullable)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'legacy-task-reminder-schema-v15-task',
        'schema-v15-task',
        'یادآوری قدیمی',
        '2026-10-20T09:30:00.000',
        0,
        1,
        1,
        1,
        'future-reminder-metadata',
        null,
      ],
    );

    await G1DriftSchema.install(executor);

    final columns = await executor.runSelect(
      "PRAGMA table_info('task_reminders')",
      const [],
    );
    expect(columns.map((row) => row['name']), isNot(contains('is_legacy_task_reminder')));
    final rows = await executor.runSelect(
      'SELECT id, remind_at, sequence, is_enabled FROM task_reminders WHERE task_id = ?',
      const <Object?>['schema-v15-task'],
    );
    expect(rows, hasLength(1));
    expect(rows.single['id'], 'legacy-task-reminder-schema-v15-task');
    expect(rows.single['remind_at'], '2026-10-20T09:30:00.000');
    expect(rows.single['sequence'], 1);
    expect(rows.single['is_enabled'], 1);
    final unknownRows = await executor.runSelect(
      'SELECT opaque_payload, opaque_nullable FROM task_reminders WHERE task_id = ?',
      const <Object?>['schema-v15-task'],
    );
    expect(unknownRows.single['opaque_payload'], 'future-reminder-metadata');
    expect(unknownRows.single['opaque_nullable'], isNull);

    await G1DriftSchema.markLegacyMigrationComplete(executor);
    final restored = (await TaskStore(executor: executor).load()).single;
    expect(restored.taskReminders, hasLength(1));
    expect(
      restored.taskReminders.single.id,
      'legacy-task-reminder-schema-v15-task',
    );
    expect(
      isMigratedTaskReminder(restored, restored.taskReminders.single),
      isTrue,
    );
  });

  test('timed due date remains independent from reminders and Follow-up history across file reopen', () async {
    SharedPreferences.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp(
      'arvin-task-due-date-reopen-',
    );
    final databaseFile = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    final firstExecutor = NativeDatabase(databaseFile);
    await G1DriftSchema.install(firstExecutor);
    await G1DriftSchema.markLegacyMigrationComplete(firstExecutor);
    final firstStore = TaskStore(executor: firstExecutor);
    final dueDate = DateTime(2026, 9, 11, 16, 0);
    final reminderDate = DateTime(2026, 9, 9, 10, 0);
    final followUpDate = DateTime(2026, 9, 10, 12, 30);
    final task = Task(
      id: 'file-due-date-independent',
      title: 'استقلال موعد و یادآور',
      dueDate: dueDate,
      taskReminders: <TaskReminder>[
        TaskReminder(
          id: 'file-due-date-reminder',
          title: 'یادآوری مستقل',
          date: reminderDate,
          sequence: 1,
        ),
      ],
      followUps: <FollowUp>[
        FollowUp(
          id: 'file-due-date-follow-up',
          dateTime: followUpDate,
          note: 'پیگیری تاریخی',
        ),
      ],
    );

    await firstStore.save(<Task>[task]);
    final storedDue = await firstExecutor.runSelect(
      'SELECT due_date FROM tasks WHERE id = ?',
      const <Object?>['file-due-date-independent'],
    );
    expect(storedDue.single['due_date'], dueDate.toIso8601String());
    await firstExecutor.close();

    final secondExecutor = NativeDatabase(databaseFile);
    addTearDown(secondExecutor.close);
    final reopened = (await TaskStore(executor: secondExecutor).load()).single;

    expect(reopened.id, 'file-due-date-independent');
    expect(reopened.dueDate, dueDate);
    expect(reopened.taskReminders, hasLength(1));
    expect(reopened.taskReminders.single.id, 'file-due-date-reminder');
    expect(reopened.reminderDate, reminderDate);
    expect(reopened.followUps, hasLength(1));
    expect(reopened.followUps.single.id, 'file-due-date-follow-up');
    expect(reopened.followUps.single.dateTime, followUpDate);
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
