import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/task_store.dart';
import 'services/task_taxonomy_mutation_service.dart';

/// User-facing management for the canonical Task category/tag fields.
///
/// This page owns no taxonomy database. Categories and tags are derived from
/// canonical Tasks and every rename/delete is persisted through [TaskStore].
class TaskTaxonomyManagementPage extends StatefulWidget {
  const TaskTaxonomyManagementPage({
    super.key,
    this.store,
    this.mutationService,
  });

  final TaskStore? store;
  final TaskTaxonomyMutationService? mutationService;

  @override
  State<TaskTaxonomyManagementPage> createState() =>
      _TaskTaxonomyManagementPageState();
}

class _TaskTaxonomyManagementPageState
    extends State<TaskTaxonomyManagementPage> {
  late final TaskStore store = widget.store ?? TaskStore();
  late final TaskTaxonomyMutationService mutationService =
      widget.mutationService ?? TaskTaxonomyMutationService();

  List<Task> tasks = const <Task>[];
  bool loading = true;
  bool saving = false;
  Object? loadFailure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await store.load();
      if (!mounted) return;
      setState(() {
        tasks = List<Task>.of(loaded);
        loading = false;
        loadFailure = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadFailure = error;
      });
    }
  }

  Map<String, int> get _categories {
    final counts = <String, int>{};
    for (final task in tasks) {
      final category = task.category?.trim();
      if (category == null || category.isEmpty) continue;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return Map<String, int>.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<String, int> get _tags {
    final counts = <String, int>{};
    for (final task in tasks) {
      for (final raw in task.tags) {
        final tag = raw.trim();
        if (tag.isEmpty) continue;
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return Map<String, int>.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Future<String?> _askRename({
    required String title,
    required String current,
    required String inputKey,
  }) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          key: ValueKey(inputKey),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'نام جدید',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(dialogContext, value.isEmpty ? null : value);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('لغو'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ==
        true;
  }

  Future<void> _persistMutation(int changed, String successMessage) async {
    if (changed == 0 || saving) return;
    setState(() => saving = true);
    try {
      await store.save(List<Task>.of(tasks));
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تغییر ذخیره نشد؛ داده‌های قبلی حفظ شدند'),
          ),
        );
      await _load();
    }
  }

  Future<void> _renameCategory(String category) async {
    if (saving) return;
    final next = await _askRename(
      title: 'تغییر نام دسته',
      current: category,
      inputKey: 'taxonomy-category-rename-input',
    );
    if (next == null || next == category || !mounted) return;
    setState(() {
      final changed = mutationService.renameCategory(
        tasks,
        from: category,
        to: next,
      );
      _pendingChanged = changed;
    });
    final changed = _takePendingChanged();
    await _persistMutation(changed, '$changed مورد به «$next» منتقل شد');
  }

  Future<void> _deleteCategory(String category) async {
    if (saving) return;
    final approved = await _confirmDelete(
      title: 'حذف دسته',
      message:
          'دسته «$category» حذف شود؟ خود کارها و یادداشت‌ها حذف نمی‌شوند و فقط بدون دسته می‌مانند.',
    );
    if (!approved || !mounted) return;
    setState(() {
      _pendingChanged = mutationService.deleteCategory(tasks, category);
    });
    final changed = _takePendingChanged();
    await _persistMutation(changed, 'دسته از $changed مورد برداشته شد');
  }

  Future<void> _renameTag(String tag) async {
    if (saving) return;
    final next = await _askRename(
      title: 'تغییر نام برچسب',
      current: tag,
      inputKey: 'taxonomy-tag-rename-input',
    );
    if (next == null || next == tag || !mounted) return;
    setState(() {
      _pendingChanged = mutationService.renameTag(
        tasks,
        from: tag,
        to: next,
      );
    });
    final changed = _takePendingChanged();
    await _persistMutation(changed, '$changed مورد با برچسب «$next» به‌روز شد');
  }

  Future<void> _deleteTag(String tag) async {
    if (saving) return;
    final approved = await _confirmDelete(
      title: 'حذف برچسب',
      message:
          'برچسب «$tag» از همه موارد حذف شود؟ هیچ کار یا یادداشتی حذف نمی‌شود.',
    );
    if (!approved || !mounted) return;
    setState(() {
      _pendingChanged = mutationService.deleteTag(tasks, tag);
    });
    final changed = _takePendingChanged();
    await _persistMutation(changed, 'برچسب از $changed مورد برداشته شد');
  }

  int _pendingChanged = 0;
  int _takePendingChanged() {
    final value = _pendingChanged;
    _pendingChanged = 0;
    return value;
  }

  Widget _taxonomyRow({
    required String value,
    required int count,
    required String kind,
    required VoidCallback onRename,
    required VoidCallback onDelete,
  }) {
    return ListTile(
      key: ValueKey('taxonomy-$kind-$value'),
      contentPadding: EdgeInsets.zero,
      title: Text(value),
      subtitle: Text('$count مورد'),
      trailing: Wrap(
        spacing: 2,
        children: [
          IconButton(
            key: ValueKey('taxonomy-$kind-rename-$value'),
            tooltip: 'تغییر نام',
            onPressed: saving ? null : onRename,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: ValueKey('taxonomy-$kind-delete-$value'),
            tooltip: 'حذف',
            onPressed: saving ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    final tags = _tags;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('دسته‌ها و برچسب‌ها')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : loadFailure != null
                ? Center(
                    child: FilledButton.icon(
                      key: const ValueKey('taxonomy-retry'),
                      onPressed: () {
                        setState(() => loading = true);
                        _load();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('تلاش دوباره'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'دسته یا برچسب جدید هنگام ویرایش کار/یادداشت ساخته و همان‌جا روی همان مورد canonical ذخیره می‌شود. این صفحه فقط نام‌گذاری و حذف ارتباط‌ها را مدیریت می‌کند و مخزن جداگانه‌ای نمی‌سازد.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'دسته‌ها',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (categories.isEmpty)
                        const ListTile(
                          key: ValueKey('taxonomy-categories-empty'),
                          contentPadding: EdgeInsets.zero,
                          title: Text('هنوز دسته‌ای استفاده نشده است'),
                        )
                      else
                        ...categories.entries.map(
                          (entry) => _taxonomyRow(
                            value: entry.key,
                            count: entry.value,
                            kind: 'category',
                            onRename: () => _renameCategory(entry.key),
                            onDelete: () => _deleteCategory(entry.key),
                          ),
                        ),
                      const Divider(height: 32),
                      const Text(
                        'برچسب‌ها',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (tags.isEmpty)
                        const ListTile(
                          key: ValueKey('taxonomy-tags-empty'),
                          contentPadding: EdgeInsets.zero,
                          title: Text('هنوز برچسبی استفاده نشده است'),
                        )
                      else
                        ...tags.entries.map(
                          (entry) => _taxonomyRow(
                            value: entry.key,
                            count: entry.value,
                            kind: 'tag',
                            onRename: () => _renameTag(entry.key),
                            onDelete: () => _deleteTag(entry.key),
                          ),
                        ),
                      if (saving) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
      ),
    );
  }
}
