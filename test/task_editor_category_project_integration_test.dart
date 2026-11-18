import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openEditor(
    WidgetTester tester, {
    Task? task,
    List<ProjectPlan> projects = const [],
    String? selectedProjectId,
    ValueChanged<String?>? onProjectChanged,
    ValueChanged<Task?>? onResult,
  }) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showDialog<Task>(
                    context: context,
                    builder: (_) => ArvinTaskEditorDialog(
                      task: task,
                      projects: projects,
                      selectedProjectId: selectedProjectId,
                      onProjectChanged: onProjectChanged,
                      knownCategories: const ['اداری', 'مشتری'],
                    ),
                  );
                  onResult?.call(result);
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    final finder = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('new task saves typed category without an extra apply step',
      (tester) async {
    Task? result;
    await openEditor(tester, onResult: (value) => result = value);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'کار دسته‌بندی‌شده',
    );
    await tester.tap(find.byTooltip('دسته'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('افزودن').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'نام'), '  مشتری ویژه  ');
    await tester.tap(find.text('افزودن').last);
    await tester.pumpAndSettle();
    await save(tester);

    expect(result, isNotNull);
    expect(result!.category, 'مشتری ویژه');
    expect(result!.tags, isEmpty);
  });

  testWidgets('category can be cleared while tags remain independent',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'category-edit',
      title: 'پرونده',
      category: 'اداری',
      tags: const ['مهم'],
    );
    await openEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byTooltip('دسته'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بدون دسته'));
    await tester.pump();
    await save(tester);

    expect(result?.category, isNull);
    expect(result?.tags, const ['مهم']);
  });

  testWidgets('Project selection returns canonical Project id separately',
      (tester) async {
    Task? result;
    String? projectId = 'p1';
    final projects = [
      ProjectPlan(id: 'p1', title: 'کاری', colorValue: 0xFF2F80ED),
      ProjectPlan(id: 'p2', title: 'شخصی', colorValue: 0xFF9B51E0),
    ];

    await openEditor(
      tester,
      projects: projects,
      selectedProjectId: projectId,
      onProjectChanged: (value) => projectId = value,
      onResult: (value) => result = value,
    );

    final projectRollBox = find.byTooltip('پروژه');
    await tester.tap(projectRollBox);
    await tester.pumpAndSettle();
    expect(find.text('کاری'), findsWidgets);
    expect(find.text('شخصی'), findsOneWidget);
    await tester.tap(find.text('شخصی'));
    await tester.pump();
    await save(tester);

    expect(result, isNotNull);
    expect(projectId, 'p2');
  });

  testWidgets('Project can be explicitly removed without changing category',
      (tester) async {
    Task? result;
    String? projectId = 'p1';
    final task = Task(
      id: 'project-clear',
      title: 'کار',
      category: 'اداری',
    );

    await openEditor(
      tester,
      task: task,
      projects: [ProjectPlan(id: 'p1', title: 'کاری')],
      selectedProjectId: projectId,
      onProjectChanged: (value) => projectId = value,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byTooltip('پروژه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بدون پروژه'));
    await tester.pump();
    await save(tester);

    expect(projectId, isNull);
    expect(result?.category, 'اداری');
  });
}
