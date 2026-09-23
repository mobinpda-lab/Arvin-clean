import 'package:flutter/material.dart';

import 'calendar_official_reminders.dart';
import 'calendar_page.dart';
import 'iranian_official_holiday_source.dart';
import 'iranian_prayer_time_source.dart';
import 'prayer_completion_report_page.dart';
import 'services/app_settings_service.dart';
import 'services/external_calendar_event_projection.dart';
import 'services/external_calendar_link_store.dart';
import 'services/prayer_completion_projection.dart';
import 'services/prayer_completion_store.dart';
import 'services/system_calendar_bridge.dart';

/// Loads canonical, official and user-approved external calendar reminders
/// into the existing Calendar presentation without creating parallel Task data.
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
    this.onOpenExternalReminder,
    this.onCreateTaskFromCalendarEvent,
    this.canMutateReminder,
    this.onCreateTaskForDate,
    this.settingsService,
    this.calendarBridge,
    this.externalLinkStore,
    this.externalProjection,
  });

  final OfficialCalendarReminderService service;
  final List<int> years;
  final List<CalendarReminder> reminders;
  final DateTime? initialSelectedDay;
  final Future<void> Function(CalendarReminder reminder)? onCompleteReminder;
  final Future<void> Function(CalendarReminder reminder)? onSnoozeReminder;
  final Future<void> Function(CalendarReminder reminder)? onEditReminder;
  final Future<void> Function(CalendarReminder reminder)? onConvertReminderToTask;
  final Future<void> Function(CalendarReminder reminder)? onOpenExternalReminder;
  final Future<void> Function(CalendarReminder reminder)? onCreateTaskFromCalendarEvent;
  final bool Function(CalendarReminder reminder)? canMutateReminder;
  final Future<void> Function(DateTime date)? onCreateTaskForDate;
  final Future<void> Function(CalendarReminder reminder)? onCreateTaskFromCalendarEvent;
  final AppSettingsService? settingsService;
  final SystemCalendarBridge? calendarBridge;
  final ExternalCalendarLinkStore? externalLinkStore;
  final ExternalCalendarEventProjection? externalProjection;

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
    super.onOpenExternalReminder,
    super.canMutateReminder,
    super.onCreateTaskForDate,
    super.settingsService,
    super.calendarBridge,
    super.externalLinkStore,
    super.externalProjection,
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

  Future<List<CalendarReminder>> _loadExternalEvents() async {
    try {
      final settings = await (widget.settingsService ?? AppSettingsService()).load();
      final integration = settings.calendarIntegration;
      if (!integration.enabled || !integration.showExternalEvents || integration.visibleCalendarIds.isEmpty) {
        return const <CalendarReminder>[];
      }

      final bridge = widget.calendarBridge ?? SystemCalendarBridge();
      if (!await bridge.hasReadPermission()) return const <CalendarReminder>[];

      final calendarIds = integration.visibleCalendarIds.toList()..sort();
      final boundedIds = calendarIds.take(SystemCalendarBridge.maxEventQueryCalendars).toList(growable: false);
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 31));
      final events = await bridge.listDeviceCalendarEvents(
        calendarIds: boundedIds,
        start: start,
        end: start.add(SystemCalendarBridge.maxEventQueryWindow),
      );

      var links = const <dynamic>[];
      try {
        links = await (widget.externalLinkStore ?? ExternalCalendarLinkStore()).load();
      } on FormatException {
        // Corrupt sync metadata must not break canonical Calendar content.
      }
      return (widget.externalProjection ?? const ExternalCalendarEventProjection()).project(events, linkedEvents: links.cast());
    } catch (_) {
      return const <CalendarReminder>[];
    }
  }

  Future<List<CalendarReminder>> _load() async {
    final officialGroups = await Future.wait(widget.years.map((year) => widget.service.load(year: year)));
    final external = await _loadExternalEvents();
    final byId = <String, CalendarReminder>{for (final reminder in widget.reminders) reminder.id: reminder};
    for (final reminder in officialGroups.expand((group) => group)) {
      byId.putIfAbsent(reminder.id, () => reminder);
    }
    for (final reminder in external) {
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
      MaterialPageRoute<void>(builder: (_) => PrayerCompletionReportPage(store: _prayerStore)),
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
              onOpenExternalReminder: widget.onOpenExternalReminder,
              canMutateReminder: widget.canMutateReminder,
              onCreateTaskForDate: widget.onCreateTaskForDate,
              onCreateTaskFromCalendarEvent: widget.onCreateTaskFromCalendarEvent,
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
