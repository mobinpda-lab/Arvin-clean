import 'package:flutter/material.dart';

import '../arvin_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object?>(
      tooltip: label,
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      onSelected: (value) async {
        if (value is _ArvinCreateToken) {
          final created = await onCreate?.call();
          if (created != null) onSelected(created);
          return;
        }
        if (value is _ArvinClearToken) {
          onSelected(null);
          return;
        }
        onSelected(value as T?);
      },
      itemBuilder: (context) => [
        if (emptyLabel != null) PopupMenuItem<Object?>(
          value: _ArvinClearToken.instance,
          child: Text(emptyLabel!),
        ),
        ...items.map((item) => PopupMenuItem<T>(
          value: item.value,
          child: Row(children: [
            Icon(item.icon ?? icon, size: 18, color: item.color ?? color),
            const SizedBox(width: 7),
            Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis))),
          ]),
        )),
        if (onCreate != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem<Object?>(
            value: _ArvinCreateToken.instance,
            child: Row(children: [
              const Icon(Icons.add_circle_outline, size: 18, color: ArvinColors.primary),
              const SizedBox(width: 9),
              Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(createLabel, maxLines: 1, overflow: TextOverflow.ellipsis))),
            ]),
          ),
        ],
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .42)),
        ),
        child: Row(children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 7),
          Expanded(child: Text(valueLabel.isEmpty ? label : valueLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800))),
          Icon(Icons.keyboard_arrow_down_rounded, size: 19, color: color),
        ]),
      ),
    );
  }
}

class ArvinRollItem<T> {
  const ArvinRollItem({required this.value, required this.label, this.icon, this.color});
  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
}

class ArvinTagRollBox extends StatefulWidget {
  const ArvinTagRollBox({super.key, required this.tags, required this.selectedTags, required this.onChanged, this.onCreate});
  final List<String> tags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final Future<String?> Function()? onCreate;
  @override State<ArvinTagRollBox> createState() => _ArvinTagRollBoxState();
}

class _ArvinTagRollBoxState extends State<ArvinTagRollBox> {
  Future<void> _create() async {
    final created = await widget.onCreate?.call();
    if (created == null || created.trim().isEmpty || !mounted) return;
    final next = List<String>.of(widget.selectedTags);
    if (!next.contains(created.trim())) next.add(created.trim());
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.tags.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList()..sort();
    final selected = widget.selectedTags.toSet();
    return PopupMenuButton<Object?>(
      tooltip: 'برچسب',
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      onSelected: (value) async {
        if (value is _ArvinCreateToken) { await _create(); return; }
        if (value is! String) return;
        final next = List<String>.of(widget.selectedTags);
        if (next.contains(value)) { next.remove(value); } else { next.add(value); }
        widget.onChanged(next);
      },
      itemBuilder: (context) => [
        ...tags.map((tag) => CheckedPopupMenuItem<String>(
          value: tag,
          checked: selected.contains(tag),
          child: Row(children: [
            const Icon(Icons.sell_outlined, size: 18, color: ArvinColors.tag),
            const SizedBox(width: 7),
            Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(tag, maxLines: 1, overflow: TextOverflow.ellipsis))),
          ]),
        )),
        if (widget.onCreate != null) ...[
          const PopupMenuDivider(),
          const PopupMenuItem<Object?>(
            value: _ArvinCreateToken.instance,
            child: Row(children: [
              Icon(Icons.add_circle_outline, size: 20, color: ArvinColors.primary),
              SizedBox(width: 9),
              Text('افزودن برچسب'),
            ]),
          ),
        ],
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: ArvinColors.tagSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: ArvinColors.tag.withValues(alpha: .42))),
        child: Row(children: [
          const Icon(Icons.sell_outlined, size: 19, color: ArvinColors.tag),
          const SizedBox(width: 7),
          Expanded(child: Text(selected.isEmpty ? 'برچسب' : '${selected.length} برچسب', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ArvinColors.tagDark, fontSize: 12, fontWeight: FontWeight.w800))),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 19, color: ArvinColors.tag),
        ]),
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