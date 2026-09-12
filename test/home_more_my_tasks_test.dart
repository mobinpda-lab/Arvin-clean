import 'dart:convert';

import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final today = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'plain',
          'title': 'کار بدون پیگیری',
          'category': 'اداری',
          'completed': false,
        },
        {
          'id': 'followup',
          'title': 'کار پیگیری دار',
          'category': 'مشتری',
          'followUpEnabled': true,
          'followUpDate': today.toIso8601String(),
          'completed': false,
        },
        {
          'id': 'today',
          'title': 'کار امروز',
          'dueDate': DateTime(today.year, today.month, today.day, 12)
              .toIso8601String(),
          'completed': false,
        },
        {
          'id': 'done',
          'title': 'کار تمام شده',
          'completed': true,
        },
      ]),
    });
  });

  Future<void> openMyTasks(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-more-my-tasks')));
    await tester.pumpAndSettle();
  }

  testWidgets('My Tasks filters live under More instead of visible Home',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کارهای من'), findsNothing);

    await openMyTasks(tester);

    expect(find.text('کارهای من'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-my-tasks-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-my-tasks-today')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-my-tasks-followup')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-my-tasks-without-followup')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-my-tasks-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-my-tasks-incomplete')),
      findsOneWidget,
    );
    expect(find.text('دسته‌ها'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-my-tasks-category-اداری')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-my-tasks-category-مشتری')),
      findsOneWidget,
    );
  });

  testWidgets('without-follow-up and category selections filter Home',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await openMyTasks(tester);
    await tester.tap(
      find.byKey(const ValueKey('home-my-tasks-without-followup')),
    );
    await tester.pumpAndSettle();

    expect(find.text('کار بدون پیگیری'), findsOneWidget);
    expect(find.text('کار پیگیری دار'), findsNothing);

    await openMyTasks(tester);
    await tester.tap(
      find.byKey(const ValueKey('home-my-tasks-category-اداری')),
    );
    await tester.pumpAndSettle();

    expect(find.text('کار بدون پیگیری'), findsOneWidget);
    expect(find.text('کار امروز'), findsNothing);
    expect(find.text('کار تمام شده'), findsNothing);
    expect(find.byKey(const ValueKey('home-clear-task-filter')), findsOneWidget);
  });

  testWidgets('Today under My Tasks uses canonical dueDate projection',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await openMyTasks(tester);
    await tester.tap(find.byKey(const ValueKey('home-my-tasks-today')));
    await tester.pumpAndSettle();

    expect(find.text('کار امروز'), findsOneWidget);
    expect(find.text('کار پیگیری دار'), findsNothing);
    expect(find.text('کار بدون پیگیری'), findsNothing);
  });
}
