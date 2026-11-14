import 'package:flutter/material.dart';

import '../arvin_colors.dart';

enum ArvinPrimaryDestination {
  home,
  calendar,
  notebook,
  reports,
  more,
}

class ArvinPrimaryNavigation extends StatelessWidget {
  const ArvinPrimaryNavigation({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ArvinPrimaryDestination selected;
  final ValueChanged<ArvinPrimaryDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const background = ArvinColors.surface;
    const muted = ArvinColors.textSecondary;
    final selectedSurface = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD9F0EE)
        : ArvinColors.primarySoft;
    const iconColors = <ArvinPrimaryDestination, Color>{
      ArvinPrimaryDestination.home: Color(0xFF0F766E),
      ArvinPrimaryDestination.calendar: Color(0xFF2A9D8F),
      ArvinPrimaryDestination.notebook: Color(0xFFC76B16),
      ArvinPrimaryDestination.reports: Color(0xFF8E6CCF),
      ArvinPrimaryDestination.more: Color(0xFF219EBC),
    };

    const destinations = [
      (
        ArvinPrimaryDestination.home,
        Icons.home_outlined,
        Icons.home_rounded,
        'خانه',
      ),
      (
        ArvinPrimaryDestination.calendar,
        Icons.calendar_month_outlined,
        Icons.calendar_month_rounded,
        'تقویم',
      ),
      (
        ArvinPrimaryDestination.notebook,
        Icons.note_alt_outlined,
        Icons.note_alt_rounded,
        'دفترچه',
      ),
      (
        ArvinPrimaryDestination.reports,
        Icons.assessment_outlined,
        Icons.assessment_rounded,
        'گزارش‌ها',
      ),
      (
        ArvinPrimaryDestination.more,
        Icons.more_horiz_rounded,
        Icons.more_horiz_rounded,
        'بیشتر',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(color: ArvinColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final destination in destinations)
                Expanded(
                  child: _NavigationItem(
                    key: destination.$1 == ArvinPrimaryDestination.more
                        ? const ValueKey('primary-nav-more')
                        : null,
                    selected: selected == destination.$1,
                    icon: selected == destination.$1
                        ? destination.$3
                        : destination.$2,
                    label: destination.$4,
                    primary: primary,
                    muted: muted,
                    selectedSurface: selectedSurface,
                    iconColor: iconColors[destination.$1]!,
                    onTap: () => onSelected(destination.$1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.primary,
    required this.muted,
    required this.selectedSurface,
    required this.iconColor,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color primary;
  final Color muted;
  final Color selectedSurface;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: selected ? selectedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? primary : muted,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArvinPrimaryPageShell extends StatelessWidget {
  const ArvinPrimaryPageShell({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.child,
  });

  final ArvinPrimaryDestination selected;
  final ValueChanged<ArvinPrimaryDestination> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: child,
        bottomNavigationBar: ArvinPrimaryNavigation(
          selected: selected,
          onSelected: onSelected,
        ),
      ),
    );
  }
}
