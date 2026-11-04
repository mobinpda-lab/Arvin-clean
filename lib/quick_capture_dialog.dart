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
  final TextEditingController _descriptionController = TextEditingController();
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
    _descriptionController.dispose();
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
    task.description = _descriptionController.text.trim();
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
      const message = 'عنوان برای ثبت کافی است';
      setState(() => _error = message);
      // Keep the compact inline field error and mirror it in the floating
      // messenger so the validation remains visible without growing the form.
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: const Text('عنوان برای ثبت کافی است'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
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
      _descriptionController.clear();
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
        _descriptionController.clear();
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
    const hints = <TaskPriority, String>{
      TaskPriority.high: 'فوری و مهم',
      TaskPriority.medium: 'مهم و غیرفوری',
      TaskPriority.low: 'فوری و غیرمهم',
      TaskPriority.none: 'غیرفوری و غیرمهم',
    };
    return KeyedSubtree(
      key: const ValueKey('quick-capture-priority-dropdown'),
      child: _surfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('اولویت', textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, height: 1.1, fontWeight: FontWeight.w700, color: ArvinColors.textPrimary)),
            const SizedBox(height: 4),
            Row(
              textDirection: TextDirection.rtl,
              children: TaskPriority.values.map((priority) {
                final color = ArvinColors.priorityColor(priority);
                final selected = _priority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: 'اولویت ${priority.sortOrder}، ${hints[priority]}',
                      child: InkWell(
                        key: ValueKey('quick-capture-priority-option-${priority.sortOrder}'),
                        borderRadius: BorderRadius.circular(12),
                        onTap: _saving ? null : () => setState(() => _priority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: selected ? 0.18 : 0.09),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: selected ? 0.95 : 0.28),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _dateFormatter.toPersianDigits('اولویت ${priority.sortOrder}'),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: color, fontSize: 10, height: 1.15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
            const SizedBox(height: 3),
            Row(
              textDirection: TextDirection.rtl,
              children: TaskPriority.values.map((priority) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    hints[priority]!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: ArvinColors.textSecondary, fontSize: 8, height: 1.1),
                  ),
                ),
              )).toList(growable: false),
            ),

          ],
        ),
      ),
    );
  }

  Widget _surfaceCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(6)}) {
    return Card(
      elevation: 1,
      shadowColor: ArvinColors.shadowSoft,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: padding, child: child),
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

    return ColoredBox(
      color: const Color(0xFFF5F6FA),
      child: SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        widthFactor: 1,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 2, 12, bottomInset + 4),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: ArvinColors.primaryDark,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        IconButton(
                          key: const ValueKey('quick-capture-close'),
                          tooltip: 'بستن',
                          onPressed: _saving ? null : () => Navigator.of(context).pop(),
                          color: Colors.white,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const Expanded(child: Text(
                          'ثبت سریع کار',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white, fontSize: 16, height: 1.1, fontWeight: FontWeight.w800),
                        )),
                        IconButton(
                          key: const ValueKey('quick-capture-full-form'),
                          tooltip: 'ورود به فرم کامل',
                          visualDensity: VisualDensity.compact,
                          onPressed: _saving ? null : _openFullForm,
                          color: Colors.white,
                          icon: const Icon(Icons.open_in_new_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  _surfaceCard(
                    child: TextField(
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
                        prefixIcon: const Icon(Icons.title_rounded, size: 18, color: ArvinColors.primary),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _surfaceCard(
                    child: TextField(
                      key: const ValueKey('quick-capture-description'),
                      controller: _descriptionController,
                      enabled: !_saving,
                      minLines: 1,
                      maxLines: 2,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        hintText: 'توضیحات تکمیلی...',
                        prefixIcon: Icon(Icons.notes_rounded, size: 18, color: ArvinColors.primary),
                         isDense: true,
                         contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _surfaceCard(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SingleChildScrollView(
                      key: const ValueKey('quick-capture-categories-scroll'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          SizedBox(
                            width: 112,
                            child: ArvinRollBox<String>(
                              key: const ValueKey('quick-capture-center-rollbox'),
                              label: 'مرکز',
                              compact: true,
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
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 124,
                            child: ArvinRollBox<String>(
                              key: const ValueKey('quick-capture-project-rollbox'),
                              label: 'پروژه',
                              compact: true,
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
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 128,
                            child: ArvinRollBox<String>(
                              key: const ValueKey('quick-capture-category-rollbox'),
                              label: 'دسته',
                              compact: true,
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
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 120,
                            child: ArvinTagRollBox(
                              compact: true,
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
                  ),
                  const SizedBox(height: 6),
                  _surfaceCard(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SingleChildScrollView(
                      key: const ValueKey('quick-capture-settings-scroll'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          SizedBox(width: 124, child: ArvinRollBox<Object?>(
                            key: const ValueKey('quick-capture-due-rollbox'),
                            label: 'تاریخ و ساعت',
                            compact: true,
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
                          const SizedBox(width: 6),
                          SizedBox(width: 148, child: ArvinRollBox<Object?>(
                            key: const ValueKey('quick-capture-reminder-rollbox'),
                            label: 'یادآور',
                            compact: true,
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
                          const SizedBox(width: 6),
                          SizedBox(width: 108, child: ArvinRollBox<RecurrenceRule?>(
                            key: const ValueKey('quick-capture-recurrence-rollbox'),
                            label: 'تکرار',
                            compact: true,
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
                  ),
                  const SizedBox(height: 5),
                  _priorityDropdown(),
                  const SizedBox(height: 5),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(child: FilledButton(
                        key: const ValueKey('quick-capture-submit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: ArvinColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _saving ? null : _submit,
                        child: Text(_saving ? 'در حال ثبت…' : 'ثبت کار'),
                      )),
                      const SizedBox(width: 6),
                      TextButton(
                        key: const ValueKey('quick-capture-cancel'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(64, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        onPressed: _saving ? null : () => Navigator.of(context).pop(),
                        child: const Text('لغو'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
