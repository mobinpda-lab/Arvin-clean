import '../models/arvin_center.dart';
import '../models/goal_project.dart';
import '../models/project_template.dart';
import '../models/task.dart';
import 'center_store.dart';
import 'project_store.dart';
import 'project_template_store.dart';
import 'task_store.dart';

class TemplateGenerationResult {
  const TemplateGenerationResult({this.created = const [], this.duplicates = const [], this.failed = const {}});
  final List<String> created;
  final List<String> duplicates;
  final Map<String, String> failed;
}
class TemplatePropagationCandidates {
  const TemplatePropagationCandidates(this.eligible, this.ineligible);
  final List<ProjectPlan> eligible;
  final List<ProjectPlan> ineligible;
}
class TemplatePropagationResult {
  const TemplatePropagationResult({this.applied = const [], this.alreadyPresent = const [], this.ineligible = const [], this.failed = const {}});
  final List<String> applied;
  final List<String> alreadyPresent;
  final List<String> ineligible;
  final Map<String, String> failed;
}

/// Uses the canonical TaskStore + ProjectStore; template definitions are never
/// executable Tasks. Cross-store writes use TaskStore.saveWithProjects' single
/// SQLite transaction.
class ProjectTemplateService {
  ProjectTemplateService({
    ProjectTemplateStore? templateStore,
    CenterStore? centerStore,
    ProjectStore? projectStore,
    TaskStore? taskStore,
    String Function(String prefix)? idFactory,
  }) : templateStore = templateStore ?? ProjectTemplateStore(),
       centerStore = centerStore ?? CenterStore(),
       projectStore = projectStore ?? ProjectStore(),
       taskStore = taskStore ?? TaskStore(),
       _idFactory = idFactory;
  final ProjectTemplateStore templateStore;
  final CenterStore centerStore;
  final ProjectStore projectStore;
  final TaskStore taskStore;
  final String Function(String prefix)? _idFactory;
  int _sequence = 0;
  String _id(String prefix) => _idFactory?.call(prefix) ??
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  Future<TemplateGenerationResult> generateProjects({
    required String templateId,
    required Set<String> centerIds,
  }) async {
    final templates = await templateStore.load();
    ProjectTemplate? template;
    for (final item in templates) { if (item.id == templateId) { template = item; break; } }
    if (template == null || template.isArchived) throw StateError('قالب فعال پیدا نشد.');
    final centers = await centerStore.load(includeArchived: false);
    final created = <String>[], duplicates = <String>[];
    final failed = <String, String>{};
    for (final centerId in centerIds) {
      ArvinCenter? center;
      for (final item in centers) { if (item.id == centerId) { center = item; break; } }
      if (center == null) { failed[centerId] = 'مرکز فعال پیدا نشد.'; continue; }
      final generatedTasks = template.tasks.map(_instantiate).toList(growable: false);
      final project = ProjectPlan(
        id: _id('project'), title: template.name, centerId: centerId,
        templateId: template.id, templateNameSnapshot: template.name,
        itemIds: generatedTasks.map((task) => task.id),
      );
      try {
        await taskStore.createProjectFromTemplate(project, generatedTasks);
        created.add(centerId);
      } catch (error) {
        final current = await projectStore.load();
        if (current.any((p) => p.templateId == template.id && p.centerId == centerId && !p.isArchived)) {
          duplicates.add(centerId);
        } else {
          failed[centerId] = error.toString();
        }
      }
    }
    return TemplateGenerationResult(created: created, duplicates: duplicates, failed: failed);
  }

  Future<TemplatePropagationCandidates> propagationCandidates(String templateId) async {
    final projects = await projectStore.load();
    final tasks = await taskStore.load();
    final byId = <String, Task>{for (final task in tasks) task.id: task};
    final eligible = <ProjectPlan>[], ineligible = <ProjectPlan>[];
    for (final project in projects.where((item) => item.templateId == templateId)) {
      final active = !project.isArchived && project.itemIds
          .map((id) => byId[id])
          .whereType<Task>()
          .any((task) => !task.completed && !task.archived && !task.trashed);
      (active ? eligible : ineligible).add(project);
    }
    return TemplatePropagationCandidates(eligible, ineligible);
  }

  Future<TemplatePropagationResult> propagateTask({
    required String templateId,
    required ProjectTemplateTask templateTask,
    required Set<String> selectedProjectIds,
  }) async {
    ProjectTemplate? template;
    for (final item in await templateStore.load()) { if (item.id == templateId) { template = item; break; } }
    if (template == null || !template.tasks.any((item) => item.id == templateTask.id)) {
      throw StateError('کار انتخاب‌شده متعلق به این قالب نیست.');
    }
    final projects = await projectStore.load();
    final projectIds = projects.where((p) => selectedProjectIds.contains(p.id)).map((p) => p.id).toSet();
    final applied = <String>[], already = <String>[], ineligible = <String>[];
    final failed = <String, String>{};
    for (final projectId in projectIds) {
      try {
        final result = await taskStore.appendTemplateTaskToProject(
          projectId: projectId, templateId: templateId, task: _instantiate(templateTask),
        );
        switch (result) {
          case TemplateTaskAppendResult.appended:
            applied.add(projectId);
            break;
          case TemplateTaskAppendResult.alreadyPresent:
            already.add(projectId);
            break;
          case TemplateTaskAppendResult.ineligible:
            ineligible.add(projectId);
            break;
        }
      } catch (error) { failed[projectId] = error.toString(); }
    }
    return TemplatePropagationResult(applied: applied, alreadyPresent: already, ineligible: ineligible, failed: failed);
  }

  Task _instantiate(ProjectTemplateTask definition) => Task(
    id: _id('task'), title: definition.title, description: definition.description,
    category: definition.category, tags: List<String>.of(definition.tags),
    checklist: List<String>.of(definition.checklist), templateTaskId: definition.id,
  );
}
