import 'package:arvin/models/goal_project.dart';
import 'package:arvin/projects_launcher.dart';
import 'package:arvin/services/project_plan_codec.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
  });

  tearDown(() async => database.close());

  testWidgets('loads persisted Projects and saves lifecycle changes', (tester) async {
    final store = ProjectStore(
      codec: const ProjectPlanCodec(),
      executor: database,
    );
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
    expect(
      restored.map((project) => project.title),
      containsAll(['پروژه موجود', 'پروژه جدید']),
    );
  });
}
