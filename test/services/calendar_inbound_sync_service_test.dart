import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_inbound_sync_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NativeDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = NativeDatabase.memory();
    await TaskStore(executor: database).save([
      Task(
        id: 'task-1',
        title: 'کار مالک آروین',
        dueDate: DateTime(2026, 10, 8, 10),
        reminderDate: DateTime(2026, 10, 8, 9),
        taskReminders: [
          TaskReminder(
            id: 'reminder-1',
            title: 'یادآور مستقل',
            date: DateTime(2026, 10, 8, 9),
            sequence: 1,
          ),
        ],
      ),
    ]);
  });

  tearDown(() async {
    await database.close();
  });

  test('retired inbound reconciliation never mutates native Task ownership', () async {
    final taskStore = TaskStore(executor: database);
    final before = (await taskStore.load()).single;

    final result = await const CalendarInboundSyncService().reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    final after = (await taskStore.load()).single;
    expect(result.updated, 0);
    expect(result.deleted, 0);
    expect(result.conflicts, 0);
    expect(result.changed, isFalse);
    expect(after.id, before.id);
    expect(after.title, before.title);
    expect(after.dueDate, before.dueDate);
    expect(after.reminderDate, before.reminderDate);
    expect(after.taskReminders.map((item) => item.id), ['reminder-1']);
    expect(after.taskReminders.single.title, 'یادآور مستقل');
    expect(after.taskReminders.single.date, DateTime(2026, 10, 8, 9));
  });

  test('provider deletion or movement has no inbound mutation entry point', () async {
    final result = await const CalendarInboundSyncService().reconcile(
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 1),
    );

    expect(result.changed, isFalse);
    expect(result.updated + result.deleted, 0);
  });
}
