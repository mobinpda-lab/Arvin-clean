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

  test('Project and Task membership survive a fresh file-backed SQLite reopen',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('arvin-project-file-backed-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/arvin.sqlite');

    final firstDatabase = NativeDatabase(file);
    try {
      final tasks = TaskStore(executor: firstDatabase);
      final projects = ProjectStore(executor: firstDatabase);
      await tasks.save(<Task>[
        Task(id: 'durable-task-1', title: 'کار پایدار یک'),
        Task(id: 'durable-task-2', title: 'کار پایدار دو'),
      ]);
      await projects.save(<ProjectPlan>[
        ProjectPlan(
          id: 'durable-project',
          title: 'پروژه پایدار',
          colorValue: 0xFF2F80ED,
          isArchived: true,
          itemIds: const <String>['durable-task-1', 'durable-task-2'],
        ),
      ]);
    } finally {
      await firstDatabase.close();
    }

    // A new executor and new Store instances must recover the same SQLite file.
    final reopenedDatabase = NativeDatabase(file);
    try {
      final reopenedTasks = await TaskStore(executor: reopenedDatabase).load();
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
    } finally {
      await reopenedDatabase.close();
    }
  });
}
