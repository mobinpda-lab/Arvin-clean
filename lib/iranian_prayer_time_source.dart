import 'package:adhan_dart/adhan_dart.dart';

import 'calendar_official_reminders.dart';

/// Local astronomical Prayer Times provider for the existing official calendar.
///
/// No network or persistence is owned here. The returned wall-clock values are
/// projected into [OfficialCalendarReminder] and then merged by the existing
/// official calendar service.
class IranianPrayerTimeSource implements OfficialCalendarReminderSource {
  const IranianPrayerTimeSource({
    this.latitude = 35.6892,
    this.longitude = 51.3890,
    this.utcOffset = const Duration(hours: 3, minutes: 30),
    this.locationKey = 'tehran',
    this.locationLabel = 'تهران',
  });

  final double latitude;
  final double longitude;
  final Duration utcOffset;
  final String locationKey;
  final String locationLabel;

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async {
    final coordinates = Coordinates(latitude, longitude);
    final output = <OfficialCalendarReminder>[];

    for (var date = DateTime(year, 1, 1);
        date.year == year;
        date = date.add(const Duration(days: 1))) {
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: CalculationMethodParameters.tehran(),
      );

      output.addAll(<OfficialCalendarReminder>[
        _reminder(date, 'fajr', 'اذان صبح', prayerTimes.fajr),
        _reminder(date, 'dhuhr', 'اذان ظهر', prayerTimes.dhuhr),
        _reminder(date, 'asr', 'عصر', prayerTimes.asr),
        _reminder(date, 'maghrib', 'اذان مغرب', prayerTimes.maghrib),
        _reminder(date, 'isha', 'عشا', prayerTimes.isha),
      ]);
    }

    return List<OfficialCalendarReminder>.unmodifiable(output);
  }

  OfficialCalendarReminder _reminder(
    DateTime localDate,
    String prayerKey,
    String title,
    DateTime utcTime,
  ) {
    final localTime = _toWallClock(utcTime);
    final day =
        '${localDate.year.toString().padLeft(4, '0')}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';

    return OfficialCalendarReminder(
      id: 'prayer-$locationKey-$day-$prayerKey',
      title: '$title — $locationLabel',
      date: localTime,
      kind: OfficialReminderKind.prayerTime,
      locationKey: locationKey,
      sourceLabel: 'Adhan / Tehran calculation method',
    );
  }

  DateTime _toWallClock(DateTime utcTime) {
    final shifted = utcTime.toUtc().add(utcOffset);
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
    );
  }
}
