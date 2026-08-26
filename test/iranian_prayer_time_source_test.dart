import 'package:arvin/calendar_official_reminders.dart';
import 'package:arvin/iranian_prayer_time_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const source = IranianPrayerTimeSource();

  test('produces five real prayer reminders for every day of 2026', () async {
    final reminders = await source.load(year: 2026);

    expect(reminders, hasLength(365 * 5));
    expect(
      reminders.every((item) => item.kind == OfficialReminderKind.prayerTime),
      isTrue,
    );
    expect(reminders.every((item) => item.locationKey == 'tehran'), isTrue);
    expect(reminders.map((item) => item.id).toSet(), hasLength(reminders.length));
  });

  test('daily Tehran prayer times are chronological and on the requested day',
      () async {
    final reminders = await source.load(year: 2026);
    final day = reminders
        .where((item) =>
            item.date.year == 2026 &&
            item.date.month == 8 &&
            item.date.day == 26)
        .toList();

    expect(day, hasLength(5));
    expect(day.map((item) => item.title).toList(), [
      'اذان صبح — تهران',
      'اذان ظهر — تهران',
      'عصر — تهران',
      'اذان مغرب — تهران',
      'عشا — تهران',
    ]);

    for (var index = 1; index < day.length; index++) {
      expect(day[index].date.isAfter(day[index - 1].date), isTrue);
    }
  });

  test('provider remains explicit and configurable for another location',
      () async {
    const configured = IranianPrayerTimeSource(
      latitude: 32.6539,
      longitude: 51.6660,
      locationKey: 'isfahan',
      locationLabel: 'اصفهان',
    );

    final reminders = await configured.load(year: 2026);
    expect(reminders.first.locationKey, 'isfahan');
    expect(reminders.first.title, contains('اصفهان'));
  });
}
