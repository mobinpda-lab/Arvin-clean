import 'package:flutter/material.dart';

class ArvinRadioBox extends StatelessWidget {
  const ArvinRadioBox({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accent = const Color(0xFF4A4CAB),
    this.newOption = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color accent;
  final bool newOption;

  @override
  Widget build(BuildContext context) {
    final border = selected ? accent : const Color(0xFFE1E2EA);
    final background = selected ? accent.withValues(alpha: 0.10) : const Color(0xFFFDFDFE);
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
                  color: selected ? accent : const Color(0xFF7D7F95),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF232433),
                    ),
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
