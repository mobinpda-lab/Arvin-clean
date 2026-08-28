import 'package:flutter/material.dart';

import '../models/goal_project.dart';

/// Visual selector for first-class Projects.
///
/// Projects deliberately render as bordered cards with their owned color and
/// never as Tag chips, keeping Project and Tag semantics visibly distinct.
class ProjectSelectorField extends StatelessWidget {
  const ProjectSelectorField({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
    this.label = 'پروژه',
  });

  final List<ProjectPlan> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
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
          spacing: 8,
          runSpacing: 8,
          children: [
            _ProjectOption(
              key: const ValueKey('project-selector-unassigned'),
              title: 'بدون پروژه',
              color: const Color(0xFFB7B7C5),
              selected: selectedProjectId == null,
              onTap: () => onChanged(null),
            ),
            ...projects.map(
              (project) => _ProjectOption(
                key: ValueKey('project-selector-${project.id}'),
                title: project.title,
                color: Color(project.colorValue),
                selected: selectedProjectId == project.id,
                onTap: () => onChanged(project.id),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectOption extends StatelessWidget {
  const _ProjectOption({
    super.key,
    required this.title,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? color : const Color(0xFFE2E2EA);
    final surface = selected ? color.withValues(alpha: 0.12) : Colors.white;

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 46, minWidth: 112),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
