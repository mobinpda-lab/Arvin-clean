import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/calendar_official_reminders.dart';

class _FakeOfficialSource implements OfficialCalendarReminderSource {
  const _FakeOfficialSource(this.items);

  final List<OfficialCalendarReminder> items;

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async {
    return items.where((item) => item.date.year == year).toList(growable: false);
  }
}

void main() {
  test('maps an official reminder to the existing CalendarReminder model', () {
    final source = OfficialCalendarReminder(
      id: 'prayer-fajr-1405-01-01',
      title: 'اذان صبح',
      date: DateTime(2026, 3, 21, 4, 35),
      kind: OfficialReminderKind.prayerTime,
      locationKey: 'tehran',
      sourceLabel: 'مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران',
    );

    final reminder = source.toCalendarReminder();

    expect(reminder.id, 'prayer-fajr-1405-01-01');
    expect(reminder.title, 'اذان صبح');
    expect(reminder.date, DateTime(2026, 3, 21, 4, 35));
  });

  test('combines sources without creating a separate storage model', () async {
    final service = OfficialCalendarReminderService([
      _FakeOfficialSource([
        OfficialCalendarReminder(
          id: 'holiday-1',
          title: 'تعطیل رسمی',
          date: DateTime(2026, 3, 21),
          kind: OfficialReminderKind.iranianHoliday,
        ),
      ]),
      _FakeOfficialSource([
        OfficialCalendarReminder(
          id: 'prayer-1',
          title: 'اذان صبح',
          date: DateTime(2026, 3, 21, 4, 35),
          kind: OfficialReminderKind.prayerTime,
        ),
      ]),
    ]);

    final reminders = await service.load(year: 2026);

    expect(reminders, hasLength(2));
    expect(reminders.map((item) => item.id), containsAll(<String>['holiday-1', 'prayer-1']));
  });
}
