import 'package:flutter/material.dart';

import 'arvin_colors.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/quick_capture_service.dart';
import 'services/task_project_assignment_service.dart';
import 'follow_up_entry_page.dart';
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
    this.initialProjectId,
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
  final String? initialProjectId;
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
  final TextEditingController _controller = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  String? _error;
  bool _backHandling = false;
  bool _saving = false;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  bool _reminderFollowsDueTime = true;
  bool _checklistEnabled = false;
  final List<FollowUp> _pendingFollowUps = <FollowUp>[];
  final List<String> _checklistItems = <String>[];
  RecurrenceRule? _recurrence;
  final TextEditingController _recurrenceIntervalController =
      TextEditingController(text: '1');
  String? _projectId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
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
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _recurrenceIntervalController.dispose();
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
    task.description = _descriptionController.text.trim();
    _syncAutomaticReminder();
    task.dueDate = _dueDate;
    task.reminderDate = _reminderDate;
    task.recurrence = _recurrence;
    // Compatibility mirror only; the FollowUps list drives current behavior.
    task.followUpEnabled = _pendingFollowUps.isNotEmpty;
    task.followUps = List<FollowUp>.of(_pendingFollowUps);
    task.checklistEnabled = _checklistEnabled;
    task.checklist = List<String>.of(_checklistItems);
    final category = _categoryController.text.trim();
    task.category = category.isEmpty ? null : category;
    final manualTags = _tagsController.text
        .split(RegExp(r'[,،#\\s]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet();
    task.tags = {...task.tags, ..._selectedTags, ...manualTags}.toList(growable: false);
    return task;
  }

  Future<String?> _addFollowUpEntry() async {
    final followUp = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(
        builder: (_) => FollowUpEntryPage(initialDateTime: _now()),
      ),
    );
    if (!mounted || followUp == null) return null;
    setState(() {
      _pendingFollowUps.add(followUp);
    });
    return followUp.note;
  }

  Future<String?> _addChecklistItem() async {
    var enteredItem = '';
    final item = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مورد چک‌لیست'),
        content: TextField(
          key: const ValueKey('quick-capture-checklist-item-input'),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (value) => enteredItem = value,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
          decoration: const InputDecoration(
            hintText: 'مثلاً تماس با فروشنده',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('لغو'),
          ),
          FilledButton(
            key: const ValueKey('quick-capture-checklist-item-save'),
            onPressed: () => Navigator.of(dialogContext).pop(enteredItem.trim()),
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
    final normalized = item?.trim();
    if (!mounted || normalized == null || normalized.isEmpty) return null;
    setState(() {
      _checklistItems.add('[ ] $normalized');
      _checklistEnabled = true;
    });
    return normalized;
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
      _descriptionController.clear();
      setState(() => _saving = false);
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
      setState(() => _saving = false);
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

  Widget _buildContent(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, bottomInset + 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ArvinColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ثبت سریع کار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ArvinColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('quick-capture-input'),
                controller: _controller,
                focusNode: _titleFocus,
                autofocus: true,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'عنوان',
                  hintText: 'عنوان کار را وارد کنید',
                  helperText: 'عنوان برای ثبت کافی است',
                  errorText: _error,
                  filled: true,
                  fillColor: ArvinColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ArvinColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (widget.onCaptured == null)
                TextField(
                  key: const ValueKey('quick-capture-description'),
                controller: _descriptionController,
                enabled: !_saving,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'توضیحات (اختیاری)',
                  filled: true,
                  fillColor: ArvinColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              if (widget.onCaptured == null) const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: ArvinRollBox<String>(
                    label: 'پروژه',
                    valueLabel: _projectId == null                        ? 'پروژه'
                        : _knownProjects
                                .where((project) => project.id == _projectId)
                                .map((project) => project.title)
                                .isEmpty
                            ? 'پروژه'
                            : _knownProjects
                                .where((project) => project.id == _projectId)
                                .map((project) => project.title)
                                .first,
                    icon: Icons.folder_outlined,
                    color: ArvinColors.project,
                    emptyLabel: 'بدون پروژه',
                    createLabel: 'ایجاد جدید',
                    items: _knownProjects
                        .where((project) =>
                            !project.isArchived || project.id == _projectId)
                        .map(
                          (project) => ArvinRollItem<String>(
                            value: project.id,
                            label: project.isArchived
                                ? '${project.title} (بایگانی‌شده)'
                                : project.title,
                            icon: Icons.folder_outlined,
                            color: project.isArchived
                                ? ArvinColors.textSecondary
                                : ArvinColors.project,
                          ),
                        )
                        .toList(),
                    onSelected: (value) => setState(() {
                      _projectId = value;
                    }),
                    onCreate: () async {
                      var draftName = '';
                      final value = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            16 + MediaQuery.viewInsetsOf(ctx).bottom,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('پروژه جدید'),
                                TextField(
                                  autofocus: false,
                                  onChanged: (text) => draftName = text,
                                  decoration: const InputDecoration(labelText: 'نام پروژه'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, draftName.trim()),
                                  child: const Text('افزودن'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      if (value == null || value.isEmpty) return null;
                      final createProject = widget.onCreateProject;
                      final createdId = createProject != null
                          ? await createProject(value)
                          : await TaskProjectAssignmentService()
                              .createProject(title: value)
                              .then((project) => project.id);
                      if (!mounted || createdId == null) return createdId;
                      final existing = _knownProjects
                          .where((project) => project.id == createdId)
                          .toList(growable: false);
                      if (existing.isEmpty) {
                        final refreshed =
                            await TaskProjectAssignmentService().loadProjects();
                        _knownProjects = List<ProjectPlan>.of(refreshed);
                      }
                      setState(() => _projectId = createdId);
                      return createdId;
                    },
                  ),),
                      const SizedBox(width: 8),
                      Expanded(child: ArvinRollBox<String>(
                    label: 'دسته',
                    valueLabel: _categoryController.text.trim().isEmpty ? 'دسته' : _categoryController.text.trim(),
                    icon: Icons.grid_view_rounded,
                    color: ArvinColors.tag,
                    emptyLabel: 'بدون دسته',
                    items: _knownCategories.map((v) => v.trim()).where((v) => v.isNotEmpty).map((v) => ArvinRollItem<String>(
                      value: v, label: v, icon: Icons.grid_view_rounded, color: ArvinColors.tag,
                    )).toList(),
                    onSelected: (v) => setState(() => _categoryController.text = v ?? ''),
                    onCreate: () async {
                      final controller = TextEditingController();
                      final value = await showModalBottomSheet<String>(
                        context: context, isScrollControlled: true,
                        builder: (ctx) => Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('دسته جدید'),
                            TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'نام')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('افزودن')),
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
                  ),),
                      const SizedBox(width: 8),
                      Expanded(child: ArvinTagRollBox(
                    tags: _knownTags,
                    selectedTags: _selectedTags,
                    onChanged: (values) => setState(() {
                      _selectedTags
                        ..clear()
                        ..addAll(values);
                      _tagsController.text = _selectedTags.join('، ');
                    }),
                    onCreate: () async {
                      final controller = TextEditingController();
                      final value = await showModalBottomSheet<String>(
                        context: context, isScrollControlled: true,
                        builder: (ctx) => Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('برچسب جدید'),
                            TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'نام')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('افزودن')),
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
                        _tagsController.text = _selectedTags.join('، ');
                      });
                      return created;
                    },
                  ),),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ArvinRollBox<Object?>(
                          key: const ValueKey('quick-capture-due-rollbox'),
                          label: 'موعد',
                          valueLabel: _dueDate == null ? 'موعد' : _dateLabel(_dueDate),
                          icon: Icons.calendar_today_outlined,
                          color: ArvinColors.time,
                          emptyLabel: 'بدون موعد',
                          items: [
                            ArvinRollItem<Object?>(value: _now(), label: 'امروز', icon: Icons.today_outlined, color: ArvinColors.time),
                            ArvinRollItem<Object?>(value: _now().add(const Duration(days: 1)), label: 'فردا', icon: Icons.event_outlined, color: ArvinColors.project),
                            ArvinRollItem<Object?>(value: _now().add(const Duration(days: 7)), label: 'هفته آینده', icon: Icons.date_range_outlined, color: ArvinColors.tag),
                          ],
                          createLabel: 'تاریخ و ساعت سفارشی',
                          onCreate: _saving ? null : _pickCustomDue,
                          onSelected: (value) {
                            if (value is DateTime) {
                              _setDueDate(value);
                            } else {
                              _setDueDate(null);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ArvinRollBox<RecurrenceRule?>(
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ArvinRollBox<Object?>(
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      FilterChip(
                        key: const ValueKey('quick-capture-checklist-enabled'),
                        selected: _checklistEnabled,
                        avatar: const Icon(Icons.checklist_outlined, size: 18),
                        label: const Text('دارای چک‌لیست'),
                        onSelected: _saving
                            ? null
                            : (value) => setState(() => _checklistEnabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ArvinRollBox<String>(
                      key: const ValueKey('quick-capture-follow-up-rollbox'),
                      label: 'پیگیری',
                      valueLabel: _pendingFollowUps.isEmpty
                          ? 'افزودن پیگیری'
                          : '${_pendingFollowUps.length} پیگیری ثبت‌شده',
                      icon: Icons.follow_the_signs_outlined,
                      color: ArvinColors.tag,
                      emptyLabel: 'هنوز پیگیری ثبت نشده',
                      items: _pendingFollowUps
                          .map((followUp) {
                            final label = followUp.note.trim().isEmpty
                                ? 'پیگیری'
                                : followUp.note.trim();
                            return ArvinRollItem<String>(
                              value: label,
                              label: label,
                              icon: Icons.follow_the_signs_outlined,
                            );
                          })
                          .toList(growable: false),
                      createLabel: 'ثبت جزئیات پیگیری',
                      onCreate: _saving ? null : _addFollowUpEntry,
                      onSelected: (_) {},
                  ),
                  if (_checklistEnabled) ...[
                    const SizedBox(height: 8),
                    ArvinRollBox<String>(
                      key: const ValueKey('quick-capture-checklist-rollbox'),
                      label: 'چک‌لیست',
                      valueLabel: _checklistItems.isEmpty
                          ? 'افزودن مورد'
                          : '${_checklistItems.length} مورد',
                      icon: Icons.checklist_outlined,
                      color: ArvinColors.time,
                      emptyLabel: 'چک‌لیست خالی',
                      items: _checklistItems
                          .map((item) => ArvinRollItem<String>(
                                value: item,
                                label: item,
                                icon: Icons.check_box_outline_blank,
                              ))
                          .toList(growable: false),
                      createLabel: 'افزودن مورد چک‌لیست',
                      onCreate: _saving ? null : _addChecklistItem,
                      onSelected: (_) {},
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      key: const ValueKey('quick-capture-cancel'),
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('لغو'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('quick-capture-full-form'),
                      onPressed: _saving ? null : _openFullForm,
                      child: const Text('فرم کامل'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('quick-capture-submit'),
                      onPressed: _saving ? null : _submit,
                      child: Text(_saving ? 'در حال ثبت…' : 'ثبت کار'),
                    ),
                  ),                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}