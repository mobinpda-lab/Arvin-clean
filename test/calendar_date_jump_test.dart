import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('visible Jalali date jump opens the exact selected day',
      (tester) async {
    final initial = DateTime(2026, 8, 12, 9, 30); // 1405/05/21
    final target = DateTime(2026, 8, 13, 10, 15); // 1405/05/22

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: initial,
          reminders: [
            CalendarReminder(
              id: 'initial',
              title: 'رویداد روز مبنا',
              date: initial,
            ),
            CalendarReminder(
              id: 'target',
              title: 'رویداد روز انتخابی',
              date: target,
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('calendar-date-jump')), findsOneWidget);
    expect(find.text('برو به تاریخ'), findsOneWidget);
    expect(find.text('رویداد روز مبنا'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-date-jump')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-jump-year')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-jump-month')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-jump-day')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-jump-day')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('22').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-jump-apply')));
    await tester.pumpAndSettle();

    expect(find.text('رویداد روز انتخابی'), findsOneWidget);
    expect(find.text('رویداد روز مبنا'), findsNothing);
    expect(find.text('۱۴۰۵/۰۵'), findsOneWidget);
  });

  testWidgets('cancelling Jalali date jump has zero calendar side effects',
      (tester) async {
    final initial = DateTime(2026, 8, 12, 9, 30);
    final target = DateTime(2026, 8, 13, 10, 15);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: initial,
          reminders: [
            CalendarReminder(
              id: 'initial',
              title: 'انتخاب بدون تغییر',
              date: initial,
            ),
            CalendarReminder(
              id: 'target',
              title: 'نباید انتخاب شود',
              date: target,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-date-jump')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-jump-day')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('22').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-jump-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('انتخاب بدون تغییر'), findsOneWidget);
    expect(find.text('نباید انتخاب شود'), findsNothing);
    expect(find.text('۱۴۰۵/۰۵'), findsOneWidget);
  });

  testWidgets('changing Jalali month clamps an invalid day safely',
      (tester) async {
    final initial = DateTime(2026, 9, 22); // 1405/06/31

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: initial,
          reminders: const [],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-date-jump')));
    await tester.pumpAndSettle();

    var dayDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(const ValueKey('calendar-jump-day')),
    );
    expect(dayDropdown.value, 31);

    await tester.tap(find.byKey(const ValueKey('calendar-jump-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مهر').last);
    await tester.pumpAndSettle();

    dayDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(const ValueKey('calendar-jump-day')),
    );
    expect(dayDropdown.value, 30);

    await tester.tap(find.byKey(const ValueKey('calendar-jump-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('۱۴۰۵/۰۶'), findsOneWidget);
  });
}
