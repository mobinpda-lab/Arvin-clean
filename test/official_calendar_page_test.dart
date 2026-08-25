import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_official_reminders.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/official_calendar_page.dart';

class _FakeOfficialSource implements OfficialCalendarReminderSource {
  const _FakeOfficialSource(this.items);

  final List<OfficialCalendarReminder> items;

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async {
    return items.where((item) => item.date.year == year).toList();
  }
}

void main() {
  testWidgets('feeds official service output into the existing CalendarPage',
      (tester) async {
    final selectedDay = DateTime(2026, 3, 21);
    final service = OfficialCalendarReminderService([
      _FakeOfficialSource([
        OfficialCalendarReminder(
          id: 'ir-holiday-1405-01-01',
          title: 'نوروز',
          date: selectedDay,
          kind: OfficialReminderKind.iranianHoliday,
        ),
      ]),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: OfficialCalendarPage(
            service: service,
            years: const <int>[2026],
            initialSelectedDay: selectedDay,
            reminders: [
              CalendarReminder(
                id: 'task-follow-up',
                title: 'پیگیری مشتری',
                date: DateTime(2026, 3, 21, 9),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نوروز'), findsOneWidget);
    expect(find.text('پیگیری مشتری'), findsOneWidget);
    expect(find.textContaining('رویداد تمام‌روز'), findsOneWidget);
    expect(find.textContaining('ساعت ۰۰:۰۰'), findsNothing);
  });
}
