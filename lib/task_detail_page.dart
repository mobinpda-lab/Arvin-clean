import 'package:flutter/material.dart';

import 'arvin_colors.dart';
import 'core/theme/arvin_theme.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'follow_up_entry_page.dart';
import 'follow_up_repository.dart';
import 'models/task.dart';
import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'services/follow_up_elapsed_formatter.dart';
import 'services/follow_up_write_coordinator.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_store.dart';
import 'services/task_template_store.dart';
import 'services/task_move_to_today_service.dart';
import 'services/waiting_for_response_service.dart';
import 'task_report_page.dart';
import 'widgets/persian_date_picker.dart';
import 'widgets/universal_arvin_time_picker.dart';

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

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  static const _brand = ArvinColors.primary;
  static const _waiting = ArvinColors.reminder;
  static const _muted = ArvinColors.neutral;
  static const _formatter = PersianDateFormatter();
  static const _elapsedFormatter = FollowUpElapsedFormatter();
  static const _waitingService = WaitingForResponseService();

  late Task _task;
  TextEditingController? _descriptionController;
  TextEditingController? _titleController;
  TextEditingController? _categoryController;
  TextEditingController? _tagsController;
  bool _isInlineEditing = false;
  bool _isSavingInlineEdit = false;
  bool _isSavingTaskTemplate = false;
  bool _recurrenceConfigured = false;
  bool _recurrenceActive = true;
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
  DateTime? _draftDueDate;
  bool _draftAllDay = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _beginInlineEdit() {
    _titleController?.dispose();
    _descriptionController?.dispose();
    _titleController = TextEditingController(text: _task.title);
    _descriptionController = TextEditingController(text: _task.description);
    _categoryController = TextEditingController(text: _task.category ?? '');
    _tagsController = TextEditingController(text: _task.tags.join('، '));
    _draftReminders = List<TaskReminder>.of(_task.taskReminders);
    _draftDueDate = _task.dueDate;
    _draftAllDay = _task.allDay;
    final rule = _task.recurrence;
    _recurrenceConfigured = rule != null;
    _recurrenceActive = rule?.active ?? true;
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
    _titleController = null;
    _descriptionController = null;
    _categoryController = null;
    _tagsController = null;
    _recurrenceIntervalController = null;
    _recurrenceCountController = null;
    _draftReminders = const [];
    _draftDueDate = null;
    _draftAllDay = false;
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
      ..category = category.isEmpty ? null : category
      ..tags = tags
      ..taskReminders = List<TaskReminder>.of(_draftReminders)
      ..dueDate = _draftDueDate
      ..allDay = _draftAllDay
      ..nextReminderSequence = _draftReminders.isEmpty
          ? _task.nextReminderSequence
          : (_draftReminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b) + 1).clamp(_task.nextReminderSequence, 1 << 30).toInt()
      ..recurrence = _recurrenceConfigured ? RecurrenceRule(
        frequency: _recurrenceFrequency,
        interval: recurrenceInterval,
        startDate: _task.recurrence?.startDate,
        endDate: _task.recurrence?.endDate,
        count: recurrenceCount,
        active: _recurrenceActive,
        trackingLevel: _recurrenceTrackingLevel,
      ) : _task.recurrence
      ..updatedAt = DateTime.now();
    setState(() => _isSavingInlineEdit = true);
    try {
      final updated = await save(candidate);
      if (!mounted) return;
      if (updated == null) throw StateError('Inline Task edit was not persisted.');
      _titleController?.dispose();
      _descriptionController?.dispose();
      _categoryController?.dispose();
      _tagsController?.dispose();
      _recurrenceIntervalController?.dispose();
      _recurrenceCountController?.dispose();
      _titleController = null;
      _descriptionController = null;
      _categoryController = null;
      _tagsController = null;
      _recurrenceIntervalController = null;
      _recurrenceCountController = null;
      _draftReminders = const [];
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
    final titleController = TextEditingController(
      text: 'یادآور ${_draftReminders.length + 1}',
    );
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('یادآور جدید'),
        content: TextField(
          key: const ValueKey('task-detail-reminder-title-input'),
          controller: titleController,
          decoration: const InputDecoration(labelText: 'عنوان یادآور'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          FilledButton(
            onPressed: () {
              final value = titleController.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('ادامه'),
          ),
        ],
      ),
    );
    titleController.dispose();
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
    final time = await showUniversalArvinTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: 'انتخاب ساعت یادآور',
    );
    if (time == null || !mounted) return;

    final highest = _draftReminders.isEmpty
        ? _task.nextReminderSequence - 1
        : _draftReminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b);
    final reminder = TaskReminder(
      id: 'reminder-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      date: DateTime(date.year, date.month, date.day, time.hour, time.minute),
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

  Future<void> _pickInlineDueDate() async {
    final current = _draftDueDate ?? DateTime.now();
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب موعد انجام',
    );
    if (picked == null || !mounted) return;
    final wasUnset = _draftDueDate == null;
    setState(() {
      _draftDueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _draftDueDate?.hour ?? 0,
        _draftDueDate?.minute ?? 0,
      );
      if (wasUnset) _draftAllDay = true;
    });
  }

  Future<void> _pickInlineDueTime() async {
    final current = _draftDueDate;
    if (current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا تاریخ موعد را انتخاب کنید.')),
      );
      return;
    }
    final picked = await showUniversalArvinTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'انتخاب ساعت موعد انجام',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _draftDueDate = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );
      _draftAllDay = false;
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
    final controller = TextEditingController(text: _task.title);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تبدیل کار به الگو'),
        content: TextField(
          key: const ValueKey('task-detail-template-name'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'نام الگو'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          FilledButton(
            key: const ValueKey('task-detail-template-confirm'),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('تأیید و ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
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

  Future<void> _edit() async {
    final edit = widget.onEdit;
    if (edit == null) return;
    final updated = await edit(_task);
    if (!mounted || updated == null) return;
    setState(() => _task = updated);
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

  Future<void> _addFollowUp() async {
    final add = widget.onAddFollowUp;
    if (add == null) return;
    final followUp = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(builder: (_) => FollowUpEntryPage(taskId: _task.id)),
    );
    if (!mounted || followUp == null) return;
    final updated = await add(_task, followUp);
    if (mounted) setState(() => _task = updated);
  }

  Future<void> _editFollowUp(FollowUp existing) async {
    final updated = await Navigator.of(context).push<FollowUp>(
      MaterialPageRoute<FollowUp>(
        builder: (_) => FollowUpEntryPage(initialFollowUp: existing),
      ),
    );
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
      child: child,
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
              if (!_isInlineEditing)
                IconButton(
                  key: const ValueKey('task-detail-summary-edit'),
                  tooltip: 'ویرایش درجا',
                  onPressed: widget.onTaskChanged == null
                      ? (widget.onEdit == null ? null : _edit)
                      : _beginInlineEdit,
                  icon: const Icon(Icons.edit_outlined, color: _brand),
                ),
            ],
          ),
          if (_isInlineEditing) ...[
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('task-detail-inline-description'),
              controller: _descriptionController,
              minLines: 2,
              maxLines: null,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'توضیحات کامل', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('task-detail-inline-category'),
              controller: _categoryController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'دسته', border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('task-detail-inline-tags'),
              controller: _tagsController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'برچسب‌ها (با ویرگول جدا کنید)', border: OutlineInputBorder(), isDense: true),
            ),
          ],
          const SizedBox(height: 10),
          _statusPriorityCard(),
          const SizedBox(height: 10),
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
          if (_task.templateTaskId?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _templateSourceCard(),
          ],
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
              const Icon(Icons.calendar_month_outlined, color: _brand),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('موعد انجام', style: TextStyle(fontFamily: 'Vazirmatn', color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
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
                  key: const ValueKey('task-detail-inline-due-date'),
                  tooltip: 'تغییر تاریخ',
                  onPressed: _pickInlineDueDate,
                  icon: const Icon(Icons.edit_calendar_outlined),
                ),
                IconButton(
                  key: const ValueKey('task-detail-inline-due-time'),
                  tooltip: 'تغییر ساعت',
                  onPressed: dueDate == null ? null : _pickInlineDueTime,
                  icon: const Icon(Icons.access_time),
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
          if (_isInlineEditing)
            SwitchListTile(
              key: const ValueKey('task-detail-inline-all-day'),
              contentPadding: EdgeInsets.zero,
              title: const Text('تمام‌روز'),
              value: allDay,
              onChanged: (value) => setState(() => _draftAllDay = value),
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

  List<String> _normalizedChecklist() => _task.checklist.map((item) {
        final value = item.trim();
        if (value.startsWith('[x] ')) return value;
        if (value.startsWith('[ ] ')) return value;
        if (value.startsWith('[x]')) return '[x] ${value.substring(3).trim()}';
        if (value.startsWith('[ ]')) return '[ ] ${value.substring(3).trim()}';
        return '[ ] $value';
      }).toList();

  Future<void> _saveChecklist(List<String> values) async {
    final handler = widget.onChecklistChanged;
    if (handler == null || _isSavingChecklist) return;

    // Checklist edits are isolated from legacy follow-up scheduling fields.
    // Pass a detached Task snapshot to the owner and restore the protected
    // fields on the returned model before accepting it.
    final previous = _task;
    final protectedFollowUpDate = previous.followUpDate;
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
      updated.followUpDate = protectedFollowUpDate;
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
    if (_task.checklist.isNotEmpty && mounted) {
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
                onPressed: widget.onChecklistChanged != null
                    ? () => setState(() => _isAddingChecklist = true)
                    : (widget.onEdit == null ? null : _edit),
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
          TextField(
            key: const ValueKey('task-detail-checklist-add-input'),
            controller: _checklistAddController,
            enabled: widget.onChecklistChanged != null && !_isSavingChecklist,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'عنوان مرحله جدید را بنویسید...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _addChecklistItem(),
          ),
          const SizedBox(height: 6),
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
                      onChanged: widget.onChecklistChanged == null || _isSavingChecklist
                          ? null
                          : (_) => _toggleChecklistItem(index),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                        title: Text(items[index].substring(4)),
                      ),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('task-detail-checklist-edit-$index'),
                    tooltip: 'ویرایش مورد',
                    onPressed: widget.onChecklistChanged == null || _isSavingChecklist
                        ? null
                        : () => _beginChecklistEdit(index, items[index]),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                  IconButton(
                    key: ValueKey('task-detail-checklist-delete-$index'),
                    tooltip: 'حذف مورد',
                    onPressed: widget.onChecklistChanged == null || _isSavingChecklist
                        ? null
                        : () => _deleteChecklistItem(index),
                    icon: const Icon(Icons.delete_outline, size: 18),
                  ),
                ],
              ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('task-detail-checklist-add'),
              onPressed: widget.onChecklistChanged == null || _isSavingChecklist
                  ? null
                  : _addChecklistItem,
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
              latest.note.trim().isEmpty ? 'پیگیری' : latest.note.trim(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(_dateTime(latest.dateTime), style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '● ${_elapsedFormatter.since(latest.dateTime, now: now)}',
                    key: const ValueKey('task-detail-latest-followup-elapsed'),
                    style: const TextStyle(color: _brand, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
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
          _sectionTitle('مسیر پیگیری', Icons.timeline_outlined),
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
                  followUp.note.trim().isEmpty ? 'پیگیری' : followUp.note.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
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



  Widget _metadataChip(String label, Color color, {IconData icon = Icons.info_outline}) {
    return Container(
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

  Widget _metadataItem({required Key key, required String label, required String value, required Color color, required IconData icon}) {
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
            Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Vazirmatn', color: Color(0xFF232433), fontSize: 12, fontWeight: FontWeight.w700, height: 1.35)),
          ],
        ),
      ),
    );
  }

  Widget _statusPriorityCard() {
    final status = _task.trashed ? 'در سطل زباله' : _task.archived ? 'بایگانی‌شده' : _task.completed ? 'انجام‌شده' : 'در حال انجام';
    return Wrap(spacing: 7, runSpacing: 7, children: [
      PopupMenuButton<String>(
        key: const ValueKey('task-detail-status-menu'),
        tooltip: 'تغییر وضعیت کار',
        onSelected: (value) { if (value == 'toggle') _complete(); },
        itemBuilder: (_) => [PopupMenuItem(value: 'toggle', child: Text(_task.completed ? 'بازگشت به انجام‌نشده' : 'علامت‌گذاری به‌عنوان انجام‌شده'))],
        child: _metadataChip(status, _task.completed ? ArvinColors.tag : _brand, icon: Icons.check_circle_outline),
      ),
      PopupMenuButton<TaskPriority>(
        key: const ValueKey('task-detail-priority-menu'),
        tooltip: 'تغییر اولویت',
        onSelected: _changePriority,
        itemBuilder: (_) => TaskPriority.values.map((value) => PopupMenuItem(
          value: value,
          child: Text(value.label, style: TextStyle(color: ArvinColors.priorityColor(value))),
        )).toList(growable: false),
        child: _metadataChip(_task.priority.label, ArvinColors.priorityColor(_task.priority), icon: Icons.flag_outlined),
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
      key: const ValueKey('task-detail-template-source'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.copy_all_outlined, color: _brand),
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
    final center = widget.centerName?.trim();
    final project = widget.project;
    final items = <Widget>[
      _metadataItem(key: const ValueKey('task-detail-metadata-time'), label: 'زمان اجرا', value: 'ثبت نشده', color: _muted, icon: Icons.schedule_outlined),
      _metadataItem(key: const ValueKey('task-detail-metadata-center'), label: 'مرکز', value: center?.isNotEmpty == true ? center! : 'ثبت نشده', color: ArvinColors.category, icon: Icons.apartment_outlined),
      _metadataItem(key: const ValueKey('task-detail-metadata-project'), label: 'پروژه', value: project?.title.trim().isNotEmpty == true ? project!.title : 'ثبت نشده', color: project == null ? _muted : Color(project.colorValue), icon: Icons.folder_special_outlined),
      _metadataItem(key: const ValueKey('task-detail-metadata-category'), label: 'دسته', value: _task.category?.trim().isNotEmpty == true ? _task.category!.trim() : 'ثبت نشده', color: ArvinColors.category, icon: Icons.folder_outlined),
      _metadataItem(key: const ValueKey('task-detail-metadata-tags'), label: 'برچسب‌ها', value: _task.tags.isNotEmpty ? _task.tags.join('، ') : 'بدون برچسب', color: ArvinColors.tag, icon: Icons.sell_outlined),
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
    final hasLegacyReminder = _task.reminderDate != null;
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
                    ? (widget.onEdit == null ? null : _edit)
                    : _beginInlineEdit,
            icon: const Icon(Icons.add, size: 17),
            label: const Text('افزودن'),
          ),
        ]),
        if (reminders.isEmpty && !hasLegacyReminder)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('یادآوری ثبت نشده است', style: TextStyle(color: _muted)),
          ),
        if (hasLegacyReminder)
          ListTile(
            key: const ValueKey('task-detail-legacy-reminder'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_none_outlined, color: ArvinColors.reminder),
            title: const Text('یادآور اصلی'),
            subtitle: Text(_dateTime(_task.reminderDate!)),
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
              if (_isInlineEditing)
                IconButton(
                  key: ValueKey('task-detail-reminder-remove-${reminder.id}'),
                  tooltip: 'حذف یادآور',
                  onPressed: () => _removeDraftReminder(reminder),
                  icon: const Icon(Icons.delete_outline),
                ),
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
              onPressed: widget.onTaskChanged == null ? (widget.onEdit == null ? null : _edit) : (_isInlineEditing ? _saveInlineEdit : _beginInlineEdit),
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
              onPressed: _isSavingTaskTemplate ? null : _convertToTemplate,
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
              itemBuilder: (_) => const [
                PopupMenuItem(
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
                  child: ListTile(
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
          minimum: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              key: const ValueKey('task-detail-add-followup-bottom'),
              onPressed: _isInlineEditing || widget.onAddFollowUp == null
                  ? null
                  : _addFollowUp,
              style: OutlinedButton.styleFrom(
                foregroundColor: _brand,
                side: const BorderSide(color: _brand),
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
