import 'package:arvin/models/task.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/task_template_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/task_template_management_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Task Template tab selects an existing Task and persists a separate definition', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final tasks = TaskStore(executor: database);
    final templates = TaskTemplateStore(executor: database);
    final projects = ProjectStore(executor: database);
    final centers = CenterStore(executor: database);
    final source = Task(
      id: 'template-list-source',
      title: 'سرویس پمپ',
      description: 'شرح منبع',
      checklist: const ['[x] کنترل برق', '[ ] کنترل فشار'],
      dueDate: DateTime(2026, 11, 20),
    );
    await tasks.save([source]);
    await centers.create(
      id: 'task-template-center',
      name: 'مرکز نگهداری',
      now: DateTime(2026, 11, 5),
    );
    await projects.save([
      ProjectPlan(
        id: 'task-template-project',
        title: 'پروژه تعمیرات',
        centerId: 'task-template-center',
        itemIds: [source.id],
      ),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: TaskTemplateManagementPage(
        taskStore: tasks,
        templateStore: templates,
        projectStore: projects,
        centerStore: centers,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-template-convert-template-list-source')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('task-template-name-input')), 'سرویس فصلی پمپ');
    await tester.tap(find.byKey(const ValueKey('task-template-confirm')));
    await tester.pumpAndSettle();

    final saved = (await templates.load()).single;
    expect(saved.name, 'سرویس فصلی پمپ');
    expect(saved.title, 'سرویس پمپ');
    expect(saved.checklist, ['کنترل برق', 'کنترل فشار']);
    expect(saved.centerNameSnapshot, 'مرکز نگهداری');
    expect(saved.projectNameSnapshot, 'پروژه تعمیرات');
    expect(saved.centerIdSnapshot, 'task-template-center');
    expect(saved.projectIdSnapshot, 'task-template-project');
    expect(source.dueDate, DateTime(2026, 11, 20));
    expect(source.checklist, ['[x] کنترل برق', '[ ] کنترل فشار']);
    expect(find.text('الگوی کار ذخیره شد؛ کار اصلی بدون تغییر ماند.'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('task-template-create-${saved.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('task-template-create-confirm-${saved.id}')));
    await tester.pumpAndSettle();
    final allTasks = await tasks.load();
    expect(allTasks, hasLength(2));
    final generated = allTasks.singleWhere((item) => item.id != source.id);
    expect(generated.title, 'سرویس پمپ');
    expect(generated.checklist, ['[ ] کنترل برق', '[ ] کنترل فشار']);
    expect(generated.checklistEnabled, isTrue);
    expect(generated.dueDate, isNull);
    expect(generated.completed, isFalse);
    expect(generated.completedAt, isNull);
    expect(generated.followUps, isEmpty);
    expect(generated.taskReminders, isEmpty);
    expect(source.checklist, ['[x] کنترل برق', '[ ] کنترل فشار']);
    expect(find.text('کار «سرویس پمپ» از الگو ساخته شد.'), findsOneWidget);
  });
}
