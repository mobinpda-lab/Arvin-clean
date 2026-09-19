import 'package:flutter/material.dart';

import 'daily_content.dart';
import 'services/prayer_completion_projection.dart';
import 'services/persian_date_formatter.dart';
import 'widgets/jalali_date_jump_dialog.dart';

class CalendarReminder {
  const CalendarReminder({
    required this.id,
    required this.title,
    required this.date,
    this.completed = false,
    this.isAllDay = false,
  });
  final String id;
  final String title;
  final DateTime date;
  final bool completed;
  final bool isAllDay;
}

enum _CalendarViewMode { day, week, month, year }

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.reminders,
    this.initialSelectedDay,
    this.dailyContentForDate,
    this.onCompleteReminder,
    this.onSnoozeReminder,
    this.onEditReminder,
    this.onConvertReminderToTask,
    this.onOpenExternalReminder,
    this.canMutateReminder,
    this.onCreateTaskForDate,
    this.prayerStatusFor,
    this.onPrayerCompleted,
    this.onPrayerNotCompleted,
  });

  final List<CalendarReminder> reminders;
  final DateTime? initialSelectedDay;
  final Future<void> Function(CalendarReminder reminder)? onCompleteReminder;
  final Future<void> Function(CalendarReminder reminder)? onSnoozeReminder;
  final Future<void> Function(CalendarReminder reminder)? onEditReminder;
  final Future<void> Function(CalendarReminder reminder)?
  onConvertReminderToTask;
  final Future<void> Function(CalendarReminder reminder)? onOpenExternalReminder;

  /// Generic Task/FollowUp actions are shown only for exact canonical targets.
  final bool Function(CalendarReminder reminder)? canMutateReminder;

  /// Creates a canonical Task with the pressed calendar date prefilled.
  final Future<void> Function(DateTime date)? onCreateTaskForDate;

  final PrayerCompletionStatus? Function(CalendarReminder reminder)?
  prayerStatusFor;
  final Future<void> Function(CalendarReminder reminder)? onPrayerCompleted;
  final Future<void> Function(CalendarReminder reminder)? onPrayerNotCompleted;

  /// Optional Daily Content projection for the selected calendar date.
  ///
  /// This is deliberately separate from [reminders], so «پیام روز» never
  /// changes the task/follow-up/reminder count rendered on calendar cells.
  final DailyContentItem? Function(DateTime date)? dailyContentForDate;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _dateFormatter = PersianDateFormatter();
  late DateTime _month;
  late DateTime _selectedDay;
  _CalendarViewMode _viewMode = _CalendarViewMode.week;

  @override
  void initState() {
    super.initState();
    final selected = widget.initialSelectedDay ?? DateTime.now();
    _selectedDay = DateTime(selected.year, selected.month, selected.day);
    final jalali = _dateFormatter.toJalali(_selectedDay);
    _month = _dateFormatter.fromJalali(JalaliDate(jalali.year, jalali.month, 1));
  }

  String _date(DateTime date) {
    final j = _dateFormatter.toJalali(date);
    return _dateFormatter.toPersianDigits(
      '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}',
    );
  }

  String _time(DateTime date) => _dateFormatter.toPersianDigits(
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
  );

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<CalendarReminder> _forDay(DateTime day) => widget.reminders
      .where((item) => _sameDay(item.date, day))
      .toList(growable: false);

  Map<int, int> _countsForMonth() {
    final counts = <int, int>{};
    final current = _dateFormatter.toJalali(_month);
    for (final item in widget.reminders) {
      final j = _dateFormatter.toJalali(item.date);
      if (j.year == current.year && j.month == current.month) {
        counts[j.day] = (counts[j.day] ?? 0) + 1;
      }
    }
    return counts;
  }

  int _daysInJalaliMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    final first = _dateFormatter.fromJalali(JalaliDate(year, 12, 1));
    final next = _dateFormatter.fromJalali(JalaliDate(year + 1, 1, 1));
    return next.difference(first).inDays;
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final daysSinceSaturday = (normalized.weekday + 1) % 7;
    return normalized.subtract(Duration(days: daysSinceSaturday));
  }

  String _weekdayShort(DateTime date) {
    return switch (date.weekday) {
      DateTime.saturday => 'ش',
      DateTime.sunday => 'ی',
      DateTime.monday => 'د',
      DateTime.tuesday => 'س',
      DateTime.wednesday => 'چ',
      DateTime.thursday => 'پ',
      DateTime.friday => 'ج',
      _ => '',
    };
  }

  String _weekdayFull(DateTime date) {
    return switch (date.weekday) {
      DateTime.saturday => 'شنبه',
      DateTime.sunday => 'یکشنبه',
      DateTime.monday => 'دوشنبه',
      DateTime.tuesday => 'سه‌شنبه',
      DateTime.wednesday => 'چهارشنبه',
      DateTime.thursday => 'پنجشنبه',
      DateTime.friday => 'جمعه',
      _ => '',
    };
  }

  void _selectDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final jalali = _dateFormatter.toJalali(normalized);
    setState(() {
      _selectedDay = normalized;
      _month = _dateFormatter.fromJalali(JalaliDate(jalali.year, jalali.month, 1));
    });
  }

  void _moveMonth(int delta) {
    final current = _dateFormatter.toJalali(_month);
    var month = current.month + delta;
    var year = current.year;
    while (month < 1) {
      month += 12;
      year--;
    }
    while (month > 12) {
      month -= 12;
      year++;
    }
    final first = _dateFormatter.fromJalali(JalaliDate(year, month, 1));
    setState(() {
      _month = first;
      _selectedDay = first;
    });
  }

  void _movePeriod(int delta) {
    switch (_viewMode) {
      case _CalendarViewMode.day:
        _selectDay(_selectedDay.add(Duration(days: delta)));
        return;
      case _CalendarViewMode.week:
        _selectDay(_selectedDay.add(Duration(days: delta * 7)));
        return;
      case _CalendarViewMode.month:
        _moveMonth(delta);
        return;
      case _CalendarViewMode.year:
        final current = _dateFormatter.toJalali(_selectedDay);
        final nextYear = current.year + delta;
        final maxDay = _daysInJalaliMonth(nextYear, current.month);
        _selectDay(
          _dateFormatter.fromJalali(
            JalaliDate(
              nextYear,
              current.month,
              current.day > maxDay ? maxDay : current.day,
            ),
          ),
        );
        return;
    }
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200) {
      _movePeriod(1);
    } else if (velocity > 200) {
      _movePeriod(-1);
    }
  }

  void _today() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jalali = _dateFormatter.toJalali(today);
    setState(() {
      _month = _dateFormatter.fromJalali(JalaliDate(jalali.year, jalali.month, 1));
      _selectedDay = today;
    });
  }

  Future<void> _jumpToDate() async {
    final current = _dateFormatter.toJalali(_selectedDay);
    final selection = await showJalaliDateJumpDialog(
      context,
      initialYear: current.year,
      initialMonth: current.month,
      initialDay: current.day,
      daysInMonth: _daysInJalaliMonth,
    );
    if (!mounted || selection == null) return;
    _selectDay(_dateFormatter.fromJalali(JalaliDate(selection.year, selection.month, selection.day)));
  }

  void _showDailyContent(DailyContentItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'پیام روز • ${_dailyContentKindLabel(item.kind)}',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(item.text, style: Theme.of(context).textTheme.bodyLarge),
                if (item.originalText?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  Text(item.originalText!, textDirection: TextDirection.rtl),
                ],
                const SizedBox(height: 20),
                Text(
                  '${item.author} — ${item.source}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(item.reference),
                const SizedBox(height: 6),
                Text(
                  'تطبیق/تأیید: ${item.verifiedBy}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewModeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Center(
        child: SegmentedButton<_CalendarViewMode>(
          key: const ValueKey('calendar-view-mode-control'),
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: const [
            ButtonSegment<_CalendarViewMode>(
              value: _CalendarViewMode.day,
              label: Text('روزانه'),
            ),
            ButtonSegment<_CalendarViewMode>(
              value: _CalendarViewMode.week,
              label: Text('هفتگی'),
            ),
            ButtonSegment<_CalendarViewMode>(
              value: _CalendarViewMode.month,
              label: Text('ماهانه'),
            ),
            ButtonSegment<_CalendarViewMode>(
              value: _CalendarViewMode.year,
              label: Text('سالانه'),
            ),
          ],
          selected: <_CalendarViewMode>{_viewMode},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            setState(() => _viewMode = selection.first);
          },
        ),
      ),
    );
  }

  Widget _buildDayView() {
    final jalali = _dateFormatter.toJalali(_selectedDay);
    final count = _forDay(_selectedDay).length;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('calendar-day-view'),
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Text(
            _weekdayFull(_selectedDay),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(
            _dateFormatter.toPersianDigits('${jalali.day}'),
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Container(
            key: const ValueKey('calendar-day-count'),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: count > 0
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_dateFormatter.toPersianDigits('$count')} مورد',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final weekStart = _startOfWeek(_selectedDay);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      key: const ValueKey('calendar-week-view'),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          for (var offset = 0; offset < 7; offset++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Builder(
                  builder: (context) {
                    final date = weekStart.add(Duration(days: offset));
                    final jalali = _dateFormatter.toJalali(date);
                    final count = _forDay(date).length;
                    final selected = _sameDay(date, _selectedDay);
                    return InkWell(
                      key: ValueKey(
                        'calendar-week-day-${date.year}-${date.month}-${date.day}',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _selectDay(date),
                      onLongPress: widget.onCreateTaskForDate == null
                          ? null
                          : () => widget.onCreateTaskForDate!(date),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: selected ? scheme.primaryContainer : null,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: count > 0
                                ? scheme.outlineVariant
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _weekdayShort(date),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _dateFormatter.toPersianDigits('${jalali.day}'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (count > 0)
                              Text(
                                _dateFormatter.toPersianDigits('$count'),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    final current = _dateFormatter.toJalali(_month);
    final days = _daysInJalaliMonth(current.year, current.month);
    final leading = (_month.weekday + 1) % 7;
    final counts = _countsForMonth();

    return Column(
      key: const ValueKey('calendar-month-view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              _Weekday('ش'),
              _Weekday('ی'),
              _Weekday('د'),
              _Weekday('س'),
              _Weekday('چ'),
              _Weekday('پ'),
              _Weekday('ج'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leading + days,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 38,
            ),
            itemBuilder: (_, index) {
              if (index < leading) {
                return const SizedBox.shrink();
              }
              final day = index - leading + 1;
              final date = _dateFormatter.fromJalali(JalaliDate(current.year, current.month, day));
              final count = counts[day] ?? 0;
              final isSelected = _sameDay(date, _selectedDay);
              return Padding(
                padding: const EdgeInsets.all(1.5),
                child: InkWell(
                  key: ValueKey('calendar-month-day-$day'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectDay(date),
                  onLongPress: widget.onCreateTaskForDate == null
                      ? null
                      : () => widget.onCreateTaskForDate!(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      border: count > 0
                          ? Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_dateFormatter.toPersianDigits('$day')),
                        if (count > 0)
                          Text(
                            _dateFormatter.toPersianDigits('$count'),
                            style: TextStyle(
                              fontSize: 10,
                              height: 1,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static const _jalaliMonthNames = <String>[
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  Widget _buildYearView() {
    final current = _dateFormatter.toJalali(_selectedDay);
    final counts = <int, int>{};
    for (final item in widget.reminders) {
      final jalali = _dateFormatter.toJalali(item.date);
      if (jalali.year == current.year) {
        counts[jalali.month] = (counts[jalali.month] ?? 0) + 1;
      }
    }

    return GridView.builder(
      key: const ValueKey('calendar-year-view'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;
        final selected = month == current.month;
        final count = counts[month] ?? 0;
        final scheme = Theme.of(context).colorScheme;
        return InkWell(
          key: ValueKey('calendar-year-month-$month'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectDay(
            _dateFormatter.fromJalali(JalaliDate(current.year, month, 1)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _jalaliMonthNames[index],
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (count > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${_dateFormatter.toPersianDigits('$count')} مورد',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarSurface() {
    return switch (_viewMode) {
      _CalendarViewMode.day => _buildDayView(),
      _CalendarViewMode.week => _buildWeekView(),
      _CalendarViewMode.month => _buildMonthView(),
      _CalendarViewMode.year => _buildYearView(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedJalali = _dateFormatter.toJalali(_selectedDay);
    final selectedReminders = _forDay(_selectedDay);
    final selectedDailyContent = widget.dailyContentForDate?.call(_selectedDay);
    final hasSelectedItems =
        selectedDailyContent != null || selectedReminders.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقویم پیگیری'),
          actions: [
            TextButton(
              key: const ValueKey('calendar-date-jump'),
              onPressed: _jumpToDate,
              child: const Text('برو به تاریخ'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TextButton.icon(
                key: const ValueKey('calendar-today'),
                onPressed: _today,
                icon: const Icon(Icons.today_outlined, size: 18),
                label: const Text('امروز'),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('calendar-period-previous'),
                    onPressed: () => _movePeriod(-1),
                    tooltip: 'بازه قبل',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _dateFormatter.toPersianDigits(
                          '${selectedJalali.year}/${selectedJalali.month.toString().padLeft(2, '0')}',
                        ),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('calendar-period-next'),
                    onPressed: () => _movePeriod(1),
                    tooltip: 'بازه بعد',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
            ),
            _buildViewModeSelector(),
            GestureDetector(
              key: const ValueKey('calendar-swipe-surface'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _handleHorizontalSwipe,
              onLongPress:
                  _viewMode == _CalendarViewMode.day &&
                      widget.onCreateTaskForDate != null
                  ? () => widget.onCreateTaskForDate!(_selectedDay)
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _buildCalendarSurface(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: !hasSelectedItems
                  ? Center(
                      child: Text(
                        'برای این روز یادآوری ثبت نشده است',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView(
                      key: const ValueKey('calendar-selected-day-list'),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                      children: [
                        if (selectedDailyContent != null) ...[
                          _DailyContentCard(
                            item: selectedDailyContent,
                            onTap: () =>
                                _showDailyContent(selectedDailyContent),
                          ),
                          if (selectedReminders.isNotEmpty)
                            const SizedBox(height: 10),
                        ],
                        for (
                          var index = 0;
                          index < selectedReminders.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 6),
                          _ReminderCard(
                            item: selectedReminders[index],
                            dateLabel: _date(selectedReminders[index].date),
                            timeLabel: _time(selectedReminders[index].date),
                            onComplete:
                                (widget.canMutateReminder?.call(
                                      selectedReminders[index],
                                    ) ??
                                    true)
                                ? widget.onCompleteReminder
                                : null,
                            onSnooze:
                                (widget.canMutateReminder?.call(
                                      selectedReminders[index],
                                    ) ??
                                    true)
                                ? widget.onSnoozeReminder
                                : null,
                            onEdit:
                                (widget.canMutateReminder?.call(
                                      selectedReminders[index],
                                    ) ??
                                    true)
                                ? widget.onEditReminder
                                : null,
                            onConvertToTask: widget.onConvertReminderToTask,
                            onOpenExternal: selectedReminders[index].id.startsWith('external-calendar:')
                                ? widget.onOpenExternalReminder
                                : null,
                            prayerStatus: widget.prayerStatusFor?.call(
                              selectedReminders[index],
                            ),
                            onPrayerCompleted: widget.onPrayerCompleted,
                            onPrayerNotCompleted: widget.onPrayerNotCompleted,
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyContentCard extends StatelessWidget {
  const _DailyContentCard({required this.item, required this.onTap});

  final DailyContentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.auto_awesome_outlined),
        title: Text('پیام روز • ${_dailyContentKindLabel(item.kind)}'),
        subtitle: Text(
          '${item.text}\n${item.source} — ${item.reference}',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}

class _ReminderCard extends StatefulWidget {
  const _ReminderCard({
    required this.item,
    required this.dateLabel,
    required this.timeLabel,
    this.onComplete,
    this.onSnooze,
    this.onEdit,
    this.onConvertToTask,
    this.onOpenExternal,
    this.prayerStatus,
    this.onPrayerCompleted,
    this.onPrayerNotCompleted,
  });

  final CalendarReminder item;
  final String dateLabel;
  final String timeLabel;
  final Future<void> Function(CalendarReminder reminder)? onComplete;
  final Future<void> Function(CalendarReminder reminder)? onSnooze;
  final Future<void> Function(CalendarReminder reminder)? onEdit;
  final Future<void> Function(CalendarReminder reminder)? onConvertToTask;
  final Future<void> Function(CalendarReminder reminder)? onOpenExternal;
  final PrayerCompletionStatus? prayerStatus;
  final Future<void> Function(CalendarReminder reminder)? onPrayerCompleted;
  final Future<void> Function(CalendarReminder reminder)? onPrayerNotCompleted;

  bool get isPrayer => item.id.startsWith('prayer-');

  @override
  State<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<_ReminderCard> {
  bool _expanded = false;

  bool get _hasActions =>
      (widget.isPrayer &&
          (widget.onPrayerCompleted != null ||
              widget.onPrayerNotCompleted != null)) ||
      (!widget.isPrayer &&
          (widget.onComplete != null ||
              widget.onSnooze != null ||
              widget.onEdit != null ||
              widget.onConvertToTask != null ||
              widget.onOpenExternal != null));

  Future<void> _run(
    Future<void> Function(CalendarReminder reminder)? action,
  ) async {
    if (action == null) return;
    await action(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final prayerState = switch (widget.prayerStatus) {
      PrayerCompletionStatus.completed => 'ادا شد',
      PrayerCompletionStatus.notCompleted => 'قضا شد',
      null => 'ثبت نشده',
    };
    final subtitle = item.isAllDay
        ? '${widget.dateLabel}\nرویداد تمام‌روز'
        : '${widget.dateLabel}  •  ساعت ${widget.timeLabel}\n${widget.isPrayer ? prayerState : (item.completed ? 'انجام‌شده' : 'در انتظار پیگیری')}';

    return Card(
      child: Column(
        children: [
          ListTile(
            key: ValueKey('reminder-card-${item.id}'),
            onTap: _hasActions
                ? () => setState(() => _expanded = !_expanded)
                : null,
            leading: CircleAvatar(
              child: Icon(
                item.isAllDay
                    ? Icons.event_outlined
                    : item.completed
                    ? Icons.check_circle
                    : Icons.notifications_active_outlined,
              ),
            ),
            title: const Text(
              'یادآور',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
            trailing: _hasActions
                ? Icon(_expanded ? Icons.expand_less : Icons.expand_more)
                : null,
          ),
          if (_expanded && _hasActions)
            Padding(
              key: ValueKey('reminder-actions-${item.id}'),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.isPrayer && widget.onPrayerCompleted != null)
                    ActionChip(
                      key: ValueKey('prayer-completed-${item.id}'),
                      avatar: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('ادا شد'),
                      onPressed: () => _run(widget.onPrayerCompleted),
                    ),
                  if (widget.isPrayer && widget.onPrayerNotCompleted != null)
                    ActionChip(
                      key: ValueKey('prayer-not-completed-${item.id}'),
                      avatar: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('قضا شد'),
                      onPressed: () => _run(widget.onPrayerNotCompleted),
                    ),
                  if (!widget.isPrayer && widget.onOpenExternal != null)
                    ActionChip(
                      key: ValueKey('external-calendar-open-${item.id}'),
                      avatar: const Icon(Icons.info_outline, size: 18),
                      label: const Text('جزئیات رویداد'),
                      onPressed: () => _run(widget.onOpenExternal),
                    ),
                  if (!widget.isPrayer &&
                      widget.onComplete != null &&
                      !item.completed)
                    ActionChip(
                      key: ValueKey('reminder-complete-${item.id}'),
                      avatar: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('انجام شد'),
                      onPressed: () => _run(widget.onComplete),
                    ),
                  if (!widget.isPrayer &&
                      widget.onSnooze != null &&
                      !item.completed)
                    ActionChip(
                      key: ValueKey('reminder-snooze-${item.id}'),
                      avatar: const Icon(Icons.snooze_outlined, size: 18),
                      label: const Text('تعویق'),
                      onPressed: () => _run(widget.onSnooze),
                    ),
                  if (!widget.isPrayer && widget.onEdit != null)
                    ActionChip(
                      key: ValueKey('reminder-edit-${item.id}'),
                      avatar: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('ویرایش'),
                      onPressed: () => _run(widget.onEdit),
                    ),
                  if (!widget.isPrayer && widget.onConvertToTask != null)
                    ActionChip(
                      key: ValueKey('reminder-convert-${item.id}'),
                      avatar: const Icon(Icons.task_alt_outlined, size: 18),
                      label: const Text('تبدیل به کار'),
                      onPressed: () => _run(widget.onConvertToTask),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _dailyContentKindLabel(DailyContentKind kind) {
  return switch (kind) {
    DailyContentKind.quran => 'قرآن کریم',
    DailyContentKind.nahjAlBalagha => 'نهج‌البلاغه',
    DailyContentKind.shiaHadith => 'حدیث شیعه',
    DailyContentKind.sahifaSajjadiya => 'صحیفه سجادیه',
    DailyContentKind.iranianQuote => 'سخن بزرگان ایران',
    DailyContentKind.worldQuote => 'سخن بزرگان جهان',
  };
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}
