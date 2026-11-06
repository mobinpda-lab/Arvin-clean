import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('calendar exposes three date systems and five content filters',
      (tester) async {
    final selected = DateTime(2026, 8, 12);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: selected,
          reminders: [
            CalendarReminder(
              id: 'task-reminder-item:task-a:reminder-a',
              title: 'جلسه آروین',
              date: selected,
            ),
            CalendarReminder(
              id: 'external-calendar:event-a',
              title: 'رویداد گوشی',
              date: selected,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-date-triplet')), findsOneWidget);
    expect(find.text('میلادی'), findsOneWidget);
    expect(find.text('شمسی'), findsOneWidget);
    expect(find.text('قمری'), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-search-toggle')), findsOneWidget);

    for (final filter in const [
      'همه',
      'تقویم آروین',
      'تقویم گوشی',
      'یادآورها',
      'انجام‌نشده',
    ]) {
      expect(find.text(filter), findsOneWidget);
    }

    await tester.tap(find.text('تقویم آروین'));
    await tester.pumpAndSettle();
    expect(find.text('جلسه آروین'), findsOneWidget);
    expect(find.text('رویداد گوشی'), findsNothing);

    await tester.tap(find.text('تقویم گوشی'));
    await tester.pumpAndSettle();
    expect(find.text('رویداد گوشی'), findsOneWidget);
    expect(find.text('جلسه آروین'), findsNothing);
  });

  testWidgets('calendar search dynamically filters selected-day reminders',
      (tester) async {
    final selected = DateTime(2026, 8, 12);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: selected,
          reminders: [
            CalendarReminder(
              id: 'task-reminder-item:task-a:reminder-a',
              title: 'تماس با مشتری',
              date: selected,
            ),
            CalendarReminder(
              id: 'task-reminder-item:task-b:reminder-b',
              title: 'جلسه تیم',
              date: selected,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-search-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-search-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('calendar-search-field')),
      'مشتری',
    );
    await tester.pumpAndSettle();

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('جلسه تیم'), findsNothing);
  });
}
