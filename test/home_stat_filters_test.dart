import 'dart:convert';

import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'time',
          'title': 'کار زمان‌دار',
          'dueDate': '2030-01-01T08:00:00.000',
        },
        {
          'id': 'project',
          'title': 'کار پروژه',
          'tags': ['مهم'],
          'category': 'توسعه',
        },
        {
          'id': 'multi',
          'title': 'کار چندبرچسبی',
          'tags': ['مهم', 'فوری'],
        },
      ]),
    });
  });

  testWidgets('Home exposes exactly four grouping buttons and no legacy selectors',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    for (final key in const [
      'home-group-time',
      'home-group-projects',
      'home-group-categories',
      'home-group-labels',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('home-group-mode-selector')), findsNothing);
    expect(find.byKey(const ValueKey('home-sort-selector')), findsNothing);
    expect(find.text('کارهای من'), findsNothing);
    expect(find.text('مشاهده همه'), findsNothing);
  });

  testWidgets('selecting grouping buttons changes the same Home projection',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-group-categories')));
    await tester.pumpAndSettle();
    expect(find.text('توسعه'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-group-labels')));
    await tester.pumpAndSettle();
    expect(find.text('مهم'), findsWidgets);
    expect(find.text('فوری'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('home-group-projects')));
    await tester.pumpAndSettle();
    expect(find.text('بدون پروژه'), findsOneWidget);
  });

  testWidgets('grouping changes do not mutate canonical task storage',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString('arvin.tasks');

    for (final key in const [
      'home-group-projects',
      'home-group-categories',
      'home-group-labels',
      'home-group-time',
    ]) {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
    }

    expect(prefs.getString('arvin.tasks'), before);
  });
}
