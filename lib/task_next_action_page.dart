import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/task_next_action_service.dart';
import 'task_report_page.dart';

class TaskNextActionPage extends StatelessWidget {
  const TaskNextActionPage({
    super.key,
    required this.tasks,
    this.service = const TaskNextActionService(),
    this.now,
  });

  final List<Task> tasks;
  final TaskNextActionService service;
  final DateTime? now;

  String _reason(TaskNextActionReason reason) => switch (reason) {
        TaskNextActionReason.overdue => 'عقب‌افتاده',
        TaskNextActionReason.scheduled => 'زمان‌بندی‌شده',
        TaskNextActionReason.unscheduled => 'بدون زمان‌بندی',
      };

  String _dateTime(DateTime value) {
    final date =
        '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date • $time';
  }

  Future<void> _openReports(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskReportPage(tasks: tasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = service.rank(
      tasks,
      now: now ?? DateTime.now(),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اقدام بعدی'),
          actions: [
            IconButton(
              key: const ValueKey('next-action-report'),
              tooltip: 'PDF و چاپ',
              onPressed: () => _openReports(context),
              icon: const Icon(Icons.print_outlined),
            ),
          ],
        ),
        body: suggestions.isEmpty
            ? const Center(child: Text('اقدام بازی برای پیشنهاد وجود ندارد'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final title = suggestion.task.title.trim().isEmpty
                      ? 'بدون عنوان'
                      : suggestion.task.title;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(title),
                      subtitle: Text(
                        suggestion.dueAt == null
                            ? _reason(suggestion.reason)
                            : '${_reason(suggestion.reason)} • ${_dateTime(suggestion.dueAt!)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
