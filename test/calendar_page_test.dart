import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('shows reminders for the selected day', (tester) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            reminders: [
              CalendarReminder(
                id: '1',
                title: 'تماس با مشتری',
                date: day,
              ),
              CalendarReminder(
                id: '2',
                title: 'جلسه تیم',
                date: day.add(const Duration(days: 1)),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('جلسه تیم'), findsNothing);
  });

  testWidgets('shows empty state when selected day has no reminder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(reminders: <CalendarReminder>[]),
        ),
      ),
    );

    expect(
      find.text('برای این روز یادآوری ثبت نشده است'),
      findsOneWidget,
    );
  });
  testWidgets('does not show a synthetic midnight for all-day reminders',
      (tester) async {
    final holiday = DateTime(2026, 3, 21);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: holiday,
            reminders: [
              CalendarReminder(
                id: 'holiday',
                title: 'نوروز',
                date: holiday,
                isAllDay: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('نوروز'), findsOneWidget);
    expect(find.textContaining('رویداد تمام‌روز'), findsOneWidget);
    expect(find.textContaining('ساعت ۰۰:۰۰'), findsNothing);
    expect(find.textContaining('در انتظار پیگیری'), findsNothing);
  });

  testWidgets('expands reminder actions and routes applicable callbacks',
      (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    final reminder = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری قرارداد',
      date: day,
    );
    var completed = 0;
    var snoozed = 0;
    var edited = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [reminder],
          onCompleteReminder: (_) async => completed++,
          onSnoozeReminder: (_) async => snoozed++,
          onEditReminder: (_) async => edited++,
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('reminder-card-followup:task-1:fu-1')),
    );
    await tester.pump();

    expect(find.text('انجام شد'), findsOneWidget);
    expect(find.text('تعویق'), findsOneWidget);
    expect(find.text('ویرایش'), findsOneWidget);
    expect(find.text('تبدیل به کار'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('reminder-complete-followup:task-1:fu-1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('reminder-snooze-followup:task-1:fu-1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('reminder-edit-followup:task-1:fu-1')),
    );
    await tester.pump();

    expect(completed, 1);
    expect(snoozed, 1);
    expect(edited, 1);
  });

}
