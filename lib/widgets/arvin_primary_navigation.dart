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
    return NavigationBar(
      selectedIndex: selected.index,
      onDestinationSelected: (index) =>
          onSelected(ArvinPrimaryDestination.values[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'خانه',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'تقویم',
        ),
        NavigationDestination(
          icon: Icon(Icons.note_alt_outlined),
          selectedIcon: Icon(Icons.note_alt),
          label: 'دفترچه',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: 'اقدام بعدی',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'بیشتر',
        ),
      ],
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
