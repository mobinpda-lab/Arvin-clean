import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_store.dart';
import 'services/project_store.dart';
import 'services/calendar_outbound_sync_service.dart';
import 'services/follow_up_calendar_projection.dart';
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
  Future<void> cancel(int notificationId) => _plugin.cancel(id: notificationId);
}

class AlarmOverlayPage extends StatefulWidget {
  const AlarmOverlayPage({
    super.key,
    required this.taskId,
    required this.taskReminderId,
    required this.notificationId,
    this.taskStore,
    this.projectStore,
    this.notificationController,
    this.rescheduleReminders,
    this.now,
    this.completeActionKey,
    this.onLoadComplete,
  });

  final String taskId;
  final String? taskReminderId;
  final int notificationId;
  final TaskStore? taskStore;
  final ProjectStore? projectStore;
  final AlarmOverlayNotificationController? notificationController;
  final Future<void> Function()? rescheduleReminders;
  final DateTime Function()? now;

  /// Optional stable handle for verifying and tapping the real Complete control.
  /// Production callers can omit it; tests can avoid a full-tree Finder traversal.
  final GlobalKey? completeActionKey;

  /// Optional lifecycle signal for tests waiting on the asynchronous load.
  final ValueChanged<String?>? onLoadComplete;

  @override
  State<AlarmOverlayPage> createState() => _AlarmOverlayPageState();
}

class _AlarmOverlayPageState extends State<AlarmOverlayPage> {
  static const _formatter = PersianDateFormatter();
  late final TaskStore _store = widget.taskStore ?? TaskStore();
  late final ProjectStore _projects = widget.projectStore ?? ProjectStore();
  late final AlarmOverlayNotificationController _notifications =
      widget.notificationController ?? FlutterLocalAlarmNotificationController();
  late final Future<void> Function() _reschedule =
      widget.rescheduleReminders ?? AndroidFollowUpReminderScheduler().reschedule;
  late final DateTime Function() _now = widget.now ?? DateTime.now;

  Task? _task;
  TaskReminder? _reminder;
  String? _projectTitle;
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
      final projects = await _projects.load();
      final memberships = projects.where((project) => project.itemIds.contains(task.id));
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
        _projectTitle = memberships.isEmpty ? null : memberships.first.title;
        _loading = false;
      });
      widget.onLoadComplete?.call(null);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
      widget.onLoadComplete?.call(error.toString());
    }
  }

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
        debugPrint('[ARVIN_TIMEOUT_DIAG][SNOOZE] before TaskStore.mutate');
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
        debugPrint('[ARVIN_TIMEOUT_DIAG][SNOOZE] TaskStore.mutate completed');
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

  Future<void> _completeTask() async {
    final task = _task;
    if (task == null || _busy) return;
    setState(() => _busy = true);
    try {
      debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] before TaskStore.mutate');
      await _store.mutate<void>((tasks) {
        final index = tasks.indexWhere((item) => item.id == widget.taskId);
        if (index < 0) throw StateError('Task not found');
        final storedTask = tasks[index];
        if (storedTask.completed) return;
        storedTask.setCompleted(true, at: _now());
        storedTask.updatedAt = _now();
      });
      debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] TaskStore.mutate completed');
      try {
        debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] before reminder reschedule');
        await _reschedule();
        debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] reminder reschedule completed');
      } catch (error) {
        debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] reminder reschedule failed: $error');
        // Canonical Task completion is already persisted; scheduler can retry.
      }
      try {
        debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] before post-completion TaskStore.load');
        final snapshot = await _store.load();
        debugPrint('[ARVIN_TIMEOUT_DIAG][COMPLETE] post-completion TaskStore.load completed; tasks=${snapshot.length}');
        debugPrint('[ARVIN_TIMEOUT_DIAG][CALENDAR] before CalendarOutboundSyncService.sync');
        await CalendarOutboundSyncService().sync(
          const FollowUpCalendarProjection().project(snapshot),
          preserveUnprojectedTaskIds: snapshot
              .where((item) => item.trashed)
              .map((item) => item.id)
              .toSet(),
        );
        debugPrint('[ARVIN_TIMEOUT_DIAG][CALENDAR] CalendarOutboundSyncService.sync completed');
      } catch (error) {
        debugPrint('[ARVIN_TIMEOUT_DIAG][CALENDAR] Calendar outbound sync failed: $error');
        // Match the existing Home save contract: calendar failure never rolls
        // back a successfully persisted Task completion.
      }
      await _notifications.cancel(widget.notificationId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      await _showError('تکمیل کار ذخیره نشد. دوباره تلاش کنید.');
    }
  }

  Future<void> _showSnoozeDurationPicker() async {
    if (_busy || _reminder?.isAllDay != false || _persistedSnoozeAt != null) return;
    var selectedMinutes = _snoozeMinutes;
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('مدت تعویق یادآور'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'کاهش مدت تعویق',
                onPressed: selectedMinutes <= 5
                    ? null
                    : () => setDialogState(() => selectedMinutes -= 5),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${_persianNumber(selectedMinutes)} دقیقه',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                tooltip: 'افزایش مدت تعویق',
                onPressed: selectedMinutes >= 120
                    ? null
                    : () => setDialogState(() => selectedMinutes += 5),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('انصراف'),
            ),
            FilledButton(
              key: const ValueKey('alarm-overlay-snooze-dialog-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(selectedMinutes),
              child: const Text('تأیید تعویق'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _snoozeMinutes = result);
    await _snoozeAlarm();
  }

  Widget _buildOverlay(BuildContext context) {
    final task = _task!;
    final reminder = _reminder!;
    final subtitle = _projectTitle?.trim().isNotEmpty == true
        ? _projectTitle!.trim()
        : task.category?.trim().isNotEmpty == true
            ? task.category!.trim()
            : reminder.title;
    final time = reminder.isAllDay ? 'تمام‌روز' : _formatTime(reminder.date);
    final textTheme = Theme.of(context).textTheme;

    Widget action({
      required String key,
      Key? widgetKey,
      required String label,
      required String semanticLabel,
      required Color background,
      required Color foreground,
      required VoidCallback? onPressed,
      bool outlined = false,
    }) {
      final style = outlined
          ? OutlinedButton.styleFrom(
              foregroundColor: foreground,
              side: BorderSide(color: foreground, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              textStyle: textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.vazirmatnFamily,
                fontWeight: FontWeight.w600,
              ),
            )
          : FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              textStyle: textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.vazirmatnFamily,
                fontWeight: FontWeight.w600,
              ),
            );
      return Semantics(
        button: true,
        label: semanticLabel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: outlined
              ? OutlinedButton(
                  key: widgetKey ?? ValueKey<String>(key),
                  style: style,
                  onPressed: onPressed,
                  child: Text(label, textAlign: TextAlign.center),
                )
              : FilledButton(
                  key: widgetKey ?? ValueKey<String>(key),
                  style: style,
                  onPressed: onPressed,
                  child: Text(label, textAlign: TextAlign.center),
                ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFF0ECFF),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF6554C0),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                task.title,
                                key: const ValueKey('alarm-overlay-task-title'),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleLarge?.copyWith(
                                  fontFamily: AppFonts.vazirmatnFamily,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF25243A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                key: const ValueKey('alarm-overlay-task-subtitle'),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFamily: AppFonts.vazirmatnFamily,
                                  fontSize: 14,
                                  color: const Color(0xFF777487),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          time,
                          key: const ValueKey('alarm-overlay-reminder-time'),
                          textAlign: TextAlign.left,
                          style: textTheme.headlineSmall?.copyWith(
                            fontFamily: AppFonts.vazirmatnFamily,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF25243A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    textDirection: TextDirection.ltr,
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      action(
                        key: 'alarm-overlay-complete',
                        widgetKey: widget.completeActionKey,
                        label: 'تکمیل',
                        semanticLabel: 'تکمیل کار از مسیر اصلی آروین',
                        background: const Color(0xFF238B58),
                        foreground: Colors.white,
                        onPressed: _busy ? null : _completeTask,
                      ),
                      action(
                        key: 'alarm-overlay-snooze',
                        label: 'تعویق',
                        semanticLabel: 'انتخاب مدت و تعویق همین یادآور',
                        background: const Color(0xFF2878C8),
                        foreground: Colors.white,
                        onPressed: _busy || reminder.isAllDay
                            ? null
                            : _showSnoozeDurationPicker,
                      ),
                      action(
                        key: 'alarm-overlay-follow-up',
                        label: 'پیگیری',
                        semanticLabel: 'بازکردن فرم استاندارد ثبت سابقه پیگیری برای همین کار',
                        background: const Color(0xFF6B55B8),
                        foreground: Colors.white,
                        onPressed: _busy ? null : _openFollowUpEntry,
                      ),
                      action(
                        key: 'alarm-overlay-stop',
                        label: 'توقف زنگ',
                        semanticLabel: 'توقف اعلان فعال همین یادآور؛ بدون تکمیل کار یا ثبت سابقه',
                        background: Colors.white,
                        foreground: const Color(0xFFC53E48),
                        onPressed: _busy ? null : _stopAlarm,
                        outlined: true,
                      ),
                    ],
                  ),
                  if (reminder.isAllDay) ...[
                    const SizedBox(height: 8),
                    Text(
                      'این یادآور تمام‌روز است و تعویق زمانی ندارد.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
