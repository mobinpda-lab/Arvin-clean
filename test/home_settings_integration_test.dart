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

  testWidgets('Home drawer opens canonical Settings page', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'تنظیمات'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'تنظیمات'));
    await tester.pumpAndSettle();

    expect(find.text('تنظیمات'), findsOneWidget);
    expect(find.text('نمایش تاریخ فارسی'), findsOneWidget);
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);
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
    expect(find.textContaining('۱۴۰۵/۰۶/۰۴'), findsOneWidget);
  });
}
