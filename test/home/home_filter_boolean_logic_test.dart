import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
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
    'Center filters support multi-select, constrain descendants and clear invalid descendants',
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
      final centerAInitial = find.byKey(const ValueKey('multi-select-option-center-a'));
      final centerBInitial = find.byKey(const ValueKey('multi-select-option-center-b'));
      await tester.tap(centerAInitial);
      await tester.ensureVisible(centerBInitial);
      await tester.pumpAndSettle();
      await tester.tap(centerBInitial);
      await tester.tap(find.text('تأیید / اعمال فیلتر'));
      await tester.pumpAndSettle();
      expect(find.text('فعالیت مرکز الف'), findsOneWidget);
      expect(find.text('فعالیت مرکز ب'), findsOneWidget);

      final projectFilter = find.byKey(const ValueKey('home-filter-card-project'));
      await tester.ensureVisible(projectFilter);
      await tester.tap(projectFilter);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('multi-select-option-project-a')), findsOneWidget);
      expect(find.byKey(const ValueKey('multi-select-option-project-b')), findsOneWidget);
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
      final centerAOption = find.byKey(const ValueKey('multi-select-option-center-a'));
      await tester.ensureVisible(centerAOption);
      await tester.tap(centerAOption);
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


  testWidgets('Project filter supports multiple projects and clears independently of Category',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final taskStore = TaskStore(executor: database);
    final due = DateTime(2030, 1, 1, 12);
    await taskStore.save([
      Task(id: 'project-task-a', title: 'فعالیت پروژه الف', centerId: 'center-shared',
          category: 'دسته مشترک', dueDate: due),
      Task(id: 'project-task-b', title: 'فعالیت پروژه ب', centerId: 'center-shared',
          category: 'دسته مشترک', dueDate: due),
      Task(id: 'project-task-c', title: 'فعالیت پروژه ج', centerId: 'center-shared',
          category: 'دسته دیگر', dueDate: due),
    ]);
    final centerStore = CenterStore(executor: database);
    await centerStore.create(id: 'center-shared', name: 'مرکز مشترک');
    final projectStore = ProjectStore(executor: database);
    await projectStore.save([
      ProjectPlan(id: 'project-a', title: 'پروژه الف', centerId: 'center-shared',
          itemIds: const ['project-task-a']),
      ProjectPlan(id: 'project-b', title: 'پروژه ب', centerId: 'center-shared',
          itemIds: const ['project-task-b']),
      ProjectPlan(id: 'project-c', title: 'پروژه ج', centerId: 'center-shared',
          itemIds: const ['project-task-c']),
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

    final projectFilter = find.byKey(const ValueKey('home-filter-card-project'));
    await tester.ensureVisible(projectFilter);
    await tester.tap(projectFilter);
    await tester.pumpAndSettle();
    final projectA = find.byKey(const ValueKey('multi-select-option-project-a'));
    final projectB = find.byKey(const ValueKey('multi-select-option-project-b'));
    await tester.ensureVisible(projectA);
    await tester.tap(projectA);
    await tester.pumpAndSettle();
    await tester.ensureVisible(projectB);
    await tester.tap(projectB);
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    expect(find.text('فعالیت پروژه الف'), findsOneWidget);
    expect(find.text('فعالیت پروژه ب'), findsOneWidget);
    expect(find.text('فعالیت پروژه ج'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('task-card-title-project-task-a')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-detail-back')));
    await tester.pumpAndSettle();
    expect(find.text('فعالیت پروژه الف'), findsOneWidget);
    expect(find.text('فعالیت پروژه ب'), findsOneWidget);
    expect(find.text('فعالیت پروژه ج'), findsNothing);

    final categoryFilter = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryFilter);
    await tester.tap(categoryFilter);
    await tester.pumpAndSettle();
    final sharedCategory = find.byKey(const ValueKey('multi-select-option-دسته مشترک'));
    await tester.ensureVisible(sharedCategory);
    await tester.tap(sharedCategory);
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    final removeFilterButtons = find.byTooltip('حذف فیلتر');
    expect(removeFilterButtons, findsNWidgets(2));
    await tester.ensureVisible(removeFilterButtons.first);
    await tester.tap(removeFilterButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('فعالیت پروژه الف'), findsOneWidget);
    expect(find.text('فعالیت پروژه ب'), findsOneWidget);
    expect(find.text('فعالیت پروژه ج'), findsNothing);
    expect(find.byTooltip('حذف فیلتر'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
