import 'dart:convert';

import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Today drawer shows only active canonical tasks due today',
      (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);
    final tomorrow = today.add(const Duration(days: 1));

    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'today',
          'title': 'کار امروز',
          'followUpEnabled': true,
          'followUpDate': today.toIso8601String(),
        },
        {
          'id': 'tomorrow',
          'title': 'کار فردا',
          'followUpEnabled': true,
          'followUpDate': tomorrow.toIso8601String(),
        },
        {
          'id': 'completed',
          'title': 'کار انجام‌شده امروز',
          'completed': true,
          'followUpEnabled': true,
          'followUpDate': today.toIso8601String(),
        },
      ]),
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'امروز'));
    await tester.pumpAndSettle();

    expect(find.text('کار امروز'), findsOneWidget);
    expect(find.text('کار فردا'), findsNothing);
    expect(find.text('کار انجام‌شده امروز'), findsNothing);
  });

  testWidgets('Today drawer has a dedicated empty state', (tester) async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'امروز'));
    await tester.pumpAndSettle();

    expect(find.text('کاری برای امروز وجود ندارد'), findsOneWidget);
  });

  testWidgets('About drawer opens Flutter built-in Arvin about dialog',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'درباره آروین'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutDialog), findsOneWidget);
    expect(find.text('آروین'), findsWidgets);
    expect(find.text('مدیریت کارها و پیگیری‌ها'), findsOneWidget);
  });
}
