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
    this.centerId,
    this.colorValue = 0xFF4A4CAB,
  }) : tasks = List.unmodifiable(tasks);
  final String id;
  final String name;
  final List<ProjectTemplateTask> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final String? centerId;
  final int colorValue;
  ProjectTemplate copyWith({String? name, Iterable<ProjectTemplateTask>? tasks, bool? isArchived, DateTime? updatedAt, String? centerId, bool clearCenterId = false, int? colorValue}) => ProjectTemplate(
    id: id, name: name ?? this.name, tasks: tasks ?? this.tasks, createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt, isArchived: isArchived ?? this.isArchived,
    centerId: clearCenterId ? null : centerId ?? this.centerId, colorValue: colorValue ?? this.colorValue,
  );
}
class ProjectTemplateDeleteBlocked implements Exception {
  const ProjectTemplateDeleteBlocked(this.templateId, this.projectCount);
  final String templateId;
  final int projectCount;
}
