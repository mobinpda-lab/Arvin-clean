import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'g1_drift_schema.dart';
import 'task_migration_adapter.dart';
import 'task_migration_reader.dart';

/// One-way migration writer from the canonical legacy task document to SQL.
///
/// This is a migration boundary, not a second repository or domain model.
/// The legacy JSON envelope is stored on the same SQL task row so fields not
/// known by the current Task model remain recoverable.
class SqlTaskMigrationWriter {
  const SqlTaskMigrationWriter({
    TaskMigrationAdapter? adapter,
  }) : adapter = adapter ?? const TaskMigrationAdapter();

  final TaskMigrationAdapter adapter;

  Future<SqlTaskMigrationReport> migrateFromPreferences({
    required QueryExecutor executor,
    required SharedPreferences preferences,
  }) async {
    await G1DriftSchema.install(executor);

    final raw = preferences.getString(TaskMigrationReader.legacyKey);
    if (raw == null || raw.trim().isEmpty) {
      return const SqlTaskMigrationReport();
    }

    final records = adapter.decodeLegacyRecords(raw);
    // The executor is already opened by G1DriftSchema.install; use an explicit SQL transaction so every statement runs on that opened executor.
    var inserted = 0;
    var skippedExisting = 0;

    await executor.runCustom('BEGIN');
    try {
      for (var storageOrdinal = 0; storageOrdinal < records.length; storageOrdinal++) {
        final record = records[storageOrdinal];
        final exists = await executor.runSelect(
          'SELECT id FROM tasks WHERE id = ? LIMIT 1',
          <Object?>[record.task.id],
        );
        if (exists.isNotEmpty) {
          skippedExisting++;
          continue;
        }

        await _insertTask(executor, record, storageOrdinal);
        inserted++;
      }

      await executor.runCustom('COMMIT');
    } catch (_) {
      await executor.runCustom('ROLLBACK');
      rethrow;
    }

    final countRows = await executor.runSelect(
      'SELECT COUNT(*) AS count FROM tasks',
      const [],
    );

    return SqlTaskMigrationReport(
      sourceCount: records.length,
      insertedCount: inserted,
      skippedExistingCount: skippedExisting,
      sqlTaskCount: (countRows.single['count'] as num).toInt(),
    );
  }

  Future<void> _insertTask(
    QueryExecutor executor,
    TaskMigrationRecord record,
    int storageOrdinal,
  ) async {
    final task = record.task;

    await executor.runInsert(
      '''INSERT INTO tasks (
        id, storage_ordinal, title, description, created_at, updated_at, due_date,
        follow_up_enabled, follow_up_date, category, notebook_kind,
        reminder_date, priority, archived, trashed, completed,
        recurrence_json, legacy_payload_json
       ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        task.id,
        storageOrdinal,
        task.title,
        task.description,
        task.createdAt?.toIso8601String(),
        task.updatedAt?.toIso8601String(),
        task.dueDate?.toIso8601String(),
        _bool(task.followUpEnabled),
        task.followUpDate?.toIso8601String(),
        task.category,
        task.notebookKind?.name,
        task.reminderDate?.toIso8601String(),
        task.priority.name,
        _bool(task.archived),
        _bool(task.trashed),
        _bool(task.completed),
        task.recurrence == null ? null : jsonEncode(task.recurrence!.toJson()),
        record.sourceJsonEncoded,
      ],
    );

    for (var ordinal = 0; ordinal < task.followUps.length; ordinal++) {
      final followUp = task.followUps[ordinal];
      await executor.runInsert(
        '''INSERT INTO follow_ups (
          id, task_id, date_time, note, result, reminder_date,
          next_follow_up, completed, ordinal
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          followUp.id,
          task.id,
          followUp.dateTime.toIso8601String(),
          followUp.note,
          followUp.result,
          followUp.reminderDate?.toIso8601String(),
          followUp.nextFollowUp?.toIso8601String(),
          _bool(followUp.completed),
          ordinal,
        ],
      );
    }

    for (var ordinal = 0; ordinal < task.checklist.length; ordinal++) {
      await executor.runInsert(
        '''INSERT INTO checklist_items (task_id, ordinal, value)
           VALUES (?, ?, ?)''',
        <Object?>[task.id, ordinal, task.checklist[ordinal]],
      );
    }

    for (var ordinal = 0; ordinal < task.people.length; ordinal++) {
      final person = task.people[ordinal];
      await executor.runInsert(
        '''INSERT INTO task_people (
          task_id, person_id, person_json, ordinal
        ) VALUES (?, ?, ?, ?)''',
        <Object?>[
          task.id,
          person.id,
          jsonEncode(person.toJson()),
          ordinal,
        ],
      );
    }

    for (var ordinal = 0; ordinal < task.tags.length; ordinal++) {
      final tag = task.tags[ordinal];
      final tagId = _tagId(tag);
      await executor.runInsert(
        'INSERT OR IGNORE INTO tags (id, name) VALUES (?, ?)',
        <Object?>[tagId, tag],
      );
      await executor.runInsert(
        '''INSERT INTO task_tags (task_id, tag_id, ordinal)
           VALUES (?, ?, ?)''',
        <Object?>[task.id, tagId, ordinal],
      );
    }
  }

  static int _bool(bool value) => value ? 1 : 0;

  static String _tagId(String value) {
    final bytes = Uint8List.fromList(utf8.encode(value));
    return 'legacy-tag-${base64UrlEncode(bytes).replaceAll('=', '')}';
  }
}

class SqlTaskMigrationReport {
  const SqlTaskMigrationReport({
    this.sourceCount = 0,
    this.insertedCount = 0,
    this.skippedExistingCount = 0,
    this.sqlTaskCount = 0,
  });

  final int sourceCount;
  final int insertedCount;
  final int skippedExistingCount;
  final int sqlTaskCount;
}
