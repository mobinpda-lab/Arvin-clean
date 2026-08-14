import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('shows reminders for the selected day', (tester) async {
    final day = DateTime(2026, 8, 14);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: day,
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
    await tester.pumpAndSettle();

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('جلسه تیم'), findsNothing);
  });

  testWidgets('shows empty state when selected day has no reminder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: DateTime(2026, 8, 14),
            reminders: const <CalendarReminder>[],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('برای این روز یادآوری ثبت نشده است'),
      findsOneWidget,
    );
  });
}
