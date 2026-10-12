import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/quick_capture_service.dart';
import 'widgets/arvin_roll_box.dart';
import 'widgets/universal_arvin_time_picker.dart';

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
  String? _draftId;
  TaskPriority _priority = TaskPriority.none;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  bool _reminderFollowsDueTime = true;
  RecurrenceRule? _recurrence;
  final TextEditingController _recurrenceIntervalController =
      TextEditingController(text: '1');
  String? _projectId;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
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
    _draftId ??= widget.idFactory?.call() ?? createdAt.microsecondsSinceEpoch.toString();
    final task = widget.service.capture(
      _controller.text,
      id: _draftId!,
      createdAt: createdAt,
    );
    if (task == null) return null;
    task.priority = _priority;
    _syncAutomaticReminder();
    task.dueDate = _dueDate;
    task.reminderDate = _reminderDate;
    task.recurrence = _recurrence;
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
      _draftId = null;
      setState(() {
        _saving = false;
        _priority = TaskPriority.none;
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
        _draftId = null;
        _priority = TaskPriority.none;
      }
      setState(() => _saving = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'باز کردن جزئیات بیشتر انجام نشد؛ متن و انتخاب‌ها حفظ شدند';
      });
    }
  }

  String _dateLabel(DateTime? value) {
    if (value == null) return 'بدون موعد';
    final formatter = const PersianDateFormatter();
    final date = formatter.format(value, usePersianDate: true);
    return '$date • ${_timeLabel(value)}';
  }

  String _weekdayLabel(DateTime value) {
    const weekdays = <int, String>{
      DateTime.monday: 'دوشنبه',
      DateTime.tuesday: 'سه‌شنبه',
      DateTime.wednesday: 'چهارشنبه',
      DateTime.thursday: 'پنجشنبه',
      DateTime.friday: 'جمعه',
      DateTime.saturday: 'شنبه',
      DateTime.sunday: 'یکشنبه',
    };
    return weekdays[value.weekday]!;
  }

  String _relativeDateLabel(DateTime? value) {
    if (value == null) return 'بدون تاریخ';
    final now = _now();
    final selectedDay = DateTime.utc(value.year, value.month, value.day);
    final currentDay = DateTime.utc(now.year, now.month, now.day);
    final dayOffset = selectedDay.difference(currentDay).inDays;
    if (dayOffset == 0) return 'امروز، ${_weekdayLabel(value)}';
    if (dayOffset == 1) return 'فردا، ${_weekdayLabel(value)}';
    final formatter = const PersianDateFormatter();
    return '${formatter.format(value, usePersianDate: true)}، ${_weekdayLabel(value)}';
  }

  String _timeLabel(DateTime value) {
    final formatter = const PersianDateFormatter();
    return formatter.toPersianDigits('${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}');
  }

  String _recurrenceContextLabel() {
    if (_recurrence == null) return 'بدون تکرار';
    final anchor = _dueDate;
    if (anchor == null) return _recurrenceLabel();
    return '${_recurrenceLabel()} • ${_relativeDateLabel(anchor)}، ${_timeLabel(anchor)}';
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
    final date = await _pickJalaliDate(context, initialDate: initial);
    if (date == null || !mounted) return null;
    final time = await _pickPersianTime(context, initial: initial, helpText: 'زمان انجام کار');
    if (time == null || !mounted) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DateTime?> _pickCustomReminder() async {
    final initial = _reminderDate ?? _dueDate ?? widget.now?.call() ?? DateTime.now();
    final date = await _pickJalaliDate(context, initialDate: initial);
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
                    color: const Color(0xFF4A4CAB),
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
  Future<DateTime?> _pickJalaliDate(
    BuildContext parentContext, {
    required DateTime initialDate,
  }) async {
    final formatter = const PersianDateFormatter();
    final initial = formatter.toJalali(initialDate);
    return showDialog<DateTime>(
      context: parentContext,
      builder: (sheetContext) {
        var year = initial.year;
        var month = initial.month;
        var selectedDay = initial.day;
        final clockNow = widget.now?.call() ?? DateTime.now();
        final today = DateTime(clockNow.year, clockNow.month, clockNow.day);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final monthLength = formatter.monthLength(year, month);
            if (selectedDay > monthLength) { selectedDay = monthLength; }
            final firstGregorian = formatter.fromJalali(JalaliDate(year, month, 1));
            final firstWeekday = firstGregorian.weekday % 7;
            final days = List<int?>.filled(firstWeekday, null, growable: true)..addAll(List<int>.generate(monthLength, (i) => i + 1));
            DateTime selectedDate() => formatter.fromJalali(JalaliDate(year, month, selectedDay));
            void changeMonth(int delta) {
              var nextYear = year;
              var nextMonth = month + delta;
              if (nextMonth < 1) { nextMonth = 12; nextYear--; }
              if (nextMonth > 12) { nextMonth = 1; nextYear++; }
              setSheetState(() {
                year = nextYear; month = nextMonth;                final length = formatter.monthLength(year, month);
                if (selectedDay > length) selectedDay = length;
              });
            }
            final canGoBack = !formatter.fromJalali(JalaliDate(year, month, 1)).isBefore(today);
            return Dialog(
              child: SafeArea(
                child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('انتخاب تاریخ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                          padding: EdgeInsets.zero,
                          tooltip: 'ماه قبل',
                          onPressed: canGoBack ? () => changeMonth(-1) : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${formatter.monthName(month)} ${formatter.toPersianDigits(year.toString())}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                          padding: EdgeInsets.zero,
                          tooltip: 'ماه بعد',
                          onPressed: () => changeMonth(1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                      ],
                    ),
                    const Row(children: [
                      Expanded(child: Center(child: Text('ش'))), Expanded(child: Center(child: Text('ی'))),
                      Expanded(child: Center(child: Text('د'))), Expanded(child: Center(child: Text('س'))),
                      Expanded(child: Center(child: Text('چ'))), Expanded(child: Center(child: Text('پ'))),
                      Expanded(child: Center(child: Text('ج'))),
                    ]),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: days.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 42),
                      itemBuilder: (context, index) {
                        final day = days[index];
                        if (day == null) return const SizedBox.shrink();
                        final date = formatter.fromJalali(JalaliDate(year, month, day));
                        final isPast = date.isBefore(today);
                        final selected = day == selectedDay;
                        return Padding(
                          padding: const EdgeInsets.all(2),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isPast ? null : () => setSheetState(() => selectedDay = day),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primaryContainer : null, borderRadius: BorderRadius.circular(12)),
                              child: Text(formatter.toPersianDigits(day.toString()), style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: isPast ? Theme.of(context).disabledColor : null)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: FilledButton(key: const ValueKey('quick-capture-date-confirm'), onPressed: selectedDate().isBefore(today) ? null : () => Navigator.pop(sheetContext, selectedDate()), child: const Text('انتخاب تاریخ'))),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
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
                    color: const Color(0xFFE5E7ED),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ثبت سریع کار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF232433),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('quick-capture-input'),
                      controller: _controller,
                      focusNode: _titleFocus,
                      autofocus: true,
                      enabled: !_saving,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'عنوان کار',
                        hintText: 'عنوان کار را بنویسید',
                        helperText: 'عنوان برای ثبت کافی است',
                        errorText: _error,
                        filled: true,
                        fillColor: const Color(0xFFFDFDFE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE5E7ED)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: const ValueKey('quick-capture-priority'),
                    tooltip: _priority == TaskPriority.high
                        ? 'حذف اهمیت'
                        : 'مهم کردن کار',
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _priority = _priority == TaskPriority.high
                                  ? TaskPriority.none
                                  : TaskPriority.high;
                            }),
                    icon: Icon(
                      _priority == TaskPriority.high
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _priority == TaskPriority.high
                          ? const Color(0xFF4A4CAB)
                          : const Color(0xFF80829C),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ArvinRollBox<Object?>(
                          key: const ValueKey('quick-capture-due-rollbox'),
                          label: 'موعد',
                          valueLabel: _dueDate == null ? 'موعد' : '${_relativeDateLabel(_dueDate)} • ${_timeLabel(_dueDate!)}',
                          icon: Icons.calendar_today_outlined,
                          color: const Color(0xFF2F7D5A),
                          emptyLabel: 'بدون موعد',
                          items: [
                            ArvinRollItem<Object?>(value: _now(), label: 'امروز', icon: Icons.today_outlined, color: const Color(0xFF2F7D5A)),
                            ArvinRollItem<Object?>(value: _now().add(const Duration(days: 1)), label: 'فردا', icon: Icons.event_outlined, color: const Color(0xFF3568D4)),
                            ArvinRollItem<Object?>(value: _now().add(const Duration(days: 7)), label: 'هفته آینده', icon: Icons.date_range_outlined, color: const Color(0xFF7650C8)),
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
                          valueLabel: _recurrenceContextLabel(),
                          icon: Icons.repeat_rounded,
                          color: const Color(0xFFD16A2D),
                          emptyLabel: 'بدون تکرار',
                          items: const [
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.minutes, interval: 15), label: 'هر ۱۵ دقیقه', icon: Icons.timer_outlined, color: Color(0xFFD16A2D)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.hours), label: 'هر ساعت', icon: Icons.access_time_rounded, color: Color(0xFFD16A2D)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.daily), label: 'هر روز', icon: Icons.today_outlined, color: Color(0xFFD16A2D)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.weekly), label: 'هر هفته', icon: Icons.view_week_outlined, color: Color(0xFF3568D4)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.monthly), label: 'هر ماه', icon: Icons.calendar_month_outlined, color: Color(0xFF7650C8)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.yearly), label: 'هر سال', icon: Icons.event_repeat_outlined, color: Color(0xFF2F7D5A)),
                          ],
                          createLabel: 'تکرار سفارشی',
                          onCreate: _saving ? null : _pickCustomRecurrence,
                          onSelected: (value) => setState(() {
                            _recurrence = value;
                            if (value != null && _dueDate == null) {
                              final now = _now();
                              _dueDate = DateTime(now.year, now.month, now.day, now.hour, now.minute);
                              _syncAutomaticReminder();
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ArvinRollBox<Object?>(
                          key: const ValueKey('quick-capture-reminder-rollbox'),
                          label: 'یادآور',
                          valueLabel: _dueDate == null ? 'ابتدا موعد را تعیین کنید' : (_reminderDate == null ? 'یادآور • ${_relativeDateLabel(_dueDate)}' : '${_relativeDateLabel(_reminderDate)} • ${_timeLabel(_reminderDate!)}'),
                          icon: Icons.notifications_none_outlined,
                          color: const Color(0xFFE08A2E),
                          emptyLabel: 'بدون یادآور',
                          items: _dueDate == null ? const [] : [
                            ArvinRollItem<Object?>(value: _dueDate!, label: 'همان زمان موعد', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: _dueDate!.subtract(const Duration(minutes: 15)), label: '۱۵ دقیقه قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: _dueDate!.subtract(const Duration(hours: 1)), label: 'یک ساعت قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: _dueDate!.subtract(const Duration(days: 1)), label: 'یک روز قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: _dueDate!.subtract(const Duration(days: 7)), label: 'یک هفته قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                          ],
                          createLabel: 'تاریخ و ساعت سفارشی',
                          onCreate: _saving || _dueDate == null ? null : _pickCustomReminder,
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
                      child: const Text('جزئیات بیشتر'),
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