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
    final template = templates.where((item) => item.id == templateId).firstOrNull;
    if (template == null || template.isArchived) throw StateError('قالب فعال پیدا نشد.');
    final centers = await centerStore.load(includeArchived: false);
    var projects = await projectStore.load();
    var tasks = await taskStore.load();
    final created = <String>[], duplicates = <String>[];
    final failed = <String, String>{};
    for (final centerId in centerIds) {
      final center = centers.where((item) => item.id == centerId).firstOrNull;
      if (center == null) { failed[centerId] = 'مرکز فعال پیدا نشد.'; continue; }
      if (projects.any((p) => p.templateId == template.id && p.centerId == centerId && !p.isArchived)) {
        duplicates.add(centerId); continue;
      }
      final generatedTasks = template.tasks.map(_instantiate).toList(growable: false);
      final project = ProjectPlan(
        id: _id('project'), title: template.name, centerId: centerId,
        templateId: template.id, templateNameSnapshot: template.name,
        itemIds: generatedTasks.map((task) => task.id),
      );
      final nextTasks = [...tasks, ...generatedTasks];
      final nextProjects = [...projects, project];
      try {
        await taskStore.saveWithProjects(nextTasks, nextProjects);
        tasks = nextTasks; projects = nextProjects; created.add(centerId);
      } catch (error) { failed[centerId] = error.toString(); }
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
    final template = (await templateStore.load()).where((item) => item.id == templateId).firstOrNull;
    if (template == null || !template.tasks.any((item) => item.id == templateTask.id)) {
      throw StateError('کار انتخاب‌شده متعلق به این قالب نیست.');
    }
    var projects = await projectStore.load();
    var tasks = await taskStore.load();
    final byId = <String, Task>{for (final task in tasks) task.id: task};
    final applied = <String>[], already = <String>[], ineligible = <String>[];
    final failed = <String, String>{};
    for (final projectId in selectedProjectIds) {
      final index = projects.indexWhere((item) => item.id == projectId);
      if (index < 0 || projects[index].templateId != templateId || projects[index].isArchived ||
          !projects[index].itemIds.map((id) => byId[id]).whereType<Task>().any((task) => !task.completed && !task.archived && !task.trashed)) {
        ineligible.add(projectId); continue;
      }
      final project = projects[index];
      if (project.itemIds.map((id) => byId[id]).whereType<Task>().any((task) => task.templateTaskId == templateTask.id)) {
        already.add(projectId); continue;
      }
      final task = _instantiate(templateTask);
      final updatedProject = project.copyWith(itemIds: [...project.itemIds, task.id]);
      final nextProjects = [...projects]..[index] = updatedProject;
      final nextTasks = [...tasks, task];
      try {
        await taskStore.saveWithProjects(nextTasks, nextProjects);
        tasks = nextTasks; projects = nextProjects; byId[task.id] = task; applied.add(projectId);
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
