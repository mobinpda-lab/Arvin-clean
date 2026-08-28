import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_timeline_service.dart';
import 'task_people_page.dart';
import 'task_recurrence_page.dart';

class TaskTimelinePage extends StatelessWidget {
  const TaskTimelinePage({
    super.key,
    required this.task,
    this.service = const TaskTimelineService(),
  });

  final Task task;
  final TaskTimelineService service;

  static const _formatter = PersianDateFormatter();

  String _formatDateTime(DateTime value) {
    final date = _formatter.format(value, usePersianDate: true);
    final time = _formatter.toPersianDigits(
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    );
    return '$date • $time';
  }

  String _label(TaskTimelineEntryKind kind) => switch (kind) {
        TaskTimelineEntryKind.created => 'ایجاد کار',
        TaskTimelineEntryKind.reminder => 'یادآور',
        TaskTimelineEntryKind.followUp => 'پیگیری',
        TaskTimelineEntryKind.updated => 'آخرین ویرایش',
      };

  IconData _icon(TaskTimelineEntryKind kind) => switch (kind) {
        TaskTimelineEntryKind.created => Icons.add_task_outlined,
        TaskTimelineEntryKind.reminder => Icons.notifications_none,
        TaskTimelineEntryKind.followUp => Icons.history,
        TaskTimelineEntryKind.updated => Icons.edit_outlined,
      };

  Future<void> _openPeople(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskPeoplePage(taskId: task.id),
      ),
    );
  }

  Future<void> _openRecurrence(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskRecurrencePage(initialTaskId: task.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = service.build(task);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خط زمانی'),
          actions: [
            IconButton(
              key: const ValueKey('timeline-open-people'),
              tooltip: 'افراد مرتبط',
              onPressed: () => _openPeople(context),
              icon: const Icon(Icons.people_outline),
            ),
            IconButton(
              key: const ValueKey('timeline-open-recurrence'),
              tooltip: 'تکرار',
              onPressed: () => _openRecurrence(context),
              icon: const Icon(Icons.repeat),
            ),
          ],
        ),
        body: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'هنوز رویدادی برای «${task.title}» ثبت نشده است',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(_icon(entry.kind)),
                      title: Text(_label(entry.kind)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDateTime(entry.dateTime)),
                          if (entry.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(entry.note),
                          ],
                          if (entry.result?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text('نتیجه: ${entry.result}'),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
