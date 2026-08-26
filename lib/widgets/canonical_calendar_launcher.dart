import 'package:flutter/material.dart';

import '../models/task.dart';
import '../official_calendar_page.dart';
import '../services/follow_up_calendar_projection.dart';
import '../task_next_action_page.dart';
import '../task_timeline_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final reminders = projection.project(tasks);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Positioned.fill(
            child: IranianOfficialCalendarPage(reminders: reminders),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
