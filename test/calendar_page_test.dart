import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/iran_clock.dart';

void main() {
  testWidgets('calendar cards use canonical pastel status colors and status icons', (tester) async {
    final selectedDay = DateTime(2030, 5, 1);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: selectedDay,
          reminders: [
            CalendarReminder(id: 'planned', title: 'کار برنامه‌ریزی‌شده', date: selectedDay),
            CalendarReminder(id: 'task-followup:waiting', title: 'در انتظار پیگیری', date: selectedDay),
            CalendarReminder(id: 'completed', title: 'کار انجام‌شده', date: selectedDay, completed: true),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      (tester.widget<Card>(find.byKey(const ValueKey('reminder-card-planned'))).color),
      const Color(0xFFEFF6FF),
    );
    expect(
      tester.widget<Card>(find.byKey(const ValueKey('reminder-card-task-followup:waiting'))).color,
      const Color(0xFFFEFCE8),
    );
    expect(
      tester.widget<Card>(find.byKey(const ValueKey('reminder-card-completed'))).color,
      const Color(0xFFECFDF5),
    );
    expect(find.byIcon(Icons.hourglass_bottom_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });

  testWidgets('overdue calendar card uses red pastel and warning icon', (tester) async {
    final overdueDay = DateTime(2020, 1, 1);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: overdueDay,
          reminders: [CalendarReminder(id: 'overdue', title: 'کار عقب‌افتاده', date: overdueDay)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Card>(find.byKey(const ValueKey('reminder-card-overdue'))).color,
      const Color(0xFFFEF2F2),
    );
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.text('عقب‌افتاده'), findsOneWidget);
  });

  testWidgets('week date bar is 56 pixels high and highlights selected day in pastel purple', (tester) async {
    final selectedDay = DateTime(2030, 5, 1);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: selectedDay,
          reminders: [CalendarReminder(id: 'week-task', title: 'کار روز', date: selectedDay)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final selectedKey = ValueKey('calendar-week-day-${selectedDay.year}-${selectedDay.month}-${selectedDay.day}');
    final selectedDayWidget = tester.widget<Container>(
      find.descendant(of: find.byKey(selectedKey), matching: find.byType(Container)).first,
    );
    expect(selectedDayWidget.constraints?.maxHeight, anyOf(isNull, 56));
    expect(tester.getSize(find.byKey(selectedKey)).height, 56);
    expect(selectedDayWidget.decoration, isA<BoxDecoration>());
    expect(
      (selectedDayWidget.decoration! as BoxDecoration).color,
      const Color(0xFFEDE9FE),
    );
  });

  testWidgets('follow-up calendar card shows parent subtitle and exact timed chip', (tester) async {
  final selectedDay = DateTime(2026, 10, 16, 18, 45);
  await tester.pumpWidget(
    MaterialApp(
      home: CalendarPage(
        initialSelectedDay: selectedDay,
        reminders: [
          CalendarReminder(
            id: 'followup:task-1:follow-up-1',
            title: 'تماس مجدد',
            date: selectedDay,
            description: 'پیگیری: تماس با مشتری',
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('تماس مجدد'), findsOneWidget);
  expect(find.text('پیگیری: تماس با مشتری'), findsOneWidget);
  expect(find.byKey(const ValueKey('calendar-followup-time-chip-followup:task-1:follow-up-1')), findsOneWidget);
  expect(find.text('۱۸:۴۵'), findsOneWidget);
});


  testWidgets('shows reminders for the selected day', (tester) async {
    final now = IranClock.now();
    final day = DateTime(now.year, now.month, now.day);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            reminders: [
              CalendarReminder(
                id: '1',
                title: 'تماس با مشتری',
                date: day,
              ),
              CalendarReminder(
                id: '2',
                title: 'جلسه تیم',
                date: day.add(const Duration(days: 1)),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('جلسه تیم'), findsNothing);
  });

  testWidgets('shows empty state when selected day has no reminder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(reminders: <CalendarReminder>[]),
        ),
      ),
    );

    expect(
      find.text('برای این روز یادآوری ثبت نشده است'),
      findsOneWidget,
    );
  });

  testWidgets('does not show a synthetic midnight for all-day reminders',
      (tester) async {
    final holiday = DateTime(2026, 3, 21);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: holiday,
            reminders: [
              CalendarReminder(
                id: 'holiday',
                title: 'نوروز',
                date: holiday,
                isAllDay: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('نوروز'), findsOneWidget);
    expect(find.textContaining('رویداد تمام‌روز'), findsOneWidget);
    expect(find.textContaining('ساعت ۰۰:۰۰'), findsNothing);
    expect(find.textContaining('در انتظار پیگیری'), findsNothing);
  });

  testWidgets('offers year view with all Jalali months on a phone viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final day = DateTime(2026, 9, 15);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: const [],
        ),
      ),
    );

    await tester.tap(find.text('سالانه'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-year-view')), findsOneWidget);
    for (var month = 1; month <= 12; month++) {
      expect(find.byKey(ValueKey('calendar-year-month-$month')), findsOneWidget);
    }
  });

  testWidgets('horizontal swipe advances day week and month periods',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final initial = DateTime(2026, 9, 15, 10);
    const modes = <String>['روزانه', 'هفتگی', 'ماهانه'];

    for (final mode in modes) {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarPage(
            key: ValueKey('calendar-$mode'),
            initialSelectedDay: initial,
            reminders: [
              CalendarReminder(
                id: 'origin-$mode',
                title: 'رویداد مبدأ $mode',
                date: initial,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(mode));
      await tester.pumpAndSettle();
      expect(find.text('رویداد مبدأ $mode'), findsOneWidget);

      await tester.fling(
        find.byKey(const ValueKey('calendar-swipe-surface')),
        const Offset(-500, 0),
        1200,
      );
      await tester.pumpAndSettle();

      expect(find.text('رویداد مبدأ $mode'), findsNothing);
    }
  });

  testWidgets('horizontal swipe advances annual view by one Jalali year',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final initial = DateTime(2026, 9, 15, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: initial,
          reminders: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('سالانه'));
    await tester.pumpAndSettle();
    expect(find.text('شهریور ۱۴۰۵'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('calendar-swipe-surface')),
      const Offset(-500, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('شهریور ۱۴۰۶'), findsOneWidget);
  });


  testWidgets('calendar Today and period controls navigate the canonical selected day',
      (tester) async {
    final initial = DateTime(2026, 9, 15, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: initial,
          reminders: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('شهریور ۱۴۰۵'), findsOneWidget);

    await tester.tap(find.text('ماهانه'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-period-next')));
    await tester.pumpAndSettle();
    expect(find.text('مهر ۱۴۰۵'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-period-previous')));
    await tester.pumpAndSettle();
    expect(find.text('شهریور ۱۴۰۵'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-today')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-today')), findsOneWidget);
  });

  testWidgets('follow-up short tap opens its route and long press opens actions', (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    final followUp = CalendarReminder(
      id: 'followup:task-1:fu-tap',
      title: 'پیگیری قرارداد',
      date: day,
    );
    var taskEdited = 0;
    var followUpEdited = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [followUp],
          onEditTask: (_) async => taskEdited++,
          onEditReminder: (_) async => followUpEdited++,
          onCompleteReminder: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('reminder-card-followup:task-1:fu-tap'));
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(taskEdited, 0);
    expect(followUpEdited, 1);
    expect(find.byKey(const ValueKey('reminder-actions-followup:task-1:fu-tap')), findsNothing);
    expect(find.byKey(const ValueKey('reminder-edit-followup:task-1:fu-tap')), findsNothing);

    await tester.longPress(card);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const ValueKey('reminder-complete-followup:task-1:fu-tap')), findsOneWidget);
    expect(find.byKey(const ValueKey('reminder-edit-followup:task-1:fu-tap')), findsOneWidget);
    expect(find.byKey(const ValueKey('reminder-actions-followup:task-1:fu-tap')), findsNothing);
  });

  testWidgets('external calendar short tap opens the source item without expanding actions', (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [
            CalendarReminder(
              id: 'external-calendar:event-tap',
              title: 'رویداد گوشی',
              date: day,
            ),
          ],
          onOpenExternalReminder: (_) async => opened++,
          onCreateTaskFromCalendarEvent: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('reminder-card-external-calendar:event-tap')));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.byKey(const ValueKey('reminder-actions-external-calendar:event-tap')), findsNothing);
  });

  testWidgets('long press exposes follow-up actions and routes callbacks',
      (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    final reminder = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری قرارداد',
      date: day,
    );
    var completed = 0;
    var edited = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [reminder],
          onCompleteReminder: (_) async => completed++,
          onEditReminder: (_) async => edited++,
        ),
      ),
    );

    await tester.longPress(
      find.byKey(const ValueKey('reminder-card-followup:task-1:fu-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('انجام شد'), findsOneWidget);
    expect(find.text('تعویق'), findsNothing);
    expect(find.text('ویرایش پیگیری'), findsOneWidget);
    expect(find.text('تبدیل به کار'), findsNothing);

    final completeAction =
        find.byKey(const ValueKey('reminder-complete-followup:task-1:fu-1'));
    await tester.ensureVisible(completeAction);
    await tester.tap(completeAction);
    await tester.pumpAndSettle();
    await tester.longPress(
      find.byKey(const ValueKey('reminder-card-followup:task-1:fu-1')),
    );
    await tester.pumpAndSettle();
    final editAction =
        find.byKey(const ValueKey('reminder-edit-followup:task-1:fu-1'));
    await tester.ensureVisible(editAction);
    await tester.tap(editAction);
    await tester.pumpAndSettle();

    expect(completed, 1);
    expect(edited, 1);
  });
  testWidgets('distinguishes Arvin reminders from imported phone calendar items', (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [
            CalendarReminder(id: 'task-due:task-1', title: 'آروین', date: day),
            CalendarReminder(
              id: 'external-calendar:event-1',
              title: 'گوشی',
              date: day.add(const Duration(minutes: 30)),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-item-icon-task-due:task-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-item-icon-external-calendar:event-1')), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    expect(find.text('واردشده از تقویم گوشی'), findsNothing);
    expect(find.text('یادآوری آروین'), findsNothing);
    expect(find.text('یادآور'), findsNothing);
  });


  testWidgets('exposes reversible delete only for Arvin-owned task rows', (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    var deleted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CalendarPage(
            initialSelectedDay: day,
            reminders: [
              CalendarReminder(id: 'task-due:task-1', title: 'کار آروین', date: day),
              CalendarReminder(
                id: 'external-calendar:event-1',
                title: 'رویداد گوشی',
                date: day.add(const Duration(minutes: 30)),
              ),
            ],
            onDeleteTask: (_) async {
              deleted++;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const ValueKey('reminder-card-task-due:task-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-due-delete-task-due:task-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-due-delete-task-due:task-1')));
    await tester.pumpAndSettle();
    expect(deleted, 1);

    await tester.tap(find.byKey(const ValueKey('reminder-card-external-calendar:event-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-due-delete-external-calendar:event-1')), findsNothing);
  });



  testWidgets('task calendar card tap opens editor and long-press reveals actions',
      (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    final task = CalendarReminder(
      id: 'task-due:interaction-task',
      title: 'کار برای تعامل',
      date: day,
    );
    var edited = 0;
    var deleted = 0;
    var registered = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [task],
          onEditTask: (_) async => edited++,
          onDeleteTask: (_) async => deleted++,
          onRegisterTaskToDeviceCalendar: (_) async => registered++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('reminder-card-task-due:interaction-task')),
    );
    await tester.pumpAndSettle();
    expect(edited, 1);
    expect(find.byKey(const ValueKey('reminder-actions-task-due:interaction-task')),
        findsNothing);

    await tester.longPress(
      find.byKey(const ValueKey('reminder-card-task-due:interaction-task')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reminder-actions-task-due:interaction-task')),
        findsNothing);
    expect(find.byKey(const ValueKey('task-due-edit-task-due:interaction-task')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('task-due-delete-task-due:interaction-task')),
        findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-due-device-calendar-task-due:interaction-task')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('task-due-delete-task-due:interaction-task')),
    );
    await tester.pumpAndSettle();
    expect(deleted, 1);

    await tester.longPress(
      find.byKey(const ValueKey('reminder-card-task-due:interaction-task')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('task-due-device-calendar-task-due:interaction-task')),
    );
    await tester.pumpAndSettle();
    expect(registered, 1);
  });


  testWidgets('prayer cards use mosque icon and subdued unregistered status', (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [
            CalendarReminder(id: 'prayer-fajr', title: 'نماز صبح', date: day),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mosque), findsWidgets);
    final status = tester.widget<Text>(find.text('ثبت نشده'));
    expect(status.style?.fontSize, 11);
  });


}
