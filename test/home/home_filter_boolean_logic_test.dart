import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/models/arvin_center.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('Home filters combine OR within each dimension and AND across dimensions', (tester) async {
    final now = IranClock.now();
    // Use the active Iran date and a late same-day time. A stale fixed date
    // turns this filter-only fixture into an unrelated overdue-data fixture.
    final due = DateTime(now.year, now.month, now.day, 23, 59).toIso8601String();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'arvin.tasks': '''
[
  {"id":"personal-home","title":"شخصی خانه","dueDate":"$due","category":"شخصی","tags":["خانه"]},
  {"id":"work-home","title":"کاری خانه","dueDate":"$due","category":"کاری","tags":["خانه"]},
  {"id":"personal-office","title":"شخصی اداری","dueDate":"$due","category":"شخصی","tags":["اداری"]},
  {"id":"work-office","title":"کاری اداری","dueDate":"$due","category":"کاری","tags":["اداری"]},
  {"id":"other-home","title":"سایر خانه","dueDate":"$due","category":"سایر","tags":["خانه"]},
  {"id":"personal-other","title":"شخصی متفرقه","dueDate":"$due","category":"شخصی","tags":["متفرقه"]}
]
''',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final categoryFilter = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryFilter);
    await tester.tap(categoryFilter);
    await tester.pumpAndSettle();
    final personalOption = find.byKey(const ValueKey('multi-select-option-شخصی'));
    await tester.ensureVisible(personalOption);
    await tester.tap(personalOption);
    await tester.pumpAndSettle();
    final workOption = find.byKey(const ValueKey('multi-select-option-کاری'));
    await tester.ensureVisible(workOption);
    await tester.tap(workOption);
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    final tagFilter = find.byKey(const ValueKey('home-filter-card-tags'));
    await tester.ensureVisible(tagFilter);
    await tester.tap(tagFilter);
    await tester.pumpAndSettle();
    final homeOption = find.byKey(const ValueKey('multi-select-option-خانه'));
    await tester.ensureVisible(homeOption);
    await tester.tap(homeOption);
    await tester.pumpAndSettle();
    final officeOption = find.byKey(const ValueKey('multi-select-option-اداری'));
    await tester.ensureVisible(officeOption);
    await tester.tap(officeOption);
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    expect(find.text('شخصی خانه'), findsOneWidget);
    expect(find.text('کاری خانه'), findsOneWidget);
    expect(find.text('شخصی اداری'), findsOneWidget);
    expect(find.text('کاری اداری'), findsOneWidget);
    expect(find.text('سایر خانه'), findsNothing);
    expect(find.text('شخصی متفرقه'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Center limits Project options, Project limits Category options, and parent changes clear invalid descendants',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final database = NativeDatabase.memory();
      addTearDown(database.close);
      final taskStore = TaskStore(executor: database);
      await taskStore.save([
        Task(
          id: 'task-center-a',
          title: 'فعالیت مرکز الف',
          centerId: 'center-a',
          category: 'دسته الف',
        ),
        Task(
          id: 'task-center-b',
          title: 'فعالیت مرکز ب',
          centerId: 'center-b',
          category: 'دسته ب',
        ),
      ]);
      final centerStore = CenterStore(executor: database);
      await centerStore.create(id: 'center-a', name: 'مرکز الف');
      await centerStore.create(id: 'center-b', name: 'مرکز ب');
      final projectStore = ProjectStore(executor: database);
      await projectStore.save([
        ProjectPlan(
          id: 'project-a',
          title: 'پروژه الف',
          centerId: 'center-a',
          itemIds: const ['task-center-a'],
        ),
        ProjectPlan(
          id: 'project-b',
          title: 'پروژه ب',
          centerId: 'center-b',
          itemIds: const ['task-center-b'],
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: HomePage(
              taskStore: taskStore,
              projectStore: projectStore,
              centerStore: centerStore,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final centerFilter = find.byKey(const ValueKey('home-filter-card-center'));
      await tester.ensureVisible(centerFilter);
      await tester.tap(centerFilter);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('multi-select-option-center-a')));
      await tester.tap(find.text('تأیید / اعمال فیلتر'));
      await tester.pumpAndSettle();

      final projectFilter = find.byKey(const ValueKey('home-filter-card-project'));
      await tester.ensureVisible(projectFilter);
      await tester.tap(projectFilter);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('multi-select-option-project-a')), findsOneWidget);
      expect(find.byKey(const ValueKey('multi-select-option-project-b')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('multi-select-option-project-a')));
      await tester.tap(find.text('تأیید / اعمال فیلتر'));
      await tester.pumpAndSettle();

      final categoryFilter = find.byKey(const ValueKey('home-filter-card-category'));
      await tester.ensureVisible(categoryFilter);
      await tester.tap(categoryFilter);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('multi-select-option-دسته الف')), findsOneWidget);
      expect(find.byKey(const ValueKey('multi-select-option-دسته ب')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('multi-select-option-دسته الف')));
      await tester.tap(find.text('تأیید / اعمال فیلتر'));
      await tester.pumpAndSettle();
      expect(find.text('فعالیت مرکز الف'), findsOneWidget);
      expect(find.text('فعالیت مرکز ب'), findsNothing);

      await tester.ensureVisible(centerFilter);
      await tester.tap(centerFilter);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('multi-select-option-center-a')));
      await tester.tap(find.byKey(const ValueKey('multi-select-option-center-b')));
      await tester.tap(find.text('تأیید / اعمال فیلتر'));
      await tester.pumpAndSettle();

      expect(find.text('فعالیت مرکز الف'), findsNothing);
      expect(find.text('فعالیت مرکز ب'), findsOneWidget);
      await tester.ensureVisible(projectFilter);
      await tester.tap(projectFilter);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('multi-select-option-project-a')), findsNothing);
      expect(find.byKey(const ValueKey('multi-select-option-project-b')), findsOneWidget);
      await tester.tap(find.text('لغو'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(categoryFilter);
      await tester.tap(categoryFilter);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('multi-select-option-دسته الف')), findsNothing);
      expect(find.byKey(const ValueKey('multi-select-option-دسته ب')), findsOneWidget);
      await tester.tap(find.text('لغو'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

}
