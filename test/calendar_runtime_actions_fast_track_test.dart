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
    await _expectReadOnlyReminder(
      tester,
      id: 'task-followup:task-1',
      title: 'پیگیری قدیمی',
    );
  });

  testWidgets('Follow-up tap opens its Task; long press shows typed actions', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15, 9);
    final reminder = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری قرارداد',
      date: day,
    );
    var opened = 0;
    var completed = 0;
    var edited = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [reminder],
          canMutateReminder: (item) => item.id.startsWith('followup:'),
          onOpenTaskDetail: (item) async {
            expect(item.id, reminder.id);
            opened++;
          },
          onCompleteReminder: (_) async => completed++,
          onEditReminder: (_) async => edited++,
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pump();
    expect(opened, 1);
    expect(find.byKey(ValueKey('calendar-action-edit-${reminder.id}')), findsNothing);

    await tester.longPress(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('calendar-action-complete-${reminder.id}')), findsOneWidget);
    expect(find.byKey(ValueKey('calendar-action-edit-${reminder.id}')), findsOneWidget);
    expect(find.byKey(ValueKey('reminder-snooze-${reminder.id}')), findsNothing);

    await tester.tap(find.byKey(ValueKey('calendar-action-complete-${reminder.id}')));
    await tester.pumpAndSettle();
    expect(completed, 1);
    expect(edited, 0);
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

  testWidgets('Task tap opens detail; long press exposes management only', (
    tester,
  ) async {
    final day = DateTime(2026, 9, 15, 9);
    final reminder = CalendarReminder(
      id: 'task-reminder:task-1',
      title: 'یادآوری کار',
      date: day,
    );
    var openedId = '';
    var editedId = '';
    var registeredId = '';
    var deleted = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: <CalendarReminder>[reminder],
          onOpenTaskDetail: (item) async => openedId = item.id,
          onEditTask: (item) async => editedId = item.id,
          onDeleteTask: (item) async => deleted++,
          onRegisterTaskToDeviceCalendar: (item) async => registeredId = item.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pump();
    expect(openedId, reminder.id);
    expect(find.byKey(ValueKey('calendar-action-edit-${reminder.id}')), findsNothing);
    expect(find.byKey(ValueKey('task-due-edit-${reminder.id}')), findsNothing);
    expect(find.byKey(ValueKey('task-due-device-calendar-${reminder.id}')), findsNothing);

    await tester.longPress(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pumpAndSettle();
    final edit = find.byKey(ValueKey('calendar-action-edit-${reminder.id}'));
    final register = find.byKey(ValueKey('calendar-action-register-${reminder.id}'));
    final delete = find.byKey(ValueKey('calendar-action-delete-${reminder.id}'));
    expect(edit, findsOneWidget);
    expect(register, findsOneWidget);
    expect(delete, findsOneWidget);

    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(editedId, reminder.id);

    await tester.longPress(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pumpAndSettle();
    await tester.tap(register);
    await tester.pumpAndSettle();
    expect(registeredId, reminder.id);

    await tester.longPress(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(find.text('حذف کار'), findsOneWidget);
    expect(deleted, 0);
    await tester.tap(find.text('لغو'));
    await tester.pumpAndSettle();
    expect(deleted, 0);
  });
}
