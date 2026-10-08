import 'package:flutter/material.dart';

import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_recurrence_repository.dart';
import 'widgets/persian_date_picker.dart';

class TaskRecurrencePage extends StatefulWidget {
  TaskRecurrencePage({super.key, this.initialTaskId, TaskRecurrenceRepository? repository})
      : repository = repository ?? TaskRecurrenceRepository();

  final String? initialTaskId;
  final TaskRecurrenceRepository repository;

  @override
  State<TaskRecurrencePage> createState() => _TaskRecurrencePageState();
}

class _TaskRecurrencePageState extends State<TaskRecurrencePage> {
  static const _dateFormatter = PersianDateFormatter();
  final _interval = TextEditingController(text: '1');
  final _count = TextEditingController();
  List<Task> _tasks = const [];
  String? _selectedTaskId;
  bool _loading = true;
  bool _saving = false;
  bool _enabled = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.daily;
  RecurrenceTrackingLevel _trackingLevel = RecurrenceTrackingLevel.normal;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic> _progress = const {};
  DateTime? _nextOccurrence;
  DateTime? _lastOccurrence;
  List<MapEntry<DateTime, Map<String, dynamic>>> _history = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _interval.dispose();
    _count.dispose();
    super.dispose();
  }

  Future<void> _reload({String? keepSelected}) async {
    final tasks = await widget.repository.loadTasks();
    if (!mounted) {
      return;
    }
    final active = tasks.where((task) => !task.trashed && !task.archived && !task.completed).toList(growable: false);
    final selectedId = keepSelected ?? _selectedTaskId ?? widget.initialTaskId;
    final selected = active.where((task) => task.id == selectedId).firstOrNull;
    final nextSelected = selected ?? (active.isEmpty ? null : active.first);
    final rule = nextSelected?.recurrence;
    setState(() {
      _tasks = active;
      _selectedTaskId = nextSelected?.id;
      _loading = false;
      _enabled = rule != null && rule.active;
      _frequency = rule?.frequency ?? RecurrenceFrequency.daily;
      _trackingLevel = rule?.trackingLevel ?? RecurrenceTrackingLevel.normal;
      _interval.text = '\${rule?.interval ?? 1}';
      _startDate = rule?.startDate;
      _endDate = rule?.endDate;
      _count.text = rule?.count?.toString() ?? '';
    });
    await _loadLifecycle(nextSelected);
  }

  void _loadRule(Task? task) {
    final rule = task?.recurrence;
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = rule != null && rule.active;
      _frequency = rule?.frequency ?? RecurrenceFrequency.daily;
      _trackingLevel = rule?.trackingLevel ?? RecurrenceTrackingLevel.normal;
      _interval.text = '${rule?.interval ?? 1}';
      _startDate = rule?.startDate;
      _endDate = rule?.endDate;
      _count.text = rule?.count?.toString() ?? '';
    });
  }

  Future<void> _loadLifecycle(Task? task) async {
    if (task == null || task.recurrence == null || task.reminderDate == null) {
      if (mounted) {
        setState(() {
        _progress = const {};
        _nextOccurrence = null;
        _lastOccurrence = null;
        _history = const [];
        });
      }
      return;
    }
    final now = widget.repository.now();
    final progress = await widget.repository.progress(task.id, from: task.recurrence!.startDate);
    final rule = task.recurrence!;
    final anchor = task.reminderDate!;
    DateTime? next;
    var cursor = rule.startDate ?? anchor;
    var guard = 0;
    while (guard++ < 10000) {
      if (rule.endDate != null && !cursor.isBefore(rule.endDate!)) break;
      if (!cursor.isBefore(now)) {
        next = cursor;
        break;
      }
      cursor = rule.nextOccurrence(cursor);
    }
    DateTime? last;
    final history = <MapEntry<DateTime, Map<String, dynamic>>>[];
    for (final entry in task.occurrenceHistory.entries) {
      final date = DateTime.tryParse(entry.key);
      if (date == null) continue;
      if (last == null || date.isAfter(last)) last = date;
      history.add(MapEntry(date, Map<String, dynamic>.from(entry.value)));
    }
    history.sort((a, b) => b.key.compareTo(a.key));
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _nextOccurrence = next;
      _lastOccurrence = last;
      _history = history;
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
    final count = int.tryParse(_count.text.trim());
    final startDate = _startDate ?? task.reminderDate;
    if (_enabled && (interval == null || interval < 1)) {
      _message('فاصله تکرار باید حداقل ۱ باشد');
      return;
    }
    if (_enabled && count != null && count < 1) {
      _message('تعداد اجرا باید حداقل ۱ باشد');
      return;
    }
    if (_enabled && _endDate != null && startDate != null && !_endDate!.isAfter(startDate)) {
      _message('تاریخ پایان باید بعد از تاریخ شروع باشد');
      return;
    }
    setState(() => _saving = true);
    try {
      final existing = task.recurrence;
      final rule = _enabled
          ? RecurrenceRule(
              frequency: _frequency,
              interval: interval!,
              startDate: startDate,
              endDate: _endDate,
              count: count,
              active: true,
              trackingLevel: _trackingLevel,
            )
          : (existing == null ? null : RecurrenceRule(
              frequency: existing.frequency,
              interval: existing.interval,
              startDate: existing.startDate,
              endDate: existing.endDate,
              count: existing.count,
              active: false,
              trackingLevel: existing.trackingLevel,
            ));
      await widget.repository.setRule(task.id, rule);
      await _reload(keepSelected: task.id);
      _message(_enabled ? 'تکرار ذخیره شد' : 'تکرار غیرفعال شد');
    } catch (_) {
      _message('ذخیره تکرار انجام نشد');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _completeNext() async {
    final task = _selectedTask;
    final occurrence = _nextOccurrence;
    if (task == null || occurrence == null || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.repository.completeOccurrence(task.id, occurrence);
      await _reload(keepSelected: task.id);
      _message('این نوبت انجام‌شده ثبت شد');
    } catch (_) {
      _message('ثبت نوبت انجام‌شده ناموفق بود');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resumeFromToday() async {
    final task = _selectedTask;
    if (task == null || task.recurrence == null || task.reminderDate == null || _saving) return;
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

  Future<void> _chooseStartDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: _startDate ?? _selectedTask?.reminderDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'تاریخ شروع تکرار',
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
    if (picked != null && mounted) setState(() => _startDate = picked);
  }

  Future<void> _chooseEndDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? _selectedTask?.reminderDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'تاریخ پایان تکرار',
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
    if (picked != null && mounted) setState(() => _endDate = picked);
  }
  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String _frequencyLabel(RecurrenceFrequency value) {
    switch (value) {
      case RecurrenceFrequency.daily: return 'روزانه';
      case RecurrenceFrequency.weekly: return 'هفتگی';
      case RecurrenceFrequency.monthly: return 'ماهانه';
      case RecurrenceFrequency.yearly: return 'سالانه';
      case RecurrenceFrequency.oncePerDay: return 'یک‌بار در روز';
      case RecurrenceFrequency.minutes: return 'دقیقه‌ای';
      case RecurrenceFrequency.hours: return 'ساعتی';
    }
  }

  String _date(DateTime value) => _dateFormatter.format(value, usePersianDate: true);
  String _dateTime(DateTime value) => '${_date(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  String _statusLabel(String? status) {
    switch (status) {
      case 'completed': return 'انجام‌شده';
      case 'missed': return 'از دست‌رفته';
      case 'skipped': return 'ردشده';
      case 'cancelled': return 'لغوشده';
      default: return 'در انتظار';
    }
  }

  Widget _infoChip(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFE9EAFF), borderRadius: BorderRadius.circular(14)),
    child: Text('$label: $value'),
  );

  Widget _lifecycleCard(Task? task) {
    if (task?.recurrence == null) return const SizedBox.shrink();
    final completed = _progress['completed'] ?? 0;
    final total = _progress['total'];
    final remaining = _progress['remaining'];
    return Card(
      key: const ValueKey('recurrence-lifecycle-card'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('وضعیت تکرار', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 12),
            if (task?.recurrence?.trackingLevel == RecurrenceTrackingLevel.tracking) ...[
              const SizedBox(height: 12),
              const Text('این کار مهم و قابل پیگیری است', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
            ],
            Wrap(spacing: 10, runSpacing: 10, children: [
              _infoChip('انجام‌شده', '$completed'),
              _infoChip('کل', total == null ? 'نامحدود' : '$total'),
              if (remaining != null) _infoChip('باقی‌مانده', '$remaining'),
            ]),
            const SizedBox(height: 12),
            if (_nextOccurrence != null)
              ListTile(
                key: const ValueKey('recurrence-next'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('بعدی'),
                subtitle: Text(_dateTime(_nextOccurrence!)),
              ),
            if (_lastOccurrence != null)
              ListTile(
                key: const ValueKey('recurrence-last'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: const Text('آخرین نوبت ثبت‌شده'),
                subtitle: Text(_dateTime(_lastOccurrence!)),
              ),
            if (_nextOccurrence != null)
              FilledButton.icon(
                key: const ValueKey('recurrence-complete-next'),
                onPressed: _saving ? null : _completeNext,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('ثبت نوبت بعدی به‌عنوان انجام‌شده'),
              ),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('سوابق اجرا', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              for (final entry in _history.take(10))
                ListTile(
                  key: ValueKey('recurrence-history-${entry.key.toIso8601String()}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.checklist_outlined),
                  title: Text(_dateTime(entry.key)),
                  subtitle: Text(_statusLabel(entry.value['status'] as String?)),
                ),
            ],
          ],
        ),
      ),
    );
  }

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
                        key: ValueKey('recurrence-task-picker-${_selectedTaskId ?? 'none'}'),
                        initialValue: _selectedTaskId,
                        decoration: const InputDecoration(labelText: 'کار'),
                        items: [
                          for (final item in _tasks)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(item.title.trim().isEmpty ? 'بدون عنوان' : item.title),
                            ),
                        ],
                        onChanged: _saving ? null : (value) {
                          final selected = _tasks.where((item) => item.id == value).firstOrNull;
                          setState(() {
                            _selectedTaskId = value;
                            final rule = selected?.recurrence;
                            _enabled = rule != null && rule.active;
                            _frequency = rule?.frequency ?? RecurrenceFrequency.daily;
                            _trackingLevel = rule?.trackingLevel ?? RecurrenceTrackingLevel.normal;
                            _interval.text = '\${rule?.interval ?? 1}';
                            _startDate = rule?.startDate;
                            _endDate = rule?.endDate;
                            _count.text = rule?.count?.toString() ?? '';
                          });
                          _loadLifecycle(selected);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        key: const ValueKey('recurrence-enabled'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('تکرار فعال باشد'),
                        value: _enabled,
                        onChanged: _saving ? null : (value) => setState(() => _enabled = value),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RecurrenceFrequency>(
                        key: ValueKey('recurrence-frequency-${_frequency.name}'),
                        initialValue: _frequency,
                        decoration: const InputDecoration(labelText: 'نوع تکرار'),
                        items: [
                          for (final value in RecurrenceFrequency.values)
                            DropdownMenuItem(value: value, child: Text(_frequencyLabel(value))),
                        ],
                        onChanged: !_enabled || _saving ? null : (value) {
                          if (value != null) setState(() => _frequency = value);
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
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const ValueKey('recurrence-start-date'),
                        onPressed: !_enabled || _saving ? null : _chooseStartDate,
                        icon: const Icon(Icons.event_outlined),
                        label: Text('شروع: ${_date(_startDate ?? task?.reminderDate ?? widget.repository.now())}'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const ValueKey('recurrence-end-date'),
                              onPressed: !_enabled || _saving ? null : _chooseEndDate,
                              icon: const Icon(Icons.event_busy_outlined),
                              label: Text(_endDate == null ? 'پایان: بدون پایان' : 'پایان: ${_date(_endDate!)}'),
                            ),
                          ),
                          if (_endDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              key: const ValueKey('recurrence-clear-end-date'),
                              tooltip: 'حذف تاریخ پایان',
                              onPressed: !_enabled || _saving ? null : () => setState(() => _endDate = null),
                              icon: const Icon(Icons.clear),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('recurrence-count'),
                        controller: _count,
                        enabled: _enabled && !_saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'تعداد اجرا',
                          helperText: 'خالی = بدون محدودیت تعداد اجرا',
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
                      if (_enabled && task?.reminderDate != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const ValueKey('recurrence-resume-today'),
                          onPressed: _saving ? null : _resumeFromToday,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('از امروز ادامه بده'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _lifecycleCard(task),
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
