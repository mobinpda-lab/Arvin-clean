import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/task_store.dart';
import 'services/task_taxonomy_mutation_service.dart';

/// User-facing management for the canonical Task category/tag fields.
///
/// This page owns no taxonomy database. Categories and tags are derived from
/// canonical Tasks. Renames are persisted through [TaskStore], while deletion
/// fails closed whenever a category/tag is still referenced by any canonical
/// Task/Note item.
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
  late final TaskStore store;
  late final TaskTaxonomyMutationService mutationService;

  List<Task> tasks = const <Task>[];
  bool loading = true;
  bool saving = false;
  Object? loadFailure;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? TaskStore();
    mutationService =
        widget.mutationService ?? TaskTaxonomyMutationService();
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
    // The dialog route may still be animating out when this Future resolves.
    // Let the short-lived controller be collected with the route instead of
    // disposing it while EditableText is still detaching.
    return result;
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

  void _showDeleteBlocked(TaskTaxonomyDeleteBlocked error) {
    final kind = error.kind == 'category' ? 'دسته' : 'برچسب';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$kind «${error.value}» در ${error.referenceCount} مورد استفاده می‌شود و قابل حذف نیست. ابتدا موارد را منتقل/تغییرنام دهید.',
          ),
        ),
      );
  }

  void _deleteCategory(String category) {
    if (saving) return;
    try {
      mutationService.deleteCategory(tasks, category);
    } on TaskTaxonomyDeleteBlocked catch (error) {
      _showDeleteBlocked(error);
    }
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

  void _deleteTag(String tag) {
    if (saving) return;
    try {
      mutationService.deleteTag(tasks, tag);
    } on TaskTaxonomyDeleteBlocked catch (error) {
      _showDeleteBlocked(error);
    }
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
            tooltip: 'تغییر نام / انتقال همه موارد',
            onPressed: saving ? null : onRename,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: ValueKey('taxonomy-$kind-delete-$value'),
            tooltip: 'در حال استفاده است؛ حذف مسدود است',
            onPressed: saving ? null : onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
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
                            'دسته یا برچسب جدید هنگام ویرایش کار/یادداشت ساخته می‌شود. موردی که در کار یا یادداشت استفاده شده باشد حذف نمی‌شود؛ برای جابه‌جایی امن، آن را تغییرنام/منتقل کنید تا هیچ داده‌ای بی‌دسته یا بی‌برچسب نشود.',
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
