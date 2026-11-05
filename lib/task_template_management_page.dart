import 'package:flutter/material.dart';

import 'models/task.dart';
import 'models/task_template.dart';
import 'services/task_store.dart';
import 'services/task_template_store.dart';
import 'project_template_management_page.dart';

class TaskTemplateManagementPage extends StatefulWidget {
  const TaskTemplateManagementPage({
    super.key,
    this.taskStore,
    this.templateStore,
    this.embedded = false,
  });

  final TaskStore? taskStore;
  final TaskTemplateStore? templateStore;
  final bool embedded;

  @override
  State<TaskTemplateManagementPage> createState() =>
      _TaskTemplateManagementPageState();
}

class _TaskTemplateManagementPageState extends State<TaskTemplateManagementPage> {
  late final TaskStore _tasks = widget.taskStore ?? TaskStore();
  late final TaskTemplateStore _templates =
      widget.templateStore ?? TaskTemplateStore();
  List<Task> _sourceTasks = const [];
  List<TaskTemplate> _savedTemplates = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait<Object>([
        _tasks.load(),
        _templates.load(),
      ]);
      if (!mounted) return;
      setState(() {
        _sourceTasks = values[0] as List<Task>;
        _savedTemplates = values[1] as List<TaskTemplate>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خواندن کارها و الگوها انجام نشد: $error')),
      );
    }
  }

  Future<String?> _askName(Task task) async {
    final controller = TextEditingController(text: task.title);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تبدیل کار به الگو'),
        content: TextField(
          key: const ValueKey('task-template-name-input'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'نام الگو'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('ادامه'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _convert(Task task) async {
    final name = await _askName(task);
    if (name == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأیید ساخت الگو'),
        content: Text(
          'از مشخصات پایدار «${task.title}» یک الگوی مستقل با نام «$name» ساخته شود؟ کار اصلی و تاریخچه آن تغییر نمی‌کند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('بازگشت'),
          ),
          FilledButton(
            key: const ValueKey('task-template-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تبدیل به الگو'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _templates.createFromTask(task: task, name: name);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الگوی کار ذخیره شد؛ کار اصلی بدون تغییر ماند.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ساخت الگوی کار انجام نشد: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _archive(TaskTemplate template) async {
    setState(() => _busy = true);
    try {
      await _templates.setArchived(id: template.id, archived: !template.isArchived);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(template.isArchived ? 'الگو فعال شد.' : 'الگو بایگانی شد.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تغییر وضعیت الگو انجام نشد: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: const Text('الگوهای کار')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                key: const ValueKey('task-template-management-list'),
                padding: const EdgeInsets.all(16),
                children: [
                  Text('الگوهای ذخیره‌شده', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_savedTemplates.isEmpty)
                    const ListTile(
                      key: ValueKey('task-template-empty'),
                      title: Text('هنوز الگویی برای کارها ثبت نشده است.'),
                    ),
                  for (final template in _savedTemplates)
                    Card(
                      key: ValueKey('task-template-${template.id}'),
                      child: ListTile(
                        title: Text(template.name),
                        subtitle: Text(
                          '${template.title} • ${template.checklist.length} مرحله • ${template.tags.length} برچسب${template.isArchived ? ' • بایگانی‌شده' : ''}',
                        ),
                        trailing: IconButton(
                          tooltip: template.isArchived ? 'فعال‌سازی' : 'بایگانی',
                          onPressed: _busy ? null : () => _archive(template),
                          icon: Icon(template.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                        ),
                      ),
                    ),
                  const Divider(height: 32),
                  Text('انتخاب کار موجود', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text('با انتخاب یک کار، از اطلاعات پایدار آن الگو ساخته می‌شود؛ تاریخ‌ها و سابقه اجرا منتقل نمی‌شوند.'),
                  const SizedBox(height: 8),
                  for (final task in _sourceTasks.where((item) => !item.trashed && !item.archived))
                    Card(
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.category ?? 'بدون دسته'),
                        trailing: IconButton(
                          key: ValueKey('task-template-convert-${task.id}'),
                          tooltip: 'تبدیل به الگو',
                          onPressed: _busy ? null : () => _convert(task),
                          icon: const Icon(Icons.bookmark_add_outlined),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class TemplatesSettingsPage extends StatelessWidget {
  const TemplatesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('الگوها'),
            bottom: const TabBar(
              tabs: [
                Tab(key: ValueKey('task-templates-tab'), text: 'الگوهای کار'),
                Tab(key: ValueKey('project-templates-tab'), text: 'الگوهای پروژه'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              TaskTemplateManagementPage(embedded: true),
              ProjectTemplateManagementPage(embedded: true),
            ],
          ),
        ),
      );
}
