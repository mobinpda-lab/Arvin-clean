import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatelessWidget {
  const ArvinApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مدیریت کارها وپیگیری آروین',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder())),
        home: const Directionality(textDirection: TextDirection.rtl, child: HomePage()),
      );
}

class ArvinTask {
  ArvinTask({required this.id, required this.title, this.description = '', this.followUpDate, this.tags = const [], this.archived = false, this.trashed = false, this.completed = false});
  final String id;
  String title;
  String description;
  DateTime? followUpDate;
  List<String> tags;
  bool archived;
  bool trashed;
  bool completed;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'followUpDate': followUpDate?.toIso8601String(), 'tags': tags, 'archived': archived, 'trashed': trashed, 'completed': completed};
  factory ArvinTask.fromJson(Map<String, dynamic> j) => ArvinTask(id: j['id'] as String, title: j['title'] as String? ?? '', description: j['description'] as String? ?? '', followUpDate: j['followUpDate'] == null ? null : DateTime.tryParse(j['followUpDate'] as String), tags: (j['tags'] as List<dynamic>? ?? []).whereType<String>().toList(), archived: j['archived'] as bool? ?? false, trashed: j['trashed'] as bool? ?? false, completed: j['completed'] as bool? ?? false);
}

class TaskRepository {
  static const _key = 'arvin.tasks';
  Future<List<ArvinTask>> load() async { final p = await SharedPreferences.getInstance(); final raw = p.getString(_key); if (raw == null || raw.isEmpty) return []; try { return (jsonDecode(raw) as List<dynamic>).map((e) => ArvinTask.fromJson(e as Map<String, dynamic>)).toList(); } catch (_) { return []; } }
  Future<void> save(List<ArvinTask> tasks) async { final p = await SharedPreferences.getInstance(); await p.setString(_key, jsonEncode(tasks.map((e) => e.toJson()).toList())); }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  final _repo = TaskRepository();
  List<ArvinTask> _tasks = [];
  bool _loading = true;
  bool _selectionMode = false;
  final Set<String> _selected = {};
  String _query = '';
  String _filter = 'فعال';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final tasks = await _repo.load(); if (!mounted) return; setState(() { _tasks = tasks; _loading = false; }); }
  Future<void> _save() => _repo.save(_tasks);

  List<ArvinTask> get _visible {
    final q = _query.trim().toLowerCase();
    return _tasks.where((t) {
      if (_filter == 'فعال' && (t.archived || t.trashed)) return false;
      if (_filter == 'بایگانی' && (!t.archived || t.trashed)) return false;
      if (_filter == 'سطل زباله' && !t.trashed) return false;
      if (q.isNotEmpty && !('${t.title} ${t.description} ${t.tags.join(' ')}'.toLowerCase().contains(q))) return false;
      return true;
    }).toList();
  }

  Future<void> _addTask() async { final task = await showDialog<ArvinTask>(context: context, builder: (_) => const AddTaskDialog()); if (task == null) return; setState(() => _tasks = [..._tasks, task]); await _save(); }
  Future<void> _toggleSelected(ArvinTask t) async { setState(() => t.completed = !t.completed); await _save(); }
  Future<void> _archiveSelected() async { setState(() { for (final t in _tasks.where((t) => _selected.contains(t.id))) { t.archived = true; } _selected.clear(); _selectionMode = false; }); await _save(); }
  Future<void> _trashSelected() async { setState(() { for (final t in _tasks.where((t) => _selected.contains(t.id))) { t.trashed = true; } _selected.clear(); _selectionMode = false; }); await _save(); }
  Future<void> _restore(ArvinTask t) async { setState(() { t.trashed = false; t.archived = false; }); await _save(); }
  Future<void> _permanentDelete(ArvinTask t) async { setState(() => _tasks.removeWhere((x) => x.id == t.id)); await _save(); }

  String _date(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(centerTitle: true, title: const Column(mainAxisSize: MainAxisSize.min, children: [Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)), SizedBox(height: 4), Text('مدیریت کارها وپیگیری آروین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]),
    actions: [IconButton(onPressed: () => setState(() => _selectionMode = !_selectionMode), icon: Icon(_selectionMode ? Icons.close : Icons.checklist))],
    body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: TextField(onChanged: (v) => setState(() => _query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'جست‌وجو در کارها'))),
      SizedBox(height: 52, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: ['فعال', 'بایگانی', 'سطل زباله'].map((f) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: ChoiceChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f))).toList())),
      Expanded(child: _visible.isEmpty ? Center(child: Text(_filter == 'سطل زباله' ? 'سطل زباله خالی است' : 'کاری برای نمایش وجود ندارد')) : ListView.separated(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), itemCount: _visible.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) { final t = _visible[i]; return Dismissible(key: ValueKey(t.id), direction: _selectionMode ? DismissDirection.none : DismissDirection.horizontal, confirmDismiss: (_) async { if (t.trashed) { await _permanentDelete(t); } else { setState(() => t.trashed = true); await _save(); } return true; }, background: Container(color: Theme.of(context).colorScheme.errorContainer, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete_outline)), child: Card(child: ListTile(onLongPress: () => setState(() { _selectionMode = true; _selected.add(t.id); }), onTap: _selectionMode ? () => setState(() { _selected.contains(t.id) ? _selected.remove(t.id) : _selected.add(t.id); }) : () => _toggleSelected(t), leading: _selectionMode ? Checkbox(value: _selected.contains(t.id), onChanged: (_) => setState(() { _selected.contains(t.id) ? _selected.remove(t.id) : _selected.add(t.id); })) : Icon(t.completed ? Icons.check_circle : Icons.radio_button_unchecked), title: Text(t.title, style: TextStyle(fontWeight: FontWeight.w700, decoration: t.completed ? TextDecoration.lineThrough : null)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (t.description.isNotEmpty) Text(t.description), if (t.tags.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Wrap(spacing: 4, children: t.tags.map((x) => Chip(label: Text(x), visualDensity: VisualDensity.compact)).toList())), if (t.followUpDate != null) Text(_date(t.followUpDate!)), if (t.trashed) TextButton(onPressed: () => _restore(t), child: const Text('بازگردانی'))])))); }) )]),
    floatingActionButton: _selected.isEmpty ? FloatingActionButton.extended(onPressed: _addTask, icon: const Icon(Icons.add), label: const Text('کار جدید')) : null,
    bottomNavigationBar: _selected.isEmpty ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [FilledButton.icon(onPressed: _archiveSelected, icon: const Icon(Icons.archive_outlined), label: const Text('بایگانی')), FilledButton.tonalIcon(onPressed: _trashSelected, icon: const Icon(Icons.delete_outline), label: const Text('حذف'))]))),
  );
}

class AddTaskDialog extends StatefulWidget { const AddTaskDialog({super.key}); @override State<AddTaskDialog> createState() => _AddTaskDialogState(); }
class _AddTaskDialogState extends State<AddTaskDialog> {
  final _title = TextEditingController(); final _desc = TextEditingController(); final _tag = TextEditingController(); DateTime? _date; final List<String> _tags = [];
  @override void dispose() { _title.dispose(); _desc.dispose(); _tag.dispose(); super.dispose(); }
  Future<void> _pickDate() async { final d = await showDatePicker(context: context, initialDate: _date ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: 'انتخاب تاریخ پیگیری', cancelText: 'لغو', confirmText: 'تأیید'); if (d != null) setState(() => _date = d); }
  void _submit() { final title = _title.text.trim(); if (title.isEmpty) return; Navigator.pop(context, ArvinTask(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, description: _desc.text.trim(), followUpDate: _date, tags: List.of(_tags))); }
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('کار جدید'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _title, autofocus: true, decoration: const InputDecoration(labelText: 'عنوان کار')), const SizedBox(height: 12), TextField(controller: _desc, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'توضیحات')), const SizedBox(height: 12), Row(children: [Expanded(child: TextField(controller: _tag, onSubmitted: (v) { if (v.trim().isNotEmpty) setState(() { _tags.add(v.trim()); _tag.clear(); }); }, decoration: const InputDecoration(labelText: 'تگ'))), IconButton(onPressed: () { if (_tag.text.trim().isNotEmpty) setState(() { _tags.add(_tag.text.trim()); _tag.clear(); }); }, icon: const Icon(Icons.add))]), Wrap(spacing: 4, children: _tags.map((x) => InputChip(label: Text(x), onDeleted: () => setState(() => _tags.remove(x)))).toList()), ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_outlined), title: Text(_date == null ? 'تاریخ پیگیری انتخاب نشده' : 'تاریخ: ${_date!.year}/${_date!.month}/${_date!.day}'), trailing: TextButton(onPressed: _pickDate, child: const Text('انتخاب'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')), FilledButton(onPressed: _title.text.trim().isEmpty ? null : _submit, child: const Text('ذخیره'))]);
}
