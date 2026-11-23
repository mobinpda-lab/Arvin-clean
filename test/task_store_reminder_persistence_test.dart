import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

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

  test('TaskStore persists reminder removal as null', () async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore();
    final task = Task(
      id: 'store-reminder-remove',
      title: 'حذف یادآوری',
      reminderDate: DateTime.parse('2026-08-22T08:00:00.000'),
    );

    await store.save([task]);
    task.reminderDate = null;
    await store.save([task]);

    final loaded = await store.load();
    expect(loaded.single.reminderDate, isNull);
  });
}
