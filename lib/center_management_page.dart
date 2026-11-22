import 'package:flutter/material.dart';

import 'models/center.dart' as domain;
import 'models/goal_project.dart';
import 'services/center_store.dart';
import 'services/project_store.dart';
import 'services/arvin_async_trace.dart';

enum _CenterSort { name, newest, oldest }

/// Independent management surface for the canonical Center entity.
///
/// Persistence is delegated to the existing CenterStore and ProjectStore.
/// This page intentionally edits only fields supported by the current model;
/// description/color require a separately accepted persistence contract.
class CenterManagementPage extends StatefulWidget {
  const CenterManagementPage({
    super.key,
    this.centerStore,
    this.projectStore,
    this.onLoadComplete,
  });

  final CenterStore? centerStore;
  final ProjectStore? projectStore;
  /// Signals completion of the page's canonical Center/Project load.
  final VoidCallback? onLoadComplete;

  @override
  State<CenterManagementPage> createState() => _CenterManagementPageState();
}

class _CenterManagementPageState extends State<CenterManagementPage> {
  late final CenterStore _centers = widget.centerStore ?? CenterStore();
  late final ProjectStore _projects = widget.projectStore ?? ProjectStore();
  final TextEditingController _searchController = TextEditingController();

  List<domain.Center> _items = const [];
  List<ProjectPlan> _projectItems = const [];
  Map<String, List<String>> _centerProjectIds = const {};
  _CenterSort _sort = _CenterSort.name;
  bool _showArchived = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshView);
    _load();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshView)
      ..dispose();
    super.dispose();
  }

  void _refreshView() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await arvinAsyncTrace.run<void>(
        operationName: 'center.page.load',
        operation: _loadTraced,
      );
    } catch (_) {
      // _loadTraced already updates the visible error state and completion
      // callback; keep the lifecycle Future handled by the widget.
    }
  }

  Future<void> _loadTraced() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // CenterStore._ensureReady already initializes the canonical Project
      // path. Load stores sequentially to avoid overlapping schema/install
      // transactions on the shared SQLite executor.
      final centers = await arvinTraceFuture(
        'center.page.load_centers',
        _centers.load(includeArchived: true),
      );
      final projects = await arvinTraceFuture(
        'center.page.load_projects',
        _projects.load(),
      );
      final links = await arvinTraceFuture(
        'center.page.load_all_links',
        Future.wait(centers.map((center) => _centers.projectIdsForCenter(center.id))),
      );
      if (!mounted) return;
      setState(() {
        _items = centers;
        _projectItems = projects;
        _centerProjectIds = {
          for (var index = 0; index < centers.length; index++)
            centers[index].id: links[index],
        };
        _loading = false;
      });
      widget.onLoadComplete?.call();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'بارگذاری مراکز انجام نشد: $error';
        _loading = false;
      });
      widget.onLoadComplete?.call();
      rethrow;
    }
  }

  List<domain.Center> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    final result = _items.where((item) {
      if (!_showArchived && item.isArchived) return false;
      if (_showArchived && !item.isArchived) return false;
      return query.isEmpty || item.name.toLowerCase().contains(query);
    }).toList();
    switch (_sort) {
      case _CenterSort.name:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case _CenterSort.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _CenterSort.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    return result;
  }

  Future<void> _editCenter([domain.Center? center]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CenterNameDialog(
        initialName: center?.name ?? '',
        title: center == null ? 'مرکز جدید' : 'ویرایش مرکز',
      ),
    );
    if (!mounted || name == null) return;
    if (name.trim().isEmpty) {
      _showMessage('نام مرکز نمی‌تواند خالی باشد.');
      return;
    }
    try {
      if (center == null) {
        final id = 'center-${DateTime.now().microsecondsSinceEpoch}';
        await arvinAsyncTrace.run<void>(
          operationName: 'center.page.create',
          operation: () async {
            await _centers.create(id: id, name: name);
          },
        );
      } else {
        await arvinAsyncTrace.run<void>(
          operationName: 'center.page.rename',
          operation: () async {
            await _centers.rename(center.id, name);
          },
        );
      }
      await _load();
    } catch (error) {
      _showMessage('ذخیره مرکز انجام نشد: $error');
    }
  }

  Future<void> _setArchived(domain.Center center, bool archived) async {
    final action = archived ? 'بایگانی' : 'بازیابی';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('$action مرکز'),
          content: Text('آیا از $action «${center.name}» مطمئن هستید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return;
    try {
      if (archived) {
        await arvinAsyncTrace.run<void>(
          operationName: 'center.page.archive',
          operation: () => _centers.archive(center.id),
        );
      } else {
        await arvinAsyncTrace.run<void>(
          operationName: 'center.page.restore',
          operation: () => _centers.restore(center.id),
        );
      }
      await _load();
    } catch (error) {
      _showMessage('$action مرکز انجام نشد: $error');
    }
  }

  Future<void> _editProjectLinks(domain.Center center) async {
    try {
      final current = await arvinAsyncTrace.run<List<String>>(
        operationName: 'center.page.read_project_links_for_edit',
        operation: () => _centers.projectIdsForCenter(center.id),
      );
      if (!mounted) return;
      final selected = await showDialog<Set<String>>(
        context: context,
        builder: (dialogContext) {
          final chosen = Set<String>.of(current);
          return StatefulBuilder(
            builder: (context, setDialogState) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text('پروژه‌های «${center.name}»'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 320,
                  child: _projectItems.isEmpty
                      ? const Center(child: Text('پروژه‌ای برای اتصال وجود ندارد.'))
                      : ListView(
                          children: _projectItems.map((project) {
                            return CheckboxListTile(
                              value: chosen.contains(project.id),
                              title: Text(project.title),
                              secondary: CircleAvatar(
                                backgroundColor: Color(project.colorValue),
                                radius: 7,
                              ),
                              onChanged: (checked) => setDialogState(() {
                                if (checked == true) {
                                  chosen.add(project.id);
                                } else {
                                  chosen.remove(project.id);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('انصراف'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, chosen),
                    child: const Text('ذخیره ارتباط‌ها'),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (!mounted || selected == null) return;
      await arvinAsyncTrace.run<void>(
        operationName: 'center.page.replace_project_links',
        operation: () => _centers.replaceProjectLinks(center.id, selected),
      );
      await _load();
      _showMessage('ارتباط پروژه‌های مرکز به‌روزرسانی شد.');
    } catch (error) {
      _showMessage('ویرایش ارتباط پروژه‌ها انجام نشد: $error');
    }
  }

  Future<void> _showDetails(domain.Center center) async {
    try {
      final ids = await arvinAsyncTrace.run<List<String>>(
        operationName: 'center.page.read_project_links_for_details',
        operation: () => _centers.projectIdsForCenter(center.id),
      );
      final byId = {for (final project in _projectItems) project.id: project};
      final linked = ids.map((id) => byId[id]).whereType<ProjectPlan>().toList();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(center.name, style: Theme.of(sheetContext).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(center.isArchived ? 'وضعیت: بایگانی‌شده' : 'وضعیت: فعال'),
                  Text('شناسه: ${center.id}'),
                  Text('ایجاد: ${_dateLabel(center.createdAt)}'),
                  Text('آخرین تغییر: ${_dateLabel(center.updatedAt)}'),
                  const Divider(height: 24),
                  Text('پروژه‌های مرتبط (${linked.length})',
                      style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (linked.isEmpty)
                    const Text('هنوز پروژه‌ای به این مرکز متصل نشده است.')
                  else
                    ...linked.map((project) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Color(project.colorValue),
                            radius: 7,
                          ),
                          title: Text(project.title),
                        )),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('center-edit-project-links'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _editProjectLinks(center);
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('مدیریت ارتباط پروژه‌ها'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      _showMessage('نمایش جزئیات مرکز انجام نشد: $error');
    }
  }

  String _dateLabel(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.day.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مدیریت مراکز'),
          actions: [
            IconButton(
              tooltip: 'بارگذاری مجدد',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const ValueKey('center-create'),
          onPressed: _loading ? null : () => _editCenter(),
          icon: const Icon(Icons.add),
          label: const Text('مرکز جدید'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                key: const ValueKey('center-search'),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'جست‌وجوی مرکز',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'پاک کردن جست‌وجو',
                    onPressed: _searchController.clear,
                    icon: const Icon(Icons.clear),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    key: const ValueKey('center-archived-filter'),
                    label: const Text('بایگانی‌شده‌ها'),
                    selected: _showArchived,
                    onSelected: (value) => setState(() => _showArchived = value),
                  ),
                  const Spacer(),
                  PopupMenuButton<_CenterSort>(
                    tooltip: 'مرتب‌سازی',
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: _CenterSort.name, child: Text('نام')),
                      PopupMenuItem(value: _CenterSort.newest, child: Text('جدیدترین')),
                      PopupMenuItem(value: _CenterSort.oldest, child: Text('قدیمی‌ترین')),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(Icons.sort),
                          SizedBox(width: 6),
                          Text('مرتب‌سازی'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 36),
                                const SizedBox(height: 8),
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: _load,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('تلاش دوباره'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : visible.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.hub_outlined, size: 42),
                                    const SizedBox(height: 12),
                                    Text(
                                      _searchController.text.isNotEmpty
                                          ? 'مرکزی با این عبارت پیدا نشد.'
                                          : _showArchived
                                              ? 'مرکز بایگانی‌شده‌ای وجود ندارد.'
                                              : 'هنوز مرکزی ساخته نشده است.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final center = visible[index];
                                final linkedCount = _centerProjectIds[center.id]?.length ?? 0;
                                return ListTile(
                                  key: ValueKey('center-row-${center.id}'),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: const Icon(Icons.hub_outlined),
                                  ),
                                  title: Text(center.name),
                                  subtitle: Text(
                                    center.isArchived ? 'بایگانی‌شده' : 'فعال • $linkedCount پروژه',
                                  ),
                                  onTap: () => _showDetails(center),
                                  trailing: PopupMenuButton<String>(
                                    tooltip: 'عملیات مرکز',
                                    onSelected: (action) {
                                      if (action == 'edit') _editCenter(center);
                                      if (action == 'archive') _setArchived(center, true);
                                      if (action == 'restore') _setArchived(center, false);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                                      PopupMenuItem(
                                        value: center.isArchived ? 'restore' : 'archive',
                                        child: Text(center.isArchived ? 'بازیابی' : 'بایگانی'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}


class _CenterNameDialog extends StatefulWidget {
  const _CenterNameDialog({
    required this.initialName,
    required this.title,
  });

  final String initialName;
  final String title;

  @override
  State<_CenterNameDialog> createState() => _CenterNameDialogState();
}

class _CenterNameDialogState extends State<_CenterNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(widget.title),
          content: TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'نام مرکز',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) =>
                Navigator.pop(context, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _controller.text.trim()),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      );
}
