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
    final prefs = await SharedPreferences.getInstance();
    return loadFrom(prefs);
  }

  List<Task> loadFrom(SharedPreferences prefs) {
    final raw = prefs.getString(legacyKey);
    if (raw == null || raw.trim().isEmpty) return const [];
    return adapter.decodeLegacyList(raw);
  }
}
