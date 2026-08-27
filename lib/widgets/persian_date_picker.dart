import 'package:flutter/material.dart';

import '../services/persian_date_formatter.dart';

Future<DateTime?> showPersianDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String helpText = 'انتخاب تاریخ',
  String cancelText = 'لغو',
  String confirmText = 'تأیید',
}) {
  final first = DateUtils.dateOnly(firstDate);
  final last = DateUtils.dateOnly(lastDate);
  assert(!last.isBefore(first));

  var initial = DateUtils.dateOnly(initialDate);
  if (initial.isBefore(first)) initial = first;
  if (initial.isAfter(last)) initial = last;

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: _PersianDatePickerDialog(
        initialDate: initial,
        firstDate: first,
        lastDate: last,
        helpText: helpText,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    ),
  );
}

class _PersianDatePickerDialog extends StatefulWidget {
  const _PersianDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.helpText,
    required this.cancelText,
    required this.confirmText,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String helpText;
  final String cancelText;
  final String confirmText;

  @override
  State<_PersianDatePickerDialog> createState() =>
      _PersianDatePickerDialogState();
}

class _PersianDatePickerDialogState extends State<_PersianDatePickerDialog> {
  static const _calendar = PersianDateFormatter();
  static const _weekdays = <String>['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  late JalaliDate _selected;
  late int _visibleYear;
  late int _visibleMonth;
  late JalaliDate _firstJalali;
  late JalaliDate _lastJalali;

  @override
  void initState() {
    super.initState();
    _selected = _calendar.toJalali(widget.initialDate);
    _visibleYear = _selected.year;
    _visibleMonth = _selected.month;
    _firstJalali = _calendar.toJalali(widget.firstDate);
    _lastJalali = _calendar.toJalali(widget.lastDate);
  }

  bool _isSameJalali(JalaliDate a, JalaliDate b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isAllowed(JalaliDate date) {
    final gregorian = _calendar.fromJalali(date);
    return !gregorian.isBefore(widget.firstDate) &&
        !gregorian.isAfter(widget.lastDate);
  }

  JalaliDate _monthShift(int delta) {
    final zeroBased = (_visibleYear * 12) + (_visibleMonth - 1) + delta;
    final year = zeroBased ~/ 12;
    final month = zeroBased % 12 + 1;
    return JalaliDate(year, month, 1);
  }

  bool _canShift(int delta) {
    final candidate = _monthShift(delta);
    final firstDay = _calendar.fromJalali(candidate);
    final lastDay = _calendar.fromJalali(
      JalaliDate(
        candidate.year,
        candidate.month,
        _calendar.monthLength(candidate.year, candidate.month),
      ),
    );
    return !lastDay.isBefore(widget.firstDate) &&
        !firstDay.isAfter(widget.lastDate);
  }

  void _shift(int delta) {
    if (!_canShift(delta)) return;
    final candidate = _monthShift(delta);
    setState(() {
      _visibleYear = candidate.year;
      _visibleMonth = candidate.month;
    });
  }

  void _selectYear(int? year) {
    if (year == null) return;
    var month = _visibleMonth;
    if (year == _firstJalali.year && month < _firstJalali.month) {
      month = _firstJalali.month;
    }
    if (year == _lastJalali.year && month > _lastJalali.month) {
      month = _lastJalali.month;
    }
    setState(() {
      _visibleYear = year;
      _visibleMonth = month;
    });
  }

  Widget _buildDayCell({
    required int index,
    required int firstOffset,
    required int daysInMonth,
    required JalaliDate today,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final day = index - firstOffset + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox(height: 38);
    }

    final value = JalaliDate(_visibleYear, _visibleMonth, day);
    final selected = _isSameJalali(value, _selected);
    final isToday = _isSameJalali(value, today);
    final enabled = _isAllowed(value);

    return SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          key: ValueKey('persian-date-day-$day'),
          borderRadius: BorderRadius.circular(999),
          onTap: enabled
              ? () => setState(() {
                    _selected = value;
                  })
              : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? colorScheme.primary : null,
              border: isToday && !selected
                  ? Border.all(color: colorScheme.primary)
                  : null,
            ),
            child: Center(
              child: Text(
                _calendar.toPersianDigits('$day'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: !enabled
                      ? colorScheme.onSurface.withValues(alpha: 0.35)
                      : selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthStart =
        _calendar.fromJalali(JalaliDate(_visibleYear, _visibleMonth, 1));
    final firstOffset = (monthStart.weekday + 1) % 7;
    final daysInMonth = _calendar.monthLength(_visibleYear, _visibleMonth);
    final today = _calendar.toJalali(DateTime.now());

    final years = <DropdownMenuItem<int>>[
      for (var year = _firstJalali.year; year <= _lastJalali.year; year++)
        DropdownMenuItem<int>(
          value: year,
          child: Text(_calendar.toPersianDigits('$year')),
        ),
    ];

    final dayCells = <Widget>[
      for (var index = 0; index < 42; index++)
        _buildDayCell(
          index: index,
          firstOffset: firstOffset,
          daysInMonth: daysInMonth,
          today: today,
          theme: theme,
          colorScheme: colorScheme,
        ),
    ];

    return AlertDialog(
      key: const ValueKey('persian-date-picker'),
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.helpText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_calendar.toPersianDigits('${_selected.day}')} '
            '${_calendar.monthName(_selected.month)} '
            '${_calendar.toPersianDigits('${_selected.year}')}',
            key: const ValueKey('persian-date-selected-label'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'ماه قبل',
                  onPressed: _canShift(-1) ? () => _shift(-1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _calendar.monthName(_visibleMonth),
                      key: const ValueKey('persian-date-month-name'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    key: const ValueKey('persian-date-year'),
                    value: _visibleYear,
                    items: years,
                    onChanged: _selectYear,
                  ),
                ),
                IconButton(
                  tooltip: 'ماه بعد',
                  onPressed: _canShift(1) ? () => _shift(1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final weekday in _weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (var row = 0; row < 6; row++)
                  TableRow(
                    children: [
                      for (var column = 0; column < 7; column++)
                        dayCells[(row * 7) + column],
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _calendar.fromJalali(_selected),
          ),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
