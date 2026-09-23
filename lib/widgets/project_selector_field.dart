import 'package:flutter/material.dart';

import '../models/goal_project.dart';
import 'arvin_radio_box.dart';

/// Visual selector for first-class Projects.
///
/// Projects deliberately render as bordered cards with their owned color and
/// never as Tag chips, keeping Project and Tag semantics visibly distinct.
/// Archived Projects are not offered for new assignments; an already-selected
/// archived Project remains visible so editing an existing item never silently
/// drops its membership.
class ProjectSelectorField extends StatelessWidget {
  const ProjectSelectorField({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
    this.label = 'پروژه',
    this.onCreateProject,
  });

  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;
  final String label;
  final Future<String?> Function(String title)? onCreateProject;

  @override
  Widget build(BuildContext context) {
    final visibleProjects = projects
        .where(
          (project) =>
              !project.isArchived || project.id == selectedProjectId,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            ArvinRadioBox(
              key: const ValueKey('project-selector-unassigned'),
              label: 'بدون پروژه',
              accent: const Color(0xFF8A8B9C),
              selected: selectedProjectId == null,
              icon: Icons.folder_off_outlined,
              onTap: () => onChanged(null),
            ),
            ...visibleProjects.map(
              (project) => ArvinRadioBox(
                key: ValueKey('project-selector-${project.id}'),
                label: project.isArchived
                    ? '${project.title} (بایگانی‌شده)'
                    : project.title,
                accent: project.isArchived
                    ? const Color(0xFF9E9E9E)
                    : Color(project.colorValue),
                selected: selectedProjectId == project.id,
                icon: Icons.folder_outlined,
                onTap: () => onChanged(project.id),
              ),
            ),
            ArvinRadioBox(
              key: const ValueKey('project-selector-new'),
              label: 'گزینه جدید',
              selected: false,
              newOption: true,
              accent: const Color(0xFF4A4CAB),
              onTap: () async {
                final controller = TextEditingController();
                final title = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('پروژه جدید'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'نام پروژه را وارد کنید'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لغو')),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('ثبت')),
                    ],
                  ),
                );
                controller.dispose();
                if (!context.mounted || title == null || title.isEmpty) return;
                final createProject = onCreateProject;
                if (createProject == null) return;
                final id = await createProject(title);
                if (!context.mounted || id == null) return;
                onChanged(id);
              },
            ),
          ],
        ),
      ],
    );
  }
}

