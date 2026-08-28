import 'package:flutter/material.dart';

/// Reusable editor field for Arvin's canonical Task.category.
///
/// Category stays independent from Tags and Projects. This widget owns no
/// persistence; it only returns normalized user intent to the canonical Task
/// editor/apply path.
class TaskCategoryField extends StatefulWidget {
  const TaskCategoryField({
    super.key,
    required this.value,
    required this.onChanged,
    this.knownCategories = const [],
    this.label = 'دسته‌بندی',
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> knownCategories;
  final String label;

  @override
  State<TaskCategoryField> createState() => _TaskCategoryFieldState();
}

class _TaskCategoryFieldState extends State<TaskCategoryField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant TaskCategoryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text.trim() != (widget.value ?? '')) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(String raw) {
    final value = raw.trim();
    widget.onChanged(value.isEmpty ? null : value);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.knownCategories
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('task-category-input'),
          controller: _controller,
          textInputAction: TextInputAction.done,
          onSubmitted: _apply,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'مثلاً اداری، شخصی، مشتری',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.trim().isNotEmpty)
                  IconButton(
                    key: const ValueKey('task-category-clear'),
                    tooltip: 'حذف دسته‌بندی',
                    onPressed: () {
                      setState(_clear);
                    },
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  key: const ValueKey('task-category-apply'),
                  tooltip: 'ثبت دسته‌بندی',
                  onPressed: () => _apply(_controller.text),
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => ActionChip(
                    key: ValueKey('task-category-option-$category'),
                    label: Text(category),
                    avatar: const Icon(Icons.folder_outlined, size: 17),
                    onPressed: () {
                      setState(() => _controller.text = category);
                      widget.onChanged(category);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
