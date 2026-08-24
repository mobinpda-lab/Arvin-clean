import 'package:arvin/calendar_official_reminders.dart';
import 'package:arvin/iranian_official_holiday_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const source = IranianOfficialHolidaySource();

  test('returns verified 1405 holidays in the requested Gregorian year', () async {
    final holidays = await source.load(year: 2026);

    expect(holidays, hasLength(18));
    expect(holidays.every((item) => item.date.year == 2026), isTrue);
    expect(
      holidays.where((item) => item.id == 'ir-holiday-1405-01-01').single,
      isA<OfficialCalendarReminder>()
          .having((item) => item.title, 'title', 'نوروز و عید فطر')
          .having((item) => item.date, 'date', DateTime(2026, 3, 21))
          .having(
            (item) => item.kind,
            'kind',
            OfficialReminderKind.iranianHoliday,
          ),
    );
  });

  test('keeps the 1405 Gregorian boundary and stable unique identifiers', () async {
    final holidays2026 = await source.load(year: 2026);
    final holidays2027 = await source.load(year: 2027);
    final all = [...holidays2026, ...holidays2027];

    expect(holidays2027, hasLength(7));
    expect(all, hasLength(25));
    expect(all.map((item) => item.id).toSet(), hasLength(25));
    expect(
      holidays2027
          .where((item) => item.id == 'ir-holiday-1405-12-29')
          .single
          .date,
      DateTime(2027, 3, 20),
    );
    expect(await source.load(year: 2028), isEmpty);
  });

  test('carries the official source label for every holiday', () async {
    final holidays = await source.load(year: 2026);

    expect(
      holidays.every(
        (holiday) => holiday.sourceLabel == IranianOfficialHolidaySource.sourceLabel,
      ),
      isTrue,
    );
  });
}
