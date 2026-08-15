import 'dart:convert';

import '../models/task.dart';

/// Boundary for migrating Home's legacy `arvin.tasks` JSON into the
/// canonical Unified Item model without coupling the UI to legacy JSON.
class TaskMigrationAdapter {
  const TaskMigrationAdapter();

  Task fromLegacyJson(Map<String, dynamic> json) => Task.fromJson(json);

  List<Task> decodeLegacyList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Expected a task list');
    }

    return decoded
        .map((item) => fromLegacyJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  String encodeUnifiedList(List<Task> tasks) {
    return jsonEncode(tasks.map((task) => task.toJson()).toList());
  }
}
