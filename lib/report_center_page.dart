import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_report_filter.dart';
import 'task_report_page.dart';

class ReportCenterPage extends StatefulWidget {
  const ReportCenterPage({
    super.key,
    required this.tasks,
    this.projects = const [],
    this.now,
  });

  final List<Task> tasks;
  final List<ProjectPlan> projects;
  final DateTime? now;

  @override
  State<ReportCenterPage> createState() => _ReportCenterPageState();
}

class _ReportCenterPageState extends State<ReportCenterPage> {
  TaskReportFilter _filter = const TaskReportFilter();

  DateTime get _now => widget.now ?? DateTime.now();

  List<Task> get _filtered => _filter.apply(
        widget.tasks,
        now: _now,
        projects: widget.projects,
      );

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<TaskReportFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportFilterSheet(
        initial: _filter,
        projects: widget.projects,
        tasks: widget.tasks,
        now: _now,
      ),
    );
    if (result != null) setState(() => _filter = result);
  }

  void _clear() => setState(() => _filter = const TaskReportFilter());

  @override
  Widget build(BuildContext context) {
    final tasks = _filtered;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('گزارش‌ها'),
          actions: [
            if (_filter.isActive)
              IconButton(
                key: const ValueKey('report-center-clear'),
                tooltip: 'پاک کردن فیلترها',
                onPressed: _clear,
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'مرکز گزارش آروین',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('report-center-filters'),
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune),
                    label: const Text('فیلترها'),
                  ),
                ],
              ),
            ),
            if (_filter.isActive)
              _ActiveFilterChips(filter: _filter, onClear: _clear),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('نتیجه: ${tasks.length} کار'),
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('موردی با این فیلترها پیدا نشد'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final task = tasks[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              task.title.trim().isEmpty ? 'بدون عنوان' : task.title,
                            ),
                            subtitle: Text(
                              [
                                if (task.category?.trim().isNotEmpty == true)
                                  'دسته: ${task.category}',
                                if (task.tags.isNotEmpty)
                                  'برچسب: ${task.tags.join('، ')}',
                                if (task.completed) 'انجام‌شده' else 'باز',
                              ].join(' • '),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: tasks.isEmpty
            ? null
            : FloatingActionButton.extended(
                key: const ValueKey('report-center-open-report'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => TaskReportPage(tasks: List<Task>.of(tasks)),
                  ),
                ),
                icon: const Icon(Icons.description_outlined),
                label: const Text('مشاهده و خروجی'),
              ),
      ),
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({required this.filter, required this.onClear});

  final TaskReportFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 6,
        children: [
          if (filter.timePreset != ReportTimePreset.all)
            Chip(label: Text(_timeLabel(filter.timePreset))),
          if (filter.projectId != null) const Chip(label: Text('پروژه')),
          if (filter.category != null) Chip(label: Text(filter.category!)),
          if (filter.tag != null) Chip(label: Text(filter.tag!)),
          if (filter.status != ReportStatusFilter.all)
            Chip(label: Text(_statusLabel(filter.status))),
          if (filter.priority != null)
            Chip(label: Text(_priorityLabel(filter.priority!))),
          if (filter.hasRepeat != null)
            Chip(label: Text(filter.hasRepeat! ? 'تکرارشونده' : 'بدون تکرار')),
          if (filter.hasFollowUp != null)
            Chip(label: Text(filter.hasFollowUp! ? 'پیگیری‌دار' : 'بدون پیگیری')),
          if (filter.hasChecklist != null)
            Chip(label: Text(filter.hasChecklist! ? 'Checklist‌دار' : 'بدون Checklist')),
          if (filter.fromDate != null || filter.toDate != null)
            const Chip(label: Text('بازه تاریخ')),
          if (filter.fromTime != null || filter.toTime != null)
            const Chip(label: Text('بازه ساعت')),
          ActionChip(label: const Text('پاک کردن'), onPressed: onClear),
        ],
      ),
    );
  }
}

class _ReportFilterSheet extends StatefulWidget {
  const _ReportFilterSheet({
    required this.initial,
    required this.projects,
    required this.tasks,
    required this.now,
  });

  final TaskReportFilter initial;
  final List<ProjectPlan> projects;
  final List<Task> tasks;
  final DateTime now;

  @override
  State<_ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<_ReportFilterSheet> {
  late ReportTimePreset _timePreset;
  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String? _projectId;
  String? _category;
  String? _tag;
  ReportStatusFilter _status = ReportStatusFilter.all;
  TaskPriority? _priority;
  bool? _hasRepeat;
  bool? _hasFollowUp;
  bool? _hasChecklist;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _timePreset = f.timePreset;
    _fromDate = f.fromDate;
    _toDate = f.toDate;
    _fromTime = f.fromTime == null ? null : _toTimeOfDay(f.fromTime!);
    _toTime = f.toTime == null ? null : _toTimeOfDay(f.toTime!);
    _projectId = f.projectId;
    _category = f.category;
    _tag = f.tag;
    _status = f.status;
    _priority = f.priority;
    _hasRepeat = f.hasRepeat;
    _hasFollowUp = f.hasFollowUp;
    _hasChecklist = f.hasChecklist;
  }

  Future<void> _pickDate(bool from) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from ? (_fromDate ?? widget.now) : (_toDate ?? _fromDate ?? widget.now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (_, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _pickTime(bool from) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: from
          ? (_fromTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (_toTime ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (_, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _fromTime = picked;
      } else {
        _toTime = picked;
      }
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      TaskReportFilter(
        timePreset: _timePreset,
        fromDate: _fromDate,
        toDate: _toDate,
        fromTime: _fromTime == null
            ? null
            : Duration(hours: _fromTime!.hour, minutes: _fromTime!.minute),
        toTime: _toTime == null
            ? null
            : Duration(hours: _toTime!.hour, minutes: _toTime!.minute),
        projectId: _projectId,
        category: _category,
        tag: _tag,
        status: _status,
        priority: _priority,
        hasRepeat: _hasRepeat,
        hasFollowUp: _hasFollowUp,
        hasChecklist: _hasChecklist,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.tasks
        .map((task) => task.category?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()..sort();
    final tags = widget.tasks
        .expand((task) => task.tags)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()..sort();
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [BoxShadow(blurRadius: 24, offset: Offset(0, -6))],
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('فیلتر گزارش‌ها', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _Section(
              title: 'زمان',
              child: Wrap(
                spacing: 6,
                children: [
                  for (final preset in ReportTimePreset.values)
                    ChoiceChip(
                      label: Text(_timeLabel(preset)),
                      selected: _timePreset == preset,
                      onSelected: (_) => setState(() => _timePreset = preset),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'بازه دقیق',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickDate(true),
                          child: Text(_dateLabel(_fromDate, 'از تاریخ')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickDate(false),
                          child: Text(_dateLabel(_toDate, 'تا تاریخ')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickTime(true),
                          child: Text(_timeLabelOf(_fromTime, 'از ساعت')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickTime(false),
                          child: Text(_timeLabelOf(_toTime, 'تا ساعت')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'پروژه',
              child: DropdownButtonFormField<String?>(
                value: _projectId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('همه پروژه‌ها')),
                  ...widget.projects.map(
                    (project) => DropdownMenuItem<String?>(
                      value: project.id,
                      child: Text(project.title),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _projectId = value),
              ),
            ),
            _Section(
              title: 'دسته',
              child: DropdownButtonFormField<String?>(
                value: _category,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('همه دسته‌ها')),
                  ...categories.map((value) => DropdownMenuItem<String?>(value: value, child: Text(value))),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
            ),
            _Section(
              title: 'برچسب',
              child: DropdownButtonFormField<String?>(
                value: _tag,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('همه برچسب‌ها')),
                  ...tags.map((value) => DropdownMenuItem<String?>(value: value, child: Text(value))),
                ],
                onChanged: (value) => setState(() => _tag = value),
              ),
            ),
            _Section(
              title: 'وضعیت',
              child: Wrap(
                spacing: 6,
                children: [
                  for (final value in ReportStatusFilter.values)
                    ChoiceChip(
                      label: Text(_statusLabel(value)),
                      selected: _status == value,
                      onSelected: (_) => setState(() => _status = value),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'اهمیت',
              child: Wrap(
                spacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('همه'),
                    selected: _priority == null,
                    onSelected: (_) => setState(() => _priority = null),
                  ),
                  for (final value in TaskPriority.values.where((v) => v != TaskPriority.none))
                    ChoiceChip(
                      label: Text(_priorityLabel(value)),
                      selected: _priority == value,
                      onSelected: (_) => setState(() => _priority = value),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'نوع',
              child: Wrap(
                spacing: 6,
                children: [
                  _TriStateChip(
                    label: 'تکرار',
                    value: _hasRepeat,
                    onChanged: (value) => setState(() => _hasRepeat = value),
                  ),
                  _TriStateChip(
                    label: 'پیگیری',
                    value: _hasFollowUp,
                    onChanged: (value) => setState(() => _hasFollowUp = value),
                  ),
                  _TriStateChip(
                    label: 'Checklist',
                    value: _hasChecklist,
                    onChanged: (value) => setState(() => _hasChecklist = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('report-filter-clear'),
                    onPressed: () => setState(() {
                      _timePreset = ReportTimePreset.all;
                      _fromDate = null;
                      _toDate = null;
                      _fromTime = null;
                      _toTime = null;
                      _projectId = null;
                      _category = null;
                      _tag = null;
                      _status = ReportStatusFilter.all;
                      _priority = null;
                      _hasRepeat = null;
                      _hasFollowUp = null;
                      _hasChecklist = null;
                    }),
                    child: const Text('پاک کردن'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('report-filter-apply'),
                    onPressed: _apply,
                    child: const Text('اعمال'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
            child,
          ],
        ),
      );
}

class _TriStateChip extends StatelessWidget {
  const _TriStateChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == true;
    return ChoiceChip(
      label: Text(value == null ? label : selected ? 'دارای $label' : 'بدون $label'),
      selected: value != null,
      onSelected: (_) => onChanged(value == null ? true : selected ? false : null),
    );
  }
}

String _timeLabel(ReportTimePreset value) => switch (value) {
      ReportTimePreset.all => 'همه',
      ReportTimePreset.today => 'امروز',
      ReportTimePreset.tomorrow => 'فردا',
      ReportTimePreset.thisWeek => 'این هفته',
      ReportTimePreset.future => 'آینده',
      ReportTimePreset.past => 'گذشته',
      ReportTimePreset.undated => 'فاقد زمان',
    };

String _statusLabel(ReportStatusFilter value) => switch (value) {
      ReportStatusFilter.all => 'همه',
      ReportStatusFilter.open => 'باز',
      ReportStatusFilter.completed => 'انجام‌شده',
      ReportStatusFilter.archived => 'بایگانی',
      ReportStatusFilter.trashed => 'سطل زباله',
    };

String _priorityLabel(TaskPriority value) => switch (value) {
      TaskPriority.none => 'بدون اهمیت',
      TaskPriority.low => 'کم',
      TaskPriority.medium => 'متوسط',
      TaskPriority.high => 'زیاد',
    };

String _dateLabel(DateTime? value, String empty) {
  if (value == null) return empty;
  return const PersianDateFormatter().format(value, usePersianDate: true);
}

String _timeLabelOf(TimeOfDay? value, String empty) {
  if (value == null) return empty;
  final raw = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  return const PersianDateFormatter().toPersianDigits(raw);
}

TimeOfDay _toTimeOfDay(Duration value) =>
    TimeOfDay(hour: value.inHours % 24, minute: value.inMinutes % 60);
