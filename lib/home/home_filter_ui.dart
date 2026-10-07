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
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: title + ': ' + value,
        child: Material(
          color: selected ? Color.alphaBlend(accent.withAlpha(28), soft) : soft,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            key: ValueKey('home-filter-card-' + dimension.name),
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 104),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Color.alphaBlend(accent.withAlpha(20), soft) : soft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? accent.withAlpha(170) : accent.withAlpha(55),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(selected ? 12 : 6),
                    blurRadius: selected ? 8 : 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: accent, size: 21),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent.withAlpha(240),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
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
    return Semantics(
      button: true,
      label: 'فیلتر $label، حذف',
      child: Container(
        constraints: const BoxConstraints(minHeight: 34),
        decoration: BoxDecoration(
          color: soft,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: accent.withAlpha(65)),
        ),
        padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 14, color: accent),
            if (icon != null) const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: 'حذف فیلتر $label',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close_rounded, size: 15, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product-grade Home selection panel.
///
/// Arvin-specific bottom-sheet presentation for the four Home filters.
/// The same selection flow is reused by time, project, category and tag filters.
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
    final height = MediaQuery.sizeOf(context).height;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: height * .76,
          minHeight: 220,
        ),
        child: Material(
          color: ArvinColors.surface,
          elevation: 12,
          shadowColor: Colors.black.withAlpha(35),
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(70),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'بستن',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Color accent,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(55),
      builder: (_) => HomeFilterSheet(
        title: title,
        accent: accent,
        child: child,
      ),
    );
  }
}
