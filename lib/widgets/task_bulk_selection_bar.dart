import 'package:flutter/material.dart';

/// Reusable bulk-selection surface for canonical Task/Note lists.
///
/// This widget owns no selection state or persistence. Callers keep canonical
/// IDs/state and wire actions to the existing mutation/report foundations.
class TaskBulkSelectionBar extends StatelessWidget {
  const TaskBulkSelectionBar({
    super.key,
    required this.selectedCount,
    required this.allVisibleSelected,
    required this.onToggleAll,
    required this.onClearSelection,
    this.onTrash,
    this.onCategory,
    this.onTags,
    this.onShare,
  }) : assert(selectedCount >= 0);

  final int selectedCount;
  final bool allVisibleSelected;
  final VoidCallback onToggleAll;
  final VoidCallback onClearSelection;
  final VoidCallback? onTrash;
  final VoidCallback? onCategory;
  final VoidCallback? onTags;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('task-bulk-selection-bar'),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              final summary = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const ValueKey('task-bulk-clear'),
                    tooltip: 'لغو انتخاب',
                    onPressed: onClearSelection,
                    icon: const Icon(Icons.close),
                  ),
                  Text(
                    '$selectedCount انتخاب',
                    key: const ValueKey('task-bulk-count'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    key: const ValueKey('task-bulk-select-all'),
                    onPressed: onToggleAll,
                    icon: Icon(
                      allVisibleSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    label: Text(allVisibleSelected ? 'لغو همه' : 'انتخاب همه'),
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.end,
                children: [
                  IconButton(
                    key: const ValueKey('task-bulk-share'),
                    tooltip: 'اشتراک / خروجی',
                    onPressed: onShare,
                    icon: const Icon(Icons.ios_share_outlined),
                  ),
                  IconButton(
                    key: const ValueKey('task-bulk-tags'),
                    tooltip: 'برچسب‌ها',
                    onPressed: onTags,
                    icon: const Icon(Icons.sell_outlined),
                  ),
                  IconButton(
                    key: const ValueKey('task-bulk-category'),
                    tooltip: 'تغییر دسته',
                    onPressed: onCategory,
                    icon: const Icon(Icons.folder_outlined),
                  ),
                  IconButton(
                    key: const ValueKey('task-bulk-trash'),
                    tooltip: 'انتقال به سطل زباله',
                    onPressed: onTrash,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              );

              final scrollableSummary = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: summary,
              );

              if (compact) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    scrollableSummary,
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerLeft, child: actions),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: scrollableSummary),
                  const SizedBox(width: 4),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
