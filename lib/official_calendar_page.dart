import 'package:flutter/material.dart';

import 'calendar_official_reminders.dart';
import 'calendar_page.dart';
import 'iranian_official_holiday_source.dart';
import 'iranian_prayer_time_source.dart';
import 'services/app_settings_service.dart';
import 'services/external_calendar_event_projection.dart';
import 'services/external_calendar_link_store.dart';
import 'services/system_calendar_bridge.dart';

/// Loads official providers and user-approved external device-calendar events,
/// then hands their read-only presentation to the existing [CalendarPage].
///
/// Device events are never converted to canonical Task/FollowUp data here.
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

  /// Optional injection points keep provider reads testable without creating a
  /// second settings or calendar engine.
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
    super.settingsService,
    super.calendarBridge,
    super.externalLinkStore,
    super.externalProjection,
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

  Future<List<CalendarReminder>> _loadExternalEvents() async {
    try {
      final settings = await (widget.settingsService ?? AppSettingsService()).load();
      final integration = settings.calendarIntegration;
      if (!integration.enabled ||
          !integration.showExternalEvents ||
          integration.visibleCalendarIds.isEmpty) {
        return const <CalendarReminder>[];
      }

      final bridge = widget.calendarBridge ?? SystemCalendarBridge();
      if (!await bridge.hasReadPermission()) {
        // Calendar screens never trigger a permission prompt implicitly. The
        // user grants access explicitly from Settings → تقویم و همگام‌سازی.
        return const <CalendarReminder>[];
      }

      final calendarIds = integration.visibleCalendarIds.toList()..sort();
      final boundedIds = calendarIds
          .take(SystemCalendarBridge.maxEventQueryCalendars)
          .toList(growable: false);
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 31));
      final end = start.add(SystemCalendarBridge.maxEventQueryWindow);
      final events = await bridge.listDeviceCalendarEvents(
        calendarIds: boundedIds,
        start: start,
        end: end,
      );

      var links = const <dynamic>[];
      try {
        links = await (widget.externalLinkStore ?? ExternalCalendarLinkStore()).load();
      } on FormatException {
        // Corrupt provider-link metadata must never break the Calendar UI.
      }

      return (widget.externalProjection ?? const ExternalCalendarEventProjection())
          .project(events, linkedEvents: links.cast());
    } catch (_) {
      // Provider/permission failures are non-fatal: canonical Arvin and
      // official calendar content must continue to render normally.
      return const <CalendarReminder>[];
    }
  }

  Future<List<CalendarReminder>> _load() async {
    final officialGroups = await Future.wait(
      widget.years.map((year) => widget.service.load(year: year)),
    );
    final external = await _loadExternalEvents();
    final byId = <String, CalendarReminder>{
      for (final reminder in widget.reminders) reminder.id: reminder,
    };
    for (final reminder in officialGroups.expand((group) => group)) {
      byId.putIfAbsent(reminder.id, () => reminder);
    }
    for (final reminder in external) {
      byId.putIfAbsent(reminder.id, () => reminder);
    }
    final merged = byId.values.toList()..sort((a, b) => a.date.compareTo(b.date));
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
        return CalendarPage(
          reminders: snapshot.requireData,
          initialSelectedDay: widget.initialSelectedDay,
          onCompleteReminder: widget.onCompleteReminder,
          onSnoozeReminder: widget.onSnoozeReminder,
          onEditReminder: widget.onEditReminder,
          onConvertReminderToTask: widget.onConvertReminderToTask,
        );
      },
    );
  }
}
