import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/arvin_center.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/project_detail_page.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/project_template_service.dart';
import 'package:arvin/services/project_template_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Project Details converts existing project to stored template without source mutation', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final tasks = TaskStore(executor: database);
    final projects = ProjectStore(executor: database);
    final centers = CenterStore(executor: database);
    final templates = ProjectTemplateStore(executor: database);
    final task = Task(
      id: 'project-detail-source-task',
      title: 'بازرسی موتور',
      checklist: const ['[x] کنترل روغن', '[ ] کنترل لرزش'],
    );
    await tasks.save([task]);
    await centers.create(
      id: 'center-1',
      name: 'مرکز نمونه',
      now: DateTime(2026, 11, 5),
    );
    final project = ProjectPlan(
      id: 'project-detail-source',
      title: 'بازرسی دوره‌ای',
      centerId: 'center-1',
      itemIds: [task.id],
    );
    await projects.save([project]);
    final service = ProjectTemplateService(
      templateStore: templates,
      projectStore: projects,
      taskStore: tasks,
      idFactory: (prefix) => '$prefix-id',
    );

    await tester.pumpWidget(MaterialApp(
      home: ProjectDetailPage(
        project: project,
        centerName: 'مرکز نمونه',
        taskStore: tasks,
        templateService: service,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('project-detail-convert-template')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('project-detail-template-confirm')));
    await tester.pumpAndSettle();

    final saved = (await templates.load()).single;
    expect(saved.name, 'بازرسی دوره‌ای');
    expect(saved.centerId, 'center-1');
    expect(saved.tasks.single.title, 'بازرسی موتور');
    expect(saved.tasks.single.checklist, ['کنترل روغن', 'کنترل لرزش']);
    expect((await projects.load()).single.title, 'بازرسی دوره‌ای');
    expect((await tasks.load()).single.checklist, ['[x] کنترل روغن', '[ ] کنترل لرزش']);
    expect(find.text('الگوی «بازرسی دوره‌ای» ذخیره شد؛ پروژه اصلی بدون تغییر ماند.'), findsOneWidget);
  });
}
