import 'package:flutter/material.dart';

import 'android_automatic_follow_up_scheduler.dart';
import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'follow_up_repository.dart';
import 'models/task.dart';
import 'services/follow_up_elapsed_formatter.dart';
import 'services/follow_up_write_coordinator.dart';
import 'services/persian_date_formatter.dart';
import 'services/waiting_for_response_service.dart';
import 'task_report_page.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({
    super.key,
    required this.task,
    this.onEdit,
    this.onAddFollowUp,
    this.onEditFollowUp,
    this.onComplete,
    this.now,
  });

  final Task task;
  final Future<Task?> Function(Task task)? onEdit;
  final Future<Task> Function(Task task, FollowUp followUp)? onAddFollowUp;
  final Future<FollowUp> Function(Task task, FollowUp followUp)? onEditFollowUp;
  final Future<Task?> Function(Task task)? onComplete;
  final DateTime? now;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  static const _brand = Color(0xFF4A4CAB);
  static const _waiting = Color(0xFFD97706);
  static const _done = Color(0xFF2E8B57);
  static const _danger = Color(0xFFC94B4B);
  static const _muted = Color(0xFF80829C);
  static const _formatter = PersianDateFormatter();
  static const _elapsedFormatter = FollowUpElapsedFormatter();
  static const _waitingService = WaitingForResponseService();

  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  String _date(DateTime value) => _formatter.format(value, usePersianDate: true);

  String _time(DateTime value) => _formatter.toPersianDigits(
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      );

  String _dateTime(DateTime value) => '${_date(value)} • ${_time(value)}';

  String _statusLabel() {
    if (_task.completed) return 'انجام شده';
    final latest = _task.lastFollowUp;
    if (latest != null && _waitingService.isWaitingResult(latest.result)) {
      return 'در انتظار پاسخ';
    }
    return _task.followUpEnabled ? 'کار پیگیری‌دار' : 'در انتظار انجام';
  }

  Color _statusColor() {
    if (_task.completed) return _done;
    final latest = _task.lastFollowUp;
    if (latest != null && _waitingService.isWaitingResult(latest.result)) {
      return _waiting;
    }
    return _task.priority == TaskPriority.high ? _danger : _brand;
  }

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

  Future<void> _openReport() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => TaskReportPage(tasks: [_task])),
    );
  }

  Future<void> _addFollowUp() async {
    final add = widget.onAddFollowUp;
    if (add == null) return;
    final followUp = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(builder: (_) => const FollowUpEntryPage()),
    );
    if (!mounted || followUp == null) return;
    final updated = await add(_task, followUp);
    if (mounted) setState(() => _task = updated);
  }

  Future<void> _editFollowUp(FollowUp existing) async {
    final updated = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(
        builder: (_) => FollowUpEntryPage(initialFollowUp: existing),
      ),
    );
    if (!mounted || updated == null) return;

    try {
      final handler = widget.onEditFollowUp;
      final persisted = handler != null
          ? await handler(_task, updated)
          : await _persistFollowUpUpdate(updated);
      if (!mounted) return;
      final index = _task.followUps.indexWhere((item) => item.id == persisted.id);
      if (index < 0) return;
      setState(() {
        final history = List<FollowUp>.of(_task.followUps);
        history[index] = persisted;
        _task.followUps = history;
        _task.updatedAt = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('ویرایش پیگیری انجام نشد؛ دوباره تلاش کنید')));
    }
  }

  Future<FollowUp> _persistFollowUpUpdate(FollowUp updated) async {
    final writer = FollowUpWriteCoordinator(
      repository: const FollowUpRepository(),
      scheduler: AndroidAutomaticFollowUpScheduler(),
      reminderReschedule: AndroidFollowUpReminderScheduler().reschedule,
    );
    await writer.update(_task.id, updated);
    return updated;
  }

  Widget _badge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7ED)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _brand),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _summaryCard() {
    final statusColor = _statusColor();
    return _card(
      key: const ValueKey('task-detail-summary-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _task.title,
                  key: const ValueKey('task-detail-title'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.25),
                ),
              ),
              _badge(_statusLabel(), statusColor, icon: _task.completed ? Icons.check_circle_outline : Icons.track_changes_outlined),
            ],
          ),
          if (_task.description.trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(_task.description.trim(), key: const ValueKey('task-detail-description'), style: const TextStyle(color: Color(0xFF80829C), height: 1.55)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (_task.category?.trim().isNotEmpty == true)
                _badge(_task.category!.trim(), const Color(0xFF8C68D9), icon: Icons.folder_outlined),
              if (_task.priority != TaskPriority.none)
                _badge(
                  switch (_task.priority) {
                    TaskPriority.high => 'اهمیت زیاد',
                    TaskPriority.medium => 'اهمیت متوسط',
                    TaskPriority.low => 'اهمیت کم',
                    TaskPriority.none => '',
                  },
                  _task.priority == TaskPriority.high ? _danger : _waiting,
                  icon: Icons.flag_outlined,
                ),
              if (_task.followUpEnabled) _badge('پیگیری‌دار', _brand, icon: Icons.timeline_outlined),
              for (final tag in _task.tags.take(4))
                _badge('#${tag.trim()}', const Color(0xFF38A89B), icon: Icons.sell_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_outlined, size: 18, color: _muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _task.dueDate == null ? 'بدون موعد انجام' : _dateTime(_task.dueDate!),
                  key: const ValueKey('task-detail-due-date'),
                  style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              if (_task.reminderDate != null)
                const Icon(Icons.notifications_none_outlined, size: 18, color: _muted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _latestCard(FollowUp? latest, DateTime now) {
    return _card(
      key: const ValueKey('task-detail-latest-followup'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('آخرین پیگیری', Icons.bolt_outlined),
          const SizedBox(height: 10),
          if (latest == null)
            const Text('هنوز پیگیری ثبت نشده است', style: TextStyle(color: _muted))
          else ...[
            Text(
              latest.note.trim().isEmpty ? 'پیگیری' : latest.note.trim(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(_dateTime(latest.dateTime), style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '● ${_elapsedFormatter.since(latest.dateTime, now: now)}',
                    key: const ValueKey('task-detail-latest-followup-elapsed'),
                    style: const TextStyle(color: _brand, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                if (_resultLabel(latest) != null) _badge(_resultLabel(latest)!, _waitingService.isWaitingResult(latest.result) ? _waiting : _brand),
                IconButton(
                  key: ValueKey('task-detail-latest-edit-followup-${latest.id}'),
                  onPressed: () => _editFollowUp(latest),
                  tooltip: 'ویرایش پیگیری',
                  icon: const Icon(Icons.edit_outlined, size: 19),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeline(List<FollowUp> history) {
    if (history.isEmpty) return const SizedBox.shrink();
    return _card(
      key: const ValueKey('task-detail-timeline'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('مسیر پیگیری', Icons.timeline_outlined),
          const SizedBox(height: 12),
          for (var index = 0; index < history.length; index++)
            _timelineItem(
              history[index],
              previous: index + 1 < history.length ? history[index + 1] : null,
              isLast: index == history.length - 1,
              isLatest: index == 0,
            ),
        ],
      ),
    );
  }

  Widget _timelineItem(FollowUp followUp, {required FollowUp? previous, required bool isLast, required bool isLatest}) {
    final result = _resultLabel(followUp);
    final color = _waitingService.isWaitingResult(followUp.result) ? _waiting : _brand;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(width: 2, height: 65, color: color.withValues(alpha: .18)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            key: ValueKey('task-detail-followup-${followUp.id}'),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  followUp.note.trim().isEmpty ? 'پیگیری' : followUp.note.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(_dateTime(followUp.dateTime), style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
                if (result != null && !isLatest) ...[
                  const SizedBox(height: 5),
                  Text(result, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
                if (previous != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'فاصله از پیگیری قبلی: ${_elapsedFormatter.interval(followUp.dateTime, previous.dateTime)}',
                      key: ValueKey('task-detail-followup-interval-${followUp.id}'),
                      style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                IconButton(
                  key: ValueKey('task-detail-edit-followup-${followUp.id}'),
                  onPressed: () => _editFollowUp(followUp),
                  tooltip: 'ویرایش پیگیری',
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextAction(FollowUp? latest) {
    final next = latest?.nextFollowUp;
    if (next == null) return const SizedBox.shrink();
    return _card(
      key: const ValueKey('task-detail-next-action'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _brand.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.next_plan_outlined, color: _brand),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اقدام بعدی', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(_dateTime(next), style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _task.lastFollowUp;
    final history = List<FollowUp>.of(_task.followUps)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final now = widget.now ?? DateTime.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: const ValueKey('task-detail-page'),
        appBar: AppBar(
          title: const Text('جزئیات کار'),
          actions: [
            IconButton(
              key: const ValueKey('task-detail-edit'),
              tooltip: 'ویرایش',
              onPressed: widget.onEdit == null ? null : _edit,
              icon: const Icon(Icons.edit_outlined),
            ),
            PopupMenuButton<String>(
              key: const ValueKey('task-detail-more'),
              tooltip: 'بیشتر',
              onSelected: (value) {
                if (value == 'report') _openReport();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    key: ValueKey('task-detail-report'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.picture_as_pdf_outlined),
                    title: Text('PDF، چاپ و اشتراک‌گذاری'),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (_task.followUpEnabled && !(_task.completed))
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('task-detail-add-followup'),
                    onPressed: widget.onAddFollowUp == null ? null : _addFollowUp,
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن پیگیری'),
                  ),
                ),
              if (_task.followUpEnabled && !_task.completed) const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('task-detail-complete'),
                  onPressed: widget.onComplete == null || _task.completed
                      ? null
                      : () async {
                          final updated = await widget.onComplete!(_task);
                          if (!mounted || updated == null) return;
                          setState(() => _task = updated);
                        },
                  icon: Icon(_task.completed ? Icons.check_circle : Icons.check_circle_outline),
                  label: Text(_task.completed ? 'انجام شده' : 'انجام کار'),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            _summaryCard(),
            const SizedBox(height: 10),
            _latestCard(latest, now),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 10),
              _timeline(history),
            ],
            if (latest?.nextFollowUp != null) ...[
              const SizedBox(height: 10),
              _nextAction(latest),
            ],
            if (_task.reminderDate != null) ...[
              const SizedBox(height: 10),
              _card(
                key: const ValueKey('task-detail-reminder-date'),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_none_outlined, color: _muted),
                    const SizedBox(width: 9),
                    const Text('یادآور', style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(_dateTime(_task.reminderDate!), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
