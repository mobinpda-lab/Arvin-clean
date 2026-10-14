import 'package:flutter/material.dart';

import 'models/person_reference.dart';
import 'models/task.dart';
import 'services/task_store.dart';
import 'services/persian_date_formatter.dart';
import 'services/waiting_for_response_service.dart';
import 'widgets/persian_date_picker.dart';

class FollowUpEntryPage extends StatefulWidget {
  const FollowUpEntryPage({
    super.key,
    this.initialFollowUp,
    this.initialDateTime,
    this.onSaved,
    this.store,
  });

  final FollowUp? initialFollowUp;
  final DateTime? initialDateTime;
  final ValueChanged<FollowUp>? onSaved;
  final TaskStore? store;

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
  List<PersonReference> _availablePeople = const <PersonReference>[];
  final Set<String> _selectedPersonIds = <String>{};
  Set<String> _initialPersonIds = <String>{};
  bool _peopleLoading = false;
  bool _peopleLoadStarted = false;
  String? _personError;
  late DateTime _initialDateTime;
  late String _initialNote;
  late String _initialResult;
  late DateTime? _initialReminderDate;
  late DateTime? _initialNextFollowUp;
  late bool _initialWaitingForResponse;

  bool get _editing => widget.initialFollowUp != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFollowUp;
    _dateTime = initial?.dateTime ?? widget.initialDateTime ?? DateTime.now();
    _noteController.text = initial?.note ?? '';
    _waitingForResponse = initial?.waitingForResponse == true ||
        _waitingService.isWaitingResult(initial?.result);
    _selectedPersonIds.addAll(initial?.personIds ?? const <String>[]);
    _initialPersonIds = Set<String>.of(_selectedPersonIds);
    if (_waitingForResponse) _loadPeopleDirectory();
    _resultController.text = _waitingForResponse ? '' : initial?.result ?? '';
    _reminderDate = initial?.reminderDate;
    _nextFollowUp = initial?.nextFollowUp;
    _initialDateTime = _dateTime;
    _initialNote = _noteController.text;
    _initialResult = _resultController.text;
    _initialReminderDate = _reminderDate;
    _initialNextFollowUp = _nextFollowUp;
    _initialWaitingForResponse = _waitingForResponse;
  }

  Future<void> _loadPeopleDirectory() async {
    if (_peopleLoadStarted) return;
    _peopleLoadStarted = true;
    if (mounted) {
      setState(() {
        _peopleLoading = true;
        _personError = null;
      });
    }
    try {
      final people = await (widget.store ?? TaskStore()).loadPeopleDirectory();
      if (!mounted) return;
      setState(() {
        _availablePeople = people;
        _peopleLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _peopleLoading = false;
        _personError = 'فهرست اشخاص بارگذاری نشد؛ دوباره صفحه را باز کنید.';
      });
    }
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

  bool get _hasChanges =>
      _dateTime != _initialDateTime ||
      _noteController.text != _initialNote ||
      _resultController.text != _initialResult ||
      _reminderDate != _initialReminderDate ||
      _nextFollowUp != _initialNextFollowUp ||
      _waitingForResponse != _initialWaitingForResponse ||
      _selectedPersonIds.length != _initialPersonIds.length ||
      !_selectedPersonIds.containsAll(_initialPersonIds);

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
          'برای جلوگیری از از دست رفتن پیگیری، تغییرات را ذخیره کنید یا صریحاً بدون ذخیره خارج شوید.',
        ),
        actions: [
          TextButton(
            key: const ValueKey('follow-up-exit-continue'),
            onPressed: () => Navigator.of(dialogContext).pop('continue'),
            child: const Text('ادامه ویرایش'),
          ),
          TextButton(
            key: const ValueKey('follow-up-exit-discard'),
            onPressed: () => Navigator.of(dialogContext).pop('discard'),
            child: const Text('بدون ذخیره'),
          ),
          FilledButton(
            key: const ValueKey('follow-up-exit-save'),
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
    if (_waitingForResponse && _selectedPersonIds.isEmpty) {
      setState(() {
        _personError = 'برای ثبت «منتظر پاسخ»، حداقل یک شخص مرتبط انتخاب کنید.';
      });
      return;
    }
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
      waitingForResponse: _waitingForResponse,
      personIds: List<String>.unmodifiable(_selectedPersonIds),
      completed: widget.initialFollowUp?.completed ?? false,
    );
    widget.onSaved?.call(followUp);
    Navigator.of(context).pop(followUp);
  }

  @override
  Widget build(BuildContext context) {
    final reminder = _reminderDate;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: const ValueKey('follow-up-entry-back'),
              tooltip: 'بازگشت',
              onPressed: _requestClose,
              icon: const Icon(Icons.arrow_back),
            ),
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
              onChanged: (value) {
                setState(() => _waitingForResponse = value);
                if (value) _loadPeopleDirectory();
              },
            ),
            if (_waitingForResponse) ...[
              const SizedBox(height: 8),
              const Text(
                'اشخاص مرتبط',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (_peopleLoading)
                const LinearProgressIndicator()
              else if (_availablePeople.isEmpty)
                const Text(
                  'هنوز شخصی در دفترچه اشخاص ثبت نشده است. ابتدا از تنظیمات، بخش «اشخاص»، فرد موردنظر را اضافه کنید.',
                )
              else
                ..._availablePeople.map(
                  (person) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(person.displayName),
                    value: _selectedPersonIds.contains(person.id),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedPersonIds.add(person.id);
                        } else {
                          _selectedPersonIds.remove(person.id);
                        }
                        _personError = null;
                      });
                    },
                  ),
                ),
              if (_personError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _personError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
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
      ),
    );
  }
}
