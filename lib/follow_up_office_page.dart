import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'follow_up_entry_page.dart';
import 'follow_up_repository.dart';
import 'models/follow_up.dart';

class FollowUpOfficePage extends StatefulWidget {
  const FollowUpOfficePage({
    super.key,
    this.repository = const FollowUpRepository(),
  });

  final FollowUpRepository repository;

  @override
  State<FollowUpOfficePage> createState() => _FollowUpOfficePageState();
}

class _FollowUpOfficePageState extends State<FollowUpOfficePage> {
  static const _storeKey = 'arvin.tasks';
  bool _loading = true;
  bool _saving = false;
  bool _showFutureOnly = false;
  List<_TaskOption> _tasks = const [];
  List<_FollowUpRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
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
          }
          final history = task['followUps'];
          if (history is List && history.isNotEmpty) {
            for (final entry in history) {
              final followUp = Map<String, dynamic>.from(entry as Map);
              final date = DateTime.tryParse(
                followUp['dateTime'] as String? ?? '',
              );
              if (date == null) {
                continue;
              }
              rows.add(_FollowUpRow(
                taskTitle: title,
                dateTime: date,
                note: followUp['note'] as String? ?? '',
                result: followUp['result'] as String?,
                nextFollowUp: DateTime.tryParse(
                  followUp['nextFollowUp'] as String? ?? '',
                ),
              ));
            }
          } else {
            final legacy = DateTime.tryParse(
              task['followUpDate'] as String? ?? '',
            );
            if (legacy != null) {
              rows.add(_FollowUpRow(
                taskTitle: title,
                dateTime: legacy,
                note: 'پیگیری قدیمی مهاجرت‌شده',
              ));
            }
          }
        }
      } catch (_) {}
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
      await widget.repository.add(task.id, followUp);
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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

  List<_FollowUpRow> get _visibleRows {
    if (!_showFutureOnly) return _rows;
    final now = DateTime.now();
    return _rows
        .where((row) => row.dateTime.isAfter(now))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر پیگیری'),
        actions: [
          IconButton(
            tooltip: _showFutureOnly ? 'نمایش همه' : 'فقط پیگیری‌های آینده',
            onPressed: () =>
                setState(() => _showFutureOnly = !_showFutureOnly),
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
                    _showFutureOnly
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
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_dateTime(row.dateTime)),
                            if (row.note.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(row.note),
                            ],
                            if (row.result?.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 6),
                              Text('نتیجه: ${row.result}'),
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
    required this.taskTitle,
    required this.dateTime,
    this.note = '',
    this.result,
    this.nextFollowUp,
  });

  final String taskTitle;
  final DateTime dateTime;
  final String note;
  final String? result;
  final DateTime? nextFollowUp;
}
