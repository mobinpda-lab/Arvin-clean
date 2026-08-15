import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Arvin starts with the final Persian title', (tester) async {
    await tester.pumpWidget(const ArvinApp());

    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'), findsOneWidget);
    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
  });

  testWidgets('HomePage exposes the current legacy workflow controls',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'فعال'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'بایگانی'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'سطل زباله'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);
    expect(find.byTooltip('پشتیبان'), findsOneWidget);
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
