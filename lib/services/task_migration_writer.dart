import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_migration_adapter.dart';
import 'task_migration_reader.dart';

/// Lossless, single-key write boundary for the transitional Home UI.
///
/// Home still edits a limited projection of the canonical [Task]. Before
/// writing that projection, this boundary merges its editable fields into the
/// existing JSON object so reminder, recurrence, checklist, follow-up history,
/// and future canonical fields are not discarded.
class TaskMigrationWriter {
  TaskMigrationWriter({TaskMigrationAdapter? adapter})
      : adapter = adapter ?? const TaskMigrationAdapter();

  final TaskMigrationAdapter adapter;

  Future<void> save(List<Task> homeSnapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await saveTo(prefs, homeSnapshot);
  }

  Future<void> saveTo(
    SharedPreferences prefs,
    List<Task> homeSnapshot,
  ) async {
    final encoded = mergeHomeSnapshot(
      existingRaw: prefs.getString(TaskMigrationReader.legacyKey),
      homeSnapshot: homeSnapshot,
    );
    final saved = await prefs.setString(
      TaskMigrationReader.legacyKey,
      encoded,
    );
    if (!saved) {
      throw StateError('Could not persist the canonical Home snapshot');
    }
  }

  String mergeHomeSnapshot({
    required String? existingRaw,
    required List<Task> homeSnapshot,
  }) {
    final snapshotJson =
        jsonDecode(adapter.encodeUnifiedList(homeSnapshot)) as List<dynamic>;
    final sourceRaw = existingRaw == null || existingRaw.trim().isEmpty
        ? '[]'
        : existingRaw;
    final existingTasks = adapter.decodeLegacyList(sourceRaw);
    final existingJson = jsonDecode(sourceRaw) as List<dynamic>;
    final existingById = <String, Map<String, dynamic>>{};

    for (var index = 0; index < existingTasks.length; index++) {
      existingById[existingTasks[index].id] =
          Map<String, dynamic>.from(existingJson[index] as Map);
    }

    final merged = <Map<String, dynamic>>[];
    for (var index = 0; index < homeSnapshot.length; index++) {
      final task = homeSnapshot[index];
      final existing = existingById[task.id];

      if (existing == null) {
        merged.add(
          Map<String, dynamic>.from(snapshotJson[index] as Map),
        );
        continue;
      }

      merged.add(<String, dynamic>{
        ...existing,
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'followUpDate': task.followUpDate?.toIso8601String(),
        'tags': List<String>.of(task.tags),
        'archived': task.archived,
        'trashed': task.trashed,
        'completed': task.completed,
      });
    }

    final encoded = jsonEncode(merged);
    adapter.decodeLegacyList(encoded);
    return encoded;
  }
}
