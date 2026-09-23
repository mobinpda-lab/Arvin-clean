import 'dart:async';

import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/task.dart';
import 'services/canonical_notebook_repository.dart';
import 'services/persian_date_formatter.dart';
import 'task_report_page.dart';
import 'widgets/arvin_radio_box.dart';
import 'widgets/task_bulk_selection_bar.dart';
import 'services/project_store.dart';

enum _NotebookCreateMode { note, checklist }

class _ChecklistPreset {
  const _ChecklistPreset({
    required this.id,
    required this.title,
    this.items = const [],
  });

  final String id;
  final String title;
  final List<String> items;
}

const _checklistPresets = <_ChecklistPreset>[
  _ChecklistPreset(
    id: 'shopping',
    title: 'لیست خرید',
    items: ['[ ] نان', '[ ] شیر', '[ ] میوه'],
  ),
  _ChecklistPreset(
    id: 'travel',
    title: 'وسایل سفر',
    items: ['[ ] مدارک', '[ ] شارژر', '[ ] لباس'],
  ),
  _ChecklistPreset(
    id: 'today',
    title: 'کارهای امروز',
  ),
  _ChecklistPreset(
    id: 'blank',
    title: 'چک‌لیست جدید',
  ),
];

class NotebookPage extends StatefulWidget {
  NotebookPage({
    super.key,
    CanonicalNotebookRepository? repository,
  }) : repository = repository ?? CanonicalNotebookRepository();

  final CanonicalNotebookRepository repository;

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  bool _loading = true;
  List<Task> _notes = const [];
  bool _selectionMode = false;
  final Set<String> _selected = <String>{};
  final TextEditingController _search = TextEditingController();
  _NotebookCreateMode _activeMode = _NotebookCreateMode.note;
  String _activeCategory = 'همه';
  bool _showTrash = false;

  static const _referenceCategories = <String>['همه', 'شخصی', 'کاری', 'ایده‌ها'];

  List<Task> get _visibleNotes {
    final query = _search.text.trim().toLowerCase();
    return _notes.where((note) {
      final isChecklist = note.isNotebookChecklist;
      if (_activeMode == _NotebookCreateMode.note && isChecklist) return false;
      if (_activeMode == _NotebookCreateMode.checklist && !isChecklist) return false;
      if (_activeCategory != 'همه' && note.category?.trim() != _activeCategory) {
        return false;
      }
      if (query.isEmpty) return true;
      return note.title.toLowerCase().contains(query) ||
          note.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final notes = _showTrash
        ? await widget.repository.loadTrashedNotes()
        : await widget.repository.loadNotes();
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      _selectionMode = true;
      if (!_selected.add(id)) {
        _selected.remove(id);
      }
      if (_selected.isEmpty) _selectionMode = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  void _toggleAll() {
    setState(() {
      final visible = _visibleNotes.map((note) => note.id).toSet();
      final allSelected = visible.isNotEmpty && visible.every(_selected.contains);
      if (allSelected) {
        _selected.removeAll(visible);
      } else {
        _selected.addAll(visible);
      }
      _selectionMode = _selected.isNotEmpty;
    });
  }

  Future<void> _openSelectedReport() async {
    if (_selected.isEmpty) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskReportPage(
          tasks: List<Task>.of(_notes),
          initialSelectedIds: Set<String>.of(_selected),
        ),
      ),
    );
  }

  Future<void> _trashSelected() async {
    if (_selected.isEmpty) return;
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('انتقال به سطل زباله'),
        content: Text('$count یادداشت انتخاب‌شده منتقل شود؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            key: const ValueKey('notebook-bulk-trash-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final changed = await widget.repository.moveSelectedToTrash(_selected);
    if (!mounted) return;
    _clearSelection();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$changed یادداشت به سطل زباله منتقل شد')),
    );
  }

  Future<void> _moveSelectedToCategory() async {
    if (_selected.isEmpty) return;
    final categories = await widget.repository.loadCategories();
    if (!mounted) return;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          children: [
            Text('تغییر دسته یادداشت‌ها', style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 10),
            ArvinRadioBox(
              label: 'بدون دسته',
              selected: false,
              icon: Icons.folder_off_outlined,
              onTap: () => Navigator.of(sheetContext).pop(''),
            ),
            const SizedBox(height: 8),
            for (final category in categories) ...[
              ArvinRadioBox(
                key: ValueKey('notebook-bulk-category-$category'),
                label: category,
                selected: false,
                icon: Icons.folder_outlined,
                onTap: () => Navigator.of(sheetContext).pop(category),
              ),
              const SizedBox(height: 8),
            ],
            ArvinRadioBox(
              key: const ValueKey('notebook-bulk-category-new'),
              label: 'گزینه جدید',
              newOption: true,

              selected: false,
              onTap: () => Navigator.of(sheetContext).pop('__new_category__'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;

    String? category = selected;
    if (selected == '__new_category__') {
      var value = '';
      category = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('دسته جدید'),
          content: TextField(
            key: const ValueKey('notebook-bulk-category-new-input'),
            autofocus: true,
            decoration: const InputDecoration(labelText: 'نام دسته'),
            onChanged: (next) => value = next,
            onSubmitted: (next) => Navigator.of(dialogContext).pop(next.trim()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, value.trim()), child: const Text('ثبت')),
          ],
        ),
      );
      if (!mounted || category == null || category.trim().isEmpty) return;
    }

    final finalCategory = category;
    if (finalCategory == null || finalCategory.trim().isEmpty) return;
    final changed = await widget.repository.moveSelectedToCategory(_selected, finalCategory);
    if (!mounted) return;
    _clearSelection();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('دسته برای $changed یادداشت به‌روز شد')),
    );
  }

  Future<void> _addTagsToSelected() async {
    if (_selected.isEmpty) return;
    final notes = await widget.repository.loadNotes();
    if (!mounted) return;
    final knownTags = <String>{
      for (final note in notes)
        for (final tag in note.tags)
          if (tag.trim().isNotEmpty) tag.trim(),
    }.toList()..sort();

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final working = <String>{};
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                Text('افزودن برچسب', style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 10),
                for (final tag in knownTags) ...[
                  ArvinRadioBox(
                    key: ValueKey('notebook-bulk-tag-$tag'),
                    label: tag,
                    selected: working.contains(tag),
                    icon: Icons.sell_outlined,
                    onTap: () => setSheetState(() {
                      if (!working.add(tag)) working.remove(tag);
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                ArvinRadioBox(
                  key: const ValueKey('notebook-bulk-tag-new'),
                  label: 'گزینه جدید',
                  newOption: true,

                  selected: false,
                  onTap: () async {
                    var value = '';
                    final tag = await showDialog<String>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('برچسب جدید'),
                        content: TextField(
                          key: const ValueKey('notebook-bulk-tag-new-input'),
                          autofocus: true,
                          decoration: const InputDecoration(labelText: 'نام برچسب'),
                          onChanged: (next) => value = next,
                          onSubmitted: (next) => Navigator.of(dialogContext).pop(next.trim()),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
                          FilledButton(onPressed: () => Navigator.pop(dialogContext, value.trim()), child: const Text('ثبت')),
                        ],
                      ),
                    );
                    if (!mounted || tag == null || tag.trim().isEmpty) return;
                    setSheetState(() => working.add(tag.trim()));
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('notebook-bulk-tags-apply'),
                  onPressed: () => Navigator.of(sheetContext).pop(working.toList()..sort()),
                  child: const Text('اعمال'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null || selected.isEmpty) return;

    final changed = await widget.repository.addTagsToSelected(_selected, selected);
    if (!mounted) return;
    _clearSelection();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('برچسب‌ها برای $changed یادداشت به‌روز شد')),
    );
  }

  Future<void> _open(
    Task note, {
    bool startEditing = false,
    bool focusChecklistOnOpen = false,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: NotebookEditorPage(
            noteId: note.id,
            repository: widget.repository,
            startEditing: startEditing,
            focusChecklistOnOpen: focusChecklistOnOpen,
          ),
        ),
      ),
    );
    await _reload();
  }

  Future<_ChecklistPreset?> _chooseChecklistPreset() {
    return showModalBottomSheet<_ChecklistPreset>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: [
              Text(
                'قالب چک‌لیست',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final preset in _checklistPresets)
                ListTile(
                  key: ValueKey('notebook-preset-${preset.id}'),
                  leading: Icon(
                    preset.id == 'shopping'
                        ? Icons.shopping_basket_outlined
                        : preset.id == 'travel'
                            ? Icons.luggage_outlined
                            : preset.id == 'today'
                                ? Icons.today_outlined
                                : Icons.checklist_outlined,
                  ),
                  title: Text(preset.title),
                  subtitle: preset.items.isEmpty
                      ? const Text('از یک چک‌لیست خالی شروع کنید')
                      : Text(
                          '${preset.items.length} مورد پیشنهادی قابل ویرایش',
                        ),
                  onTap: () => Navigator.of(sheetContext).pop(preset),
                ),
              TextButton(
                key: const ValueKey('notebook-preset-cancel'),
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('انصراف'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    final mode = _activeMode;

    if (mode == _NotebookCreateMode.note) {
      final note = await widget.repository.createNote(
        title: 'یادداشت جدید',
        notebookKind: NotebookItemKind.note,
        category: _activeCategory == 'همه' ? null : _activeCategory,
      );
      if (!mounted) return;
      await _open(note, startEditing: true);
      return;
    }

    final preset = await _chooseChecklistPreset();
    if (!mounted || preset == null) return;

    final note = await widget.repository.createNote(
      title: preset.title,
      checklist: preset.items,
      notebookKind: NotebookItemKind.checklist,
      category: _activeCategory == 'همه' ? null : _activeCategory,
    );
    if (!mounted) return;
    await _open(
      note,
      startEditing: true,
      focusChecklistOnOpen: preset.items.isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotes = _visibleNotes;
    final allVisibleSelected = visibleNotes.isNotEmpty &&
        visibleNotes.every((note) => _selected.contains(note.id));
    return Scaffold(
      appBar: AppBar(
        actions: _selectionMode
            ? null
            : [
                IconButton(
                  key: const ValueKey('notebook-trash-view'),
                  tooltip: _showTrash ? 'بازگشت به دفترچه' : 'سطل زباله',
                  icon: Icon(
                    _showTrash
                        ? Icons.menu_book_outlined
                        : Icons.delete_outline,
                  ),
                  onPressed: () async {
                    setState(() {
                      _showTrash = !_showTrash;
                      _selected.clear();
                      _selectionMode = false;
                      _loading = true;
                    });
                    await _reload();
                  },
                ),
              ],
        title: _selectionMode
            ? Text('${_selected.length} انتخاب')
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('دفترچه'),
                  Text(
                    'یادداشت‌ها و چک‌لیست‌ها',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    key: const ValueKey('notebook-search'),
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'جستجو در دفترچه',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      for (final category in _referenceCategories)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            key: ValueKey('notebook-filter-$category'),
                            label: Text(category),
                            selected: _activeCategory == category,
                            onSelected: (_) =>
                                setState(() => _activeCategory = category),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SegmentedButton<_NotebookCreateMode>(
                    key: const ValueKey('notebook-mode-switch'),
                    segments: const [
                      ButtonSegment(
                        value: _NotebookCreateMode.note,
                        label: Text('یادداشت‌ها'),
                        icon: Icon(Icons.note_alt_outlined),
                      ),
                      ButtonSegment(
                        value: _NotebookCreateMode.checklist,
                        label: Text('چک‌لیست‌ها'),
                        icon: Icon(Icons.checklist_outlined),
                      ),
                    ],
                    selected: {_activeMode},
                    onSelectionChanged: (selection) => setState(
                      () => _activeMode = selection.first,
                    ),
                  ),
                ),
                Expanded(
                  child: visibleNotes.isEmpty
                      ? Center(
                          child: Text(
                            _notes.isEmpty
                                ? 'هنوز یادداشتی ثبت نشده است'
                                : 'موردی مطابق فیلتر فعلی پیدا نشد',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: visibleNotes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final note = visibleNotes[index];
                            final selected = _selected.contains(note.id);
                            final preview = note.description.trim().isNotEmpty
                                ? note.description.trim()
                                : note.checklist
                                    .map(_checklistPreviewLabel)
                                    .take(2)
                                    .join(' • ');
                            return Card(
                              child: ListTile(
                                key: ValueKey('notebook-note-${note.id}'),
                                leading: _selectionMode
                                    ? Checkbox(
                                        value: selected,
                                        onChanged: (_) =>
                                            _toggleSelection(note.id),
                                      )
                                    : Icon(
                                        note.isNotebookChecklist
                                            ? Icons.checklist_outlined
                                            : Icons.note_alt_outlined,
                                      ),
                                title: Text(note.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (preview.isNotEmpty)
                                      Text(
                                        preview,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          note.category?.trim().isNotEmpty ??
                                                  false
                                              ? note.category!
                                              : 'بدون دسته',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Text(
                                          _formatNotebookDate(
                                            note.updatedAt ?? note.createdAt,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                selected: selected,
                                onLongPress: () =>
                                    _toggleSelection(note.id),
                                trailing: _showTrash
                                    ? IconButton(
                                        key: ValueKey(
                                          'notebook-restore-${note.id}',
                                        ),
                                        tooltip: 'بازیابی',
                                        icon: const Icon(Icons.restore),
                                        onPressed: () async {
                                          await widget.repository
                                              .restoreNote(note.id);
                                          await _reload();
                                        },
                                      )
                                    : null,
                                onTap: () => _showTrash
                                    ? null
                                    : _selectionMode
                                        ? _toggleSelection(note.id)
                                        : _open(note),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _selectionMode
          ? TaskBulkSelectionBar(
              selectedCount: _selected.length,
              allVisibleSelected: allVisibleSelected,
              onToggleAll: _toggleAll,
              onClearSelection: _clearSelection,
              onTrash: _trashSelected,
              onCategory: _moveSelectedToCategory,
              onTags: _addTagsToSelected,
              onShare: _openSelectedReport,
            )
          : null,
      floatingActionButton: _selectionMode || _showTrash
          ? null
          : FloatingActionButton(
              key: const ValueKey('notebook-create'),
              onPressed: _loading ? null : _create,
              tooltip: _activeMode == _NotebookCreateMode.note
                  ? 'یادداشت جدید'
                  : 'چک‌لیست جدید',
              child: const Icon(Icons.add),
            ),
    );
  }

  static String _checklistPreviewLabel(String item) =>
      item.replaceFirst(RegExp(r'^\\[(?:x| )\\]\\s*'), '');

  static const _listDateFormatter = PersianDateFormatter();

  static String _formatNotebookDate(DateTime? value) {
    if (value == null) return '';
    final iranTime = value.toUtc().add(const Duration(hours: 3, minutes: 30));
    return _listDateFormatter.format(
      iranTime,
      usePersianDate: true,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}

class NotebookEditorPage extends StatefulWidget {
  const NotebookEditorPage({
    super.key,
    required this.noteId,
    required this.repository,
    this.startEditing = false,
    this.focusChecklistOnOpen = false,
    this.autosaveDelay = const Duration(milliseconds: 350),
  });

  final String noteId;
  final CanonicalNotebookRepository repository;
  final bool startEditing;
  final bool focusChecklistOnOpen;
  final Duration autosaveDelay;

  @override
  State<NotebookEditorPage> createState() => _NotebookEditorPageState();
}

class _NotebookEditorPageState extends State<NotebookEditorPage> {
  static const _newCategoryToken = '__new_category__';
  static const _clearCategoryToken = '__clear_category__';

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _checklistInput = TextEditingController();
  final _checklistFocus = FocusNode();
  Timer? _autosaveTimer;
  Task? _note;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  bool _checklistMode = false;
  String? _category;
  String? _projectId;
  String? _projectTitle;
  List<String> _tags = [];
  List<String> _checklist = [];

  @override
  void initState() {
    super.initState();
    _editing = widget.startEditing;
    _checklistMode = widget.focusChecklistOnOpen;
    _load();
  }

  Future<void> _load() async {
    final note = await widget.repository.loadNote(widget.noteId);
    if (!mounted) return;
    if (note == null) {
      Navigator.of(context).pop();
      return;
    }

    _note = note;
    _title.text = note.title;
    _description.text = note.description;
    _checklist = List<String>.of(note.checklist);
    _category = note.category;
    _tags = List<String>.of(note.tags);
    final projectId = await widget.repository.projectIdForNote(note.id);
    final projects = await widget.repository.loadProjects();
    _projectId = projectId;
    for (final project in projects) {
      if (project.id == projectId) {
        _projectTitle = project.title;
        break;
      }
    }
    _checklistMode = _checklistMode || note.isNotebookChecklist;
    _title.addListener(_scheduleAutosave);
    _description.addListener(_scheduleAutosave);
    setState(() => _loading = false);
    if (widget.focusChecklistOnOpen && _editing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checklistFocus.requestFocus();
      });
    }
  }

  void _scheduleAutosave() {
    if (!_editing || _loading) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(widget.autosaveDelay, _saveNow);
  }

  Future<void> _saveNow() async {
    if (_note == null || _saving) return;
    _autosaveTimer?.cancel();
    _saving = true;
    try {
      await widget.repository.updateNote(
        id: widget.noteId,
        title: _title.text,
        description: _description.text,
        checklist: _checklistMode ? _checklist : const [],
      );
    } finally {
      _saving = false;
    }
  }

  Future<void> _finishEditing() async {
    await _saveNow();
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _handleBack() async {
    if (_editing) {
      await _saveNow();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<String?> _promptNewCategory() async {
    var value = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('دسته جدید'),
        content: TextField(
          key: const ValueKey('notebook-category-new-input'),
          autofocus: true,
          decoration: const InputDecoration(labelText: 'نام دسته'),
          onChanged: (next) => value = next,
          onSubmitted: (next) =>
              Navigator.of(dialogContext).pop(next.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const ValueKey('notebook-category-new-save'),
            onPressed: () => Navigator.of(dialogContext).pop(value.trim()),
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCategory() async {
    final categories = await widget.repository.loadCategories();
    if (!mounted) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          children: [
            Text('انتخاب دسته', style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 10),
            ArvinRadioBox(
              label: 'بدون دسته',
              selected: _category == null || _category!.trim().isEmpty,
              icon: Icons.folder_off_outlined,
              onTap: () => Navigator.of(sheetContext).pop(_clearCategoryToken),
            ),
            const SizedBox(height: 8),
            for (final category in categories) ...[
              ArvinRadioBox(
                key: ValueKey('notebook-category-$category'),
                label: category,
                selected: category == _category,
                icon: Icons.folder_outlined,
                onTap: () => Navigator.of(sheetContext).pop(category),
              ),
              const SizedBox(height: 8),
            ],
            ArvinRadioBox(
              key: const ValueKey('notebook-category-new'),
              label: 'گزینه جدید',
              newOption: true,

              selected: false,
              onTap: () => Navigator.of(sheetContext).pop(_newCategoryToken),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    String? nextCategory;
    if (selected == _newCategoryToken) {
      nextCategory = await _promptNewCategory();
      if (!mounted || nextCategory == null || nextCategory.trim().isEmpty) return;
    } else if (selected == _clearCategoryToken) {
      nextCategory = null;
    } else {
      nextCategory = selected;
    }
    final updated = await widget.repository.updateCategory(
      id: widget.noteId,
      category: nextCategory,
    );
    if (!mounted) return;
    setState(() {
      _note = updated;
      _category = updated.category;
    });
  }

  Future<String?> _promptNewProject() async {
    var value = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('پروژه جدید'),
        content: TextField(
          key: const ValueKey('notebook-project-new-input'),
          autofocus: true,
          decoration: const InputDecoration(labelText: 'نام پروژه'),
          onChanged: (next) => value = next,
          onSubmitted: (next) => Navigator.of(dialogContext).pop(next.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('انصراف')),
          FilledButton(
            key: const ValueKey('notebook-project-new-save'),
            onPressed: () => Navigator.of(dialogContext).pop(value.trim()),
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProject() async {
    final projects = await widget.repository.loadProjects();
    if (!mounted) return;
    final activeProjects = projects.where((project) => !project.isArchived).toList(growable: false);
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          children: [
            Text('انتخاب پروژه', style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 10),
            ArvinRadioBox(
              label: 'بدون پروژه',
              selected: _projectId == null,
              icon: Icons.work_off_outlined,
              onTap: () => Navigator.of(sheetContext).pop(''),
            ),
            const SizedBox(height: 8),
            for (final project in activeProjects) ...[
              ArvinRadioBox(
                key: ValueKey('notebook-project-${project.id}'),
                label: project.title,
                selected: project.id == _projectId,
                icon: Icons.work_outline,
                onTap: () => Navigator.of(sheetContext).pop(project.id),
              ),
              const SizedBox(height: 8),
            ],
            ArvinRadioBox(
              key: const ValueKey('notebook-project-new'),
              label: 'گزینه جدید',
              newOption: true,

              selected: false,
              onTap: () => Navigator.of(sheetContext).pop('__new_project__'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;

    String? nextProjectId;
    String? nextTitle;
    if (selected == '__new_project__') {
      final title = await _promptNewProject();
      if (!mounted || title == null || title.trim().isEmpty) return;
      final store = ProjectStore();
      final existing = await store.load();
      final project = ProjectPlan(
        id: 'project_${DateTime.now().microsecondsSinceEpoch}',
        title: title.trim(),
      );
      await store.save(<ProjectPlan>[...existing, project]);
      nextProjectId = project.id;
      nextTitle = project.title;
    } else {
      nextProjectId = selected.isEmpty ? null : selected;
      for (final project in activeProjects) {
        if (project.id == nextProjectId) {
          nextTitle = project.title;
          break;
        }
      }
    }
    await widget.repository.updateProject(id: widget.noteId, projectId: nextProjectId);
    if (!mounted) return;
    setState(() {
      _projectId = nextProjectId;
      _projectTitle = nextTitle;
    });
  }

  Future<String?> _promptNewTag() async {
    var value = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('برچسب جدید'),
        content: TextField(
          key: const ValueKey('notebook-tag-new-input'),
          autofocus: true,
          decoration: const InputDecoration(labelText: 'نام برچسب'),
          onChanged: (next) => value = next,
          onSubmitted: (next) => Navigator.of(dialogContext).pop(next.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('انصراف')),
          FilledButton(
            key: const ValueKey('notebook-tag-new-save'),
            onPressed: () => Navigator.of(dialogContext).pop(value.trim()),
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTags() async {
    final notes = await widget.repository.loadNotes();
    if (!mounted) return;
    final knownTags = <String>{
      for (final note in notes)
        for (final tag in note.tags)
          if (tag.trim().isNotEmpty) tag.trim(),
    }.toList()..sort();

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final working = <String>{..._tags};
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                Text('انتخاب برچسب', style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 10),
                for (final tag in knownTags) ...[
                  ArvinRadioBox(
                    key: ValueKey('notebook-tag-$tag'),
                    label: tag,
                    selected: working.contains(tag),
                    icon: Icons.sell_outlined,
                    onTap: () => setSheetState(() {
                      if (!working.add(tag)) working.remove(tag);
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                ArvinRadioBox(
                  key: const ValueKey('notebook-tag-new'),
                  label: 'گزینه جدید',
                  newOption: true,

                  selected: false,
                  onTap: () async {
                    final tag = await _promptNewTag();
                    if (!mounted || tag == null || tag.trim().isEmpty) return;
                    setSheetState(() => working.add(tag.trim()));
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('notebook-tags-save'),
                  onPressed: () => Navigator.of(sheetContext).pop(working.toList()..sort()),
                  child: const Text('اعمال'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    final updated = await widget.repository.updateTags(id: widget.noteId, tags: selected);
    if (!mounted) return;
    setState(() => _tags = List<String>.of(updated.tags));
  }

  Future<void> _convertToTask() async {
    if (_note == null) return;
    if (_editing) {
      await _saveNow();
      if (!mounted) return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تبدیل به کار؟'),
        content: const Text(
          'این یادداشت با همان شناسه، پروژه، دسته و برچسب‌ها به کار تبدیل می‌شود.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const ValueKey('notebook-convert-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تبدیل به کار'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.repository.convertNoteToTask(widget.noteId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _trashNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('انتقال به سطل زباله؟'),
        content: const Text('یادداشت از دفتر حذف می‌شود و در سطل زباله باقی می‌ماند.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const ValueKey('notebook-editor-trash-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.repository.moveSelectedToTrash(<String>[widget.noteId]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _addChecklistItem() {
    if (!_editing || !_checklistMode) return;
    final value = _checklistInput.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _checklist.add('[ ] $value');
      _checklistInput.clear();
    });
    _scheduleAutosave();
  }

  bool _checked(String item) => item.startsWith('[x] ');

  String _checklistLabel(String item) =>
      item.replaceFirst(RegExp(r'^\[(?:x| )\]\s*'), '');

  void _toggleChecklist(int index, bool? value) {
    if (!_editing || !_checklistMode) return;
    final label = _checklistLabel(_checklist[index]);
    setState(() {
      _checklist[index] = value == true ? '[x] $label' : '[ ] $label';
    });
    _scheduleAutosave();
  }

  Future<void> _editChecklistItem(int index) async {
    if (!_editing || !_checklistMode) return;
    var editedLabel = _checklistLabel(_checklist[index]);
    final replacement = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ویرایش مورد'),
        content: TextFormField(
          key: const ValueKey('notebook-checklist-edit-input'),
          initialValue: editedLabel,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'متن مورد'),
          onChanged: (value) => editedLabel = value,
          onFieldSubmitted: (value) =>
              Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const ValueKey('notebook-checklist-edit-save'),
            onPressed: () =>
                Navigator.of(dialogContext).pop(editedLabel.trim()),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    if (!mounted || replacement == null || replacement.isEmpty) return;
    final prefix = _checked(_checklist[index]) ? '[x] ' : '[ ] ';
    setState(() => _checklist[index] = '$prefix$replacement');
    _scheduleAutosave();
  }

  void _removeChecklistItem(int index) {
    if (!_editing || !_checklistMode) return;
    setState(() => _checklist.removeAt(index));
    _scheduleAutosave();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _title.dispose();
    _description.dispose();
    _checklistInput.dispose();
    _checklistFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final noteDate = _note?.updatedAt ?? _note?.createdAt;
    return PopScope(
      canPop: !_editing,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_editing) return;
        await _handleBack();
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const ValueKey('notebook-editor-back'),
          onPressed: _handleBack,
          tooltip: 'بازگشت',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const SizedBox.shrink(),
        centerTitle: false,
        actions: [
          IconButton(
            key: const ValueKey('notebook-convert-to-task'),
            onPressed: _convertToTask,
            tooltip: 'تبدیل به کار',
            icon: const Icon(Icons.task_alt_outlined),
          ),
          IconButton(
            key: const ValueKey('notebook-editor-trash'),
            onPressed: _trashNote,
            tooltip: 'سطل زباله',
            icon: const Icon(Icons.delete_outline),
          ),
          if (_editing)
            TextButton(
              key: const ValueKey('notebook-done'),
              onPressed: _finishEditing,
              child: const Text('ذخیره'),
            )
          else
            IconButton(
              key: const ValueKey('notebook-edit'),
              onPressed: () => setState(() => _editing = true),
              tooltip: 'ویرایش',
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextField(
              key: const ValueKey('notebook-title'),
              controller: _title,
              readOnly: !_editing,
              maxLines: null,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              decoration: const InputDecoration(
                hintText: 'عنوان',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 4),
            if (noteDate != null)
              Text(
                _formatEditorDate(noteDate),
                key: const ValueKey('notebook-editor-date'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.72),
                    ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  key: const ValueKey('notebook-category-picker'),
                  onPressed: _pickCategory,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(
                    _category == null || _category!.trim().isEmpty
                        ? 'انتخاب دفتر'
                        : _category!,
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('notebook-project-picker'),
                  onPressed: _pickProject,
                  icon: const Icon(Icons.work_outline, size: 18),
                  label: Text(_projectTitle ?? 'انتخاب پروژه'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('notebook-tags-picker'),
                  onPressed: _pickTags,
                  icon: const Icon(Icons.sell_outlined, size: 18),
                  label: Text(
                    _tags.isEmpty ? 'برچسب‌ها' : _tags.map((tag) => '#$tag').join(' '),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 0.5),
            const SizedBox(height: 4),
            if (!_checklistMode)
              TextField(
                key: const ValueKey('notebook-description'),
                controller: _description,
                readOnly: !_editing,
                minLines: 12,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'شروع به نوشتن کنید…',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            else if (_description.text.trim().isNotEmpty)
              TextField(
                key: const ValueKey('notebook-description'),
                controller: _description,
                readOnly: !_editing,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'توضیحات',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          if (_checklistMode) ...[
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final completed = _checklist.where(_checked).length;
                final total = _checklist.length;
                final progress = total == 0 ? 0.0 : completed / total;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'چک‌لیست — $completed از $total انجام شده',
                      key: const ValueKey('notebook-checklist-progress-label'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      key: const ValueKey('notebook-checklist-progress'),
                      value: progress,
                    ),
                  ],
                );
              },
            ),
            for (var index = 0; index < _checklist.length; index++)
              CheckboxListTile(
                key: ValueKey('notebook-check-$index'),
                contentPadding: EdgeInsets.zero,
                value: _checked(_checklist[index]),
                onChanged: _editing
                    ? (value) => _toggleChecklist(index, value)
                    : null,
                title: Text(_checklistLabel(_checklist[index])),
                secondary: _editing
                    ? PopupMenuButton<String>(
                        key: ValueKey('notebook-check-menu-$index'),
                        tooltip: 'گزینه‌های مورد',
                        onSelected: (action) {
                          if (action == 'edit') {
                            _editChecklistItem(index);
                          } else if (action == 'remove') {
                            _removeChecklistItem(index);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('ویرایش مورد'),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text('حذف مورد'),
                          ),
                        ],
                      )
                    : null,
              ),
            if (_editing)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('notebook-checklist-input'),
                      controller: _checklistInput,
                      focusNode: _checklistFocus,
                      onSubmitted: (_) => _addChecklistItem(),
                      decoration: const InputDecoration(
                        labelText: 'مورد جدید چک‌لیست',
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('notebook-checklist-add'),
                    onPressed: _addChecklistItem,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
          ],
        ],
        ),
      ),
      ),
    );
  }

  static const _editorDateFormatter = PersianDateFormatter();

  static String _formatEditorDate(DateTime value) {
    final iranTime = value.toUtc().add(const Duration(hours: 3, minutes: 30));
    final date = _editorDateFormatter.format(
      iranTime,
      usePersianDate: true,
    );
    final time = _editorDateFormatter.toPersianDigits(
      '${iranTime.hour.toString().padLeft(2, '0')}:${iranTime.minute.toString().padLeft(2, '0')}',
    );
    return '$date  $time';
  }
}
