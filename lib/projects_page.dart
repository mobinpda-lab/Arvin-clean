import 'package:flutter/material.dart';

import 'models/goal_project.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({
    super.key,
    required this.projects,
    required this.onChanged,
  });

  final List<ProjectPlan> projects;
  final ValueChanged<List<ProjectPlan>> onChanged;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  static const _service = ProjectLifecycleService();
  late List<ProjectPlan> _projects;

  @override
  void initState() {
    super.initState();
    _projects = List<ProjectPlan>.of(widget.projects);
  }

  void _commit(List<ProjectPlan> next) {
    setState(() => _projects = List<ProjectPlan>.of(next));
    widget.onChanged(List<ProjectPlan>.unmodifiable(_projects));
  }

  Future<void> _addProject() async {
    final result = await _editDialog();
    if (result == null) return;
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    _commit(_service.add(
      _projects,
      ProjectPlan(id: 'project-$now', title: result.title, colorValue: result.colorValue),
    ));
  }

  Future<void> _editProject(ProjectPlan project) async {
    final result = await _editDialog(project: project);
    if (result == null) return;
    _commit(_service.edit(
      _projects,
      projectId: project.id,
      title: result.title,
      colorValue: result.colorValue,
    ));
  }

  void _deleteProject(ProjectPlan project) {
    if (!project.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پروژه دارای کار است و قابل حذف نیست.')),
      );
      return;
    }
    _commit(_service.delete(_projects, projectId: project.id));
  }

  Future<_ProjectDraft?> _editDialog({ProjectPlan? project}) {
    return showDialog<_ProjectDraft>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: project?.title ?? '');
        var colorValue = project?.colorValue ?? 0xFF4A4CAB;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(project == null ? 'پروژه جدید' : 'ویرایش پروژه'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const ValueKey('project-title-input'),
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'عنوان پروژه'),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    0xFF4A4CAB,
                    0xFF2F80ED,
                    0xFF27AE60,
                    0xFFF2994A,
                    0xFFEB5757,
                    0xFF9B51E0,
                  ].map((value) {
                    final selected = value == colorValue;
                    return InkWell(
                      key: ValueKey('project-color-$value'),
                      onTap: () => setDialogState(() => colorValue = value),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(value),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.black87, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('لغو'),
              ),
              FilledButton(
                key: const ValueKey('project-dialog-save'),
                onPressed: () {
                  final title = controller.text.trim();
                  if (title.isEmpty) return;
                  Navigator.pop(
                    context,
                    _ProjectDraft(title: title, colorValue: colorValue),
                  );
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروژه‌ها')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('projects-add'),
        onPressed: _addProject,
        icon: const Icon(Icons.add),
        label: const Text('پروژه جدید'),
      ),
      body: _projects.isEmpty
          ? const Center(child: Text('هنوز پروژه‌ای ساخته نشده است.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = _projects[index];
                final color = Color(project.colorValue);
                return Card(
                  key: ValueKey('project-card-${project.id}'),
                  color: color.withValues(alpha: 0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    title: Text(project.title),
                    subtitle: Text('${project.itemIds.length} کار'),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          key: ValueKey('project-edit-${project.id}'),
                          tooltip: 'ویرایش',
                          onPressed: () => _editProject(project),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          key: ValueKey('project-delete-${project.id}'),
                          tooltip: project.canDelete
                              ? 'حذف'
                              : 'ابتدا کارهای پروژه را منتقل یا حذف کنید',
                          onPressed: () => _deleteProject(project),
                          icon: Icon(
                            Icons.delete_outline,
                            color: project.canDelete ? null : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ProjectDraft {
  const _ProjectDraft({required this.title, required this.colorValue});
  final String title;
  final int colorValue;
}
