import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../arvin_colors.dart';
import '../services/persian_date_formatter.dart';

/// Opens Arvin's canonical 24-hour time-only picker.
///
/// The result is a [TimeOfDay] so callers can keep their existing canonical
/// date, Task, reminder, recurrence, and scheduling models unchanged.
Future<TimeOfDay?> showUniversalArvinTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required String helpText,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQuery.of(dialogContext).copyWith(
          alwaysUse24HourFormat: true,
        ),
        child: _UniversalArvinTimePickerDialog(
          initialTime: initialTime,
          title: helpText,
        ),
      ),
    ),
  );
}

class _UniversalArvinTimePickerDialog extends StatefulWidget {
  const _UniversalArvinTimePickerDialog({
    required this.initialTime,
    required this.title,
  });

  final TimeOfDay initialTime;
  final String title;

  @override
  State<_UniversalArvinTimePickerDialog> createState() =>
      _UniversalArvinTimePickerDialogState();
}

class _UniversalArvinTimePickerDialogState
    extends State<_UniversalArvinTimePickerDialog> {
  static const _formatter = PersianDateFormatter();

  late int _hour;
  late int _minute;
  bool _choosingMinute = false;
  bool _manualEntry = false;
  bool _manualValid = true;
  late final TextEditingController _manualController;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _manualController = TextEditingController(text: _clockText);
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  String get _clockText =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  String get _persianClockText => _formatter.toPersianDigits(_clockText);

  int? _readDigits(String value) {
    final normalized = value
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9')
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
    return int.tryParse(normalized);
  }

  void _selectHour(int value) {
    setState(() {
      _hour = value;
      _choosingMinute = true;
      _manualController.text = _clockText;
    });
  }

  void _selectMinute(int value) {
    setState(() {
      _minute = value;
      _manualController.text = _clockText;
    });
  }

  void _applyManualEntry() {
    final pieces = _manualController.text.trim().split(':');
    final hour = pieces.length == 2 ? _readDigits(pieces[0].trim()) : null;
    final minute = pieces.length == 2 ? _readDigits(pieces[1].trim()) : null;
    final valid = hour != null &&
        minute != null &&
        hour >= 0 &&
        hour <= 23 &&
        minute >= 0 &&
        minute <= 59;
    setState(() {
      _manualValid = valid;
      if (valid) {
        _hour = hour;
        _minute = minute;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ArvinColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 360,
          // Keep the dialog inside the usable viewport on short screens and
          // landscape layouts; the scroll view handles content beyond this.
          maxHeight: (MediaQuery.sizeOf(context).height - 48).clamp(240.0, 690.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: ArvinColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ArvinColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Semantics(
                  key: const ValueKey('universal-time-selected-value'),
                  label: _persianClockText,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.ltr,
                  children: [
                    _digitalSegment(_formatter.toPersianDigits(_hour.toString().padLeft(2, '0')), segmentKey: 'universal-time-hour-value', selected: !_choosingMinute && !_manualEntry, onTap: () => setState(() { _choosingMinute = false; _manualEntry = false; })),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 3), child: Text(':', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700))),
                    _digitalSegment(_formatter.toPersianDigits(_minute.toString().padLeft(2, '0')), segmentKey: 'universal-time-minute-value', selected: _choosingMinute && !_manualEntry, onTap: () => setState(() { _choosingMinute = true; _manualEntry = false; })),
                  ],
                ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stageButton('ساعت', !_choosingMinute, () {
                    setState(() {
                      _choosingMinute = false;
                      _manualEntry = false;
                    });
                  }),
                  const SizedBox(width: 8),
                  _stageButton('دقیقه', _choosingMinute, () {
                    setState(() {
                      _choosingMinute = true;
                      _manualEntry = false;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 8),
              if (_manualEntry)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: TextField(
                    key: const ValueKey('universal-time-manual-input'),
                    controller: _manualController,
                    autofocus: true,
                    keyboardType: TextInputType.datetime,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'ساعت دقیق (۲۴ ساعته)',
                      hintText: '۱۴:۳۷',
                      helperText: 'ساعت و دقیقه را با : جدا کنید',
                      errorText: _manualValid ? null : 'ساعت معتبر وارد کنید؛ نمونه: ۱۴:۳۷',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) => _applyManualEntry(),
                  ),
                )
              else
                _ClockFace(
                  choosingMinute: _choosingMinute,
                  hour: _hour,
                  minute: _minute,
                  onHourSelected: _selectHour,
                  onMinuteSelected: _selectMinute,
                ),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  key: const ValueKey('universal-time-manual-toggle'),
                  onPressed: () {
                    setState(() {
                      _manualEntry = !_manualEntry;
                      _manualController.text = _clockText;
                    });
                  },
                  icon: Icon(_manualEntry ? Icons.schedule : Icons.keyboard),
                  label: Text(_manualEntry ? 'صفحه ساعت' : 'ورود ساعت دقیق'),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('universal-time-cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ArvinColors.textPrimary,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('لغو'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('universal-time-save'),
                      onPressed: _manualEntry && !_manualValid
                          ? null
                          : () => Navigator.of(context).pop(
                                TimeOfDay(hour: _hour, minute: _minute),
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: ArvinColors.primary,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('ذخیره'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _digitalSegment(String value, {required String segmentKey, required bool selected, required VoidCallback onTap}) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        key: ValueKey(segmentKey),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: selected ? Colors.white : Colors.transparent, width: 3))),
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
          ),
        ),
      ),
    );
  }

  Widget _stageButton(String label, bool selected, VoidCallback onPressed) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
      selectedColor: ArvinColors.primarySoft,
      labelStyle: TextStyle(
        color: selected ? ArvinColors.primary : ArvinColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? ArvinColors.primary : ArvinColors.border,
      ),
    );
  }
}

class _ClockFace extends StatelessWidget {
  static const _formatter = PersianDateFormatter();
  const _ClockFace({
    required this.choosingMinute,
    required this.hour,
    required this.minute,
    required this.onHourSelected,
    required this.onMinuteSelected,
  });

  final bool choosingMinute;
  final int hour;
  final int minute;
  final ValueChanged<int> onHourSelected;
  final ValueChanged<int> onMinuteSelected;

  @override
  Widget build(BuildContext context) {
    const size = 240.0;
    const center = size / 2;
    final values = choosingMinute
        ? List<int>.generate(12, (index) => index * 5)
        : List<int>.generate(12, (index) => index == 0 ? 12 : index);
    final children = <Widget>[
      Positioned(
        left: center - 2,
        top: center - 2,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: ArvinColors.primary,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 4, height: 4),
        ),
      ),
    ];

    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      final angle = (index * 2 * math.pi / 12) - math.pi / 2;
      final isSelected = choosingMinute
          ? minute == value
          : hour == value;
      const radius = 94.0;
      final x = center + radius * math.cos(angle);
      final y = center + radius * math.sin(angle);
      final labelValue = _formatter.toPersianDigits(
        choosingMinute
            ? value.toString().padLeft(2, '0')
            : value.toString(),
      );
      children.add(
        Positioned(
          left: x - 19,
          top: y - 19,
          child: Semantics(
            button: true,
            selected: isSelected,
            label: choosingMinute
                ? 'دقیقه ${value.toString().padLeft(2, '0')}'
                : 'ساعت $labelValue',
            child: InkWell(
              key: ValueKey(choosingMinute
                  ? 'universal-time-minute-$value'
                  : 'universal-time-hour-outer-$value'),
              customBorder: const CircleBorder(),
              onTap: () {
                if (choosingMinute) {
                  onMinuteSelected(value);
                } else {
                  onHourSelected(value);
                }
              },
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? ArvinColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  labelValue,
                  style: TextStyle(
                    color: isSelected ? Colors.white : ArvinColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!choosingMinute) {
      final innerValues = List<int>.generate(12, (index) => index == 0 ? 0 : index + 12);
      for (var index = 0; index < innerValues.length; index++) {
        final value = innerValues[index];
        final angle = (index * 2 * math.pi / 12) - math.pi / 2;
        final x = center + 64 * math.cos(angle);
        final y = center + 64 * math.sin(angle);
        final isSelected = hour == value;
        final display = _formatter.toPersianDigits(
          value == 0 ? '24' : value.toString(),
        );
        children.add(
          Positioned(
            left: x - 15,
            top: y - 15,
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'ساعت $display',
              child: InkWell(
                key: ValueKey('universal-time-hour-inner-$display'),
                customBorder: const CircleBorder(),
                onTap: () => onHourSelected(value),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? ArvinColors.primary : ArvinColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    display,
                    style: TextStyle(
                      color: isSelected ? Colors.white : ArvinColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: ArvinColors.background,
          shape: BoxShape.circle,
        ),
        child: Stack(children: children),
      ),
    );
  }
}