import 'calendar_page.dart';

enum OfficialReminderKind { prayerTime, iranianHoliday }

/// A source-neutral official calendar reminder.
///
/// This model deliberately contains no storage or networking concerns. Concrete
/// providers can resolve official data and map it to [CalendarReminder] without
/// creating a second calendar store.
class OfficialCalendarReminder {
  const OfficialCalendarReminder({
    required this.id,
    required this.title,
    required this.date,
    required this.kind,
    this.locationKey,
    this.sourceLabel,
  });

  final String id;
  final String title;
  final DateTime date;
  final OfficialReminderKind kind;
  final String? locationKey;
  final String? sourceLabel;

  CalendarReminder toCalendarReminder() => CalendarReminder(
        id: id,
        title: title,
        date: date,
      );
}

/// Contract for an official calendar source.
///
/// Implementations must supply authoritative data and must not persist a
/// parallel calendar database. [year] is Gregorian because it is unambiguous
/// for source retrieval; the Calendar UI remains responsible for Jalali display.
abstract interface class OfficialCalendarReminderSource {
  Future<List<OfficialCalendarReminder>> load({required int year});
}

/// Combines independent official sources into the existing CalendarReminder
/// stream without changing the Calendar foundation.
class OfficialCalendarReminderService {
  const OfficialCalendarReminderService(this.sources);

  final List<OfficialCalendarReminderSource> sources;

  Future<List<CalendarReminder>> load({required int year}) async {
    final groups = await Future.wait(
      sources.map((source) => source.load(year: year)),
    );

    final byId = <String, OfficialCalendarReminder>{};
    for (final item in groups.expand((group) => group)) {
      if (item.date.year == year) {
        byId.putIfAbsent(item.id, () => item);
      }
    }

    final reminders = byId.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return reminders
        .map((item) => item.toCalendarReminder())
        .toList(growable: false);
  }
}
