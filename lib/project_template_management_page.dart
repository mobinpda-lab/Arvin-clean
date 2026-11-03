import 'package:flutter/material.dart';
import 'models/arvin_center.dart';
import 'models/project_template.dart';
import 'models/goal_project.dart';
import 'services/center_store.dart';
import 'services/project_template_service.dart';

class ProjectTemplateManagementPage extends StatefulWidget {
  const ProjectTemplateManagementPage({super.key, this.service});
  final ProjectTemplateService? service;
  @override State<ProjectTemplateManagementPage> createState() => _ProjectTemplateManagementPageState();
}
class _ProjectTemplateManagementPageState extends State<ProjectTemplateManagementPage> {
  late final ProjectTemplateService _service = widget.service ?? ProjectTemplateService();
  final CenterStore _centersStore = CenterStore();
  List<ProjectTemplate> _templates = const [];
  List<ArvinCenter> _centers = const [];
  List<ProjectPlan> _projects = const [];
  bool _loading = true, _busy = false;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final values = await Future.wait<Object>([_service.templateStore.load(), _centersStore.load(includeArchived: true), _service.projectStore.load()]);
      if (!mounted) return;
      setState(() { _templates = values[0] as List<ProjectTemplate>; _centers = values[1] as List<ArvinCenter>; _projects = values[2] as List<ProjectPlan>; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خواندن قالب‌ها انجام نشد: $error')));
    }
  }
  Future<String?> _askName({String initial = '', String title = 'نام قالب'}) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'نام قالب پروژه')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')), FilledButton(onPressed: () { final name = controller.text.trim(); if (name.isNotEmpty) Navigator.pop(ctx, name); }, child: const Text('ذخیره'))],
    ));
    controller.dispose(); return value;
  }
  Future<void> _createTemplate() async {
    final name = await _askName(title: 'قالب جدید'); if (name == null) return;
    final now = DateTime.now();
    await _saveTemplate(ProjectTemplate(id: 'template-${now.microsecondsSinceEpoch}', name: name, tasks: const [], createdAt: now, updatedAt: now));
  }
  Future<void> _renameTemplate(ProjectTemplate template) async {
    final name = await _askName(initial: template.name, title: 'ویرایش نام قالب'); if (name == null) return;
    await _saveTemplate(template.copyWith(name: name, updatedAt: DateTime.now()));
  }
  Future<void> _saveTemplate(ProjectTemplate template) async {
    setState(() => _busy = true);
    try { await _service.templateStore.save(template); await _load(); }
    catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ذخیره قالب انجام نشد: $error'))); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  Future<ProjectTemplateTask?> _taskDialog({ProjectTemplateTask? existing}) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final description = TextEditingController(text: existing?.description ?? '');
    final category = TextEditingController(text: existing?.category ?? '');
    final tags = TextEditingController(text: existing?.tags.join(', ') ?? '');
    final checklist = TextEditingController(text: existing?.checklist.join('\n') ?? '');
    final result = await showDialog<ProjectTemplateTask>(context: context, builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'کار جدید در قالب' : 'ویرایش کار قالب'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان کار')),
        TextField(controller: description, decoration: const InputDecoration(labelText: 'توضیحات')),
        TextField(controller: category, decoration: const InputDecoration(labelText: 'دسته (اختیاری)')),
        TextField(controller: tags, decoration: const InputDecoration(labelText: 'برچسب‌ها (با ویرگول جدا شوند)')),
        TextField(controller: checklist, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'چک‌لیست (هر مورد در یک خط)')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
        FilledButton(onPressed: () { if (title.text.trim().isEmpty) return; Navigator.pop(ctx, ProjectTemplateTask(
          id: existing?.id ?? 'template-task-${DateTime.now().microsecondsSinceEpoch}',
          title: title.text.trim(), description: description.text.trim(),
          category: category.text.trim().isEmpty ? null : category.text.trim(),
          tags: tags.text.split(',').map((value) => value.trim()).where((value) => value.isNotEmpty).toSet().toList(),
          checklist: checklist.text.split('\n').map((value) => value.trim()).where((value) => value.isNotEmpty).toList(),
        )); }, child: const Text('ذخیره کار')),
      ],
    ));
    title.dispose(); description.dispose(); category.dispose(); tags.dispose(); checklist.dispose(); return result;
  }
  Future<void> _addTask(ProjectTemplate template, {ProjectTemplateTask? existing}) async {
    final definition = await _taskDialog(existing: existing); if (definition == null) return;
    final tasks = [...template.tasks];
    if (existing == null) {
      tasks.add(definition);
    } else {
      final index = tasks.indexWhere((item) => item.id == existing.id);
      if (index >= 0) tasks[index] = definition;
    }
    final updated = template.copyWith(tasks: tasks, updatedAt: DateTime.now());
    await _saveTemplate(updated);
    if (existing == null) await _offerPropagation(updated, definition);
  }
  Future<void> _offerPropagation(ProjectTemplate template, ProjectTemplateTask definition) async {
    final candidates = await _service.propagationCandidates(template.id);
    if (!mounted || candidates.eligible.isEmpty) return;
    final selected = <String>{};
    final result = await showDialog<Set<String>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: const Text('افزودن کار به پروژه‌های فعال؟'),
      content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('کار «${definition.title}» فقط به مقصدهای انتخاب‌شده اضافه می‌شود. کارهای قبلی تغییر نمی‌کنند.'),
        const SizedBox(height: 8),
        for (final project in candidates.eligible)
          CheckboxListTile(value: selected.contains(project.id), title: Text(project.title), subtitle: Text(_centerName(project.centerId)),
            onChanged: (value) => setDialogState(() { value == true ? selected.add(project.id) : selected.remove(project.id); })),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, <String>{}), child: const Text('فعلاً نه')),
        FilledButton(onPressed: selected.isEmpty ? null : () => Navigator.pop(ctx, Set<String>.of(selected)), child: const Text('افزودن به انتخاب‌شده‌ها')),
      ],
    )));
    if (result == null || result.isEmpty) return;
    setState(() => _busy = true);
    try {
      final outcome = await _service.propagateTask(templateId: template.id, templateTask: definition, selectedProjectIds: result);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('افزوده‌شده: ${outcome.applied.length} • تکراری: ${outcome.alreadyPresent.length} • نامجاز: ${outcome.ineligible.length} • ناموفق: ${outcome.failed.length}')));
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('انتشار کار انجام نشد: $error'))); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _generate(ProjectTemplate template) async {
    final selected = <String>{};
    final result = await showDialog<Set<String>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: Text('تولید پروژه از «${template.name}»'),
      content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('برای هر مرکز انتخاب‌شده یک پروژه مستقل ساخته می‌شود. پروژه فعال تکراری تولید نمی‌شود.'),
        for (final center in _centers)
          CheckboxListTile(value: selected.contains(center.id), title: Text(center.name), onChanged: (value) => setDialogState(() { value == true ? selected.add(center.id) : selected.remove(center.id); })),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')), FilledButton(onPressed: selected.isEmpty ? null : () => Navigator.pop(ctx, Set<String>.of(selected)), child: const Text('تأیید و تولید'))],
    )));
    if (result == null || result.isEmpty) return;
    setState(() => _busy = true);
    try {
      final outcome = await _service.generateProjects(templateId: template.id, centerIds: result);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ایجاد: ${outcome.created.length} • تکراری: ${outcome.duplicates.length} • ناموفق: ${outcome.failed.length}')));
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تولید پروژه انجام نشد: $error'))); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  String _centerName(String? id) {
    if (id == null) return 'بدون مرکز';
    for (final center in _centers) { if (center.id == id) return center.name; }
    return 'مرکز حذف‌شده';
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('قالب پروژه‌ها')),
    floatingActionButton: FloatingActionButton.extended(key: const ValueKey('template-add'), onPressed: _busy ? null : _createTemplate, icon: const Icon(Icons.add), label: const Text('قالب جدید')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _templates.isEmpty ? const Center(child: Text('هنوز قالبی ثبت نشده است.'))
      : ListView.separated(padding: const EdgeInsets.all(16), itemCount: _templates.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (ctx, i) {
        final template = _templates[i];
        final generated = _projects.where((p) => p.templateId == template.id).length;
        return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text(template.name, style: Theme.of(context).textTheme.titleMedium)), IconButton(tooltip: 'ویرایش نام قالب', onPressed: _busy ? null : () => _renameTemplate(template), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: template.isArchived ? 'فعال‌سازی' : 'بایگانی', onPressed: _busy ? null : () async { await _service.templateStore.setArchived(id: template.id, archived: !template.isArchived); await _load(); }, icon: Icon(template.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined))]),
          Text('${template.tasks.length} کار پایه • $generated پروژه تولیدشده'),
          for (final task in template.tasks) ListTile(dense: true, title: Text(task.title), subtitle: task.category == null ? null : Text('دسته: ${task.category}'), onTap: _busy ? null : () => _addTask(template, existing: task)),
          Row(children: [
            TextButton.icon(key: ValueKey('template-add-task-${template.id}'), onPressed: _busy || template.isArchived ? null : () => _addTask(template), icon: const Icon(Icons.add_task), label: const Text('افزودن کار')),
            const Spacer(),
            FilledButton.tonalIcon(key: ValueKey('template-generate-${template.id}'), onPressed: _busy || template.isArchived ? null : () => _generate(template), icon: const Icon(Icons.playlist_add), label: const Text('تولید پروژه')),
          ]),
        ])));
      }),
  );
}
