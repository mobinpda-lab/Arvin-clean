import 'package:flutter/material.dart';

import 'arvin_colors.dart';

import 'android_automatic_follow_up_scheduler.dart';
import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'follow_up_repository.dart';
import 'models/task.dart';
import 'services/task_store.dart';
import 'services/follow_up_write_coordinator.dart';
import 'services/persian_date_formatter.dart';
import 'services/waiting_for_response_service.dart';

class FollowUpOfficePage extends StatefulWidget {
  const FollowUpOfficePage({
    super.key,
    this.repository = const FollowUpRepository(),
    this.writeCoordinator,
  });

  final FollowUpRepository repository;
  final FollowUpWriteCoordinator? writeCoordinator;

  @override
  State<FollowUpOfficePage> createState() => _FollowUpOfficePageState();
}

class _FollowUpOfficePageState extends State<FollowUpOfficePage> {
  static const _waitingService = WaitingForResponseService();
  static const _dateFormatter = PersianDateFormatter();

  late final FollowUpWriteCoordinator _writer;
  bool _loading = true;
  bool _saving = false;
  bool _showWaitingOnly = false;
  List<_TaskOption> _tasks = const [];
  List<_FollowUpRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _writer = widget.writeCoordinator ??
        FollowUpWriteCoordinator(
          repository: widget.repository,
          scheduler: AndroidAutomaticFollowUpScheduler(),
          reminderReschedule: AndroidFollowUpReminderScheduler().reschedule,
        );
    _load();
  }

  Future<void> _load() async {
    final canonicalTasks = await TaskStore().load();
    final tasks = <_TaskOption>[];
    final rows = <_FollowUpRow>[];
    for (final task in canonicalTasks) {
      final id = task.id;
      if (id.isNotEmpty) {
        tasks.add(_TaskOption(
          id: id,
          title: task.title.trim().isEmpty ? 'بدون عنوان' : task.title,
        ));
      }
      if (!task.completed && !task.archived && !task.trashed &&
          task.followUps.isNotEmpty) {
        for (final followUp in task.followUps) {
          rows.add(_FollowUpRow(
            taskId: id,
            taskTitle: task.title,
            followUp: followUp,
          ));
        }
      }
    }
    rows.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _rows = rows;
      _loading = false;
    });
  }

  Future<_TaskOption?> _selectTask() async {
    if (_tasks.isEmpty) {
      _showMessage('ابتدا یک کار ثبت کنید');
      return null;
    }
    if (_tasks.length == 1) return _tasks.single;

    return showDialog<_TaskOption>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('انتخاب کار'),
        children: [
          for (final task in _tasks)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(task),
              child: Row(
                children: [
                  const Icon(Icons.task_alt_outlined),
                  const SizedBox(width: 10),
                  Expanded(child: Text(task.title)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addFollowUp() async {
    final task = await _selectTask();
    if (task == null || !mounted) return;

    final followUp = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute(builder: (_) => const FollowUpEntryPage()),
    );
    if (followUp == null || !mounted) return;

    setState(() => _saving = true);
    try {
      await _writer.add(task.id, followUp);
      await _load();
      if (mounted) {
        _showMessage('پیگیری برای «${task.title}» ثبت شد');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('ثبت پیگیری انجام نشد؛ دوباره تلاش کنید');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _editFollowUp(_FollowUpRow row) async {
    if (row.taskId.isEmpty || !mounted) return;

    final updated = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute(
        builder: (_) => FollowUpEntryPage(initialFollowUp: row.followUp),
      ),
    );
    if (updated == null || !mounted) return;

    setState(() => _saving = true);
    try {
      await _writer.update(row.taskId, updated);
      await _load();
      if (mounted) {
        _showMessage('پیگیری «${row.taskTitle}» ویرایش شد');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('ویرایش پیگیری انجام نشد؛ دوباره تلاش کنید');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _dateTime(DateTime value) {
    final date = _dateFormatter.format(value, usePersianDate: true);
    final time = _dateFormatter.toPersianDigits(
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    );
    return '$date • ساعت $time';
  }

  String _resultLabel(String? result) {
    if (_waitingService.isWaitingResult(result)) return 'منتظر پاسخ';
    return result?.trim() ?? '';
  }

  List<_FollowUpRow> get _waitingRows {
    final latestByTask = <String, _FollowUpRow>{};
    for (final row in _rows) {
      if (row.taskId.isEmpty) continue;
      final current = latestByTask[row.taskId];
      if (current == null || row.dateTime.isAfter(current.dateTime)) {
        latestByTask[row.taskId] = row;
      }
    }

    final waiting = latestByTask.values
        .where((row) => _waitingService.isWaitingResult(row.result))
        .toList();
    waiting.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return waiting;
  }

  List<_FollowUpRow> get _visibleRows {
    return _showWaitingOnly ? _waitingRows : List<_FollowUpRow>.of(_rows);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    return Scaffold(
      backgroundColor: ArvinColors.background,
      appBar: AppBar(
        backgroundColor: ArvinColors.surface,
        foregroundColor: ArvinColors.textPrimary,
        title: const Text('دفتر پیگیری'),
        actions: [
          IconButton(
            tooltip: _showWaitingOnly ? 'نمایش همه پیگیری‌ها' : 'فقط منتظر پاسخ',
            onPressed: () => setState(() {
              _showWaitingOnly = !_showWaitingOnly;
            }),
            icon: Icon(
              _showWaitingOnly ? Icons.hourglass_top : Icons.hourglass_top_outlined,
            ),
          ),
          IconButton(
            onPressed: _saving ? null : _load,
            tooltip: 'بازخوانی',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
              ? Center(
                  child: Text(
                    _showWaitingOnly
                        ? 'موردی در انتظار پاسخ نیست'
                        : 'هنوز پیگیری‌ای ثبت نشده است',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ArvinColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final row = rows[index];
                    final resultLabel = _resultLabel(row.result);
                    final waiting = _waitingService.isWaitingResult(row.result);
                    return Card(
                      color: waiting ? ArvinColors.reminderSoft : ArvinColors.projectSoft,
                      elevation: 1,
                      shadowColor: ArvinColors.shadowSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: waiting
                              ? ArvinColors.reminder.withValues(alpha: 0.20)
                              : ArvinColors.project.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, color: waiting ? ArvinColors.reminder : ArvinColors.project),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    row.taskTitle,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: ArvinColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (waiting)
                                  Chip(
                                    backgroundColor: ArvinColors.reminderSoft,
                                    avatar: const Icon(Icons.hourglass_top, size: 16, color: ArvinColors.reminder),
                                    label: const Text('منتظر پاسخ'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                IconButton(
                                  tooltip: 'ویرایش پیگیری',
                                  onPressed: _saving || row.taskId.isEmpty
                                      ? null
                                      : () => _editFollowUp(row),
                                  icon: const Icon(Icons.edit_outlined, color: ArvinColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                               _dateTime(row.dateTime),
                               style: const TextStyle(color: ArvinColors.textSecondary, fontWeight: FontWeight.w600),
                             ),
                            if (row.note.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(row.note),
                            ],
                            if (resultLabel.isNotEmpty && !waiting) ...[
                              const SizedBox(height: 6),
                              Text('نتیجه: $resultLabel'),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ArvinColors.primary,
        foregroundColor: Colors.white,
        onPressed: _loading || _saving ? null : _addFollowUp,
        icon: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const Text('ثبت پیگیری'),
      ),
    );
  }
}

class _TaskOption {
  const _TaskOption({required this.id, required this.title});

  final String id;
  final String title;
}

class _FollowUpRow {
  const _FollowUpRow({
    required this.taskId,
    required this.taskTitle,
    required this.followUp,
  });

  final String taskId;
  final String taskTitle;
  final FollowUp followUp;

  DateTime get dateTime => followUp.dateTime;
  String get note => followUp.note;
  String? get result => followUp.result;
}
