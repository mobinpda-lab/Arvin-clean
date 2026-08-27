import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('calendar offers compact day week and month views', (tester) async {
    final selected = DateTime(2026, 8, 14, 9, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: selected,
            reminders: [
              CalendarReminder(
                id: 'follow-up-1',
                title: 'پیگیری نمونه',
                date: selected,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('calendar-view-mode-control')), findsOneWidget);
    expect(find.text('روزانه'), findsOneWidget);
    expect(find.text('هفتگی'), findsOneWidget);
    expect(find.text('ماهانه'), findsOneWidget);

    // Weekly is intentionally the compact default so reminders get more room.
    expect(find.byKey(const ValueKey('calendar-week-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-day-view')), findsNothing);
    expect(find.byKey(const ValueKey('calendar-month-view')), findsNothing);

    await tester.tap(find.text('روزانه'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-day-view')), findsOneWidget);
    expect(find.text('پیگیری نمونه'), findsOneWidget);

    await tester.tap(find.text('ماهانه'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-month-view')), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
