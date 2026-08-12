import 'package:flutter/material.dart';

import 'backup_schedule.dart';

class BackupSchedulePage extends StatefulWidget {
  const BackupSchedulePage({super.key});

  @override
  State<BackupSchedulePage> createState() => _BackupSchedulePageState();
}

class _BackupSchedulePageState extends State<BackupSchedulePage> {
  BackupSchedule? _schedule;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final schedule = await BackupSchedule.load();
    if (!mounted) return;
    setState(() {
      _schedule = schedule;
      _time = TimeOfDay(hour: schedule.hour, minute: schedule.minute);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 3, minute: 0),
    );
    if (picked == null || _schedule == null) return;
    setState(() {
      _time = picked;
      _schedule = _schedule!.copyWith(hour: picked.hour, minute: picked.minute);
    });
  }

  Future<void> _save() async {
    final schedule = _schedule;
    if (schedule == null) return;
    setState(() => _saving = true);
    await schedule.save();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تنظیمات پشتیبان‌گیری ذخیره شد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _schedule;
    if (schedule == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('زمان‌بندی پشتیبان‌گیری')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              title: const Text('پشتیبان‌گیری خودکار'),
              subtitle: const Text('در زمان تعیین‌شده تنظیمات اجرا خواهد شد'),
              value: schedule.enabled,
              onChanged: (value) {
                setState(() => _schedule = schedule.copyWith(enabled: value));
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              enabled: schedule.enabled,
              leading: const Icon(Icons.schedule),
              title: const Text('زمان پشتیبان‌گیری'),
              subtitle: Text(
                (_time ?? const TimeOfDay(hour: 3, minute: 0)).format(context),
              ),
              onTap: schedule.enabled ? _pickTime : null,
            ),
            const SizedBox(height: 12),
            if (schedule.enabled)
              Text(
                'اجرای بعدی: ${_formatDateTime(schedule.nextRun())}',
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'در حال ذخیره...' : 'ذخیره تنظیمات'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final date = '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date ساعت $time';
  }
}
