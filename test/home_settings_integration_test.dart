import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saved dark theme is applied by the real app shell', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.settings.themeMode': 'dark',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final homeContext = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(homeContext).brightness, Brightness.dark);
  });

  testWidgets('Home More opens canonical Settings page', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-more-task-filters')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تنظیمات'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('تنظیمات'), findsOneWidget);

    await tester.tap(find.text('تنظیمات'));
    await tester.pumpAndSettle();

    expect(find.text('تنظیمات'), findsOneWidget);
    expect(find.text('نمایش تاریخ فارسی'), findsOneWidget);
    expect(find.text('حرکت کارت‌ها'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('پشتیبان‌گیری و بازیابی'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);
  });

  testWidgets('Home keeps user-visible dates Jalali when legacy preference is off',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.settings.usePersianDate': false,
      'arvin.tasks':
          '[{"id":"dated-off","title":"کار شمسی اجباری","followUpEnabled":true,"followUpDate":"2026-08-26T10:00:00.000","dueDate":"2026-08-26T12:00:00.000"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار شمسی اجباری'), findsOneWidget);
    expect(find.textContaining('۱۴۰۵/۰۶/۰۴'), findsWidgets);
    expect(find.textContaining('2026/08/26'), findsNothing);
  });

  testWidgets('Persian date preference changes real Home follow-up rendering',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.settings.usePersianDate': true,
      'arvin.tasks':
          '[{"id":"dated","title":"کار تاریخ‌دار","followUpEnabled":true,"followUpDate":"2026-08-26T10:00:00.000"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار تاریخ‌دار'), findsOneWidget);
    expect(find.textContaining('2026/08/26'), findsNothing);
  });
}
