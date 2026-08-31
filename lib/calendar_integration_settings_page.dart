import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/app_settings_service.dart';
import 'services/system_calendar_bridge.dart';

/// User-facing controls for device-calendar integration.
///
/// Provider discovery is read-only and uses Android Calendar Provider through
/// [SystemCalendarBridge]. Persisted choices stay in the existing
/// [AppSettingsService]; this page does not introduce a second settings store.
class CalendarIntegrationSettingsPage extends StatefulWidget {
  const CalendarIntegrationSettingsPage({
    super.key,
    required this.service,
    this.calendarBridge,
  });

  final AppSettingsService service;
  final SystemCalendarBridge? calendarBridge;

  @override
  State<CalendarIntegrationSettingsPage> createState() =>
      _CalendarIntegrationSettingsPageState();
}

class _CalendarIntegrationSettingsPageState
    extends State<CalendarIntegrationSettingsPage> {
  late final SystemCalendarBridge calendarBridge;
  CalendarIntegrationSettings? settings;
  List<DeviceCalendarInfo> deviceCalendars = const <DeviceCalendarInfo>[];
  bool providerPermissionGranted = false;
  bool providerLoading = false;
  bool saving = false;
  String? providerError;

  @override
  void initState() {
    super.initState();
    calendarBridge = widget.calendarBridge ?? SystemCalendarBridge();
    _load();
  }

  Future<void> _load() async {
    final appSettings = await widget.service.load();
    if (!mounted) return;
    setState(() => settings = appSettings.calendarIntegration);
    await _refreshProviderState();
  }

  Future<void> _refreshProviderState({bool requestPermission = false}) async {
    if (providerLoading) return;
    setState(() {
      providerLoading = true;
      providerError = null;
    });
    try {
      final granted = requestPermission
          ? await calendarBridge.requestReadPermission()
          : await calendarBridge.hasReadPermission();
      final calendars = granted
          ? await calendarBridge.listDeviceCalendars()
          : const <DeviceCalendarInfo>[];
      if (!mounted) return;
      setState(() {
        providerPermissionGranted = granted;
        deviceCalendars = calendars;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        providerPermissionGranted = false;
        deviceCalendars = const <DeviceCalendarInfo>[];
        providerError = error.message ?? error.code;
      });
    } finally {
      if (mounted) setState(() => providerLoading = false);
    }
  }

  Future<void> _save(CalendarIntegrationSettings next) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await widget.service.saveCalendarIntegrationSettings(next);
      if (!mounted) return;
      setState(() => settings = next);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _switch({
    required Key key,
    required String title,
    required String subtitle,
    required bool value,
    required CalendarIntegrationSettings Function(bool value) update,
  }) {
    return SwitchListTile(
      key: key,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: saving ? null : (enabled) => _save(update(enabled)),
    );
  }

  String _providerLabel(DeviceCalendarInfo calendar) {
    final type = calendar.accountType?.toLowerCase() ?? '';
    if (type.contains('google')) return 'Google Calendar';
    if (type.contains('samsung') || type.contains('osp')) {
      return 'Samsung Calendar';
    }
    return calendar.accountName ?? 'تقویم دستگاه';
  }

  Widget _providerSelection(CalendarIntegrationSettings current) {
    if (providerLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }

    if (!providerPermissionGranted) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'برای دیدن تقویم‌های نصب‌شده، دسترسی فقط‌خواندنی تقویم لازم است. آروین در این مرحله هیچ رویدادی را مستقیم ایجاد، ویرایش یا حذف نمی‌کند.',
              ),
              if (providerError != null) ...[
                const SizedBox(height: 8),
                Text(
                  'دسترسی تقویم در دسترس نیست: $providerError',
                  key: const ValueKey('calendar-provider-error'),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('calendar-request-provider-permission'),
                onPressed: () => _refreshProviderState(requestPermission: true),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('دریافت دسترسی تقویم گوشی'),
              ),
            ],
          ),
        ),
      );
    }

    if (deviceCalendars.isEmpty) {
      return const ListTile(
        key: ValueKey('calendar-provider-empty'),
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.event_busy_outlined),
        title: Text('تقویمی روی دستگاه پیدا نشد'),
        subtitle: Text('پس از اضافه‌شدن حساب تقویم در گوشی، دوباره این صفحه را باز کنید.'),
      );
    }

    return Column(
      children: deviceCalendars.map((calendar) {
        final visible = current.visibleCalendarIds.contains(calendar.id);
        return Card(
          key: ValueKey('calendar-provider-${calendar.id}'),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  calendar.isPrimary
                      ? Icons.star_outline_rounded
                      : Icons.calendar_month_outlined,
                ),
                title: Text(calendar.displayName),
                subtitle: Text(
                  '${_providerLabel(calendar)}${calendar.accountName == null ? '' : ' • ${calendar.accountName}'}',
                ),
              ),
              RadioListTile<String>(
                key: ValueKey('calendar-target-${calendar.id}'),
                title: const Text('تقویم مقصد آروین'),
                subtitle: const Text('برای ارسال موارد آروین در مراحل همگام‌سازی بعدی'),
                value: calendar.id,
                groupValue: current.targetCalendarId,
                onChanged: saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        _save(current.copyWith(targetCalendarId: value));
                      },
              ),
              CheckboxListTile(
                key: ValueKey('calendar-visible-${calendar.id}'),
                title: const Text('نمایش رویدادهای این تقویم در آروین'),
                value: visible,
                onChanged: saving
                    ? null
                    : (checked) {
                        final nextIds = <String>{...current.visibleCalendarIds};
                        if (checked == true) {
                          nextIds.add(calendar.id);
                        } else {
                          nextIds.remove(calendar.id);
                        }
                        _save(current.copyWith(visibleCalendarIds: nextIds));
                      },
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = settings;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تقویم و همگام‌سازی')),
        body: current == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _switch(
                    key: const ValueKey('calendar-integration-enabled'),
                    title: 'اتصال به تقویم دستگاه',
                    subtitle:
                        'خاموش بودن این گزینه هیچ بخشی از آروین را غیرفعال نمی‌کند.',
                    value: current.enabled,
                    update: (value) => current.copyWith(enabled: value),
                  ),
                  _switch(
                    key: const ValueKey('calendar-show-external-events'),
                    title: 'نمایش رویدادهای تقویم گوشی',
                    subtitle:
                        'رویدادهای خارجی فقط برای نمایش هستند و خودکار به کار آروین تبدیل نمی‌شوند.',
                    value: current.showExternalEvents,
                    update: (value) =>
                        current.copyWith(showExternalEvents: value),
                  ),
                  _switch(
                    key: const ValueKey('calendar-sync-outbound'),
                    title: 'ارسال کارهای آروین به تقویم',
                    subtitle:
                        'موارد انتخاب‌شده فقط پس از تکمیل موتور همگام‌سازی به تقویم مقصد ارسال خواهند شد.',
                    value: current.syncArvinToDevice,
                    update: (value) =>
                        current.copyWith(syncArvinToDevice: value),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'تقویم‌های دستگاه',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    key: const ValueKey('calendar-target-status'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_available_outlined),
                    title: const Text('تقویم مقصد'),
                    subtitle: Text(
                      current.targetCalendarId == null
                          ? 'هنوز انتخاب نشده است.'
                          : 'شناسه فعلی: ${current.targetCalendarId}',
                    ),
                  ),
                  ListTile(
                    key: const ValueKey('calendar-visible-status'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.visibility_outlined),
                    title: const Text('تقویم‌های قابل نمایش'),
                    subtitle: Text(
                      current.visibleCalendarIds.isEmpty
                          ? 'هنوز تقویمی از دستگاه انتخاب نشده است.'
                          : '${current.visibleCalendarIds.length} تقویم انتخاب شده: ${current.visibleCalendarIds.join('، ')}',
                    ),
                  ),
                  _providerSelection(current),
                  const SizedBox(height: 8),
                  const Text(
                    'Google Calendar، Samsung Calendar و سایر تقویم‌های اندروید از یک Calendar Provider مشترک استفاده می‌کنند؛ آروین موتور جداگانه و تکراری برای هر برند نمی‌سازد.',
                  ),
                  const Divider(height: 32),
                  const Text(
                    'موارد قابل همگام‌سازی',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _switch(
                    key: const ValueKey('calendar-sync-due-dates'),
                    title: 'موعد کارها',
                    subtitle: 'Due Date کارهای آروین',
                    value: current.syncDueDates,
                    update: (value) => current.copyWith(syncDueDates: value),
                  ),
                  _switch(
                    key: const ValueKey('calendar-sync-task-reminders'),
                    title: 'یادآور کارها',
                    subtitle: 'Reminder مستقل کار',
                    value: current.syncTaskReminders,
                    update: (value) =>
                        current.copyWith(syncTaskReminders: value),
                  ),
                  _switch(
                    key: const ValueKey('calendar-sync-followups'),
                    title: 'پیگیری‌ها',
                    subtitle: 'تاریخ خود پیگیری‌ها',
                    value: current.syncFollowUps,
                    update: (value) => current.copyWith(syncFollowUps: value),
                  ),
                  _switch(
                    key: const ValueKey('calendar-sync-followup-reminders'),
                    title: 'یادآور پیگیری‌ها',
                    subtitle: 'Reminder مستقل هر پیگیری',
                    value: current.syncFollowUpReminders,
                    update: (value) =>
                        current.copyWith(syncFollowUpReminders: value),
                  ),
                  _switch(
                    key: const ValueKey('calendar-sync-recurrence'),
                    title: 'تکرار کارها',
                    subtitle:
                        'خاموش به‌صورت پیش‌فرض؛ فقط پس از فعال‌سازی صریح کاربر.',
                    value: current.syncRecurrence,
                    update: (value) => current.copyWith(syncRecurrence: value),
                  ),
                  const Divider(height: 32),
                  _switch(
                    key: const ValueKey('calendar-auto-sync'),
                    title: 'همگام‌سازی خودکار',
                    subtitle:
                        'اجرای واقعی پس از تکمیل موتور همگام‌سازی فعال خواهد شد.',
                    value: current.autoSync,
                    update: (value) => current.copyWith(autoSync: value),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'حذف رویداد متصل همراه با حذف کار، گزینه‌ای حساس است و به‌صورت پیش‌فرض خاموش می‌ماند.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          _switch(
                            key: const ValueKey('calendar-delete-linked'),
                            title: 'حذف رویداد متصل همراه کار',
                            subtitle:
                                'فقط برای رویدادهای متعلق به آروین؛ رویداد خارجی مستقل حذف نمی‌شود.',
                            value: current.deleteLinkedEventWithTask,
                            update: (value) => current.copyWith(
                              deleteLinkedEventWithTask: value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (saving) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
      ),
    );
  }
}
