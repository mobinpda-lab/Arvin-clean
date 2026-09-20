import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_migration_adapter.dart';

/// Read-only migration boundary for the existing Home storage.
///
/// This slice deliberately performs no writes and does not change HomePage.
/// It lets the next migration step prove that `arvin.tasks` can be decoded
/// into the canonical `Task` model before production wiring is changed.
class TaskMigrationReader {
  TaskMigrationReader({TaskMigrationAdapter? adapter})
      : adapter = adapter ?? const TaskMigrationAdapter();

  final TaskMigrationAdapter adapter;

  static const String legacyKey = 'arvin.tasks';

  Future<List<Task>> load() async {
    // Refresh the legacy SharedPreferences cache before reading so a separate
    // Flutter engine cannot expose an older canonical task document.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(legacyKey);
    return loadFromRaw(raw);
  }

  List<Task> loadFrom(SharedPreferences prefs) {
    return loadFromRaw(prefs.getString(legacyKey));
  }

  List<Task> loadFromRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <Task>[];
    return List<Task>.of(adapter.decodeLegacyList(raw));
  }
}
