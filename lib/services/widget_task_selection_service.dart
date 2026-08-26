import '../models/task.dart';
import 'task_migration_reader.dart';

/// Resolves a Widget-selected canonical Task id from Arvin's existing storage.
///
/// This boundary owns no storage and intentionally reloads the Task instead of
/// trusting Android/Widget payload data. Only the canonical Task id crosses the
/// platform bridge.
class WidgetTaskSelectionService {
  WidgetTaskSelectionService({TaskMigrationReader? reader})
      : _reader = reader ?? TaskMigrationReader();

  final TaskMigrationReader _reader;

  Future<Task?> loadTask(String taskId) async {
    final normalized = taskId.trim();
    if (normalized.isEmpty) return null;

    final tasks = await _reader.load();
    for (final task in tasks) {
      if (task.id == normalized && !task.trashed) return task;
    }
    return null;
  }
}
