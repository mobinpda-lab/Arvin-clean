// Analyzer cleanup: these are style-only lints; no product behavior is affected.
// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

import '../arvin_colors.dart';

enum HomeFilterDimension { time, project, category, tags }

class HomeFilterCard extends StatelessWidget {
  const HomeFilterCard({
    super.key,
    required this.dimension,
    required this.title,
    required this.value,
    required this.accent,
    required this.soft,
    required this.icon,
    required this.onTap,
  });

  final HomeFilterDimension dimension;
  final String title;
  final String value;
  final Color accent;
  final Color soft;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value != 'همه';
    return Semantics(
        button: true,
        label: title + ': ' + value,
        child: Material(
          color: selected ? Color.alphaBlend(accent.withAlpha(22), soft) : soft,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            key: ValueKey('home-filter-card-' + dimension.name),
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 104,
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? accent.withAlpha(150) : accent.withAlpha(45),
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: accent, size: 23),
                  const SizedBox(height: 7),
                  Text(title, maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: accent.withAlpha(235), fontSize: 11.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value, maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: accent, fontSize: 12.5, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class HomeFilterChip extends StatelessWidget {
  const HomeFilterChip({
    super.key,
    required this.label,
    required this.accent,
    required this.soft,
    required this.onRemove,
    this.icon,
  });

  final String label;
  final Color accent;
  final Color soft;
  final VoidCallback onRemove;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: accent.withAlpha(65)),
      ),
      padding: const EdgeInsetsDirectional.only(start: 8, end: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 15, color: accent),
          if (icon != null) const SizedBox(width: 4),
          Text(label, style: TextStyle(color: accent, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(width: 2),
          IconButton(
            onPressed: onRemove,
            tooltip: 'حذف فیلتر',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 16, color: accent),
          ),
        ],
      ),
    );
  }
}

class HomeFilterSheet extends StatelessWidget {
  const HomeFilterSheet({
    super.key,
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'بستن',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                const SizedBox(width: 2),
                Icon(Icons.tune_rounded, color: accent, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
              ],
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>(BuildContext context, {
    required String title,
    required Color accent,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ArvinColors.surface,
      barrierColor: Colors.black.withAlpha(45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => HomeFilterSheet(title: title, accent: accent, child: child),
    );
  }
}
