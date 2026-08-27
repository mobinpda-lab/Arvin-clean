import 'package:flutter/material.dart';

import '../android_automatic_follow_up_scheduler.dart';
import '../calendar_page.dart';
import '../follow_up_repository.dart';
import '../models/task.dart';
import '../notebook_page.dart';
import '../official_calendar_page.dart';
import '../services/calendar_reschedule_apply_service.dart';
import '../services/calendar_rescheduling_advisor.dart';
import '../services/follow_up_calendar_projection.dart';
import '../services/follow_up_write_coordinator.dart';
import '../services/system_calendar_bridge.dart';
import '../task_next_action_page.dart';
import '../task_timeline_page.dart';
import 'contextual_help.dart';

/// Small UI boundary that keeps Home unaware of calendar/timeline/next-action
/// projection details while reusing canonical Tasks supplied by Home.
class CanonicalCalendarLauncher extends StatefulWidget {
  const CanonicalCalendarLauncher({
    super.key,
    required this.tasks,
    this.projection = const FollowUpCalendarProjection(),
    this.reschedulingAdvisor = const CalendarReschedulingAdvisor(),
    this.rescheduleApplyService,
  });

  final List<Task> tasks;
  final FollowUpCalendarProjection projection;
  final CalendarReschedulingAdvisor reschedulingAdvisor;
  final CalendarRescheduleApplyService? rescheduleApplyService;

  @override
  State<CanonicalCalendarLauncher> createState() =>
      _CanonicalCalendarLauncherState();
}

class _CanonicalCalendarLauncherState extends State<CanonicalCalendarLauncher> {
  late final List<Task> _tasks;

  CalendarRescheduleApplyService get _applyService =>
      widget.rescheduleApplyService ??
      CalendarRescheduleApplyService(
        writer: FollowUpWriteCoordinator(
          repository: const FollowUpRepository(),
          scheduler: AndroidAutomaticFollowUpScheduler(),
        ),
      );

  static const _calendarHelpSteps = <ContextualHelpStep>[
    ContextualHelpStep(
      icon: Icons.touch_app_outlined,
      title: 'انتخاب روز',
      body: 'روی هر روز بزنید تا پیگیری‌ها، مناسبت‌ها و اطلاعات همان روز پایین تقویم دیده شود.',
    ),
    ContextualHelpStep(
      icon: Icons.swap_horiz,
      title: 'تغییر ماه',
      body: 'با فلش‌های کنار نام ماه بین ماه قبل و بعد جابه‌جا شوید.',
    ),
    ContextualHelpStep(
      icon: Icons.today_outlined,
      title: 'برگشت به امروز',
      body: 'دکمه «امروز» شما را مستقیم به تاریخ امروز برمی‌گرداند.',
    ),
    ContextualHelpStep(
      icon: Icons.notifications_active_outlined,
      title: 'پیگیری‌ها و مناسبت‌ها',
      body: 'عدد کوچک روی روز یعنی آن روز موردی برای دیدن دارد؛ جزئیات در پایین صفحه نمایش داده می‌شود.',
    ),
    ContextualHelpStep(
      icon: Icons.warning_amber_outlined,
      title: 'بررسی تداخل‌ها',
      body: 'از «بیشتر» و سپس «تداخل‌ها» پیگیری‌های زمان‌دار را بررسی کنید؛ هیچ تغییری بدون تأیید شما اعمال نمی‌شود.',
    ),
    ContextualHelpStep(
      icon: Icons.event_available_outlined,
      title: 'تقویم دستگاه',
      body: 'از «بیشتر» و سپس «تقویم دستگاه» می‌توانید یک پیگیری فعال را به تقویم گوشی منتقل کنید.',
    ),
  ];

  static const _notebookHelpSteps = <ContextualHelpStep>[
    ContextualHelpStep(
      icon: Icons.add_circle_outline,
      title: 'یادداشت جدید',
      body: 'دکمه «یادداشت جدید» را بزنید و بین یادداشت ساده یا چک‌لیست انتخاب کنید.',
    ),
    ContextualHelpStep(
      icon: Icons.checklist_outlined,
      title: 'قالب آماده',
      body: 'برای چک‌لیست می‌توانید از قالب خرید، سفر، کارهای امروز یا فهرست خالی شروع کنید.',
    ),
    ContextualHelpStep(
      icon: Icons.edit_outlined,
      title: 'ویرایش یادداشت',
      body: 'یادداشت را باز کنید و دکمه ویرایش را بزنید؛ تغییرات هنگام کار ذخیره می‌شوند.',
    ),
    ContextualHelpStep(
      icon: Icons.task_alt_outlined,
      title: 'تیک زدن موارد',
      body: 'در حالت ویرایش می‌توانید موردهای چک‌لیست را تیک بزنید، تغییر دهید یا حذف کنید.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tasks = List<Task>.of(widget.tasks);
  }

  Future<void> _openTimeline(BuildContext context) async {
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('کاری برای نمایش خط زمانی وجود ندارد')),
        );
      return;
    }

    Task? selected;
    if (_tasks.length == 1) {
      selected = _tasks.single;
    } else {
      selected = await showDialog<Task>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('انتخاب کار برای خط زمانی'),
          children: [
            for (final task in _tasks)
              SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(task),
                child: Text(task.title.trim().isEmpty ? 'بدون عنوان' : task.title),
              ),
          ],
        ),
      );
    }

    if (selected == null || !context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskTimelinePage(task: selected!),
      ),
    );
  }

  Future<void> _openNextAction(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskNextActionPage(tasks: _tasks),
      ),
    );
  }

  Future<void> _openNotebook(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: ContextualHelpOverlay(
            title: 'راهنمای دفترچه',
            steps: _notebookHelpSteps,
            buttonKey: const ValueKey('notebook-context-help'),
            child: NotebookPage(),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmAndApplyReschedule(
    BuildContext context,
    _CalendarConflictAdviceEntry entry,
    DateTime proposed,
  ) async {
    final target = widget.projection.resolveTarget(_tasks, entry.reminder.id);
    if (target == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('پیگیری اصلی برای تغییر پیدا نشد')),
        );
      return false;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأیید تغییر زمان'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.reminder.title),
            const SizedBox(height: 12),
            Text('زمان فعلی: ${_time(target.followUp.dateTime)}'),
            Text('زمان پیشنهادی: ${_time(proposed)}'),
            const SizedBox(height: 12),
            const Text('این تغییر فقط با تأیید شما ثبت می‌شود.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('اعمال زمان پیشنهادی'),
          ),
        ],
      ),
    );

    if (approved != true || !context.mounted) return false;

    try {
      final updated = await _applyService.applyConfirmed(
        target: target,
        dateTime: proposed,
      );
      if (!mounted) return false;

      final taskIndex = _tasks.indexWhere((task) => task.id == target.taskId);
      if (taskIndex >= 0) {
        final task = _tasks[taskIndex];
        final followUpIndex =
            task.followUps.indexWhere((item) => item.id == updated.id);
        if (followUpIndex >= 0) {
          setState(() {
            final next = List<FollowUp>.of(task.followUps);
            next[followUpIndex] = updated;
            task.followUps = next;
          });
        }
      }
      return true;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('تغییر زمان انجام نشد؛ دوباره تلاش کنید')),
          );
      }
      return false;
    }
  }

  Future<void> _openConflictAdvice(
    BuildContext context,
    List<CalendarReminder> reminders,
  ) async {
    final entries = <_CalendarConflictAdviceEntry>[];

    for (final reminder in reminders) {
      if (reminder.completed || reminder.isAllDay) continue;
      final dayEnd = DateTime(
        reminder.date.year,
        reminder.date.month,
        reminder.date.day,
      ).add(const Duration(days: 1));
      final advice = widget.reschedulingAdvisor.advise(
        reminders: reminders,
        reminderId: reminder.id,
        windowStart: reminder.date,
        windowEnd: dayEnd,
        limit: 3,
      );
      if (!advice.hasConflict) continue;
      entries.add(
        _CalendarConflictAdviceEntry(
          reminder: reminder,
          advice: advice,
        ),
      );
    }

    if (!context.mounted) return;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  entries.isEmpty
                      ? 'تداخل زمانی پیدا نشد'
                      : 'تداخل‌های زمانی',
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  const Text(
                    'بین پیگیری‌های زمان‌دار فعلی تداخلی دیده نشد.',
                  )
                else
                  for (final entry in entries) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              entry.reminder.title,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_digits('${entry.advice.conflicts.length}')} تداخل در این زمان پیدا شد.',
                            ),
                            const SizedBox(height: 10),
                            if (entry.advice.suggestions.isEmpty)
                              const Text(
                                'تا پایان همین روز زمان خالی پیشنهادی پیدا نشد.',
                              )
                            else ...[
                              const Text('زمان‌های پیشنهادی:'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final suggestion
                                      in entry.advice.suggestions)
                                    ActionChip(
                                      label: Text(
                                        'اعمال ${_time(suggestion.start)}',
                                      ),
                                      onPressed: () async {
                                        final changed =
                                            await _confirmAndApplyReschedule(
                                          sheetContext,
                                          entry,
                                          suggestion.start,
                                        );
                                        if (changed && sheetContext.mounted) {
                                          Navigator.of(sheetContext).pop(true);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 8),
                const Text(
                  'هیچ زمانی بدون تأیید شما تغییر نمی‌کند.',
                ),
              ],
            ),
          ),
        );
      },
    );

    if (applied == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('زمان پیگیری با موفقیت تغییر کرد')),
        );
    }
  }

  Future<void> _exportToSystemCalendar(BuildContext context) async {
    final eligible = widget.projection
        .project(_tasks)
        .where(SystemCalendarBridge.isEligible)
        .toList(growable: false);

    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('پیگیری فعالی برای افزودن به تقویم دستگاه نیست')),
        );
      return;
    }

    CalendarReminder? selected;
    if (eligible.length == 1) {
      selected = eligible.single;
    } else {
      selected = await showDialog<CalendarReminder>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('انتخاب پیگیری برای تقویم دستگاه'),
          children: [
            for (final reminder in eligible)
              SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(reminder),
                child: Text(reminder.title),
              ),
          ],
        ),
      );
    }

    if (selected == null || !context.mounted) return;

    try {
      final opened = await SystemCalendarBridge().insert(selected);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              opened
                  ? 'فرم افزودن رویداد در تقویم دستگاه باز شد'
                  : 'برنامه تقویم سازگار روی دستگاه پیدا نشد',
            ),
          ),
        );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('باز کردن تقویم دستگاه ناموفق بود: $error')),
        );
    }
  }

  Future<void> _openMore(
    BuildContext context,
    List<CalendarReminder> reminders,
  ) async {
    final action = await showModalBottomSheet<_CalendarMoreAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('تقویم دستگاه'),
                subtitle: const Text('افزودن پیگیری فعال به تقویم گوشی'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_CalendarMoreAction.systemCalendar),
              ),
              ListTile(
                leading: const Icon(Icons.timeline_outlined),
                title: const Text('خط زمانی'),
                subtitle: const Text('نمایش روند زمانی یک کار'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_CalendarMoreAction.timeline),
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber_outlined),
                title: const Text('تداخل‌ها'),
                subtitle: const Text('بررسی تداخل پیگیری‌های زمان‌دار'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_CalendarMoreAction.conflicts),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case _CalendarMoreAction.systemCalendar:
        await _exportToSystemCalendar(context);
        return;
      case _CalendarMoreAction.timeline:
        await _openTimeline(context);
        return;
      case _CalendarMoreAction.conflicts:
        await _openConflictAdvice(context, reminders);
        return;
    }
  }

  void _onBottomDestinationSelected(
    BuildContext context,
    int index,
    List<CalendarReminder> reminders,
  ) {
    switch (index) {
      case 0:
        Navigator.of(context).maybePop();
        return;
      case 1:
        return;
      case 2:
        _openNotebook(context);
        return;
      case 3:
        _openNextAction(context);
        return;
      case 4:
        _openMore(context, reminders);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders = widget.projection.project(_tasks);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ContextualHelpOverlay(
          title: 'راهنمای تقویم',
          steps: _calendarHelpSteps,
          buttonKey: const ValueKey('calendar-context-help'),
          child: IranianOfficialCalendarPage(reminders: reminders),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 1,
          onDestinationSelected: (index) =>
              _onBottomDestinationSelected(context, index, reminders),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'خانه',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'تقویم',
            ),
            NavigationDestination(
              icon: Icon(Icons.note_alt_outlined),
              selectedIcon: Icon(Icons.note_alt),
              label: 'دفترچه',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'اقدام بعدی',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'بیشتر',
            ),
          ],
        ),
      ),
    );
  }
}

enum _CalendarMoreAction {
  systemCalendar,
  timeline,
  conflicts,
}

class _CalendarConflictAdviceEntry {
  const _CalendarConflictAdviceEntry({
    required this.reminder,
    required this.advice,
  });

  final CalendarReminder reminder;
  final CalendarReschedulingAdvice advice;
}

String _digits(String value) {
  const western = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], persian[i]);
  }
  return result;
}

String _time(DateTime value) {
  return _digits(
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
  );
}
