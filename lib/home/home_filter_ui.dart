// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

import '../core/theme/arvin_theme.dart';

enum HomeFilterDimension { time, center, project, category, tags }

class HomeFilterPill extends StatelessWidget {
  const HomeFilterPill({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.soft,
    required this.active,
    required this.onPressed,
    this.selectedCount = 0,
    this.showLabel = false,
    this.iconWidget,
  });

  /// Accessibility-only name; the compact Home row shows icons, not labels.
  final String label;
  final IconData icon;
  final Color accent;
  final Color soft;
  final bool active;
  final VoidCallback onPressed;
  final int selectedCount;
  final bool showLabel;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedSurface = Color.alphaBlend(accent.withAlpha(18), colors.surface);
    return Semantics(
      button: true,
      label: selectedCount > 0 ? '$label، $selectedCount انتخاب' : label,
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        height: 48,
        child: Material(
          color: active ? selectedSurface : colors.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: active ? accent.withAlpha(110) : colors.outline,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: showLabel
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            iconWidget ??
                                Icon(
                                  icon,
                                  size: 18,
                                  color: active ? accent : accent.withAlpha(205),
                                ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'VazirHarf',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: active ? accent : accent.withAlpha(205),
                                ),
                              ),
                            ),
                          ],
                        )
                      : iconWidget ??
                          Icon(
                            icon,
                            size: 20,
                            color: active ? accent : accent.withAlpha(205),
                          ),
                ),
                if (selectedCount > 0)
                  Positioned(
                    top: 1,
                    right: 2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
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
    this.active,
  });

  final HomeFilterDimension dimension;
  final String title;
  final String value;
  final Color accent;
  final Color soft;
  final IconData icon;
  final VoidCallback onTap;
  final bool? active;

  @override
  Widget build(BuildContext context) {
    final selected = active ?? value != 'همه';
    final colors = Theme.of(context).colorScheme;
    final selectedAccent = colors.primary;
    final selectedSoft = Color.alphaBlend(selectedAccent.withAlpha(18), colors.surface);
    final compact = MediaQuery.sizeOf(context).height < 700;
    return Expanded(
      child: Semantics(
        button: true,
        label: title + ': ' + value,
        child: Material(
          color: selected ? Color.alphaBlend(selectedAccent.withAlpha(22), selectedSoft) : colors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: ValueKey('home-filter-card-' + dimension.name),
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              height: compact ? 72 : 88,
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: compact ? 4 : 7),
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(selectedAccent.withAlpha(18), selectedSoft)
                    : colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? selectedAccent.withAlpha(150) : colors.outline,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ArvinTheme.shadowFor(context),
                    blurRadius: selected ? 9 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: selectedAccent, size: compact ? 18 : 20),
                  SizedBox(height: compact ? 3 : 5),
                  Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selectedAccent.withAlpha(235),
                      fontSize: compact ? 10 : 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: compact ? 1 : 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selectedAccent,
                        fontSize: compact ? 10.5 : 11.5,
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
    final colors = Theme.of(context).colorScheme;
    final chipAccent = colors.primary;
    final chipSoft = Color.alphaBlend(chipAccent.withAlpha(18), colors.surface);
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      decoration: BoxDecoration(
        color: chipSoft,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: chipAccent.withAlpha(65)),
      ),
      padding: const EdgeInsetsDirectional.only(start: 8, end: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 15, color: chipAccent),
          if (icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: chipAccent,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: onRemove,
            tooltip: 'حذف فیلتر',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 16, color: chipAccent),
          ),
        ],
      ),
    );
  }
}

/// Product-grade Home selection panel.
///
/// Arvin-specific bottom-sheet presentation for the five Home filters.
/// The same selection flow is reused by time, project, category and tag filters.
class HomeFilterSheet extends StatelessWidget {
  const HomeFilterSheet({
    super.key,
    required this.title,
    required this.accent,
    required this.child,
    this.heightFactor = .76,
    this.expandToMaxHeight = false,
  });

  final String title;
  final Color accent;
  final Widget child;
  final double heightFactor;
  final bool expandToMaxHeight;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = height - keyboardInset;
    final requestedHeight = availableHeight * heightFactor;
    final sheetHeight = requestedHeight < 220
        ? (availableHeight < 220 ? availableHeight : 220.0)
        : requestedHeight;
    final minSheetHeight = expandToMaxHeight
        ? sheetHeight
        : (sheetHeight < 220 ? sheetHeight : 220.0);
    final colors = Theme.of(context).colorScheme;
    final brandAccent = colors.primary;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: sheetHeight,
          minHeight: minSheetHeight,
        ),
        child: Material(
          color: colors.surface,
          elevation: 2,
          shadowColor: ArvinTheme.shadowFor(context),
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              mainAxisSize: expandToMaxHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: brandAccent.withAlpha(70),
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
                        color: brandAccent.withAlpha(22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune_rounded, color: brandAccent, size: 20),
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
    double heightFactor = .76,
    bool expandToMaxHeight = false,
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
        heightFactor: heightFactor,
        expandToMaxHeight: expandToMaxHeight,
        child: child,
      ),
    );
  }
}
