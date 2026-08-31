import 'package:flutter/material.dart';

import 'daily_content.dart';
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

class _JalaliDate {
  const _JalaliDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;
}

enum _CalendarViewMode { day, week, month }

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.reminders,
    this.initialSelectedDay,
    this.dailyContentForDate,
  });

  final List<CalendarReminder> reminders;
  final DateTime? initialSelectedDay;

  /// Optional Daily Content projection for the selected calendar date.
  ///
  /// This is deliberately separate from [reminders], so «پیام روز» never
  /// changes the task/follow-up/reminder count rendered on calendar cells.
  final DailyContentItem? Function(DateTime date)? dailyContentForDate;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selectedDay;
  _CalendarViewMode _viewMode = _CalendarViewMode.week;

  @override
  void initState() {
    super.initState();
    final selected = widget.initialSelectedDay ?? DateTime.now();
    _selectedDay = DateTime(selected.year, selected.month, selected.day);
    final jalali = _toJalali(_selectedDay);
    _month = _toGregorian(jalali.year, jalali.month, 1);
  }

  _JalaliDate _toJalali(DateTime date) {
    var gy = date.year - 1600;
    final gm = date.month - 1;
    final gd = date.day - 1;
    const gDays = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gDayNo =
        365 * gy + (gy + 3) ~/ 4 - (gy + 99) ~/ 100 + (gy + 399) ~/ 400;
    for (var i = 0; i < gm; i++) {
      gDayNo += gDays[i];
    }
    if (gm > 1 && _isGregorianLeap(date.year)) {
      gDayNo++;
    }
    gDayNo += gd;
    var jDayNo = gDayNo - 79;
    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;
    var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;
    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }
    final jm = jDayNo < 186 ? 1 + jDayNo ~/ 31 : 7 + (jDayNo - 186) ~/ 30;
    final jd =
        1 + (jDayNo < 186 ? jDayNo % 31 : (jDayNo - 186) % 30);
    return _JalaliDate(jy, jm, jd);
  }

  DateTime _toGregorian(int jy, int jm, int jd) {
    var jy0 = jy - 979;
    var jDayNo =
        365 * jy0 + (jy0 ~/ 33) * 8 + ((jy0 % 33) + 3) ~/ 4;
    for (var i = 1; i < jm; i++) {
      jDayNo += i <= 6 ? 31 : 30;
    }
    jDayNo += jd - 1;
    var gDayNo = jDayNo + 79;
    var gy = 1600 + 400 * (gDayNo ~/ 146097);
    gDayNo %= 146097;
    var leap = true;
    if (gDayNo >= 36525) {
      gDayNo--;
      gy += 100 * (gDayNo ~/ 36524);
      gDayNo %= 36524;
      if (gDayNo >= 365) {
        gDayNo++;
      } else {
        leap = false;
      }
    }
    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;
    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += gDayNo ~/ 365;
      gDayNo %= 365;
    }
    const gDays = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gm = 0;
    while (gm < 12) {
      final days = gDays[gm] + (gm == 1 && leap ? 1 : 0);
      if (gDayNo < days) {
        break;
      }
      gDayNo -= days;
      gm++;
    }
    return DateTime(gy, gm + 1, gDayNo + 1);
  }

  bool _isGregorianLeap(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  String _digits(String value) {
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], persian[i]);
    }
    return result;
  }

  String _date(DateTime date) {
    final j = _toJalali(date);
    return _digits(
      '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}',
    );
  }

  String _time(DateTime date) => _digits(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<CalendarReminder> _forDay(DateTime day) => widget.reminders
      .where((item) => _sameDay(item.date, day))
      .toList(growable: false);

  Map<int, int> _countsForMonth() {
    final counts = <int, int>{};
    final current = _toJalali(_month);
    for (final item in widget.reminders) {
      final j = _toJalali(item.date);
      if (j.year == current.year && j.month == current.month) {
        counts[j.day] = (counts[j.day] ?? 0) + 1;
      }
    }
    return counts;
  }

  int _daysInJalaliMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    final first = _toGregorian(year, 12, 1);
    final next = _toGregorian(year + 1, 1, 1);
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
    final jalali = _toJalali(normalized);
    setState(() {
      _selectedDay = normalized;
      _month = _toGregorian(jalali.year, jalali.month, 1);
    });
  }

  void _moveMonth(int delta) {
    final current = _toJalali(_month);
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
    final first = _toGregorian(year, month, 1);
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
    }
  }

  void _today() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jalali = _toJalali(today);
    setState(() {
      _month = _toGregorian(jalali.year, jalali.month, 1);
      _selectedDay = today;
    });
  }

  Future<void> _jumpToDate() async {
    final current = _toJalali(_selectedDay);
    final selection = await showJalaliDateJumpDialog(
      context,
      initialYear: current.year,
      initialMonth: current.month,
      initialDay: current.day,
      daysInMonth: _daysInJalaliMonth,
    );
    if (!mounted || selection == null) return;
    _selectDay(_toGregorian(selection.year, selection.month, selection.day));
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
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
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
    final jalali = _toJalali(_selectedDay);
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
            _digits('${jalali.day}'),
            style: Theme.of(context)
                .textTheme
                .titleLarge
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
              '${_digits('$count')} مورد',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
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
                    final jalali = _toJalali(date);
                    final count = _forDay(date).length;
                    final selected = _sameDay(date, _selectedDay);
                    return InkWell(
                      key: ValueKey(
                        'calendar-week-day-${date.year}-${date.month}-${date.day}',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _selectDay(date),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _digits('${jalali.day}'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (count > 0)
                              Text(
                                _digits('$count'),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
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
    final current = _toJalali(_month);
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
              final date = _toGregorian(current.year, current.month, day);
              final count = counts[day] ?? 0;
              final isSelected = _sameDay(date, _selectedDay);
              return Padding(
                padding: const EdgeInsets.all(1.5),
                child: InkWell(
                  key: ValueKey('calendar-month-day-$day'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectDay(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      border: count > 0
                          ? Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_digits('$day')),
                        if (count > 0)
                          Text(
                            _digits('$count'),
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

  Widget _buildCalendarSurface() {
    return switch (_viewMode) {
      _CalendarViewMode.day => _buildDayView(),
      _CalendarViewMode.week => _buildWeekView(),
      _CalendarViewMode.month => _buildMonthView(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedJalali = _toJalali(_selectedDay);
    final selectedReminders = _forDay(_selectedDay);
    final selectedDailyContent =
        widget.dailyContentForDate?.call(_selectedDay);
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
                        _digits(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _buildCalendarSurface(),
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
                        for (var index = 0;
                            index < selectedReminders.length;
                            index++) ...[
                          if (index > 0) const SizedBox(height: 6),
                          _ReminderCard(
                            item: selectedReminders[index],
                            dateLabel: _date(selectedReminders[index].date),
                            timeLabel: _time(selectedReminders[index].date),
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.item,
    required this.dateLabel,
    required this.timeLabel,
  });

  final CalendarReminder item;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final subtitle = item.isAllDay
        ? '$dateLabel\nرویداد تمام‌روز'
        : '$dateLabel  •  ساعت $timeLabel\n${item.completed ? 'انجام‌شده' : 'در انتظار پیگیری'}';
    return Card(
      child: ListTile(
        leading: Icon(
          item.isAllDay
              ? Icons.event_outlined
              : item.completed
                  ? Icons.check_circle
                  : Icons.notifications_active_outlined,
        ),
        title: Text(item.title),
        subtitle: Text(subtitle),
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
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
}
