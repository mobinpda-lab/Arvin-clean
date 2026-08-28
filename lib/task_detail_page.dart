import 'package:flutter/material.dart';

import 'follow_up_entry_page.dart';
import 'models/task.dart';
import 'services/follow_up_elapsed_formatter.dart';
import 'services/persian_date_formatter.dart';
import 'services/waiting_for_response_service.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({
    super.key,
    required this.task,
    this.onEdit,
    this.onAddFollowUp,
    this.now,
  });

  final Task task;
  final Future<Task?> Function(Task task)? onEdit;
  final Future<Task> Function(Task task, FollowUp followUp)? onAddFollowUp;

  /// Optional fixed clock for deterministic UI tests. Production uses device time.
  final DateTime? now;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  static const _brand = Color(0xFF4A4CAB);
  static const _formatter = PersianDateFormatter();
  static const _elapsedFormatter = FollowUpElapsedFormatter();
  static const _waitingService = WaitingForResponseService();

  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  String _date(DateTime value) =>
      _formatter.format(value, usePersianDate: true);

  String _time(DateTime value) => _formatter.toPersianDigits(
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      );

  String _dateTime(DateTime value) => '${_date(value)} • ${_time(value)}';

  String? _resultLabel(FollowUp followUp) {
    if (_waitingService.isWaitingResult(followUp.result)) return 'منتظر پاسخ';
    final value = followUp.result?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> _edit() async {
    final edit = widget.onEdit;
    if (edit == null) return;
    final updated = await edit(_task);
    if (!mounted || updated == null) return;
    setState(() => _task = updated);
  }

  Future<void> _addFollowUp() async {
    final add = widget.onAddFollowUp;
    if (add == null) return;

    final followUp = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(
        builder: (_) => const FollowUpEntryPage(),
      ),
    );
    if (!mounted || followUp == null) return;

    final updated = await add(_task, followUp);
    if (!mounted) return;
    setState(() => _task = updated);
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    Key? key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E6F7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _brand, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF77778A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF242438),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _followUpCard(
    FollowUp followUp, {
    required FollowUp? previous,
  }) {
    final result = _resultLabel(followUp);
    return Card(
      key: ValueKey('task-detail-followup-${followUp.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.circle, color: _brand, size: 11),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    followUp.note.trim().isEmpty
                        ? 'پیگیری'
                        : followUp.note.trim(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(_dateTime(followUp.dateTime)),
                  if (result != null) ...[
                    const SizedBox(height: 5),
                    Text(result),
                  ],
                  if (previous != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      'فاصله از پیگیری قبلی: ${_elapsedFormatter.interval(followUp.dateTime, previous.dateTime)}',
                      key: ValueKey('task-detail-followup-interval-${followUp.id}'),
                      style: const TextStyle(
                        color: Color(0xFF66667A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _task.lastFollowUp;
    final history = List<FollowUp>.of(_task.followUps)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final current = widget.now ?? DateTime.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: const ValueKey('task-detail-page'),
        appBar: AppBar(
          title: const Text('جزئیات کار'),
          actions: [
            TextButton.icon(
              key: const ValueKey('task-detail-edit'),
              onPressed: widget.onEdit == null ? null : _edit,
              icon: const Icon(Icons.edit_outlined, size: 19),
              label: const Text('ویرایش'),
            ),
            const SizedBox(width: 6),
          ],
        ),
        floatingActionButton: _task.followUpEnabled
            ? FloatingActionButton.small(
                key: const ValueKey('task-detail-add-followup'),
                onPressed: widget.onAddFollowUp == null ? null : _addFollowUp,
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                tooltip: 'ثبت پیگیری',
                child: const Icon(Icons.add),
              )
            : null,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
          children: [
            Text(
              _task.title,
              key: const ValueKey('task-detail-title'),
              style: const TextStyle(
                color: Color(0xFF242438),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (_task.description.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _task.description,
                key: const ValueKey('task-detail-description'),
                style: const TextStyle(height: 1.7),
              ),
            ],
            const SizedBox(height: 18),
            _infoCard(
              key: const ValueKey('task-detail-due-date'),
              icon: Icons.event_available_outlined,
              label: 'موعد کار',
              value: _task.dueDate == null
                  ? 'بدون موعد'
                  : _dateTime(_task.dueDate!),
            ),
            if (_task.reminderDate != null) ...[
              const SizedBox(height: 10),
              _infoCard(
                key: const ValueKey('task-detail-reminder-date'),
                icon: Icons.notifications_none_outlined,
                label: 'یادآور',
                value: _dateTime(_task.reminderDate!),
              ),
            ],
            if (_task.followUpEnabled || history.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoCard(
                key: const ValueKey('task-detail-latest-followup'),
                icon: Icons.history_outlined,
                label: 'آخرین پیگیری',
                value: latest == null
                    ? 'هنوز پیگیری ثبت نشده است'
                    : _dateTime(latest.dateTime),
              ),
              if (latest != null) ...[
                const SizedBox(height: 8),
                Text(
                  '● ${_elapsedFormatter.since(latest.dateTime, now: current)}',
                  key: const ValueKey('task-detail-latest-followup-elapsed'),
                  style: const TextStyle(
                    color: _brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
            if (_task.category?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _infoCard(
                icon: Icons.folder_outlined,
                label: 'دسته‌بندی',
                value: _task.category!.trim(),
              ),
            ],
            if (_task.tags.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'برچسب‌ها',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _task.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
            if (history.isNotEmpty) ...[
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'تاریخچه پیگیری‌ها',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                  ),
                  Text(
                    _formatter.toPersianDigits(history.length.toString()),
                    style: const TextStyle(color: Color(0xFF77778A)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < history.length; index++)
                _followUpCard(
                  history[index],
                  previous:
                      index + 1 < history.length ? history[index + 1] : null,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
