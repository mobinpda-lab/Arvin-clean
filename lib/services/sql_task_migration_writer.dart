import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'g1_drift_schema.dart';
import 'task_migration_adapter.dart';
import 'task_migration_reader.dart';
import 'occurrence_sql_codec.dart';
import 'recurrence_sql_codec.dart';

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
          await _assertExistingTaskParity(executor, record, storageOrdinal);
          skippedExisting++;
          continue;
        }

        await _insertTask(executor, record, storageOrdinal);
        inserted++;
      }

      // Run complete parity validation before commit so any mismatch rolls
      // back all task and relation writes.
      await _validateMigratedSnapshot(executor, records);
      final foreignKeyViolations =
          await executor.runSelect('PRAGMA foreign_key_check', const []);
      if (foreignKeyViolations.isNotEmpty) {
        throw StateError('Task migration foreign-key violations: $foreignKeyViolations');
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
        category, notebook_kind, priority, archived, trashed, completed, completed_at,
        is_favorite, recurrence_json, legacy_payload_json
       ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        task.id,
        storageOrdinal,
        task.title,
        task.description,
        task.createdAt?.toIso8601String(),
        task.updatedAt?.toIso8601String(),
        task.dueDateStorageValue,
        task.category,
        task.notebookKind?.name,
        task.priority.name,
        _bool(task.archived),
        _bool(task.trashed),
        _bool(task.completed),
        task.completedAt?.toIso8601String(),
        _bool(task.isFavorite),
        null,
        jsonEncode(_storageEnvelope(record)),
      ],
    );

    for (final reminder in task.taskReminders) {
      await executor.runInsert(
        '''INSERT INTO task_reminders
           (id, task_id, title, remind_at, is_all_day, sequence, is_enabled)
           VALUES (?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          reminder.id,
          task.id,
          reminder.title,
          reminder.storageDateValue,
          _bool(reminder.isAllDay),
          reminder.sequence,
          _bool(reminder.isEnabled),
        ],
      );
    }

    final now = DateTime.now().toIso8601String();
    for (final person in task.people) {
      await executor.runInsert(
        '''INSERT INTO persons (id, name, created_at, updated_at)
           VALUES (?, ?, ?, ?)
           ON CONFLICT(id) DO UPDATE SET name = excluded.name, updated_at = excluded.updated_at''',
        <Object?>[person.id, person.displayName, now, now],
      );
      await executor.runInsert(
        'INSERT OR IGNORE INTO person_directory (person_id) VALUES (?)',
        <Object?>[person.id],
      );
    }
    for (final followUp in task.followUps) {
      for (final personId in followUp.personIds) {
        await executor.runInsert(
          '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
             VALUES (?, '', ?, ?)''',
          <Object?>[personId, now, now],
        );
      }
    }

    for (var ordinal = 0; ordinal < task.followUps.length; ordinal++) {
      final followUp = task.followUps[ordinal];
      await executor.runInsert(
        '''INSERT INTO follow_up_records (
          id, task_id, completed_at, title, note, result, completed,
          waiting_for_response, ordinal
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          followUp.id,
          task.id,
          followUp.completedAt.toIso8601String(),
          followUp.title,
          followUp.note,
          followUp.result,
          _bool(followUp.completed),
          _bool(followUp.waitingForResponse),
          ordinal,
        ],
      );
      for (var personOrdinal = 0;
          personOrdinal < followUp.personIds.length;
          personOrdinal++) {
        await executor.runInsert(
          'INSERT INTO follow_up_record_people (follow_up_id, person_id, ordinal) VALUES (?, ?, ?)',
          <Object?>[
            followUp.id,
            followUp.personIds[personOrdinal],
            personOrdinal,
          ],
        );
      }
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
      final now = DateTime.now().toIso8601String();
      await executor.runInsert(
        '''INSERT INTO persons (id, name, created_at, updated_at)
           VALUES (?, ?, ?, ?)
           ON CONFLICT(id) DO UPDATE SET name = excluded.name, updated_at = excluded.updated_at''',
        <Object?>[person.id, person.displayName, now, now],
      );
      await executor.runInsert(
        'INSERT INTO task_persons (task_id, person_id, ordinal) VALUES (?, ?, ?)',
        <Object?>[task.id, person.id, ordinal],
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
    await OccurrenceSqlCodec.writeTask(executor, task);
    await RecurrenceSqlCodec.writeTask(executor, task);
  }

  Map<String, dynamic> _storageEnvelope(TaskMigrationRecord record) {
    return Map<String, dynamic>.from(record.sourceJson)
      ..remove('recurrence')
      ..remove('occurrenceHistory')
      ..remove('checklistOccurrences');
  }

  Future<void> _validateMigratedSnapshot(QueryExecutor executor, List<TaskMigrationRecord> records) async {
    final rows = await executor.runSelect(
      'SELECT id, storage_ordinal FROM tasks ORDER BY storage_ordinal, id', const [],
    );
    if (rows.length != records.length) {
      throw StateError('Task row-count mismatch before commit: source=${records.length}, target=${rows.length}');
    }
    for (var i = 0; i < records.length; i++) {
      if (rows[i]['id'] != records[i].task.id ||
          (rows[i]['storage_ordinal'] as num?)?.toInt() != i) {
        throw StateError('Task ID/order mismatch at ordinal $i before commit.');
      }
      await _assertExistingTaskParity(executor, records[i], i);
    }
  }

  Future<void> _assertExistingTaskParity(
    QueryExecutor executor, TaskMigrationRecord record, int storageOrdinal,
  ) async {
    final task = record.task;
    final rows = await executor.runSelect('SELECT * FROM tasks WHERE id = ?', [task.id]);
    if (rows.length != 1) throw StateError('Missing or duplicate target Task ${task.id}.');
    final row = rows.single;
    final fields = <String, Object?>{
      'storage_ordinal': storageOrdinal, 'title': task.title,
      'description': task.description,
      'created_at': task.createdAt?.toIso8601String(),
      'updated_at': task.updatedAt?.toIso8601String(),
      'due_date': task.dueDateStorageValue, 'category': task.category,
      'notebook_kind': task.notebookKind?.name, 'priority': task.priority.name,
      'archived': task.archived ? 1 : 0, 'trashed': task.trashed ? 1 : 0,
      'completed': task.completed ? 1 : 0,
      'completed_at': task.completedAt?.toIso8601String(),
      'is_favorite': task.isFavorite ? 1 : 0,
    };
    for (final entry in fields.entries) {
      if (row[entry.key] != entry.value) {
        throw StateError('Task field conflict ${task.id}.${entry.key}: source=${entry.value}, target=${row[entry.key]}');
      }
    }
    final rawEnvelope = row['legacy_payload_json'];
    if (rawEnvelope is! String) {
      throw StateError('Task envelope is missing for ${task.id}.');
    }
    final existingEnvelope = Map<String, dynamic>.from(jsonDecode(rawEnvelope) as Map)
      ..remove('recurrence')
      ..remove('occurrenceHistory')
      ..remove('checklistOccurrences');
    if (_canonicalJson(existingEnvelope) != _canonicalJson(_storageEnvelope(record))) {
      throw StateError('Task envelope/unknown-field conflict for ${task.id}.');
    }

    final reminders = task.taskReminders.toList()
      ..sort((a,b) => a.sequence != b.sequence ? a.sequence.compareTo(b.sequence) : a.id.compareTo(b.id));
    await _assertRows(executor,
      'SELECT id,title,remind_at,is_all_day,sequence,is_enabled FROM task_reminders WHERE task_id=? ORDER BY sequence,id',
      [task.id], ['id','title','remind_at','is_all_day','sequence','is_enabled'],
      reminders.map((r) => <String,Object?>{'id':r.id,'title':r.title,'remind_at':r.storageDateValue,'is_all_day':r.isAllDay?1:0,'sequence':r.sequence,'is_enabled':r.isEnabled?1:0}).toList(),
      'TaskReminder', task.id);

    await _assertRows(executor,
      'SELECT id,completed_at,title,note,result,completed,waiting_for_response,ordinal FROM follow_up_records WHERE task_id=? ORDER BY ordinal',
      [task.id], ['id','completed_at','title','note','result','completed','waiting_for_response','ordinal'],
      List.generate(task.followUps.length,(i){final f=task.followUps[i];return <String,Object?>{'id':f.id,'completed_at':f.completedAt.toIso8601String(),'title':f.title,'note':f.note,'result':f.result,'completed':f.completed?1:0,'waiting_for_response':f.waitingForResponse?1:0,'ordinal':i};}),
      'Follow-up history', task.id);

    await _assertRows(executor,
      'SELECT ordinal,value FROM checklist_items WHERE task_id=? ORDER BY ordinal',
      [task.id], ['ordinal','value'],
      List.generate(task.checklist.length,(i)=><String,Object?>{'ordinal':i,'value':task.checklist[i]}),
      'Checklist', task.id);

    await _assertRows(executor,
      'SELECT person_id,ordinal FROM task_persons WHERE task_id=? ORDER BY ordinal',
      [task.id], ['person_id','ordinal'],
      List.generate(task.people.length,(i)=><String,Object?>{'person_id':task.people[i].id,'ordinal':i}),
      'Task-Person', task.id);

    await _assertRows(executor,
      'SELECT tags.name AS name,task_tags.ordinal AS ordinal FROM task_tags JOIN tags ON tags.id=task_tags.tag_id WHERE task_tags.task_id=? ORDER BY task_tags.ordinal',
      [task.id], ['name','ordinal'],
      List.generate(task.tags.length,(i)=><String,Object?>{'name':task.tags[i],'ordinal':i}),
      'Task-Tag', task.id);

    final people=<Map<String,Object?>>[];
    for(final f in task.followUps){for(var i=0;i<f.personIds.length;i++){people.add(<String,Object?>{'follow_up_id':f.id,'person_id':f.personIds[i],'ordinal':i});}}
    await _assertRows(executor,
      'SELECT p.follow_up_id AS follow_up_id,p.person_id AS person_id,p.ordinal AS ordinal FROM follow_up_record_people p JOIN follow_up_records f ON f.id=p.follow_up_id WHERE f.task_id=? ORDER BY f.ordinal,p.ordinal',
      [task.id], ['follow_up_id','person_id','ordinal'], people,
      'Follow-up-Person', task.id);
    final occurrenceData = await OccurrenceSqlCodec.readTask(executor, task.id);
    final expectedOccurrenceHistory =
        Map<String, Map<String, dynamic>>.from(task.occurrenceHistory);
    for (final scheduledAt in task.checklistOccurrences.keys) {
      expectedOccurrenceHistory.putIfAbsent(
        scheduledAt,
        () => <String, dynamic>{
          'scheduledDate': scheduledAt,
          'status': 'pending',
        },
      );
    }
    if (_canonicalJson(occurrenceData.history) != _canonicalJson(expectedOccurrenceHistory) ||
        _canonicalJson(occurrenceData.checklists) != _canonicalJson(task.checklistOccurrences)) {
      throw StateError('Occurrence/occurrence-checklist parity mismatch for Task ${task.id}.');
    }
    final recurrenceRule = await RecurrenceSqlCodec.readTask(executor, task.id);
    if (_canonicalJson(recurrenceRule?.toJson()) !=
        _canonicalJson(task.recurrence?.toJson())) {
      throw StateError('Recurrence relational parity mismatch for Task ${task.id}.');
    }
  }

  Future<void> _assertRows(
    QueryExecutor executor, String sql, List<Object?> variables,
    List<String> fields, List<Map<String,Object?>> expected,
    String relation, String taskId,
  ) async {
    final rows=await executor.runSelect(sql,variables);
    final actual=rows.map((r)=><String,Object?>{for(final f in fields) f:r[f]}).toList();
    if(_canonicalJson(actual)!=_canonicalJson(expected)){
      throw StateError('$relation parity mismatch for Task $taskId before commit.');
    }
  }

  Object? _canonicalize(Object? value){
    if(value is Map){final keys=value.keys.map((k)=>k.toString()).toList()..sort();return <String,Object?>{for(final k in keys)k:_canonicalize(value[k])};}
    if(value is List)return value.map(_canonicalize).toList(growable:false);
    return value;
  }
  String _canonicalJson(Object? value)=>jsonEncode(_canonicalize(value));

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
