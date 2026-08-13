import 'package:flutter/material.dart';

/// A reminder projected onto Arvin's calendar.
///
/// The DateTime remains the single source of truth, including its time. The
/// calendar only converts it for Persian/Jalali presentation.
class CalendarReminder {
  const CalendarReminder({
    required this.id,
    required this.title,
    required this.date,
    this.completed = false,
  });

  final String id;
  final String title;
  final DateTime date;
  final bool completed;
}

class _JalaliDate {
  const _JalaliDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}

/// Internal calendar view for Arvin reminders.
///
/// Gregorian DateTime values are kept internally so existing storage and
/// reminder logic do not change. The visible calendar is Jalali (Persian).
class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.reminders,
    this.initialSelectedDay,
  });

  final List<CalendarReminder> reminders;
  final DateTime? initialSelectedDay;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final selected = widget.initialSelectedDay ?? DateTime.now();
    final day = DateTime(selected.year, selected.month, selected.day);
    _selectedDay = day;
    _month = DateTime(day.year, day.month, 1);
  }

  _JalaliDate _toJalali(DateTime date) {
    var gy = date.year - 1600;
    final gm = date.month - 1;
    final gd = date.day - 1;
    const gMonthDays = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    var gDayNo = 365 * gy + (gy + 3) ~/ 4 - (gy + 99) ~/ 100 + (gy + 399) ~/ 400;
    for (var i = 0; i < gm; i++) {
      gDayNo += gMonthDays[i];
    }
    if (gm > 1 && ((date.year % 4 == 0 && date.year % 100 != 0) || date.year % 400 == 0)) {
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
    final jd = 1 + (jDayNo < 186 ? jDayNo % 31 : (jDayNo - 186) % 30);
    return _JalaliDate(jy, jm, jd);
  }

  DateTime _toGregorian(int jy, int jm, int jd) {
    var jy0 = jy - 979;
    var jDayNo = 365 * jy0 + (jy0 ~/ 33) * 8 + ((jy0 % 33) + 3) ~/ 4;
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
      if (gDayNo >= 365) gDayNo++;
      else leap = false;
    }
    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;
    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += gDayNo ~/ 365;
      gDayNo %= 365;
    }

    const gMonthDays = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gm = 0;
    while (gm < 12) {
      final days = gMonthDays[gm] + (gm == 1 && leap ? 1 : 0);
      if (gDayNo < days) break;
      gDayNo -= days;
      gm++;
    }
    return DateTime(gy, gm + 1, gDayNo + 1);
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

  String _jalaliDate(DateTime date) {
    final j = _toJalali(date);
    return _digits('${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');
  }

  String _time(DateTime date) =>
      _digits('${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}');

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

  void _today() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _month = DateTime(now.year, now.month, 1);
      _selectedDay = today;
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<CalendarReminder> _forDay(DateTime day) => widget.reminders
      .where((item) => _sameDay(item.date, day))
      .toList(growable: false);

  Map<int, int> _countsForMonth() {
    final counts = <int, int>{};
    for (final reminder in widget.reminders) {
      if (reminder.date.year == _month.year && reminder.date.month == _month.month) {
        counts[reminder.date.day] = (counts[reminder.date.day] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final jalaliMonth = _toJalali(_month);
    final daysInMonth = _toGregorian(
      jalaliMonth.year,
      jalaliMonth.month == 12 ? 1 : jalaliMonth.month + 1,
      1,
    );
    final actualDays = jalaliMonth.month == 12
        ? _toGregorian(jalaliMonth.year + 1, 1, 1).difference(_month).inDays
        : daysInMonth.difference(_month).inDays;
    final first = _month;
    // Saturday = 0 ... Friday = 6.
    final leading = (first.weekday + 1) % 7;
    final counts = _countsForMonth();
    final selected = _selectedDay ?? first;
    final selectedReminders = _forDay(selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقویم پیگیری'),
        actions: [
          IconButton(
            onPressed: _today,
            tooltip: 'امروز',
            icon: const Icon(Icons.today_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _moveMonth(-1),
                  icon: const Icon(Icons.chevron_right),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _digits('${jalaliMonth.year}/${jalaliMonth.month.toString().padLeft(2, '0')}'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _moveMonth(1),
                  icon: const Icon(Icons.chevron_left),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: const [
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
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leading + actualDays,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 48,
              ),
              itemBuilder: (_, index) {
                if (index < leading) return const SizedBox.shrink();
                final day = index - leading + 1;
                final date = _toGregorian(jalaliMonth.year, jalaliMonth.month, day);
                final count = counts[date.day] ?? 0;
                final isSelected = _sameDay(date, selected);
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedDay = date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                        borderRadius: BorderRadius.circular(12),
                        border: count > 0
                            ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_digits('$day')),
                          if (count > 0)
                            Text(
                              _digits('$count'),
                              style: TextStyle(
                                fontSize: 11,
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
          const Divider(height: 1),
          Expanded(
            child: selectedReminders.isEmpty
                ? Center(
                    child: Text(
                      'برای این روز یادآوری ثبت نشده است',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedReminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = selectedReminders[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(item.completed ? Icons.check_circle : Icons.notifications_active_outlined),
                          title: Text(item.title),
                          subtitle: Text(
                            '${_jalaliDate(item.date)}  •  ساعت ${_time(item.date)}\n'
                            '${item.completed ? 'انجام‌شده' : 'در انتظار پیگیری'}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
