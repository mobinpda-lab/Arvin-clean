import 'package:arvin/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Calendar visible header uses Jalali year/month and Persian digits',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: DateTime.utc(2026, 9, 19),
          reminders: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('۱۴۰۵/۰۶'), findsOneWidget);
    expect(find.textContaining('2026'), findsNothing);
  });

  testWidgets('Calendar selected-day surface uses Persian date and time digits',
      (tester) async {
    final reminder = CalendarReminder(
      id: 'jalali-visible',
      title: 'یادآور آزمایشی',
      date: DateTime.utc(2026, 9, 19, 14, 5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: DateTime.utc(2026, 9, 19),
          reminders: [reminder],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('۱۴۰۵'), findsWidgets);
    expect(find.textContaining('۲۰۲۶'), findsNothing);
    expect(find.textContaining('۱۴:۰۵'), findsOneWidget);
    expect(find.textContaining('14:05'), findsNothing);
  });
}
