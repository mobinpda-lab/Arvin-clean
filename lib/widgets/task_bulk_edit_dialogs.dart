import 'package:flutter/material.dart';

class TaskBulkCategorySelection {
  const TaskBulkCategorySelection({required this.category});

  final String? category;

  factory TaskBulkCategorySelection.fromInput(String raw) {
    final value = raw.trim();
    return TaskBulkCategorySelection(category: value.isEmpty ? null : value);
  }
}

class TaskBulkTagSelection {
  TaskBulkTagSelection(Iterable<String> values)
      : tags = List<String>.unmodifiable(_normalize(values));

  factory TaskBulkTagSelection.fromText(String raw) {
    return TaskBulkTagSelection(raw.split(RegExp(r'[,،\n]+')));
  }

  final List<String> tags;

  static List<String> _normalize(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};
    for (final value in values) {
      final tag = value.trim();
      if (tag.isEmpty || !seen.add(tag)) continue;
      result.add(tag);
    }
    return result;
  }
}

Future<TaskBulkCategorySelection?> showTaskBulkCategoryDialog(
  BuildContext context, {
  String? initialCategory,
}) {
  return showDialog<TaskBulkCategorySelection>(
    context: context,
    builder: (_) => TaskBulkCategoryDialog(initialCategory: initialCategory),
  );
}

class TaskBulkCategoryDialog extends StatefulWidget {
  const TaskBulkCategoryDialog({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<TaskBulkCategoryDialog> createState() => _TaskBulkCategoryDialogState();
}

class _TaskBulkCategoryDialogState extends State<TaskBulkCategoryDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialCategory ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغییر دسته'),
      content: TextField(
        key: const ValueKey('task-bulk-category-input'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'نام دسته',
          helperText: 'برای حذف دسته، این کادر را خالی بگذارید.',
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('task-bulk-category-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('لغو'),
        ),
        FilledButton(
          key: const ValueKey('task-bulk-category-apply'),
          onPressed: () => Navigator.of(context).pop(
            TaskBulkCategorySelection.fromInput(_controller.text),
          ),
          child: const Text('اعمال'),
        ),
      ],
    );
  }
}

Future<TaskBulkTagSelection?> showTaskBulkTagsDialog(BuildContext context) {
  return showDialog<TaskBulkTagSelection>(
    context: context,
    builder: (_) => const TaskBulkTagsDialog(),
  );
}

class TaskBulkTagsDialog extends StatefulWidget {
  const TaskBulkTagsDialog({super.key});

  @override
  State<TaskBulkTagsDialog> createState() => _TaskBulkTagsDialogState();
}

class _TaskBulkTagsDialogState extends State<TaskBulkTagsDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _canApply = false;

  void _update() {
    final next = TaskBulkTagSelection.fromText(_controller.text).tags.isNotEmpty;
    if (next == _canApply) return;
    setState(() => _canApply = next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('افزودن برچسب'),
      content: TextField(
        key: const ValueKey('task-bulk-tags-input'),
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: 3,
        onChanged: (_) => _update(),
        decoration: const InputDecoration(
          labelText: 'برچسب‌های جدید',
          helperText: 'چند برچسب را با ویرگول جدا کنید.',
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('task-bulk-tags-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('لغو'),
        ),
        FilledButton(
          key: const ValueKey('task-bulk-tags-apply'),
          onPressed: _canApply
              ? () => Navigator.of(context).pop(
                    TaskBulkTagSelection.fromText(_controller.text),
                  )
              : null,
          child: const Text('افزودن'),
        ),
      ],
    );
  }
}
