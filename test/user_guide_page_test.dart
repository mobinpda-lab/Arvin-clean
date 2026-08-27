import 'package:arvin/user_guide_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('user guide shows quick start and core help sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UserGuidePage()),
    );

    expect(find.text('راهنمای استفاده از آروین'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('شروع سریع در ۳۰ ثانیه'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('شروع سریع در ۳۰ ثانیه'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ساخت کار جدید'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ساخت کار جدید'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ثبت سریع'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ثبت سریع'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('پشتیبان‌گیری و بازیابی'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تنظیمات'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('تنظیمات'), findsOneWidget);
  });
}
