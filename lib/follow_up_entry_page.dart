import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/waiting_for_response_service.dart';

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

  late DateTime _dateTime;
  final _noteController = TextEditingController();
  final _resultController = TextEditingController();
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
    _nextFollowUp = initial?.nextFollowUp;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  String _digits(String value) {
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], persian[i]);
    }
    return result;
  }

  String _formatDate(DateTime value) {
    final date =
        '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
    return _digits(date);
  }

  String _formatTime(DateTime value) {
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return _digits(time);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ پیگیری',
      cancelText: 'لغو',
      confirmText: 'تأیید',
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
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
      helpText: 'انتخاب ساعت پیگیری',
      cancelText: 'لغو',
      confirmText: 'تأیید',
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

  Future<void> _pickNext() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextFollowUp ?? _dateTime,
      firstDate: _dateTime,
      lastDate: DateTime(2100),
      helpText: 'انتخاب پیگیری بعدی',
      cancelText: 'لغو',
      confirmText: 'تأیید',
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
    final followUp = FollowUp(
      id: widget.initialFollowUp?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      dateTime: _dateTime,
      note: _noteController.text.trim(),
      result: result,
      nextFollowUp: _nextFollowUp,
    );
    widget.onSaved?.call(followUp);
    Navigator.of(context).pop(followUp);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing ? 'ویرایش پیگیری' : 'ثبت پیگیری'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'تاریخ و ساعت به‌صورت خودکار از سیستم وارد شده‌اند و قابل ویرایش هستند.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_formatDate(_dateTime)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_formatTime(_dateTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'یادداشت پیگیری',
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
                hintText: _waitingForResponse
                    ? 'وضعیت: منتظر پاسخ'
                    : null,
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
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_editing ? 'ذخیره تغییرات' : 'ذخیره پیگیری'),
            ),
          ],
        ),
      ),
    );
  }
}
