import 'dart:io';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('file-backed SQLite close/reopen preserves independent Reminder CRUD', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-task-reminder-test-');
    final databaseFile = File('${directory.path}/isolated-reminders.sqlite');
    var executor = NativeDatabase(databaseFile);
    addTearDown(() async {
      try {
        await executor.close();
      } catch (_) {}
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    SharedPreferences.setMockInitialValues({});

    final task = Task(
      id: 'file-task',
      title: 'Task with independent Reminders',
      dueDate: DateTime(2026, 10, 24, 16),
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'Alarm only',
          date: DateTime(2026, 10, 24, 17),
          alarmEnabled: true,
          calendarSyncEnabled: false,
          sequence: 1,
        ),
        TaskReminder(
          id: 'r2',
          title: 'Calendar only',
          date: DateTime(2026, 10, 24, 18),
          alarmEnabled: false,
          calendarSyncEnabled: true,
          sequence: 2,
        ),
        TaskReminder(
          id: 'r3',
          title: 'Both channels',
          date: DateTime(2026, 10, 24, 19),
          alarmEnabled: true,
          calendarSyncEnabled: true,
          sequence: 3,
        ),
        TaskReminder(
          id: 'r4',
          title: 'Neither channel',
          date: DateTime(2026, 10, 24, 20),
          alarmEnabled: false,
          calendarSyncEnabled: false,
          sequence: 4,
        ),
      ],
    );

    await TaskStore(executor: executor).save([task]);
    await executor.close();

    executor = NativeDatabase(databaseFile);
    var loaded = await TaskStore(executor: executor).load();
    expect(loaded, hasLength(1));
    expect(loaded.single.dueDate, task.dueDate);
    expect(loaded.single.taskReminders.map((item) => item.id), ['r1', 'r2', 'r3', 'r4']);
    expect(loaded.single.taskReminders.map((item) => [item.alarmEnabled, item.calendarSyncEnabled]), [
      [true, false],
      [false, true],
      [true, true],
      [false, false],
    ]);

    final current = loaded.single;
    current.taskReminders = [
      current.taskReminders.first.copyWith(
        title: 'Edited alarm',
        date: DateTime(2026, 10, 24, 17, 30),
        alarmEnabled: false,
        calendarSyncEnabled: true,
      ),
      current.taskReminders.last,
      TaskReminder(
        id: 'r5',
        title: 'New independent Reminder',
        date: DateTime(2026, 10, 25, 9),
        alarmEnabled: true,
        calendarSyncEnabled: false,
        sequence: 5,
      ),
    ];
    await TaskStore(executor: executor).save([current]);
    await executor.close();

    executor = NativeDatabase(databaseFile);
    loaded = await TaskStore(executor: executor).load();
    final reminders = loaded.single.taskReminders;
    expect(reminders.map((item) => item.id), ['r1', 'r3', 'r5']);
    expect(reminders.first.title, 'Edited alarm');
    expect(reminders.first.date, DateTime(2026, 10, 24, 17, 30));
    expect(reminders.first.alarmEnabled, isFalse);
    expect(reminders.first.calendarSyncEnabled, isTrue);
    expect(loaded.single.dueDate, task.dueDate);
  });
}
