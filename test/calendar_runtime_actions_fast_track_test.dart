import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('read-only provider rows never expose generic Task actions', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15, 9);
    final prayer = CalendarReminder(
      id: 'prayer-tehran-2026-09-15-fajr',
      title: 'نماز صبح',
      date: day,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [prayer],
          canMutateReminder: (_) => false,
          onCompleteReminder: (_) async {},
          onSnoozeReminder: (_) async {},
          onEditReminder: (_) async {},
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey('reminder-card-${prayer.id}')));
    await tester.pump();

    expect(find.byKey(ValueKey('reminder-actions-${prayer.id}')), findsNothing);
    expect(
      find.byKey(ValueKey('reminder-complete-${prayer.id}')),
      findsNothing,
    );
    expect(find.byKey(ValueKey('reminder-snooze-${prayer.id}')), findsNothing);
    expect(find.byKey(ValueKey('reminder-edit-${prayer.id}')), findsNothing);
  });

  testWidgets('canonical follow-up row keeps generic Task actions', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15, 9);
    final reminder = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری قرارداد',
      date: day,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [reminder],
          canMutateReminder: (_) => true,
          onCompleteReminder: (_) async {},
          onSnoozeReminder: (_) async {},
          onEditReminder: (_) async {},
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pump();

    expect(
      find.byKey(ValueKey('reminder-complete-${reminder.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('reminder-snooze-${reminder.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('reminder-edit-${reminder.id}')),
      findsOneWidget,
    );
  });

  testWidgets('long press on a week date forwards the exact selected date', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15);
    DateTime? requestedDate;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: const [],
          onCreateTaskForDate: (date) async => requestedDate = date,
        ),
      ),
    );

    await tester.longPress(
      find.byKey(const ValueKey('calendar-week-day-2026-9-15')),
    );
    await tester.pump();

    expect(requestedDate, DateTime(2026, 9, 15));
  });
}
