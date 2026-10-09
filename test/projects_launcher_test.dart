import 'package:arvin/models/goal_project.dart';
import 'package:arvin/projects_launcher.dart';
import 'package:arvin/services/project_plan_codec.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

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

    var restored = await store.load();
    expect(
      restored.map((project) => project.title),
      containsAll(['پروژه موجود', 'پروژه جدید']),
    );

    // Rename and recolor the newly created Project through the same Settings
    // launcher path, then verify the committed values in canonical storage.
    await tester.tap(find.byTooltip('ویرایش').at(1));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('project-title-input')),
      'پروژه ویرایش‌شده',
    );
    await tester.tap(find.byKey(const ValueKey('project-color-4281303277')));
    await tester.tap(find.byKey(const ValueKey('project-dialog-save')));
    await tester.pumpAndSettle();

    restored = await store.load();
    final edited = restored.singleWhere((project) => project.title == 'پروژه ویرایش‌شده');
    expect(edited.colorValue, 0xFF2F80ED);

    // Reopen the management surface to prove it reads the durable state,
    // rather than merely retaining the previous widget's in-memory list.
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpWidget(MaterialApp(home: ProjectsLauncher(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('پروژه ویرایش‌شده'), findsOneWidget);
  });
}
