import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/waiting_for_response_service.dart';
import 'widgets/persian_date_picker.dart';

class FollowUpEntryPage extends StatefulWidget {
  const FollowUpEntryPage({
    super.key,
    this.initialFollowUp,
    this.initialDateTime,
    this.onSaved,
  });

  final FollowUp? initialFollowUp;
  final DateTime? initialDateTime;
  final ValueChanged<FollowUp>? onSaved;

  @override
  State<FollowUpEntryPage> createState() => _FollowUpEntryPageState();
}

class _FollowUpEntryPageState extends State<FollowUpEntryPage> {
  static const _waitingService = WaitingForResponseService();
  static const _dateFormatter = PersianDateFormatter();
  static const _defaultTitle = 'پیگیری';

  late DateTime _dateTime;
  final _noteController = TextEditingController();
  final _resultController = TextEditingController();
  DateTime? _reminderDate;
  DateTime? _nextFollowUp;
  bool _waitingForResponse = false;

  bool get _editing => widget.initialFollowUp != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFollowUp;
    _dateTime = initial?.dateTime ?? widget.initialDateTime ?? DateTime.now();
    _noteController.text = initial?.note ?? '';
    _waitingForResponse = _waitingService.isWaitingResult(initial?.result);
    _resultController.text = _waitingForResponse ? '' : initial?.result ?? '';
    _reminderDate = initial?.reminderDate;
    _nextFollowUp = initial?.nextFollowUp;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  String _digits(String value) => _dateFormatter.toPersianDigits(value);

  String _formatDate(DateTime value) =>
      _dateFormatter.format(value, usePersianDate: true);

  String _formatTime(DateTime value) {
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return _digits(time);
  }

  Future<DateTime?> _pickPersianDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required String helpText,
  }) {
    return showPersianDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      helpText: helpText,
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
  }

  Future<TimeOfDay?> _pickClock({
    required DateTime initialDate,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: helpText,
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
  }

  Future<void> _pickDate() async {
    final picked = await _pickPersianDate(
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      helpText: 'انتخاب تاریخ پیگیری',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await _pickClock(
      initialDate: _dateTime,
      helpText: 'انتخاب ساعت پیگیری',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  DateTime _baseReminder() => _reminderDate ?? _nextFollowUp ?? _dateTime;

  Future<void> _pickReminderDate() async {
    final base = _baseReminder();
    final picked = await _pickPersianDate(
      initialDate: base,
      firstDate: DateTime(2020),
      helpText: 'انتخاب تاریخ یادآور پیگیری',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _reminderDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        base.hour,
        base.minute,
      );
    });
  }

  Future<void> _pickReminderTime() async {
    final base = _baseReminder();
    final picked = await _pickClock(
      initialDate: base,
      helpText: 'انتخاب ساعت یادآور پیگیری',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _reminderDate = DateTime(
        base.year,
        base.month,
        base.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _clearReminder() => setState(() => _reminderDate = null);

  Future<void> _pickNext() async {
    final picked = await _pickPersianDate(
      initialDate: _nextFollowUp ?? _dateTime,
      firstDate: _dateTime,
      helpText: 'انتخاب پیگیری بعدی',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _nextFollowUp = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  void _save() {
    final rawResult = _resultController.text.trim();
    final result = _waitingForResponse
        ? WaitingForResponseService.canonicalResult
        : _waitingService.canonicalizeResult(rawResult);
    final enteredTitle = _noteController.text.trim();
    final followUp = FollowUp(
      id: widget.initialFollowUp?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      dateTime: _dateTime,
      note: enteredTitle.isEmpty ? _defaultTitle : enteredTitle,
      result: result,
      reminderDate: _reminderDate,
      nextFollowUp: _nextFollowUp,
    );
    widget.onSaved?.call(followUp);
    Navigator.of(context).pop(followUp);
  }

  @override
  Widget build(BuildContext context) {
    final reminder = _reminderDate;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing ? 'ویرایش پیگیری' : 'ثبت پیگیری'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              'تاریخ و ساعت به‌صورت خودکار از سیستم وارد شده‌اند و قابل ویرایش هستند.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('follow-up-entry-date'),
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_formatDate(_dateTime)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('follow-up-entry-time'),
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_formatTime(_dateTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('follow-up-entry-title'),
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'عنوان پیگیری (اختیاری)',
                hintText: 'اگر خالی بماند «پیگیری» ثبت می‌شود',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('منتظر پاسخ دیگران'),
              subtitle: const Text(
                'این پیگیری در فهرست موارد منتظر پاسخ نمایش داده می‌شود.',
              ),
              value: _waitingForResponse,
              onChanged: (value) =>
                  setState(() => _waitingForResponse = value),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _resultController,
              enabled: !_waitingForResponse,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'نتیجه پیگیری',
                hintText: _waitingForResponse ? 'وضعیت: منتظر پاسخ' : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickNext,
              icon: const Icon(Icons.event_repeat),
              label: Text(
                _nextFollowUp == null
                    ? 'انتخاب پیگیری بعدی'
                    : 'پیگیری بعدی: ${_formatDate(_nextFollowUp!)} • ساعت ${_formatTime(_nextFollowUp!)}',
              ),
            ),
            const SizedBox(height: 16),
            Card(
              key: const ValueKey('follow-up-reminder-block'),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'یادآور این پیگیری',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 2),
                              Text('مستقل از زمان خود پیگیری و پیگیری بعدی'),
                            ],
                          ),
                        ),
                        if (reminder != null)
                          TextButton(
                            key: const ValueKey('follow-up-reminder-clear'),
                            onPressed: _clearReminder,
                            child: const Text('حذف یادآور'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('follow-up-reminder-date'),
                            onPressed: _pickReminderDate,
                            icon: const Icon(Icons.notifications_active_outlined),
                            label: Text(
                              reminder == null
                                  ? 'تاریخ یادآور'
                                  : _formatDate(reminder),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('follow-up-reminder-time'),
                            onPressed: _pickReminderTime,
                            icon: const Icon(Icons.schedule_outlined),
                            label: Text(
                              reminder == null
                                  ? 'ساعت یادآور'
                                  : _formatTime(reminder),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton.icon(
              key: const ValueKey('follow-up-entry-save'),
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_editing ? 'ذخیره تغییرات' : 'ذخیره پیگیری'),
            ),
          ),
        ),
      ),
    );
  }
}
