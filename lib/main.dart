import 'package:flutter/material.dart';
import 'backup_manager.dart';
import 'models/task.dart';
import 'official_calendar_page.dart';
import 'services/follow_up_calendar_projection.dart';
import 'services/home_search_projection.dart';
import 'services/task_migration_reader.dart';
import 'services/task_migration_writer.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatelessWidget {
  const ArvinApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت کارها وپیگیری آروین',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class ArvinTask {
  ArvinTask({
    required this.id,
    required this.title,
    this.description = '',
    this.followUpDate,
    this.tags = const [],
    this.archived = false,
    this.trashed = false,
    this.completed = false,
  });

  final String id;
  String title;
  String description;
  DateTime? followUpDate;
  List<String> tags;
  bool archived;
  bool trashed;
  bool completed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'followUpDate': followUpDate?.toIso8601String(),
        'tags': tags,
        'archived': archived,
        'trashed': trashed,
        'completed': completed,
      };

  factory ArvinTask.fromJson(Map<String, dynamic> json) {
    return ArvinTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.tryParse(json['followUpDate'] as String),
      tags: (json['tags'] as List<dynamic>? ?? []).whereType<String>().toList(),
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskMigrationReader migrationReader = TaskMigrationReader();
  final TaskMigrationWriter migrationWriter = TaskMigrationWriter();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  final HomeSearchProjection homeSearchProjection = const HomeSearchProjection();
  final FollowUpCalendarProjection followUpCalendarProjection =
      const FollowUpCalendarProjection();
  List<ArvinTask> tasks = [];
  List<Task> canonicalTasks = [];
  final Set<String> selected = <String>{};
  bool loading = true;
  bool selectionMode = false;
  String query = '';
  String filter = 'فعال';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final unifiedTasks = await migrationReader.load();
      final value = unifiedTasks.map(_legacyViewOf).toList();
      if (!mounted) return;
      setState(() {
        canonicalTasks = unifiedTasks;
        tasks = value;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        canonicalTasks = [];
        tasks = [];
        loading = false;
      });
    }
  }

  ArvinTask _legacyViewOf(Task task) {
    final followUpDate = task.legacyHomeFollowUpDate;
    return ArvinTask(
      id: task.id,
      title: task.title,
      description: task.description,
      followUpDate: followUpDate,
      tags: List<String>.of(task.tags),
      archived: task.archived,
      trashed: task.trashed,
      completed: task.completed,
    );
  }

  Task _canonicalSnapshotOf(ArvinTask task) {
    return Task(
      id: task.id,
      title: task.title,
      description: task.description,
      followUpEnabled: task.followUpDate != null,
      followUpDate: task.followUpDate,
      tags: List<String>.of(task.tags),
      archived: task.archived,
      trashed: task.trashed,
      completed: task.completed,
    );
  }

  List<Task> get _searchSource {
    final canonicalById = <String, Task>{
      for (final task in canonicalTasks) task.id: task,
    };
    return tasks.map((view) {
      final canonical = canonicalById[view.id];
      final snapshot = _canonicalSnapshotOf(view);
      if (canonical == null) return snapshot;
      return Task(
        id: snapshot.id,
        title: snapshot.title,
        description: snapshot.description,
        followUpEnabled: snapshot.followUpEnabled,
        followUpDate: snapshot.followUpDate,
        tags: List<String>.of(snapshot.tags),
        category: canonical.category,
        checklist: List<String>.of(canonical.checklist),
        reminderDate: canonical.reminderDate,
        archived: snapshot.archived,
        trashed: snapshot.trashed,
        completed: snapshot.completed,
        followUps: List<FollowUp>.of(canonical.followUps),
        recurrence: canonical.recurrence,
        createdAt: canonical.createdAt,
        updatedAt: canonical.updatedAt,
      );
    }).toList();
  }

  Future<void> _save() => migrationWriter.save(
        tasks.map(_canonicalSnapshotOf).toList(),
      );

  bool _overdue(ArvinTask task) {
    return task.followUpDate != null &&
        !task.completed &&
        task.followUpDate!.isBefore(DateTime.now());
  }

  List<ArvinTask> get visible {
    final matchingIds = query.trim().isEmpty
        ? null
        : homeSearchProjection.matchingIds(_searchSource, query);
    final result = tasks.where((task) {
      if (filter == 'فعال' && (task.archived || task.trashed)) return false;
      if (filter == 'بایگانی' && (!task.archived || task.trashed)) return false;
      if (filter == 'سطل زباله' && !task.trashed) return false;
      if (matchingIds != null && !matchingIds.contains(task.id)) return false;
      return true;
    }).toList();
    result.sort((a, b) => (a.followUpDate ?? DateTime(9999))
        .compareTo(b.followUpDate ?? DateTime(9999)));
    return result;
  }

  String _date(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  Future<void> _add() async {
    final task = await showDialog<ArvinTask>(context: context, builder: (_) => const TaskDialog());
    if (task == null) return;
    setState(() => tasks.add(task));
    await _save();
  }

  Future<void> _edit(ArvinTask old) async {
    final task = await showDialog<ArvinTask>(context: context, builder: (_) => TaskDialog(task: old));
    if (task == null) return;
    setState(() {
      old.title = task.title;
      old.description = task.description;
      old.followUpDate = task.followUpDate;
      old.tags = task.tags;
    });
    await _save();
  }

  Future<void> _archiveSelected() async {
    setState(() {
      for (final task in tasks) { if (selected.contains(task.id)) task.archived = true; }
      selected.clear(); selectionMode = false;
    });
    await _save();
  }

  Future<void> _trashSelected() async {
    setState(() {
      for (final task in tasks) { if (selected.contains(task.id)) task.trashed = true; }
      selected.clear(); selectionMode = false;
    });
    await _save();
  }

  Future<void> _restore(ArvinTask task) async {
    setState(() { task.trashed = false; task.archived = false; });
    await _save();
  }

  Future<void> _deleteForever(ArvinTask task) async {
    setState(() => tasks.removeWhere((item) => item.id == task.id));
    await _save();
  }

  Future<void> _toggle(ArvinTask task) async {
    setState(() => task.completed = !task.completed);
    await _save();
  }

  Future<void> _chooseBackupDirectory() async {
    try {
      final uri = await backupManager.chooseAndRememberDirectory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(uri == null ? 'انتخاب پوشه لغو شد' : 'پوشه پشتیبان با موفقیت انتخاب شد')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('انتخاب پوشه ناموفق بود: $error')));
    }
  }

  Future<void> _backupToFolder() async {
    try {
      var directory = await backupManager.getDirectory();
      if (directory == null || directory.isEmpty) directory = await backupManager.chooseAndRememberDirectory();
      if (directory == null || directory.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ابتدا یک پوشه برای پشتیبان انتخاب کنید')));
        return;
      }
      final fileName = await backupManager.backupTasks(tasks.map((task) => task.toJson()).toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fileName == null ? 'پشتیبان‌گیری انجام نشد' : 'پشتیبان ذخیره شد: $fileName')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('پشتیبان‌گیری ناموفق بود: $error')));
    }
  }

  Future<void> _restoreFromFile() async {
    try {
      final backup = await backupManager.restoreBackup();
      if (backup == null) return;
      final rawTasks = backup['tasks'];
      if (rawTasks is! List) throw const FormatException('فهرست کارهای پشتیبان نامعتبر است');
      final list = rawTasks.map((item) => ArvinTask.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      final emergencyBackup = await backupManager.backupTasks(tasks.map((task) => task.toJson()).toList());
      if (!mounted) return;
      final approved = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
        title: const Text('بازیابی اطلاعات'),
        content: Text('تعداد ${list.length} کار از پشتیبان آماده بازیابی است.\n\n${emergencyBackup == null ? '' : 'قبل از بازیابی، یک پشتیبان اضطراری نیز ساخته شد.'}'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('لغو')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('بازیابی'))],
      ));
      if (approved != true) return;
      setState(() => tasks = list);
      await _save();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${list.length} کار با موفقیت بازیابی شد')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بازیابی ناموفق بود: $error')));
    }
  }

  Future<void> _backupMenu() async {
    await showModalBottomSheet<void>(context: context, builder: (sheetContext) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.folder_outlined), title: const Text('انتخاب پوشه پشتیبان'), onTap: () { Navigator.pop(sheetContext); _chooseBackupDirectory(); }),
      ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('ایجاد Backup'), onTap: () { Navigator.pop(sheetContext); _backupToFolder(); }),
      ListTile(leading: const Icon(Icons.restore), title: const Text('Restore از فایل'), onTap: () { Navigator.pop(sheetContext); _restoreFromFile(); }),
    ])));
  }

  Future<void> _openCalendar(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final reminders = followUpCalendarProjection.project(_searchSource);
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: IranianOfficialCalendarPage(reminders: reminders),
    )));
  }

  Widget _taskCard(ArvinTask task) {
    final late = _overdue(task);
    return Dismissible(
      key: ValueKey(task.id),
      direction: selectionMode ? DismissDirection.none : DismissDirection.endToStart,
      confirmDismiss: (_) async { if (task.trashed) { await _deleteForever(task); } else { setState(() => task.trashed = true); await _save(); } return true; },
      background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), color: Theme.of(context).colorScheme.errorContainer, child: const Icon(Icons.delete_outline)),
      child: Card(child: ListTile(
        onLongPress: () => setState(() { selectionMode = true; selected.add(task.id); }),
        onTap: selectionMode ? () => setState(() { if (selected.contains(task.id)) { selected.remove(task.id); } else { selected.add(task.id); } }) : () => _edit(task),
        leading: selectionMode ? Checkbox(value: selected.contains(task.id), onChanged: (_) => setState(() { if (selected.contains(task.id)) { selected.remove(task.id); } else { selected.add(task.id); } })) : IconButton(onPressed: () => _toggle(task), icon: Icon(task.completed ? Icons.check_circle : late ? Icons.warning_amber : Icons.radio_button_unchecked)),
        title: Text(task.title, style: TextStyle(fontWeight: FontWeight.w700, decoration: task.completed ? TextDecoration.lineThrough : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (task.description.isNotEmpty) Text(task.description),
          if (task.tags.isNotEmpty) Wrap(spacing: 4, children: task.tags.map<Widget>((tag) => Chip(label: Text(tag), visualDensity: VisualDensity.compact)).toList()),
          if (task.followUpDate != null) Text('پیگیری: ${_date(task.followUpDate!)}${late ? '  •  عقب‌افتاده' : ''}'),
          if (task.trashed) TextButton(onPressed: () => _restore(task), child: const Text('بازگردانی')),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final item in ['فعال', 'بایگانی', 'سطل زباله']) {
      chips.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: ChoiceChip(label: Text(item), selected: filter == item, onSelected: (_) => setState(() => filter = item))));
    }
    return Scaffold(
      drawer: Drawer(child: SafeArea(child: Builder(builder: (drawerContext) => ListView(padding: EdgeInsets.zero, children: [
        const ListTile(leading: Icon(Icons.dashboard_outlined), title: Text('آروین', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('مدیریت کارها و پیگیری‌ها')),
        const Divider(),
        ListTile(leading: const Icon(Icons.calendar_month_outlined), title: const Text('تقویم'), onTap: () => _openCalendar(drawerContext)),
      ])))),
      appBar: AppBar(centerTitle: true, title: const Column(mainAxisSize: MainAxisSize.min, children: [Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', style: TextStyle(fontSize: 13)), SizedBox(height: 3), Text('مدیریت کارها وپیگیری آروین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]), actions: [IconButton(onPressed: _backupMenu, tooltip: 'پشتیبان', icon: const Icon(Icons.backup_outlined)), IconButton(onPressed: () => setState(() { selectionMode = !selectionMode; if (!selectionMode) selected.clear(); }), icon: Icon(selectionMode ? Icons.close : Icons.checklist))]),
      body: loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 0), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'جست‌وجو در کارها', border: OutlineInputBorder()), onChanged: (value) => setState(() => query = value))),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: chips)),
        if (selectionMode) Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(child: FilledButton.tonalIcon(onPressed: selected.isEmpty ? null : _archiveSelected, icon: const Icon(Icons.archive_outlined), label: const Text('بایگانی'))), const SizedBox(width: 8), Expanded(child: FilledButton.tonalIcon(onPressed: selected.isEmpty ? null : _trashSelected, icon: const Icon(Icons.delete_outline), label: const Text('حذف')))])),
        Expanded(child: visible.isEmpty ? const Center(child: Text('کاری برای نمایش وجود ندارد')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: visible.length, itemBuilder: (_, index) => _taskCard(visible[index]))),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('کار جدید')),
    );
  }
}

class TaskDialog extends StatefulWidget {
  const TaskDialog({super.key, this.task});
  final ArvinTask? task;
  @override State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController tags;
  DateTime? followUpDate;
  @override void initState() { super.initState(); title = TextEditingController(text: widget.task?.title ?? ''); description = TextEditingController(text: widget.task?.description ?? ''); tags = TextEditingController(text: widget.task?.tags.join(', ') ?? ''); followUpDate = widget.task?.followUpDate; }
  @override void dispose() { title.dispose(); description.dispose(); tags.dispose(); super.dispose(); }
  Future<void> _pickDate() async { final now = DateTime.now(); final date = await showDatePicker(context: context, initialDate: followUpDate ?? now, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 10)); if (date != null) setState(() => followUpDate = date); }
  @override Widget build(BuildContext context) => AlertDialog(title: Text(widget.task == null ? 'کار جدید' : 'ویرایش کار'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان')), TextField(controller: description, decoration: const InputDecoration(labelText: 'توضیحات')), TextField(controller: tags, decoration: const InputDecoration(labelText: 'برچسب‌ها با ویرگول')), const SizedBox(height: 12), ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event), title: Text(followUpDate == null ? 'تاریخ پیگیری' : '${followUpDate!.year}/${followUpDate!.month}/${followUpDate!.day}'), onTap: _pickDate, trailing: followUpDate == null ? null : IconButton(onPressed: () => setState(() => followUpDate = null), icon: const Icon(Icons.close)))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')), FilledButton(onPressed: () { if (title.text.trim().isEmpty) return; Navigator.pop(context, ArvinTask(id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), description: description.text.trim(), followUpDate: followUpDate, tags: tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(), archived: widget.task?.archived ?? false, trashed: widget.task?.trashed ?? false, completed: widget.task?.completed ?? false)); }, child: const Text('ذخیره'))]);
}
