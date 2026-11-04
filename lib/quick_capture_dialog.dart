import 'package:flutter/material.dart';

import 'arvin_colors.dart';
import 'models/arvin_center.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/quick_capture_service.dart';
import 'services/task_project_assignment_service.dart';
import 'widgets/arvin_roll_box.dart';
import 'widgets/universal_arvin_time_picker.dart';
import 'widgets/persian_date_picker.dart';

/// Compact Persian quick-capture surface backed by the canonical parser.
///
/// This widget owns no persistence. When [onCaptured] is supplied, every
/// canonical [Task] is handed to the caller for persistence and the dialog
/// remains open for the next entry. Without it, the legacy single-capture
/// behavior is preserved and the task is returned through Navigator.pop.
class QuickCaptureDialog extends StatefulWidget {
  const QuickCaptureDialog({
    super.key,
    this.service = const QuickCaptureService(),
    this.idFactory,
    this.now,
    this.onCaptured,
    this.onFullForm,
    this.projects = const <ProjectPlan>[],
    this.centers = const <ArvinCenter>[],
    this.initialProjectId,
    this.initialCenterId,
    this.onCreateProjectWithCenter,
    this.onProjectChanged,
    this.knownCategories = const <String>[],
    this.knownTags = const <String>[],
    this.onCreateCategory,
    this.onCreateTag,
    this.onCreateProject,
  });

  final QuickCaptureService service;
  final String Function()? idFactory;
  final DateTime Function()? now;
  final Future<void> Function(Task task)? onCaptured;
  final Future<bool> Function(Task draft)? onFullForm;
  final List<ProjectPlan> projects;
  final List<ArvinCenter> centers;
  final String? initialProjectId;
  final String? initialCenterId;
  final Future<String?> Function(String title, String? centerId)? onCreateProjectWithCenter;
  final ValueChanged<String?>? onProjectChanged;
  final List<String> knownCategories;
  final List<String> knownTags;
  final Future<String?> Function(String name)? onCreateCategory;
  final Future<String?> Function(String name)? onCreateTag;

  /// Canonical Project creation; no Quick Capture-owned persistence.
  final Future<String?> Function(String title)? onCreateProject;

  @override
  State<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<QuickCaptureDialog> {
  static const _dateFormatter = PersianDateFormatter();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  String? _error;
  bool _backHandling = false;
  bool _saving = false;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  bool _reminderFollowsDueTime = true;
  RecurrenceRule? _recurrence;
  String? _projectId;
  String? _centerId;
  final TextEditingController _categoryController = TextEditingController();
  final List<String> _selectedTags = <String>[];
  late List<ProjectPlan> _knownProjects;
  late List<String> _knownCategories;
  late List<String> _knownTags;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
    _knownCategories = List<String>.of(widget.knownCategories);
    _knownTags = List<String>.of(widget.knownTags);
    _knownProjects = List<ProjectPlan>.of(widget.projects);
    final selectedProject = _knownProjects.where((project) => project.id == _projectId);
    _centerId = widget.initialCenterId ??
        (selectedProject.isEmpty ? null : selectedProject.first.centerId);
  }

  Future<void> _handleBack() async {
    if (_backHandling || !mounted) return;
    _backHandling = true;
    try {
      final primaryFocus = FocusManager.instance.primaryFocus;
      if (primaryFocus != null) {
        primaryFocus.unfocus();
        return;
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } finally {
      _backHandling = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleFocus.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _syncAutomaticReminder() {
    if (!_reminderFollowsDueTime) return;
    if (_dueDate == null) {
      _reminderDate = null;
    } else {
      _reminderDate = _dueDate;
    }
  }

  void _setDueDate(DateTime? value) {
    setState(() {
      _dueDate = value;
      _syncAutomaticReminder();
    });
  }

  Task? _buildDraft() {
    final createdAt = widget.now?.call() ?? DateTime.now();
    final task = widget.service.capture(
      _controller.text,
      id: widget.idFactory?.call() ?? createdAt.microsecondsSinceEpoch.toString(),
      createdAt: createdAt,
    );
    if (task == null) return null;
    task.priority = _priority;
    _syncAutomaticReminder();
    task.dueDate = _dueDate;
    task.reminderDate = _reminderDate;
    task.recurrence = _recurrence;
    final category = _categoryController.text.trim();
    task.category = category.isEmpty ? null : category;
    task.tags = {...task.tags, ..._selectedTags}.toList(growable: false);
    return task;
  }

  Future<void> _submit() async {
    if (_saving) return;
    final task = _buildDraft();
    if (task == null) {
      setState(() => _error = 'عنوان برای ثبت کافی است');
      return;
    }
    final onCaptured = widget.onCaptured;
    if (onCaptured == null) {
      Navigator.of(context).pop(task);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      widget.onProjectChanged?.call(_projectId);
      await onCaptured(task);
      if (!mounted) return;
      _controller.clear();
      setState(() {
        _priority = TaskPriority.medium;
        _saving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(_titleFocus);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'ثبت انجام نشد؛ متن و انتخاب‌ها حفظ شدند';
      });
    }  }


  Future<void> _openFullForm() async {
    if (_saving) return;
    final draft = _buildDraft();
    if (draft == null) {
      setState(() => _error = 'عنوان برای ادامه کافی است');
      return;
    }
    final onFullForm = widget.onFullForm;
    if (onFullForm == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      widget.onProjectChanged?.call(_projectId);
      final saved = await onFullForm(draft);
      if (!mounted) return;
      if (saved) {
        _controller.clear();
      }
      setState(() {
        if (saved) _priority = TaskPriority.medium;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'باز کردن فرم کامل انجام نشد؛ متن و انتخاب‌ها حفظ شدند';
      });
    }
  }

  String _dateLabel(DateTime? value) {
    if (value == null) return 'بدون موعد';
    final formatter = const PersianDateFormatter();
    final date = formatter.format(value, usePersianDate: true);
    final time = formatter.formatTime(value.hour, value.minute);
    return '$date • $time';
  }

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  Future<TimeOfDay?> _pickPersianTime(
    BuildContext parentContext, {
    required DateTime initial,
    required String helpText,
  }) {
    return showUniversalArvinTimePicker(
      context: parentContext,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: helpText,
    );
  }

Future<DateTime?> _pickCustomDue() async {
    final initial = _dueDate ?? widget.now?.call() ?? DateTime.now();
    final date = await showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ',
      cancelText: 'لغو',
      confirmText: 'انتخاب تاریخ',
    );
    if (date == null || !mounted) return null;
    final time = await _pickPersianTime(context, initial: initial, helpText: 'زمان انجام کار');
    if (time == null || !mounted) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DateTime?> _pickCustomReminder() async {
    final initial = _reminderDate ?? _dueDate ?? widget.now?.call() ?? DateTime.now();
    final date = await showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ',
      cancelText: 'لغو',
      confirmText: 'انتخاب تاریخ',
    );
    if (date == null || !mounted) return null;
    final time = await _pickPersianTime(context, initial: initial, helpText: 'زمان یادآوری');
    if (time == null || !mounted) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<RecurrenceRule?> _pickCustomRecurrence() async {
    final controller = TextEditingController(text: _recurrence?.interval.toString() ?? '1');
    var frequency = _recurrence?.frequency ?? RecurrenceFrequency.daily;
    try {
      return await showDialog<RecurrenceRule>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تکرار سفارشی'),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder: (context, setDialogState) => ArvinRollBox<RecurrenceFrequency>(
                    key: const ValueKey('quick-capture-custom-recurrence-frequency'),
                    label: 'واحد تکرار',
                    valueLabel: switch (frequency) {
                      RecurrenceFrequency.minutes => 'دقیقه',
                      RecurrenceFrequency.hours => 'ساعت',
                      RecurrenceFrequency.daily => 'روز',
                      RecurrenceFrequency.weekly => 'هفته',
                      RecurrenceFrequency.monthly => 'ماه',
                      RecurrenceFrequency.yearly => 'سال',
                      RecurrenceFrequency.oncePerDay => 'روز',
                    },
                    icon: Icons.repeat_rounded,
                    color: ArvinColors.primary,
                    items: const [
                      ArvinRollItem(value: RecurrenceFrequency.minutes, label: 'دقیقه', icon: Icons.schedule_rounded),
                      ArvinRollItem(value: RecurrenceFrequency.hours, label: 'ساعت', icon: Icons.access_time_rounded),
                      ArvinRollItem(value: RecurrenceFrequency.daily, label: 'روز', icon: Icons.today_outlined),
                      ArvinRollItem(value: RecurrenceFrequency.weekly, label: 'هفته', icon: Icons.view_week_outlined),
                      ArvinRollItem(value: RecurrenceFrequency.monthly, label: 'ماه', icon: Icons.calendar_month_outlined),
                      ArvinRollItem(value: RecurrenceFrequency.yearly, label: 'سال', icon: Icons.event_repeat_outlined),
                    ],
                    onSelected: (value) {
                      if (value != null) setDialogState(() => frequency = value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'تعداد', hintText: 'مثلاً ۵'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لغو')),
            FilledButton(
              onPressed: () {
                final interval = int.tryParse(controller.text.trim());
                if (interval == null || interval < 1) return;
                Navigator.pop(dialogContext, RecurrenceRule(frequency: frequency, interval: interval));
              },
              child: const Text('ثبت'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  String _recurrenceLabel() {
    if (_recurrence == null) return 'تکرار';
    final unit = switch (_recurrence!.frequency) {
      RecurrenceFrequency.daily => 'روز',
      RecurrenceFrequency.weekly => 'هفته',
      RecurrenceFrequency.monthly => 'ماه',
      RecurrenceFrequency.yearly => 'سال',
      RecurrenceFrequency.oncePerDay => 'روز',
      RecurrenceFrequency.minutes => 'دقیقه',
      RecurrenceFrequency.hours => 'ساعت',
    };
    final formatter = const PersianDateFormatter();
    final interval = formatter.toPersianDigits(_recurrence!.interval.toString());
    return 'هر $interval $unit';
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: KeyedSubtree(
        key: const ValueKey('quick-capture-dialog'),
        child: _buildContent(context),
      ),
    );
  }

  Widget _priorityDropdown() {
    final selectedColor = ArvinColors.priorityColor(_priority);
    return Tooltip(
      message: '${_dateFormatter.toPersianDigits('اولویت ${_priority.sortOrder}')} — ${_priority.label}',
      child: DecoratedBox(
        key: const ValueKey('quick-capture-priority-surface'),
        decoration: BoxDecoration(
          color: selectedColor.withValues(alpha: 0.06),
          border: Border.all(color: selectedColor.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskPriority>(
              key: const ValueKey('quick-capture-priority-dropdown'),
              value: _priority,
              isExpanded: true,
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 320,
              selectedItemBuilder: (context) => TaskPriority.values.map((priority) {
                final color = ArvinColors.priorityColor(priority);
                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'اولویت',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(growable: false),
              items: TaskPriority.values.map((priority) {
                final color = ArvinColors.priorityColor(priority);
                return DropdownMenuItem<TaskPriority>(
                  value: priority,
                  child: Text(
                    _dateFormatter.toPersianDigits('اولویت ${priority.sortOrder}'),
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(growable: false),
              onChanged: _saving ? null : (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableCenters = widget.centers
        .where((center) => !center.isArchived || center.id == _centerId)
        .toList(growable: false);
    final availableProjects = _knownProjects
        .where((project) =>
            (!project.isArchived || project.id == _projectId) &&
            (_centerId == null || project.centerId == _centerId))
        .toList(growable: false);
    final selectedCenter = availableCenters.where((center) => center.id == _centerId).toList();
    final selectedProject = _knownProjects.where((project) => project.id == _projectId).toList();

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        widthFactor: 1,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 6, 12, bottomInset + 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      IconButton(
                        key: const ValueKey('quick-capture-full-form'),
                        tooltip: 'ورود به فرم کامل',
                        visualDensity: VisualDensity.compact,
                        onPressed: _saving ? null : _openFullForm,
                        icon: const Icon(Icons.open_in_new_rounded),
                      ),
                      const Expanded(child: Text(
                        'ثبت سریع کار',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ArvinColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                      )),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    key: const ValueKey('quick-capture-input'),
                    controller: _controller,
                    focusNode: _titleFocus,
                    autofocus: true,
                    enabled: !_saving,
                    minLines: 1,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'عنوان کار را وارد کنید',
                      errorText: _error,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: ArvinColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: ArvinColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SingleChildScrollView(
                      key: const ValueKey('quick-capture-categories-scroll'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          SizedBox(
                            width: 128,
                            child: ArvinRollBox<String>(
                              key: const ValueKey('quick-capture-center-rollbox'),
                              label: 'مرکز',
                              valueLabel: selectedCenter.isEmpty ? 'مرکز' : selectedCenter.first.name,
                              icon: Icons.business_outlined,
                              color: ArvinColors.primary,
                              emptyLabel: 'همه مراکز',
                              items: availableCenters.map((center) => ArvinRollItem<String>(
                                value: center.id, label: center.name,
                                icon: Icons.business_outlined, color: ArvinColors.primary,
                              )).toList(growable: false),
                              onSelected: (value) {
                                setState(() {
                                  _centerId = value;
                                  if (_projectId != null) {
                                    final current = _knownProjects.where((project) => project.id == _projectId);
                                    if (current.isEmpty || (value != null && current.first.centerId != value)) {
                                      _projectId = null;
                                      widget.onProjectChanged?.call(null);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 148,
                            child: ArvinRollBox<String>(
                              key: const ValueKey('quick-capture-project-rollbox'),
                              label: 'پروژه',
                              valueLabel: selectedProject.isEmpty ? 'پروژه' : selectedProject.first.title,
                              icon: Icons.folder_outlined,
                              color: ArvinColors.project,
                              emptyLabel: 'بدون پروژه',
                              createLabel: 'ایجاد جدید',
                              items: availableProjects.map((project) => ArvinRollItem<String>(
                                value: project.id,
                                label: project.isArchived ? '${project.title} (بایگانی‌شده)' : project.title,
                                icon: Icons.folder_outlined,
                                color: project.isArchived ? ArvinColors.textSecondary : ArvinColors.project,
                              )).toList(growable: false),
                              onSelected: (value) {
                                setState(() {
                                  _projectId = value;
                                  if (value != null) {
                                    final match = _knownProjects.where((project) => project.id == value);
                                    _centerId = match.isEmpty ? null : match.first.centerId;
                                  }
                                  widget.onProjectChanged?.call(value);
                                });
                              },
                              onCreate: () async {
                                var draftName = '';
                                final value = await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (ctx) => Padding(
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
                                    child: SingleChildScrollView(
                                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                                        const Text('پروژه جدید'),
                                        TextField(autofocus: false, onChanged: (text) => draftName = text,
                                          decoration: const InputDecoration(labelText: 'نام پروژه')),
                                        FilledButton(onPressed: () => Navigator.pop(ctx, draftName.trim()),
                                          child: const Text('افزودن')),
                                      ]),
                                    ),
                                  ),
                                );
                                if (value == null || value.isEmpty) return null;
                                final createWithCenter = widget.onCreateProjectWithCenter;
                                final createProject = widget.onCreateProject;
                                final createdId = createWithCenter != null
                                    ? await createWithCenter(value, _centerId)
                                    : createProject != null
                                        ? await createProject(value)
                                        : await TaskProjectAssignmentService()
                                            .createProject(title: value, centerId: _centerId)
                                            .then((project) => project.id);
                                if (!mounted || createdId == null) return createdId;
                                final existing = _knownProjects.where((project) => project.id == createdId).toList();
                                if (existing.isEmpty) {
                                  _knownProjects = List<ProjectPlan>.of(
                                    await TaskProjectAssignmentService().loadProjects(),
                                  );
                                }
                                final created = _knownProjects.where((project) => project.id == createdId).toList();
                                setState(() {
                                  _projectId = createdId;
                                  if (created.isNotEmpty) _centerId = created.first.centerId;
                                });
                                widget.onProjectChanged?.call(createdId);
                                return createdId;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 128,
                            child: ArvinRollBox<String>(
                              key: const ValueKey('quick-capture-category-rollbox'),
                              label: 'دسته',
                              valueLabel: _categoryController.text.trim().isEmpty ? 'دسته' : _categoryController.text.trim(),
                              icon: Icons.grid_view_rounded,
                              color: ArvinColors.tag,
                              emptyLabel: 'بدون دسته',
                              items: _knownCategories.map((v) => v.trim()).where((v) => v.isNotEmpty)
                                  .map((v) => ArvinRollItem<String>(
                                    value: v, label: v, icon: Icons.grid_view_rounded, color: ArvinColors.tag,
                                  )).toList(growable: false),
                              onSelected: (v) => setState(() => _categoryController.text = v ?? ''),
                              onCreate: () async {
                                final controller = TextEditingController();
                                final value = await showModalBottomSheet<String>(
                                  context: context, isScrollControlled: true,
                                  builder: (ctx) => Padding(
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      const Text('دسته جدید'),
                                      TextField(controller: controller, autofocus: true,
                                        decoration: const InputDecoration(labelText: 'نام')),
                                      FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                        child: const Text('افزودن')),
                                    ]),
                                  ),
                                );
                                controller.dispose();
                                if (value == null || value.isEmpty) return null;
                                final created = await widget.onCreateCategory?.call(value) ?? value;
                                if (!mounted) return created;
                                setState(() {
                                  _categoryController.text = created;
                                  if (!_knownCategories.contains(created)) _knownCategories.add(created);
                                });
                                return created;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 152,
                            child: ArvinTagRollBox(
                              key: const ValueKey('quick-capture-tag-rollbox'),
                              tags: _knownTags,
                              selectedTags: _selectedTags,
                              onChanged: (values) => setState(() {
                                _selectedTags..clear()..addAll(values);
                              }),
                              onCreate: () async {
                                final controller = TextEditingController();
                                final value = await showModalBottomSheet<String>(
                                  context: context, isScrollControlled: true,
                                  builder: (ctx) => Padding(
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      const Text('برچسب جدید'),
                                      TextField(controller: controller, autofocus: true,
                                        decoration: const InputDecoration(labelText: 'نام')),
                                      FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                        child: const Text('افزودن')),
                                    ]),
                                  ),
                                );
                                controller.dispose();
                                if (value == null || value.isEmpty) return null;
                                final created = await widget.onCreateTag?.call(value) ?? value;
                                if (!mounted) return created;
                                setState(() {
                                  if (!_selectedTags.contains(created)) _selectedTags.add(created);
                                  if (!_knownTags.contains(created)) _knownTags.add(created);
                                });
                                return created;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SingleChildScrollView(
                      key: const ValueKey('quick-capture-settings-scroll'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          SizedBox(width: 124, child: _priorityDropdown()),
                          const SizedBox(width: 8),
                          SizedBox(width: 148, child: ArvinRollBox<Object?>(
                            key: const ValueKey('quick-capture-due-rollbox'),
                            label: 'تاریخ و ساعت',
                            valueLabel: _dueDate == null ? 'تاریخ و ساعت' : _dateLabel(_dueDate),
                            icon: Icons.calendar_today_outlined,
                            color: ArvinColors.time,
                            emptyLabel: 'بدون تاریخ و ساعت',
                            items: [
                              ArvinRollItem<Object?>(value: _now(), label: 'امروز', icon: Icons.today_outlined, color: ArvinColors.time),
                              ArvinRollItem<Object?>(value: _now().add(const Duration(days: 1)), label: 'فردا', icon: Icons.event_outlined, color: ArvinColors.project),
                              ArvinRollItem<Object?>(value: _now().add(const Duration(days: 7)), label: 'هفته آینده', icon: Icons.date_range_outlined, color: ArvinColors.tag),
                            ],
                            createLabel: 'تاریخ و ساعت سفارشی',
                            onCreate: _saving ? null : _pickCustomDue,
                            onSelected: (value) => _setDueDate(value is DateTime ? value : null),
                          )),
                          const SizedBox(width: 8),
                          SizedBox(width: 148, child: ArvinRollBox<Object?>(
                            key: const ValueKey('quick-capture-reminder-rollbox'),
                            label: 'یادآور',
                            valueLabel: _reminderDate == null ? 'یادآور' : _dateLabel(_reminderDate),
                            icon: Icons.notifications_none_outlined,
                            color: ArvinColors.reminder,
                            emptyLabel: 'بدون یادآور',
                            items: [
                              ArvinRollItem<Object?>(value: _dueDate ?? _now(), label: 'همان زمان موعد', icon: Icons.notifications_active_outlined, color: ArvinColors.reminder),
                              ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(minutes: 15)), label: '۱۵ دقیقه قبل', icon: Icons.notifications_active_outlined, color: ArvinColors.reminder),
                              ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(hours: 1)), label: 'یک ساعت قبل', icon: Icons.notifications_active_outlined, color: ArvinColors.reminder),
                              ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(days: 1)), label: 'یک روز قبل', icon: Icons.notifications_active_outlined, color: ArvinColors.reminder),
                              ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(days: 7)), label: 'یک هفته قبل', icon: Icons.notifications_active_outlined, color: ArvinColors.reminder),
                            ],
                            createLabel: 'تاریخ و ساعت سفارشی',
                            onCreate: _saving ? null : _pickCustomReminder,
                            onSelected: (value) {
                              setState(() {
                                _reminderDate = value is DateTime ? value : null;
                                _reminderFollowsDueTime = false;
                              });
                            },
                          )),
                          const SizedBox(width: 8),
                          SizedBox(width: 132, child: ArvinRollBox<RecurrenceRule?>(
                            key: const ValueKey('quick-capture-recurrence-rollbox'),
                            label: 'تکرار',
                            valueLabel: _recurrenceLabel(),
                            icon: Icons.repeat_rounded,
                            color: ArvinColors.category,
                            emptyLabel: 'بدون تکرار',
                            items: const [
                              ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.daily), label: 'هر روز', icon: Icons.today_outlined, color: ArvinColors.category),
                              ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.weekly), label: 'هر هفته', icon: Icons.view_week_outlined, color: ArvinColors.project),
                              ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.monthly), label: 'هر ماه', icon: Icons.calendar_month_outlined, color: ArvinColors.tag),
                              ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.yearly), label: 'هر سال', icon: Icons.event_repeat_outlined, color: ArvinColors.time),
                            ],
                            createLabel: 'تکرار سفارشی',
                            onCreate: _saving ? null : _pickCustomRecurrence,
                            onSelected: (value) => setState(() => _recurrence = value),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(child: FilledButton(
                        key: const ValueKey('quick-capture-submit'),
                        onPressed: _saving ? null : _submit,
                        child: Text(_saving ? 'در حال ثبت…' : 'ثبت کار'),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: TextButton(
                        key: const ValueKey('quick-capture-cancel'),
                        onPressed: _saving ? null : () => Navigator.of(context).pop(),
                        child: const Text('لغو'),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
