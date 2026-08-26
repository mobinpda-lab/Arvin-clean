import 'package:flutter/material.dart';

import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/task_recurrence_repository.dart';

class TaskRecurrencePage extends StatefulWidget {
  TaskRecurrencePage({
    super.key,
    this.initialTaskId,
    TaskRecurrenceRepository? repository,
  }) : repository = repository ?? TaskRecurrenceRepository();

  final String? initialTaskId;
  final TaskRecurrenceRepository repository;

  @override
  State<TaskRecurrencePage> createState() => _TaskRecurrencePageState();
}

class _TaskRecurrencePageState extends State<TaskRecurrencePage> {
  final _interval = TextEditingController(text: '1');
  List<Task> _tasks = const [];
  String? _selectedTaskId;
  bool _loading = true;
  bool _saving = false;
  bool _enabled = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.daily;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _interval.dispose();
    super.dispose();
  }

  Future<void> _reload({String? keepSelected}) async {
    final tasks = await widget.repository.loadTasks();
    if (!mounted) return;
    final active = tasks
        .where((task) => !task.trashed && !task.archived && !task.completed)
        .toList(growable: false);
    final selectedId =
        keepSelected ?? _selectedTaskId ?? widget.initialTaskId;
    final selected = active.where((task) => task.id == selectedId).firstOrNull;
    final nextSelected = selected ?? (active.isEmpty ? null : active.first);

    setState(() {
      _tasks = active;
      _selectedTaskId = nextSelected?.id;
      _loading = false;
    });
    _loadRule(nextSelected);
  }

  void _loadRule(Task? task) {
    final rule = task?.recurrence;
    if (!mounted) return;
    setState(() {
      _enabled = rule != null;
      _frequency = rule?.frequency ?? RecurrenceFrequency.daily;
      _interval.text = '${rule?.interval ?? 1}';
    });
  }

  Task? get _selectedTask {
    final id = _selectedTaskId;
    if (id == null) return null;
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> _saveRule() async {
    final task = _selectedTask;
    if (task == null || _saving) return;
    final interval = int.tryParse(_interval.text.trim());
    if (_enabled && (interval == null || interval < 1)) {
      _message('فاصله تکرار باید حداقل ۱ باشد');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.repository.setRule(
        task.id,
        _enabled
            ? RecurrenceRule(
                frequency: _frequency,
                interval: interval!,
              )
            : null,
      );
      await _reload(keepSelected: task.id);
      _message(_enabled ? 'تکرار ذخیره شد' : 'تکرار غیرفعال شد');
    } catch (_) {
      _message('ذخیره تکرار انجام نشد');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resumeFromToday() async {
    final task = _selectedTask;
    if (task == null || task.recurrence == null || task.reminderDate == null) {
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.repository.resumeFromToday(task.id);
      await _reload(keepSelected: task.id);
      _message('برنامه تکرار از امروز ادامه پیدا کرد');
    } catch (_) {
      _message('ادامه برنامه تکرار انجام نشد');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String _frequencyLabel(RecurrenceFrequency value) {
    switch (value) {
      case RecurrenceFrequency.daily:
        return 'روزانه';
      case RecurrenceFrequency.weekly:
        return 'هفتگی';
      case RecurrenceFrequency.monthly:
        return 'ماهانه';
      case RecurrenceFrequency.yearly:
        return 'سالانه';
      case RecurrenceFrequency.oncePerDay:
        return 'یک‌بار در روز';
    }
  }

  String _date(DateTime value) =>
      '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final task = _selectedTask;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تکرار کارها')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? const Center(child: Text('کار فعالی برای تنظیم تکرار وجود ندارد'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'recurrence-task-picker-${_selectedTaskId ?? 'none'}',
                        ),
                        initialValue: _selectedTaskId,
                        decoration: const InputDecoration(labelText: 'کار'),
                        items: [
                          for (final item in _tasks)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                item.title.trim().isEmpty ? 'بدون عنوان' : item.title,
                              ),
                            ),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) {
                                setState(() => _selectedTaskId = value);
                                _loadRule(_selectedTask);
                              },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        key: const ValueKey('recurrence-enabled'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('تکرار فعال باشد'),
                        value: _enabled,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _enabled = value),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RecurrenceFrequency>(
                        key: ValueKey('recurrence-frequency-${_frequency.name}'),
                        initialValue: _frequency,
                        decoration: const InputDecoration(labelText: 'نوع تکرار'),
                        items: [
                          for (final value in RecurrenceFrequency.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(_frequencyLabel(value)),
                            ),
                        ],
                        onChanged: !_enabled || _saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _frequency = value);
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('recurrence-interval'),
                        controller: _interval,
                        enabled: _enabled && !_saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'فاصله تکرار',
                          helperText: 'مثلاً ۲ یعنی هر دو روز/هفته/ماه/سال',
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        key: const ValueKey('recurrence-save'),
                        onPressed: _saving ? null : _saveRule,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('ذخیره تکرار'),
                      ),
                      if (task?.reminderDate != null) ...[
                        const SizedBox(height: 12),
                        Text('زمان فعلی یادآوری: ${_date(task!.reminderDate!)}'),
                      ],
                      if (task?.recurrence != null && task?.reminderDate != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const ValueKey('recurrence-resume-today'),
                          onPressed: _saving ? null : _resumeFromToday,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('از امروز ادامه بده'),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    for (final value in this) {
      return value;
    }
    return null;
  }
}
