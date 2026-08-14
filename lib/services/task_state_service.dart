import '../models/task.dart';

/// Centralizes archive/trash transitions so UI layers cannot accidentally
/// create contradictory states.
class TaskStateService {
  const TaskStateService();

  void archive(ArvinTask task) {
    task.archived = true;
    task.trashed = false;
  }

  void restoreFromArchive(ArvinTask task) {
    task.archived = false;
    task.trashed = false;
  }

  void moveToTrash(ArvinTask task) {
    task.trashed = true;
    task.archived = false;
  }

  void restoreFromTrash(ArvinTask task) {
    task.trashed = false;
    task.archived = false;
  }
}
