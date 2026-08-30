import 'package:flutter/material.dart';

import 'daily_content.dart';
import 'services/daily_content_preferences_service.dart';

class DailyContentSettingsPage extends StatefulWidget {
  const DailyContentSettingsPage({
    super.key,
    required this.service,
  });

  final DailyContentPreferencesService service;

  @override
  State<DailyContentSettingsPage> createState() =>
      _DailyContentSettingsPageState();
}

class _DailyContentSettingsPageState extends State<DailyContentSettingsPage> {
  DailyContentPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final value = await widget.service.load();
    if (!mounted) return;
    setState(() => _preferences = value);
  }

  Future<void> _setEnabled(bool value) async {
    await widget.service.saveEnabled(value);
    await _reload();
  }

  Future<void> _setNotificationEnabled(bool value) async {
    await widget.service.saveNotificationEnabled(value);
    await _reload();
  }

  Future<void> _setKind(DailyContentKind kind, bool value) async {
    await widget.service.saveKindEnabled(kind, value);
    await _reload();
  }

  Future<void> _pickTime() async {
    final current = _preferences;
    if (current == null) return;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current.notificationHour,
        minute: current.notificationMinute,
      ),
    );
    if (selected == null) return;
    await widget.service.saveNotificationTime(
      hour: selected.hour,
      minute: selected.minute,
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final current = _preferences;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('پیام روز')),
        body: current == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('نمایش پیام روز در تقویم'),
                    subtitle: const Text(
                      'پیام روز جدا از شمارنده کارها و پیگیری‌ها نمایش داده می‌شود.',
                    ),
                    value: current.enabled,
                    onChanged: _setEnabled,
                  ),
                  const Divider(height: 28),
                  const Text(
                    'دسته‌های محتوا',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  for (final kind in DailyContentKind.values)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_label(kind)),
                      value: current.enabledKinds.contains(kind),
                      onChanged: current.enabled
                          ? (value) => _setKind(kind, value)
                          : null,
                    ),
                  const Divider(height: 28),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('اعلان پیام روز'),
                    subtitle: const Text(
                      'اختیاری است؛ خاموش‌کردن اعلان، پیام روز را از تقویم حذف نمی‌کند.',
                    ),
                    value: current.notificationEnabled,
                    onChanged:
                        current.enabled ? _setNotificationEnabled : null,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: current.enabled && current.notificationEnabled,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('زمان اعلان'),
                    subtitle: Text(
                      TimeOfDay(
                        hour: current.notificationHour,
                        minute: current.notificationMinute,
                      ).format(context),
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: current.enabled && current.notificationEnabled
                        ? _pickTime
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'فقط محتوای دارای منبع، مأخذ و مرجع تأیید وارد چرخه پیام روز می‌شود.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}

String _label(DailyContentKind kind) {
  return switch (kind) {
    DailyContentKind.quran => 'قرآن کریم',
    DailyContentKind.nahjAlBalagha => 'نهج‌البلاغه',
    DailyContentKind.shiaHadith => 'حدیث معتبر شیعه',
    DailyContentKind.sahifaSajjadiya => 'صحیفه سجادیه',
    DailyContentKind.iranianQuote => 'سخن بزرگان ایران',
    DailyContentKind.worldQuote => 'سخن بزرگان جهان',
  };
}
