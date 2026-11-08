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

  Future<void> _toggleFavorite() async {
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..isFavorite = !_task.isFavorite;
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
    final nextCenterId = result.cleared ? null : result.value;
    final selectedProject = _projects.where((project) => project.id == _selectedProjectId);
    final clearProject = result.cleared ||
        (selectedProject.isNotEmpty &&
            nextCenterId != null &&
            selectedProject.first.centerId != nextCenterId);
    setState(() {
      _selectedCenterId = nextCenterId;
      if (clearProject) _selectedProjectId = null;
    });
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..centerId = nextCenterId;
    await _persistCandidate(candidate);
    if (clearProject) await widget.onProjectChanged?.call(null);
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
    final nextProjectId = result.cleared ? null : result.value;
    final selectedProject = _projects.where((project) => project.id == nextProjectId);
    final nextCenterId = selectedProject.isNotEmpty
        ? selectedProject.first.centerId
        : _selectedCenterId;
    setState(() {
      _selectedProjectId = nextProjectId;
      _selectedCenterId = nextCenterId;
    });
    await widget.onProjectChanged?.call(nextProjectId);
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..centerId = nextCenterId;
    await _persistCandidate(candidate);
  }

  Future<void> _openInlineCategorySelector() async {
    final current = _task.category?.trim() ?? '';
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
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..category = result.cleared ? null : result.value;
    await _persistCandidate(candidate);
  }

  Future<void> _openInlineTagSelector() async {
    final current = _task.tags
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
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..tags = (result.toList()..sort());
    await _persistCandidate(candidate);
  }

  Future<void> _pickInlineWorkTime() async {
    final current = _task.dueDate ?? DateTime.now();
    final pickedDate = await showPersianDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب زمان کار / موعد',
    );
    if (pickedDate == null || !mounted) return;

    // Confirm the date first, then the round clock (including the explicit
    // no-time choice). Persist the canonical Task immediately after confirmation.
    final selection = await showUniversalArvinTimeSelectionPicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'زمان انجام کار',
    );
    if (selection == null || !mounted) return;

    final dueDate = selection.isAllDay
        ? DateTime(pickedDate.year, pickedDate.month, pickedDate.day)
        : DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            selection.time!.hour,
            selection.time!.minute,
          );
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..dueDate = dueDate
      ..allDay = selection.isAllDay;
    await _persistCandidate(candidate);
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
    return KeyedSubtree(
      key: const ValueKey('task-detail-summary-card'),
      child: _isInlineEditing
          ? TextField(
              key: const ValueKey('task-detail-inline-title'),
              controller: _titleController,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              onSubmitted: (_) => _saveInlineEdit(),
              style: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                hintText: 'عنوان کار',
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            )
          : Text(
              _task.title,
              key: const ValueKey('task-detail-title'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
            ),
    );
  }

  Widget _dueDateCard() {
    final dueDate = _isInlineEditing ? _draftDueDate : _task.dueDate;
    final allDay = _isInlineEditing ? _draftAllDay : _task.allDay;
    return _linearActionRow(
        key: const ValueKey('task-detail-due-date-card'),
        valueKey: const ValueKey('task-detail-due-date'),
        icon: Icons.calendar_month_outlined,
        title: 'موعد',
        value: dueDate == null ? 'تعیین نشده' : (allDay ? _date(dueDate) : _dateTime(dueDate)),
        onTap: widget.onTaskChanged == null ? null : _pickInlineWorkTime,
      );
  }

  Widget _assigneeCard() {
    final latest = _task.lastFollowUp;
    return KeyedSubtree(
      key: const ValueKey('task-detail-assignee-card'),
      child: _linearActionRow(
        key: const ValueKey('task-detail-waiting-person-row'),
        icon: Icons.person_outline_rounded,
        title: 'مسئول',
        value: 'مسئول مستقلی برای این کار ثبت نشده است',
        onTap: latest?.waitingForResponse == true && widget.onAddFollowUp != null
            ? _addFollowUp
            : null,
      ),
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
    final handler = widget.onChecklistChanged;
    if (handler == null && widget.onTaskChanged == null) return;

    // Checklist edits are persisted immediately and remain isolated from the
    // historical Follow-up timeline, regardless of the former edit-mode state.
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
      final updated = handler != null
          ? await handler(candidate, List<String>.of(values))
          : await widget.onTaskChanged?.call(candidate);
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

  Widget _metadataCard() => KeyedSubtree(
        key: const ValueKey('task-detail-metadata'),
        child: _organizationCard(),
      );

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

  Future<void> _saveDescriptionImmediately(String value) async {
    final candidate = Task.fromJson(Map<String, dynamic>.from(_task.toJson()))
      ..description = value
      ..updatedAt = DateTime.now();
    final save = widget.onDescriptionChanged;
    try {
      final updated = save != null
          ? await save(_task, value)
          : await widget.onTaskChanged?.call(candidate);
      if (!mounted || updated == null) return;
      setState(() => _task = updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ذخیره یادداشت انجام نشد؛ دوباره تلاش کنید')),
      );
    }
  }

  Widget _linearActionRow({
    required Key key,
    required IconData icon,
    required String title,
    required String value,
    Key? valueKey,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(icon, color: _brand, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(value, key: valueKey, style: const TextStyle(fontFamily: 'Vazirmatn', color: _muted, fontSize: 12)),
                    ],
                  ),
                ),
                trailing ?? const Icon(Icons.chevron_left, color: _muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _organizationCard() {
    Future<void> openSelector(Future<void> Function() open) => open();

    return _card(
      key: const ValueKey('task-detail-organization-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('سازماندهی کار', Icons.tune_rounded),
          const SizedBox(height: 8),
          _linearActionRow(
            key: const ValueKey('task-detail-organization-center'),
            icon: Icons.apartment_outlined,
            title: 'مرکز',
            value: _selectedCenterName,
            onTap: () => openSelector(_openInlineCenterSelector),
          ),
          const Divider(height: 1),
          _linearActionRow(
            key: const ValueKey('task-detail-organization-project'),
            icon: Icons.folder_outlined,
            title: 'پروژه',
            value: _selectedProjectTitle,
            onTap: () => openSelector(_openInlineProjectSelector),
          ),
          const Divider(height: 1),
          _linearActionRow(
            key: const ValueKey('task-detail-organization-category'),
            icon: Icons.category_outlined,
            title: 'دسته‌بندی',
            value: _task.category?.trim().isNotEmpty == true ? _task.category!.trim() : 'بدون دسته',
            onTap: () => openSelector(_openInlineCategorySelector),
          ),
          const Divider(height: 1),
          _linearActionRow(
            key: const ValueKey('task-detail-organization-tags'),
            icon: Icons.sell_outlined,
            title: 'برچسب‌ها',
            value: _task.tags.isEmpty ? 'بدون برچسب' : _task.tags.join('، '),
            onTap: () => openSelector(_openInlineTagSelector),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _task.lastFollowUp;
    final history = List<FollowUp>.of(_task.followUps)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final now = widget.now ?? DateTime.now();
    final due = _isInlineEditing ? _draftDueDate : _task.dueDate;
    final dueToday = due != null &&
        due.year == now.year && due.month == now.month && due.day == now.day;
    final priority = _isInlineEditing ? _draftPriority : _task.priority;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: const ValueKey('task-detail-page'),
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              Material(
                key: const ValueKey('task-detail-app-bar'),
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            key: const ValueKey('task-detail-back'),
                            tooltip: 'بازگشت',
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const Spacer(),
                          if (widget.onRegisterTaskToDeviceCalendar != null)
                            IconButton(
                              key: const ValueKey('task-detail-send-device-calendar'),
                              tooltip: 'ارسال به تقویم دستگاه',
                              color: Colors.white,
                              onPressed: _sendToDeviceCalendar,
                              icon: const Icon(Icons.event_available_outlined),
                            ),
                          IconButton(
                            key: const ValueKey('task-detail-inline-edit-toggle'),
                            tooltip: _isInlineEditing ? 'ذخیره تغییرات' : 'ویرایش کار',
                            color: Colors.white,
                            onPressed: widget.onTaskChanged == null
                                ? null
                                : (_isInlineEditing ? _saveInlineEdit : _beginInlineEdit),
                            icon: Icon(_isInlineEditing ? Icons.save_outlined : Icons.edit_outlined),
                          ),
                          if (_isInlineEditing)
                            IconButton(
                              key: const ValueKey('task-detail-inline-edit-cancel'),
                              tooltip: 'لغو ویرایش',
                              color: Colors.white,
                              onPressed: _cancelInlineEdit,
                              icon: const Icon(Icons.close),
                            ),
                          IconButton(
                            key: const ValueKey('task-detail-convert-template'),
                            tooltip: 'تبدیل به الگو',
                            color: Colors.white,
                            onPressed: _isInlineEditing || _isSavingTaskTemplate ? null : _convertToTemplate,
                            icon: const Icon(Icons.bookmark_add_outlined),
                          ),
                          IconButton(
                            key: const ValueKey('task-detail-clone'),
                            tooltip: 'تکثیر کار',
                            color: Colors.white,
                            onPressed: widget.onClone == null ? null : _cloneTask,
                            icon: const Icon(Icons.copy_all_outlined),
                          ),
                          PopupMenuButton<String>(
                            key: const ValueKey('task-detail-more'),
                            iconColor: Colors.white,
                            onSelected: (value) {
                              if (value == 'report') _openReport();
                              if (value == 'delete') _deleteTask();
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                key: ValueKey('task-detail-report'),
                                value: 'report',
                                child: Text('PDF، چاپ و اشتراک‌گذاری'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                enabled: widget.onDelete != null && !_isInlineEditing,
                                child: const Text('حذف کار'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _summaryCard()),
                          const SizedBox(width: 4),
                          IconButton(
                            key: const ValueKey('task-detail-favorite'),
                            tooltip: _task.isFavorite ? 'حذف از علاقه‌مندی‌ها' : 'افزودن به علاقه‌مندی‌ها',
                            onPressed: widget.onTaskChanged == null ? null : _toggleFavorite,
                            color: _task.isFavorite ? const Color(0xFFFFD166) : Colors.white,
                            icon: Icon(_task.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<TaskPriority>(
                            key: const ValueKey('task-detail-priority-menu'),
                            tooltip: 'اولویت کار',
                            initialValue: priority,
                            onSelected: (value) {
                              if (_isInlineEditing) {
                                setState(() => _draftPriority = value);
                              } else {
                                _changePriority(value);
                              }
                            },
                            itemBuilder: (_) => TaskPriority.values
                                .map((value) => PopupMenuItem(
                                      value: value,
                                      child: Text(value.label),
                                    ))
                                .toList(growable: false),
                            child: _metadataChip(
                              priority.label,
                              ArvinColors.priorityColor(priority),
                              icon: Icons.flag_outlined,
                            ),
                          ),
                          IconButton(
                            key: const ValueKey('task-detail-header-complete'),
                            tooltip: _task.completed ? 'بازگشت به انجام‌نشده' : 'انجام کار',
                            onPressed: widget.onComplete == null ? null : _complete,
                            color: Colors.white,
                            iconSize: 32,
                            icon: Icon(_task.completed
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded),
                          ),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8, top: 4),
                          child: Text(
                            _task.completed ? 'انجام‌شده' : 'در انتظار انجام',
                            key: const ValueKey('task-status-badge'),
                            style: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  key: const ValueKey('task-detail-content-list'),
                  controller: _detailScrollController,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                  children: [
                    _checklistCard(),
                    const SizedBox(height: 10),
                    _card(
                      key: const ValueKey('task-detail-linear-actions'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _linearActionRow(
                            key: const ValueKey('task-detail-my-day'),
                            icon: Icons.wb_sunny_outlined,
                            title: 'افزودن به روز من',
                            value: dueToday ? 'برای امروز تنظیم شده' : 'با انتخاب، موعد امروز ثبت می‌شود',
                            onTap: _isMovingDueDateToToday ? null : _moveDueDateToToday,
                            trailing: dueToday
                                ? Icon(Icons.check_circle, color: _brand)
                                : const Icon(Icons.chevron_left, color: _muted),
                          ),
                          const Divider(height: 1),
                          _linearActionRow(
                            key: const ValueKey('task-detail-add-reminder-row'),
                            icon: Icons.notifications_none_rounded,
                            title: 'افزودن یادآور',
                            value: _task.taskReminders.isEmpty
                                ? 'یادآور مستقلی ثبت نشده'
                                : '${_task.taskReminders.length} یادآور ثبت شده',
                            onTap: widget.onTaskChanged == null
                                ? null
                                : () async {
                                    if (!_isInlineEditing) _beginInlineEdit();
                                    await _addInlineReminder();
                                    if (mounted && _isInlineEditing) await _saveInlineEdit();
                                  },
                          ),
                          const Divider(height: 1),
                          _dueDateCard(),
                          const Divider(height: 1),
                          _linearActionRow(
                            key: const ValueKey('task-detail-repeat-row'),
                            icon: Icons.repeat_rounded,
                            title: 'تکرار',
                            value: _task.recurrence == null
                                ? 'بدون تکرار'
                                : _recurrenceFrequencyLabel(_task.recurrence!.frequency),
                            onTap: widget.onTaskChanged == null
                                ? null
                                : () {
                                    if (!_isInlineEditing) _beginInlineEdit();
                                    setState(() => _recurrenceConfigured = true);
                                  },
                          ),
                          const Divider(height: 1),
                          _assigneeCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _metadataCard(),
                    const SizedBox(height: 10),
                    _card(
                      key: const ValueKey('task-detail-description-card'),
                      child: Column(
                        key: const ValueKey('task-detail-connected-notes'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionTitle('یادداشت', Icons.sticky_note_2_outlined),
                          const SizedBox(height: 8),
                          if (_isInlineEditing)
                            TextField(
                              key: const ValueKey('task-detail-connected-notes-field'),
                              controller: _descriptionController,
                              minLines: 3,
                              maxLines: null,
                              textDirection: TextDirection.rtl,
                              onSubmitted: _saveDescriptionImmediately,
                              onEditingComplete: () => _saveDescriptionImmediately(
                                _descriptionController?.text ?? _task.description,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'یادداشت این کار را بنویسید...',
                                border: OutlineInputBorder(),
                              ),
                            )
                          else ...[
                            Text(
                              _task.description.trim().isEmpty ? 'یادداشتی ثبت نشده است' : _task.description,
                              key: const ValueKey('task-detail-description'),
                              style: const TextStyle(fontFamily: 'Vazirmatn', height: 1.7),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton.icon(
                                onPressed: widget.onTaskChanged == null && widget.onDescriptionChanged == null
                                    ? null
                                    : _beginInlineEdit,
                                icon: const Icon(Icons.edit_note_outlined),
                                label: const Text('ویرایش یادداشت'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _remindersCard(),
                    const SizedBox(height: 10),
                    _recurrenceCard(now),
                    const SizedBox(height: 10),
                    _templateSourceCard(),
                    const SizedBox(height: 10),
                    _latestCard(latest, now),
                    const SizedBox(height: 10),
                    _timeline(history),
                    const SizedBox(height: 10),
                    _card(
                      key: const ValueKey('task-detail-footer'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تاریخ ایجاد: ${_task.createdAt == null ? 'نامشخص' : _dateTime(_task.createdAt!)}',
                            key: const ValueKey('task-detail-created-at'),
                            style: const TextStyle(fontFamily: 'Vazirmatn', color: _muted, fontSize: 12),
                          ),
                          if (widget.onDelete != null) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              key: const ValueKey('task-detail-delete-footer'),
                              onPressed: _isInlineEditing ? null : _deleteTask,
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD04444)),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('حذف کار'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          key: const ValueKey('task-detail-bottom-actions'),
          minimum: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('task-detail-add-followup-bottom'),
                  onPressed: _isInlineEditing || widget.onAddFollowUp == null ? null : _addFollowUp,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('افزودن پیگیری'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('task-detail-complete'),
                  onPressed: _isInlineEditing || widget.onComplete == null ? null : _complete,
                  icon: Icon(_task.completed ? Icons.undo : Icons.check_circle_outline),
                  label: Text(_task.completed ? 'بازگشت به انجام‌نشده' : 'انجام کار'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
