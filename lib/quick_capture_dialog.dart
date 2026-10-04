import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/quick_capture_service.dart';
import 'widgets/arvin_roll_box.dart';

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
  RecurrenceRule? _recurrence;
  final TextEditingController _recurrenceIntervalController =
      TextEditingController(text: '1');
  String? _projectId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<String> _selectedTags = <String>[];
  late List<String> _knownCategories;
  late List<String> _knownTags;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
    _knownCategories = List<String>.of(widget.knownCategories);
    _knownTags = List<String>.of(widget.knownTags);
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

  Task? _buildDraft() {
    final createdAt = widget.now?.call() ?? DateTime.now();
    final task = widget.service.capture(
      _controller.text,
      id: widget.idFactory?.call() ?? createdAt.microsecondsSinceEpoch.toString(),
      createdAt: createdAt,
    );
    if (task == null) return null;
    task.description = _descriptionController.text.trim();
    task.dueDate = _dueDate;
    task.reminderDate = _reminderDate;
    task.recurrence = _recurrence;
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
    final time = formatter.toPersianDigits('${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}');
    return '$date • $time';
  }

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  Future<TimeOfDay?> _pickPersianTime(
    BuildContext parentContext, {
    required DateTime initial,
  }) async {
    var hour = initial.hour;
    var minute = initial.minute;
    return showDialog<TimeOfDay>(
      context: parentContext,
      builder: (sheetContext) {
        final formatter = const PersianDateFormatter();
        return Dialog(
          child: SafeArea(
            child: StatefulBuilder(
            builder: (context, setSheetState) {
              final label = formatter.toPersianDigits(
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
              );
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('انتخاب ساعت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(label, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ArvinRollBox<int>(
                      label: 'ساعت',
                      valueLabel: 'ساعت ${formatter.toPersianDigits(hour.toString().padLeft(2, '0'))}',
                      icon: Icons.access_time_rounded,
                      color: const Color(0xFF3568D4),
                      items: List.generate(
                        24,
                        (value) => ArvinRollItem<int>(
                          value: value,
                          label: formatter.toPersianDigits(value.toString().padLeft(2, '0')),
                          icon: Icons.schedule_outlined,
                          color: const Color(0xFF3568D4),
                        ),
                      ),
                      onSelected: (value) { if (value != null) setSheetState(() => hour = value); },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ArvinRollBox<int>(
                      label: 'دقیقه',
                      valueLabel: 'دقیقه ${formatter.toPersianDigits(minute.toString().padLeft(2, '0'))}',
                      icon: Icons.more_time_rounded,
                      color: const Color(0xFF7650C8),
                      items: List.generate(60, (value) {

                          return ArvinRollItem<int>(
                            value: value,
                            label: formatter.toPersianDigits(value.toString().padLeft(2, '0')),
                            icon: Icons.timelapse_outlined,
                            color: const Color(0xFF7650C8),
                          );
                        }),
                      onSelected: (value) { if (value != null) setSheetState(() => minute = value); },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          TimeOfDay(hour: hour, minute: minute),
                        ),
                        key: const ValueKey('quick-capture-time-confirm'),
                        child: const Text('انتخاب ساعت'),
                      ),
                    ),
                  ],
                ),
              );
            },
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickCustomDue() async {
    final initial = _dueDate ?? widget.now?.call() ?? DateTime.now();
    final date = await _pickJalaliDate(context, initialDate: initial);
    if (date == null || !mounted) return null;
    final time = await _pickPersianTime(context, initial: initial);
    if (time == null || !mounted) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DateTime?> _pickCustomReminder() async {
    final initial = _reminderDate ?? _dueDate ?? widget.now?.call() ?? DateTime.now();
    final date = await _pickJalaliDate(context, initialDate: initial);
    if (date == null || !mounted) return null;
    final time = await _pickPersianTime(context, initial: initial);
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
                  builder: (context, setDialogState) {
                    const labels = <RecurrenceFrequency, String>{
                      RecurrenceFrequency.minutes: 'دقیقه',
                      RecurrenceFrequency.hours: 'ساعت',
                      RecurrenceFrequency.daily: 'روز',
                      RecurrenceFrequency.weekly: 'هفته',
                      RecurrenceFrequency.monthly: 'ماه',
                      RecurrenceFrequency.yearly: 'سال',
                    };
                    return ArvinRollBox<RecurrenceFrequency>(
                      key: const ValueKey('quick-capture-custom-recurrence-frequency'),
                      label: 'واحد تکرار',
                      valueLabel: labels[frequency] ?? 'روز',
                      icon: Icons.repeat_rounded,
                      color: ArvinColors.recurrence,
                      items: labels.entries
                          .map(
                            (entry) => ArvinRollItem<RecurrenceFrequency>(
                              value: entry.key,
                              label: entry.value,
                              icon: Icons.repeat_rounded,
                              color: ArvinColors.recurrence,
                            ),
                          )
                          .toList(growable: false),
                      onSelected: (value) {
                        if (value != null) setDialogState(() => frequency = value);
                      },
                    );
                  },
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
                  fillColor: const Color(0xFFFDFDFE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7ED)),
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
                  fillColor: const Color(0xFFFDFDFE),
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
                        : widget.projects
                                .where((project) => project.id == _projectId)
                                .map((project) => project.title)
                                .isEmpty
                            ? 'پروژه'
                            : widget.projects
                                .where((project) => project.id == _projectId)
                                .map((project) => project.title)
                                .first,
                    icon: Icons.folder_outlined,
                    color: const Color(0xFF3568D4),
                    emptyLabel: 'بدون پروژه',
                    items: widget.projects
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
                                ? const Color(0xFF7D8298)
                                : const Color(0xFF3568D4),
                          ),
                        )
                        .toList(),
                    onSelected: (value) => setState(() {
                      _projectId = value;
                    }),
                  ),),
                      const SizedBox(width: 8),
                      Expanded(child: ArvinRollBox<String>(
                    label: 'دسته',
                    valueLabel: _categoryController.text.trim().isEmpty ? 'دسته' : _categoryController.text.trim(),
                    icon: Icons.grid_view_rounded,
                    color: const Color(0xFF7650C8),
                    emptyLabel: 'بدون دسته',
                    items: _knownCategories.map((v) => v.trim()).where((v) => v.isNotEmpty).map((v) => ArvinRollItem<String>(
                      value: v, label: v, icon: Icons.grid_view_rounded, color: const Color(0xFF7650C8),
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
                          label: 'موعد',
                          valueLabel: _dueDate == null ? 'موعد' : _dateLabel(_dueDate),
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
                              setState(() => _dueDate = value);
                            } else {
                              setState(() => _dueDate = null);
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
                          color: const Color(0xFFD16A2D),
                          emptyLabel: 'بدون تکرار',
                          items: const [
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.daily), label: 'هر روز', icon: Icons.today_outlined, color: Color(0xFFD16A2D)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.weekly), label: 'هر هفته', icon: Icons.view_week_outlined, color: Color(0xFF3568D4)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.monthly), label: 'هر ماه', icon: Icons.calendar_month_outlined, color: Color(0xFF7650C8)),
                            ArvinRollItem<RecurrenceRule?>(value: RecurrenceRule(frequency: RecurrenceFrequency.yearly), label: 'هر سال', icon: Icons.event_repeat_outlined, color: Color(0xFF2F7D5A)),
                          ],
                          createLabel: 'تکرار سفارشی',
                          onCreate: _saving ? null : _pickCustomRecurrence,
                          onSelected: (value) => setState(() => _recurrence = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ArvinRollBox<Object?>(
                          label: 'یادآور',
                          valueLabel: _reminderDate == null ? 'یادآور' : _dateLabel(_reminderDate),
                          icon: Icons.notifications_none_outlined,
                          color: const Color(0xFFE08A2E),
                          emptyLabel: 'بدون یادآور',
                          items: [
                            ArvinRollItem<Object?>(value: _dueDate ?? _now(), label: 'همان زمان موعد', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(minutes: 15)), label: '۱۵ دقیقه قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(hours: 1)), label: 'یک ساعت قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(days: 1)), label: 'یک روز قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                            ArvinRollItem<Object?>(value: (_dueDate ?? _now()).subtract(const Duration(days: 7)), label: 'یک هفته قبل', icon: Icons.notifications_active_outlined, color: const Color(0xFFE08A2E)),
                          ],
                          createLabel: 'تاریخ و ساعت سفارشی',
                          onCreate: _saving ? null : _pickCustomReminder,
                          onSelected: (value) {
                            if (value is DateTime) {
                              setState(() => _reminderDate = value);
                            } else {
                              setState(() => _reminderDate = null);
                            }
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
