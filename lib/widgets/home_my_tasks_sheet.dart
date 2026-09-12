import 'package:flutter/material.dart';

enum HomeTaskFilterKind {
  all,
  today,
  followUp,
  withoutFollowUp,
  completed,
  incomplete,
  category,
}

class HomeTaskFilterSelection {
  const HomeTaskFilterSelection(this.kind, {this.category});

  final HomeTaskFilterKind kind;
  final String? category;
}

Future<HomeTaskFilterSelection?> showHomeMyTasksSheet({
  required BuildContext context,
  required Iterable<String> categories,
}) {
  final normalizedCategories = categories
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return showModalBottomSheet<HomeTaskFilterSelection>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(
                'کارهای من',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            _FilterTile(
              key: const ValueKey('home-my-tasks-all'),
              icon: Icons.list_alt_outlined,
              title: 'همه کارها',
              selection: const HomeTaskFilterSelection(HomeTaskFilterKind.all),
            ),
            _FilterTile(
              key: const ValueKey('home-my-tasks-today'),
              icon: Icons.today_outlined,
              title: 'کار امروز',
              selection: const HomeTaskFilterSelection(HomeTaskFilterKind.today),
            ),
            _FilterTile(
              key: const ValueKey('home-my-tasks-followup'),
              icon: Icons.follow_the_signs_outlined,
              title: 'پیگیری‌دار',
              selection:
                  const HomeTaskFilterSelection(HomeTaskFilterKind.followUp),
            ),
            _FilterTile(
              key: const ValueKey('home-my-tasks-without-followup'),
              icon: Icons.playlist_remove_outlined,
              title: 'بدون پیگیری',
              selection: const HomeTaskFilterSelection(
                HomeTaskFilterKind.withoutFollowUp,
              ),
            ),
            _FilterTile(
              key: const ValueKey('home-my-tasks-completed'),
              icon: Icons.check_circle_outline,
              title: 'انجام‌شده',
              selection:
                  const HomeTaskFilterSelection(HomeTaskFilterKind.completed),
            ),
            _FilterTile(
              key: const ValueKey('home-my-tasks-incomplete'),
              icon: Icons.radio_button_unchecked,
              title: 'انجام‌نشده',
              selection:
                  const HomeTaskFilterSelection(HomeTaskFilterKind.incomplete),
            ),
            if (normalizedCategories.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Text(
                  'دسته‌ها',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              for (final category in normalizedCategories)
                ListTile(
                  key: ValueKey('home-my-tasks-category-$category'),
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(category),
                  onTap: () => Navigator.of(sheetContext).pop(
                    HomeTaskFilterSelection(
                      HomeTaskFilterKind.category,
                      category: category,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    super.key,
    required this.icon,
    required this.title,
    required this.selection,
  });

  final IconData icon;
  final String title;
  final HomeTaskFilterSelection selection;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.of(context).pop(selection),
    );
  }
}
