import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_manager.dart';
import 'core/storage/task_store.dart';
import 'models/task.dart';
import 'services/task_migration_reader.dart';

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

class TaskRepository implements TaskStore<ArvinTask> {
  static const String key = 'arvin.tasks';

  @override
  Future<List<ArvinTask>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((item) => ArvinTask.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<ArvinTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskRepository repo = TaskRepository();
  final TaskMigrationReader migrationReader = TaskMigrationReader();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  List<ArvinTask> tasks = [];
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
        tasks = value;
        loading = false;
      });
    } catch (_) {
      // Preserve the existing UI behavior for malformed storage: show the
      // empty state rather than allowing a read-only migration boundary to
      // break Home. No storage is written by this slice.
      if (!mounted) return;
      setState(() {
        tasks = [];
        loading = false;
      });
    }
  }

  ArvinTask _legacyViewOf(Task task) {
    final followUpDate = task.followUps.isEmpty
        ? task.followUpDate
        : task.followUps.first.date;
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

  Future<void> _save() => repo.save(tasks);

  bool _overdue(ArvinTask task) {
    return task.followUpDate != null &&
        !task.completed &&
        task.followUpDate!.isBefore(DateTime.now());
  }

  List<ArvinTask> get visible {
    final result = tasks.where((task) {
      if (filter == 'فعال' && (task.archived || task.trashed)) return false;
      if (filter == 'بایگانی' && (!task.archived || task.trashed)) return false;
      if (filter == 'سطل زباله' && !task.trashed) return false;
      if (query.trim().isNotEmpty) {
        final haystack =
            '${task.title} ${task.description} ${task.tags.join(' ')}'.toLowerCase();
        if (!haystack.contains(query.trim().toLowerCase())) return false;
      }
      return true;
    }).toList();

    result.sort(
      (a, b) => (a.followUpDate ?? DateTime(9999))
          .compareTo(b.followUpDate ?? DateTime(9999)),
    );
    return result;
  }

  String _date(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  Future<void> _add() async {
    final task = await showDialog<ArvinTask>(
      context: context,
      builder: (_) => const TaskDialog(),
    );
    if (task == null) return;
    setState(() => tasks.add(task));
    await _save();
  }

  Future<void> _edit(ArvinTask old) async {
    final task = await showDialog<ArvinTask>(
      context: context,
      builder: (_) => TaskDialog(task: old),
    );
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
      for (final task in tasks) {
        if (selected.contains(task.id)) task.archived = true;
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _trashSelected() async {
    setState(() {
      for (final task in tasks) {
        if (selected.contains(task.id)) task.trashed = true;
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _restoreSelected() async {
    setState(() {
      for (final task in tasks) {
        if (selected.contains(task.id)) {
          task.archived = false;
          task.trashed = false;
        }
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _deleteSelectedPermanently() async {
    setState(() {
      tasks.removeWhere((task) => selected.contains(task.id));
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _toggleComplete(ArvinTask task) async {
    setState(() => task.completed = !task.completed);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('آروین'),
        actions: [
          IconButton(
            tooltip: 'پشتیبان‌گیری',
            onPressed: () async {
              await backupManager.createBackup(tasks);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('پشتیبان تهیه شد.')),
              );
            },
            icon: const Icon(Icons.backup),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'جستجو در کارها...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => query = value),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: ['فعال', 'بایگانی', 'سطل زباله']
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(item),
                              selected: filter == item,
                              onSelected: (_) => setState(() => filter = item),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (selectionMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text('${selected.length} مورد انتخاب شده'),
                        const Spacer(),
                        if (filter == 'سطل زباله')
                          IconButton(
                            tooltip: 'بازگردانی',
                            onPressed: selected.isEmpty ? null : _restoreSelected,
                            icon: const Icon(Icons.restore),
                          ),
                        if (filter == 'سطل زباله')
                          IconButton(
                            tooltip: 'حذف دائمی',
                            onPressed: selected.isEmpty
                                ? null
                                : _deleteSelectedPermanently,
                            icon: const Icon(Icons.delete_forever),
                          )
                        else
                          IconButton(
                            tooltip: 'بایگانی',
                            onPressed: selected.isEmpty ? null : _archiveSelected,
                            icon: const Icon(Icons.archive),
                          ),
                        if (filter != 'سطل زباله')
                          IconButton(
                            tooltip: 'سطل زباله',
                            onPressed: selected.isEmpty ? null : _trashSelected,
                            icon: const Icon(Icons.delete),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: visible.isEmpty
                      ? const Center(child: Text('موردی برای نمایش وجود ندارد.'))
                      : ListView.builder(
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final task = visible[index];
                            final overdue = _overdue(task);
                            final checked = selected.contains(task.id);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: selectionMode
                                    ? Checkbox(
                                        value: checked,
                                        onChanged: (_) => setState(() {
                                          if (checked) {
                                            selected.remove(task.id);
                                          } else {
                                            selected.add(task.id);
                                          }
                                        }),
                                      )
                                    : IconButton(
                                        tooltip: task.completed ? 'بازگردانی' : 'انجام شد',
                                        onPressed: () => _toggleComplete(task),
                                        icon: Icon(
                                          task.completed
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                        ),
                                      ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description.isNotEmpty)
                                      Text(task.description),
                                    if (task.followUpDate != null)
                                      Text(
                                        'پیگیری: ${_date(task.followUpDate!)}',
                                        style: TextStyle(
                                          color: overdue ? Colors.red : null,
                                        ),
                                      ),
                                    if (task.tags.isNotEmpty)
                                      Text('برچسب‌ها: ${task.tags.join(', ')}'),
                                  ],
                                ),
                                onLongPress: () => setState(() {
                                  selectionMode = true;
                                  selected.add(task.id);
                                }),
                                trailing: IconButton(
                                  tooltip: 'ویرایش',
                                  onPressed: () => _edit(task),
                                  icon: const Icon(Icons.edit),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  const TaskDialog({super.key, this.task});

  final ArvinTask? task;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController tagsController;
  DateTime? followUpDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    tagsController = TextEditingController(
      text: widget.task?.tags.join(', ') ?? '',
    );
    followUpDate = widget.task?.followUpDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: followUpDate ?? DateTime.now(),
    );
    if (date != null) setState(() => followUpDate = date);
  }

  void _save() {
    final title = titleController.text.trim();
    if (title.isEmpty) return;
    final task = widget.task;
    Navigator.of(context).pop(
      ArvinTask(
        id: task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: descriptionController.text.trim(),
        followUpDate: followUpDate,
        tags: tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        archived: task?.archived ?? false,
        trashed: task?.trashed ?? false,
        completed: task?.completed ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'افزودن کار' : 'ویرایش کار'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'عنوان'),
              autofocus: true,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'توضیحات'),
              maxLines: 3,
            ),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'برچسب‌ها',
                hintText: 'مثال: مهم، کاری',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    followUpDate == null
                        ? 'تاریخ پیگیری انتخاب نشده'
                        : 'پیگیری: ${followUpDate!.year}/${followUpDate!.month}/${followUpDate!.day}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('انتخاب تاریخ'),
                ),
                if (followUpDate != null)
                  IconButton(
                    tooltip: 'حذف تاریخ',
                    onPressed: () => setState(() => followUpDate = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('ذخیره'),
        ),
      ],
    );
  }
}
