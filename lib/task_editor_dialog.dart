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
    this.initialDueDate,
    this.projects = const [],
    this.selectedProjectId,
    this.onProjectChanged,
    this.knownCategories = const [],
  });

  final Task? task;
  final DateTime? initialDueDate;

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
    _dueDateTime = task?.dueDate ?? widget.initialDueDate;
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
          _dueDateTime != widget.initialDueDate ||
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
      padding: const EdgeInsets.all(14),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF303044),
                  ),
                ),
              ),
              if (value != null)
                IconButton(
                  key: ValueKey('$keyPrefix-clear'),
                  tooltip: 'پاک کردن',
                  visualDensity: VisualDensity.compact,
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _dateTimeButton(
                  key: ValueKey('$keyPrefix-date'),
                  label: 'تاریخ',
                  value: value == null ? 'انتخاب نشده' : _dateText(value),
                  icon: Icons.calendar_month_outlined,
                  onTap: onPickDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dateTimeButton(
                  key: ValueKey('$keyPrefix-time'),
                  label: 'ساعت',
                  value: value == null ? 'انتخاب نشده' : _timeText(value),
                  icon: Icons.schedule_outlined,
                  onTap: onPickTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recurrence = _recurrence;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestClose();
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _softBrand,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.task == null
                            ? Icons.add_task_outlined
                            : Icons.edit_note_outlined,
                        color: _brand,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task == null ? 'کار جدید' : 'ویرایش کار',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF232433),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'جزئیات اصلی کار را در همین فرم مدیریت کنید',
                            style: TextStyle(
                              color: Color(0xFF7B7D91),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('task-editor-close'),
                      tooltip: 'بستن',
                      onPressed: _requestClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  key: const ValueKey('task-editor-title'),
                  controller: _titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(
                    label: 'عنوان کار',
                    hint: 'مثلاً تماس با مشتری',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('task-editor-description'),
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: _fieldDecoration(
                    label: 'توضیحات',
                    hint: 'جزئیات کوتاه کار را بنویسید',
                  ),
                ),
                const SizedBox(height: 14),
                ProjectSelectorField(
                  projects: widget.projects,
                  selectedProjectId: _selectedProjectId,
                  onChanged: (value) => setState(() => _selectedProjectId = value),
                ),
                const SizedBox(height: 12),
                TaskCategoryField(
                  value: _category,
                  knownCategories: widget.knownCategories,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        key: const ValueKey('task-editor-priority'),
                        value: _priority,
                        decoration: _fieldDecoration(label: 'اولویت'),
                        items: [
                          for (final priority in TaskPriority.values)
                            DropdownMenuItem<TaskPriority>(
                              value: priority,
                              child: Text(_priorityLabel(priority)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _priority = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<RecurrenceFrequency?>(
                        key: const ValueKey('task-editor-recurrence'),
                        value: recurrence?.frequency,
                        decoration: _fieldDecoration(label: 'تکرار'),
                        items: <DropdownMenuItem<RecurrenceFrequency?>>[
                          const DropdownMenuItem<RecurrenceFrequency?>(
                            value: null,
                            child: Text('بدون تکرار'),
                          ),
                          ...RecurrenceFrequency.values.map(
                            (frequency) => DropdownMenuItem<RecurrenceFrequency?>(
                              value: frequency,
                              child: Text(_recurrenceLabel(frequency)),
                            ),
                          ),
                        ],
                        onChanged: (frequency) {
                          setState(() {
                            _recurrence = frequency == null
                                ? null
                                : RecurrenceRule(frequency: frequency);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _dateTimeEditor(
                  keyPrefix: 'task-editor-due',
                  title: 'تاریخ انجام کار',
                  value: _dueDateTime,
                  onPickDate: _pickDueDate,
                  onPickTime: _pickDueTime,
                  onClear: _clearDueTime,
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  key: const ValueKey('task-editor-follow-up-enabled'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: const Text(
                    'پیگیری',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('برای این کار زمان پیگیری جدا ثبت شود'),
                  value: _followUpEnabled,
                  onChanged: _setFollowUpEnabled,
                ),
                if (_followUpEnabled) ...[
                  const SizedBox(height: 4),
                  _dateTimeEditor(
                    keyPrefix: 'task-editor-followup',
                    title: 'زمان پیگیری',
                    value: _followUpDateTime,
                    onPickDate: _pickFollowUpDate,
                    onPickTime: _pickFollowUpTime,
                    onClear: _clearFollowUpTime,
                  ),
                ],
                const SizedBox(height: 12),
                _dateTimeEditor(
                  keyPrefix: 'task-editor-reminder',
                  title: 'یادآوری',
                  value: _reminderDateTime,
                  onPickDate: _pickReminderDate,
                  onPickTime: _pickReminderTime,
                  onClear: _clearReminderTime,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in _tags)
                      InputChip(
                        key: ValueKey('task-editor-tag-$tag'),
                        label: Text(tag),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      ),
                  ],
                ),
                if (_tags.isNotEmpty) const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('task-editor-tag-input'),
                        controller: _tagController,
                        onFieldSubmitted: (_) => _addTag(),
                        decoration: _fieldDecoration(
                          label: 'برچسب',
                          hint: 'مثلاً مهم',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      key: const ValueKey('task-editor-add-tag'),
                      tooltip: 'افزودن برچسب',
                      onPressed: _addTag,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  key: const ValueKey('task-editor-completed'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: const Text('انجام شده'),
                  value: _completed,
                  onChanged: (value) =>
                      setState(() => _completed = value ?? false),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('task-editor-save'),
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('ذخیره'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      key: const ValueKey('task-editor-cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('انصراف'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
