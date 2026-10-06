import 'package:flutter/material.dart';

enum ArvinPrimaryDestination {
  home,
  calendar,
  notebook,
  nextAction,
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
    final primary = const Color(0xFF4A4CAB);
    const background = Color(0xFFFDFDFE);
    const muted = Color(0xFF80829C);

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
        ArvinPrimaryDestination.nextAction,
        Icons.auto_awesome_outlined,
        Icons.auto_awesome_rounded,
        'اقدام بعدی',
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
          top: BorderSide(color: Color(0xFFE7E7F0), width: 1),
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
                    selected: selected == destination.$1,
                    icon: selected == destination.$1
                        ? destination.$3
                        : destination.$2,
                    label: destination.$4,
                    primary: primary,
                    muted: muted,
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
    required this.selected,
    required this.icon,
    required this.label,
    required this.primary,
    required this.muted,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color primary;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE9EAFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? primary : muted,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? primary : muted,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
