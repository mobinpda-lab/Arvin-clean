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
      accent: ArvinColors.primary,
      child: Builder(
        builder: (sheetContext) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: [
            if (emptyLabel != null)
              RadioListTile<Object?>(
                value: _ArvinClearToken.instance,
                groupValue: currentValue,
                activeColor: ArvinColors.primary,
                title: Text(emptyLabel!),
                onChanged: (value) =>
                    Navigator.of(sheetContext).pop(_ArvinClearToken.instance),
              ),
            for (final item in items)
              RadioListTile<Object?>(
                value: item.value,
                groupValue: currentValue,
                activeColor: ArvinColors.primary,
                title: Text(item.label),
                secondary: Icon(
                  item.icon ?? icon,
                  color: ArvinColors.primary,
                  size: 20,
                ),
                onChanged: (value) =>
                    Navigator.of(sheetContext).pop(item.value),
              ),
            if (onCreate != null)
              ListTile(
                key: createItemKey,
                leading: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: ArvinColors.primary,
                ),
                title: Text(createLabel),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_ArvinCreateToken.instance),
              ),
          ],
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
    return Tooltip(
      message: label,
      child: Material(
        color: selected ? ArvinColors.primarySoft : ArvinColors.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          key: key,
          onTap: () => _openSelector(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected
                    ? ArvinColors.primary.withAlpha(90)
                    : ArvinColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: ArvinColors.primary),
                SizedBox(width: compact ? 4 : 7),
                Expanded(
                  child: Text(
                    valueLabel.isEmpty ? label : valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ArvinColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: ArvinColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
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
      accent: ArvinColors.primary,
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
                      activeColor: ArvinColors.primary,
                      value: working.contains(tag),
                      secondary: const Icon(
                        Icons.sell_outlined,
                        color: ArvinColors.primary,
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
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: ArvinColors.primary,
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
    return Tooltip(
      message: 'برچسب',
      child: Material(
        color: selected.isEmpty ? ArvinColors.surface : ArvinColors.primarySoft,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          key: widget.key,
          onTap: _openSelector,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected.isEmpty
                    ? ArvinColors.border
                    : ArvinColors.primary.withAlpha(90),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: widget.compact ? 16 : 19,
                  color: ArvinColors.primary,
                ),
                SizedBox(width: widget.compact ? 4 : 7),
                Expanded(
                  child: Text(
                    selected.isEmpty ? 'برچسب' : '${selected.length} برچسب',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ArvinColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: widget.compact ? 16 : 19,
                  color: ArvinColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
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
