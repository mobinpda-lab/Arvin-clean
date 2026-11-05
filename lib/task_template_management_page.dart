import 'package:flutter/material.dart';

import 'models/task.dart';
import 'android_follow_up_reminder_scheduler.dart';
import 'models/task_template.dart';
import 'models/goal_project.dart';
import 'models/arvin_center.dart';
import 'services/task_store.dart';
import 'services/task_template_store.dart';
import 'services/project_store.dart';
import 'services/center_store.dart';
import 'widgets/persian_date_picker.dart';
import 'project_template_management_page.dart';

class TaskTemplateManagementPage extends StatefulWidget {
  const TaskTemplateManagementPage({
    super.key,
    this.taskStore,
    this.templateStore,
    this.projectStore,
    this.centerStore,
    this.embedded = false,
  });

  final TaskStore? taskStore;
  final TaskTemplateStore? templateStore;
  final ProjectStore? projectStore;
  final CenterStore? centerStore;
  final bool embedded;

  @override
  State<TaskTemplateManagementPage> createState() =>
      _TaskTemplateManagementPageState();
}

class _TaskTemplateManagementPageState extends State<TaskTemplateManagementPage> {
  late final TaskStore _tasks = widget.taskStore ?? TaskStore();
  late final TaskTemplateStore _templates =
      widget.templateStore ?? TaskTemplateStore();
  late final ProjectStore _projectsStore = widget.projectStore ?? ProjectStore();
  late final CenterStore _centersStore = widget.centerStore ?? CenterStore();
  List<Task> _sourceTasks = const [];
  List<TaskTemplate> _savedTemplates = const [];
  List<ProjectPlan> _projects = const [];
  List<ArvinCenter> _centers = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // These stores may share the same Drift executor. Keep schema
      // installation and reads sequential to avoid nested BEGIN transactions.
      final tasks = await _tasks.load();
      final templates = await _templates.load();
      final projects = await _projectsStore.load();
      final centers = await _centersStore.load();
      if (!mounted) return;
      setState(() {
        _sourceTasks = tasks;
        _savedTemplates = templates;
        _projects = projects;
        _centers = centers;
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
      final relatedProjects = _projects.where((project) => project.itemIds.contains(task.id)).toList();
      final projectSnapshot = relatedProjects.isEmpty
          ? null
          : relatedProjects.map((project) => project.title).toSet().join('، ');
      final centerIds = relatedProjects.map((project) => project.centerId)
          .whereType<String>().toSet();
      final centerSnapshot = _centers
          .where((center) => centerIds.contains(center.id))
          .map((center) => center.name)
          .toSet()
          .join('، ');
      await _templates.createFromTask(
        task: task,
        name: name,
        centerNameSnapshot: centerSnapshot.isEmpty ? null : centerSnapshot,
        projectNameSnapshot: projectSnapshot,
        centerIdSnapshot: centerIds.length == 1 ? centerIds.single : null,
        projectIdSnapshot: relatedProjects.length == 1 ? relatedProjects.single.id : null,
      );
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

  Future<void> _createTaskFromTemplate(TaskTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ساخت کار از الگو'),
        content: Text('یک کار تازه با مشخصات «${template.name}» ساخته شود؟ الگو و کارهای قبلی تغییر نمی‌کنند.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton(
            key: ValueKey('task-template-create-confirm-${template.id}'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ساخت کار'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    DateTime? reminderDate;
    if (template.reminders.isNotEmpty) {
      reminderDate = await showPersianDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        helpText: 'انتخاب تاریخ یادآورهای الگو',
      );
      if (reminderDate == null || !mounted) return;
    }

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final reminders = template.reminders.map((reminder) => TaskReminder(
        id: 'reminder-${now.microsecondsSinceEpoch}-${reminder.sequence}',
        title: reminder.title,
        date: DateTime(
          reminderDate!.year,
          reminderDate.month,
          reminderDate.day,
          reminder.hour,
          reminder.minute,
        ),
        isAllDay: reminder.isAllDay,
        sequence: reminder.sequence,
        isEnabled: reminder.isEnabled,
      )).toList(growable: false);
      final task = Task(
        id: 'task-${now.microsecondsSinceEpoch}',
        title: template.title,
        description: template.description,
        category: template.category,
        priority: template.priority,
        tags: List<String>.of(template.tags),
        checklistEnabled: template.checklistEnabled || template.checklist.isNotEmpty,
        checklist: template.checklist.map((item) => '[ ] $item').toList(growable: false),
        people: List.of(template.people),
        taskReminders: reminders,
        nextReminderSequence: reminders.isEmpty
            ? 1
            : reminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b) + 1,
        recurrence: template.recurrence,
      );
      await _tasks.mutate<void>((items) => items.add(task));
      try {
        await AndroidFollowUpReminderScheduler().reschedule();
      } catch (_) {
        // The Task is already persisted. Scheduling is retried by the app's
        // normal alarm reconciliation path; never roll back the saved Task.
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('کار «${task.title}» از الگو ساخته شد.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ساخت کار از الگو انجام نشد: $error')),
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
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              key: ValueKey('task-template-create-${template.id}'),
                              tooltip: 'ساخت کار از الگو',
                              onPressed: _busy || template.isArchived
                                  ? null
                                  : () => _createTaskFromTemplate(template),
                              icon: const Icon(Icons.add_task),
                            ),
                            IconButton(
                              tooltip: template.isArchived ? 'فعال‌سازی' : 'بایگانی',
                              onPressed: _busy ? null : () => _archive(template),
                              icon: Icon(template.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                            ),
                          ],
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
