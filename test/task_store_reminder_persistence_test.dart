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
    task.reminderDate = updated;
    await store.save([task]);
    expect((await store.load()).single.reminderDate, updated);

    task.reminderDate = null;
    await store.save([task]);
    final loaded = await store.load();
    expect(loaded.single.reminderDate, isNull);
    expect(loaded.single.legacyTaskReminderMigrationVersion, 1);
  });
}
