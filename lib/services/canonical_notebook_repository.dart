import '../models/goal_project.dart';
import '../models/task.dart';
import 'task_bulk_mutation_service.dart';
import 'task_project_assignment_service.dart';
import 'task_store.dart';

/// Notebook persistence boundary backed only by the canonical `arvin.tasks`
/// store. It deliberately owns no key/database/model of its own.
///
/// Project membership is also delegated to the existing canonical
/// [TaskProjectAssignmentService], where membership remains owned by
/// `ProjectPlan.itemIds`. Notebook never writes a parallel `projectId` field.
class CanonicalNotebookRepository {
  CanonicalNotebookRepository({
    TaskStore? store,
    TaskProjectAssignmentService? projectAssignmentService,
    DateTime Function()? now,
  })  : _store = store ?? TaskStore(),
        _projectAssignmentService =
            projectAssignmentService ?? TaskProjectAssignmentService(),
        _now = now ?? DateTime.now;

  final TaskStore _store;
  final TaskProjectAssignmentService _projectAssignmentService;
  final DateTime Function() _now;

  TaskBulkMutationService get _bulk => TaskBulkMutationService(now: _now);

  Future<List<Task>> loadNotes() async {
    final tasks = await _store.load();
    final notes = tasks
        .where((task) => task.isSimpleNote && !task.trashed && !task.archived)
        .toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        if (aTime == null && bTime == null) return a.id.compareTo(b.id);
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
    return notes;
  }

  Future<List<String>> loadCategories() async {
    final notes = await loadNotes();
    final values = notes
        .map((note) => note.category?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  Future<Task?> loadNote(String id) async {
    final tasks = await _store.load();
    for (final task in tasks) {
      if (task.id == id && task.isSimpleNote) return task;
    }
    return null;
  }

  Future<Task> createNote({
    String? id,
    String title = 'یادداشت جدید',
    List<String> checklist = const [],
    String? category,
  }) {
    return _store.mutate<Task>((tasks) {
      final createdAt = _now();
      final normalizedCategory = category?.trim();
      final note = Task(
        id: id ?? 'note-${createdAt.microsecondsSinceEpoch}',
        title: title.trim().isEmpty ? 'یادداشت جدید' : title.trim(),
        checklist: List<String>.of(checklist),
        category: normalizedCategory == null || normalizedCategory.isEmpty
            ? null
            : normalizedCategory,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      tasks.add(note);
      return note;
    });
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String description,
    required List<String> checklist,
  }) {
    return _store.mutate<void>((tasks) {
      final index = tasks.indexWhere((task) => task.id == id);
      if (index < 0) throw StateError('Notebook task not found: $id');

      final task = tasks[index];
      task.title = title.trim().isEmpty ? 'بدون عنوان' : title.trim();
      task.description = description;
      task.checklist = List<String>.of(checklist);
      task.updatedAt = _now();
    });
  }

  /// Reassigns the same canonical Task to a category immediately.
  /// Passing null/blank removes the category. No copy is created.
  Future<Task> updateCategory({
    required String id,
    String? category,
  }) {
    return _store.mutate<Task>((tasks) {
      final index = tasks.indexWhere((task) => task.id == id);
      if (index < 0) throw StateError('Notebook task not found: $id');

      final task = tasks[index];
      final normalized = category?.trim();
      task.category =
          normalized == null || normalized.isEmpty ? null : normalized;
      task.updatedAt = _now();
      return task;
    });
  }

  /// Loads the existing first-class Project collection without creating any
  /// Notebook-owned Project state.
  Future<List<ProjectPlan>> loadProjects() =>
      _projectAssignmentService.loadProjects();

  /// Resolves Project membership for the same canonical Note/Checklist id.
  /// If the item is no longer a Notebook item, fail closed rather than keeping
  /// or fabricating an orphan membership.
  Future<String?> projectIdForNote(String id) async {
    final note = await loadNote(id);
    if (note == null) throw StateError('Notebook task not found: $id');
    return _projectAssignmentService.projectIdForTask(id);
  }

  /// Assigns/reassigns/unassigns the same canonical Note/Checklist id using
  /// `ProjectPlan.itemIds` through the existing ProjectStore path.
  Future<void> updateProject({
    required String id,
    required String? projectId,
  }) async {
    final note = await loadNote(id);
    if (note == null) throw StateError('Notebook task not found: $id');
    await _projectAssignmentService.assign(taskId: id, projectId: projectId);
  }

  Future<int> moveSelectedToTrash(Iterable<String> ids) {
    return _store.mutate<int>((tasks) => _bulk.moveToTrash(tasks, ids));
  }

  Future<int> moveSelectedToCategory(
    Iterable<String> ids,
    String? category,
  ) {
    return _store.mutate<int>(
      (tasks) => _bulk.moveToCategory(tasks, ids, category),
    );
  }

  Future<int> addTagsToSelected(
    Iterable<String> ids,
    Iterable<String> tags,
  ) {
    return _store.mutate<int>((tasks) => _bulk.addTags(tasks, ids, tags));
  }
}
