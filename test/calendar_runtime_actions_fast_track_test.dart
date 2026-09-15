import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

Future<void> _expectReadOnlyReminder(
  WidgetTester tester, {
  required String id,
  required String title,
}) async {
  final day = DateTime(2026, 9, 15, 9);
  final reminder = CalendarReminder(id: id, title: title, date: day);

  await tester.pumpWidget(
    MaterialApp(
      home: CalendarPage(
        initialSelectedDay: day,
        reminders: [reminder],
        canMutateReminder: (item) => item.id.startsWith('followup:'),
        onCompleteReminder: (_) async {},
        onSnoozeReminder: (_) async {},
        onEditReminder: (_) async {},
      ),
    ),
  );

  await tester.tap(find.byKey(ValueKey('reminder-card-$id')));
  await tester.pump();

  expect(find.byKey(ValueKey('reminder-actions-$id')), findsNothing);
  expect(find.byKey(ValueKey('reminder-complete-$id')), findsNothing);
  expect(find.byKey(ValueKey('reminder-snooze-$id')), findsNothing);
  expect(find.byKey(ValueKey('reminder-edit-$id')), findsNothing);
}

void main() {
  testWidgets('every read-only source hides generic Task actions', (
    tester,
  ) async {
    await _expectReadOnlyReminder(
      tester,
      id: 'prayer-tehran-2026-09-15-fajr',
      title: 'نماز صبح',
    );
    await _expectReadOnlyReminder(
      tester,
      id: 'ir-holiday-1405-06-24',
      title: 'تعطیلی رسمی',
    );
    await _expectReadOnlyReminder(
      tester,
      id: 'task-due:task-1',
      title: 'موعد کار',
    );
    await _expectReadOnlyReminder(
      tester,
      id: 'task-followup:task-1',
      title: 'پیگیری قدیمی',
    );
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
          canMutateReminder: (item) => item.id.startsWith('followup:'),
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
