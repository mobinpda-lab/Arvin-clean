import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'models/task.dart';
import 'services/project_template_service.dart';
import 'services/task_store.dart';

/// Read-only detail surface for a canonical Project, with a real conversion
/// action that writes through the existing Project Template store.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({
    super.key,
    required this.project,
    this.centerName,
    this.taskStore,
    this.templateService,
  });

  final ProjectPlan project;
  final String? centerName;
  final TaskStore? taskStore;
  final ProjectTemplateService? templateService;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late final TaskStore _tasks = widget.taskStore ?? TaskStore();
  late final ProjectTemplateService _templates =
      widget.templateService ?? ProjectTemplateService();
  List<Task> _projectTasks = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final all = await _tasks.load();
      if (!mounted) return;
      final byId = <String, Task>{for (final task in all) task.id: task};
      setState(() {
        _projectTasks = widget.project.itemIds
            .map((id) => byId[id])
            .whereType<Task>()
            .toList(growable: false);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خواندن کارهای پروژه انجام نشد: $error')),
      );
    }
  }

  Future<void> _convertToTemplate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تبدیل پروژه به الگو'),
        content: Text(
          'از پروژه «${widget.project.title}» و کارهای پایه آن یک الگوی مستقل ساخته شود؟ داده‌های پروژه و کارهای اصلی تغییر نمی‌کنند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const ValueKey('project-detail-template-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأیید و تبدیل'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final template = await _templates.createFromProject(project: widget.project);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الگوی «${template.name}» ذخیره شد؛ پروژه اصلی بدون تغییر ماند.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تبدیل پروژه انجام نشد: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('مشخصات پروژه')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(widget.project.title),
                subtitle: Text(widget.centerName ?? 'بدون مرکز'),
                leading: Icon(Icons.folder_outlined, color: Color(widget.project.colorValue)),
              ),
            ),
            const SizedBox(height: 12),
            Text('کارهای پروژه', style: Theme.of(context).textTheme.titleMedium),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (!_loading && _projectTasks.isEmpty)
              const ListTile(title: Text('این پروژه هنوز کاری ندارد.')),
            for (final task in _projectTasks)
              ListTile(
                key: ValueKey('project-detail-task-${task.id}'),
                leading: const Icon(Icons.task_alt_outlined),
                title: Text(task.title),
                subtitle: Text(task.category ?? 'بدون دسته'),
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('project-detail-convert-template'),
              onPressed: _busy || _loading
                  ? null
                  : _convertToTemplate,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('تبدیل پروژه به الگو'),
            ),
          ],
        ),
      );
}
