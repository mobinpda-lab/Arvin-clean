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
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const Directionality(textDirection: TextDirection.rtl, child: HomePage()),
      );
}

class ArvinTask {
  ArvinTask({required this.id, required this.title, this.description = '', this.followUpDate});

  final String id;
  String title;
  String description;
  DateTime? followUpDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'followUpDate': followUpDate?.toIso8601String(),
      };

  factory ArvinTask.fromJson(Map<String, dynamic> json) => ArvinTask(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        followUpDate: json['followUpDate'] == null ? null : DateTime.tryParse(json['followUpDate'] as String),
      );
}

class TaskRepository {
  static const _key = 'arvin.tasks';

  Future<List<ArvinTask>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => ArvinTask.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ArvinTask> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(tasks.map((task) => task.toJson()).toList()));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = TaskRepository();
  List<ArvinTask> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _repository.load();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _addTask() async {
    final task = await showDialog<ArvinTask>(context: context, builder: (_) => const AddTaskDialog());
    if (task == null) return;
    setState(() => _tasks = [..._tasks, task]);
    await _repository.save(_tasks);
  }

  Future<void> _deleteTask(ArvinTask task) async {
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
    await _repository.save(_tasks);
  }

  String _formatDate(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('مدیریت کارها وپیگیری آروین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? const _EmptyTasksView()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          await _deleteTask(task);
                          return true;
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(task.description),
                                ],
                                if (task.followUpDate != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.event_outlined, size: 16),
                                      const SizedBox(width: 5),
                                      Text(_formatDate(task.followUpDate!)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton.extended(onPressed: _addTask, icon: const Icon(Icons.add), label: const Text('کار جدید')),
      );
}

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('هنوز کاری ثبت نشده است', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('برای شروع، روی «کار جدید» بزنید.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});
  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _followUpDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ پیگیری',
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(
      ArvinTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: _descriptionController.text.trim(),
        followUpDate: _followUpDate,
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('کار جدید'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'عنوان کار'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'توضیحات'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(_followUpDate == null ? 'تاریخ پیگیری انتخاب نشده' : 'تاریخ پیگیری: ${_formatDate(_followUpDate!)}'),
                trailing: TextButton(onPressed: _pickDate, child: const Text('انتخاب')),
              ),
              if (_followUpDate != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _followUpDate = null),
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('حذف تاریخ'),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('لغو')),
          FilledButton(onPressed: _titleController.text.trim().isEmpty ? null : _submit, child: const Text('ذخیره')),
        ],
      );
}
