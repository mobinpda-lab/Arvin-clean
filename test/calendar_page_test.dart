import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/iran_clock.dart';

void main() {
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
    expect(find.text('۱۴۰۵/۰۶'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('calendar-swipe-surface')),
      const Offset(-500, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('۱۴۰۶/۰۶'), findsOneWidget);
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

    expect(find.text('۱۴۰۵/۰۶'), findsOneWidget);

    await tester.tap(find.text('ماهانه'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-period-next')));
    await tester.pumpAndSettle();
    expect(find.text('۱۴۰۵/۰۷'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-period-previous')));
    await tester.pumpAndSettle();
    expect(find.text('۱۴۰۵/۰۶'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-today')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-today')), findsOneWidget);
  });

  testWidgets('expands reminder actions and routes applicable callbacks',
      (tester) async {
    final day = DateTime(2026, 9, 9, 10);
    final reminder = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری قرارداد',
      date: day,
    );
    var completed = 0;
    var snoozed = 0;
    var edited = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [reminder],
          onCompleteReminder: (_) async => completed++,
          onSnoozeReminder: (_) async => snoozed++,
          onEditReminder: (_) async => edited++,
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('reminder-card-followup:task-1:fu-1')),
    );
    await tester.pump();

    expect(find.text('انجام شد'), findsOneWidget);
    expect(find.text('تعویق'), findsOneWidget);
    expect(find.text('ویرایش'), findsOneWidget);
    expect(find.text('تبدیل به کار'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('reminder-complete-followup:task-1:fu-1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('reminder-snooze-followup:task-1:fu-1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('reminder-edit-followup:task-1:fu-1')),
    );
    await tester.pump();

    expect(completed, 1);
    expect(snoozed, 1);
    expect(edited, 1);
  });
}
