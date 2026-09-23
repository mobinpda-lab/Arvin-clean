import 'package:flutter/material.dart';

import 'arvin_radio_box.dart';

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
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            ArvinRadioBox(
              key: const ValueKey('task-category-none'),
              label: 'بدون دسته',
              selected: widget.value == null || widget.value!.trim().isEmpty,
              icon: Icons.remove_circle_outline,
              onTap: _clear,
            ),
            ...categories.map(
              (category) => ArvinRadioBox(
                key: ValueKey('task-category-option-$category'),
                label: category,
                selected: widget.value?.trim() == category,
                icon: Icons.folder_outlined,
                onTap: () {
                  setState(() => _controller.text = category);
                  widget.onChanged(category);
                },
              ),
            ),
            ArvinRadioBox(
              key: const ValueKey('task-category-new'),
              label: 'گزینه جدید',
              selected: false,
              newOption: true,
              onTap: () async {
                final controller = TextEditingController();
                final value = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('دسته جدید'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'نام دسته را وارد کنید'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لغو')),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('ثبت')),
                    ],
                  ),
                );
                controller.dispose();
                if (value == null || value.isEmpty) return;
                setState(() => _controller.text = value);
                widget.onChanged(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
