import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/task.dart';
import '../models/recurrence.dart';

/// Relational persistence boundary for recurring Task Occurrences.
///
/// Occurrence identity is deterministic from the owning Task ID and the
/// canonical scheduled timestamp. The Task JSON representation remains a
/// portable backup/import shape only; local SQL reads and writes use these
/// normalized tables.
class OccurrenceSqlCodec {
  const OccurrenceSqlCodec._();

  static String occurrenceId(String taskId, String scheduledAt) =>
      'occ-${base64UrlEncode(utf8.encode('$taskId|$scheduledAt')).replaceAll('=', '')}';

  static Future<void> writeTask(QueryExecutor executor, Task task) async {
    var ordinal = 0;
    final known = <String>{};
    for (final entry in task.occurrenceHistory.entries) {
      final state = entry.value;
      final scheduledAt = _scheduledAt(entry.key, state);
      if (!known.add(scheduledAt)) {
        throw FormatException('Duplicate occurrence timestamp for Task ${task.id}: $scheduledAt');
      }
      final status = state['status'];
      if (status is! String ||
          !RecurrenceOccurrenceStatus.values.any((value) => value.name == status)) {
        throw FormatException('Occurrence status is invalid for Task ${task.id}: $scheduledAt');
      }
      await _ensureOccurrence(
        executor,
        taskId: task.id,
        scheduledAt: scheduledAt,
        status: status,
        completedAt: state['completionDate'] as String?,
        result: state['result'] as String?,
        ordinal: ordinal++,
      );
    }

    for (final entry in task.checklistOccurrences.entries) {
      final scheduledAt = entry.key;
      if (!known.contains(scheduledAt)) {
        await _ensureOccurrence(
          executor,
          taskId: task.id,
          scheduledAt: scheduledAt,
          status: 'pending',
          completedAt: null,
          result: null,
          ordinal: ordinal++,
        );
        known.add(scheduledAt);
      }
      final occurrenceIdValue = occurrenceId(task.id, scheduledAt);
      final existingItems = await executor.runSelect(
        'SELECT ordinal, value FROM occurrence_checklist_items '
        'WHERE occurrence_id = ? ORDER BY ordinal',
        <Object?>[occurrenceIdValue],
      );
      final expectedItems = List.generate(
        entry.value.length,
        (index) => <String, Object?>{'ordinal': index, 'value': entry.value[index]},
      );
      final actualItems = existingItems.map((row) => <String, Object?>{
        'ordinal': row['ordinal'],
        'value': row['value'],
      }).toList();
      if (existingItems.isEmpty) {
        for (var index = 0; index < entry.value.length; index++) {
          await executor.runInsert(
            'INSERT INTO occurrence_checklist_items (occurrence_id, ordinal, value) VALUES (?, ?, ?)',
            <Object?>[occurrenceIdValue, index, entry.value[index]],
          );
        }
      } else if (_canonicalJson(actualItems) != _canonicalJson(expectedItems)) {
        throw StateError('Occurrence checklist conflict for Task ${task.id} at $scheduledAt');
      }
    }
  }

  static Future<({Map<String, Map<String, dynamic>> history, Map<String, List<String>> checklists})>
      readTask(QueryExecutor executor, String taskId) async {
    final occurrences = await executor.runSelect(
      'SELECT scheduled_at, status, completed_at, result '
      'FROM task_occurrences WHERE task_id = ? ORDER BY ordinal, scheduled_at',
      <Object?>[taskId],
    );
    final history = <String, Map<String, dynamic>>{};
    for (final row in occurrences) {
      final scheduledAt = row['scheduled_at'] as String;
      history[scheduledAt] = <String, dynamic>{
        'scheduledDate': scheduledAt,
        'status': row['status'],
        if (row['completed_at'] != null) 'completionDate': row['completed_at'],
        if (row['result'] != null) 'result': row['result'],
      };
    }

    final checklistRows = await executor.runSelect(
      'SELECT o.scheduled_at AS scheduled_at, c.ordinal AS ordinal, c.value AS value '
      'FROM task_occurrences o JOIN occurrence_checklist_items c '
      'ON c.occurrence_id = o.id WHERE o.task_id = ? '
      'ORDER BY o.ordinal, c.ordinal',
      <Object?>[taskId],
    );
    final checklists = <String, List<String>>{};
    for (final row in checklistRows) {
      final key = row['scheduled_at'] as String;
      checklists.putIfAbsent(key, () => <String>[]).add(row['value'] as String);
    }
    return (history: history, checklists: checklists);
  }

  /// Converts old Task envelope maps into independent SQL Occurrence rows.
  /// The legacy fields are removed only after every row and checklist item
  /// has been written and compared inside the enclosing schema transaction.
  static Future<void> migrateLegacyEnvelopes(QueryExecutor executor) async {
    final tasks = await executor.runSelect(
      'SELECT id, legacy_payload_json FROM tasks ORDER BY storage_ordinal, id',
      const [],
    );
    for (final row in tasks) {
      final taskId = row['id'] as String;
      final raw = row['legacy_payload_json'];
      if (raw is! String || raw.trim().isEmpty) continue;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw FormatException('Task legacy envelope is invalid for $taskId');
      }
      final envelope = Map<String, dynamic>.from(decoded);
      final rawHistory = envelope['occurrenceHistory'];
      final rawChecklists = envelope['checklistOccurrences'];
      if (rawHistory != null && rawHistory is! Map) {
        throw FormatException('Occurrence history is invalid for Task $taskId');
      }
      if (rawChecklists != null && rawChecklists is! Map) {
        throw FormatException('Occurrence checklist map is invalid for Task $taskId');
      }
      final history = <String, Map<String, dynamic>>{};
      if (rawHistory is Map) {
        for (final entry in rawHistory.entries) {
          if (entry.key is! String || entry.value is! Map) {
            throw FormatException('Invalid occurrence history row for Task $taskId');
          }
          history[entry.key as String] = Map<String, dynamic>.from(entry.value as Map);
        }
      }
      final checklists = <String, List<String>>{};
      if (rawChecklists is Map) {
        for (final entry in rawChecklists.entries) {
          if (entry.key is! String || entry.value is! List ||
              (entry.value as List).any((item) => item is! String)) {
            throw FormatException('Invalid occurrence checklist row for Task $taskId');
          }
          checklists[entry.key as String] = List<String>.from(entry.value as List);
        }
      }
      for (final scheduledAt in checklists.keys) {
        history.putIfAbsent(scheduledAt, () => <String, dynamic>{
          'scheduledDate': scheduledAt,
          'status': RecurrenceOccurrenceStatus.pending.name,
        });
      }
      final task = Task(
        id: taskId,
        title: envelope['title'] is String ? envelope['title'] as String : '',
        occurrenceHistory: history,
        checklistOccurrences: checklists,
      );
      await writeTask(executor, task);
      final restored = await readTask(executor, taskId);
      if (_canonicalJson(restored.history) != _canonicalJson(history) ||
          _canonicalJson(restored.checklists) != _canonicalJson(checklists)) {
        throw StateError('Occurrence migration parity mismatch for Task $taskId');
      }
      if (envelope.containsKey('occurrenceHistory') ||
          envelope.containsKey('checklistOccurrences')) {
        envelope
          ..remove('occurrenceHistory')
          ..remove('checklistOccurrences');
        await executor.runUpdate(
          'UPDATE tasks SET legacy_payload_json = ? WHERE id = ?',
          <Object?>[jsonEncode(envelope), taskId],
        );
      }
    }
  }

  static String _scheduledAt(String key, Map<String, dynamic> state) {
    final value = state['scheduledDate'];
    if (value != null && value is! String) {
      throw const FormatException('Occurrence scheduledDate must be a string');
    }
    final scheduledAt = value as String? ?? key;
    if (scheduledAt.trim().isEmpty || scheduledAt != key) {
      throw FormatException('Occurrence key/date mismatch: key=$key, date=$scheduledAt');
    }
    return scheduledAt;
  }

  static Future<void> _ensureOccurrence(
    QueryExecutor executor, {
    required String taskId,
    required String scheduledAt,
    required String status,
    required String? completedAt,
    required String? result,
    required int ordinal,
  }) async {
    final id = occurrenceId(taskId, scheduledAt);
    final existing = await executor.runSelect(
      'SELECT id, status, completed_at, result, ordinal FROM task_occurrences '
      'WHERE task_id = ? AND scheduled_at = ?',
      <Object?>[taskId, scheduledAt],
    );
    if (existing.isEmpty) {
      await executor.runInsert(
        'INSERT INTO task_occurrences (id, task_id, scheduled_at, status, completed_at, result, ordinal) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>[id, taskId, scheduledAt, status, completedAt, result, ordinal],
      );
      return;
    }
    final row = existing.single;
    if (row['id'] != id || row['status'] != status ||
        row['completed_at'] != completedAt || row['result'] != result ||
        (row['ordinal'] as num?)?.toInt() != ordinal) {
      throw StateError('Occurrence identity/content conflict for Task $taskId at $scheduledAt');
    }
  }

  static String _canonicalJson(Object? value) => jsonEncode(_canonicalize(value));

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{for (final key in keys) key: _canonicalize(value[key])};
    }
    if (value is List) return value.map(_canonicalize).toList(growable: false);
    return value;
  }
}
