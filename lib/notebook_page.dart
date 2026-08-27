import 'dart:async';

import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/canonical_notebook_repository.dart';

enum _NotebookCreateMode { note, checklist }

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
                onTap: () => Navigator.of(sheetContext).pop(_NotebookCreateMode.note),
              ),
              ListTile(
                key: const ValueKey('notebook-create-checklist'),
                leading: const Icon(Icons.checklist_outlined),
                title: const Text('چک‌لیست'),
                subtitle: const Text('برای لیست خرید، سفر و کارهای مرحله‌ای'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NotebookCreateMode.checklist),
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

  Future<void> _create() async {
    final mode = await _chooseCreateMode();
    if (!mounted || mode == null) return;

    final isChecklist = mode == _NotebookCreateMode.checklist;
    final note = await widget.repository.createNote(
      title: isChecklist ? 'چک‌لیست جدید' : 'یادداشت جدید',
    );
    if (!mounted) return;
    await _open(
      note,
      startEditing: true,
      focusChecklistOnOpen: isChecklist,
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
                        leading: const Icon(Icons.note_alt_outlined),
                        title: Text(note.title),
                        subtitle: note.description.trim().isEmpty
                            ? Text('${note.checklist.length} مورد چک‌لیست')
                            : Text(
                                note.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        onTap: () => _open(note),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('notebook-create'),
        onPressed: _loading ? null : _create,
        icon: const Icon(Icons.add),
        label: const Text('یادداشت جدید'),
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
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _checklistInput = TextEditingController();
  final _checklistFocus = FocusNode();
  Timer? _autosaveTimer;
  Task? _note;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  List<String> _checklist = [];

  @override
  void initState() {
    super.initState();
    _editing = widget.startEditing;
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
        checklist: _checklist,
      );
    } finally {
      _saving = false;
    }
  }

  Future<void> _finishEditing() async {
    await _saveNow();
    if (mounted) setState(() => _editing = false);
  }

  void _addChecklistItem() {
    if (!_editing) return;
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
    if (!_editing) return;
    final label = _checklistLabel(_checklist[index]);
    setState(() {
      _checklist[index] = value == true ? '[x] $label' : '[ ] $label';
    });
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
        title: const Text('یادداشت'),
        actions: [
          if (_editing)
            IconButton(
              key: const ValueKey('notebook-done'),
              tooltip: 'پایان ویرایش',
              onPressed: _finishEditing,
              icon: const Icon(Icons.done),
            )
          else
            IconButton(
              key: const ValueKey('notebook-edit'),
              tooltip: 'ویرایش',
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_outlined),
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
      ),
    );
  }
}
