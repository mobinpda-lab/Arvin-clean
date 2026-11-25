import 'dart:async';
import 'package:arvin/services/arvin_async_trace.dart';
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

  Future<T> pumpFuture<T>(
    WidgetTester tester,
    Future<T> Function() operation,
  ) async {
    final completion = Completer<T>();
    operation().then(
      completion.complete,
      onError: (Object error, StackTrace stackTrace) {
        completion.completeError(error, stackTrace);
      },
    );
    completion.future.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    for (var frame = 0; !completion.isCompleted && frame < 1200; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (!completion.isCompleted) {
      throw TimeoutException(
        'Center database operation did not complete after 1200 frames',
        const Duration(seconds: 20),
      );
    }
    return completion.future;
  }

  Future<void> pumpFutureVoid(
    WidgetTester tester,
    Future<void> Function() operation,
  ) async {
    final completion = Completer<void>();
    operation().then(
      (_) => completion.complete(),
      onError: (Object error, StackTrace stackTrace) {
        completion.completeError(error, stackTrace);
      },
    );
    completion.future.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    for (var frame = 0; !completion.isCompleted && frame < 1200; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (!completion.isCompleted) {
      throw TimeoutException(
        'Center database operation did not complete after 1200 frames',
        const Duration(seconds: 20),
      );
    }
    await completion.future;
  }

  Future<void> pumpPage(WidgetTester tester) async {
    final loaded = Completer<void>();
    await arvinTraceOperation<void>('center.test_pump', () async {
      await tester.pumpWidget(MaterialApp(home: CenterManagementPage(
        centerStore: centers,
        projectStore: projects,
        onLoadComplete: () {
          if (!loaded.isCompleted) loaded.complete();
        },
      )));
    });
    completion:
    for (var frame = 0; !loaded.isCompleted && frame < 1200; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (!loaded.isCompleted) {
      throw TimeoutException(
        'Center page did not report load completion after 1200 frames',
        const Duration(seconds: 20),
      );
    }
    await loaded.future;
    await tester.pumpAndSettle();
  }

  test('concurrent CenterStore reads share one initialization path', () async {
    await centers.create(id: 'center-concurrent', name: 'مرکز هم‌زمان');

    final results = await Future.wait([
      centers.load(),
      centers.search('مرکز هم‌زمان'),
      centers.projectIdsForCenter('center-concurrent'),
      centers.centerIdsForProject('project-a'),
    ]);

    expect((results[0] as List).map((center) => center.id), contains('center-concurrent'));
    expect((results[1] as List).map((center) => center.id), ['center-concurrent']);
    expect(results[2], isEmpty);
    expect(results[3], isEmpty);
  });

  testWidgets('creates, searches, edits and sorts Centers', (tester) async {
    await pumpFuture(tester, () => centers.create(id: 'center-a', name: 'مرکز الف'));
    await pumpFuture(tester, () => centers.create(id: 'center-b', name: 'مرکز ب'));
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
    await tester.tap(find.text('ویرایش').last));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'مرکز الف ویرایش');
    await tester.tap(find.text('ذخیره').last);
    await tester.pumpAndSettle();

    expect(find.text('مرکز الف ویرایش'), findsOneWidget);
  });

  testWidgets('creates a Center and archives/restores without deleting it',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('center-create'))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'مرکز تازه');
    await tester.tap(find.text('ذخیره').last);
    await tester.pumpAndSettle();
    expect(find.text('مرکز تازه'), findsOneWidget);

    await tester.tap(find.byTooltip('عملیات مرکز').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بایگانی').last));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بایگانی').last));
    await tester.pumpAndSettle();

    expect(find.text('مرکز تازه'), findsNothing);
    final loadedCenters = await pumpFuture(tester, () => centers.load());
    expect(
      await pumpFuture(tester, () => centers.findById(loadedCenters.single.id)),
      isNotNull,
    );

    await tester.tap(find.byKey(const ValueKey('center-archived-filter')));
    await tester.pumpAndSettle();
    expect(find.text('مرکز تازه'), findsOneWidget);

    await tester.tap(find.byTooltip('عملیات مرکز').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('بازیابی').last));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بازیابی').last));
    await tester.pumpAndSettle();

    expect(
      await pumpFuture(tester, () => centers.load(includeArchived: false)),
      hasLength(1),
    );
  });

  testWidgets('shows related Project names in Center details', (tester) async {
    await pumpFuture(tester, () => centers.create(id: 'center-a', name: 'مرکز الف'));
    await pumpFutureVoid(tester, () => centers.linkProject('center-a', 'project-a'));
    await pumpPage(tester);

    await tester.tap(find.text('مرکز الف')));
    await tester.pumpAndSettle();

    expect(find.text('پروژه‌های مرتبط (1)'), findsOneWidget);
    expect(find.text('پروژه الف'), findsOneWidget);
  });

  testWidgets('manages Center to Project links through the existing store',
      (tester) async {
    await pumpFuture(tester, () => centers.create(id: 'center-a', name: 'مرکز الف'));
    await pumpPage(tester);

    await tester.tap(find.text('مرکز الف')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('center-edit-project-links'))));
    await tester.pumpAndSettle();

    expect(find.text('پروژه‌های «مرکز الف»'), findsOneWidget);
    await tester.tap(find.text('پروژه الف'));
    await tester.tap(find.text('ذخیره ارتباط‌ها'));
    await tester.pumpAndSettle();

    expect(
      await pumpFuture(tester, () => centers.projectIdsForCenter('center-a')),
      <String>['project-a'],
    );
  });

}
