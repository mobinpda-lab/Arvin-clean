import 'package:flutter/material.dart';

class ArvinRadioBox extends StatelessWidget {
  const ArvinRadioBox({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accent = const Color(0xFF4A4CAB),
    this.softAccent,
    this.newOption = false,
    this.subtitle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color accent;
  final Color? softAccent;
  final bool newOption;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final soft = softAccent ?? accent.withValues(alpha: 0.10);
    final border = selected ? accent : accent.withValues(alpha: 0.35);
    final background = selected ? soft.withValues(alpha: 0.95) : soft.withValues(alpha: 0.62);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: selected ? 1.6 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  newOption ? Icons.add_circle_outline_rounded : (icon ?? Icons.radio_button_checked_rounded),
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: const Color(0xFF232433))),
                      if (subtitle != null) Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: selected ? accent : accent.withValues(alpha: 0.82))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
