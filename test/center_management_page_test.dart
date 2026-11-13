import 'package:arvin/center_management_page.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Center Management confirms and deletes an unreferenced Center', (tester) async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final store = CenterStore(executor: database);
    await store.create(id: 'center-delete-ui', name: 'مرکز آزمایشی');

    await tester.pumpWidget(
      MaterialApp(home: CenterManagementPage(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('center-delete-center-delete-ui')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('center-delete-confirm')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('center-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('center-row-center-delete-ui')), findsNothing);
    expect(await store.load(), isEmpty);
  });

  testWidgets('Center Management blocks deletion while Projects depend on a Center', (tester) async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final centers = CenterStore(executor: database);
    await centers.create(id: 'center-with-project', name: 'مرکز وابسته');
    await ProjectStore(executor: database).save([
      ProjectPlan(
        id: 'dependent-project',
        title: 'پروژه وابسته',
        centerId: 'center-with-project',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: CenterManagementPage(store: centers)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('center-delete-center-with-project')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('center-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('center-row-center-with-project')), findsOneWidget);
    expect(find.textContaining('1 پروژه وابسته است'), findsOneWidget);
    expect((await centers.load()).single.id, 'center-with-project');
  });
}
