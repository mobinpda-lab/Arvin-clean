import 'package:flutter/material.dart';

import 'models/task.dart';

class FollowUpEntryPage extends StatefulWidget {
  const FollowUpEntryPage({super.key, this.initialDateTime, this.onSaved});

  final DateTime? initialDateTime;
  final ValueChanged<FollowUp>? onSaved;

  @override
  State<FollowUpEntryPage> createState() => _FollowUpEntryPageState();
}

class _FollowUpEntryPageState extends State<FollowUpEntryPage> {
  late DateTime _dateTime;
  final _noteController = TextEditingController();
  final _resultController = TextEditingController();
  DateTime? _nextFollowUp;

  @override
  void initState() {
    super.initState();
    _dateTime = widget.initialDateTime ?? DateTime.now();
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

  String _format(DateTime value) {
    final date = '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '${_digits(date)} • ساعت ${_digits(time)}';
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
    final followUp = FollowUp(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dateTime: _dateTime,
      note: _noteController.text.trim(),
      result: _resultController.text.trim().isEmpty
          ? null
          : _resultController.text.trim(),
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
        appBar: AppBar(title: const Text('ثبت پیگیری')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('تاریخ و ساعت پیگیری'),
              subtitle: Text(_format(_dateTime)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'یادداشت پیگیری',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _resultController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'نتیجه پیگیری',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickNext,
              icon: const Icon(Icons.event_repeat),
              label: Text(
                _nextFollowUp == null
                    ? 'انتخاب پیگیری بعدی'
                    : 'پیگیری بعدی: ${_format(_nextFollowUp!)}',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('ذخیره پیگیری'),
            ),
          ],
        ),
      ),
    );
  }
}
