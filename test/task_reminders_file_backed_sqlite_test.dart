import 'dart:io';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('multiple Task reminders survive fresh file-backed SQLite reopen and CRUD',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('arvin-task-reminders-sqlite-');
    final file = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    final originalDueDate = DateTime(2026, 10, 27, 16, 20);
    final legacyReminderDate = DateTime(2026, 10, 28, 8, 15);
    final secondReminderDate = DateTime(2026, 10, 29);

    // Decode the legacy singular field through the real migration boundary.
    final task = Task.fromJson(<String, dynamic>{
      'id': 'sqlite-multi-reminder-task',
      'title': 'File-backed reminder test',
      'dueDate': originalDueDate.toIso8601String(),
      'reminderDate': legacyReminderDate.toIso8601String(),
    });
    expect(task.taskReminders, hasLength(1));
    expect(task.taskReminders.single.id, 'legacy-task-reminder');
    expect(task.legacyTaskReminderMigrationVersion, 1);

    task.taskReminders.add(
      TaskReminder(
        id: 'reminder-second',
        title: 'Second reminder',
        date: secondReminderDate,
        isAllDay: true,
        sequence: 2,
      ),
    );
    task.nextReminderSequence = 3;

    final firstDatabase = NativeDatabase(file);
    final firstStore = TaskStore(executor: firstDatabase);
    await firstStore.save(<Task>[task]);
    await firstDatabase.close();

    // A distinct executor and Store must recover the same on-disk SQLite file.
    final reopenedDatabase = NativeDatabase(file);
    final reopenedStore = TaskStore(executor: reopenedDatabase);
    final reopened = await reopenedStore.load();
    expect(reopened, hasLength(1));
    var loaded = reopened.single;
    expect(loaded.id, 'sqlite-multi-reminder-task');
    expect(loaded.dueDate, originalDueDate);
    expect(loaded.reminderDate, legacyReminderDate);
    expect(loaded.taskReminders, hasLength(2));
    expect(loaded.taskReminders.map((r) => r.id).toList(),
        <String>['legacy-task-reminder', 'reminder-second']);
    expect(loaded.taskReminders.map((r) => r.sequence).toList(), <int>[1, 2]);
    expect(loaded.taskReminders[0].date, legacyReminderDate);
    expect(loaded.taskReminders[0].isAllDay, isFalse);
    expect(loaded.taskReminders[1].date, secondReminderDate);
    expect(loaded.taskReminders[1].isAllDay, isTrue);

    final editedFirstDate = DateTime(2026, 10, 28, 9, 35);
    loaded.taskReminders[0] = loaded.taskReminders[0].copyWith(
      date: editedFirstDate,
    );
    await reopenedStore.save(reopened);

    final afterEdit = (await reopenedStore.load()).single;
    expect(afterEdit.dueDate, originalDueDate,
        reason: 'editing a reminder must not mutate the Task due date');
    expect(afterEdit.reminderDate, legacyReminderDate,
        reason: 'editing a migrated reminder must preserve the legacy field');
    expect(afterEdit.taskReminders, hasLength(2));
    expect(afterEdit.taskReminders[0].id, 'legacy-task-reminder');
    expect(afterEdit.taskReminders[0].date, editedFirstDate);
    expect(afterEdit.taskReminders[0].isAllDay, isFalse);
    expect(afterEdit.taskReminders[1].id, 'reminder-second');
    expect(afterEdit.taskReminders[1].date, secondReminderDate);
    expect(afterEdit.taskReminders[1].isAllDay, isTrue);

    afterEdit.taskReminders.removeWhere((r) => r.id == 'reminder-second');
    await reopenedStore.save(<Task>[afterEdit]);

    await reopenedDatabase.close();

    // Reopen again to prove deletion and the migration marker are durable.
    final finalDatabase = NativeDatabase(file);
    final finalStore = TaskStore(executor: finalDatabase);
    final finalTask = (await finalStore.load()).single;
    expect(finalTask.taskReminders, hasLength(1));
    expect(finalTask.taskReminders.single.id, 'legacy-task-reminder');
    expect(finalTask.taskReminders.single.date, editedFirstDate);
    expect(finalTask.taskReminders.single.isAllDay, isFalse);
    expect(finalTask.dueDate, originalDueDate);
    expect(finalTask.reminderDate, legacyReminderDate);
    expect(finalTask.legacyTaskReminderMigrationVersion, 1);

    // Re-running the JSON migration boundary must not resurrect or duplicate
    // the removed legacy-derived reminder because the migration marker persists.
    final migratedAgain = Task.fromJson(finalTask.toJson());
    expect(migratedAgain.taskReminders, hasLength(1));
    expect(migratedAgain.taskReminders.single.id, 'legacy-task-reminder');
    expect(migratedAgain.taskReminders.single.date, editedFirstDate);
    expect(migratedAgain.legacyTaskReminderMigrationVersion, 1);

    await finalDatabase.close();
  });
}
