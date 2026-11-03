import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/calendar_swipe_settings_service.dart';

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
        onEditReminder: (_) async {},
      ),
    ),
  );

  await tester.tap(find.byKey(ValueKey('reminder-card-$id')));
  await tester.pump();

  expect(find.byKey(ValueKey('reminder-actions-$id')), findsNothing);
  expect(find.byKey(ValueKey('reminder-complete-$id')), findsNothing);
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
  });

  testWidgets('historical FollowUp is not rendered or actionable in local Calendar', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15, 9);
    const id = 'followup:task-1:fu-1';

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: <CalendarReminder>[
            CalendarReminder(
              id: id,
              title: 'پیگیری قرارداد',
              date: DateTime(2026, 9, 15, 9),
            ),
          ],
          onCompleteReminder: (_) async {},
          onEditReminder: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('پیگیری قرارداد'), findsNothing);
    expect(find.byKey(const ValueKey('reminder-card-$id')), findsNothing);
    expect(find.byKey(const ValueKey('reminder-actions-$id')), findsNothing);
    expect(find.byKey(const ValueKey('reminder-complete-$id')), findsNothing);
    expect(find.byKey(const ValueKey('reminder-edit-$id')), findsNothing);
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

  testWidgets('Arvin Task primary actions are visible before expansion', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15, 9);
    var edited = 0;
    var registered = 0;
    final reminders = <CalendarReminder>[
      CalendarReminder(
        id: 'task-reminder:task-1',
        title: 'یادآوری کار',
        date: day,
      ),
      CalendarReminder(
        id: 'task-due:task-1:2026-09-16T09:00:00.000',
        title: 'تکرار کار',
        date: day.add(const Duration(days: 1)),
      ),
    ];

    for (final reminder in reminders) {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(
            key: ValueKey(reminder.id),
            initialSelectedDay: reminder.date,
            reminders: <CalendarReminder>[reminder],
            onEditTask: (_) async => edited++,
            onDeleteTask: (_) async {},
            onRegisterTaskToDeviceCalendar: (_) async => registered++,
            calendarSwipeRightAction: CalendarSwipeAction.sync,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final edit = find.byKey(ValueKey('task-due-edit-${reminder.id}'));
      final register = find.byKey(
        ValueKey('task-due-device-calendar-${reminder.id}'),
      );
      final delete = find.byKey(ValueKey('task-due-delete-${reminder.id}'));

      // Task management actions are available only from long-press.
      expect(edit, findsNothing);
      expect(register, findsNothing);
      expect(delete, findsNothing);

      await tester.longPress(find.byKey(ValueKey('reminder-card-${reminder.id}')));
      await tester.pumpAndSettle();
      expect(edit, findsOneWidget);
      expect(register, findsNothing);
      expect(delete, findsOneWidget);

      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.fling(
        find.byKey(ValueKey('reminder-card-${reminder.id}')),
        const Offset(500, 0),
        1000,
      );
      await tester.pumpAndSettle();
    }

    expect(edited, 2);
    expect(registered, 2);
  });

}
