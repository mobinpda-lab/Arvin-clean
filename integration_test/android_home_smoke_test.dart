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

    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);

    final skipGuide = find.text('رد کردن');
    if (skipGuide.evaluate().isNotEmpty) {
      await tester.tap(skipGuide);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    final titleField = find.byKey(const ValueKey('task-editor-title'));
    final descriptionField =
        find.byKey(const ValueKey('task-editor-description'));
    final tagField = find.byKey(const ValueKey('task-editor-tag'));
    final followUpToggle =
        find.byKey(const ValueKey('task-editor-followup-enabled'));

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(tagField, findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-block')), findsOneWidget);
    expect(followUpToggle, findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-date')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-time')), findsNothing);

    await tester.tap(followUpToggle);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-editor-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-time')), findsOneWidget);

    await tester.enterText(titleField, 'تست واقعی اندروید');
    await tester.enterText(
      descriptionField,
      'ثبت از مسیر Home روی Emulator',
    );
    await tester.enterText(tagField, 'آزمایش');
    await tester.tap(find.byKey(const ValueKey('task-editor-add-tag')));
    await tester.pumpAndSettle();
    expect(find.text('آزمایش'), findsOneWidget);

    final saveButton = find.byKey(const ValueKey('task-editor-save'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsNothing);
    expect(find.text('تست واقعی اندروید'), findsOneWidget);
    expect(find.text('ثبت از مسیر Home روی Emulator'), findsOneWidget);

    // Binding mobile contract: Calendar opens compact in weekly mode.
    final calendarNav = find.text('تقویم');
    await tester.ensureVisible(calendarNav);
    await tester.pumpAndSettle();
    await tester.tap(calendarNav);
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
