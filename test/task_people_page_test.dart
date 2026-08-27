import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_people_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_people_page.dart';
import 'package:arvin/task_timeline_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<TaskStore> seedTask() async {
    final store = TaskStore();
    await store.save([
      Task(
        id: 'task-1',
        title: 'کار اصلی',
        description: 'توضیح محفوظ',
        tags: const ['مهم'],
        checklist: const ['مرحله یک'],
        reminderDate: DateTime(2026, 8, 30, 9),
      ),
    ]);
    return store;
  }

  testWidgets('empty People UI adds and removes a local Person explicitly',
      (tester) async {
    final store = await seedTask();
    final service = TaskPeopleService(
      store: store,
      personIdFactory: () => 'person-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskPeoplePage(taskId: 'task-1', service: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('people-empty')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('people-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('people-name-input')),
      'علی رضایی',
    );
    await tester.tap(find.byKey(const ValueKey('people-add-save')));
    await tester.pumpAndSettle();

    expect(find.text('علی رضایی'), findsOneWidget);
    var reloaded = (await store.load()).single;
    expect(reloaded.people.single.displayName, 'علی رضایی');
    expect(reloaded.description, 'توضیح محفوظ');
    expect(reloaded.tags, ['مهم']);
    expect(reloaded.checklist, ['مرحله یک']);

    await tester.tap(find.byKey(const ValueKey('people-remove-person-1')));
    await tester.pumpAndSettle();
    expect(find.text('حذف ارتباط'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('people-remove-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('علی رضایی'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('people-remove-person-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('people-remove-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('people-empty')), findsOneWidget);
    reloaded = (await store.load()).single;
    expect(reloaded.people, isEmpty);
  });

  testWidgets('cancelling add performs no write', (tester) async {
    final store = await seedTask();
    final service = TaskPeopleService(
      store: store,
      personIdFactory: () => 'person-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskPeoplePage(taskId: 'task-1', service: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('people-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('people-name-input')),
      'نباید ذخیره شود',
    );
    await tester.tap(find.byKey(const ValueKey('people-add-cancel')));
    await tester.pumpAndSettle();

    final reloaded = (await store.load()).single;
    expect(reloaded.people, isEmpty);
    expect(find.byKey(const ValueKey('people-empty')), findsOneWidget);
  });

  testWidgets('Task Timeline exposes the canonical People entry', (tester) async {
    final store = await seedTask();
    final task = (await store.load()).single;

    await tester.pumpWidget(
      MaterialApp(home: TaskTimelinePage(task: task)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('timeline-open-people')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('timeline-open-people')));
    await tester.pumpAndSettle();

    expect(find.text('افراد مرتبط'), findsOneWidget);
    expect(find.byKey(const ValueKey('people-empty')), findsOneWidget);
  });
}
