import 'package:arvin/models/goal_project.dart';
import 'package:arvin/projects_launcher.dart';
import 'package:arvin/services/project_plan_codec.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('loads persisted Projects and saves lifecycle changes', (tester) async {
    final store = ProjectStore(codec: const ProjectPlanCodec());
    await store.save([
      ProjectPlan(
        id: 'existing',
        title: 'پروژه موجود',
        colorValue: 0xFF27AE60,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: ProjectsLauncher(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('پروژه موجود'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('projects-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('project-title-input')),
      'پروژه جدید',
    );
    await tester.tap(find.byKey(const ValueKey('project-dialog-save')));
    await tester.pumpAndSettle();

    final restored = await store.load();
    expect(restored.map((project) => project.title), containsAll(['پروژه موجود', 'پروژه جدید']));
  });
}
