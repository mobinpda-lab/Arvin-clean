import 'package:arvin/center_management_page.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NativeDatabase database;
  late CenterStore centers;
  late ProjectStore projects;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = NativeDatabase.memory();
    centers = CenterStore(executor: database);
    projects = ProjectStore(executor: database);
    await projects.save(<ProjectPlan>[
      ProjectPlan(id: 'project-a', title: 'پروژه الف'),
    ]);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CenterManagementPage(
          centerStore: centers,
          projectStore: projects,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('creates, searches, edits and sorts Centers', (tester) async {
    await centers.create(id: 'center-a', name: 'مرکز الف');
    await centers.create(id: 'center-b', name: 'مرکز ب');
    await pumpPage(tester);

    expect(find.text('مرکز الف'), findsOneWidget);
    expect(find.text('مرکز ب'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('center-search')), 'مرکز ب');
    await tester.pumpAndSettle();
    expect(find.text('مرکز ب'), findsOneWidget);
    expect(find.text('مرکز الف'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('center-search')));
    await tester.enterText(find.byKey(const ValueKey('center-search')), '');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('center-row-center-a')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('عملیات مرکز').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ویرایش').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'مرکز الف ویرایش');
    await tester.tap(find.text('ذخیره').last);
    await tester.pumpAndSettle();

    expect(find.text('مرکز الف ویرایش'), findsOneWidget);
  });

  testWidgets('creates a Center and archives/restores without deleting it',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('center-create')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'مرکز تازه');
    await tester.tap(find.text('ذخیره').last);
    await tester.pumpAndSettle();
    expect(find.text('مرکز تازه'), findsOneWidget);

    await tester.tap(find.byTooltip('عملیات مرکز').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بایگانی').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بایگانی').last);
    await tester.pumpAndSettle();

    expect(find.text('مرکز تازه'), findsNothing);
    expect(await centers.findById(
      (await centers.load()).single.id,
    ), isNotNull);

    await tester.tap(find.byKey(const ValueKey('center-archived-filter')));
    await tester.pumpAndSettle();
    expect(find.text('مرکز تازه'), findsOneWidget);

    await tester.tap(find.byTooltip('عملیات مرکز').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بازیابی').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بازیابی').last);
    await tester.pumpAndSettle();

    expect((await centers.load(includeArchived: false)), hasLength(1));
  });

  testWidgets('shows related Project names in Center details', (tester) async {
    await centers.create(id: 'center-a', name: 'مرکز الف');
    await centers.linkProject('center-a', 'project-a');
    await pumpPage(tester);

    await tester.tap(find.text('مرکز الف'));
    await tester.pumpAndSettle();

    expect(find.text('پروژه‌های مرتبط (1)'), findsOneWidget);
    expect(find.text('پروژه الف'), findsOneWidget);
  });

  testWidgets('manages Center to Project links through the existing store',
      (tester) async {
    await centers.create(id: 'center-a', name: 'مرکز الف');
    await pumpPage(tester);

    await tester.tap(find.text('مرکز الف'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('center-edit-project-links')));
    await tester.pumpAndSettle();

    expect(find.text('پروژه‌های «مرکز الف»'), findsOneWidget);
    await tester.tap(find.text('پروژه الف'));
    await tester.tap(find.text('ذخیره ارتباط‌ها'));
    await tester.pumpAndSettle();

    expect(
      await centers.projectIdsForCenter('center-a'),
      <String>['project-a'],
    );
  });

}
