import 'package:flutter/material.dart';

/// A reminder projected onto Arvin's calendar.
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

/// Internal calendar view for Arvin follow-up reminders.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.reminders});

  final List<CalendarReminder> reminders;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _moveMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDay = DateTime(_month.year, _month.month, 1);
    });
  }

  void _today() {
    final now = DateTime.now();
    setState(() {
      _month = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<CalendarReminder> _forDay(DateTime day) {
    return widget.reminders
        .where((item) => _sameDay(item.date, day))
        .toList(growable: false);
  }

  Map<int, int> _countsForMonth() {
    final counts = <int, int>{};
    for (final reminder in widget.reminders) {
      if (reminder.date.year == _month.year &&
          reminder.date.month == _month.month) {
        counts[reminder.date.day] = (counts[reminder.date.day] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final counts = _countsForMonth();
    final selected = _selectedDay ?? first;
    final selectedReminders = _forDay(selected);
    final rows = ((leading + daysInMonth) / 7).ceil();
    const cellHeight = 42.0;
    final gridHeight = rows * cellHeight + 8;

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
                      '${_month.year}/${_month.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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
                _Weekday('د'),
                _Weekday('س'),
                _Weekday('چ'),
                _Weekday('پ'),
                _Weekday('ج'),
                _Weekday('ش'),
                _Weekday('ی'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: SizedBox(
              height: gridHeight,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leading + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: cellHeight,
                ),
                itemBuilder: (_, index) {
                  if (index < leading) return const SizedBox.shrink();
                  final day = index - leading + 1;
                  final date = DateTime(_month.year, _month.month, day);
                  final count = counts[day] ?? 0;
                  final isSelected = _sameDay(date, selected);
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedDay = date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: count > 0
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day'),
                            if (count > 0)
                              Text(
                                '$count',
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
                          leading: Icon(
                            item.completed
                                ? Icons.check_circle
                                : Icons.notifications_active_outlined,
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            item.completed ? 'انجام‌شده' : 'در انتظار پیگیری',
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
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
