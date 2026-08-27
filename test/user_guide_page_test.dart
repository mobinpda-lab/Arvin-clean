import 'package:arvin/user_guide_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('user guide shows visual walkthrough and core help sections',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UserGuidePage()),
    );

    expect(find.text('راهنمای استفاده از آروین'), findsOneWidget);
    expect(find.text('راهنمای تصویری صفحه اصلی'), findsOneWidget);
    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('شروع سریع در ۳۰ ثانیه'),
      350,
      scrollable: scrollable,
    );
    expect(find.text('شروع سریع در ۳۰ ثانیه'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ساخت کار جدید'),
      350,
      scrollable: scrollable,
    );
    expect(find.text('ساخت کار جدید'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ثبت سریع'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('ثبت سریع'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('پشتیبان‌گیری و بازیابی'),
      350,
      scrollable: scrollable,
    );
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تنظیمات'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('تنظیمات'), findsOneWidget);
  });
}
