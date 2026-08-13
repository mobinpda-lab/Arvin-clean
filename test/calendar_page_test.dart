import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('shows reminders for the selected day', (tester) async {
    final selectedDay = DateTime(2026, 8, 13, 10, 30);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: selectedDay,
            reminders: [
              CalendarReminder(
                id: '1',
                title: 'تماس با مشتری',
                date: selectedDay,
              ),
              CalendarReminder(
                id: '2',
                title: 'جلسه تیم',
                date: selectedDay.add(const Duration(days: 1)),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('جلسه تیم'), findsNothing);
    expect(find.text('۱۴۰۵/۰۵'), findsOneWidget);
    expect(find.textContaining('ساعت ۱۰:۳۰'), findsOneWidget);
    expect(find.textContaining('۱۴۰۵/۰۵/۲۲'), findsOneWidget);
  });

  testWidgets('shows empty state when selected day has no reminder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: DateTime(2026, 8, 13),
            reminders: const <CalendarReminder>[],
          ),
        ),
      ),
    );

    expect(
      find.text('برای این روز یادآوری ثبت نشده است'),
      findsOneWidget,
    );
  });
}
