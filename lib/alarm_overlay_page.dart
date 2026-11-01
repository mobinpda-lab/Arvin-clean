import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_store.dart';
import 'theme/app_fonts.dart';

abstract interface class AlarmOverlayNotificationController {
  Future<void> cancel(int notificationId);
}

class FlutterLocalAlarmNotificationController
    implements AlarmOverlayNotificationController {
  FlutterLocalAlarmNotificationController({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> cancel(int notificationId) => _plugin.cancel(notificationId);
}

class AlarmOverlayPage extends StatefulWidget {
  const AlarmOverlayPage({
    super.key,
    required this.taskId,
    required this.taskReminderId,
    required this.notificationId,
    TaskStore? taskStore,
    AlarmOverlayNotificationController? notificationController,
    Future<void> Function()? rescheduleReminders,
    DateTime Function()? now,
  })  : taskStore = taskStore,
        notificationController = notificationController,
        rescheduleReminders = rescheduleReminders,
        now = now;

  final String taskId;
  final String? taskReminderId;
  final int notificationId;
  final TaskStore? taskStore;
  final AlarmOverlayNotificationController? notificationController;
  final Future<void> Function()? rescheduleReminders;
  final DateTime Function()? now;

  @override
  State<AlarmOverlayPage> createState() => _AlarmOverlayPageState();
}

class _AlarmOverlayPageState extends State<AlarmOverlayPage> {
  static const _formatter = PersianDateFormatter();
  late final TaskStore _store = widget.taskStore ?? TaskStore();
  late final AlarmOverlayNotificationController _notifications =
      widget.notificationController ?? FlutterLocalAlarmNotificationController();
  late final Future<void> Function() _reschedule =
      widget.rescheduleReminders ?? AndroidFollowUpReminderScheduler().reschedule;
  late final DateTime Function() _now = widget.now ?? DateTime.now;

  Task? _task;
  TaskReminder? _reminder;
  bool _loading = true;
  bool _busy = false;
  int _snoozeMinutes = 5;
  DateTime? _persistedSnoozeAt;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActiveReminder();
  }

  Future<void> _loadActiveReminder() async {
    try {
      final tasks = await _store.load();
      final taskMatches = tasks.where((item) => item.id == widget.taskId);
      if (taskMatches.length != 1) {
        throw StateError('کار مرتبط پیدا نشد.');
      }
      final task = taskMatches.single;
      if (task.completed || task.archived || task.trashed) {
        throw StateError('یادآور فعال یا کار مرتبط پیدا نشد.');
      }
      final matches = task.taskReminders.where((item) =>
          widget.taskReminderId != null
              ? item.id == widget.taskReminderId
              : item.isLegacyTaskReminder);
      if (matches.length != 1) {
        throw StateError('شناسه یادآور فعال معتبر نیست.');
      }
      if (!mounted) return;
      setState(() {
        _task = task;
        _reminder = matches.single;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime value) =>
      _formatter.format(value, usePersianDate: true);

  String _formatTime(DateTime value) =>
      _formatter.formatTime(value.hour, value.minute);

  String _persianNumber(int value) {
    const digits = '۰۱۲۳۴۵۶۷۸۹';
    return value.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index == null ? digit : digits[index];
    }).join();
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _stopAlarm() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _notifications.cancel(widget.notificationId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      await _showError('توقف اعلان انجام نشد. دوباره تلاش کنید.');
    }
  }

  Future<void> _openFollowUpEntry() async {
    final task = _task;
    if (task == null || _busy) return;
    final followUp = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(
        builder: (_) => FollowUpEntryPage(
          taskId: task.id,
          allowAddingReminder: false,
        ),
      ),
    );
    if (followUp == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _store.addFollowUp(task.id, followUp);
      if (!mounted) return;
      setState(() {
        _task = task..followUps = [...task.followUps, followUp];
        _busy = false;
      });
      await _showError('سابقه پیگیری ذخیره شد.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      await _showError('ذخیره سابقه انجام نشد. دوباره تلاش کنید.');
    }
  }

  Future<void> _snoozeAlarm() async {
    final task = _task;
    final reminder = _reminder;
    if (task == null || reminder == null || _busy || reminder.isAllDay) return;
    setState(() => _busy = true);
    try {
      if (_persistedSnoozeAt == null) {
        final nextTime = _now().add(Duration(minutes: _snoozeMinutes));
        final updated = reminder.copyWith(date: nextTime);
        await _store.mutate<void>((tasks) {
          final taskIndex = tasks.indexWhere((item) => item.id == widget.taskId);
          if (taskIndex < 0) throw StateError('Task not found');
          final storedTask = tasks[taskIndex];
          final reminderIndex = storedTask.taskReminders
              .indexWhere((item) => item.id == reminder.id);
          if (reminderIndex < 0) throw StateError('Reminder not found');
          final reminders = List<TaskReminder>.of(storedTask.taskReminders);
          reminders[reminderIndex] = updated;
          storedTask.taskReminders = reminders;
          storedTask.updatedAt = _now();
        });
        if (!mounted) return;
        setState(() {
          _reminder = updated;
          _persistedSnoozeAt = nextTime;
        });
      }
      await _reschedule();
      await _notifications.cancel(widget.notificationId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      await _showError(
        _persistedSnoozeAt == null
            ? 'تعویق یادآور ذخیره نشد.'
            : 'زمان جدید ذخیره شد، اما زمان‌بندی دوباره انجام نشد. دوباره تلاش کنید.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      fontFamily: AppFonts.vazirmatnFamily,
      textTheme: baseTheme.textTheme.apply(
        fontFamily: AppFonts.vazirmatnFamily,
      ),
    );
    return Theme(
      data: themed,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: themed.colorScheme.surface,
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.alarm_off, size: 48),
                              const SizedBox(height: 16),
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('بستن'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildOverlay(context),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final task = _task!;
    final reminder = _reminder!;
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'بستن',
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: colors.errorContainer,
            child: Icon(Icons.notifications_active, size: 42, color: colors.onErrorContainer),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'زمان یادآور رسیده است',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          task.title,
          key: const ValueKey('alarm-overlay-task-title'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatDate(reminder.date)}  •  ${_formatTime(reminder.date)}',
          key: const ValueKey('alarm-overlay-reminder-time'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const ValueKey('alarm-overlay-stop'),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _busy ? null : _stopAlarm,
          icon: const Icon(Icons.alarm_off),
          label: const Text('توقف آلارم'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('alarm-overlay-follow-up'),
          onPressed: _busy ? null : _openFollowUpEntry,
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('ثبت سابقه'),
        ),
        const SizedBox(height: 24),
        if (!reminder.isAllDay) ...[
          Text('تعویق یادآور', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const ValueKey('alarm-overlay-snooze-minus'),
                onPressed: _busy || _persistedSnoozeAt != null || _snoozeMinutes <= 5
                    ? null
                    : () => setState(() => _snoozeMinutes -= 5),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${_persianNumber(_snoozeMinutes)} دقیقه',
                key: const ValueKey('alarm-overlay-snooze-value'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                key: const ValueKey('alarm-overlay-snooze-plus'),
                onPressed: _busy || _persistedSnoozeAt != null || _snoozeMinutes >= 120
                    ? null
                    : () => setState(() => _snoozeMinutes += 5),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          FilledButton(
            key: const ValueKey('alarm-overlay-snooze-confirm'),
            onPressed: _busy ? null : _snoozeAlarm,
            child: const Text('تعویق آلارم'),
          ),
        ] else
          const Text(
            'برای یادآور تمام‌روز، تعویق زمانی در دسترس نیست.',
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 24),
        Text('صدای اعلان', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          key: const ValueKey('alarm-overlay-volume-info'),
          value: 0.65,
          onChanged: null,
        ),
        const Text(
          'کنترل صدای اعلان از تنظیمات صدای دستگاه انجام می‌شود.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
