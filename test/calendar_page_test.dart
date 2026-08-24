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
}
