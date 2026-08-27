import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'widgets/persian_date_picker.dart';

class ArvinTaskEditorDialog extends StatefulWidget {
  const ArvinTaskEditorDialog({super.key, this.task});

  final Task? task;

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
  late bool _followUpEnabled;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _tagController = TextEditingController();
    _followUpDateTime = task?.legacyHomeFollowUpDate;
    _followUpEnabled = task?.followUpEnabled == true ||
        (task?.followUps.isNotEmpty ?? false) ||
        task?.followUpDate != null;
    _tags = List<String>.of(task?.tags ?? const []);
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
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _fieldSurface,
      suffixIcon: suffixIcon,
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

  DateTime _baseFollowUp() {
    final current = _followUpDateTime;
    if (current != null) return current;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  void _setFollowUpEnabled(bool value) {
    setState(() {
      _followUpEnabled = value;
      if (value && _followUpDateTime == null) {
        _followUpDateTime = _baseFollowUp();
      }
    });
  }

  Future<void> _pickDate() async {
    final base = _baseFollowUp();
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ پیگیری',
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _followUpDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        base.hour,
        base.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final base = _baseFollowUp();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      helpText: 'انتخاب ساعت پیگیری',
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
    if (picked == null || !mounted) return;

    setState(() {
      _followUpDateTime = DateTime(
        base.year,
        base.month,
        base.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _clearFollowUpTime() {
    setState(() => _followUpDateTime = null);
  }

  void _addTag() {
    final value = _tagController.text.trim();
    if (value.isEmpty || _tags.contains(value)) return;
    setState(() {
      _tags.add(value);
      _tagController.clear();
    });
  }

  void _save() {
    final now = DateTime.now();
    final existing = widget.task;
    final id = existing?.id ?? now.microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(
      Task(
        id: id,
        title: _titleController.text.trim().isEmpty
            ? 'بدون عنوان'
            : _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        followUpEnabled: _followUpEnabled,
        followUpDate: _followUpEnabled ? _followUpDateTime : null,
        tags: List<String>.of(_tags),
        category: existing?.category,
        checklist: List<String>.of(existing?.checklist ?? const []),
        reminderDate: existing?.reminderDate,
        archived: existing?.archived ?? false,
        trashed: existing?.trashed ?? false,
        completed: existing?.completed ?? false,
        followUps: List<FollowUp>.of(existing?.followUps ?? const []),
        recurrence: existing?.recurrence,
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

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    final followUp = _followUpDateTime;
    final hasHistory = widget.task?.followUps.isNotEmpty ?? false;

    return Dialog(
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const ValueKey('task-editor-title'),
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: 18),
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
                      CheckboxListTile(
                        key: const ValueKey('task-editor-followup-enabled'),
                        value: _followUpEnabled,
                        onChanged: (value) => _setFollowUpEnabled(value ?? false),
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
                              onTap: _pickDate,
                            );
                            final timeButton = _dateTimeButton(
                              key: const ValueKey('task-editor-time'),
                              label: 'ساعت',
                              value: followUp == null
                                  ? 'انتخاب ساعت'
                                  : _timeText(followUp),
                              icon: Icons.schedule_outlined,
                              onTap: _pickTime,
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
    );
  }
}
