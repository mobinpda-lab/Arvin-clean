import 'dart:convert';

import 'package:arvin/models/task.dart';

/// One legacy task plus its original JSON envelope.
///
/// The canonical [Task] remains the only domain model. The envelope exists
/// only at the migration boundary so fields unknown to the current model are
/// not silently lost before they reach SQL.
class TaskMigrationRecord {
  const TaskMigrationRecord({required this.task, required this.sourceJson});

  final Task task;
  final Map<String, dynamic> sourceJson;

  String get sourceJsonEncoded => jsonEncode(sourceJson);
}

/// Boundary for migrating Home's legacy `arvin.tasks` JSON into the
/// canonical Unified Item model without coupling the UI to legacy JSON.
class TaskMigrationAdapter {
  const TaskMigrationAdapter();

  TaskMigrationRecord recordFromLegacyJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Legacy task requires a non-empty id');
    }

    final title = json['title'];
    if (title != null && title is! String) {
      throw const FormatException('Legacy task title must be a string');
    }

    final task = Task.fromJson(json);
    return TaskMigrationRecord(
      task: task,
      sourceJson: Map<String, dynamic>.from(json),
    );
  }

  Task fromLegacyJson(Map<String, dynamic> json) => recordFromLegacyJson(json).task;

  List<TaskMigrationRecord> decodeLegacyRecords(String raw) {
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

      final record = recordFromLegacyJson(Map<String, dynamic>.from(item));
      if (!ids.add(record.task.id)) {
        throw FormatException('Duplicate task id: ${record.task.id}');
      }
      tasks.add(record);
    }

    return tasks;
  }

  List<Task> decodeLegacyList(String raw) =>
      decodeLegacyRecords(raw).map((record) => record.task).toList();

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
