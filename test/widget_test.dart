import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Arvin starts with the canonical centered Home identity',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('آروین'), findsOneWidget);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
  });

  testWidgets('Home exposes the canonical workflow controls', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('دسته'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('بیشتر'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-more-report'), skipOffstage: false),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const ValueKey('home-more-report')), findsOneWidget);
    expect(find.text('گزارش‌ها'), findsOneWidget);
    expect(find.text('دسته‌ها و برچسب‌ها'), findsNothing);
    expect(find.text('پشتیبان‌گیری'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsOneWidget);
  });

  testWidgets('HomePage loads legacy storage through the unified reader',
      (tester) async {
    final legacyTask = {
      'id': 'legacy-1',
      'title': 'کار مهاجرتی',
      'description': 'داده قدیمی باید در Home دیده شود',
      'followUpDate': '2026-08-20T10:30:00.000',
      'tags': ['مهاجرت'],
      'archived': false,
      'trashed': false,
      'completed': false,
    };
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([legacyTask]),
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار مهاجرتی'), findsOneWidget);
    expect(find.text('داده قدیمی باید در Home دیده شود'), findsNothing);
  });

  testWidgets('HomePage shows the empty-state message after loading',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کاری برای نمایش وجود ندارد'), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('دسته'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
  });
}
