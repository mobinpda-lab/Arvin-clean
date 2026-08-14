import 'package:flutter/material.dart';

import 'models/task.dart';

/// The dedicated FollowUp office: a chronological, task-aware history view.
///
/// This widget is intentionally presentation-only. TaskStore remains the
/// source of truth; the page receives the current tasks from its caller.
class FollowUpOfficePage extends StatefulWidget {
  const FollowUpOfficePage({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<FollowUpOfficePage> createState() => _FollowUpOfficePageState();
}

class _FollowUpOfficePageState extends State<FollowUpOfficePage> {
  bool _showFutureOnly = false;

  String _digits(String value) {
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], persian[i]);
    }
    return result;
  }

  String _dateTime(DateTime value) {
    final date =
        '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '${_digits(date)} • ساعت ${_digits(time)}';
  }

  List<_FollowUpRow> get _rows {
    final now = DateTime.now();
    final rows = <_FollowUpRow>[];
    for (final task in widget.tasks) {
      for (final followUp in task.followUps) {
        if (_showFutureOnly && followUp.dateTime.isBefore(now)) continue;
        rows.add(_FollowUpRow(task: task, followUp: followUp));
      }
    }
    rows.sort((a, b) => b.followUp.dateTime.compareTo(a.followUp.dateTime));
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر پیگیری'),
        actions: [
          IconButton(
            tooltip: _showFutureOnly ? 'نمایش همه' : 'فقط پیگیری‌های آینده',
            onPressed: () => setState(() => _showFutureOnly = !_showFutureOnly),
            icon: Icon(
              _showFutureOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
          ),
        ],
      ),
      body: rows.isEmpty
          ? Center(
              child: Text(
                _showFutureOnly
                    ? 'پیگیری آینده‌ای ثبت نشده است'
                    : 'هنوز پیگیری‌ای ثبت نشده است',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final row = rows[index];
                final followUp = row.followUp;
                final next = followUp.nextFollowUp;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                row.task.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_dateTime(followUp.dateTime)),
                        if (followUp.note.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(followUp.note),
                        ],
                        if (followUp.result?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Text('نتیجه: ${followUp.result}'),
                        ],
                        if (next != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.event_repeat, size: 18),
                              const SizedBox(width: 6),
                              Text('پیگیری بعدی: ${_dateTime(next)}'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _FollowUpRow {
  const _FollowUpRow({required this.task, required this.followUp});

  final Task task;
  final FollowUp followUp;
}
