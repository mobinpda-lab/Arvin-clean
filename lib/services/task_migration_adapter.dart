import 'dart:convert';

import '../models/task.dart';

/// Boundary for migrating Home's legacy `arvin.tasks` JSON into the
/// canonical Unified Item model without coupling the UI to legacy JSON.
class TaskMigrationAdapter {
  const TaskMigrationAdapter();

  Task fromLegacyJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Legacy task requires a non-empty id');
    }

    final title = json['title'];
    if (title != null && title is! String) {
      throw const FormatException('Legacy task title must be a string');
    }

    return Task.fromJson(json);
  }

  List<Task> decodeLegacyList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Expected a task list');
    }

    final tasks = <Task>[];
    final ids = <String>{};

    for (var index = 0; index < decoded.length; index++) {
      final item = decoded[index];
      if (item is! Map) {
        throw FormatException('Task at index $index is not an object');
      }

      final task = fromLegacyJson(Map<String, dynamic>.from(item));
      if (!ids.add(task.id)) {
        throw FormatException('Duplicate task id: ${task.id}');
      }
      tasks.add(task);
    }

    return tasks;
  }

  String encodeUnifiedList(List<Task> tasks) {
    final ids = <String>{};
    for (final task in tasks) {
      if (task.id.trim().isEmpty) {
        throw const FormatException('Unified task requires a non-empty id');
      }
      if (!ids.add(task.id)) {
        throw FormatException('Duplicate task id: ${task.id}');
      }
    }

    return jsonEncode(tasks.map((task) => task.toJson()).toList());
  }
}
