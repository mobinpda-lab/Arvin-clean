import 'package:flutter/material.dart';

import '../calendar_page.dart';
import '../models/task.dart';
import '../notebook_page.dart';
import '../official_calendar_page.dart';
import '../services/follow_up_calendar_projection.dart';
import '../services/system_calendar_bridge.dart';
import '../task_next_action_page.dart';
import '../task_timeline_page.dart';
import 'contextual_help.dart';

/// Small UI boundary that keeps Home unaware of calendar/timeline/next-action
/// projection details while reusing canonical Tasks supplied by Home.
class CanonicalCalendarLauncher extends StatelessWidget {
  const CanonicalCalendarLauncher({
    super.key,
    required this.tasks,
    this.projection = const FollowUpCalendarProjection(),
  });

  final List<Task> tasks;
  final FollowUpCalendarProjection projection;

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
      icon: Icons.event_available_outlined,
      title: 'تقویم دستگاه',
      body: 'از دکمه «تقویم دستگاه» می‌توانید یک پیگیری فعال را به تقویم گوشی منتقل کنید.',
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

  Future<void> _openTimeline(BuildContext context) async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('کاری برای نمایش خط زمانی وجود ندارد')),
        );
      return;
    }

    Task? selected;
    if (tasks.length == 1) {
      selected = tasks.single;
    } else {
      selected = await showDialog<Task>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('انتخاب کار برای خط زمانی'),
          children: [
            for (final task in tasks)
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
        builder: (_) => TaskNextActionPage(tasks: tasks),
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

  Future<void> _exportToSystemCalendar(BuildContext context) async {
    final eligible = projection
        .project(tasks)
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

  @override
  Widget build(BuildContext context) {
    final reminders = projection.project(tasks);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Positioned.fill(
            child: ContextualHelpOverlay(
              title: 'راهنمای تقویم',
              steps: _calendarHelpSteps,
              buttonKey: const ValueKey('calendar-context-help'),
              child: IranianOfficialCalendarPage(reminders: reminders),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'arvin-system-calendar-export',
                  tooltip: 'افزودن پیگیری به تقویم دستگاه',
                  onPressed: () => _exportToSystemCalendar(context),
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('تقویم دستگاه'),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'arvin-canonical-notebook',
                  tooltip: 'دفترچه آروین',
                  onPressed: () => _openNotebook(context),
                  icon: const Icon(Icons.note_alt_outlined),
                  label: const Text('دفترچه'),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'arvin-canonical-next-action',
                  tooltip: 'اقدام بعدی هوشمند',
                  onPressed: () => _openNextAction(context),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('اقدام بعدی'),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'arvin-canonical-timeline',
                  tooltip: 'خط زمانی کار',
                  onPressed: () => _openTimeline(context),
                  icon: const Icon(Icons.timeline_outlined),
                  label: const Text('خط زمانی'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
