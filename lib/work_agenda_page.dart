import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/persian_date_formatter.dart';
import 'services/work_agenda_projection.dart';
import 'services/work_agenda_report_adapter.dart';
import 'widgets/persian_date_picker.dart';

class WorkAgendaPage extends StatefulWidget {
  const WorkAgendaPage({
    super.key,
    required this.tasks,
    this.initialDay,
  });

  final List<Task> tasks;
  final DateTime? initialDay;

  @override
  State<WorkAgendaPage> createState() => _WorkAgendaPageState();
}

class _WorkAgendaPageState extends State<WorkAgendaPage> {
  static const _adapter = WorkAgendaReportAdapter();
  static const _dates = PersianDateFormatter();

  late DateTime _startDay;
  late DateTime _endDay;
  bool _rangeMode = false;

  @override
  void initState() {
    super.initState();
    final base = DateUtils.dateOnly(widget.initialDay ?? DateTime.now());
    _startDay = base;
    _endDay = base;
  }

  Future<DateTime?> _pick(DateTime initial, String helpText) {
    final now = DateTime.now();
    return showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 10, 1, 1),
      lastDate: DateTime(now.year + 10, 12, 31),
      helpText: helpText,
    );
  }

  Future<void> _pickDay() async {
    final value = await _pick(_startDay, 'انتخاب روز کاری');
    if (value == null || !mounted) return;
    setState(() {
      _startDay = DateUtils.dateOnly(value);
      _endDay = _startDay;
    });
  }

  Future<void> _pickStart() async {
    final value = await _pick(_startDay, 'شروع بازه کاری');
    if (value == null || !mounted) return;
    setState(() {
      _startDay = DateUtils.dateOnly(value);
      if (_endDay.isBefore(_startDay)) _endDay = _startDay;
    });
  }

  Future<void> _pickEnd() async {
    final value = await _pick(_endDay, 'پایان بازه کاری');
    if (value == null || !mounted) return;
    setState(() {
      _endDay = DateUtils.dateOnly(value);
      if (_endDay.isBefore(_startDay)) _startDay = _endDay;
    });
  }

  WorkAgendaReport get _report => _rangeMode
      ? _adapter.forRange(
          widget.tasks,
          startDay: _startDay,
          endDay: _endDay,
          title: 'برنامه کاری بازه',
        )
      : _adapter.forDay(
          widget.tasks,
          day: _startDay,
          title: 'برنامه کاری روز',
        );

  String _date(DateTime value) => _dates.format(value, usePersianDate: true);

  String _time(DateTime value) => _dates.toPersianDigits(
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      );

  String _eventLabel(WorkAgendaEvent event) {
    final label = switch (event.kind) {
      WorkAgendaEventKind.taskDue => 'موعد کار',
      WorkAgendaEventKind.taskReminder => 'یادآوری کار',
      WorkAgendaEventKind.followUpSchedule => 'پیگیری',
      WorkAgendaEventKind.followUpReminder => 'یادآوری پیگیری',
    };
    return '$label • ${_time(event.at)}';
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return Scaffold(
      appBar: AppBar(title: const Text('برنامه کاری')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('روز')),
                ButtonSegment(value: true, label: Text('بازه')),
              ],
              selected: {_rangeMode},
              onSelectionChanged: (value) {
                setState(() => _rangeMode = value.single);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _rangeMode
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('work-agenda-start'),
                          onPressed: _pickStart,
                          icon: const Icon(Icons.date_range_outlined),
                          label: Text('از ${_date(_startDay)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('work-agenda-end'),
                          onPressed: _pickEnd,
                          icon: const Icon(Icons.event_available_outlined),
                          label: Text('تا ${_date(_endDay)}'),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const ValueKey('work-agenda-day'),
                      onPressed: _pickDay,
                      icon: const Icon(Icons.today_outlined),
                      label: Text(_date(_startDay)),
                    ),
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            child: report.days.isEmpty
                ? const Center(child: Text('کاری برای این روز یا بازه وجود ندارد'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: report.days.length,
                    itemBuilder: (context, dayIndex) {
                      final day = report.days[dayIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 6),
                            child: Text(
                              _date(day.day),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ...day.items.map(
                            (item) => Card(
                              child: ListTile(
                                title: Text(item.entry.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    ...item.events.map(
                                      (event) => Text(_eventLabel(event)),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  item.entry.completed
                                      ? Icons.check_circle_outline
                                      : Icons.radio_button_unchecked,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
