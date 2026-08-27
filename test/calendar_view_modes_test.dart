import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('calendar enforces RTL and keeps weekly mode compact by default',
      (tester) async {
    final selected = DateTime(2026, 8, 12, 9, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
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
    );

    expect(find.text('تقویم پیگیری'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('تقویم پیگیری'))),
      TextDirection.rtl,
    );
    expect(find.byKey(const ValueKey('calendar-today')), findsOneWidget);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('۱۴۰۵/۰۵'), findsOneWidget);

    expect(
      find.byKey(const ValueKey('calendar-view-mode-control')),
      findsOneWidget,
    );
    expect(find.text('روزانه'), findsOneWidget);
    expect(find.text('هفتگی'), findsOneWidget);
    expect(find.text('ماهانه'), findsOneWidget);

    // Weekly is the binding compact default so the selected-day list gets room.
    expect(find.byKey(const ValueKey('calendar-week-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-day-view')), findsNothing);
    expect(find.byKey(const ValueKey('calendar-month-view')), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('calendar-week-view'))).height,
      lessThan(80),
    );
    expect(
      find.byKey(const ValueKey('calendar-selected-day-list')),
      findsOneWidget,
    );
    expect(find.text('پیگیری نمونه'), findsOneWidget);
  });

  testWidgets('day week and month navigation use their exact period step',
      (tester) async {
    final selected = DateTime(2026, 8, 12, 9, 30);
    final nextDay = selected.add(const Duration(days: 1));
    final nextWeek = selected.add(const Duration(days: 7));

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: selected,
          reminders: [
            CalendarReminder(
              id: 'selected',
              title: 'روز مبنا',
              date: selected,
            ),
            CalendarReminder(
              id: 'next-day',
              title: 'روز بعد',
              date: nextDay,
            ),
            CalendarReminder(
              id: 'next-week',
              title: 'هفته بعد',
              date: nextWeek,
            ),
          ],
        ),
      ),
    );

    // Tapping a week day immediately updates the selected-day list.
    await tester.tap(
      find.byKey(const ValueKey('calendar-week-day-2026-8-13')),
    );
    await tester.pumpAndSettle();
    expect(find.text('روز بعد'), findsOneWidget);
    expect(find.text('روز مبنا'), findsNothing);

    // Daily arrows move exactly one day from the currently selected day.
    await tester.tap(find.text('روزانه'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-day-view')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('calendar-day-view'))).height,
      lessThan(70),
    );
    expect(find.byKey(const ValueKey('calendar-day-count')), findsOneWidget);
    expect(find.text('۱ مورد'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calendar-period-previous')));
    await tester.pumpAndSettle();
    expect(find.text('روز مبنا'), findsOneWidget);
    expect(find.text('روز بعد'), findsNothing);

    // Weekly arrows move exactly seven days.
    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-period-next')));
    await tester.pumpAndSettle();
    expect(find.text('هفته بعد'), findsOneWidget);
    expect(find.text('روز مبنا'), findsNothing);

    // Monthly is opt-in only; its arrow moves one Jalali month.
    await tester.tap(find.text('ماهانه'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-month-view')), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('calendar-month-view'))).height,
      lessThan(280),
    );
    expect(find.text('۱۴۰۵/۰۵'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calendar-period-next')));
    await tester.pumpAndSettle();
    expect(find.text('۱۴۰۵/۰۶'), findsOneWidget);
  });

  testWidgets('visible Today action selects today and refreshes selected list',
      (tester) async {
    final initial = DateTime(2026, 8, 12, 9, 30);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10, 15);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: initial,
          reminders: [
            CalendarReminder(
              id: 'initial',
              title: 'رویداد اولیه',
              date: initial,
            ),
            CalendarReminder(
              id: 'today',
              title: 'پیگیری امروز',
              date: today,
            ),
          ],
        ),
      ),
    );

    expect(find.text('رویداد اولیه'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calendar-today')));
    await tester.pumpAndSettle();
    expect(find.text('پیگیری امروز'), findsOneWidget);
    expect(find.text('رویداد اولیه'), findsNothing);
  });
}
