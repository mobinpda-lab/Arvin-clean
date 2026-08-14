import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('shows Persian Jalali month digits and reminder time', (tester) async {
    final day = DateTime(2026, 8, 14, 9, 30);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: day,
            reminders: [
              CalendarReminder(id: '1', title: 'تماس با مشتری', date: day),
            ],
          ),
        ),
      ),
    );

    expect(find.text('۱۴۰۵/۰۵'), findsOneWidget);
    expect(find.textContaining('۰۹:۳۰'), findsOneWidget);
    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('تقویم پیگیری'), findsOneWidget);
  });
}
