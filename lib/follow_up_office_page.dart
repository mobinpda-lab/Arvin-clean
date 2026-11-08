import 'package:flutter/material.dart';

import 'arvin_colors.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'follow_up_repository.dart';
import 'models/task.dart';
import 'models/goal_project.dart';
import 'models/arvin_center.dart';
import 'models/person_reference.dart';
import 'services/task_report_filter.dart';
import 'services/project_store.dart';
import 'services/center_store.dart';
import 'services/task_store.dart';
import 'widgets/reusable_multi_select_filter_bottom_sheet.dart';
import 'widgets/persian_date_picker.dart';
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
  TaskReportFilter _filter = const TaskReportFilter(hasFollowUp: true);
  List<_TaskOption> _tasks = const [];
  List<_FollowUpRow> _rows = const [];
  List<ProjectPlan> _projects = const [];
  List<ArvinCenter> _centers = const [];
  List<PersonReference> _people = const [];
  List<String> _categories = const [];
  List<String> _tags = const [];

  @override
  void initState() {
    super.initState();
    _writer = widget.writeCoordinator ??
        FollowUpWriteCoordinator(
          repository: widget.repository,
          reminderReschedule: AndroidFollowUpReminderScheduler().reschedule,
        );
    _load();
  }

  Future<void> _load() async {
    final store = TaskStore();
    final canonicalTasks = await store.load();
    final projects = await ProjectStore().load();
    final centers = await CenterStore().load();
    final people = await store.loadPeopleDirectory();
    final categories = await store.loadCategories();
    final tags = await store.loadTags();
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
            task: task,
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
      _projects = projects;
      _centers = centers;
      _people = people;
      _categories = categories;
      _tags = tags;
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
      MaterialPageRoute(builder: (_) => FollowUpEntryPage(taskId: task.id)),
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

  String _date(DateTime value) =>
      _dateFormatter.format(value, usePersianDate: true);

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
    final source = _showWaitingOnly ? _waitingRows : _rows;
    return source.where((row) => _filter.matchesFollowUpRecord(
      row.task,
      row.followUp,
      now: DateTime.now(),
      projects: _projects,
    )).toList(growable: false);
  }

  Map<String, PersonReference> get _peopleById => {
    for (final person in _people) person.id: person,
  };

  Future<void> _openFilters() async {
    final dimension = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final item in const [
            ('time', 'زمان'),
            ('center', 'مرکز'),
            ('project', 'پروژه'),
            ('category', 'دسته'),
            ('tag', 'برچسب'),
          ])
            ListTile(
              title: Text(item.$2),
              onTap: () => Navigator.of(sheetContext).pop(item.$1),
            ),
        ]),
      ),
    );
    if (dimension == null || !mounted) return;
    if (dimension == 'time') {
      await _pickTimeFilter();
      return;
    }
    late final List<ReusableFilterOption<String>> options;
    late final String title;
    late final Set<String> selected;
    if (dimension == 'center') {
      title = 'مرکز';
      selected = _filter.centerIds;
      options = _centers.map((item) => ReusableFilterOption<String>(
        value: item.id, label: item.name,
      )).toList(growable: false);
    } else if (dimension == 'project') {
      title = 'پروژه';
      selected = _filter.projectIds;
      options = _projects.map((item) => ReusableFilterOption<String>(
        value: item.id, label: item.title,
      )).toList(growable: false);
    } else if (dimension == 'category') {
      title = 'دسته';
      selected = _filter.categories;
      options = _categories.map((item) => ReusableFilterOption<String>(
        value: item, label: item,
      )).toList(growable: false);
    } else {
      title = 'برچسب';
      selected = _filter.tags;
      options = _tags.map((item) => ReusableFilterOption<String>(
        value: item, label: item,
      )).toList(growable: false);
    }
    final values = await ReusableMultiSelectFilterBottomSheet.showMultiSelect<String>(
      context,
      title: title,
      options: options,
      selectedValues: selected,
      optionKeyPrefix: 'follow-up-office-$dimension',
    );
    if (values == null || !mounted) return;
    setState(() {
      _filter = switch (dimension) {
        'center' => _filter.copyWith(centerIds: values),
        'project' => _filter.copyWith(projectIds: values),
        'category' => _filter.copyWith(categories: values),
        _ => _filter.copyWith(tags: values),
      };
    });
  }

  Future<void> _pickTimeFilter() async {
    var preset = _filter.timePreset;
    DateTime? from = _filter.fromDate;
    DateTime? to = _filter.toDate;
    final result = await ReusableMultiSelectFilterBottomSheet.showCustom<TaskReportFilter>(
      context,
      title: 'فیلتر زمان پیگیری',
      accent: Theme.of(context).colorScheme.primary,
      child: StatefulBuilder(builder: (sheetContext, setSheetState) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final entry in const [
              (ReportTimePreset.all, 'همه'),
              (ReportTimePreset.today, 'امروز'),
              (ReportTimePreset.tomorrow, 'فردا'),
              (ReportTimePreset.thisWeek, 'این هفته'),
              (ReportTimePreset.future, 'آینده'),
              (ReportTimePreset.past, 'گذشته'),
            ])
              ChoiceChip(
                label: Text(entry.$2),
                selected: preset == entry.$1,
                onSelected: (_) => setSheetState(() => preset = entry.$1),
              ),
          ]),
          Row(children: [
            Expanded(child: TextButton(
              onPressed: () async {
                final value = await showPersianDatePicker(
                  context: context, initialDate: from ?? DateTime.now(),
                  firstDate: DateTime(2000), lastDate: DateTime(2100),
                  helpText: 'شروع بازه پیگیری',
                );
                if (value != null) setSheetState(() { from = value; preset = ReportTimePreset.all; });
              },
              child: Text(from == null ? 'از تاریخ' : 'از ${_date(from!)}'),
            )),
            Expanded(child: TextButton(
              onPressed: () async {
                final value = await showPersianDatePicker(
                  context: context, initialDate: to ?? from ?? DateTime.now(),
                  firstDate: DateTime(2000), lastDate: DateTime(2100),
                  helpText: 'پایان بازه پیگیری',
                );
                if (value != null) setSheetState(() { to = value; preset = ReportTimePreset.all; });
              },
              child: Text(to == null ? 'تا تاریخ' : 'تا ${_date(to!)}'),
            )),
          ]),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 48, child: FilledButton(
            onPressed: () => Navigator.of(sheetContext).pop(_filter.copyWith(
              timePreset: preset,
              fromDate: from,
              clearFromDate: from == null,
              toDate: to,
              clearToDate: to == null,
            )),
            child: const Text('اعمال فیلتر زمان'),
          )),
        ]),
      )),
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  void _clearFilters() => setState(() {
    _filter = const TaskReportFilter(hasFollowUp: true);
  });

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
            key: const ValueKey('follow-up-office-filters'),
            tooltip: 'فیلترهای پیگیری',
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded),
          ),
          if (_filter.timePreset != ReportTimePreset.all ||
              _filter.fromDate != null || _filter.toDate != null ||
              _filter.centerIds.isNotEmpty || _filter.projectIds.isNotEmpty ||
              _filter.categories.isNotEmpty || _filter.tags.isNotEmpty)
            IconButton(
              tooltip: 'پاک کردن فیلترهای پیگیری',
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
            ),
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
                            if (row.followUp.personIds.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('اشخاص مرتبط: ${row.followUp.personIds.map((id) => _peopleById[id]?.displayName ?? 'شخص حذف‌شده').join('، ')}'),
                            ],
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
    required this.task,
    required this.taskId,
    required this.taskTitle,
    required this.followUp,
  });

  final Task task;
  final String taskId;
  final String taskTitle;
  final FollowUp followUp;

  DateTime get dateTime => followUp.dateTime;
  String get note => followUp.note;
  String? get result => followUp.result;
}
