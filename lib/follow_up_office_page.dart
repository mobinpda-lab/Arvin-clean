import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'android_automatic_follow_up_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'follow_up_repository.dart';
import 'models/task.dart';
import 'services/automatic_follow_up_service.dart';
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
  static const _storeKey = 'arvin.tasks';
  static const _waitingService = WaitingForResponseService();
  static const _automaticService = AutomaticFollowUpService();
  static const _dateFormatter = PersianDateFormatter();

  late final FollowUpWriteCoordinator _writer;
  bool _loading = true;
  bool _saving = false;
  bool _showFutureOnly = false;
  bool _showWaitingOnly = false;
  bool _showAutomaticDueOnly = false;
  List<Task> _canonicalTasks = const [];
  List<_TaskOption> _tasks = const [];
  List<_FollowUpRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _writer = widget.writeCoordinator ??
        FollowUpWriteCoordinator(
          repository: widget.repository,
          scheduler: AndroidAutomaticFollowUpScheduler(),
        );
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    final canonicalTasks = <Task>[];
    final tasks = <_TaskOption>[];
    final rows = <_FollowUpRow>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as List<dynamic>;
        for (final item in data) {
          final task = Map<String, dynamic>.from(item as Map);
          final id = task['id'] as String? ?? '';
          final title = task['title'] as String? ?? '';
          if (id.isNotEmpty) {
            tasks.add(_TaskOption(
              id: id,
              title: title.trim().isEmpty ? 'بدون عنوان' : title,
            ));
            try {
              canonicalTasks.add(Task.fromJson(task));
            } catch (_) {
              // Keep the existing tolerant office load behavior for malformed
              // legacy rows while excluding them from automatic projections.
            }
          }
          final history = task['followUps'];
          if (history is List && history.isNotEmpty) {
            for (final entry in history) {
              try {
                final followUp = FollowUp.fromJson(
                  Map<String, dynamic>.from(entry as Map),
                );
                rows.add(_FollowUpRow(
                  taskId: id,
                  taskTitle: title,
                  followUp: followUp,
                ));
              } catch (_) {
                continue;
              }
            }
          } else {
            final legacy = DateTime.tryParse(
              task['followUpDate'] as String? ?? '',
            );
            if (legacy != null) {
              rows.add(_FollowUpRow(
                taskId: id,
                taskTitle: title,
                followUp: FollowUp(
                  id: legacy.microsecondsSinceEpoch.toString(),
                  dateTime: legacy,
                  note: 'پیگیری قدیمی مهاجرت‌شده',
                ),
              ));
            }
          }
        }
      } catch (_) {}
    }
    rows.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!mounted) return;
    setState(() {
      _canonicalTasks = canonicalTasks;
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

  List<_FollowUpRow> get _automaticDueRows {
    final rowsByKey = <String, _FollowUpRow>{
      for (final row in _rows)
        if (row.taskId.isNotEmpty) '${row.taskId}\u0000${row.followUp.id}': row,
    };
    final candidates = _automaticService.dueCandidates(
      _canonicalTasks,
      now: DateTime.now(),
    );

    return [
      for (final candidate in candidates)
        if (rowsByKey['${candidate.taskId}\u0000${candidate.followUpId}'] case final row?)
          row,
    ];
  }

  List<_FollowUpRow> get _visibleRows {
    var rows = _showAutomaticDueOnly
        ? _automaticDueRows
        : _showWaitingOnly
            ? _waitingRows
            : List<_FollowUpRow>.of(_rows);
    if (_showFutureOnly) {
      final now = DateTime.now();
      rows = rows.where((row) => row.dateTime.isAfter(now)).toList();
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر پیگیری'),
        actions: [
          IconButton(
            tooltip: _showAutomaticDueOnly
                ? 'نمایش همه پیگیری‌ها'
                : 'فقط پیگیری‌های موعدرسیده',
            onPressed: () => setState(() {
              _showAutomaticDueOnly = !_showAutomaticDueOnly;
              if (_showAutomaticDueOnly) {
                _showWaitingOnly = false;
                _showFutureOnly = false;
              }
            }),
            icon: Icon(
              _showAutomaticDueOnly
                  ? Icons.alarm_on
                  : Icons.alarm_on_outlined,
            ),
          ),
          IconButton(
            tooltip: _showWaitingOnly ? 'نمایش همه پیگیری‌ها' : 'فقط منتظر پاسخ',
            onPressed: () => setState(() {
              _showWaitingOnly = !_showWaitingOnly;
              if (_showWaitingOnly) {
                _showAutomaticDueOnly = false;
              }
            }),
            icon: Icon(
              _showWaitingOnly ? Icons.hourglass_top : Icons.hourglass_top_outlined,
            ),
          ),
          IconButton(
            tooltip: _showFutureOnly ? 'نمایش همه' : 'فقط پیگیری‌های آینده',
            onPressed: () => setState(() {
              _showFutureOnly = !_showFutureOnly;
              if (_showFutureOnly) {
                _showAutomaticDueOnly = false;
              }
            }),
            icon: Icon(
              _showFutureOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
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
                    _showAutomaticDueOnly
                        ? 'پیگیری موعدرسیده‌ای وجود ندارد'
                        : _showWaitingOnly
                            ? 'موردی در انتظار پاسخ نیست'
                            : _showFutureOnly
                                ? 'پیگیری آینده‌ای ثبت نشده است'
                                : 'هنوز پیگیری‌ای ثبت نشده است',
                    style: Theme.of(context).textTheme.bodyLarge,
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
                                    row.taskTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (_showAutomaticDueOnly)
                                  const Chip(
                                    avatar: Icon(Icons.alarm_on, size: 16),
                                    label: Text('موعد پیگیری'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                if (waiting)
                                  const Chip(
                                    avatar: Icon(Icons.hourglass_top, size: 16),
                                    label: Text('منتظر پاسخ'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                IconButton(
                                  tooltip: 'ویرایش پیگیری',
                                  onPressed: _saving || row.taskId.isEmpty
                                      ? null
                                      : () => _editFollowUp(row),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_dateTime(row.dateTime)),
                            if (row.note.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(row.note),
                            ],
                            if (resultLabel.isNotEmpty && !waiting) ...[
                              const SizedBox(height: 6),
                              Text('نتیجه: $resultLabel'),
                            ],
                            if (row.nextFollowUp != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'پیگیری بعدی: ${_dateTime(row.nextFollowUp!)}',
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
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
  DateTime? get nextFollowUp => followUp.nextFollowUp;
}
