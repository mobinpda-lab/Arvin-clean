import 'dart:async';

import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/canonical_notebook_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final notes = await widget.repository.loadNotes();
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
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

  Future<_NotebookCreateMode?> _chooseCreateMode() {
    return showModalBottomSheet<_NotebookCreateMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'چه چیزی می‌خواهید بسازید؟',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                key: const ValueKey('notebook-create-note'),
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('یادداشت ساده'),
                subtitle: const Text('برای متن، توضیح و یادداشت‌های آزاد'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NotebookCreateMode.note),
              ),
              ListTile(
                key: const ValueKey('notebook-create-checklist'),
                leading: const Icon(Icons.checklist_outlined),
                title: const Text('چک‌لیست'),
                subtitle: const Text('برای لیست خرید، سفر و کارهای مرحله‌ای'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_NotebookCreateMode.checklist),
              ),
              TextButton(
                key: const ValueKey('notebook-create-cancel'),
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('انصراف'),
              ),
            ],
          ),
        ),
      ),
    );
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
                      : Text('${preset.items.length} مورد پیشنهادی قابل ویرایش'),
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
    final mode = await _chooseCreateMode();
    if (!mounted || mode == null) return;

    if (mode == _NotebookCreateMode.note) {
      final note = await widget.repository.createNote(title: 'یادداشت جدید');
      if (!mounted) return;
      await _open(note, startEditing: true);
      return;
    }

    final preset = await _chooseChecklistPreset();
    if (!mounted || preset == null) return;

    final note = await widget.repository.createNote(
      title: preset.title,
      checklist: preset.items,
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
    return Scaffold(
      appBar: AppBar(title: const Text('دفترچه آروین')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('هنوز یادداشتی ثبت نشده است'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      child: ListTile(
                        key: ValueKey('notebook-note-${note.id}'),
                        leading: Icon(
                          note.checklist.isEmpty
                              ? Icons.note_alt_outlined
                              : Icons.checklist_outlined,
                        ),
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.description.trim().isNotEmpty)
                              Text(
                                note.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            else if (note.checklist.isNotEmpty)
                              Text('${note.checklist.length} مورد چک‌لیست'),
                            if (note.category?.trim().isNotEmpty ?? false)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'دسته: ${note.category}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _open(note),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('notebook-create'),
        onPressed: _loading ? null : _create,
        tooltip: 'یادداشت جدید',
        child: const Icon(Icons.add),
      ),
    );
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
    _checklistMode = _checklistMode || note.checklist.isNotEmpty;
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
          onSubmitted: (next) => Navigator.of(dialogContext).pop(next.trim()),
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          children: [
            Text(
              'انتخاب دسته',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('notebook-category-clear'),
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('بدون دسته'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_clearCategoryToken),
            ),
            for (final category in categories)
              ListTile(
                key: ValueKey('notebook-category-$category'),
                leading: const Icon(Icons.folder_outlined),
                title: Text(category),
                trailing: category == _category
                    ? const Icon(Icons.check, color: Color(0xFF4A4CAB))
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(category),
              ),
            ListTile(
              key: const ValueKey('notebook-category-new'),
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('دسته جدید'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_checklistMode ? 'چک‌لیست' : 'یادداشت'),
        actions: [
          if (_editing)
            TextButton.icon(
              key: const ValueKey('notebook-done'),
              onPressed: _finishEditing,
              icon: const Icon(Icons.done),
              label: const Text('تمام'),
            )
          else
            TextButton.icon(
              key: const ValueKey('notebook-edit'),
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('ویرایش'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('notebook-title'),
            controller: _title,
            readOnly: !_editing,
            decoration: const InputDecoration(labelText: 'عنوان'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('notebook-description'),
            controller: _description,
            readOnly: !_editing,
            maxLines: 7,
            decoration: const InputDecoration(labelText: 'متن یادداشت'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('notebook-category-picker'),
            onPressed: _pickCategory,
            icon: const Icon(Icons.folder_outlined),
            label: Text(
              _category == null || _category!.trim().isEmpty
                  ? 'انتخاب دسته'
                  : 'دسته: $_category',
            ),
          ),
          if (_checklistMode) ...[
            const SizedBox(height: 20),
            Text(
              'چک‌لیست',
              style: Theme.of(context).textTheme.titleMedium,
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
                      decoration:
                          const InputDecoration(labelText: 'مورد جدید چک‌لیست'),
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
    );
  }
}
