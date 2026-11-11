import 'dart:io';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Project and Task membership survive a fresh file-backed SQLite reopen',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('arvin-project-file-backed-');
    final file = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    final firstDatabase = NativeDatabase(file);
    final firstTasks = TaskStore(executor: firstDatabase);
    final firstProjects = ProjectStore(executor: firstDatabase);

    await firstTasks.save(<Task>[
      Task(id: 'durable-task-1', title: 'کار پایدار یک'),
      Task(id: 'durable-task-2', title: 'کار پایدار دو'),
    ]);
    await firstProjects.save(<ProjectPlan>[
      ProjectPlan(
        id: 'durable-project',
        title: 'پروژه پایدار',
        colorValue: 0xFF2F80ED,
        isArchived: true,
        itemIds: const <String>['durable-task-1', 'durable-task-2'],
      ),
    ]);

    await firstDatabase.close();

    final reopenedDatabase = NativeDatabase(file);
    addTearDown(reopenedDatabase.close);
    final reopenedTasks =
        await TaskStore(executor: reopenedDatabase).load();
    final reopenedProjects =
        await ProjectStore(executor: reopenedDatabase).load();

    expect(
      reopenedTasks.map((task) => task.id),
      containsAll(<String>['durable-task-1', 'durable-task-2']),
    );
    expect(reopenedProjects, hasLength(1));
    expect(reopenedProjects.single.id, 'durable-project');
    expect(reopenedProjects.single.title, 'پروژه پایدار');
    expect(reopenedProjects.single.colorValue, 0xFF2F80ED);
    expect(reopenedProjects.single.isArchived, isTrue);
    expect(
      reopenedProjects.single.itemIds,
      <String>['durable-task-1', 'durable-task-2'],
    );
  });
}
