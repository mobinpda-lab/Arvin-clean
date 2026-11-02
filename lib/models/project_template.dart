class ProjectTemplateTask {
  const ProjectTemplateTask({
    required this.id,
    required this.title,
    this.description = '',
    this.category,
    this.tags = const [],
    this.checklist = const [],
  });
  final String id;
  final String title;
  final String description;
  final String? category;
  final List<String> tags;
  final List<String> checklist;
}
class ProjectTemplate {
  ProjectTemplate({
    required this.id,
    required this.name,
    required Iterable<ProjectTemplateTask> tasks,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  }) : tasks = List.unmodifiable(tasks);
  final String id;
  final String name;
  final List<ProjectTemplateTask> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  ProjectTemplate copyWith({String? name, Iterable<ProjectTemplateTask>? tasks, bool? isArchived, DateTime? updatedAt}) => ProjectTemplate(
    id: id, name: name ?? this.name, tasks: tasks ?? this.tasks, createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt, isArchived: isArchived ?? this.isArchived,
  );
}
class ProjectTemplateDeleteBlocked implements Exception {
  const ProjectTemplateDeleteBlocked(this.templateId, this.projectCount);
  final String templateId;
  final int projectCount;
}
