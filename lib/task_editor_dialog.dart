import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'arvin_colors.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'widgets/persian_date_picker.dart';
import 'widgets/arvin_roll_box.dart';

class ArvinTaskEditorDialog extends StatefulWidget {
  const ArvinTaskEditorDialog({
    super.key,
    this.task,
    this.initialDueDate,
    this.initialTitle,
    this.initialDescription,
    this.projects = const [],
    this.selectedProjectId,
    this.onProjectChanged,
    this.onCreateProject,
    this.knownCategories = const [],
    this.knownTags = const [],
    this.onCreateCategory,
    this.onCreateTag,
  });

  final Task? task;
  final DateTime? initialDueDate;
  final String? initialTitle;
  final String? initialDescription;

  /// First-class Projects remain independent from Task category and tags.
  /// The editor owns no Project persistence; callers persist the selected id
  /// through canonical ProjectPlan.itemIds after a successful Task save.
  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final ValueChanged<String?>? onProjectChanged;
  final Future<String?> Function(String title)? onCreateProject;

  /// Existing canonical Task categories offered as quick choices.
  final List<String> knownCategories;
  final List<String> knownTags;
  final Future<String?> Function(String name)? onCreateCategory;
  final Future<String?> Function(String name)? onCreateTag;

  @override
  State<ArvinTaskEditorDialog> createState() => _ArvinTaskEditorDialogState();
}

class _ArvinTaskEditorDialogState extends State<ArvinTaskEditorDialog> {
  static const _dateFormatter = PersianDateFormatter();
  static const _brand = ArvinColors.primary;
  static const _fieldSurface = ArvinColors.background;
  static const _border = ArvinColors.border;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  late final TextEditingController _checklistController;
  late final FocusNode _tagFocusNode;
  late final FocusNode _titleFocusNode;
  DateTime? _followUpDateTime;
  DateTime? _dueDateTime;
  DateTime? _reminderDateTime;
  late bool _followUpEnabled;
  late bool _completed;
  late List<String> _tags;
  late List<String> _checklist;
  late List<String> _knownCategories;
  late List<String> _knownTags;
  late String? _category;
  late String? _selectedProjectId;
  late RecurrenceRule? _recurrence;
  late final TextEditingController _recurrenceIntervalController;
  late TaskPriority _priority;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(
      text: task?.title ?? widget.initialTitle ?? '',
    );
    _descriptionController = TextEditingController(
      text: task?.description ?? widget.initialDescription ?? '',
    );
    _tagController = TextEditingController();
    _checklistController = TextEditingController();
    _tagFocusNode = FocusNode();
    _titleFocusNode = FocusNode();
    _followUpDateTime = task?.legacyHomeFollowUpDate;
    _dueDateTime = task?.dueDate ?? widget.initialDueDate;
    _reminderDateTime = task?.reminderDate;
    _followUpEnabled =
        task?.followUpEnabled == true ||
        (task?.followUps.isNotEmpty ?? false) ||
        task?.followUpDate != null;
    _completed = task?.completed ?? false;
    _tags = List<String>.of(task?.tags ?? const []);
    _checklist = List<String>.of(task?.checklist ?? const []);
    _knownCategories = List<String>.of(widget.knownCategories);
    _knownTags = List<String>.of(widget.knownTags);
    _category = task?.category;
    _selectedProjectId = widget.selectedProjectId;
    _recurrence = task?.recurrence;
    _recurrenceIntervalController = TextEditingController(
      text: '${task?.recurrence?.interval ?? 1}',
    );
    _priority = task?.priority ?? TaskPriority.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _checklistController.dispose();
    _recurrenceIntervalController.dispose();
    _tagFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFF232433), fontWeight: FontWeight.w600),
      floatingLabelStyle: const TextStyle(color: Color(0xFF232433), fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: Color(0xFF5F6072)),
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
    var hour = base.hour;
    var minute = base.minute;
    final formatter = _dateFormatter;

    final picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          child: SafeArea(
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final label = formatter.toPersianDigits(
                  '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                );
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        helpText,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(label, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      ArvinRollBox<int>(
                        label: 'ساعت',
                        valueLabel: 'ساعت ${formatter.toPersianDigits(hour.toString().padLeft(2, '0'))}',
                        icon: Icons.access_time_rounded,
                        color: ArvinColors.time,
                        items: List.generate(24, (value) => ArvinRollItem<int>(
                          value: value,
                          label: formatter.toPersianDigits(value.toString().padLeft(2, '0')),
                          icon: Icons.schedule_outlined,
                          color: ArvinColors.time,
                        )),
                        onSelected: (value) { if (value != null) setDialogState(() => hour = value); },
                      ),
                      const SizedBox(height: 10),
                      ArvinRollBox<int>(
                        label: 'دقیقه',
                        valueLabel: 'دقیقه ${formatter.toPersianDigits(minute.toString().padLeft(2, '0'))}',
                        icon: Icons.more_time_rounded,
                        color: ArvinColors.category,
                        items: List.generate(60, (value) => ArvinRollItem<int>(
                          value: value,
                          label: formatter.toPersianDigits(value.toString().padLeft(2, '0')),
                          icon: Icons.timelapse_outlined,
                          color: ArvinColors.category,
                        )),
                        onSelected: (value) { if (value != null) setDialogState(() => minute = value); },
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const ValueKey('task-editor-time-confirm'),
                          onPressed: () => Navigator.of(dialogContext).pop(TimeOfDay(hour: hour, minute: minute)),
                          child: const Text('ثبت ساعت'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (picked == null) return null;
    return DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
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

  Future<String?> _promptNewName(String title) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ArvinColors.surface,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'نام', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => Navigator.of(sheetContext).pop(controller.text.trim()), child: const Text('افزودن')),
          ]),
        ),
      ),
    );
    // The bottom-sheet route can still perform a final rebuild while its
    // closing animation is completing. Defer disposal so the TextField never
    // observes a controller that was disposed during that transition.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    return result?.trim().isEmpty == true ? null : result?.trim();
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
          _checklist.isNotEmpty ||
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

    final initialFollowUpEnabled =
        existing.followUpEnabled ||
        existing.followUps.isNotEmpty ||
        existing.followUpDate != null;
    return title != existing.title ||
        description != existing.description ||
        pendingTag.isNotEmpty ||
        !listEquals(_tags, existing.tags) ||
        !listEquals(_checklist, existing.checklist) ||
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

  static String _checklistLabel(String item) =>
      item.replaceFirst(RegExp(r'^\[(?:x| )\]\s*'), '');

  static bool _checklistChecked(String item) => item.trim().startsWith('[x]');

  static String _encodeChecklistItem(String label, bool checked) =>
      '[${checked ? 'x' : ' '}] ${label.trim()}';

  void _toggleChecklistItem(int index) {
    if (index < 0 || index >= _checklist.length) return;
    final label = _checklistLabel(_checklist[index]).trim();
    if (label.isEmpty) return;
    setState(() {
      _checklist[index] = _encodeChecklistItem(label, !_checklistChecked(_checklist[index]));
    });
  }

  void _moveChecklistItem(int index, int offset) {
    final target = index + offset;
    if (target < 0 || target >= _checklist.length) return;
    setState(() {
      final item = _checklist.removeAt(index);
      _checklist.insert(target, item);
    });
  }

  Future<void> _editChecklistItem(int index) async {
    if (index < 0 || index >= _checklist.length) return;
    final controller = TextEditingController(text: _checklistLabel(_checklist[index]));
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ویرایش مورد چک‌لیست'),
        content: TextField(
          key: const ValueKey('task-editor-checklist-edit-input'),
          controller: controller, autofocus: true, textDirection: TextDirection.rtl,
          decoration: const InputDecoration(labelText: 'عنوان مورد'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('لغو')),
          FilledButton(key: const ValueKey('task-editor-checklist-edit-save'), onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: const Text('ذخیره')),
        ],
      ),
    );
    // showDialog completes when the route is popped, while its exit animation can still rebuild
    // the dialog tree. Dispose only after that frame so the TextField cannot observe a disposed controller.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (!mounted || result == null || result.trim().isEmpty) return;
    setState(() {
      _checklist[index] = _encodeChecklistItem(result.trim(), _checklistChecked(_checklist[index]));
    });
  }

  void _addChecklistItem() {
    final label = _checklistController.text.trim();
    if (label.isEmpty) return;
    setState(() {
      _checklist.add(_encodeChecklistItem(label, false));
      _checklistController.clear();
    });
  }

  Widget _checklistEditor() {
    return Container(
      key: const ValueKey('task-editor-checklist-block'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFDDE3FF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Row(children: [Icon(Icons.checklist_rounded, color: _brand), SizedBox(width: 8), Text('چک‌لیست', style: TextStyle(color: _brand, fontWeight: FontWeight.w800, fontSize: 16))]),
        const SizedBox(height: 4),
        const Text('مواردی که باید برای این کار یکی‌یکی انجام شوند.'),
        const SizedBox(height: 10),
        if (_checklist.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('هنوز موردی اضافه نشده.'))
        else
          ...List.generate(_checklist.length, (index) {
            final item = _checklist[index];
            final checked = _checklistChecked(item);
            return Container(
              key: ValueKey('task-editor-checklist-item-$index'),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
              child: Row(children: [
                Checkbox(key: ValueKey('task-editor-checklist-check-$index'), value: checked, onChanged: (_) => _toggleChecklistItem(index)),
                Expanded(child: Text(_checklistLabel(item), style: TextStyle(decoration: checked ? TextDecoration.lineThrough : null, color: checked ? const Color(0xFF77778A) : const Color(0xFF232433), fontWeight: FontWeight.w600))),
                IconButton(key: ValueKey('task-editor-checklist-edit-$index'), tooltip: 'ویرایش', icon: const Icon(Icons.edit_outlined, size: 19), onPressed: () => _editChecklistItem(index)),
                IconButton(key: ValueKey('task-editor-checklist-up-$index'), tooltip: 'بالا', icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20), onPressed: index == 0 ? null : () => _moveChecklistItem(index, -1)),
                IconButton(key: ValueKey('task-editor-checklist-down-$index'), tooltip: 'پایین', icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20), onPressed: index == _checklist.length - 1 ? null : () => _moveChecklistItem(index, 1)),
                IconButton(key: ValueKey('task-editor-checklist-delete-$index'), tooltip: 'حذف', icon: const Icon(Icons.delete_outline, size: 19), onPressed: () => setState(() => _checklist.removeAt(index))),
              ]),
            );
          }),
        Row(children: [
          Expanded(child: TextField(key: const ValueKey('task-editor-checklist-input'), controller: _checklistController, textDirection: TextDirection.rtl, textInputAction: TextInputAction.done, onSubmitted: (_) => _addChecklistItem(), decoration: _fieldDecoration(label: 'مورد جدید', hint: 'مثلاً کیف'))),
          const SizedBox(width: 8),
          IconButton.filled(key: const ValueKey('task-editor-checklist-add'), tooltip: 'افزودن مورد', onPressed: _addChecklistItem, icon: const Icon(Icons.add)),
        ]),
      ]),
    );
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
        checklist: List<String>.of(_checklist),
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
    RecurrenceFrequency.minutes => 'دقیقه‌ای',
    RecurrenceFrequency.hours => 'ساعتی',
  };

  Widget _dateTimeRollBox({
    required String keyPrefix,
    required String label,
    required DateTime? value,
    required bool isDate,
    required String target,
    required VoidCallback onCustom,
    required Color accent,
  }) {
    final now = _baseDateTime(null);
    final base = value ?? now;
    final items = isDate
        ? <ArvinRollItem<String>>[
            ArvinRollItem<String>(value: 'today', label: 'امروز', icon: Icons.today_outlined, color: accent),
            ArvinRollItem<String>(value: 'tomorrow', label: 'فردا', icon: Icons.event_available_outlined, color: accent),
          ]
        : <ArvinRollItem<String>>[
            for (final minutes in const [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, 390, 420, 450, 480, 510, 540, 570, 600, 630, 660, 690, 720, 750, 780, 810, 840, 870, 900, 930, 960, 990, 1020, 1050, 1080, 1110, 1140, 1170, 1200, 1230, 1260, 1290, 1320, 1350, 1380, 1410])
              ArvinRollItem<String>(
                value: '$minutes',
                label: _timeText(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60)),
                icon: Icons.schedule_outlined,
                color: accent,
              ),
          ];
    final currentLabel = isDate ? _dateText(base) : _timeText(base);
    return KeyedSubtree(
      key: ValueKey('$keyPrefix-rollbox'),
      child: ArvinRollBox<String>(
        label: label,
        valueLabel: value == null ? 'انتخاب $label' : currentLabel,
        icon: isDate ? Icons.calendar_month_outlined : Icons.schedule_outlined,
        color: accent,
        items: items,
        onSelected: (selection) {
          if (selection == null) return;
          if (isDate) {
            final picked = selection == 'today' ? now : DateTime(now.year, now.month, now.day + 1, now.hour, now.minute);
            setState(() {
              if (target.contains('reminder')) {
                _reminderDateTime = DateTime(picked.year, picked.month, picked.day, base.hour, base.minute);
              } else if (target.contains('follow-up') || target.contains('followup')) {
                _followUpDateTime = DateTime(picked.year, picked.month, picked.day, base.hour, base.minute);
              } else {
                _dueDateTime = DateTime(picked.year, picked.month, picked.day, base.hour, base.minute);
              }
            });
          } else {
            final minutes = int.tryParse(selection) ?? 0;
            setState(() {
              final next = DateTime(base.year, base.month, base.day, minutes ~/ 60, minutes % 60);
              if (target.contains('reminder')) {
                _reminderDateTime = next;
              } else if (target.contains('follow-up')) {
                _followUpDateTime = next;
              } else {
                _dueDateTime = next;
              }
            });
          }
        },
        onCreate: () async {
          onCustom();
          return null;
        },
        createLabel: isDate ? 'تاریخ سفارشی' : 'ساعت سفارشی',
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
    Color accent = ArvinColors.primary,
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
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
              if (value != null)
                TextButton.icon(
                  key: ValueKey('$keyPrefix-clear'),
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('حذف'),
                  style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 4), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _dateTimeRollBox(keyPrefix: '$keyPrefix-date', label: 'تاریخ', value: value, isDate: true, target: keyPrefix, onCustom: onPickDate, accent: accent)),
              const SizedBox(width: 10),
              Expanded(child: _dateTimeRollBox(keyPrefix: '$keyPrefix-time', label: 'ساعت', value: value, isDate: false, target: keyPrefix, onCustom: onPickTime, accent: accent)),
            ],
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: Dialog.fullscreen(
        key: const ValueKey('arvin-task-editor-dialog'),
        backgroundColor: const Color(0xFFF8F8FB),
        child: SafeArea(
          child: Material(
            color: const Color(0xFFF8F8FB),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFDFE),
                    border: Border(bottom: BorderSide(color: _border)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        key: const ValueKey('task-editor-close'),
                        tooltip: 'بستن',
                        onPressed: _requestClose,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('ویرایش کار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('task-editor-header-save'),
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('ذخیره'),
                        style: FilledButton.styleFrom(backgroundColor: _brand, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 2),
                  TextField(
                    key: const ValueKey('task-editor-title'),
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    autofocus: !editing,
                    style: const TextStyle(color: Color(0xFF232433), fontWeight: FontWeight.w600),
                    cursorColor: _brand,
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
                    style: const TextStyle(color: Color(0xFF232433)),
                    cursorColor: _brand,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _fieldDecoration(
                      label: 'توضیحات',
                      hint: 'توضیحات را وارد کنید…',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ArvinRollBox<String>(
                          label: 'دسته',
                          valueLabel: _category?.trim().isNotEmpty == true ? _category!.trim() : 'دسته',
                          icon: Icons.grid_view_rounded,
                          color: ArvinColors.category,
                          emptyLabel: 'بدون دسته',
                          items: _knownCategories.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet().toList()
                              .map((value) => ArvinRollItem<String>(value: value, label: value, icon: Icons.grid_view_rounded, color: ArvinColors.category)).toList(),
                          onSelected: (value) => setState(() => _category = value),
                          onCreate: () async {
                            final value = await _promptNewName('دسته جدید');
                            if (value == null) return null;
                            final created = await widget.onCreateCategory?.call(value) ?? value;
                            if (!mounted) return created;
                            setState(() {
                              _category = created;
                              if (!_knownCategories.contains(created)) _knownCategories.add(created);
                            });
                            return created;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ArvinRollBox<String>(
                          label: 'پروژه',
                          valueLabel: _selectedProjectId == null ? 'پروژه' : widget.projects.where((p) => p.id == _selectedProjectId).map((p) => p.title).isEmpty ? 'پروژه' : widget.projects.where((p) => p.id == _selectedProjectId).map((p) => p.title).first,
                          icon: Icons.folder_outlined,
                          color: ArvinColors.project,
                          emptyLabel: 'بدون پروژه',
                          items: widget.projects.where((project) => !project.isArchived || project.id == _selectedProjectId).map((project) => ArvinRollItem<String>(
                            value: project.id,
                            label: project.isArchived ? '${project.title} (بایگانی‌شده)' : project.title,
                            icon: Icons.folder_outlined,
                            color: project.isArchived ? ArvinColors.neutral : ArvinColors.project,
                          )).toList(),
                          onSelected: (value) => setState(() => _selectedProjectId = value),
                          onCreate: () async {
                            final title = await _promptNewName('پروژه جدید');
                            if (title == null || widget.onCreateProject == null) return null;
                            return widget.onCreateProject!(title);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ArvinTagRollBox(
                          tags: _knownTags,
                          selectedTags: _tags,
                          onChanged: (value) => setState(() => _tags = List<String>.of(value)),
                          onCreate: () async {
                            final value = await _promptNewName('برچسب جدید');
                            if (value == null) return null;
                            final created = await widget.onCreateTag?.call(value) ?? value;
                            if (!mounted) return created;
                            setState(() {
                              if (!_tags.contains(created)) _tags.add(created);
                              if (!_knownTags.contains(created)) _knownTags.add(created);
                            });
                            return created;
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _tags.map((tag) => InputChip(
                        label: Text(tag),
                        backgroundColor: ArvinColors.tagSoft,
                        side: BorderSide.none,
                        deleteIconColor: ArvinColors.tagDark,
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),                  ExpansionTile(
                    key: const ValueKey('task-editor-more-details'),
                    initiallyExpanded: true,
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
                        accent: ArvinColors.time,
                      ),
                      const SizedBox(height: 10),
                      _dateTimeEditor(
                        keyPrefix: 'task-editor-reminder',
                        title: 'یادآوری',
                        value: _reminderDateTime,
                        onPickDate: _pickReminderDate,
                        onPickTime: _pickReminderTime,
                        onClear: _clearReminderTime,
                        accent: ArvinColors.reminder,
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final recurrence = ArvinRollBox<RecurrenceFrequency>(
                            key: const ValueKey('task-editor-recurrence'),
                            label: 'تکرار',
                            valueLabel: _recurrence == null
                                ? 'بدون تکرار'
                                : _recurrenceLabel(_recurrence!.frequency),
                            icon: Icons.repeat_rounded,
                            color: ArvinColors.primary,
                            emptyLabel: 'بدون تکرار',
                            items: RecurrenceFrequency.values
                                .map(
                                  (frequency) => ArvinRollItem<RecurrenceFrequency>(
                                    value: frequency,
                                    label: _recurrenceLabel(frequency),
                                    icon: Icons.repeat_rounded,
                                    color: ArvinColors.primary,
                                  ),
                                )
                                .toList(growable: false),
                            onSelected: (frequency) {
                              final interval =
                                  int.tryParse(_recurrenceIntervalController.text.trim()) ?? 1;
                              setState(() {
                                _recurrence = frequency == null
                                    ? null
                                    : RecurrenceRule(
                                        frequency: frequency,
                                        interval: interval > 0 ? interval : 1,
                                      );
                              });
                            },
                          );
                          final recurrenceInterval = TextFormField(
                            key: const ValueKey('task-editor-recurrence-interval'),
                            controller: _recurrenceIntervalController,
                            enabled: _recurrence != null,
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.rtl,
                            decoration: _fieldDecoration(
                              label: 'تعداد فاصله',
                              hint: 'مثلاً ۵',
                            ),
                            onChanged: (value) {
                              final interval = int.tryParse(value.trim());
                              if (_recurrence == null || interval == null || interval < 1) {
                                return;
                              }
                              setState(() {
                                _recurrence = RecurrenceRule(
                                  frequency: _recurrence!.frequency,
                                  interval: interval,
                                );
                              });
                            },
                          );
                          final priority = DropdownButtonFormField<TaskPriority>(
                            key: const ValueKey('task-editor-priority'),
                            isExpanded: true,
                            initialValue: _priority,
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
                          );
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: recurrence),
                                    if (_recurrence != null) ...[
                                      const SizedBox(width: 10),
                                      SizedBox(width: 120, child: recurrenceInterval),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                                priority,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: recurrence),
                              if (_recurrence != null) ...[
                                const SizedBox(width: 10),
                                SizedBox(width: 120, child: recurrenceInterval),
                              ],
                              const SizedBox(width: 10),
                              Expanded(child: priority),
                            ],
                          );
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
                  _checklistEditor(),
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
                                  key: const ValueKey(
                                    'task-editor-clear-followup',
                                  ),
                                  onPressed: _clearFollowUpTime,
                                  icon: const Icon(Icons.close, size: 17),
                                  label: const Text('حذف زمان'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _dateTimeEditor(
                            keyPrefix: 'task-editor-followup',
                            title: 'زمان پیگیری',
                            value: followUp,
                            onPickDate: _pickFollowUpDate,
                            onPickTime: _pickFollowUpTime,
                            onClear: _clearFollowUpTime,
                            accent: ArvinColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
      ],
    ),
  ),
  ),
  ),
  );
  }
}