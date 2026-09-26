import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_official_reminders.dart';
import 'package:arvin/calendar_page.dart';

class _FakeOfficialSource implements OfficialCalendarReminderSource {
  const _FakeOfficialSource(this.items);

  final List<OfficialCalendarReminder> items;

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async =>
      items.where((item) => item.date.year == year).toList(growable: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Calendar release acceptance exposes all four views and period navigation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initial = DateTime(2026, 9, 15, 10);
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: CalendarPage(
              initialSelectedDay: initial,
              reminders: const <CalendarReminder>[],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final entry in <String, String>{
        'روزانه': 'calendar-day-view',
        'هفتگی': 'calendar-week-view',
        'ماهانه': 'calendar-month-view',
        'سالانه': 'calendar-year-view',
      }.entries) {
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey<String>(entry.value)),
          findsOneWidget,
          reason: 'Calendar must expose the ${entry.key} view',
        );

        await tester.tap(find.byKey(const ValueKey('calendar-period-next')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('calendar-period-previous')));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const ValueKey('calendar-today')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('calendar-today')), findsOneWidget);
    },
  );

  testWidgets(
    'Calendar release acceptance keeps RTL horizontal navigation across all views',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initial = DateTime(2026, 9, 15, 10);
      for (final mode in <String>['روزانه', 'هفتگی', 'ماهانه', 'سالانه']) {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: CalendarPage(
                initialSelectedDay: initial,
                reminders: <CalendarReminder>[
                  CalendarReminder(
                    id: 'origin',
                    title: 'رویداد مبدأ',
                    date: initial,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(mode));
        await tester.pumpAndSettle();

        await tester.fling(
          find.byKey(const ValueKey('calendar-swipe-surface')),
          const Offset(-500, 0),
          1200,
        );
        await tester.pumpAndSettle();

        expect(
          find.text('رویداد مبدأ'),
          findsNothing,
          reason: 'RTL next-period swipe must advance the selected period in $mode',
        );
      }
    },
  );

  testWidgets(
    'Calendar release acceptance routes complete and snooze actions without a second action engine',
    (tester) async {
      final day = DateTime(2026, 9, 9, 10);
      var completed = 0;
      var snoozed = 0;
      final reminder = CalendarReminder(
        id: 'followup:release-task:release-followup',
        title: 'پیگیری قرارداد',
        date: day,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: CalendarPage(
              initialSelectedDay: day,
              reminders: <CalendarReminder>[reminder],
              onCompleteReminder: (_) async => completed++,
              onSnoozeReminder: (_) async => snoozed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('reminder-card-followup:release-task:release-followup')),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('reminder-complete-followup:release-task:release-followup')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('reminder-snooze-followup:release-task:release-followup')),
      );
      await tester.pump();

      expect(completed, 1);
      expect(snoozed, 1);
    },
  );

  testWidgets(
    'Official Calendar release acceptance maps Iranian occasions into the canonical CalendarPage',
    (tester) async {
      final selectedDay = DateTime(2026, 3, 21);
      final officialHoliday = OfficialCalendarReminder(
        id: 'ir-holiday-1405-01-01',
        title: 'نوروز',
        date: selectedDay,
        kind: OfficialReminderKind.iranianHoliday,
      );
      final service = OfficialCalendarReminderService(
        <OfficialCalendarReminderSource>[
          _FakeOfficialSource(<OfficialCalendarReminder>[officialHoliday]),
        ],
      );

      final officialReminders = await service.load(year: 2026);
      expect(officialReminders, hasLength(1));
      expect(officialReminders.single.title, 'نوروز');
      expect(officialReminders.single.isAllDay, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: CalendarPage(
              initialSelectedDay: selectedDay,
              reminders: <CalendarReminder>[
                ...officialReminders,
                CalendarReminder(
                  id: 'task',
                  title: 'کار واقعی',
                  date: DateTime(2026, 3, 21, 9),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('نوروز'), findsOneWidget);
      expect(find.text('کار واقعی'), findsOneWidget);
      expect(find.textContaining('رویداد تمام‌روز'), findsOneWidget);
      expect(find.textContaining('ساعت ۰۰:۰۰'), findsNothing);
    },
  );
}