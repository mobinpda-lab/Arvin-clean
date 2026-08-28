import 'package:arvin/models/goal_project.dart';
import 'package:arvin/projects_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'renders colored project cards and blocks deleting non-empty project',
      (tester) async {
    var changed = <ProjectPlan>[];
    final projects = [
      ProjectPlan(
        id: 'work',
        title: 'کاری',
        colorValue: 0xFF2F80ED,
        itemIds: const ['task-1'],
      ),
      ProjectPlan(id: 'personal', title: 'شخصی', colorValue: 0xFF27AE60),
    ];

    await tester.pumpWidget(MaterialApp(
      home: ProjectsPage(
        projects: projects,
        onChanged: (value) => changed = value,
      ),
    ));

    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('کاری'), findsOneWidget);
    expect(find.text('شخصی'), findsOneWidget);
    expect(find.text('1 کار'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('project-delete-work')));
    await tester.pump();
    expect(find.text('پروژه دارای کار است و قابل حذف نیست.'), findsOneWidget);
    expect(changed, isEmpty);

    await tester.tap(find.byKey(const ValueKey('project-delete-personal')));
    await tester.pump();
    expect(changed.map((item) => item.id), ['work']);
  });

  testWidgets('can add a project with title and selected color', (tester) async {
    var changed = <ProjectPlan>[];

    await tester.pumpWidget(MaterialApp(
      home: ProjectsPage(
        projects: const [],
        onChanged: (value) => changed = value,
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('projects-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('project-title-input')),
      'آروین',
    );
    await tester.tap(find.byKey(const ValueKey('project-color-4281303277')));
    await tester.tap(find.byKey(const ValueKey('project-dialog-save')));
    await tester.pumpAndSettle();

    expect(changed, hasLength(1));
    expect(changed.single.title, 'آروین');
    expect(changed.single.colorValue, 0xFF2F80ED);
  });
}
