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

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, isTrue);
    expect(appBar.toolbarHeight, 78);

    final titlePadding = appBar.title! as Padding;
    expect(titlePadding.padding, const EdgeInsets.only(top: 12));
    final title = titlePadding.child as Column;
    expect(title.children, hasLength(3));
    expect((title.children.first as Text).data, 'بسم الله الرحمن الرحیم');
    expect(title.children[1], isA<SizedBox>());
    expect(
      (title.children[2] as Text).data,
      'مدیریت کارها و پیگیری آروین',
    );
  });

  testWidgets('HomePage exposes the corrected workflow controls', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'فعال'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'بایگانی'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'سطل زباله'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);
    expect(find.byTooltip('پشتیبان'), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);
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
    expect(find.text('عقب‌افتاده'), findsOneWidget);
  });
}
