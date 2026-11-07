import 'package:flutter/material.dart';
import '../home/home_filter_ui.dart';
import 'reusable_multi_select_filter_bottom_sheet.dart';

class ArvinRollBox<T> extends StatelessWidget {
  const ArvinRollBox({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.items,
    required this.onSelected,
    required this.icon,
    required this.color,
    this.emptyLabel,
    this.onCreate,
    this.onCreateWithName,
    this.createLabel = 'افزودن',
    this.createItemKey,
    this.compact = false,
  });

  final String label;
  final String valueLabel;
  final List<ArvinRollItem<T>> items;
  final ValueChanged<T?> onSelected;
  final IconData icon;
  final Color color;
  final String? emptyLabel;
  final Future<T?> Function()? onCreate;
  final Future<ReusableFilterOption<T>?> Function(String value)? onCreateWithName;
  final String createLabel;
  final Key? createItemKey;
  final bool compact;

  Future<void> _openSelector(BuildContext context) async {
    Object? currentValue;
    if (emptyLabel != null && valueLabel == label) {
      currentValue = null;
    } else {
      for (final item in items) {
        if (item.label == valueLabel) {
          currentValue = item.value;
          break;
        }
      }
    }

    final create = onCreateWithName ??
        (onCreate == null
            ? null
            : (String _) async {
                final created = await onCreate!.call();
                if (created == null) return null;
                final existing = items.where((item) => item.value == created);
                return ReusableFilterOption<T>(
                  value: created,
                  label: existing.isNotEmpty ? existing.first.label : created.toString(),
                );
              });
    final result = await ReusableMultiSelectFilterBottomSheet.showSingleSelect<T>(
      context,
      title: 'انتخاب $label',
      accent: Theme.of(context).colorScheme.primary,
      options: items
          .map((item) => ReusableFilterOption<T>(
                value: item.value,
                label: item.label,
                icon: item.icon ?? icon,
              ))
          .toList(growable: false),
      selectedValue: currentValue as T?,
      emptyLabel: emptyLabel,
      createLabel: createLabel,
      createKey: createItemKey,
      onCreate: create,
    );

    if (!context.mounted || result == null) return;
    onSelected(result.cleared ? null : result.value);
  }

  @override
  Widget build(BuildContext context) {
    final selected = valueLabel.isNotEmpty && valueLabel != label;
    return HomeFilterPill(
      label: valueLabel.isEmpty ? label : valueLabel,
      icon: icon,
      accent: Theme.of(context).colorScheme.primary,
      soft: Color.alphaBlend(Theme.of(context).colorScheme.primary.withAlpha(18), Theme.of(context).colorScheme.surface),
      active: selected,
      onPressed: () => _openSelector(context),
    );
  }
}

class ArvinRollItem<T> {
  const ArvinRollItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
}

class ArvinTagRollBox extends StatefulWidget {
  const ArvinTagRollBox({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onChanged,
    this.onCreate,
    this.onCreateWithName,
    this.compact = false,
  });

  final List<String> tags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final Future<String?> Function()? onCreate;
  final Future<String?> Function(String value)? onCreateWithName;
  final bool compact;

  @override
  State<ArvinTagRollBox> createState() => _ArvinTagRollBoxState();
}

class _ArvinTagRollBoxState extends State<ArvinTagRollBox> {
  Future<void> _openSelector() async {
    final tags = widget.tags
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final create = widget.onCreateWithName ??
        (widget.onCreate == null
            ? null
            : (String _) async {
                final created = await widget.onCreate!.call();
                if (created == null || created.trim().isEmpty) return null;
                return ReusableFilterOption<String>(
                  value: created.trim(),
                  label: created.trim(),
                );
              });
    final applied = await ReusableMultiSelectFilterBottomSheet.showMultiSelect<String>(
      context,
      title: 'انتخاب برچسب',
      accent: Theme.of(context).colorScheme.primary,
      options: tags
          .map((tag) => ReusableFilterOption<String>(
                value: tag,
                label: tag,
                icon: Icons.sell_outlined,
              ))
          .toList(growable: false),
      selectedValues: widget.selectedTags.toSet(),
      searchHint: 'جستجو در برچسب‌ها...',
      createHint: 'نام برچسب جدید',
      createLabel: '+ افزودن برچسب',
      onCreate: create,
    );

    if (!mounted || applied == null) return;
    widget.onChanged(applied.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedTags.toSet();
    return HomeFilterPill(
      label: selected.isEmpty ? 'برچسب' : '${selected.length} برچسب',
      icon: Icons.sell_outlined,
      accent: Theme.of(context).colorScheme.primary,
      soft: Color.alphaBlend(Theme.of(context).colorScheme.primary.withAlpha(18), Theme.of(context).colorScheme.surface),
      active: selected.isNotEmpty,
      onPressed: _openSelector,
    );
  }
}

