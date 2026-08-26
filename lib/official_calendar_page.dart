import 'package:flutter/material.dart';

import 'calendar_official_reminders.dart';
import 'calendar_page.dart';
import 'iranian_official_holiday_source.dart';
import 'iranian_prayer_time_source.dart';

/// Loads official providers through [OfficialCalendarReminderService] and
/// hands their existing [CalendarReminder] output to [CalendarPage].
class OfficialCalendarPage extends StatefulWidget {
  const OfficialCalendarPage({
    super.key,
    required this.service,
    required this.years,
    this.reminders = const <CalendarReminder>[],
    this.initialSelectedDay,
  });

  final OfficialCalendarReminderService service;
  final List<int> years;
  final List<CalendarReminder> reminders;
  final DateTime? initialSelectedDay;

  @override
  State<OfficialCalendarPage> createState() => _OfficialCalendarPageState();
}

/// Ready-to-use 1405 composition. The official document spans Gregorian
/// years 2026 and 2027, so both service partitions are loaded. Prayer Times
/// use the existing official calendar provider boundary and do not create a
/// second calendar source of truth.
class IranianOfficialCalendarPage extends OfficialCalendarPage {
  const IranianOfficialCalendarPage({
    super.key,
    super.reminders,
    super.initialSelectedDay,
  }) : super(
          service: const OfficialCalendarReminderService(
            <OfficialCalendarReminderSource>[
              IranianOfficialHolidaySource(),
              IranianPrayerTimeSource(),
            ],
          ),
          years: const <int>[2026, 2027],
        );
}

class _OfficialCalendarPageState extends State<OfficialCalendarPage> {
  late Future<List<CalendarReminder>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<List<CalendarReminder>> _load() async {
    final officialGroups = await Future.wait(
      widget.years.map((year) => widget.service.load(year: year)),
    );
    final byId = <String, CalendarReminder>{
      for (final reminder in widget.reminders) reminder.id: reminder,
    };

    for (final reminder in officialGroups.expand((group) => group)) {
      byId.putIfAbsent(reminder.id, () => reminder);
    }

    final merged = byId.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(merged);
  }

  void _retry() {
    setState(() => _loadFuture = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CalendarReminder>>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('تقویم پیگیری')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('بارگذاری مناسبت‌های رسمی انجام نشد'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _retry,
                    child: const Text('تلاش دوباره'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('تقویم پیگیری')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return CalendarPage(
          reminders: snapshot.requireData,
          initialSelectedDay: widget.initialSelectedDay,
        );
      },
    );
  }
}
