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
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.tune, size: 18),
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
                extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
                extendedIconLabelSpacing: 6,
                icon: const Icon(Icons.description_outlined, size: 18),
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
          if (filter.projectId != null || filter.projectIds.isNotEmpty)
            Chip(label: Text('پروژه: ${filter.projectIds.length + (filter.projectId == null ? 0 : 1)}')),
          for (final value in <String>{...filter.categories, if (filter.category != null) filter.category!})
            Chip(label: Text(value)),
          for (final value in <String>{...filter.tags, if (filter.tag != null) filter.tag!})
            Chip(label: Text(value)),
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
  Set<String> _projectIds = <String>{};
  Set<String> _categories = <String>{};
  Set<String> _tags = <String>{};
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
    _projectIds = <String>{...f.projectIds, if (f.projectId != null) f.projectId!};
    _categories = <String>{...f.categories, if (f.category != null) f.category!};
    _tags = <String>{...f.tags, if (f.tag != null) f.tag!};
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
        projectIds: Set<String>.of(_projectIds),
        categories: Set<String>.of(_categories),
        tags: Set<String>.of(_tags),
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
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
            const SizedBox(height: 8),
            Text('فیلتر گزارش‌ها', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
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
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickDate(false),
                          child: Text(_dateLabel(_toDate, 'تا تاریخ')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
              child: _MultiSelectChips(
                allLabel: 'همه پروژه‌ها',
                options: widget.projects
                    .map((project) => MapEntry(project.id, project.title))
                    .toList(growable: false),
                selected: _projectIds,
                onChanged: (value) => setState(() => _projectIds = value),
                keyPrefix: 'report-filter-project',
              ),
            ),
            _Section(
              title: 'دسته',
              child: _MultiSelectChips(
                allLabel: 'همه دسته‌ها',
                options: categories.map((value) => MapEntry(value, value)).toList(growable: false),
                selected: _categories,
                onChanged: (value) => setState(() => _categories = value),
                keyPrefix: 'report-filter-category',
              ),
            ),
            _Section(
              title: 'برچسب',
              child: _MultiSelectChips(
                allLabel: 'همه برچسب‌ها',
                options: tags.map((value) => MapEntry(value, value)).toList(growable: false),
                selected: _tags,
                onChanged: (value) => setState(() => _tags = value),
                keyPrefix: 'report-filter-tag',
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
            const SizedBox(height: 10),
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
                      _projectIds = <String>{};
                      _categories = <String>{};
                      _tags = <String>{};
                      _status = ReportStatusFilter.all;
                      _priority = null;
                      _hasRepeat = null;
                      _hasFollowUp = null;
                      _hasChecklist = null;
                    }),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('پاک کردن'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('report-filter-apply'),
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
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

class _MultiSelectChips extends StatelessWidget {
  const _MultiSelectChips({
    required this.allLabel,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.keyPrefix,
  });

  final String allLabel;
  final List<MapEntry<String, String>> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          FilterChip(
            key: ValueKey('${keyPrefix}-all'),
            label: Text(allLabel),
            selected: selected.isEmpty,
            onSelected: (_) => onChanged(<String>{}),
          ),
          for (final option in options)
            FilterChip(
              key: ValueKey('${keyPrefix}-${option.key}'),
              label: Text(option.value),
              selected: selected.contains(option.key),
              onSelected: (checked) {
                final next = <String>{...selected};
                if (checked) {
                  next.add(option.key);
                } else {
                  next.remove(option.key);
                }
                onChanged(next);
              },
            ),
        ],
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
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
