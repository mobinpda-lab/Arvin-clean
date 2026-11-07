import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/arvin_center.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('Task Details category and tags use shared filter selectors', (tester) async {
    var saved = Task(
      id: 'detail-metadata',
      title: 'کار آزمایشی',
      category: 'کاری',
      tags: ['مهم'],
    );

    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: saved,
        categoryOptions: const ['کاری', 'شخصی'],
        tagOptions: const ['مهم', 'فوری'],
        onTaskChanged: (updated) async {
          saved = updated;
          return updated;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<Object?>, 'شخصی'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'فوری'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(saved.category, 'شخصی');
    expect(saved.tags.toSet(), {'مهم', 'فوری'});
  });

  testWidgets('Task Details Center and Project selectors share the same sheet and persist', (tester) async {
    var saved = Task(
      id: 'detail-center-project',
      title: 'کار دارای مرکز',
      centerId: 'center-1',
    );
    String? selectedProject = 'project-1';

    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: saved,
        centers: [
          ArvinCenter(id: 'center-1', name: 'مرکز یک', createdAt: DateTime(2026, 11, 1)),
          ArvinCenter(id: 'center-2', name: 'مرکز دو', createdAt: DateTime(2026, 11, 1)),
        ],
        projects: [
          ProjectPlan(id: 'project-1', title: 'پروژه یک', centerId: 'center-1'),
          ProjectPlan(id: 'project-2', title: 'پروژه دو', centerId: 'center-2'),
        ],
        selectedProjectId: 'project-1',
        onTaskChanged: (updated) async {
          saved = updated;
          return updated;
        },
        onProjectChanged: (value) async {
          selectedProject = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-center')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<Object?>, 'مرکز دو'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-project')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<Object?>, 'پروژه دو'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(saved.centerId, 'center-2');
    expect(selectedProject, 'project-2');
  });
}
