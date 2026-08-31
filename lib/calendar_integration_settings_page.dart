import 'package:flutter/material.dart';

import 'services/app_settings_service.dart';

/// User-facing controls for the existing device-calendar integration settings.
///
/// Provider discovery/permissions remain owned by the Android Calendar Provider
/// lane. This page only edits the canonical persisted preferences that already
/// exist in [AppSettingsService].
class CalendarIntegrationSettingsPage extends StatefulWidget {
  const CalendarIntegrationSettingsPage({
    super.key,
    required this.service,
  });

  final AppSettingsService service;

  @override
  State<CalendarIntegrationSettingsPage> createState() =>
      _CalendarIntegrationSettingsPageState();
}

class _CalendarIntegrationSettingsPageState
    extends State<CalendarIntegrationSettingsPage> {
  CalendarIntegrationSettings? settings;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appSettings = await widget.service.load();
    if (!mounted) return;
    setState(() => settings = appSettings.calendarIntegration);
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
                        'پس از آماده‌شدن Calendar Provider، موارد انتخاب‌شده به تقویم مقصد همگام می‌شوند.',
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
                          ? 'هنوز انتخاب نشده؛ پس از دریافت دسترسی و شناسایی Calendar Provider قابل انتخاب می‌شود.'
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
                  const Text(
                    'آروین برای Google Calendar و Samsung Calendar موتور جداگانه نمی‌سازد؛ هر دو از Calendar Provider اندروید استفاده خواهند کرد.',
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
                        'اجرای واقعی پس از اتصال Calendar Provider فعال خواهد شد.',
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
