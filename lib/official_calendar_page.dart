import 'package:flutter/material.dart';

import 'calendar_official_reminders.dart';
import 'calendar_page.dart';
import 'iranian_official_holiday_source.dart';
import 'iranian_prayer_time_source.dart';
import 'prayer_completion_report_page.dart';
import 'services/prayer_completion_projection.dart';
import 'services/prayer_completion_store.dart';

/// Loads official providers through [OfficialCalendarReminderService] and
/// hands their existing [CalendarReminder] output to [CalendarPage].
class OfficialCalendarPage extends StatefulWidget {
  const OfficialCalendarPage({
    super.key,
    required this.service,
    required this.years,
    this.reminders = const <CalendarReminder>[],
    this.initialSelectedDay,
    this.onCompleteReminder,
    this.onSnoozeReminder,
    this.onEditReminder,
    this.onConvertReminderToTask,
    this.canMutateReminder,
    this.onCreateTaskForDate,
  });

  final OfficialCalendarReminderService service;
  final List<int> years;
  final List<CalendarReminder> reminders;
  final DateTime? initialSelectedDay;
  final Future<void> Function(CalendarReminder reminder)? onCompleteReminder;
  final Future<void> Function(CalendarReminder reminder)? onSnoozeReminder;
  final Future<void> Function(CalendarReminder reminder)? onEditReminder;
  final Future<void> Function(CalendarReminder reminder)? onConvertReminderToTask;
  final bool Function(CalendarReminder reminder)? canMutateReminder;
  final Future<void> Function(DateTime date)? onCreateTaskForDate;

  @override
  State<OfficialCalendarPage> createState() => _OfficialCalendarPageState();
}

class IranianOfficialCalendarPage extends OfficialCalendarPage {
  const IranianOfficialCalendarPage({
    super.key,
    super.reminders,
    super.initialSelectedDay,
    super.onCompleteReminder,
    super.onSnoozeReminder,
    super.onEditReminder,
    super.onConvertReminderToTask,
    super.canMutateReminder,
    super.onCreateTaskForDate,
  }) : super(
         service: const OfficialCalendarReminderService(<OfficialCalendarReminderSource>[
           IranianOfficialHolidaySource(),
           IranianPrayerTimeSource(),
         ]),
         years: const <int>[2026, 2027],
       );
}

class _OfficialCalendarPageState extends State<OfficialCalendarPage> {
  late Future<List<CalendarReminder>> _loadFuture;
  final PrayerCompletionStore _prayerStore = const PrayerCompletionStore();
  List<PrayerCompletionRecord> _prayerRecords = const [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
    _loadPrayerRecords();
  }

  Future<void> _loadPrayerRecords() async {
    List<PrayerCompletionRecord> records;
    try {
      records = await _prayerStore.load();
    } catch (_) {
      records = const [];
    }
    if (!mounted) return;
    setState(() => _prayerRecords = records);
  }

  Future<List<CalendarReminder>> _load() async {
    final officialGroups = await Future.wait(widget.years.map((year) => widget.service.load(year: year)));
    final byId = <String, CalendarReminder>{for (final reminder in widget.reminders) reminder.id: reminder};
    for (final reminder in officialGroups.expand((group) => group)) {
      byId.putIfAbsent(reminder.id, () => reminder);
    }
    final merged = byId.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(merged);
  }

  void _retry() => setState(() => _loadFuture = _load());

  PrayerCompletionStatus? _prayerStatus(CalendarReminder reminder) => const PrayerCompletionProjection().statusFor(
        _prayerRecords,
        day: reminder.date,
        prayerId: reminder.id,
      );

  Future<void> _setPrayerStatus(CalendarReminder reminder, PrayerCompletionStatus status) async {
    await _prayerStore.setStatus(day: reminder.date, prayerId: reminder.id, status: status);
    final records = await _prayerStore.load();
    if (!mounted) return;
    setState(() => _prayerRecords = records);
  }

  Future<void> _openPrayerReport() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PrayerCompletionReportPage(store: _prayerStore),
      ),
    );
    await _loadPrayerRecords();
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
                  TextButton(onPressed: _retry, child: const Text('تلاش دوباره')),
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
        return Stack(
          children: [
            CalendarPage(
              reminders: snapshot.requireData,
              initialSelectedDay: widget.initialSelectedDay,
              onCompleteReminder: widget.onCompleteReminder,
              onSnoozeReminder: widget.onSnoozeReminder,
              onEditReminder: widget.onEditReminder,
              onConvertReminderToTask: widget.onConvertReminderToTask,
              canMutateReminder: widget.canMutateReminder,
              onCreateTaskForDate: widget.onCreateTaskForDate,
              prayerStatusFor: _prayerStatus,
              onPrayerCompleted: (reminder) => _setPrayerStatus(reminder, PrayerCompletionStatus.completed),
              onPrayerNotCompleted: (reminder) => _setPrayerStatus(reminder, PrayerCompletionStatus.notCompleted),
            ),
            PositionedDirectional(
              top: MediaQuery.paddingOf(context).top + 8,
              start: 8,
              child: SafeArea(
                child: IconButton.filledTonal(
                  key: const ValueKey('calendar-prayer-report'),
                  tooltip: 'گزارش نماز',
                  onPressed: _openPrayerReport,
                  icon: const Icon(Icons.assessment_outlined),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
