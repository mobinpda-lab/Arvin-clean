import 'package:flutter/material.dart';

/// Accessible 48dp Home action for explicitly selecting a Task for today's focus.
class TodayFocusToggleButton extends StatelessWidget {
  const TodayFocusToggleButton({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: selected
          ? 'برداشتن از برگزیده‌های امروز'
          : 'افزودن به برگزیده‌های امروز',
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(
        selected ? Icons.push_pin_rounded : Icons.push_pin_outlined,
        color: selected ? colors.primary : colors.onSurfaceVariant,
      ),
    );
  }
}
