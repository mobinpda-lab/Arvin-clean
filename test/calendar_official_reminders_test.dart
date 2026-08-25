import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/calendar_official_reminders.dart';

class _FakeOfficialSource implements OfficialCalendarReminderSource {
  const _FakeOfficialSource(this.items);

  final List<OfficialCalendarReminder> items;

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async {
    return items;
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
    expect(reminder.isAllDay, isFalse);
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
    expect(
      reminders.map((item) => item.id),
      containsAll(<String>['holiday-1', 'prayer-1']),
    );
  });

  test('filters to the requested year, removes duplicate ids, and sorts by time', () async {
    final service = OfficialCalendarReminderService([
      _FakeOfficialSource([
        OfficialCalendarReminder(
          id: 'late',
          title: 'دیرتر',
          date: DateTime(2026, 3, 21, 8),
          kind: OfficialReminderKind.prayerTime,
        ),
        OfficialCalendarReminder(
          id: 'duplicate',
          title: 'نسخه اول',
          date: DateTime(2026, 3, 21, 6),
          kind: OfficialReminderKind.prayerTime,
        ),
      ]),
      _FakeOfficialSource([
        OfficialCalendarReminder(
          id: 'outside-year',
          title: 'سال دیگر',
          date: DateTime(2027, 3, 21, 5),
          kind: OfficialReminderKind.iranianHoliday,
        ),
        OfficialCalendarReminder(
          id: 'duplicate',
          title: 'نسخه دوم',
          date: DateTime(2026, 3, 21, 7),
          kind: OfficialReminderKind.prayerTime,
        ),
      ]),
    ]);

    final reminders = await service.load(year: 2026);

    expect(reminders.map((item) => item.id), <String>['duplicate', 'late']);
    expect(reminders.first.title, 'نسخه اول');
    expect(reminders.last.date, DateTime(2026, 3, 21, 8));
  });
  test('maps official holidays to the existing all-day UI contract', () {
    final source = OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-01',
      title: 'نوروز',
      date: DateTime(2026, 3, 21),
      kind: OfficialReminderKind.iranianHoliday,
    );

    final reminder = source.toCalendarReminder();

    expect(reminder.isAllDay, isTrue);
  });
}
