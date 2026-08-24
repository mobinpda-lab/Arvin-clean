import 'calendar_official_reminders.dart';

/// Verified offline official holidays for the Iranian calendar year 1405.
///
/// Dates are Gregorian local midnights because [OfficialCalendarReminderSource]
/// uses Gregorian years as its retrieval boundary. The source record covers
/// 1405-01-01 (2026-03-21) through 1405-12-29 (2027-03-20).
class IranianOfficialHolidaySource implements OfficialCalendarReminderSource {
  const IranianOfficialHolidaySource();

  static const sourceLabel =
      'تقویم رسمی ۱۴۰۵، مرکز تقویم دانشگاه تهران';

  static const sourceUrl =
      'https://calendar.ut.ac.ir/documents/2139738/7092644/Calendar-1405.pdf/64228cbb-f4de-dc32-4d2b-57db3c8e322f?t=1761972997587';

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async {
    return List<OfficialCalendarReminder>.unmodifiable(
      _holidays.where((holiday) => holiday.date.year == year),
    );
  }

  static const _holidays = <OfficialCalendarReminder>[
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-01',
      title: 'نوروز و عید فطر',
      date: DateTime(2026, 3, 21),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-02',
      title: 'نوروز',
      date: DateTime(2026, 3, 22),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-03',
      title: 'نوروز',
      date: DateTime(2026, 3, 23),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-04',
      title: 'نوروز',
      date: DateTime(2026, 3, 24),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-12',
      title: 'روز جمهوری اسلامی ایران',
      date: DateTime(2026, 4, 1),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-01-13',
      title: 'روز طبیعت',
      date: DateTime(2026, 4, 2),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-03-06',
      title: 'عید قربان',
      date: DateTime(2026, 5, 27),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-03-14',
      title: 'رحلت امام خمینی و عید غدیر خم',
      date: DateTime(2026, 6, 4),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-03-15',
      title: 'قیام ۱۵ خرداد',
      date: DateTime(2026, 6, 5),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-04-02',
      title: 'تاسوعای حسینی',
      date: DateTime(2026, 6, 24),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-04-03',
      title: 'عاشورای حسینی',
      date: DateTime(2026, 6, 25),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-05-13',
      title: 'اربعین حسینی',
      date: DateTime(2026, 8, 4),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-05-21',
      title: 'رحلت پیامبر اکرم و شهادت امام حسن مجتبی',
      date: DateTime(2026, 8, 12),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-05-22',
      title: 'شهادت امام رضا',
      date: DateTime(2026, 8, 13),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-05-30',
      title: 'شهادت امام حسن عسکری',
      date: DateTime(2026, 8, 21),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-06-08',
      title: 'میلاد پیامبر اکرم و امام جعفر صادق',
      date: DateTime(2026, 8, 30),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-08-23',
      title: 'شهادت حضرت فاطمه زهرا',
      date: DateTime(2026, 11, 13),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-10-03',
      title: 'ولادت امام علی و روز پدر',
      date: DateTime(2026, 12, 23),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-10-17',
      title: 'مبعث پیامبر اکرم',
      date: DateTime(2027, 1, 6),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-11-05',
      title: 'نیمه شعبان',
      date: DateTime(2027, 1, 24),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-11-22',
      title: 'پیروزی انقلاب اسلامی',
      date: DateTime(2027, 2, 11),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-12-09',
      title: 'شهادت امام علی',
      date: DateTime(2027, 2, 28),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-12-19',
      title: 'عید فطر',
      date: DateTime(2027, 3, 10),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-12-20',
      title: 'تعطیل عید فطر',
      date: DateTime(2027, 3, 11),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
    OfficialCalendarReminder(
      id: 'ir-holiday-1405-12-29',
      title: 'ملی شدن صنعت نفت ایران',
      date: DateTime(2027, 3, 20),
      kind: OfficialReminderKind.iranianHoliday,
      sourceLabel: sourceLabel,
    ),
  ];
}
