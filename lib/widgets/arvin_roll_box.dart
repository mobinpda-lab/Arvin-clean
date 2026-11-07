import 'package:flutter/material.dart';

import '../arvin_colors.dart';
import '../home/home_filter_ui.dart';

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
  final String createLabel;
  final Key? createItemKey;
  final bool compact;

  Future<void> _openSelector(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    Object? currentValue;
    if (emptyLabel != null && valueLabel == label) {
      currentValue = _ArvinClearToken.instance;
    } else {
      for (final item in items) {
        if (item.label == valueLabel) {
          currentValue = item.value;
          break;
        }
      }
    }

    final choice = await HomeFilterSheet.show<Object?>(
      context,
      title: 'انتخاب $label',
      accent: colors.primary,
      child: Builder(
        builder: (sheetContext) => RadioGroup<Object?>(
          groupValue: currentValue,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: [
              if (emptyLabel != null)
                RadioListTile<Object?>(
                  value: _ArvinClearToken.instance,
                  activeColor: colors.primary,
                  title: Text(emptyLabel!),
                ),
              for (final item in items)
                RadioListTile<Object?>(
                  value: item.value,
                  activeColor: colors.primary,
                  title: Text(item.label),
                  secondary: Icon(
                    item.icon ?? icon,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
              if (onCreate != null)
                ListTile(
                  key: createItemKey,
                  leading: Icon(
                    Icons.add_circle_outline_rounded,
                    color: colors.primary,
                  ),
                  title: Text(createLabel),
                  onTap: () => Navigator.of(sheetContext)
                      .pop(_ArvinCreateToken.instance),
                ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || choice == null) return;
    if (choice is _ArvinClearToken) {
      onSelected(null);
      return;
    }
    if (choice is _ArvinCreateToken) {
      final created = await onCreate?.call();
      if (context.mounted && created != null) onSelected(created);
      return;
    }
    onSelected(choice as T?);
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
    this.compact = false,
  });

  final List<String> tags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final Future<String?> Function()? onCreate;
  final bool compact;

  @override
  State<ArvinTagRollBox> createState() => _ArvinTagRollBoxState();
}

class _ArvinTagRollBoxState extends State<ArvinTagRollBox> {
  Future<void> _openSelector() async {
    final colors = Theme.of(context).colorScheme;
    final tags = widget.tags
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final working = <String>{...widget.selectedTags};

    final applied = await HomeFilterSheet.show<List<String>>(
      context,
      title: 'انتخاب برچسب',
      accent: colors.primary,
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final tag in tags)
                    CheckboxListTile(
                      dense: true,
                      activeColor: colors.primary,
                      value: working.contains(tag),
                      secondary: Icon(
                        Icons.sell_outlined,
                        color: colors.primary,
                      ),
                      title: Text(tag),
                      onChanged: (checked) => setSheetState(() {
                        if (checked == true) {
                          working.add(tag);
                        } else {
                          working.remove(tag);
                        }
                      }),
                    ),
                  if (widget.onCreate != null)
                    ListTile(
                      leading: Icon(
                        Icons.add_circle_outline,
                        color: colors.primary,
                      ),
                      title: const Text('+ افزودن برچسب'),
                      onTap: () async {
                        final created = await widget.onCreate!.call();
                        if (!sheetContext.mounted ||
                            created == null ||
                            created.trim().isEmpty) {
                          return;
                        }
                        setSheetState(() => working.add(created.trim()));
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('لغو'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext)
                        .pop(working.toList()..sort()),
                    child: const Text('اعمال'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!mounted || applied == null) return;
    widget.onChanged(applied);
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

class _ArvinCreateToken {
  const _ArvinCreateToken._();
  static const instance = _ArvinCreateToken._();
}

class _ArvinClearToken {
  const _ArvinClearToken._();
  static const instance = _ArvinClearToken._();
}
