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
    final task = Task(
      id: 'store-reminder-1',
      title: 'یادآوری ذخیره‌شده',
      reminderDate: reminder,
    );

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
        UNIQUE (task_id, sequence)
      )
    ''');
    await executor.runInsert(
      'INSERT INTO tasks (id, title, description, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?)',
      const <Object?>['schema-v15-task', 'یادآور قدیمی', '', 'medium', 0, 0, 0],
    );
    await executor.runInsert(
      '''INSERT INTO task_reminders
         (id, task_id, title, remind_at, is_all_day, sequence, is_enabled, is_legacy_task_reminder)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'legacy-task-reminder-schema-v15-task',
        'schema-v15-task',
        'یادآوری قدیمی',
        '2026-10-20T09:30:00.000',
        0,
        1,
        1,
        1,
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
    final task = Task(
      id: 'store-reminder-remove',
      title: 'ویرایش و حذف یادآوری',
      reminderDate: original,
    );

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
