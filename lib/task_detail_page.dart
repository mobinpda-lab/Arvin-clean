import 'package:flutter/material.dart';

import 'arvin_colors.dart';
import 'core/theme/arvin_theme.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'models/person_reference.dart';
import 'models/arvin_center.dart';
import 'services/task_store.dart';
import 'follow_up_repository.dart';
import 'models/task.dart';
import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'services/follow_up_elapsed_formatter.dart';
import 'services/follow_up_write_coordinator.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_template_store.dart';
import 'services/task_move_to_today_service.dart';
import 'services/waiting_for_response_service.dart';
import 'task_report_page.dart';
import 'widgets/persian_date_picker.dart';
import 'widgets/universal_arvin_time_picker.dart';
import 'widgets/reusable_multi_select_filter_bottom_sheet.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({
    super.key,
    required this.task,
    this.projectTitle,
    this.project,
    this.centerName,
    this.onEdit,
    this.onClone,
    this.onDelete,
    this.onTaskChanged,
    this.onAddFollowUp,
    this.onEditFollowUp,
    this.onComplete,
    this.onChecklistChanged,
    this.onDescriptionChanged,
    this.onMoveDueDateToToday,
    this.onRegisterTaskToDeviceCalendar,
    this.taskTemplateStore,
    this.now,
    this.people = const <PersonReference>[],
    this.onCreatePerson,
    this.categoryOptions = const <String>[],
    this.tagOptions = const <String>[],
    this.onCreateCategory,
    this.onCreateTag,
    this.centers = const <ArvinCenter>[],
    this.projects = const <ProjectPlan>[],
    this.selectedProjectId,
    this.onCreateCenter,
    this.onCreateProject,
    this.onProjectChanged,
  });

  final Task task;
  final String? projectTitle;
  final ProjectPlan? project;
  final String? centerName;
  final Future<Task?> Function(Task task)? onEdit;
  final Future<Task?> Function(Task task)? onClone;
  final Future<void> Function(Task task)? onDelete;
  final Future<Task?> Function(Task task)? onTaskChanged;
  final Future<Task> Function(Task task, FollowUp followUp)? onAddFollowUp;
  final Future<FollowUp> Function(Task task, FollowUp followUp)? onEditFollowUp;
  final Future<Task?> Function(Task task)? onComplete;
  final Future<Task?> Function(Task task, List<String> checklist)? onChecklistChanged;
  final Future<Task?> Function(Task task, String description)? onDescriptionChanged;
  final Future<Task?> Function(Task task)? onMoveDueDateToToday;
  final Future<void> Function(Task task)? onRegisterTaskToDeviceCalendar;
  final TaskTemplateStore? taskTemplateStore;
  final DateTime? now;
  final List<PersonReference> people;
  final Future<void> Function(PersonReference person)? onCreatePerson;
  final List<String> categoryOptions;
  final List<String> tagOptions;
  final Future<String?> Function(String name)? onCreateCategory;
  final Future<String?> Function(String name)? onCreateTag;
  final List<ArvinCenter> centers;
  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final Future<String?> Function(String name)? onCreateCenter;
  final Future<String?> Function(String title, String? centerId)? onCreateProject;
  final Future<void> Function(String? projectId)? onProjectChanged;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  Color get _brand => Theme.of(context).colorScheme.primary;
  static const _waiting = ArvinColors.reminder;
  static const _muted = ArvinColors.neutral;
  static const _formatter = PersianDateFormatter();
  static const _elapsedFormatter = FollowUpElapsedFormatter();
  static const _waitingService = WaitingForResponseService();

  late Task _task;
  late List<ArvinCenter> _centers;
  late List<ProjectPlan> _projects;
  String? _selectedCenterId;
  String? _selectedProjectId;

  TaskTemplateStore get _taskTemplates =>
      widget.taskTemplateStore ?? TaskTemplateStore();
  TextEditingController? _descriptionController;
  TextEditingController? _titleController;
  TextEditingController? _categoryController;
  TextEditingController? _tagsController;
  bool _isInlineEditing = false;
  bool _isSavingInlineEdit = false;
  bool _draftCompleted = false;
  TaskPriority _draftPriority = TaskPriority.medium;
  bool _isSavingTaskTemplate = false;
  bool _recurrenceConfigured = false;
  bool _recurrenceActive = true;
  DateTime? _draftRecurrenceEndDate;
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.daily;
  RecurrenceTrackingLevel _recurrenceTrackingLevel = RecurrenceTrackingLevel.normal;
  TextEditingController? _recurrenceIntervalController;
  TextEditingController? _recurrenceCountController;
  bool _isMovingDueDateToToday = false;
  final TextEditingController _checklistAddController = TextEditingController();
  final ScrollController _detailScrollController = ScrollController();
  TextEditingController? _checklistEditController;
  int? _editingChecklistIndex;
  bool _isSavingChecklist = false;
  bool _isAddingChecklist = false;
  List<TaskReminder> _draftReminders = const [];
  List<String> _draftChecklist = const [];
  DateTime? _draftDueDate;
  bool _draftAllDay = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _centers = List<ArvinCenter>.of(widget.centers);
    _projects = List<ProjectPlan>.of(widget.projects);
    _selectedCenterId = widget.task.centerId ?? widget.project?.centerId;
    _selectedProjectId = widget.selectedProjectId ?? widget.project?.id;
  }

  @override
  void didUpdateWidget(covariant TaskDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _task = widget.task;
      _selectedCenterId = widget.task.centerId ?? widget.project?.centerId;
      _selectedProjectId = widget.selectedProjectId ?? widget.project?.id;
    }
    _centers = List<ArvinCenter>.of(widget.centers);
    _projects = List<ProjectPlan>.of(widget.projects);
  }

  String get _selectedCenterName {
    if (_selectedCenterId == null) return 'بدون مرکز';
    final center = _centers.where((item) => item.id == _selectedCenterId);
    return center.isNotEmpty ? center.first.name : widget.centerName ?? 'مرکز انتخاب‌شده';
  }

  String get _selectedProjectTitle {
    if (_selectedProjectId == null) return 'بدون پروژه';
    final project = _projects.where((item) => item.id == _selectedProjectId);
    return project.isNotEmpty
        ? project.first.title
        : widget.projectTitle ?? widget.project?.title ?? 'پروژه انتخاب‌شده';
  }

  void _beginInlineEdit() {
    _titleController?.dispose();
    _descriptionController?.dispose();
    _titleController = TextEditingController(text: _task.title);
    _descriptionController = TextEditingController(text: _task.description);
    _categoryController = TextEditingController(text: _task.category ?? '');
    _tagsController = TextEditingController(text: _task.tags.join('، '));
    _selectedCenterId = _task.centerId ?? widget.project?.centerId;
    _selectedProjectId = widget.selectedProjectId ?? widget.project?.id;
    _draftReminders = List<TaskReminder>.of(_task.taskReminders);
    _draftChecklist = List<String>.of(_normalizedChecklist());
    _isAddingChecklist = _task.checklist.isEmpty;
    _draftDueDate = _task.dueDate;
    _draftAllDay = _task.allDay;
    _draftCompleted = _task.completed;
    _draftPriority = _task.priority;
    final rule = _task.recurrence;
    _recurrenceConfigured = rule != null;
    _recurrenceActive = rule?.active ?? true;
    _draftRecurrenceEndDate = rule?.endDate;
    _recurrenceFrequency = rule?.frequency ?? RecurrenceFrequency.daily;
    _recurrenceTrackingLevel = rule?.trackingLevel ?? RecurrenceTrackingLevel.normal;
    _recurrenceIntervalController = TextEditingController(text: (rule?.interval ?? 1).toString());
    _recurrenceCountController = TextEditingController(text: rule?.count?.toString() ?? '');
    setState(() => _isInlineEditing = true);
  }

  void _cancelInlineEdit() {
    _titleController?.dispose();
    _descriptionController?.dispose();
    _categoryController?.dispose();
    _tagsController?.dispose();
    _recurrenceIntervalController?.dispose();
    _recurrenceCountController?.dispose();
    _checklistEditController?.dispose();
    _checklistEditController = null;
    _titleController = null;
    _descriptionController = null;
    _categoryController = null;
    _tagsController = null;
    _recurrenceIntervalController = null;
    _recurrenceCountController = null;
    _draftRecurrenceEndDate = null;
    _draftReminders = const [];
    _draftChecklist = const [];
    _isAddingChecklist = false;
    _editingChecklistIndex = null;
    _draftDueDate = null;
    _draftAllDay = false;
    _draftCompleted = false;
    _selectedCenterId = _task.centerId ?? widget.project?.centerId;
    _selectedProjectId = widget.selectedProjectId ?? widget.project?.id;
    _draftPriority = TaskPriority.medium;
    setState(() => _isInlineEditing = false);
  }

  Future<void> _saveInlineEdit() async {
    final save = widget.onTaskChanged;
    final title = _titleController?.text.trim();
    final description = _descriptionController?.text ?? '';
    if (save == null || title == null || _isSavingInlineEdit) return;
    final category = _categoryController?.text.trim() ?? '';
    final tags = (_tagsController?.text ?? '')
        .split(RegExp(r'[,،]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final recurrenceInterval = int.tryParse(_recurrenceIntervalController?.text.trim() ?? '1') ?? 0;
    final rawCount = _recurrenceCountController?.text.trim() ?? '';
    final recurrenceCount = rawCount.isEmpty ? null : int.tryParse(rawCount);
    final recurrenceAnchor = _task.recurrence?.startDate ?? _draftDueDate;
    if (_recurrenceConfigured &&
        _draftRecurrenceEndDate != null &&
        recurrenceAnchor != null &&
        _draftRecurrenceEndDate!.isBefore(recurrenceAnchor)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تاریخ پایان تکرار نمی‌تواند قبل از مبدأ تکرار باشد.')),
      );
      return;
    }
    if (_recurrenceConfigured &&
        (recurrenceInterval < 1 || (rawCount.isNotEmpty && (recurrenceCount == null || recurrenceCount < 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فاصله تکرار و شمارش باید عدد مثبت باشند.')),
      );
      return;
    }
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..title = title.isEmpty ? 'بدون عنوان' : title
      ..description = description
      ..priority = _draftPriority
      ..category = category.isEmpty ? null : category
      ..tags = tags
      ..centerId = _selectedCenterId
      ..taskReminders = List<TaskReminder>.of(_draftReminders)
      ..checklist = List<String>.of(_draftChecklist)
      ..checklistEnabled = _task.checklistEnabled || _draftChecklist.isNotEmpty
      ..dueDate = _draftDueDate
      ..allDay = _draftAllDay
      ..nextReminderSequence = _draftReminders.isEmpty
          ? _task.nextReminderSequence
          : (_draftReminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b) + 1).clamp(_task.nextReminderSequence, 1 << 30).toInt()
      ..recurrence = _recurrenceConfigured ? RecurrenceRule(
        frequency: _recurrenceFrequency,
        interval: recurrenceInterval,
        startDate: _task.recurrence?.startDate,
        endDate: _draftRecurrenceEndDate,
        count: recurrenceCount,
        active: _recurrenceActive,
        trackingLevel: _recurrenceTrackingLevel,
      ) : _task.recurrence
      ..updatedAt = DateTime.now();
    if (_draftCompleted != _task.completed) candidate.setCompleted(_draftCompleted);
    setState(() => _isSavingInlineEdit = true);
    try {
      final updated = await save(candidate);
      if (!mounted) return;
      if (updated == null) throw StateError('Inline Task edit was not persisted.');
      try {
        await widget.onProjectChanged?.call(_selectedProjectId);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('کار ذخیره شد؛ اتصال پروژه نیازمند تلاش دوباره است.')),
          );
        }
      }
      _titleController?.dispose();
      _descriptionController?.dispose();
      _categoryController?.dispose();
      _tagsController?.dispose();
      _recurrenceIntervalController?.dispose();
      _recurrenceCountController?.dispose();
      _checklistEditController?.dispose();
      _checklistEditController = null;
      _titleController = null;
      _descriptionController = null;
      _categoryController = null;
      _tagsController = null;
      _recurrenceIntervalController = null;
      _recurrenceCountController = null;
      _draftRecurrenceEndDate = null;
      _draftReminders = const [];
      _draftChecklist = const [];
      _isAddingChecklist = false;
      _editingChecklistIndex = null;
      _draftDueDate = null;
      _draftAllDay = false;
      setState(() {
        _task = updated;
        _isInlineEditing = false;
        _isSavingInlineEdit = false;
      });
      try {
        await AndroidFollowUpReminderScheduler().reschedule();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تغییرات ذخیره شد؛ زمان‌بندی اعلان در اجرای بعدی بازآزمایی می‌شود')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSavingInlineEdit = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ذخیره تغییرات کار انجام نشد؛ دوباره تلاش کنید')),
      );
    }
  }

  Future<void> _persistCandidate(Task candidate) async {
    final save = widget.onTaskChanged;
    if (save == null) return;
    candidate.updatedAt = DateTime.now();
    final updated = await save(candidate);
    if (!mounted || updated == null) return;
    setState(() => _task = updated);
  }

  Future<void> _changePriority(TaskPriority priority) async {
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..priority = priority;
    await _persistCandidate(candidate);
  }

  Future<void> _addInlineReminder() async {
    var titleValue = 'یادآور ${_draftReminders.length + 1}';
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('یادآور جدید'),
        content: TextFormField(
          key: const ValueKey('task-detail-reminder-title-input'),
          initialValue: titleValue,
          onChanged: (value) => titleValue = value,
          decoration: const InputDecoration(labelText: 'عنوان یادآور'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          FilledButton(
            onPressed: () {
              final value = titleValue.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('ادامه'),
          ),
        ],
      ),
    );
    if (title == null || !mounted) return;

    final initial = _task.dueDate ?? DateTime.now().add(const Duration(hours: 1));
    final date = await showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ یادآور',
    );
    if (date == null || !mounted) return;
    final selection = await showUniversalArvinTimeSelectionPicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: 'زمان یادآور',
    );
    if (selection == null || !mounted) return;

    final highest = _draftReminders.isEmpty
        ? _task.nextReminderSequence - 1
        : _draftReminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b);
    final reminder = TaskReminder(
      id: 'reminder-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      date: selection.isAllDay
          ? DateTime(date.year, date.month, date.day)
          : DateTime(date.year, date.month, date.day, selection.time!.hour, selection.time!.minute),
      isAllDay: selection.isAllDay,
      sequence: (highest + 1).clamp(_task.nextReminderSequence, 1 << 30).toInt(),
    );
    setState(() => _draftReminders = [..._draftReminders, reminder]);
  }

  void _toggleDraftReminder(TaskReminder reminder, bool enabled) {
    setState(() {
      _draftReminders = _draftReminders
          .map((item) => item.id == reminder.id
              ? item.copyWith(isEnabled: enabled)
              : item)
          .toList(growable: false);
    });
  }

  Future<void> _editDraftReminderTitle(TaskReminder reminder) async {
    var titleValue = reminder.title;
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ویرایش عنوان یادآور'),
        content: TextFormField(
          key: ValueKey('task-detail-reminder-edit-title-input-${reminder.id}'),
          initialValue: titleValue,
          onChanged: (value) => titleValue = value,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'عنوان یادآور'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          FilledButton(
            onPressed: () {
              final value = titleValue.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('ذخیره عنوان'),
          ),
        ],
      ),
    );
    if (title == null || !mounted) return;
    setState(() {
      _draftReminders = _draftReminders
          .map((item) => item.id == reminder.id ? item.copyWith(title: title) : item)
          .toList(growable: false);
    });
  }

  Future<void> _editDraftReminderSchedule(TaskReminder reminder) async {
    final date = await showPersianDatePicker(
      context: context,
      initialDate: reminder.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'تغییر تاریخ یادآور',
    );
    if (date == null || !mounted) return;
    final selection = await showUniversalArvinTimeSelectionPicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(reminder.date),
      helpText: 'زمان یادآور',
    );
    if (selection == null || !mounted) return;
    final updatedDate = selection.isAllDay
        ? DateTime(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day, selection.time!.hour, selection.time!.minute);
    setState(() {
      _draftReminders = _draftReminders
          .map((item) => item.id == reminder.id
              ? item.copyWith(date: updatedDate, isAllDay: selection.isAllDay)
              : item)
          .toList(growable: false);
    });
  }

  void _removeDraftReminder(TaskReminder reminder) {
    setState(() {
      _draftReminders = _draftReminders
          .where((item) => item.id != reminder.id)
          .toList(growable: false);
    });
  }

  Future<void> _toggleReminder(TaskReminder reminder, bool enabled) async {
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()));
    candidate.taskReminders = candidate.taskReminders
        .map((item) => item.id == reminder.id ? item.copyWith(isEnabled: enabled) : item)
        .toList(growable: false);
    await _persistCandidate(candidate);
    try {
      await AndroidFollowUpReminderScheduler().reschedule();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('یادآور ذخیره شد؛ زمان‌بندی اعلان در اجرای بعدی بازآزمایی می‌شود')),
      );
    }
  }

  Future<void> _openInlineCenterSelector() async {
    final options = _centers
        .map((center) => ReusableFilterOption<String>(
              value: center.id,
              label: center.name,
              icon: Icons.business_outlined,
            ))
        .toList(growable: false);
    final result = await ReusableMultiSelectFilterBottomSheet.showSingleSelect<String>(
      context,
      title: 'انتخاب مرکز',
      accent: ArvinColors.primary,
      options: options,
      selectedValue: _selectedCenterId,
      emptyLabel: 'بدون مرکز',
      createHint: 'نام مرکز جدید',
      createLabel: 'افزودن مرکز',
      onCreate: widget.onCreateCenter == null ? null : (name) async {
        final id = await widget.onCreateCenter!(name);
        if (id == null || id.trim().isEmpty) return null;
        if (mounted && !_centers.any((center) => center.id == id)) {
          setState(() {
            _centers = [
              ..._centers,
              ArvinCenter(id: id, name: name, createdAt: DateTime.now()),
            ];
          });
        }
        return ReusableFilterOption<String>(
          value: id,
          label: name,
          icon: Icons.business_outlined,
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedCenterId = result.cleared ? null : result.value;
      final selectedProject = _projects.where((project) => project.id == _selectedProjectId);
      if (result.cleared ||
          (selectedProject.isNotEmpty &&
              _selectedCenterId != null &&
              selectedProject.first.centerId != _selectedCenterId)) {
        _selectedProjectId = null;
      }
    });
  }

  Future<void> _openInlineProjectSelector() async {
    final options = _projects
        .where((project) =>
            (!project.isArchived || project.id == _selectedProjectId) &&
            (_selectedCenterId == null ||
                project.centerId == _selectedCenterId))
        .map((project) => ReusableFilterOption<String>(
              value: project.id,
              label: project.isArchived
                  ? '${project.title} (بایگانی‌شده)'
                  : project.title,
              icon: Icons.folder_outlined,
            ))
        .toList(growable: false);
    final result = await ReusableMultiSelectFilterBottomSheet.showSingleSelect<String>(
      context,
      title: 'انتخاب پروژه',
      accent: ArvinColors.project,
      options: options,
      selectedValue: _selectedProjectId,
      emptyLabel: 'بدون پروژه',
      createHint: 'نام پروژه جدید',
      createLabel: 'افزودن پروژه',
      onCreate: widget.onCreateProject == null ? null : (title) async {
        final id = await widget.onCreateProject!(title, _selectedCenterId);
        if (id == null || id.trim().isEmpty) return null;
        if (mounted && !_projects.any((project) => project.id == id)) {
          setState(() {
            _projects = [
              ..._projects,
              ProjectPlan(id: id, title: title, centerId: _selectedCenterId),
            ];
          });
        }
        return ReusableFilterOption<String>(
          value: id,
          label: title,
          icon: Icons.folder_outlined,
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedProjectId = result.cleared ? null : result.value;
      final selectedProject = _projects.where((project) => project.id == _selectedProjectId);
      if (selectedProject.isNotEmpty) {
        _selectedCenterId = selectedProject.first.centerId;
      }
    });
  }

  Future<void> _openInlineCategorySelector() async {
    final current = _categoryController?.text.trim() ?? '';
    final values = <String>{
      ...widget.categoryOptions.map((value) => value.trim()).where((value) => value.isNotEmpty),
      if (current.isNotEmpty) current,
    }.toList()
      ..sort();
    final result = await ReusableMultiSelectFilterBottomSheet.showSingleSelect<String>(
      context,
      title: 'انتخاب دسته',
      accent: ArvinColors.category,
      options: values
          .map((value) => ReusableFilterOption<String>(
                value: value,
                label: value,
                icon: Icons.layers_outlined,
              ))
          .toList(growable: false),
      selectedValue: current.isEmpty ? null : current,
      emptyLabel: 'بدون دسته',
      createHint: 'نام دسته جدید',
      createLabel: 'افزودن دسته',
      onCreate: (name) async {
        final created = await widget.onCreateCategory?.call(name) ?? name;
        if (created.trim().isEmpty) return null;
        return ReusableFilterOption<String>(
          value: created,
          label: created,
          icon: Icons.layers_outlined,
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _categoryController?.text = result.cleared ? '' : result.value ?? '';
    });
  }

  Future<void> _openInlineTagSelector() async {
    final current = (_tagsController?.text ?? '')
        .split('،')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final values = <String>{
      ...widget.tagOptions.map((value) => value.trim()).where((value) => value.isNotEmpty),
      ...current,
    }.toList()
      ..sort();
    final result = await ReusableMultiSelectFilterBottomSheet.showMultiSelect<String>(
      context,
      title: 'انتخاب برچسب‌ها',
      accent: ArvinColors.tag,
      options: values
          .map((value) => ReusableFilterOption<String>(
                value: value,
                label: value,
                icon: Icons.sell_outlined,
              ))
          .toList(growable: false),
      selectedValues: current,
      searchHint: 'جستجو در برچسب‌ها...',
      createHint: 'نام برچسب جدید',
      createLabel: 'افزودن برچسب',
      onCreate: (name) async {
        final created = await widget.onCreateTag?.call(name) ?? name;
        if (created.trim().isEmpty) return null;
        return ReusableFilterOption<String>(
          value: created,
          label: created,
          icon: Icons.sell_outlined,
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _tagsController?.text = (result.toList()..sort()).join('، ');
    });
  }

  Future<void> _pickInlineWorkTime() async {
    final current = _draftDueDate ?? DateTime.now();
    final pickedDate = await showPersianDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب زمان کار / موعد',
    );
    if (pickedDate == null || !mounted) return;

    // The date picker is deliberately followed by the round clock. Nothing is
    // committed until the user confirms a timed or explicit no-time choice.
    final selection = await showUniversalArvinTimeSelectionPicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'زمان انجام کار',
    );
    if (selection == null || !mounted) return;

    setState(() {
      _draftDueDate = selection.isAllDay
          ? DateTime(pickedDate.year, pickedDate.month, pickedDate.day)
          : DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              selection.time!.hour,
              selection.time!.minute,
            );
      _draftAllDay = selection.isAllDay;
    });
  }

  Future<void> _toggleRecurrence(bool active) async {
    final rule = _task.recurrence;
    if (rule == null) return;
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..recurrence = RecurrenceRule(
        frequency: rule.frequency,
        interval: rule.interval,
        startDate: rule.startDate,
        endDate: rule.endDate,
        count: rule.count,
        active: active,
        trackingLevel: rule.trackingLevel,
      );
    await _persistCandidate(candidate);
  }

  Future<void> _convertToTemplate() async {
    var templateName = _task.title;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تبدیل کار به الگو'),
        content: TextFormField(
          key: const ValueKey('task-detail-template-name'),
          initialValue: templateName,
          autofocus: true,
          onChanged: (value) => templateName = value,
          decoration: const InputDecoration(labelText: 'نام الگو'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          FilledButton(
            key: const ValueKey('task-detail-template-confirm'),
            onPressed: () {
              final value = templateName.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('تأیید و ذخیره'),
          ),
        ],
      ),
    );
    if (name == null || !mounted || _isSavingTaskTemplate) return;
    setState(() => _isSavingTaskTemplate = true);
    try {
      await _taskTemplates.createFromTask(
        task: _task,
        name: name,
        centerNameSnapshot: widget.centerName,
        projectNameSnapshot: widget.project?.title ?? widget.projectTitle,
        centerIdSnapshot: widget.project?.centerId,
        projectIdSnapshot: widget.project?.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('الگوی کار ذخیره شد؛ کار اصلی و سابقه آن تغییر نکرد.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('تبدیل کار به الگو انجام نشد: $error')));
    } finally {
      if (mounted) setState(() => _isSavingTaskTemplate = false);
    }
  }

  Future<void> _cloneTask() async {
    final clone = widget.onClone;
    if (clone == null) return;
    final created = await clone(_task);
    if (!mounted || created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('یک کپی مستقل از کار ایجاد شد')),
    );
  }

  Future<void> _deleteTask() async {
    final remove = widget.onDelete;
    if (remove == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('انتقال کار به سطل زباله'),
        content: const Text('این کار به سطل زباله منتقل شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('انتقال')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await remove(_task);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _complete() async {
    final complete = widget.onComplete;
    if (complete == null) return;
    final updated = await complete(_task);
    if (!mounted || updated == null) return;
    setState(() => _task = updated);
  }

  String _date(DateTime value) => _formatter.format(value, usePersianDate: true);

  String _time(DateTime value) => _formatter.toPersianDigits(
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      );

  String _dateTime(DateTime value) => '${_date(value)} • ${_time(value)}';

  String? _resultLabel(FollowUp followUp) {
    if (_waitingService.isWaitingResult(followUp.result)) return 'منتظر پاسخ';
    final value = followUp.result?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    _descriptionController?.dispose();
    _titleController?.dispose();
    _categoryController?.dispose();
    _tagsController?.dispose();
    _checklistAddController.dispose();
    _recurrenceIntervalController?.dispose();
    _recurrenceCountController?.dispose();
    _detailScrollController.dispose();
    _checklistEditController?.dispose();
    super.dispose();
  }

  Future<void> _moveDueDateToToday() async {
    final move = widget.onMoveDueDateToToday;
    if (_isMovingDueDateToToday) return;
    setState(() => _isMovingDueDateToToday = true);
    try {
      final Task updated;
      if (move != null) {
        final result = await move(_task);
        if (result == null) {
          throw StateError('Task due-date update was not persisted.');
        }
        updated = result;
      } else {
        updated = await TaskMoveToTodayService().move(_task.id);
      }
      if (!mounted) return;
      setState(() {
        _task = updated;
        _isMovingDueDateToToday = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('موعد انجام کار برای امروز تنظیم شد')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isMovingDueDateToToday = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تنظیم موعد برای امروز انجام نشد؛ دوباره تلاش کنید')));
    }
  }

  Future<void> _sendToDeviceCalendar() async {
    final callback = widget.onRegisterTaskToDeviceCalendar;
    if (callback == null) return;
    await callback(_task);
  }

  Future<void> _openReport() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => TaskReportPage(tasks: [_task])),
    );
  }

  Future<FollowUp?> _openFollowUpEntry({FollowUp? initialFollowUp}) async {
    final store = TaskStore();
    final peopleById = <String, PersonReference>{
      for (final person in widget.people) person.id: person,
      for (final person in _task.people) person.id: person,
    };
    for (final id in initialFollowUp?.personIds ?? const <String>[]) {
      peopleById.putIfAbsent(
        id,
        () => PersonReference(id: id, displayName: 'شخص حذف‌شده'),
      );
    }
    if (!mounted) return null;
    return Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(
        builder: (_) => FollowUpEntryPage(
          taskId: _task.id,
          initialFollowUp: initialFollowUp,
          people: peopleById.values.toList(growable: false),
          onCreatePerson: widget.onCreatePerson ??
              (person) => store.mergePeopleDirectory([person]),
        ),
      ),
    );
  }

  Future<void> _addFollowUp() async {
    final add = widget.onAddFollowUp;
    if (add == null) return;
    final followUp = await _openFollowUpEntry();
    if (!mounted || followUp == null) return;
    final updated = await add(_task, followUp);
    if (mounted) setState(() => _task = updated);
  }

  Future<void> _editFollowUp(FollowUp existing) async {
    final updated = await _openFollowUpEntry(initialFollowUp: existing);
    if (!mounted || updated == null) return;

    try {
      final handler = widget.onEditFollowUp;
      final persisted = handler != null
          ? await handler(_task, updated)
          : await _persistFollowUpUpdate(updated);
      if (!mounted) return;
      final index = _task.followUps.indexWhere((item) => item.id == persisted.id);
      if (index < 0) return;
      setState(() {
        final history = List<FollowUp>.of(_task.followUps);
        history[index] = persisted;
        _task.followUps = history;
        _task.updatedAt = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('ویرایش پیگیری انجام نشد؛ دوباره تلاش کنید')));
    }
  }

  Future<FollowUp> _persistFollowUpUpdate(FollowUp updated) async {
    final writer = FollowUpWriteCoordinator(
      repository: const FollowUpRepository(),
      reminderReschedule: AndroidFollowUpReminderScheduler().reschedule,
    );
    await writer.update(_task.id, updated);
    return updated;
  }

  Widget _badge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ArvinColors.surface,
        borderRadius: ArvinTheme.cardBorderRadius,
        border: Border.all(color: ArvinColors.border),
        boxShadow: const [ArvinTheme.shadowStyle],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _brand),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _summaryCard() {
    return _card(
      key: const ValueKey('task-detail-summary-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _isInlineEditing
                    ? TextField(
                        key: const ValueKey('task-detail-inline-title'),
                        controller: _titleController,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.25),
                        decoration: const InputDecoration(labelText: 'عنوان کار', border: OutlineInputBorder()),
                      )
                    : Text(
                        _task.title,
                        key: const ValueKey('task-detail-title'),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.3),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _statusPriorityCard(),
          const SizedBox(height: 10),
          if (_isInlineEditing)
            TextField(
              key: const ValueKey('task-detail-inline-description'),
              controller: _descriptionController,
              minLines: 2,
              maxLines: null,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'توضیحات کامل', border: OutlineInputBorder()),
            )
          else
            KeyedSubtree(
              key: const ValueKey('task-detail-description-card'),
              child: Text(
                _task.description.trim().isEmpty
                    ? 'توضیحی ثبت نشده است'
                    : _task.description.trim(),
                key: const ValueKey('task-detail-description'),
                style: const TextStyle(fontFamily: 'Vazirmatn', height: 1.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dueDateCard() {
    final dueDate = _isInlineEditing ? _draftDueDate : _task.dueDate;
    final allDay = _isInlineEditing ? _draftAllDay : _task.allDay;
    return _card(
      key: const ValueKey('task-detail-due-date-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: _brand),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('زمان کار / موعد', style: TextStyle(fontFamily: 'Vazirmatn', color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      dueDate == null
                          ? 'تعیین نشده'
                          : (allDay ? _date(dueDate) : _dateTime(dueDate)),
                      key: const ValueKey('task-detail-due-date'),
                      style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (_isInlineEditing) ...[
                IconButton(
                  key: const ValueKey('task-detail-inline-work-time'),
                  tooltip: 'تغییر زمان کار / موعد',
                  onPressed: _pickInlineWorkTime,
                  icon: const Icon(Icons.edit_calendar_outlined),
                ),
                if (dueDate != null)
                  IconButton(
                    key: const ValueKey('task-detail-inline-due-clear'),
                    tooltip: 'پاک‌کردن موعد',
                    onPressed: () => setState(() {
                      _draftDueDate = null;
                      _draftAllDay = false;
                    }),
                    icon: const Icon(Icons.event_busy_outlined),
                  ),
              ] else
                IconButton(
                  key: const ValueKey('task-detail-move-due-date-to-today'),
                  tooltip: 'تنظیم موعد برای امروز',
                  onPressed: _isMovingDueDateToToday ? null : _moveDueDateToToday,
                  icon: _isMovingDueDateToToday
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.today_outlined),
                ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _assigneeCard() {
    // Task has no canonical assignee relation; related people are not assignees.
    return _card(
      key: const ValueKey('task-detail-assignee-card'),
      child: Row(children: [
        const Icon(Icons.person_outline, color: _muted),
        const SizedBox(width: 10),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مسئول', style: TextStyle(fontFamily: 'Vazirmatn', color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('مسئول مستقلی برای این کار ثبت نشده است', style: TextStyle(fontFamily: 'Vazirmatn', color: Color(0xFF232433), fontWeight: FontWeight.w700)),
          ],
        )),
      ]),
    );
  }

  List<String> _normalizedChecklist() => (_isInlineEditing ? _draftChecklist : _task.checklist).map((item) {
        final value = item.trim();
        if (value.startsWith('[x] ')) return value;
        if (value.startsWith('[ ] ')) return value;
        if (value.startsWith('[x]')) return '[x] ${value.substring(3).trim()}';
        if (value.startsWith('[ ]')) return '[ ] ${value.substring(3).trim()}';
        return '[ ] $value';
      }).toList();

  Future<void> _saveChecklist(List<String> values) async {
    if (_isSavingChecklist) return;
    if (_isInlineEditing) {
      setState(() => _draftChecklist = List<String>.of(values));
      return;
    }
    final handler = widget.onChecklistChanged;
    if (handler == null) return;

    // Checklist edits are isolated from the historical Follow-up timeline.
    final previous = _task;
    final protectedFollowUps = List<FollowUp>.of(previous.followUps);
    final candidate = Task.fromJson(Map<String, dynamic>.from(previous.toJson()))
      ..checklist = List<String>.of(values)
      ..checklistEnabled = true;

    setState(() {
      _task = candidate;
      _isSavingChecklist = true;
    });
    try {
      final updated = await handler(candidate, List<String>.of(values));
      if (!mounted) return;
      if (updated == null) {
        setState(() {
          _task = previous;
          _isSavingChecklist = false;
        });
        return;
      }
      updated.followUps = protectedFollowUps;
      setState(() {
        _task = updated;
        _isSavingChecklist = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _task = previous;
        _isSavingChecklist = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('ذخیره چک‌لیست انجام نشد؛ دوباره تلاش کنید')),
        );
    }
  }

  Future<void> _addChecklistItem() async {
    final value = _checklistAddController.text.trim();
    if (value.isEmpty || _isSavingChecklist) return;
    final next = _normalizedChecklist()..add('[ ] $value');
    await _saveChecklist(next);
    if (!mounted) return;
    _checklistAddController.clear();
    if (_normalizedChecklist().isNotEmpty && mounted) {
      setState(() => _isAddingChecklist = false);
    }
  }

  void _beginChecklistEdit(int index, String item) {
    _checklistEditController?.dispose();
    _checklistEditController = TextEditingController(text: item.substring(4));
    setState(() => _editingChecklistIndex = index);
  }

  void _cancelChecklistEdit() {
    _checklistEditController?.dispose();
    _checklistEditController = null;
    setState(() => _editingChecklistIndex = null);
  }

  Future<void> _saveChecklistEdit(int index) async {
    final controller = _checklistEditController;
    if (controller == null) return;
    final value = controller.text.trim();
    if (value.isEmpty) return;
    final current = _normalizedChecklist();
    final marker = current[index].startsWith('[x] ') ? '[x]' : '[ ]';
    current[index] = '$marker $value';
    await _saveChecklist(current);
    if (!mounted) return;
    _checklistEditController?.dispose();
    _checklistEditController = null;
    setState(() => _editingChecklistIndex = null);
  }

  Future<void> _toggleChecklistItem(int index) async {
    final next = _normalizedChecklist();
    final current = next[index];
    next[index] = current.startsWith('[x] ')
        ? '[ ] ${current.substring(4)}'
        : '[x] ${current.substring(4)}';
    await _saveChecklist(next);
  }

  Future<void> _deleteChecklistItem(int index) async {
    final next = _normalizedChecklist()..removeAt(index);
    await _saveChecklist(next);
  }

  Future<void> _moveChecklistItem(int index, int offset) async {
    final next = _normalizedChecklist();
    final target = index + offset;
    if (target < 0 || target >= next.length) return;
    final item = next.removeAt(index);
    next.insert(target, item);
    await _saveChecklist(next);
  }

  Widget _checklistCard() {
    final items = _normalizedChecklist();
    if (!_isAddingChecklist && items.isEmpty) {
      return _card(
        key: const ValueKey('task-detail-checklist'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('چک‌لیست', Icons.checklist_rounded),
            const SizedBox(height: 8),
            const Text('چک‌لیستی ثبت نشده است', style: TextStyle(color: _muted)),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('task-detail-add-checklist'),
                onPressed: widget.onTaskChanged != null
                    ? _beginInlineEdit
                    : widget.onChecklistChanged != null
                        ? () => setState(() => _isAddingChecklist = true)
                        : null,
                icon: const Icon(Icons.add, size: 17),
                label: const Text('افزودن چک‌لیست'),
              ),
            ),
          ],
        ),
      );
    }
    final completed = items.where((item) => item.startsWith('[x] ')).length;
    return _card(
      key: const ValueKey('task-detail-checklist'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle('چک‌لیست', Icons.checklist_rounded),
              const Spacer(),
              Text(
                '$completed/${items.length}',
                key: const ValueKey('task-detail-checklist-progress'),
                style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              key: const ValueKey('task-detail-checklist-progress-bar'),
              value: items.isEmpty ? 0 : completed / items.length,
              minHeight: 7,
              backgroundColor: ArvinColors.border,
              color: ArvinColors.tag,
            ),
          ),
          const SizedBox(height: 10),
          if (_isInlineEditing || _isAddingChecklist) ...[
            TextField(
              key: const ValueKey('task-detail-checklist-add-input'),
              controller: _checklistAddController,
              enabled: !_isSavingChecklist,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'عنوان مرحله جدید را بنویسید...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _addChecklistItem(),
            ),
            const SizedBox(height: 6),
          ],
          for (var index = 0; index < items.length; index++)
            if (_editingChecklistIndex == index)
              Row(
                key: ValueKey('task-detail-checklist-edit-row-$index'),
                children: [
                  Expanded(
                    child: TextField(
                      key: ValueKey('task-detail-checklist-edit-input-$index'),
                      controller: _checklistEditController,
                      enabled: !_isSavingChecklist,
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _saveChecklistEdit(index),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('task-detail-checklist-save-$index'),
                    tooltip: 'ذخیره ویرایش',
                    onPressed: _isSavingChecklist ? null : () => _saveChecklistEdit(index),
                    icon: const Icon(Icons.check),
                  ),
                  IconButton(
                    key: ValueKey('task-detail-checklist-cancel-$index'),
                    tooltip: 'انصراف',
                    onPressed: _isSavingChecklist ? null : _cancelChecklistEdit,
                    icon: const Icon(Icons.close),
                  ),
                ],
              )
            else
              Row(
                key: ValueKey('task-detail-checklist-item-$index'),
                children: [
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: CheckboxListTile(
                        value: items[index].startsWith('[x] '),
                      onChanged: _isSavingChecklist ||
                              (_isInlineEditing
                                  ? widget.onTaskChanged == null
                                  : widget.onChecklistChanged == null)
                          ? null
                          : (_) => _toggleChecklistItem(index),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                        title: Text(items[index].substring(4)),
                      ),
                    ),
                  ),
                  if (_isInlineEditing) ...[
                    IconButton(
                      key: ValueKey('task-detail-checklist-up-$index'),
                      tooltip: 'انتقال به بالا',
                      onPressed: _isSavingChecklist || index == 0 ? null : () => _moveChecklistItem(index, -1),
                      icon: const Icon(Icons.arrow_upward, size: 17),
                    ),
                    IconButton(
                      key: ValueKey('task-detail-checklist-down-$index'),
                      tooltip: 'انتقال به پایین',
                      onPressed: _isSavingChecklist || index == items.length - 1 ? null : () => _moveChecklistItem(index, 1),
                      icon: const Icon(Icons.arrow_downward, size: 17),
                    ),
                    IconButton(
                      key: ValueKey('task-detail-checklist-edit-$index'),
                      tooltip: 'ویرایش مورد',
                      onPressed: _isSavingChecklist ? null : () => _beginChecklistEdit(index, items[index]),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton(
                      key: ValueKey('task-detail-checklist-delete-$index'),
                      tooltip: 'حذف مورد',
                      onPressed: _isSavingChecklist ? null : () => _deleteChecklistItem(index),
                      icon: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ],
                ],
              ),
          const SizedBox(height: 8),
          if (_isInlineEditing || widget.onTaskChanged == null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('task-detail-checklist-add'),
                onPressed: _isSavingChecklist
                    ? null
                    : _isInlineEditing || _isAddingChecklist
                        ? _addChecklistItem
                        : widget.onChecklistChanged != null
                            ? () => setState(() => _isAddingChecklist = true)
                            : null,
                icon: const Icon(Icons.add),
                label: const Text('افزودن مرحله جدید'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _latestCard(FollowUp? latest, DateTime now) {
    if (latest == null) {
      return _card(
        key: const ValueKey('task-detail-latest-followup'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: _sectionTitle('آخرین پیگیری', Icons.bolt_outlined)),
              if (!_task.completed)
                TextButton.icon(
                  key: const ValueKey('task-detail-add-followup'),
                  onPressed: widget.onAddFollowUp == null ? null : _addFollowUp,
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('افزودن پیگیری'),
                ),
            ]),
            const Text('هنوز پیگیری ثبت نشده است', style: TextStyle(color: _muted)),
          ],
        ),
      );
    }
    return _card(
      key: const ValueKey('task-detail-latest-followup'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _sectionTitle('آخرین پیگیری', Icons.bolt_outlined),
            const Spacer(),
            if (!_task.completed)
              IconButton(
                key: const ValueKey('task-detail-add-followup'),
                tooltip: 'افزودن پیگیری',
                onPressed: widget.onAddFollowUp == null ? null : _addFollowUp,
                icon: const Icon(Icons.add_circle_outline),
              ),
          ]),
          const SizedBox(height: 10),
          Text(
              latest.title?.trim().isNotEmpty == true
                  ? latest.title!.trim()
                  : (latest.note.trim().isEmpty ? 'پیگیری' : latest.note.trim()),
              key: const ValueKey('task-detail-latest-followup-title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (latest.title?.trim().isNotEmpty == true && latest.note.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(latest.note.trim(), key: const ValueKey('task-detail-latest-followup-note')),
            ],
            const SizedBox(height: 5),
            Text(_dateTime(latest.dateTime), style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '● ${_elapsedFormatter.since(latest.dateTime, now: now)}',
                    key: const ValueKey('task-detail-latest-followup-elapsed'),
                    style: TextStyle(color: _brand, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                if (latest.waitingForResponse) _badge('در انتظار پاسخ', _waiting),
                if (_resultLabel(latest) != null) _badge(_resultLabel(latest)!, _waitingService.isWaitingResult(latest.result) ? _waiting : _brand),
                IconButton(
                  key: ValueKey('task-detail-latest-edit-followup-${latest.id}'),
                  onPressed: () => _editFollowUp(latest),
                  tooltip: 'ویرایش پیگیری',
                  icon: const Icon(Icons.edit_outlined, size: 19),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _timeline(List<FollowUp> history) {
    if (history.isEmpty) {
      return _card(
        key: const ValueKey('task-detail-timeline'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('تاریخچه پیگیری‌ها', Icons.timeline_outlined),
            const SizedBox(height: 8),
            const Text('تاریخچه‌ای ثبت نشده است', style: TextStyle(color: _muted)),
          ],
        ),
      );
    }
    return _card(
      key: const ValueKey('task-detail-timeline'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('تاریخچه پیگیری‌ها', Icons.timeline_outlined),
          const SizedBox(height: 12),
          for (var index = 0; index < history.length; index++)
            _timelineItem(
              history[index],
              previous: index + 1 < history.length ? history[index + 1] : null,
              isLast: index == history.length - 1,
              isLatest: index == 0,
            ),
        ],
      ),
    );
  }

  Widget _timelineItem(FollowUp followUp, {required FollowUp? previous, required bool isLast, required bool isLatest}) {
    final result = _resultLabel(followUp);
    final color = _waitingService.isWaitingResult(followUp.result) ? _waiting : _brand;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(width: 2, height: 65, color: color.withValues(alpha: .18)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            key: ValueKey('task-detail-followup-${followUp.id}'),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  followUp.title?.trim().isNotEmpty == true
                      ? followUp.title!.trim()
                      : (followUp.note.trim().isEmpty ? 'پیگیری' : followUp.note.trim()),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (followUp.title?.trim().isNotEmpty == true && followUp.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(followUp.note.trim()),
                ],
                if (followUp.waitingForResponse) ...[
                  const SizedBox(height: 4),
                  _badge('در انتظار پاسخ', _waiting),
                ],
                const SizedBox(height: 3),
                Text(_dateTime(followUp.dateTime), style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
                if (result != null && !isLatest) ...[
                  const SizedBox(height: 5),
                  Text(result, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
                if (previous != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'فاصله از پیگیری قبلی: ${_elapsedFormatter.interval(followUp.dateTime, previous.dateTime)}',
                      key: ValueKey('task-detail-followup-interval-${followUp.id}'),
                      style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                IconButton(
                  key: ValueKey('task-detail-edit-followup-${followUp.id}'),
                  onPressed: () => _editFollowUp(followUp),
                  tooltip: 'ویرایش پیگیری',
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _metadataChip(String label, Color color, {IconData icon = Icons.info_outline, Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontFamily: 'Vazirmatn', color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _metadataItem({required Key key, required String label, required String value, required Color color, required IconData icon, Widget? editor}) {
    return SizedBox(
      key: key,
      width: 124,
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Vazirmatn', color: color, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 9),
            if (editor != null)
              editor
            else
              Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Vazirmatn', color: Color(0xFF232433), fontSize: 12, fontWeight: FontWeight.w700, height: 1.35)),
          ],
        ),
      ),
    );
  }

  Widget _statusPriorityCard() {
    final completed = _isInlineEditing ? _draftCompleted : _task.completed;
    final priority = _isInlineEditing ? _draftPriority : _task.priority;
    final waitingForResponse = !completed && !_task.archived && !_task.trashed &&
        (_task.lastFollowUp?.waitingForResponse == true || _waitingService.isWaiting(_task));
    final status = _task.trashed
        ? 'در سطل زباله'
        : _task.archived
            ? 'بایگانی‌شده'
            : completed
                ? 'انجام‌شده'
                : waitingForResponse
                    ? 'در انتظار پاسخ'
                    : 'در انتظار انجام';
    final statusColor = completed
        ? ArvinColors.tag
        : waitingForResponse
            ? _waiting
            : _brand;
    return Wrap(spacing: 7, runSpacing: 7, children: [
      PopupMenuButton<String>(
        key: const ValueKey('task-detail-status-menu'),
        tooltip: 'تغییر وضعیت کار',
        enabled: !_task.trashed && !_task.archived,
        onSelected: (value) {
          if (value != 'toggle') return;
          if (_isInlineEditing) {
            setState(() => _draftCompleted = !_draftCompleted);
          } else {
            _complete();
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'toggle',
            child: Text(completed ? 'بازگشت به انجام‌نشده' : 'علامت‌گذاری به‌عنوان انجام‌شده'),
          ),
        ],
        child: _metadataChip(status, statusColor, icon: Icons.check_circle_outline, key: const ValueKey('task-status-badge')),
      ),
      PopupMenuButton<TaskPriority>(
        key: const ValueKey('task-detail-priority-menu'),
        tooltip: 'تغییر اولویت',
        onSelected: (value) {
          if (_isInlineEditing) {
            setState(() => _draftPriority = value);
          } else {
            _changePriority(value);
          }
        },
        itemBuilder: (_) => TaskPriority.values.map((value) => PopupMenuItem(
          value: value,
          child: Text(value.label, style: TextStyle(color: ArvinColors.priorityColor(value))),
        )).toList(growable: false),
        child: _metadataChip(priority.label, ArvinColors.priorityColor(priority), icon: Icons.flag_outlined),
      ),
    ]);
  }

  Widget _templateSourceCard() {
    final templateId = _task.templateTaskId?.trim();
    if (templateId == null || templateId.isEmpty) {
      return const SizedBox.shrink();
    }
    final snapshot = widget.project?.templateId == templateId
        ? widget.project?.templateNameSnapshot?.trim()
        : null;
    return _card(
      key: const ValueKey('task_detail_template_source_card'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.copy_all_outlined, color: _brand),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('منشأ الگو', Icons.description_outlined),
                const SizedBox(height: 5),
                Text(snapshot?.isNotEmpty == true
                    ? snapshot!
                    : 'شناسه الگو: $templateId'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadataCard() {
    final selectedProject = _projects.where((item) => item.id == _selectedProjectId);
    final projectColor = selectedProject.isNotEmpty
        ? Color(selectedProject.first.colorValue)
        : widget.project == null
            ? _muted
            : Color(widget.project!.colorValue);
    final items = <Widget>[
      _metadataItem(key: const ValueKey('task-detail-metadata-time'), label: 'زمان اجرا', value: 'نامشخص', color: _muted, icon: Icons.schedule_outlined),
      _metadataItem(
        key: const ValueKey('task-detail-metadata-center'),
        label: 'مرکز',
        value: _selectedCenterName,
        color: ArvinColors.category,
        icon: Icons.apartment_outlined,
        editor: _isInlineEditing
            ? OutlinedButton.icon(
                key: const ValueKey('task-detail-inline-center'),
                onPressed: _openInlineCenterSelector,
                icon: const Icon(Icons.apartment_outlined, size: 18),
                label: Text(_selectedCenterName),
              )
            : null,
      ),
      _metadataItem(
        key: const ValueKey('task-detail-metadata-project'),
        label: 'پروژه',
        value: _selectedProjectTitle,
        color: projectColor,
        icon: Icons.folder_special_outlined,
        editor: _isInlineEditing
            ? OutlinedButton.icon(
                key: const ValueKey('task-detail-inline-project'),
                onPressed: _openInlineProjectSelector,
                icon: const Icon(Icons.folder_outlined, size: 18),
                label: Text(_selectedProjectTitle),
              )
            : null,
      ),
      _metadataItem(
        key: const ValueKey('task-detail-metadata-category'),
        label: 'دسته',
        value: _task.category?.trim().isNotEmpty == true ? _task.category!.trim() : 'بدون دسته',
        color: ArvinColors.category,
        icon: Icons.folder_outlined,
        editor: _isInlineEditing
            ? OutlinedButton.icon(
                key: const ValueKey('task-detail-inline-category'),
                onPressed: _openInlineCategorySelector,
                icon: const Icon(Icons.layers_outlined, size: 18),
                label: Text(_categoryController?.text.trim().isNotEmpty == true
                    ? _categoryController!.text.trim()
                    : 'انتخاب دسته'),
              )
            : null,
      ),
      _metadataItem(
        key: const ValueKey('task-detail-metadata-tags'),
        label: 'برچسب‌ها',
        value: _task.tags.isNotEmpty ? _task.tags.join('، ') : 'بدون برچسب',
        color: ArvinColors.tag,
        icon: Icons.sell_outlined,
        editor: _isInlineEditing
            ? OutlinedButton.icon(
                key: const ValueKey('task-detail-inline-tags'),
                onPressed: _openInlineTagSelector,
                icon: const Icon(Icons.sell_outlined, size: 18),
                label: Text(_tagsController?.text.trim().isNotEmpty == true
                    ? _tagsController!.text.trim()
                    : 'انتخاب برچسب‌ها'),
              )
            : null,
      ),
    ];
    return Column(
      key: const ValueKey('task-detail-metadata'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          key: const ValueKey('task-detail-metadata-chips'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: index == items.length - 1 ? 0 : 8),
                  child: items[index],
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text('تاریخ ایجاد: ${_task.createdAt == null ? 'نامشخص' : _dateTime(_task.createdAt!)}',
          key: const ValueKey('task-detail-created-at'),
          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: _muted)),
        const SizedBox(height: 3),
        Text('آخرین به‌روزرسانی: ${_task.updatedAt == null ? 'نامشخص' : _dateTime(_task.updatedAt!)}',
          key: const ValueKey('task-detail-updated-at'),
          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: _muted)),
      ],
    );
  }

  Widget _remindersCard() {
    final reminders = _isInlineEditing ? _draftReminders : _task.taskReminders;
    return _card(
      key: const ValueKey('task-detail-independent-reminders'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _sectionTitle('یادآوری‌ها', Icons.notifications_active_outlined),
          const Spacer(),
          TextButton.icon(
            key: const ValueKey('task-detail-add-reminder'),
            onPressed: _isInlineEditing
                ? _addInlineReminder
                : widget.onTaskChanged == null
                    ? null
                    : _beginInlineEdit,
            icon: const Icon(Icons.add, size: 17),
            label: const Text('افزودن'),
          ),
        ]),
        if (reminders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('یادآوری ثبت نشده است', style: TextStyle(color: _muted)),
          ),
        for (final reminder in reminders)
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  key: ValueKey('task-detail-reminder-${reminder.id}'),
                  contentPadding: EdgeInsets.zero,
                  value: reminder.isEnabled,
                  onChanged: _isInlineEditing
                      ? (value) => _toggleDraftReminder(reminder, value)
                      : widget.onTaskChanged == null
                          ? null
                          : (value) => _toggleReminder(reminder, value),
                  title: Text(reminder.title),
                  subtitle: Text(reminder.isAllDay ? _date(reminder.date) : _dateTime(reminder.date)),
                  secondary: Icon(Icons.notifications_outlined, color: reminder.isEnabled ? ArvinColors.reminder : _muted),
                ),
              ),
              if (_isInlineEditing) ...[
                IconButton(
                  key: ValueKey('task-detail-reminder-edit-title-${reminder.id}'),
                  tooltip: 'ویرایش عنوان یادآور',
                  onPressed: () => _editDraftReminderTitle(reminder),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  key: ValueKey('task-detail-reminder-edit-schedule-${reminder.id}'),
                  tooltip: 'تغییر زمان یادآور',
                  onPressed: () => _editDraftReminderSchedule(reminder),
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                IconButton(
                  key: ValueKey('task-detail-reminder-remove-${reminder.id}'),
                  tooltip: 'حذف یادآور',
                  onPressed: () => _removeDraftReminder(reminder),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ],
          ),
      ]),
    );
  }

  String _recurrenceFrequencyLabel(RecurrenceFrequency frequency) => switch (frequency) {
    RecurrenceFrequency.daily => 'روزانه',
    RecurrenceFrequency.weekly => 'هفتگی',
    RecurrenceFrequency.monthly => 'ماهانه',
    RecurrenceFrequency.yearly => 'سالانه',
    RecurrenceFrequency.oncePerDay => 'یک‌بار در روز',
    RecurrenceFrequency.minutes => 'دقیقه‌ای',
    RecurrenceFrequency.hours => 'ساعتی',
  };

  Future<void> _pickInlineRecurrenceEndDate() async {
    final initial = _draftRecurrenceEndDate ??
        _draftDueDate ??
        DateTime.now().add(const Duration(days: 30));
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب پایان تکرار',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _draftRecurrenceEndDate = DateTime(
        picked.year, picked.month, picked.day, 23, 59, 59, 999,
      );
    });
  }

  Widget _recurrenceCard(DateTime now) {
    final rule = _task.recurrence;
    final configured = rule != null || (_isInlineEditing && _recurrenceConfigured);
    if (!configured) {
      return _card(
        key: const ValueKey('task-detail-recurrence'),
        child: Row(
          children: [
            Expanded(child: _sectionTitle('تکرار کار', Icons.repeat)),
            const Text('بدون تکرار', style: TextStyle(color: _muted)),
            if (_isInlineEditing)
              TextButton.icon(
                key: const ValueKey('task-detail-recurrence-add'),
                onPressed: () => setState(() => _recurrenceConfigured = true),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('افزودن قاعده'),
              ),
          ],
        ),
      );
    }

    final frequency = _isInlineEditing ? _recurrenceFrequency : rule!.frequency;
    final interval = _isInlineEditing
        ? (_recurrenceIntervalController?.text ?? '1')
        : rule!.interval.toString();
    final active = _isInlineEditing ? _recurrenceActive : rule!.active;
    final anchor = rule?.startDate ?? _task.dueDate;
    final upcoming = !_isInlineEditing && rule != null && anchor != null
        ? rule.occurrencesBetween(
            anchor: anchor,
            from: now,
            to: now.add(const Duration(days: 30)),
          ).take(5).toList(growable: false)
        : const <DateTime>[];
    final unit = switch (frequency) {
      RecurrenceFrequency.daily || RecurrenceFrequency.oncePerDay => 'روز',
      RecurrenceFrequency.weekly => 'هفته',
      RecurrenceFrequency.monthly => 'ماه',
      RecurrenceFrequency.yearly => 'سال',
      RecurrenceFrequency.minutes => 'دقیقه',
      RecurrenceFrequency.hours => 'ساعت',
    };

    return _card(
      key: const ValueKey('task-detail-recurrence'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionTitle('تکرار کار', Icons.repeat)),
          if (_isInlineEditing)
            Switch(
              key: const ValueKey('task-detail-recurrence-enabled'),
              value: active,
              onChanged: (value) => setState(() => _recurrenceActive = value),
            )
          else if (rule != null)
            Switch(
              key: const ValueKey('task-detail-recurrence-enabled'),
              value: rule.active,
              onChanged: widget.onTaskChanged == null ? null : _toggleRecurrence,
            ),
        ]),
        if (_isInlineEditing) ...[
          DropdownButtonFormField<RecurrenceFrequency>(
            key: const ValueKey('task-detail-recurrence-frequency'),
            initialValue: _recurrenceFrequency,
            decoration: const InputDecoration(labelText: 'نوع تکرار'),
            items: RecurrenceFrequency.values.map((value) => DropdownMenuItem(
              value: value,
              child: Text(_recurrenceFrequencyLabel(value)),
            )).toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _recurrenceFrequency = value);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('task-detail-recurrence-interval'),
            controller: _recurrenceIntervalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'فاصله تکرار', helperText: 'مثلاً ۲ برای هر دو هفته'),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('task-detail-recurrence-count'),
            controller: _recurrenceCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'تعداد دفعات (اختیاری)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _draftRecurrenceEndDate == null
                      ? 'پایان تکرار: بدون محدودیت تاریخ'
                      : 'پایان تکرار: ${_date(_draftRecurrenceEndDate!)}',
                  key: const ValueKey('task-detail-recurrence-end-date'),
                ),
              ),
              TextButton(
                key: const ValueKey('task-detail-recurrence-end-date-pick'),
                onPressed: _pickInlineRecurrenceEndDate,
                child: const Text('انتخاب پایان'),
              ),
              if (_draftRecurrenceEndDate != null)
                IconButton(
                  key: const ValueKey('task-detail-recurrence-end-date-clear'),
                  tooltip: 'حذف پایان تکرار',
                  onPressed: () => setState(() => _draftRecurrenceEndDate = null),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<RecurrenceTrackingLevel>(
            key: const ValueKey('task-detail-recurrence-tracking'),
            initialValue: _recurrenceTrackingLevel,
            decoration: const InputDecoration(labelText: 'سطح پیگیری'),
            items: RecurrenceTrackingLevel.values.map((value) => DropdownMenuItem(
              value: value,
              child: Text(value == RecurrenceTrackingLevel.tracking ? 'با ثبت سابقه' : 'عادی'),
            )).toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _recurrenceTrackingLevel = value);
            },
          ),
        ] else if (rule != null) ...[
          Text('قاعده: هر $interval $unit'),
          if (rule.endDate != null)
            Text('پایان تکرار: ${_date(rule.endDate!)}', key: const ValueKey('task-detail-recurrence-end-date')),
          const SizedBox(height: 4),
          Text(rule.active ? 'تکرار فعال است' : 'تکرار غیرفعال است', style: const TextStyle(color: _muted)),
          const SizedBox(height: 6),
          const Text('رویدادهای آینده (۳۰ روز، حداکثر ۵ مورد):', style: TextStyle(fontWeight: FontWeight.w700)),
          if (anchor == null)
            const Text('مبدأ تکرار ثبت نشده است', style: TextStyle(color: _muted))
          else if (upcoming.isEmpty)
            const Text('رویداد آینده‌ای در این بازه وجود ندارد', style: TextStyle(color: _muted))
          else
            for (final date in upcoming)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat_outlined),
                title: Text(_task.allDay ? _date(date) : _dateTime(date)),
              ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _task.lastFollowUp;
    final history = List<FollowUp>.of(_task.followUps)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final now = widget.now ?? DateTime.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: const ValueKey('task-detail-page'),
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          key: const ValueKey('task-detail-app-bar'),
          backgroundColor: const Color(0xFF37379B),
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
          title: const Text('مشخصات کار', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
          actions: [
            if (widget.onRegisterTaskToDeviceCalendar != null)
              IconButton(
                key: const ValueKey('task-detail-send-device-calendar'),
                tooltip: 'ارسال به تقویم دستگاه',
                onPressed: _sendToDeviceCalendar,
                icon: const Icon(Icons.event_available_outlined),
              ),
            IconButton(
              key: const ValueKey('task-detail-inline-edit-toggle'),
              tooltip: _isInlineEditing ? 'ذخیره ویرایش درجا' : 'ویرایش درجا',
              onPressed: widget.onTaskChanged == null ? null : (_isInlineEditing ? _saveInlineEdit : _beginInlineEdit),
              icon: Icon(_isInlineEditing ? Icons.save_outlined : Icons.edit_note_outlined),
            ),
            if (_isInlineEditing)
              IconButton(
                key: const ValueKey('task-detail-inline-edit-cancel'),
                tooltip: 'انصراف از ویرایش درجا',
                onPressed: _isSavingInlineEdit ? null : _cancelInlineEdit,
                icon: const Icon(Icons.close),
              ),
            IconButton(
              key: const ValueKey('task-detail-convert-template'),
              tooltip: 'تبدیل به الگو',
              onPressed: _isInlineEditing || _isSavingTaskTemplate ? null : _convertToTemplate,
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
            IconButton(
              key: const ValueKey('task-detail-clone'),
              tooltip: 'تکثیر / کپی کار',
              onPressed: widget.onClone == null ? null : _cloneTask,
              icon: const Icon(Icons.copy_all_outlined),
            ),
            PopupMenuButton<String>(
              key: const ValueKey('task-detail-more'),
              tooltip: 'بیشتر',
              onSelected: (value) {
                if (value == 'report') _openReport();
                if (value == 'delete') _deleteTask();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    key: ValueKey('task-detail-report'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.picture_as_pdf_outlined),
                    title: Text('PDF، چاپ و اشتراک‌گذاری'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  enabled: widget.onDelete != null && !_isInlineEditing,
                  child: const ListTile(
                    key: ValueKey('task-detail-delete-menu'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline, color: Color(0xFFD04444)),
                    title: Text('انتقال به سطل زباله'),
                  ),
                ),
              ],
            ),
            IconButton(
              key: const ValueKey('task-detail-back'),
              tooltip: 'بازگشت',
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          key: const ValueKey('task-detail-bottom-actions'),
          minimum: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              key: const ValueKey('task-detail-add-followup-bottom'),
              onPressed: _isInlineEditing || widget.onAddFollowUp == null
                  ? null
                  : _addFollowUp,
              style: OutlinedButton.styleFrom(
                foregroundColor: _brand,
                side: BorderSide(color: _brand),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('افزودن پیگیری'),
            )),
            const SizedBox(width: 7),
            Expanded(child: FilledButton.icon(
              key: const ValueKey('task-detail-complete'),
              onPressed: _isInlineEditing || widget.onComplete == null
                  ? null
                  : _complete,
              style: FilledButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(_task.completed ? Icons.undo : Icons.check_circle_outline),
              label: Text(_task.completed ? 'بازگشت به انجام‌نشده' : 'انجام کار'),
            )),
          ]),
        ),
        body: ListView(
          key: const ValueKey('task-detail-content-list'),
          controller: _detailScrollController,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            _metadataCard(),
            const SizedBox(height: 10),
            _summaryCard(),
            const SizedBox(height: 10),
            _templateSourceCard(),
            const SizedBox(height: 10),
            _dueDateCard(),
            const SizedBox(height: 10),
            _assigneeCard(),
            const SizedBox(height: 10),
            _remindersCard(),
            const SizedBox(height: 10),
            _recurrenceCard(now),
            const SizedBox(height: 10),
            _checklistCard(),
            const SizedBox(height: 10),
            _latestCard(latest, now),
            const SizedBox(height: 10),
            _timeline(history),
          ],
        ),
      ),
    );
  }
}
