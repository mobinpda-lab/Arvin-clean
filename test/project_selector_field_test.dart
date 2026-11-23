import 'package:arvin/models/goal_project.dart';
import 'package:arvin/widgets/project_selector_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders active projects as colored options and supports unassigned',
      (tester) async {
    String? selected = 'work';
    final projects = [
      ProjectPlan(id: 'work', title: 'کاری', colorValue: 0xFF2F80ED),
      ProjectPlan(id: 'personal', title: 'شخصی', colorValue: 0xFF27AE60),
      ProjectPlan(
        id: 'archived',
        title: 'قدیمی',
        colorValue: 0xFF9B51E0,
        isArchived: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ProjectSelectorField(
              projects: projects,
              selectedProjectId: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('کاری'), findsOneWidget);
    expect(find.text('شخصی'), findsOneWidget);
    expect(find.text('قدیمی'), findsNothing);
    expect(find.text('بدون پروژه'), findsOneWidget);
    expect(find.byType(Chip), findsNothing);

    await tester.tap(find.byKey(const ValueKey('project-selector-personal')));
    await tester.pump();
    expect(selected, 'personal');

    await tester.tap(find.byKey(const ValueKey('project-selector-unassigned')));
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets('already-selected archived project stays visible during edit',
      (tester) async {
    final projects = [
      ProjectPlan(
        id: 'archived',
        title: 'قدیمی',
        isArchived: true,
        itemIds: const ['task-1'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectSelectorField(
            projects: projects,
            selectedProjectId: 'archived',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('قدیمی (بایگانی‌شده)'), findsOneWidget);
    expect(find.byKey(const ValueKey('project-selector-archived')), findsOneWidget);
  });
}
