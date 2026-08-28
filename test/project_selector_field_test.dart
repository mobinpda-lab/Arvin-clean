import 'package:arvin/models/goal_project.dart';
import 'package:arvin/widgets/project_selector_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders projects as colored options and supports unassigned',
      (tester) async {
    String? selected = 'work';
    final projects = [
      ProjectPlan(
        id: 'work',
        title: 'کاری',
        colorValue: 0xFF2F80ED,
      ),
      ProjectPlan(
        id: 'personal',
        title: 'شخصی',
        colorValue: 0xFF27AE60,
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
    expect(find.text('بدون پروژه'), findsOneWidget);
    expect(find.byType(Chip), findsNothing);

    await tester.tap(find.byKey(const ValueKey('project-selector-personal')));
    await tester.pump();
    expect(selected, 'personal');

    await tester.tap(find.byKey(const ValueKey('project-selector-unassigned')));
    await tester.pump();
    expect(selected, isNull);
  });
}
