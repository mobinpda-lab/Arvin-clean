import 'package:flutter/material.dart';

class JalaliDateSelection {
  const JalaliDateSelection({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

Future<JalaliDateSelection?> showJalaliDateJumpDialog(
  BuildContext context, {
  required int initialYear,
  required int initialMonth,
  required int initialDay,
  required int Function(int year, int month) daysInMonth,
}) {
  return showDialog<JalaliDateSelection>(
    context: context,
    builder: (context) => _JalaliDateJumpDialog(
      initialYear: initialYear,
      initialMonth: initialMonth,
      initialDay: initialDay,
      daysInMonth: daysInMonth,
    ),
  );
}

class _JalaliDateJumpDialog extends StatefulWidget {
  const _JalaliDateJumpDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
    required this.daysInMonth,
  });

  final int initialYear;
  final int initialMonth;
  final int initialDay;
  final int Function(int year, int month) daysInMonth;

  @override
  State<_JalaliDateJumpDialog> createState() => _JalaliDateJumpDialogState();
}

class _JalaliDateJumpDialogState extends State<_JalaliDateJumpDialog> {
  static const _monthNames = <String>[
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

  late int _year;
  late int _month;
  late int _day;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth.clamp(1, 12);
    _day = widget.initialDay.clamp(1, widget.daysInMonth(_year, _month));
  }

  void _normalizeDay() {
    final maxDay = widget.daysInMonth(_year, _month);
    _day = _day.clamp(1, maxDay);
  }

  @override
  Widget build(BuildContext context) {
    final maxDay = widget.daysInMonth(_year, _month);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('برو به تاریخ'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                key: const ValueKey('calendar-jump-year'),
                initialValue: _year,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'سال'),
                items: [
                  for (var year = _year - 10; year <= _year + 10; year++)
                    DropdownMenuItem(value: year, child: Text('$year')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _year = value;
                    _normalizeDay();
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: const ValueKey('calendar-jump-month'),
                initialValue: _month,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'ماه'),
                items: [
                  for (var month = 1; month <= 12; month++)
                    DropdownMenuItem(
                      value: month,
                      child: Text(
                        _monthNames[month - 1],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _month = value;
                    _normalizeDay();
                  });
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'روز'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    key: const ValueKey('calendar-jump-day'),
                    value: _day,
                    isExpanded: true,
                    items: [
                      for (var day = 1; day <= maxDay; day++)
                        DropdownMenuItem(value: day, child: Text('$day')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _day = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const ValueKey('calendar-jump-cancel'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const ValueKey('calendar-jump-apply'),
            onPressed: () => Navigator.of(context).pop(
              JalaliDateSelection(year: _year, month: _month, day: _day),
            ),
            child: const Text('رفتن'),
          ),
        ],
      ),
    );
  }
}
