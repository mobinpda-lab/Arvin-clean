import 'package:arvin/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android launches Home, creates Task and opens compact calendar',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);

    final skipGuide = find.text('رد کردن');
    if (skipGuide.evaluate().isNotEmpty) {
      await tester.tap(skipGuide);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'عنوان',
      description: 'Task dialog title field',
    );
    final descriptionField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'توضیحات',
      description: 'Task dialog description field',
    );
    final tagField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'تگ',
      description: 'Task dialog tag field',
    );

    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(tagField, findsOneWidget);

    await tester.enterText(titleField, 'تست واقعی اندروید');
    await tester.enterText(
      descriptionField,
      'ثبت از مسیر Home روی Emulator',
    );
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    expect(find.text('تست واقعی اندروید'), findsOneWidget);
    expect(find.text('ثبت از مسیر Home روی Emulator'), findsOneWidget);

    // Mobile contract: Calendar opens compact in weekly mode, not full month.
    await tester.tap(find.text('تقویم'));
    await tester.pumpAndSettle();

    expect(find.text('تقویم پیگیری'), findsOneWidget);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-week-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-month-view')), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('تقویم پیگیری'))),
      TextDirection.rtl,
    );
  });
}
