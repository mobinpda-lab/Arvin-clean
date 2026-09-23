import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/recurrence.dart';
import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/quick_capture_service.dart';
import 'widgets/arvin_radio_box.dart';

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
  });

  final QuickCaptureService service;
  final String Function()? idFactory;
  final DateTime Function()? now;
  final Future<void> Function(Task task)? onCaptured;
  final Future<bool> Function(Task draft)? onFullForm;
  final List<ProjectPlan> projects;
  final String? initialProjectId;
  final ValueChanged<String?>? onProjectChanged;

  @override
  State<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<QuickCaptureDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  String? _error;
  bool _saving = false;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  RecurrenceRule? _recurrence;
  String? _projectId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleFocus.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
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
    task.tags = {...task.tags, ...manualTags}.toList(growable: false);
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
    }
  }


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
    return const PersianDateFormatter().format(value, usePersianDate: true);
  }

  Future<void> _pickDue() async {
    final selected = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(title: Text('موعد انجام')),
            ListTile(title: const Text('امروز'), onTap: () => Navigator.pop(sheetContext, DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))),
            ListTile(title: const Text('فردا'), onTap: () => Navigator.pop(sheetContext, DateTime.now().add(const Duration(days: 1)))),
            ListTile(title: const Text('هفته آینده'), onTap: () => Navigator.pop(sheetContext, DateTime.now().add(const Duration(days: 7)))),
            ListTile(title: const Text('انتخاب تاریخ'), onTap: () async {
              final picked = await _pickJalaliDate(sheetContext, initialDate: _dueDate ?? DateTime.now());
              if (picked != null && sheetContext.mounted) Navigator.pop(sheetContext, picked);
            }),
            ListTile(title: const Text('بدون موعد'), onTap: () => Navigator.pop(sheetContext, _clearToken)),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _dueDate = selected == _clearToken ? null : selected as DateTime?);
  }

  Future<void> _pickReminder() async {
    final selected = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(title: Text('یادآور')),
            ListTile(title: const Text('۱۰ دقیقه قبل'), onTap: () => Navigator.pop(sheetContext, -10)),
            ListTile(title: const Text('۳۰ دقیقه قبل'), onTap: () => Navigator.pop(sheetContext, -30)),
            ListTile(title: const Text('یک ساعت قبل'), onTap: () => Navigator.pop(sheetContext, -60)),
            ListTile(title: const Text('انتخاب تاریخ و ساعت'), onTap: () async {
              final date = await _pickJalaliDate(sheetContext, initialDate: _reminderDate ?? _dueDate ?? DateTime.now());
              if (date == null || !sheetContext.mounted) return;
              final time = await showTimePicker(context: sheetContext, initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now()));
              if (time != null && sheetContext.mounted) Navigator.pop(sheetContext, DateTime(date.year, date.month, date.day, time.hour, time.minute));
            }),
            ListTile(title: const Text('بدون یادآور'), onTap: () => Navigator.pop(sheetContext, _clearToken)),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (selected is int) {
      final base = _dueDate ?? DateTime.now();
      setState(() => _reminderDate = base.add(Duration(minutes: selected)));
    } else {
      setState(() => _reminderDate = selected == _clearToken ? null : selected as DateTime?);
    }
  }

  Future<void> _pickRecurrence() async {
    final selected = await showModalBottomSheet<RecurrenceRule?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(title: Text('تکرار')),
            ListTile(title: const Text('بدون تکرار'), onTap: () => Navigator.pop(sheetContext)),
            ListTile(title: const Text('روزانه'), onTap: () => Navigator.pop(sheetContext, const RecurrenceRule(frequency: RecurrenceFrequency.daily))),
            ListTile(title: const Text('هفتگی'), onTap: () => Navigator.pop(sheetContext, const RecurrenceRule(frequency: RecurrenceFrequency.weekly))),
            ListTile(title: const Text('ماهانه'), onTap: () => Navigator.pop(sheetContext, const RecurrenceRule(frequency: RecurrenceFrequency.monthly))),
            ListTile(title: const Text('سالانه'), onTap: () => Navigator.pop(sheetContext, const RecurrenceRule(frequency: RecurrenceFrequency.yearly))),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _recurrence = selected);
  }

  Future<void> _pickProject() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text('پروژه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              ArvinRadioBox(
                label: 'بدون پروژه',
                selected: _projectId == null,
                icon: Icons.work_off_outlined,
                onTap: () => Navigator.pop(sheetContext, ''),
              ),
              for (final project in widget.projects.where((p) => !p.isArchived))
                ArvinRadioBox(
                  label: project.title,
                  selected: _projectId == project.id,
                  icon: Icons.work_outline,
                  onTap: () => Navigator.pop(sheetContext, project.id),
                ),
              if (widget.projects.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('هنوز پروژه‌ای ثبت نشده است'),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _projectId = selected.isEmpty ? null : selected);
    widget.onProjectChanged?.call(_projectId);
  }

  Future<DateTime?> _pickJalaliDate(BuildContext parentContext, {,    required DateTime initialDate,,  }) async {,    final formatter = const PersianDateFormatter();,    final initial = formatter.toJalali(initialDate);,    return showModalBottomSheet<DateTime>(,      context: parentContext,,      isScrollControlled: true,,      showDragHandle: true,,      builder: (sheetContext) {,        var year = initial.year;,        var month = initial.month;,        var selectedDay = initial.day;,        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);,        return StatefulBuilder(builder: (context, setSheetState) {,          final monthLength = formatter.monthLength(year, month);,          if (selectedDay > monthLength) selectedDay = monthLength;,          final firstGregorian = formatter.fromJalali(JalaliDate(year, month, 1));,          final firstWeekday = firstGregorian.weekday % 7;,          final days = List<int?>.filled(firstWeekday, null)..addAll(List<int>.generate(monthLength, (i) => i + 1));,          DateTime selectedDate() => formatter.fromJalali(JalaliDate(year, month, selectedDay));,          void changeMonth(int delta) {,            var nextYear = year;,            var nextMonth = month + delta;,            if (nextMonth < 1) { nextMonth = 12; nextYear--; },            if (nextMonth > 12) { nextMonth = 1; nextYear++; },            setSheetState(() {,              year = nextYear; month = nextMonth;,              final length = formatter.monthLength(year, month);,              if (selectedDay > length) selectedDay = length;,            });,          },          final canGoBack = !formatter.fromJalali(JalaliDate(year, month, 1)).isBefore(today);,          return SafeArea(child: Padding(,            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),,            child: Column(mainAxisSize: MainAxisSize.min, children: [,              const Text('انتخاب تاریخ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),,              const SizedBox(height: 10),,              Row(children: [,                IconButton(tooltip: 'ماه قبل', onPressed: canGoBack ? () => changeMonth(-1) : null, icon: const Icon(Icons.chevron_right)),,                Expanded(child: Center(child: Text(,                  '${formatter.monthName(month)} ${formatter.toPersianDigits(year.toString())}',,                  style: const TextStyle(fontWeight: FontWeight.w700),,                ))),,                IconButton(tooltip: 'ماه بعد', onPressed: () => changeMonth(1), icon: const Icon(Icons.chevron_left)),,              ]),,              const Row(children: [,                Expanded(child: Center(child: Text('ش'))), Expanded(child: Center(child: Text('ی'))),,                Expanded(child: Center(child: Text('د'))), Expanded(child: Center(child: Text('س'))),,                Expanded(child: Center(child: Text('چ'))), Expanded(child: Center(child: Text('پ'))),,                Expanded(child: Center(child: Text('ج'))),,              ]),,              const SizedBox(height: 6),,              GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: days.length,,                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 42),,                itemBuilder: (context, index) {,                  final day = days[index]; if (day == null) return const SizedBox.shrink();,                  final date = formatter.fromJalali(JalaliDate(year, month, day));,                  final isPast = date.isBefore(today); final selected = day == selectedDay;,                  return Padding(padding: const EdgeInsets.all(2), child: InkWell(,                    borderRadius: BorderRadius.circular(12), onTap: isPast ? null : () => setSheetState(() => selectedDay = day),,                    child: Container(alignment: Alignment.center, decoration: BoxDecoration(,                      color: selected ? Theme.of(context).colorScheme.primaryContainer : null, borderRadius: BorderRadius.circular(12)),,                      child: Text(formatter.toPersianDigits(day.toString()), style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: isPast ? Theme.of(context).disabledColor : null)),,                  ));,                }),,              const SizedBox(height: 10),,              SizedBox(width: double.infinity, child: FilledButton(onPressed: selectedDate().isBefore(today) ? null : () => Navigator.pop(context, selectedDate()), child: const Text('انتخاب تاریخ'))),,            ]),,          ));,        });,      },,    );,  }

  static const _clearToken = Object();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('quick-capture-dialog'),
      child: _buildContent(context),
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
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ArvinRadioBox(
                    label: _dateLabel(_dueDate),
                    selected: _dueDate != null,
                    icon: Icons.calendar_today_outlined,
                    onTap: _saving ? () {} : () { _pickDue(); },
                  ),
                  ArvinRadioBox(
                    label: _projectId == null
                        ? 'پروژه'
                        : widget.projects.firstWhere(
                            (p) => p.id == _projectId,
                            orElse: () => ProjectPlan(id: '', title: 'پروژه'),
                          ).title,
                    selected: _projectId != null,
                    icon: Icons.work_outline,
                    onTap: _saving ? () {} : () { _pickProject(); },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.sell_outlined, size: 18),
                    label: Text(_tagsController.text.trim().isEmpty ? 'برچسب' : _tagsController.text.trim()),
                    onPressed: _saving ? null : () async {
                      final value = await showDialog<String>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('برچسب‌ها'),
                          content: TextField(controller: _tagsController, autofocus: true, decoration: const InputDecoration(hintText: 'مثلاً مشتری، فوری')),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لغو')),
                            FilledButton(onPressed: () => Navigator.pop(dialogContext, _tagsController.text), child: const Text('اعمال')),
                          ],
                        ),
                      );
                      if (value != null && mounted) setState(() {});
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.category_outlined, size: 18),
                    label: Text(_categoryController.text.trim().isEmpty ? 'دسته' : _categoryController.text.trim()),
                    onPressed: _saving ? null : () async {
                      final value = await showDialog<String>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('دسته'),
                          content: TextField(controller: _categoryController, autofocus: true),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لغو')),
                            FilledButton(onPressed: () => Navigator.pop(dialogContext, _categoryController.text), child: const Text('اعمال')),
                          ],
                        ),
                      );
                      if (value != null && mounted) setState(() {});
                    },
                  ),
                  ArvinRadioBox(
                    label: _reminderDate == null ? 'یادآور' : 'یادآور تنظیم شد',
                    selected: _reminderDate != null,
                    icon: Icons.notifications_none_outlined,
                    onTap: _saving ? () {} : () { _pickReminder(); },
                  ),
                  ArvinRadioBox(
                    label: _recurrence == null ? 'تکرار' : 'تکرار تنظیم شد',
                    selected: _recurrence != null,
                    icon: Icons.repeat_rounded,
                    onTap: _saving ? () {} : () { _pickRecurrence(); },
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
