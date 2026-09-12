import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'widgets/persian_date_picker.dart';
import 'widgets/project_selector_field.dart';
import 'widgets/task_category_field.dart';

class ArvinTaskEditorDialog extends StatefulWidget {
  const ArvinTaskEditorDialog({
    super.key,
    this.task,
    this.projects = const [],
    this.selectedProjectId,
    this.onProjectChanged,
    this.knownCategories = const [],
  });

  final Task? task;

  /// First-class Projects remain independent from Task category and tags.
  /// The editor owns no Project persistence; callers persist the selected id
  /// through canonical ProjectPlan.itemIds after a successful Task save.
  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final ValueChanged<String?>? onProjectChanged;

  /// Existing canonical Task categories offered as quick choices.
  final List<String> knownCategories;

  @override
  State<ArvinTaskEditorDialog> createState() => _ArvinTaskEditorDialogState();
}

class _ArvinTaskEditorDialogState extends State<ArvinTaskEditorDialog> {
  static const _dateFormatter = PersianDateFormatter();
  static const _brand = Color(0xFF4A4CAB);
  static const _softBrand = Color(0xFFF0EFFF);
  static const _fieldSurface = Color(0xFFF8F8FC);
  static const _border = Color(0xFFE4E4EF);

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  DateTime? _followUpDateTime;
  DateTime? _dueDateTime;
  DateTime? _reminderDateTime;
  late bool _followUpEnabled;
  late bool _completed;
  late List<String> _tags;
  late String? _category;
  late String? _selectedProjectId;
  late RecurrenceRule? _recurrence;
  late TaskPriority _priority;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _tagController = TextEditingController();
    _followUpDateTime = task?.legacyHomeFollowUpDate;
    _dueDateTime = task?.dueDate;
    _reminderDateTime = task?.reminderDate;
    _followUpEnabled = task?.followUpEnabled == true ||
        (task?.followUps.isNotEmpty ?? false) ||
        task?.followUpDate != null;
    _completed = task?.completed ?? false;
    _tags = List<String>.of(task?.tags ?? const []);
    _category = task?.category;
    _selectedProjectId = widget.selectedProjectId;
    _recurrence = task?.recurrence;
    _priority = task?.priority ?? TaskPriority.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _fieldSurface,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _brand, width: 1.5),
      ),
    );
  }

  DateTime _baseDateTime(DateTime? current) {
    if (current != null) return current;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  Future<DateTime?> _chooseDate(
    DateTime? current, {
    required String helpText,
  }) async {
    final base = _baseDateTime(current);
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: helpText,
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
    if (picked == null) return null;
    return DateTime(
      picked.year,
      picked.month,
      picked.day,
      base.hour,
      base.minute,
    );
  }

  Future<DateTime?> _chooseTime(
    DateTime? current, {
    required String helpText,
  }) async {
    final base = _baseDateTime(current);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      helpText: helpText,
      cancelText: 'لغو',
      confirmText: 'تأیید',
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _brand,
                ),
          ),
          child: child!,
        ),
      ),
    );
    if (picked == null) return null;
    return DateTime(
      base.year,
      base.month,
      base.day,
      picked.hour,
      picked.minute,
    );
  }

  void _setFollowUpEnabled(bool value) {
    setState(() {
      _followUpEnabled = value;
      if (value && _followUpDateTime == null) {
        _followUpDateTime = _baseDateTime(null);
      }
    });
  }

  Future<void> _pickFollowUpDate() async {
    final value = await _chooseDate(
      _followUpDateTime,
      helpText: 'انتخاب تاریخ پیگیری',
    );
    if (value != null && mounted) setState(() => _followUpDateTime = value);
  }

  Future<void> _pickFollowUpTime() async {
    final value = await _chooseTime(
      _followUpDateTime,
      helpText: 'انتخاب ساعت پیگیری',
    );
    if (value != null && mounted) setState(() => _followUpDateTime = value);
  }

  Future<void> _pickDueDate() async {
    final value = await _chooseDate(
      _dueDateTime,
      helpText: 'انتخاب تاریخ انجام کار',
    );
    if (value != null && mounted) setState(() => _dueDateTime = value);
  }

  Future<void> _pickDueTime() async {
    final value = await _chooseTime(
      _dueDateTime,
      helpText: 'انتخاب ساعت انجام کار',
    );
    if (value != null && mounted) setState(() => _dueDateTime = value);
  }

  Future<void> _pickReminderDate() async {
    final value = await _chooseDate(
      _reminderDateTime,
      helpText: 'انتخاب تاریخ یادآوری',
    );
    if (value != null && mounted) setState(() => _reminderDateTime = value);
  }

  Future<void> _pickReminderTime() async {
    final value = await _chooseTime(
      _reminderDateTime,
      helpText: 'انتخاب ساعت یادآوری',
    );
    if (value != null && mounted) setState(() => _reminderDateTime = value);
  }

  void _clearFollowUpTime() => setState(() => _followUpDateTime = null);
  void _clearDueTime() => setState(() => _dueDateTime = null);
  void _clearReminderTime() => setState(() => _reminderDateTime = null);

  void _addTag() {
    final value = _tagController.text.trim();
    if (value.isEmpty || _tags.contains(value)) return;
    setState(() {
      _tags.add(value);
      _tagController.clear();
    });
  }

  bool _sameRecurrence(RecurrenceRule? a, RecurrenceRule? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    return a.frequency == b.frequency && a.interval == b.interval;
  }

  bool get _hasChanges {
    final existing = widget.task;
    final title = _titleController.text;
    final description = _descriptionController.text;
    final pendingTag = _tagController.text.trim();

    if (existing == null) {
      return title.trim().isNotEmpty ||
          description.trim().isNotEmpty ||
          pendingTag.isNotEmpty ||
          _tags.isNotEmpty ||
          _category != null ||
          _selectedProjectId != widget.selectedProjectId ||
          _followUpEnabled ||
          _followUpDateTime != null ||
          _dueDateTime != null ||
          _reminderDateTime != null ||
          _recurrence != null ||
          _priority != TaskPriority.none ||
          _completed;
    }

    final initialFollowUpEnabled = existing.followUpEnabled ||
        existing.followUps.isNotEmpty ||
        existing.followUpDate != null;
    return title != existing.title ||
        description != existing.description ||
        pendingTag.isNotEmpty ||
        !listEquals(_tags, existing.tags) ||
        _category != existing.category ||
        _selectedProjectId != widget.selectedProjectId ||
        _followUpEnabled != initialFollowUpEnabled ||
        _followUpDateTime != existing.legacyHomeFollowUpDate ||
        _dueDateTime != existing.dueDate ||
        _reminderDateTime != existing.reminderDate ||
        !_sameRecurrence(_recurrence, existing.recurrence) ||
        _priority != existing.priority ||
        _completed != existing.completed;
  }

  Future<void> _requestClose() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تغییرات ذخیره نشده'),
        content: const Text(
          'برای جلوگیری از از دست رفتن اطلاعات، تغییرات را ذخیره کنید یا صریحاً بدون ذخیره خارج شوید.',
        ),
        actions: [
          TextButton(
            key: const ValueKey('task-editor-exit-continue'),
            onPressed: () => Navigator.of(dialogContext).pop('continue'),
            child: const Text('ادامه ویرایش'),
          ),
          TextButton(
            key: const ValueKey('task-editor-exit-discard'),
            onPressed: () => Navigator.of(dialogContext).pop('discard'),
            child: const Text('بدون ذخیره'),
          ),
          FilledButton(
            key: const ValueKey('task-editor-exit-save'),
            onPressed: () => Navigator.of(dialogContext).pop('save'),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'discard') {
      Navigator.of(context).pop();
    } else if (action == 'save') {
      _save();
    }
  }

  void _save() {
    if (_saving) return;
    _saving = true;
    final pendingTag = _tagController.text.trim();
    if (pendingTag.isNotEmpty && !_tags.contains(pendingTag)) {
      _tags.add(pendingTag);
    }
    final now = DateTime.now();
    final existing = widget.task;
    final id = existing?.id ?? now.microsecondsSinceEpoch.toString();
    widget.onProjectChanged?.call(_selectedProjectId);
    Navigator.of(context).pop(
      Task(
        id: id,
        title: _titleController.text.trim().isEmpty
            ? 'بدون عنوان'
            : _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDateTime,
        followUpEnabled: _followUpEnabled,
        followUpDate: _followUpEnabled ? _followUpDateTime : null,
        tags: List<String>.of(_tags),
        category: _category,
        checklist: List<String>.of(existing?.checklist ?? const []),
        reminderDate: _reminderDateTime,
        priority: _priority,
        archived: existing?.archived ?? false,
        trashed: existing?.trashed ?? false,
        completed: _completed,
        followUps: List<FollowUp>.of(existing?.followUps ?? const []),
        recurrence: _recurrence,
        people: existing?.people ?? const [],
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  String _dateText(DateTime value) =>
      _dateFormatter.format(value, usePersianDate: true);

  String _timeText(DateTime value) {
    final raw =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return _dateFormatter.toPersianDigits(raw);
  }

  String _priorityLabel(TaskPriority priority) => switch (priority) {
        TaskPriority.none => 'بدون اولویت',
        TaskPriority.low => 'کم',
        TaskPriority.medium => 'متوسط',
        TaskPriority.high => 'زیاد',
      };

  String _recurrenceLabel(RecurrenceFrequency frequency) => switch (frequency) {
        RecurrenceFrequency.daily => 'روزانه',
        RecurrenceFrequency.weekly => 'هفتگی',
        RecurrenceFrequency.monthly => 'ماهانه',
        RecurrenceFrequency.yearly => 'سالانه',
        RecurrenceFrequency.oncePerDay => 'روزی یک‌بار',
      };

  Widget _dateTimeButton({
    required Key key,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _softBrand,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: _brand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF77778A),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateTimeEditor({
    required String keyPrefix,
    required String title,
    required DateTime? value,
    required VoidCallback onPickDate,
    required VoidCallback onPickTime,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _fieldSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (value != null)
                TextButton.icon(
                  key: ValueKey('$keyPrefix-clear'),
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 17),
                  label: const Text('حذف'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final dateButton = _dateTimeButton(
                key: ValueKey('$keyPrefix-date'),
                label: 'تاریخ',
                value: value == null ? 'انتخاب تاریخ' : _dateText(value),
                icon: Icons.calendar_month_outlined,
                onTap: onPickDate,
              );
              final timeButton = _dateTimeButton(
                key: ValueKey('$keyPrefix-time'),
                label: 'ساعت',
                value: value == null ? 'انتخاب ساعت' : _timeText(value),
                icon: Icons.schedule_outlined,
                onTap: onPickTime,
              );
              if (constraints.maxWidth < 320) {
                return Column(
                  children: [
                    dateButton,
                    const SizedBox(height: 10),
                    timeButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: dateButton),
                  const SizedBox(width: 10),
                  Expanded(child: timeButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    final followUp = _followUpDateTime;
    final hasHistory = widget.task?.followUps.isNotEmpty ?? false;
    final hasExistingDetails = widget.task != null &&
        (_dueDateTime != null ||
            _reminderDateTime != null ||
            _recurrence != null ||
            _priority != TaskPriority.none ||
            _completed);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: Dialog(
        key: const ValueKey('arvin-task-editor-dialog'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Material(
            color: const Color(0xFFFDFDFF),
            elevation: 10,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing ? 'ویرایش کار' : 'کار جدید',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF242438),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'بستن',
                        onPressed: _requestClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    key: const ValueKey('task-editor-title'),
                    controller: _titleController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    decoration: _fieldDecoration(
                      label: 'عنوان',
                      hint: 'عنوان کار را بنویسید',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const ValueKey('task-editor-description'),
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _fieldDecoration(
                      label: 'توضیحات',
                      hint: 'توضیحات را وارد کنید…',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TaskCategoryField(
                    value: _category,
                    knownCategories: widget.knownCategories,
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  if (widget.projects.isNotEmpty || _selectedProjectId != null) ...[
                    const SizedBox(height: 16),
                    ProjectSelectorField(
                      projects: widget.projects,
                      selectedProjectId: _selectedProjectId,
                      onChanged: (value) =>
                          setState(() => _selectedProjectId = value),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('task-editor-tag'),
                          controller: _tagController,
                          onSubmitted: (_) => _addTag(),
                          decoration: _fieldDecoration(
                            label: 'برچسب',
                            hint: 'مثلاً مشتری، جلسه، مهم',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: FilledButton(
                          key: const ValueKey('task-editor-add-tag'),
                          onPressed: _addTag,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: _softBrand,
                            foregroundColor: _brand,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map(
                            (item) => InputChip(
                              label: Text(item),
                              backgroundColor: _softBrand,
                              side: BorderSide.none,
                              deleteIconColor: _brand,
                              onDeleted: () =>
                                  setState(() => _tags.remove(item)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ExpansionTile(
                    key: const ValueKey('task-editor-more-details'),
                    initiallyExpanded: hasExistingDetails,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    title: const Text(
                      'جزئیات بیشتر',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'تاریخ انجام، یادآوری، تکرار، اولویت و وضعیت',
                    ),
                    children: [
                      _dateTimeEditor(
                        keyPrefix: 'task-editor-due',
                        title: 'تاریخ انجام',
                        value: _dueDateTime,
                        onPickDate: _pickDueDate,
                        onPickTime: _pickDueTime,
                        onClear: _clearDueTime,
                      ),
                      const SizedBox(height: 10),
                      _dateTimeEditor(
                        keyPrefix: 'task-editor-reminder',
                        title: 'یادآوری',
                        value: _reminderDateTime,
                        onPickDate: _pickReminderDate,
                        onPickTime: _pickReminderTime,
                        onClear: _clearReminderTime,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<RecurrenceFrequency>(
                        key: const ValueKey('task-editor-recurrence'),
                        value: _recurrence?.frequency,
                        decoration: _fieldDecoration(label: 'تکرار'),
                        items: [
                          const DropdownMenuItem<RecurrenceFrequency>(
                            value: null,
                            child: Text('بدون تکرار'),
                          ),
                          ...RecurrenceFrequency.values.map(
                            (frequency) => DropdownMenuItem<RecurrenceFrequency>(
                              value: frequency,
                              child: Text(_recurrenceLabel(frequency)),
                            ),
                          ),
                        ],
                        onChanged: (frequency) {
                          setState(() {
                            _recurrence = frequency == null
                                ? null
                                : RecurrenceRule(
                                    frequency: frequency,
                                    interval: _recurrence?.interval ?? 1,
                                  );
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<TaskPriority>(
                        key: const ValueKey('task-editor-priority'),
                        value: _priority,
                        decoration: _fieldDecoration(label: 'اولویت'),
                        items: TaskPriority.values
                            .map(
                              (priority) => DropdownMenuItem<TaskPriority>(
                                value: priority,
                                child: Text(_priorityLabel(priority)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (priority) {
                          if (priority != null) {
                            setState(() => _priority = priority);
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      CheckboxListTile(
                        key: const ValueKey('task-editor-completed'),
                        value: _completed,
                        onChanged: (value) =>
                            setState(() => _completed = value ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('انجام‌شده'),
                        subtitle: const Text('وضعیت فعلی این کار'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    key: const ValueKey('task-editor-followup-block'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8E6F7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            key: const ValueKey('task-editor-followup-enabled'),
                            value: _followUpEnabled,
                            onChanged: (value) =>
                                _setFollowUpEnabled(value ?? false),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: _brand,
                            title: const Text(
                              'کار پیگیری‌دار',
                              style: TextStyle(
                                color: _brand,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: const Text(
                              'برای این کار زمان و سابقهٔ پیگیری نگه‌داری می‌شود',
                            ),
                          ),
                        ),
                        if (!_followUpEnabled && hasHistory)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 6),
                            child: Text(
                              'سوابق پیگیری قبلی حفظ می‌شوند.',
                              style: TextStyle(
                                color: Color(0xFF77778A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (_followUpEnabled) ...[
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'زمان پیگیری',
                                  style: TextStyle(
                                    color: Color(0xFF77778A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (followUp != null)
                                TextButton.icon(
                                  key: const ValueKey('task-editor-clear-followup'),
                                  onPressed: _clearFollowUpTime,
                                  icon: const Icon(Icons.close, size: 17),
                                  label: const Text('حذف زمان'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final dateButton = _dateTimeButton(
                                key: const ValueKey('task-editor-date'),
                                label: 'تاریخ',
                                value: followUp == null
                                    ? 'انتخاب تاریخ'
                                    : _dateText(followUp),
                                icon: Icons.calendar_month_outlined,
                                onTap: _pickFollowUpDate,
                              );
                              final timeButton = _dateTimeButton(
                                key: const ValueKey('task-editor-time'),
                                label: 'ساعت',
                                value: followUp == null
                                    ? 'انتخاب ساعت'
                                    : _timeText(followUp),
                                icon: Icons.schedule_outlined,
                                onTap: _pickFollowUpTime,
                              );

                              if (constraints.maxWidth < 320) {
                                return Column(
                                  children: [
                                    dateButton,
                                    const SizedBox(height: 10),
                                    timeButton,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: dateButton),
                                  const SizedBox(width: 10),
                                  Expanded(child: timeButton),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          key: const ValueKey('task-editor-save'),
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'ذخیره',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          key: const ValueKey('task-editor-cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: _brand,
                          ),
                          child: const Text('لغو'),
                        ),
                      ),
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
