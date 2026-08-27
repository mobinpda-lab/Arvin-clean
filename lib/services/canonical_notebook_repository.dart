import '../models/task.dart';
import 'task_store.dart';

/// Notebook persistence boundary backed only by the canonical `arvin.tasks`
/// store. It deliberately owns no key/database/model of its own.
class CanonicalNotebookRepository {
  CanonicalNotebookRepository({
    TaskStore? store,
    DateTime Function()? now,
  })  : _store = store ?? TaskStore(),
        _now = now ?? DateTime.now;

  final TaskStore _store;
  final DateTime Function() _now;

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
  }) async {
    final tasks = await _store.load();
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
    await _store.save(tasks);
    return note;
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String description,
    required List<String> checklist,
  }) async {
    final tasks = await _store.load();
    final index = tasks.indexWhere((task) => task.id == id);
    if (index < 0) throw StateError('Notebook task not found: $id');

    final task = tasks[index];
    task.title = title.trim().isEmpty ? 'بدون عنوان' : title.trim();
    task.description = description;
    task.checklist = List<String>.of(checklist);
    task.updatedAt = _now();
    await _store.save(tasks);
  }

  /// Reassigns the same canonical Task to a category immediately.
  /// Passing null/blank removes the category. No copy is created.
  Future<Task> updateCategory({
    required String id,
    String? category,
  }) async {
    final tasks = await _store.load();
    final index = tasks.indexWhere((task) => task.id == id);
    if (index < 0) throw StateError('Notebook task not found: $id');

    final task = tasks[index];
    final normalized = category?.trim();
    task.category = normalized == null || normalized.isEmpty ? null : normalized;
    task.updatedAt = _now();
    await _store.save(tasks);
    return task;
  }
}
