import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/recurrence.dart';
import '../models/task.dart';

/// Relational owner for a Task's recurrence definition.
class RecurrenceSqlCodec {
  const RecurrenceSqlCodec._();

  static Future<void> writeTask(QueryExecutor executor, Task task) async {
    final rule = task.recurrence;
    if (rule == null) {
      await executor.runDelete(
        'DELETE FROM task_recurrence_rules WHERE task_id = ?',
        <Object?>[task.id],
      );
      return;
    }
    await executor.runInsert(
      '''INSERT INTO task_recurrence_rules (
        task_id, frequency, interval, start_date, end_date,
        occurrence_count, active, tracking_level
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(task_id) DO UPDATE SET
        frequency = excluded.frequency,
        interval = excluded.interval,
        start_date = excluded.start_date,
        end_date = excluded.end_date,
        occurrence_count = excluded.occurrence_count,
        active = excluded.active,
        tracking_level = excluded.tracking_level''',
      <Object?>[
        task.id,
        rule.frequency.name,
        rule.interval,
        rule.startDate?.toIso8601String(),
        rule.endDate?.toIso8601String(),
        rule.count,
        rule.active ? 1 : 0,
        rule.trackingLevel.name,
      ],
    );
  }

  static Future<RecurrenceRule?> readTask(
    QueryExecutor executor,
    String taskId,
  ) async {
    final rows = await executor.runSelect(
      'SELECT frequency, interval, start_date, end_date, occurrence_count, active, tracking_level '
      'FROM task_recurrence_rules WHERE task_id = ?',
      <Object?>[taskId],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final frequency = RecurrenceFrequency.values.where(
      (value) => value.name == row['frequency'],
    );
    final tracking = RecurrenceTrackingLevel.values.where(
      (value) => value.name == row['tracking_level'],
    );
    if (frequency.isEmpty || tracking.isEmpty) {
      throw FormatException('Invalid SQL recurrence enum for Task $taskId');
    }
    final interval = (row['interval'] as num?)?.toInt();
    final count = (row['occurrence_count'] as num?)?.toInt();
    if (interval == null || interval <= 0 || (count != null && count <= 0)) {
      throw FormatException('Invalid SQL recurrence bounds for Task $taskId');
    }
    DateTime? date(String key) {
      final raw = row[key];
      if (raw == null) return null;
      if (raw is! String) throw FormatException('Invalid SQL recurrence $key for Task $taskId');
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) throw FormatException('Invalid SQL recurrence $key for Task $taskId');
      return parsed;
    }
    final active = row['active'];
    if (active is! num || (active.toInt() != 0 && active.toInt() != 1)) {
      throw FormatException('Invalid SQL recurrence active flag for Task $taskId');
    }
    return RecurrenceRule(
      frequency: frequency.single,
      interval: interval,
      startDate: date('start_date'),
      endDate: date('end_date'),
      count: count,
      active: active.toInt() == 1,
      trackingLevel: tracking.single,
    );
  }

  /// Non-destructively imports the former JSON rule into its normalized row.
  /// The legacy JSON columns remain untouched as migration evidence until the
  /// separately authorized legacy-retirement gate is satisfied.
  static Future<void> migrateLegacyRules(QueryExecutor executor) async {
    final marker = await executor.runSelect(
      "SELECT value FROM arvin_storage_meta WHERE key = 'recurrence_rules_migrated_v1'",
      const [],
    );
    if (marker.isNotEmpty && marker.single['value'] == '1') return;

    final rows = await executor.runSelect(
      'SELECT id, recurrence_json, legacy_payload_json FROM tasks ORDER BY storage_ordinal, id',
      const [],
    );
    for (final row in rows) {
      final taskId = row['id'] as String;
      Map<String, dynamic>? columnRule;
      final rawColumn = row['recurrence_json'];
      if (rawColumn is String && rawColumn.trim().isNotEmpty) {
        final decoded = jsonDecode(rawColumn);
        if (decoded is! Map) throw FormatException('Legacy recurrence must be an object for Task $taskId');
        columnRule = Map<String, dynamic>.from(decoded);
      }
      Map<String, dynamic>? envelopeRule;
      final rawEnvelope = row['legacy_payload_json'];
      if (rawEnvelope is String && rawEnvelope.trim().isNotEmpty) {
        final decoded = jsonDecode(rawEnvelope);
        if (decoded is! Map) throw FormatException('Task envelope is invalid for Task $taskId');
        final rawRule = decoded['recurrence'];
        if (rawRule != null) {
          if (rawRule is! Map) throw FormatException('Legacy recurrence envelope is invalid for Task $taskId');
          envelopeRule = Map<String, dynamic>.from(rawRule);
        }
      }
      if (columnRule != null && envelopeRule != null &&
          _canonicalJson(columnRule) != _canonicalJson(envelopeRule)) {
        throw StateError('Legacy recurrence sources conflict for Task $taskId');
      }
      final source = columnRule ?? envelopeRule;
      if (source == null) continue;
      final rule = _decodeStrict(source, taskId);
      await _writeRule(executor, taskId, rule);
      final restored = await readTask(executor, taskId);
      if (restored == null || _canonicalJson(restored.toJson()) != _canonicalJson(rule.toJson())) {
        throw StateError('Recurrence migration parity mismatch for Task $taskId');
      }
    }
    await executor.runCustom(
      "INSERT INTO arvin_storage_meta (key, value) VALUES ('recurrence_rules_migrated_v1', '1') "
      "ON CONFLICT(key) DO UPDATE SET value = '1'",
    );
  }

  static Future<void> _writeRule(
    QueryExecutor executor,
    String taskId,
    RecurrenceRule rule,
  ) async {
    await executor.runInsert(
      '''INSERT INTO task_recurrence_rules (
        task_id, frequency, interval, start_date, end_date,
        occurrence_count, active, tracking_level
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(task_id) DO UPDATE SET
        frequency = excluded.frequency,
        interval = excluded.interval,
        start_date = excluded.start_date,
        end_date = excluded.end_date,
        occurrence_count = excluded.occurrence_count,
        active = excluded.active,
        tracking_level = excluded.tracking_level''',
      <Object?>[
        taskId, rule.frequency.name, rule.interval,
        rule.startDate?.toIso8601String(), rule.endDate?.toIso8601String(),
        rule.count, rule.active ? 1 : 0, rule.trackingLevel.name,
      ],
    );
  }

  static RecurrenceRule _decodeStrict(Map<String, dynamic> json, String taskId) {
    final frequencyName = json['frequency'];
    final frequency = RecurrenceFrequency.values.where((value) => value.name == frequencyName);
    if (frequency.isEmpty) throw FormatException('Unknown recurrence frequency for Task $taskId');
    final trackingName = json['trackingLevel'] ?? RecurrenceTrackingLevel.normal.name;
    final tracking = RecurrenceTrackingLevel.values.where((value) => value.name == trackingName);
    if (tracking.isEmpty) throw FormatException('Unknown recurrence tracking level for Task $taskId');
    final rawInterval = json['interval'] ?? 1;
    if (rawInterval is! num || rawInterval.toInt() != rawInterval || rawInterval <= 0) {
      throw FormatException('Invalid recurrence interval for Task $taskId');
    }
    final rawCount = json['count'];
    if (rawCount != null && (rawCount is! num || rawCount.toInt() != rawCount || rawCount <= 0)) {
      throw FormatException('Invalid recurrence count for Task $taskId');
    }
    DateTime? parseDate(String key) {
      final raw = json[key];
      if (raw == null) return null;
      if (raw is! String) throw FormatException('Invalid recurrence $key for Task $taskId');
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) throw FormatException('Invalid recurrence $key for Task $taskId');
      return parsed;
    }
    final active = json['active'] ?? true;
    if (active is! bool) throw FormatException('Invalid recurrence active flag for Task $taskId');
    return RecurrenceRule(
      frequency: frequency.single,
      interval: rawInterval.toInt(),
      startDate: parseDate('startDate'),
      endDate: parseDate('endDate'),
      count: rawCount?.toInt(),
      active: active,
      trackingLevel: tracking.single,
    );
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
