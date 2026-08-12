import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatelessWidget {
  const ArvinApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مدیریت کارها وپیگیری آروین',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const Directionality(textDirection: TextDirection.rtl, child: HomePage()),
      );
}

class ArvinTask {
  ArvinTask({required this.id, required this.title, this.description = '', this.followUpDate, this.tags = const [], this.archived = false, this.trashed = false, this.completed = false});
  final String id;
  String title, description;
  DateTime? followUpDate;
  List<String> tags;
  bool archived, trashed, completed;
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'followUpDate': followUpDate?.toIso8601String(), 'tags': tags, 'archived': archived, 'trashed': trashed, 'completed': completed};
  factory ArvinTask.fromJson(Map<String, dynamic> j) => ArvinTask(id: j['id'] as String, title: j['title'] as String? ?? '', description: j['description'] as String? ?? '', followUpDate: j['followUpDate'] == null ? null : DateTime.tryParse(j['followUpDate'] as String), tags: (j['tags'] as List<dynamic>? ?? []).whereType<String>().toList(), archived: j['archived'] as bool? ?? false, trashed: j['trashed'] as bool? ?? false, completed: j['completed'] as bool? ?? false);
}

class TaskRepository {
  static const key = 'arvin.tasks';
  Future<List<ArvinTask>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try { return (jsonDecode(raw) as List<dynamic>).map((e) => ArvinTask.fromJson(Map<String, dynamic>.from(e as Map))).toList(); } catch (_) { return []; }
  }
  Future<void> save(List<ArvinTask> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  final repo = TaskRepository();
  List<ArvinTask> tasks = [];
  bool loading = true, selectionMode = false;
  final selected = <String>{};
  String query = '', filter = 'فعال';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final v = await repo.load(); if (!mounted) return; setState(() { tasks = v; loading = false; }); }
  Future<void> _save() => repo.save(tasks);
  bool _overdue(ArvinTask t) => t.followUpDate != null && !t.completed && t.followUpDate!.isBefore(DateTime.now());
  List<ArvinTask> get visible {
    final result = tasks.where((t) {
      if (filter == 'فعال' && (t.archived || t.trashed)) return false;
      if (filter == 'بایگانی' && (!t.archived || t.trashed)) return false;
      if (filter == 'سطل زباله' && !t.trashed) return false;
      if (query.isNotEmpty && !('${t.title} ${t.description} ${t.tags.join(' ')}'.toLowerCase().contains(query.toLowerCase()))) return false;
      return true;
    }).toList();
    result.sort((a, b) => (a.followUpDate ?? DateTime(9999)).compareTo(b.followUpDate ?? DateTime(9999)));
    return result;
  }
  String _date(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  Future<void> _add() async { final t = await showDialog<ArvinTask>(context: context, builder: (_) => const TaskDialog()); if (t == null) return; setState(() => tasks.add(t)); await _save(); }
  Future<void> _edit(ArvinTask old) async { final t = await showDialog<ArvinTask>(context: context, builder: (_) => TaskDialog(task: old)); if (t == null) return; setState(() { old.title = t.title; old.description = t.description; old.followUpDate = t.followUpDate; old.tags = t.tags; }); await _save(); }
  Future<void> _archiveSelected() async { setState(() { for (final t in tasks) { if (selected.contains(t.id)) t.archived = true; } selected.clear(); selectionMode = false; }); await _save(); }
  Future<void> _trashSelected() async { setState(() { for (final t in tasks) { if (selected.contains(t.id)) t.trashed = true; } selected.clear(); selectionMode = false; }); await _save(); }
  Future<void> _restore(ArvinTask t) async { setState(() { t.trashed = false; t.archived = false; }); await _save(); }
  Future<void> _deleteForever(ArvinTask t) async { setState(() => tasks.removeWhere((x) => x.id == t.id)); await _save(); }
  void _toggle(ArvinTask t) { setState(() => t.completed = !t.completed); _save(); }

  String _backupJson() => const JsonEncoder.withIndent('  ').convert({'format': 'arvin-backup-v1', 'createdAt': DateTime.now().toIso8601String(), 'tasks': tasks.map((e) => e.toJson()).toList()});
  Future<void> _backup() async {
    final data = _backupJson();
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('پشتیبان‌گیری'), content: const Text('نسخه پشتیبان به صورت JSON ساخته و در کلیپ‌بورد کپی شد. آن را در یک فایل متنی امن ذخیره کنید.'), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('متوجه شدم'))]));
  }
  Future<void> _restoreBackup() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('بازیابی پشتیبان'), content: TextField(controller: controller, minLines: 8, maxLines: 14, decoration: const InputDecoration(hintText: 'JSON پشتیبان را اینجا وارد کنید')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')), FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('بازیابی'))]));
    controller.dispose();
    if (value == null || value.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      if (decoded['format'] != 'arvin-backup-v1' || decoded['tasks'] is! List) throw const FormatException();
      final restored = (decoded['tasks'] as List<dynamic>).map((e) => ArvinTask.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      setState(() { tasks = restored; selected.clear(); selectionMode = false; filter = 'فعال'; query = ''; });
      await _save();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${restored.length} کار بازیابی شد')));
    } catch (_) {
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('پشتیبان نامعتبر'), content: const Text('ساختار JSON پشتیبان آروین معتبر نیست.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('باشه'))]));
    }
  }
  Future<void> _backupMenu() async {
    await showModalBottomSheet<void>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('ایجاد پشتیبان'), subtitle: const Text('ساخت JSON و کپی در کلیپ‌بورد'), onTap: () { Navigator.pop(context); _backup(); }), ListTile(leading: const Icon(Icons.restore_outlined), title: const Text('بازیابی پشتیبان'), subtitle: const Text('وارد کردن JSON ذخیره‌شده'), onTap: () { Navigator.pop(context); _restoreBackup(); })])));
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(centerTitle: true, title: const Column(mainAxisSize: MainAxisSize.min, children: [Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', style: TextStyle(fontSize: 13)), SizedBox(height: 3), Text('مدیریت کارها وپیگیری آروین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]), actions: [IconButton(onPressed: _backupMenu, tooltip: 'پشتیبان', icon: const Icon(Icons.backup_outlined)), IconButton(onPressed: () => setState(() { selectionMode = !selectionMode; if (!selectionMode) selected.clear(); }), icon: Icon(selectionMode ? Icons.close : Icons.checklist))]),
    body: loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'جست‌وجو'))),
      SizedBox(height: 52, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: ['فعال', 'بایگانی', 'سطل زباله'].map<Widget>((f) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: ChoiceChip(label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f))).toList())),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Expanded(child: _Stat('کل', tasks.where((t) => !t.trashed).length, Icons.list_alt)), Expanded(child: _Stat('فعال', tasks.where((t) => !t.archived && !t.trashed && !t.completed).length, Icons.pending_actions)), Expanded(child: _Stat('انجام‌شده', tasks.where((t) => t.completed && !t.trashed).length, Icons.check_circle)), Expanded(child: _Stat('عقب‌افتاده', tasks.where(_overdue).length, Icons.warning_amber))])),
      Expanded(child: visible.isEmpty ? Center(child: Text(filter == 'سطل زباله' ? 'سطل زباله خالی است' : 'کاری برای نمایش وجود ندارد')) : ListView.separated(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), itemCount: visible.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) { final t = visible[i]; final late = _overdue(t); return Dismissible(key: ValueKey(t.id), direction: selectionMode ? DismissDirection.none : DismissDirection.endToStart, confirmDismiss: (_) async { if (t.trashed) { await _deleteForever(t); } else { setState(() => t.trashed = true); await _save(); } return true; }, background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), color: Theme.of(context).colorScheme.errorContainer, child: const Icon(Icons.delete_outline)), child: Card(child: ListTile(onLongPress: () => setState(() { selectionMode = true; selected.add(t.id); }), onTap: selectionMode ? () => setState(() => selected.contains(t.id) ? selected.remove(t.id) : selected.add(t.id)) : () => _edit(t), leading: selectionMode ? Checkbox(value: selected.contains(t.id), onChanged: (_) => setState(() => selected.contains(t.id) ? selected.remove(t.id) : selected.add(t.id))) : IconButton(onPressed: () => _toggle(t), icon: Icon(t.completed ? Icons.check_circle : late ? Icons.warning_amber : Icons.radio_button_unchecked)), title: Text(t.title, style: TextStyle(fontWeight: FontWeight.w700, decoration: t.completed ? TextDecoration.lineThrough : null)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (t.description.isNotEmpty) Text(t.description), if (t.tags.isNotEmpty) Wrap(spacing: 4, children: t.tags.map<Widget>((x) => Chip(label: Text(x), visualDensity: VisualDensity.compact)).toList()), if (t.followUpDate != null) Text('پیگیری: ${_date(t.followUpDate!)}${late ? '  •  عقب‌افتاده' : ''}'), if (t.trashed) TextButton(onPressed: () => _restore(t), child: const Text('بازگردانی'))])))); }))]),
    floatingActionButton: selected.isEmpty ? FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('کار جدید')) : null,
    bottomNavigationBar: selected.isEmpty ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [FilledButton.icon(onPressed: _archiveSelected, icon: const Icon(Icons.archive_outlined), label: const Text('بایگانی')), FilledButton.tonalIcon(onPressed: _trashSelected, icon: const Icon(Icons.delete_outline), label: const Text('حذف'))]))),
  );
}

class _Stat extends StatelessWidget { const _Stat(this.label, this.value, this.icon); final String label; final int value; final IconData icon; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(6), child: Column(children: [Icon(icon, size: 20), Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 10))]))); }

class TaskDialog extends StatefulWidget { const TaskDialog({super.key, this.task}); final ArvinTask? task; @override State<TaskDialog> createState() => _TaskDialogState(); }
class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController title, desc, tag; DateTime? followUpDate; late List<String> tags;
  @override void initState() { super.initState(); final t = widget.task; title = TextEditingController(text: t?.title); desc = TextEditingController(text: t?.description); tag = TextEditingController(); followUpDate = t?.followUpDate; tags = List.of(t?.tags ?? []); }
  @override void dispose() { title.dispose(); desc.dispose(); tag.dispose(); super.dispose(); }
  Future<void> _pickDate() async { final d = await showDatePicker(context: context, initialDate: followUpDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: 'انتخاب تاریخ پیگیری', cancelText: 'لغو', confirmText: 'تأیید'); if (d != null) setState(() => followUpDate = d); }
  void _addTag() { if (tag.text.trim().isNotEmpty) setState(() { tags.add(tag.text.trim()); tag.clear(); }); }
  void _submit() { if (title.text.trim().isEmpty) return; Navigator.pop(context, ArvinTask(id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), description: desc.text.trim(), followUpDate: followUpDate, tags: List.of(tags), archived: widget.task?.archived ?? false, trashed: widget.task?.trashed ?? false, completed: widget.task?.completed ?? false)); }
  @override Widget build(BuildContext context) => AlertDialog(title: Text(widget.task == null ? 'کار جدید' : 'ویرایش کار'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, autofocus: true, decoration: const InputDecoration(labelText: 'عنوان کار')), const SizedBox(height: 12), TextField(controller: desc, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'توضیحات')), const SizedBox(height: 12), Row(children: [Expanded(child: TextField(controller: tag, onSubmitted: (_) => _addTag(), decoration: const InputDecoration(labelText: 'تگ'))), IconButton(onPressed: _addTag, icon: const Icon(Icons.add))]), Wrap(spacing: 4, children: tags.map<Widget>((x) => InputChip(label: Text(x), onDeleted: () => setState(() => tags.remove(x)))).toList()), ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_outlined), title: Text(followUpDate == null ? 'تاریخ پیگیری انتخاب نشده' : 'تاریخ: ${followUpDate!.year}/${followUpDate!.month}/${followUpDate!.day}'), trailing: TextButton(onPressed: _pickDate, child: const Text('انتخاب'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')), FilledButton(onPressed: title.text.trim().isEmpty ? null : _submit, child: const Text('ذخیره'))]);
}
