import 'dart:io';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('file-backed SQLite preserves Project and Task membership after fresh reopen',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('arvin-project-persistence-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/arvin.sqlite');

    final firstDatabase = NativeDatabase(file);
    final firstTasks = TaskStore(executor: firstDatabase);
    final firstProjects = ProjectStore(executor: firstDatabase);
    await firstTasks.save([
      Task(id: 'durable-task-1', title: 'کار پایدار یک'),
      Task(id: 'durable-task-2', title: 'کار پایدار دو'),
    ]);
    await firstProjects.save([
      ProjectPlan(
        id: 'durable-project',
        title: 'پروژه پایدار',
        colorValue: 0xFF2F80ED,
        isArchived: true,
        itemIds: const ['durable-task-1', 'durable-task-2'],
      ),
    ]);

    await firstDatabase.close();

    // New executor and Store instances must recover the same on-disk database.
    final reopenedDatabase = NativeDatabase(file);
    addTearDown(reopenedDatabase.close);
    final reopenedTasks = await TaskStore(executor: reopenedDatabase).load();
    final reopenedProjects = await ProjectStore(executor: reopenedDatabase).load();

    expect(
      reopenedTasks.map((task) => task.id),
      containsAll(['durable-task-1', 'durable-task-2']),
    );
    expect(reopenedProjects, hasLength(1));
    expect(reopenedProjects.single.id, 'durable-project');
    expect(reopenedProjects.single.title, 'پروژه پایدار');
    expect(reopenedProjects.single.colorValue, 0xFF2F80ED);
    expect(reopenedProjects.single.isArchived, isTrue);
    expect(
      reopenedProjects.single.itemIds,
      ['durable-task-1', 'durable-task-2'],
    );
  });
}
