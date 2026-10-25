import 'package:flutter/material.dart';

import '../calendar_page.dart';
import '../models/task.dart';
import '../notebook_page.dart';
import '../official_calendar_page.dart';
import '../services/calendar_inbound_sync_service.dart';
import '../services/follow_up_calendar_projection.dart';
import '../services/system_calendar_bridge.dart';
import '../task_next_action_page.dart';
import '../task_timeline_page.dart';
import 'arvin_primary_navigation.dart';
import 'contextual_help.dart';

/// Small UI boundary that keeps Home unaware of calendar/timeline/next-action
/// projection details while reusing canonical Tasks supplied by Home.
class CanonicalCalendarLauncher extends StatefulWidget {
  const CanonicalCalendarLauncher({
    super.key,
    required this.tasks,
    this.projection = const FollowUpCalendarProjection(),
    this.onRefreshTasks,
    this.onCreateTaskForDate,
    this.onCreateTaskFromCalendarEvent,
    this.onEditTask,
    this.onDeleteTask,
    this.onRegisterTaskToDeviceCalendar,
    this.onRetryCalendarSync,
    this.onOpenReports,
  });

  final List<Task> tasks;
  final FollowUpCalendarProjection projection;
  /// Reloads canonical Tasks before timeline access so the launcher never
  /// relies on a stale snapshot after another route writes to SQL.
  final Future<List<Task>> Function()? onRefreshTasks;
  final Future<Task?> Function(DateTime date)? onCreateTaskForDate;
  final Future<Task?> Function(CalendarReminder reminder)? onCreateTaskFromCalendarEvent;
  final Future<void> Function(Task task)? onEditTask;
  final Future<void> Function(Task task)? onDeleteTask;
  final Future<void> Function(CalendarReminder reminder)? onRegisterTaskToDeviceCalendar;
  final Future<void> Function()? onRetryCalendarSync;
  final Future<void> Function()? onOpenReports;

  @override
  State<CanonicalCalendarLauncher> createState() =>
      _CanonicalCalendarLauncherState();
}

class _CanonicalCalendarLauncherState extends State<CanonicalCalendarLauncher> {
  late List<Task> _tasks;
  CalendarInboundSyncService get _inboundSync => CalendarInboundSyncService();

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
    Future<void>.microtask(_reconcileDeviceCalendar);
  }

  Future<void> _reconcileDeviceCalendar() async {
    try {
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final result = await _inboundSync.reconcile(
        start: today.subtract(const Duration(days: 31)),
        end: today.add(const Duration(days: 62)),
      );
      if (!mounted || !result.changed) return;
      final refreshed = await widget.onRefreshTasks?.call();
      if (refreshed != null && mounted) {
        setState(() => _tasks = List<Task>.of(refreshed));
      }
      if (result.conflicts > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعارض همگام‌سازی تقویم: ${result.conflicts} مورد بدون تغییر باقی ماند.',
            ),
          ),
        );
      }
    } catch (_) {
      // Calendar access is optional; failure must not block the Arvin calendar.
    }
  }

  @override
  void didUpdateWidget(covariant CanonicalCalendarLauncher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.tasks, widget.tasks)) {
      _tasks = List<Task>.of(widget.tasks);
    }
  }

  Task? _taskForReminder(CalendarReminder reminder) {
    for (final task in _tasks) {
      if (task.trashed) continue;
      final id = reminder.id;
      if (id == widget.projection.dueDateReminderIdFor(task) ||
          id.startsWith('task-due:${task.id}:') ||
          id == widget.projection.taskReminderIdFor(task) ||
          id.startsWith('task-reminder-item:${Uri.encodeComponent(task.id)}:')) {
        return task;
      }
    }
    return null;
  }

  bool _canMutateReminder(CalendarReminder reminder) =>
      _taskForReminder(reminder) != null;

  Future<void> _editReminder(CalendarReminder reminder) async {
    final task = _taskForReminder(reminder);
    final editTask = widget.onEditTask;
    if (task == null || editTask == null) return;
    await editTask(task);
    final refreshed = await widget.onRefreshTasks?.call();
    if (refreshed != null && mounted) {
      setState(() => _tasks = List<Task>.of(refreshed));
    }
  }

  Future<void> _createTaskForDate(DateTime date) async {
    final task = await widget.onCreateTaskForDate?.call(date);
    if (task == null || !mounted || _tasks.any((item) => item.id == task.id)) {
      return;
    }
    setState(() => _tasks.add(task));
  }

  Future<void> _createTaskFromCalendarEvent(CalendarReminder reminder) async {
    final task = await widget.onCreateTaskFromCalendarEvent?.call(reminder);
    if (task == null || !mounted || _tasks.any((item) => item.id == task.id)) return;
    setState(() => _tasks.add(task));
  }

  Future<void> _openExternalReminder(CalendarReminder reminder) async {
    if (!reminder.id.startsWith('external-calendar:')) return;
    final calendarId = reminder.externalCalendarId?.trim();
    final eventId = reminder.externalEventId?.trim();
    if (calendarId == null || calendarId.isEmpty || eventId == null || eventId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شناسهٔ رویداد تقویم گوشی در دسترس نیست.')),
      );
      return;
    }
    try {
      final opened = await SystemCalendarBridge().openDeviceCalendarEvent(
        calendarId: calendarId,
        eventId: eventId,
      );
      if (!mounted || opened) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('باز کردن رویداد در تقویم گوشی ممکن نشد.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تقویم گوشی نتوانست رویداد را برای ویرایش باز کند.')),
      );
    }
  }

  Future<void> _openTimeline(BuildContext context) async {
    final refreshed = await widget.onRefreshTasks?.call();
    if (refreshed != null && mounted) {
      setState(() => _tasks = List<Task>.of(refreshed));
    }
    if (!context.mounted) return;
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
                child: Text(
                  task.title.trim().isEmpty ? 'بدون عنوان' : task.title,
                ),
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

  Widget _notebookShell(
    BuildContext context,
    List<CalendarReminder> reminders,
  ) {
    return ArvinPrimaryPageShell(
      selected: ArvinPrimaryDestination.notebook,
      onSelected: (destination) => _onChildDestinationSelected(
        context,
        destination,
        reminders,
        current: ArvinPrimaryDestination.notebook,
      ),
      child: ContextualHelpOverlay(
        title: 'راهنمای دفترچه',
        steps: _notebookHelpSteps,
        buttonKey: const ValueKey('notebook-context-help'),
        child: NotebookPage(),
      ),
    );
  }

  Widget _nextActionShell(
    BuildContext context,
    List<CalendarReminder> reminders,
  ) {
    return ArvinPrimaryPageShell(
      selected: ArvinPrimaryDestination.nextAction,
      onSelected: (destination) => _onChildDestinationSelected(
        context,
        destination,
        reminders,
        current: ArvinPrimaryDestination.nextAction,
      ),
      child: TaskNextActionPage(tasks: _tasks),
    );
  }

  Future<void> _openNextAction(
    BuildContext context,
    List<CalendarReminder> reminders,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _nextActionShell(context, reminders),
      ),
    );
  }

  Future<void> _openReportsFromCalendar(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    await widget.onOpenReports?.call();
  }

  Future<void> _openNotebook(
    BuildContext context,
    List<CalendarReminder> reminders,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _notebookShell(context, reminders),
      ),
    );
  }

  void _onChildDestinationSelected(
    BuildContext context,
    ArvinPrimaryDestination destination,
    List<CalendarReminder> reminders, {
    required ArvinPrimaryDestination current,
  }) {
    if (destination == current) return;

    switch (destination) {
      case ArvinPrimaryDestination.home:
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      case ArvinPrimaryDestination.calendar:
        Navigator.of(context).pop();
        return;
      case ArvinPrimaryDestination.reports:
        _openReportsFromCalendar(context);
        return;
      case ArvinPrimaryDestination.notebook:
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => _notebookShell(context, reminders),
          ),
        );
        return;
      case ArvinPrimaryDestination.nextAction:
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => _nextActionShell(context, reminders),
          ),
        );
        return;
      case ArvinPrimaryDestination.more:
        _openMore(context, reminders);
        return;
    }
  }

  Future<void> _editTaskFromCalendar(CalendarReminder reminder) async {
    final task = _taskForReminder(reminder);
    final editTask = widget.onEditTask;
    if (task == null || editTask == null) return;
    await editTask(task);
    if (!mounted) return;
    final refreshed = await widget.onRefreshTasks?.call();
    if (refreshed != null && mounted) {
      setState(() => _tasks = List<Task>.of(refreshed));
    }
  }

  Future<void> _deleteTaskFromCalendar(CalendarReminder reminder) async {
    final task = _taskForReminder(reminder);
    final deleteTask = widget.onDeleteTask;
    if (task == null || deleteTask == null) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('انتقال کار به سطل زباله؟'),
        content: Text('«${task.title}» به سطل زباله منتقل می‌شود. اطلاعات و سابقهٔ کار حفظ می‌شود.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('انتقال به سطل زباله'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    await deleteTask(task);
    if (!mounted) return;
    final refreshed = await widget.onRefreshTasks?.call();
    if (refreshed != null && mounted) {
      setState(() => _tasks = List<Task>.of(refreshed));
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
            const SnackBar(
              content: Text('پیگیری فعالی برای افزودن به تقویم دستگاه نیست'),
            ),
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

  Future<void> _retryCalendarSync(BuildContext context) async {
      final retry = widget.onRetryCalendarSync;
      if (retry == null) return;
      try {
        await retry();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('همگام‌سازی تقویم دوباره انجام شد. تغییرات آروین و تقویم گوشی نیز بررسی شد.')),
          );
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('همگام‌سازی انجام نشد: $error')),
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('تقویم دستگاه'),
                subtitle: const Text('افزودن پیگیری فعال به تقویم گوشی'),
                onTap: () =>
                    Navigator.of(sheetContext)
                        .pop(_CalendarMoreAction.systemCalendar),
              ),
              ListTile(
                key: const ValueKey('calendar-retry-device-sync'),
                leading: const Icon(Icons.sync_outlined),
                title: const Text('تلاش دوباره برای همگام‌سازی'),
                subtitle: const Text('به‌روزرسانی دوباره آروین و تقویم گوشی در هر دو جهت'),
                onTap: () => Navigator.of(sheetContext).pop(
                  _CalendarMoreAction.retrySync,
                ),
              ),
              ListTile(
                key: const ValueKey('calendar-more-next-action'),
                leading: const Icon(Icons.next_plan_outlined),
                title: const Text('اقدام بعدی'),
                subtitle: const Text('پیشنهاد بهترین کار بعدی'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_CalendarMoreAction.nextAction),
              ),
              ListTile(
                key: const ValueKey('calendar-more-timeline'),
                leading: const Icon(Icons.timeline_outlined),
                title: const Text('خط زمانی'),
                subtitle: const Text('نمایش روند زمانی یک کار'),
                onTap: () =>
                    Navigator.of(sheetContext)
                        .pop(_CalendarMoreAction.timeline),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case _CalendarMoreAction.systemCalendar:
        await _exportToSystemCalendar(context);
        return;
      case _CalendarMoreAction.retrySync:
        await _retryCalendarSync(context);
        return;
      case _CalendarMoreAction.nextAction:
        await _openNextAction(context, reminders);
        return;
      case _CalendarMoreAction.timeline:
        await _openTimeline(context);
        return;
    }
  }

  void _onBottomDestinationSelected(
    BuildContext context,
    ArvinPrimaryDestination destination,
    List<CalendarReminder> reminders,
  ) {
    switch (destination) {
      case ArvinPrimaryDestination.home:
        Navigator.of(context).maybePop();
        return;
      case ArvinPrimaryDestination.calendar:
        return;
      case ArvinPrimaryDestination.notebook:
        _openNotebook(context, reminders);
        return;
      case ArvinPrimaryDestination.reports:
        _openReportsFromCalendar(context);
        return;
      case ArvinPrimaryDestination.nextAction:
        _openNextAction(context, reminders);
        return;
      case ArvinPrimaryDestination.more:
        _openMore(context, reminders);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders = <CalendarReminder>[
      ...widget.projection.project(
        _tasks.where((task) => task.recurrence == null),
      ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    List<CalendarReminder> projectVisible(DateTime from, DateTime to) {
      final items = <CalendarReminder>[
        ...widget.projection.project(
          _tasks,
          visibleFrom: from,
          visibleTo: to,
        ),
      ]..sort((a, b) => a.date.compareTo(b.date));
      return items;
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ContextualHelpOverlay(
          title: 'راهنمای تقویم',
          steps: _calendarHelpSteps,
          buttonKey: const ValueKey('calendar-context-help'),
          child: IranianOfficialCalendarPage(
            reminders: reminders,
            visibleReminderProjection: projectVisible,
              onEditReminder: _editReminder,
            onEditTask: _editTaskFromCalendar,
            onDeleteTask: _deleteTaskFromCalendar,
            onRegisterTaskToDeviceCalendar: widget.onRegisterTaskToDeviceCalendar,
            onOpenExternalReminder: _openExternalReminder,
            canMutateReminder: _canMutateReminder,
            onCreateTaskForDate: widget.onCreateTaskForDate == null
                ? null
                : _createTaskForDate,
            onCreateTaskFromCalendarEvent: widget.onCreateTaskFromCalendarEvent == null
                ? null
                : _createTaskFromCalendarEvent,
          ),
        ),
        bottomNavigationBar: ArvinPrimaryNavigation(
          selected: ArvinPrimaryDestination.calendar,
          onSelected: (destination) =>
              _onBottomDestinationSelected(context, destination, reminders),
        ),
      ),
    );
  }
}

enum _CalendarMoreAction { systemCalendar, retrySync, nextAction, timeline }


