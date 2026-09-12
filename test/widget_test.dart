import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Arvin starts with the approved Bismillah above the Persian title',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'), findsNothing);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const ValueKey('home-bismillah')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-title-block')), findsOneWidget);
  });

  testWidgets('HomePage exposes the canonical workflow controls', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stat-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stat-active')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stat-done')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stat-overdue')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-scope-all')), findsNothing);
    expect(find.byKey(const ValueKey('home-sort-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-sort-direction')), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'خانه'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'تقویم'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-more-my-tasks')), findsOneWidget);
    expect(find.text('پشتیبان‌گیری'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-more-my-tasks')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-my-tasks-all')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-my-tasks-without-followup')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-my-tasks-today')), findsOneWidget);
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
    expect(find.text('داده قدیمی باید در Home دیده شود'), findsOneWidget);
    expect(find.text('مهاجرت'), findsOneWidget);
    expect(find.textContaining('پیگیری: ۱۴۰۵/۰۵/۲۹'), findsOneWidget);
  });

  testWidgets('HomePage shows the empty-state message after loading',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کاری برای نمایش وجود ندارد'), findsOneWidget);
    expect(find.text('کل'), findsOneWidget);
    expect(find.text('انجام‌شده'), findsOneWidget);
    expect(find.text('عقب‌افتاده'), findsWidgets);
  });
}
