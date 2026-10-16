import 'package:flutter/material.dart';
import 'arvin_colors.dart';

import 'models/goal_project.dart';
import 'models/person_reference.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_report_filter.dart';
import 'services/person_follow_up_report_projection.dart';
import 'task_report_page.dart';
import 'widgets/persian_date_picker.dart';
import 'widgets/universal_arvin_time_picker.dart';

String _reportDateTimeLabel(DateTime value) {
  const formatter = PersianDateFormatter();
  final date = formatter.format(value, usePersianDate: true);
  final time = formatter.formatTime(value.hour, value.minute);
  return '$date $time';
}

class ReportCenterPage extends StatefulWidget {
  const ReportCenterPage({
    super.key,
    required this.tasks,
    this.projects = const [],
    this.people = const [],
    this.now,
  });

  final List<Task> tasks;
  final List<ProjectPlan> projects;
  final List<PersonReference> people;
  final DateTime? now;

  @override
  State<ReportCenterPage> createState() => _ReportCenterPageState();
}

class _ReportCenterPageState extends State<ReportCenterPage> {
  TaskReportFilter _filter = const TaskReportFilter();
  bool _showWaitingFollowUps = false;
  String? _selectedPersonId;

  DateTime get _now => widget.now ?? DateTime.now();

  List<PersonReference> get _peopleDirectory {
    final activeById = <String, PersonReference>{
      for (final person in widget.people) person.id: person,
    };
    final byId = <String, PersonReference>{
      if (widget.people.isEmpty)
        for (final task in widget.tasks)
          for (final person in task.people) person.id: person,
      if (widget.people.isNotEmpty)
        for (final task in widget.tasks)
          for (final person in task.people)
            if (activeById.containsKey(person.id)) person.id: activeById[person.id]!,
      if (widget.people.isNotEmpty)
        for (final task in widget.tasks)
          for (final person in task.people)
            if (!activeById.containsKey(person.id))
              person.id: PersonReference(id: person.id, displayName: 'شخص حذف‌شده'),
      for (final person in widget.people) person.id: person,
      for (final task in widget.tasks)
        for (final followUp in task.followUps)
          for (final personId in followUp.personIds)
            if (!activeById.containsKey(personId))
              personId: PersonReference(id: personId, displayName: 'شخص حذف‌شده'),
    };
    final result = byId.values.toList(growable: false)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return result;
  }

  List<PersonFollowUpReportRow> get _waitingRows =>
      const PersonFollowUpReportProjection().project(
        widget.tasks,
        people: _peopleDirectory,
        personId: _selectedPersonId,
      );

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
        people: _peopleDirectory,
        now: _now,
      ),
    );
    if (result != null) setState(() => _filter = result);
  }

  void _clear() => setState(() {
        _filter = const TaskReportFilter();
        _showWaitingFollowUps = false;
        _selectedPersonId = null;
      });

  @override
  Widget build(BuildContext context) {
    final tasks = _filtered;
    final waitingRows = _waitingRows;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('پیگیری‌های منتظر پاسخ'),
                      value: _showWaitingFollowUps,
                      onChanged: (value) => setState(() => _showWaitingFollowUps = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPersonId ?? '',
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'فرد', isDense: true),
                      items: [
                        const DropdownMenuItem<String>(value: '', child: Text('همه افراد')),
                        for (final person in _peopleDirectory)
                          DropdownMenuItem<String>(value: person.id, child: Text(person.displayName, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (value) => setState(() => _selectedPersonId = value == null || value.isEmpty ? null : value),
                    ),
                  ),
                ],
              ),
            ),
            if (_filter.isActive && !_showWaitingFollowUps)
              _ActiveFilterChips(filter: _filter, onClear: _clear),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_showWaitingFollowUps
                    ? 'نتیجه: ${waitingRows.length} پیگیری'
                    : 'نتیجه: ${tasks.length} کار'),
              ),
            ),
            Expanded(
              child: _showWaitingFollowUps
                  ? (waitingRows.isEmpty
                      ? const Center(child: Text('موردی با این فیلترها پیدا نشد'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: waitingRows.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final row = waitingRows[index];
                            final next = row.nextFollowUp;
                            final reminder = row.reminderDate;
                            return Card(
                              child: ListTile(
                                title: Text(row.task.title.trim().isEmpty ? 'بدون عنوان' : row.task.title),
                                subtitle: Text([
                                  if (row.followUp.note.trim().isNotEmpty) row.followUp.note.trim(),
                                  if (row.followUp.result?.trim().isNotEmpty == true) 'نتیجه: ${row.followUp.result!.trim()}',
                                  'افراد: ${row.people.map((person) => person.displayName).join('، ')}',
                                  if (next != null) 'اقدام بعدی: ${_reportDateTimeLabel(next)}',
                                  if (reminder != null) 'یادآور: ${_reportDateTimeLabel(reminder)}',
                                ].join(' • ')),
                              ),
                            );
                          },
                        ))
                  : (tasks.isEmpty
                      ? const Center(child: Text('موردی با این فیلترها پیدا نشد'))
                      : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final task = tasks[index];
                        final cardColor = task.completed
                            ? ArvinColors.timeSoft
                            : task.dueDate != null &&
                                  DateUtils.dateOnly(task.dueDate!).isBefore(
                                    DateUtils.dateOnly(_now),
                                  )
                            ? ArvinColors.errorSoft
                            : task.followUpEnabled
                            ? ArvinColors.reminderSoft
                            : ArvinColors.projectSoft;
                        return Card(
                          key: ValueKey('report-task-card-${task.id}'),
                          color: cardColor,
                          child: ListTile(
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -1),
                            title: Text(
                              task.title.trim().isEmpty ? 'بدون عنوان' : task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                    )),
            ),
          ],
        ),
        floatingActionButton: _showWaitingFollowUps || tasks.isEmpty
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
          if (filter.personIds.isNotEmpty)
            Chip(label: Text('اشخاص: ${filter.personIds.length}')),
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
    required this.people,
    required this.now,
  });

  final TaskReportFilter initial;
  final List<ProjectPlan> projects;
  final List<Task> tasks;
  final List<PersonReference> people;
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
  Set<String> _personIds = <String>{};
  Set<ReportStatusFilter> _statuses = <ReportStatusFilter>{};
  Set<RecurrenceTrackingLevel> _trackingLevels = <RecurrenceTrackingLevel>{};
  Set<NotebookItemKind> _noteKinds = <NotebookItemKind>{};
  final TextEditingController _noteQueryController = TextEditingController();
  ReportNoteDateField? _noteDateField;
  DateTime? _noteFromDate;
  DateTime? _noteToDate;
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
    _personIds = <String>{...f.personIds};
    _statuses = <ReportStatusFilter>{...f.statuses};
    if (_statuses.isEmpty && f.status != ReportStatusFilter.all) {
      _statuses.add(f.status);
    }
    _trackingLevels = <RecurrenceTrackingLevel>{...f.trackingLevels};
    _noteKinds = <NotebookItemKind>{...f.noteKinds};
    _noteQueryController.text = f.noteQuery;
    _noteDateField = f.noteDateField;
    _noteFromDate = f.noteFromDate;
    _noteToDate = f.noteToDate;
    _priority = f.priority;
    _hasRepeat = f.hasRepeat;
    _hasFollowUp = f.hasFollowUp;
    _hasChecklist = f.hasChecklist;
  }

  @override
  void dispose() {
    _noteQueryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool from) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: from ? (_fromDate ?? widget.now) : (_toDate ?? _fromDate ?? widget.now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: from ? 'انتخاب تاریخ شروع گزارش' : 'انتخاب تاریخ پایان گزارش',
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


  Future<void> _pickNoteDate(bool from) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: from
          ? (_noteFromDate ?? widget.now)
          : (_noteToDate ?? _noteFromDate ?? widget.now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: from ? 'شروع بازه یادداشت' : 'پایان بازه یادداشت',
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _noteFromDate = picked;
      } else {
        _noteToDate = picked;
      }
      _noteDateField ??= ReportNoteDateField.created;
    });
  }

  Future<void> _pickTime(bool from) async {
    final picked = await showUniversalArvinTimePicker(
      context: context,
      initialTime: from
          ? (_fromTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (_toTime ?? const TimeOfDay(hour: 17, minute: 0)),
      helpText: from ? 'از ساعت گزارش' : 'تا ساعت گزارش',
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
        personIds: Set<String>.of(_personIds),
        status: ReportStatusFilter.all,
        statuses: Set<ReportStatusFilter>.of(_statuses),
        trackingLevels: Set<RecurrenceTrackingLevel>.of(_trackingLevels),
        noteKinds: Set<NotebookItemKind>.of(_noteKinds),
        noteQuery: _noteQueryController.text.trim(),
        noteDateField: _noteDateField,
        noteFromDate: _noteFromDate,
        noteToDate: _noteToDate,
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
        child: Column(
          children: [
            SizedBox(
              key: const ValueKey('report-filter-header'),
              height: 64,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('report-filter-close'),
                      tooltip: 'بستن',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'فیلتر گزارش‌ها',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                children: [
            _Section(
              title: 'زمان',
              icon: Icons.schedule_outlined,
              accentColor: ArvinColors.time,
              selectedCount: (_timePreset != ReportTimePreset.all ? 1 : 0) +
                  (_fromDate != null || _toDate != null ? 1 : 0) +
                  (_fromTime != null || _toTime != null ? 1 : 0),
              initiallyExpanded: true,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final preset in ReportTimePreset.values)
                    ChoiceChip(
                      label: Text(_timeLabel(preset)),
                      selected: _timePreset == preset,
                      selectedColor: ArvinColors.timeSoft,
                      onSelected: (_) => setState(() => _timePreset = preset),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'بازه دقیق',
              icon: Icons.date_range_outlined,
              accentColor: ArvinColors.time,
              selectedCount: (_fromDate != null ? 1 : 0) +
                  (_toDate != null ? 1 : 0) +
                  (_fromTime != null ? 1 : 0) +
                  (_toTime != null ? 1 : 0),
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
              icon: Icons.folder_open_outlined,
              accentColor: ArvinColors.project,
              selectedCount: _projectIds.length,
              child: _MultiSelectChips(
                allLabel: 'همه پروژه‌ها',
                accentColor: ArvinColors.project,
                options: widget.projects
                    .map((project) => MapEntry(project.id, project.title))
                    .toList(growable: false),
                selected: _projectIds,
                onChanged: (value) => setState(() => _projectIds = value),
                keyPrefix: 'report-filter-project',
              ),
            ),
            _Section(
              title: 'شخص',
              icon: Icons.people_outline,
              accentColor: ArvinColors.primary,
              selectedCount: _personIds.length,
              child: _MultiSelectChips(
                allLabel: 'همه اشخاص',
                accentColor: ArvinColors.primary,
                options: widget.people
                    .map((person) => MapEntry(person.id, person.displayName))
                    .toList(growable: false),
                selected: _personIds,
                onChanged: (value) => setState(() => _personIds = value),
                keyPrefix: 'report-filter-person',
              ),
            ),
            _Section(
              title: 'دسته',
              icon: Icons.category_outlined,
              accentColor: ArvinColors.category,
              selectedCount: _categories.length,
              child: _MultiSelectChips(
                allLabel: 'همه دسته‌ها',
                accentColor: ArvinColors.category,
                options: categories.map((value) => MapEntry(value, value)).toList(growable: false),
                selected: _categories,
                onChanged: (value) => setState(() => _categories = value),
                keyPrefix: 'report-filter-category',
              ),
            ),
            _Section(
              title: 'برچسب',
              icon: Icons.sell_outlined,
              accentColor: ArvinColors.tag,
              selectedCount: _tags.length,
              child: _MultiSelectChips(
                allLabel: 'همه برچسب‌ها',
                accentColor: ArvinColors.tag,
                options: tags.map((value) => MapEntry(value, value)).toList(growable: false),
                selected: _tags,
                onChanged: (value) => setState(() => _tags = value),
                keyPrefix: 'report-filter-tag',
              ),
            ),
            _Section(
              title: 'یادداشت',
              icon: Icons.sticky_note_2_outlined,
              accentColor: ArvinColors.primary,
              selectedCount: _noteKinds.length +
                  (_noteQueryController.text.trim().isNotEmpty ? 1 : 0) +
                  (_noteFromDate != null || _noteToDate != null ? 1 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('report-filter-note-query'),
                    controller: _noteQueryController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان یا متن یادداشت',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      FilterChip(
                        key: const ValueKey('report-filter-note-kind-note'),
                        label: const Text('یادداشت'),
                        selected: _noteKinds.contains(NotebookItemKind.note),
                        selectedColor: ArvinColors.primarySoft,
                        checkmarkColor: ArvinColors.primary,
                        onSelected: (selected) => setState(() {
                          selected
                              ? _noteKinds.add(NotebookItemKind.note)
                              : _noteKinds.remove(NotebookItemKind.note);
                        }),
                      ),
                      FilterChip(
                        key: const ValueKey('report-filter-note-kind-checklist'),
                        label: const Text('چک‌لیست'),
                        selected: _noteKinds.contains(NotebookItemKind.checklist),
                        selectedColor: ArvinColors.timeSoft,
                        checkmarkColor: ArvinColors.time,
                        onSelected: (selected) => setState(() {
                          selected
                              ? _noteKinds.add(NotebookItemKind.checklist)
                              : _noteKinds.remove(NotebookItemKind.checklist);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ReportNoteDateField>(
                    key: const ValueKey('report-filter-note-date-field'),
                    initialValue: _noteDateField ?? ReportNoteDateField.created,
                    decoration: const InputDecoration(labelText: 'مبنای تاریخ یادداشت'),
                    items: const [
                      DropdownMenuItem(
                        value: ReportNoteDateField.created,
                        child: Text('تاریخ ایجاد'),
                      ),
                      DropdownMenuItem(
                        value: ReportNoteDateField.updated,
                        child: Text('تاریخ تغییر'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _noteDateField = value),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickNoteDate(true),
                          child: Text(_dateLabel(_noteFromDate, 'از تاریخ')),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickNoteDate(false),
                          child: Text(_dateLabel(_noteToDate, 'تا تاریخ')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'وضعیت کار',
              icon: Icons.flag_outlined,
              accentColor: ArvinColors.reminder,
              selectedCount: _statuses.length,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  FilterChip(
                    key: const ValueKey('report-filter-status-all'),
                    label: const Text('همه'),
                    selected: _statuses.isEmpty,
                    onSelected: (_) => setState(() => _statuses.clear()),
                  ),
                  for (final value in ReportStatusFilter.values.where((v) => v != ReportStatusFilter.all))
                    FilterChip(
                      key: ValueKey('report-filter-status-${value.name}'),
                      label: Text(_statusLabel(value)),
                      selected: _statuses.contains(value),
                      selectedColor: switch (value) {
                        ReportStatusFilter.open => ArvinColors.projectSoft,
                        ReportStatusFilter.completed => ArvinColors.timeSoft,
                        ReportStatusFilter.archived => ArvinColors.neutralSoft,
                        ReportStatusFilter.all => ArvinColors.primarySoft,
                      },
                      checkmarkColor: switch (value) {
                        ReportStatusFilter.open => ArvinColors.project,
                        ReportStatusFilter.completed => ArvinColors.time,
                        ReportStatusFilter.archived => ArvinColors.neutral,
                        ReportStatusFilter.all => ArvinColors.primary,
                      },
                      onSelected: (selected) => setState(() {
                        selected ? _statuses.add(value) : _statuses.remove(value);
                      }),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'Tracking',
              icon: Icons.track_changes_outlined,
              accentColor: ArvinColors.reminder,
              selectedCount: _trackingLevels.length,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  FilterChip(
                    key: const ValueKey('report-filter-tracking-all'),
                    label: const Text('همه'),
                    selected: _trackingLevels.isEmpty,
                    onSelected: (_) => setState(() => _trackingLevels.clear()),
                  ),
                  FilterChip(
                    key: const ValueKey('report-filter-tracking-normal'),
                    label: const Text('عادی'),
                    selected: _trackingLevels.contains(RecurrenceTrackingLevel.normal),
                    selectedColor: ArvinColors.neutralSoft,
                    checkmarkColor: ArvinColors.neutral,
                    onSelected: (selected) => setState(() {
                      selected
                          ? _trackingLevels.add(RecurrenceTrackingLevel.normal)
                          : _trackingLevels.remove(RecurrenceTrackingLevel.normal);
                    }),
                  ),
                  FilterChip(
                    key: const ValueKey('report-filter-tracking-important'),
                    label: const Text('مهم و قابل پیگیری'),
                    selected: _trackingLevels.contains(RecurrenceTrackingLevel.tracking),
                    selectedColor: ArvinColors.reminderSoft,
                    checkmarkColor: ArvinColors.reminder,
                    onSelected: (selected) => setState(() {
                      selected
                          ? _trackingLevels.add(RecurrenceTrackingLevel.tracking)
                          : _trackingLevels.remove(RecurrenceTrackingLevel.tracking);
                    }),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Follow-up',
              icon: Icons.notifications_active_outlined,
              accentColor: ArvinColors.time,
              selectedCount: _hasFollowUp == null ? 0 : 1,
              child: Wrap(
                spacing: 6,
                children: [
                  _TriStateChip(
                    label: 'پیگیری',
                    value: _hasFollowUp,
                    onChanged: (value) => setState(() => _hasFollowUp = value),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'اهمیت',
              icon: Icons.star_border_rounded,
              accentColor: ArvinColors.tag,
              selectedCount: _priority == null ? 0 : 1,
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
              title: 'ویژگی‌های کار',
              icon: Icons.checklist_outlined,
              accentColor: ArvinColors.category,
              selectedCount: (_hasRepeat != null ? 1 : 0) + (_hasChecklist != null ? 1 : 0),
              child: Wrap(
                spacing: 6,
                children: [
                  _TriStateChip(
                    label: 'تکرار',
                    value: _hasRepeat,
                    onChanged: (value) => setState(() => _hasRepeat = value),
                  ),
                  _TriStateChip(
                    label: 'Checklist',
                    value: _hasChecklist,
                    onChanged: (value) => setState(() => _hasChecklist = value),
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                boxShadow: const [BoxShadow(blurRadius: 12, color: ArvinColors.shadowSoft, offset: Offset(0, -3))],
              ),
              child: SafeArea(
                top: false,
                child: Row(
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
                          _personIds = <String>{};
                          _statuses.clear();
                          _trackingLevels.clear();
                          _noteKinds.clear();
                          _noteQueryController.clear();
                          _noteDateField = null;
                          _noteFromDate = null;
                          _noteToDate = null;
                          _priority = null;
                          _hasRepeat = null;
                          _hasFollowUp = null;
                          _hasChecklist = null;
                        }),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                        child: const Text('بازنشانی'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('report-filter-apply'),
                        onPressed: _apply,
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                        child: const Text('اعمال فیلتر'),
                      ),
                    ),
                  ],
                ),
              ),
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
    this.accentColor = ArvinColors.primary,
    required this.selected,
    required this.onChanged,
    required this.keyPrefix,
  });

  final String allLabel;
  final Color accentColor;
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
            key: ValueKey('$keyPrefix-all'),
            label: Text(allLabel),
            selected: selected.isEmpty,
            selectedColor: accentColor.withValues(alpha: .16),
            checkmarkColor: accentColor,
            onSelected: (_) => onChanged(<String>{}),
          ),
          for (final option in options)
            FilterChip(
              key: ValueKey('$keyPrefix-${option.key}'),
              label: Text(option.value),
              selected: selected.contains(option.key),
              selectedColor: accentColor.withValues(alpha: .16),
              checkmarkColor: accentColor,
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

class _Section extends StatefulWidget {
  const _Section({
    required this.title,
    required this.child,
    this.icon = Icons.tune_outlined,
    this.accentColor,
    this.selectedCount = 0,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final IconData icon;
  final Color? accentColor;
  final int selectedCount;
  final bool initiallyExpanded;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = widget.accentColor ?? colors.primary;
    return Card(
      key: ValueKey('report-filter-section-${widget.title}'),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: (widget.accentColor ?? colors.outlineVariant).withValues(alpha: .18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (value) => setState(() => _expanded = value),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(widget.icon, color: accent),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (widget.selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  widget.selectedCount.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
        children: [widget.child],
      ),
    );
  }
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
  return const PersianDateFormatter().formatTime(value.hour, value.minute);
}

TimeOfDay _toTimeOfDay(Duration value) =>
    TimeOfDay(hour: value.inHours % 24, minute: value.inMinutes % 60);
