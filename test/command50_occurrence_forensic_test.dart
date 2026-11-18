import 'dart:convert';
import 'dart:io';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/occurrence_sql_codec.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/drift.dart' show QueryExecutor, QueryExecutorUser, OpeningDetails;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _V7Inspector implements QueryExecutorUser {
  @override
  int get schemaVersion => 7;
  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

Future<QueryExecutor> _open(File file, {bool v7 = false}) async {
  final executor = NativeDatabase(file);
  await executor.ensureOpen(v7 ? _V7Inspector() : G1DriftSchema());
  return executor;
}

Future<void> _markLegacySourcesMigrated(QueryExecutor db) async {
  for (final key in const ['legacy_tasks_migrated', 'legacy_tags_migrated']) {
    await db.runInsert(
      'INSERT INTO arvin_storage_meta (key, value) VALUES (?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      <Object?>[key, '1'],
    );
  }
}

Future<Map<String, Object?>> _installAndCapture(File file) async {
  final db = await _open(file);
  try {
    String error = 'UNEXPECTED_PASS';
    try {
      await G1DriftSchema.install(db);
    } catch (caught) {
      error = caught.runtimeType.toString() + ': ' + caught.toString();
    }
    final occurrenceTable = await db.runSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='task_occurrences'",
      const [],
    );
    final occurrenceRows = occurrenceTable.isEmpty
        ? const <Map<String, Object?>>[]
        : (await db.runSelect(
            "SELECT id, task_id, scheduled_at, status FROM task_occurrences WHERE task_id LIKE 'c50-%' ORDER BY task_id, ordinal",
            const [],
          )).map((row) => Map<String, Object?>.from(row)).toList();
    final sources = await db.runSelect(
      "SELECT id, legacy_payload_json FROM tasks WHERE id LIKE 'c50-%' ORDER BY id",
      const [],
    );
    final integrity = await db.runSelect('PRAGMA integrity_check', const []);
    final foreignKeys = await db.runSelect('PRAGMA foreign_key_check', const []);
    return <String, Object?>{
      'error': error,
      'sources_after_failure': sources,
      'occurrences_after_failure': occurrenceRows,
      'integrity_check': integrity,
      'foreign_key_violations': foreignKeys.length,
    };
  } finally {
    await db.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = Directory(Platform.environment['ARVIN_COMMAND50_DIR']!);
  final baseFixture = File(Platform.environment['ARVIN_COMMAND50_BASE_FIXTURE']!);
  final nullFixture = File(Platform.environment['ARVIN_COMMAND50_NULL_FIXTURE']!);
  final unknownFixture = File(Platform.environment['ARVIN_COMMAND50_UNKNOWN_FIXTURE']!);

  test('COMMAND 50-R: historical V19 Occurrence forensic matrix', () async {
    expect(G1DriftSchema.version, 19);
    expect(await baseFixture.exists(), isTrue);
    expect(await nullFixture.exists(), isTrue);
    expect(await unknownFixture.exists(), isTrue);

    final primary = File(root.path + '/command50-primary.sqlite');
    await baseFixture.copy(primary.path);
    var db = await _open(primary, v7: true);
    final before = await db.runSelect(
      "SELECT id, legacy_payload_json FROM tasks WHERE id LIKE 'c50-%' ORDER BY id",
      const [],
    );
    expect(before.length, 4);
    final sourceSnapshot = <String, Object?>{};
    for (final row in before) {
      final taskId = row['id'] as String;
      sourceSnapshot[taskId] = jsonDecode(row['legacy_payload_json'] as String);
    }
    File(root.path + '/command50-source-occurrences.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(sourceSnapshot),
    );
    await db.close();

    final expectedFromSource = <String, Map<String, Object?>>{};
    for (final sourceEntry in sourceSnapshot.entries) {
      final taskId = sourceEntry.key;
      final envelope = sourceEntry.value as Map;
      final history = envelope['occurrenceHistory'] as Map;
      var sourceOrdinal = 0;
      for (final occurrenceEntry in history.entries) {
        final scheduledAt = occurrenceEntry.key as String;
        final state = Map<String, dynamic>.from(occurrenceEntry.value as Map);
        expectedFromSource['$taskId|$scheduledAt'] = <String, Object?>{
          'id': OccurrenceSqlCodec.occurrenceId(taskId, scheduledAt),
          'task_id': taskId,
          'scheduled_at': scheduledAt,
          'status': state['status'],
          'completed_at': state['completionDate'],
          'result': state['result'],
          'ordinal': sourceOrdinal++,
        };
      }
    }

    db = await _open(primary);
    try {
      await G1DriftSchema.install(db);
      final sqlRows = await db.runSelect(
        "SELECT id, task_id, scheduled_at, status, completed_at, result, ordinal "
        "FROM task_occurrences WHERE task_id LIKE 'c50-%' ORDER BY task_id, ordinal",
        const [],
      );
      final expected = <Map<String, Object?>>[
        {'id': OccurrenceSqlCodec.occurrenceId('c50-matrix-a', '2026-11-01T08:00:00.000Z'),
         'task_id': 'c50-matrix-a', 'scheduled_at': '2026-11-01T08:00:00.000Z',
         'status': 'pending', 'completed_at': null, 'result': null, 'ordinal': 0},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-matrix-a', '2026-11-02T08:00:00.000Z'),
         'task_id': 'c50-matrix-a', 'scheduled_at': '2026-11-02T08:00:00.000Z',
         'status': 'completed', 'completed_at': '2026-11-02T08:10:00.000Z',
         'result': 'done', 'ordinal': 1},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-matrix-a', '2026-11-03T08:00:00.000Z'),
         'task_id': 'c50-matrix-a', 'scheduled_at': '2026-11-03T08:00:00.000Z',
         'status': 'cancelled', 'completed_at': null, 'result': null, 'ordinal': 2},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-matrix-b', '0001-01-01T00:00:00.000Z'),
         'task_id': 'c50-matrix-b', 'scheduled_at': '0001-01-01T00:00:00.000Z',
         'status': 'missed', 'completed_at': null, 'result': null, 'ordinal': 0},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-matrix-b', '9999-12-31T23:59:59.999Z'),
         'task_id': 'c50-matrix-b', 'scheduled_at': '9999-12-31T23:59:59.999Z',
         'status': 'skipped', 'completed_at': null, 'result': null, 'ordinal': 1},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-matrix-b', '2026-11-05T10:00:00+03:30'),
         'task_id': 'c50-matrix-b', 'scheduled_at': '2026-11-05T10:00:00+03:30',
         'status': 'pending', 'completed_at': null, 'result': null, 'ordinal': 2},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-no-recurrence', '2026-12-02T09:00:00.000Z'),
         'task_id': 'c50-no-recurrence', 'scheduled_at': '2026-12-02T09:00:00.000Z',
         'status': 'pending', 'completed_at': null, 'result': null, 'ordinal': 0},
        {'id': OccurrenceSqlCodec.occurrenceId('c50-recurring', '2026-12-01T09:00:00.000Z'),
         'task_id': 'c50-recurring', 'scheduled_at': '2026-12-01T09:00:00.000Z',
         'status': 'pending', 'completed_at': null, 'result': null, 'ordinal': 0},
      ];
      final actual = sqlRows.map((row) => <String, Object?>{
        for (final key in ['id','task_id','scheduled_at','status','completed_at','result','ordinal'])
          key: row[key],
      }).toList();
      final expectedByIdentity = <String, Map<String, Object?>>{
        for (final row in expected)
          '${row['task_id']}|${row['scheduled_at']}': row,
      };
      final actualByIdentity = <String, Map<String, Object?>>{
        for (final row in actual)
          '${row['task_id']}|${row['scheduled_at']}': row,
      };
      expect(expectedByIdentity, expectedFromSource,
          reason: 'Fixture expectation must be derived from the captured V7 source JSON.');
      expect(actualByIdentity.length, expectedFromSource.length);
      expect(actualByIdentity, expectedFromSource,
          reason: 'Compare occurrence rows by Task ID + scheduled timestamp, not JSON array order.');

      for (final taskId in const ['c50-matrix-a','c50-matrix-b','c50-recurring','c50-no-recurrence']) {
        final restored = await OccurrenceSqlCodec.readTask(db, taskId);
        expect(restored.history, isNotEmpty);
        expect(restored.checklists, isEmpty);
      }
      final recurrence = await db.runSelect(
        "SELECT frequency, interval, active, start_date, end_date FROM task_recurrence_rules WHERE task_id='c50-recurring'",
        const [],
      );
      expect(recurrence, hasLength(1));
      expect(recurrence.single['frequency'], 'daily');
      expect(recurrence.single['interval'], 2);
      expect(recurrence.single['start_date'], '2026-12-01T05:30:00.000Z');
      expect(recurrence.single['end_date'], '2026-12-08T05:30:00.000Z');
      expect(actualByIdentity['c50-matrix-b|2026-11-05T10:00:00+03:30']!['scheduled_at'],
          '2026-11-05T10:00:00+03:30', reason: 'Occurrence scheduled timestamp is preserved as its original text.');

      final payload = await db.runSelect(
        "SELECT legacy_payload_json FROM tasks WHERE id='c50-matrix-a'",
        const [],
      );
      final migratedEnvelope = jsonDecode(payload.single['legacy_payload_json'] as String) as Map;
      expect(migratedEnvelope.containsKey('occurrenceHistory'), isFalse);
      expect(migratedEnvelope['legacyFollowUpMetadata']['unknownFields']['legacyCustomField'],
          'preserve-me');

      await _markLegacySourcesMigrated(db);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final loaded = await TaskStore(executor: db).load();
      final byId = <String, Task>{for (final task in loaded) task.id: task};
      expect(byId['c50-matrix-a']!.occurrenceHistory, hasLength(3));
      expect(byId['c50-matrix-b']!.occurrenceHistory, hasLength(3));
      expect(byId['c50-recurring']!.recurrence, isNotNull);
      expect(byId['c50-no-recurrence']!.recurrence, isNull);
      File(root.path + '/command50-taskstore-readback.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(
          loaded.where((task) => task.id.startsWith('c50-')).map((task) => task.toJson()).toList(),
        ),
      );
      File(root.path + '/command50-first-install-sql.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(actual),
      );
    } finally {
      await db.close();
    }

    db = await _open(primary);
    String retryError = 'UNEXPECTED_PASS';
    try {
      try {
        await G1DriftSchema.install(db);
      } catch (error) {
        retryError = error.runtimeType.toString() + ': ' + error.toString();
      }
      expect(retryError, contains('Occurrence migration parity mismatch for Task c50-matrix-a'));
      final persisted = await db.runSelect(
        "SELECT id, task_id, scheduled_at, status FROM task_occurrences WHERE task_id LIKE 'c50-%' ORDER BY task_id, ordinal",
        const [],
      );
      expect(persisted, hasLength(expectedFromSource.length));
      final retryIntegrity = await db.runSelect('PRAGMA integrity_check', const []);
      final retryForeignKeys = await db.runSelect('PRAGMA foreign_key_check', const []);
      expect(retryIntegrity.single['integrity_check'], 'ok');
      expect(retryForeignKeys, isEmpty);
      File(root.path + '/command50-retry-error.txt').writeAsStringSync(retryError);
      File(root.path + '/command50-retry-sql.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(persisted),
      );
      File(root.path + '/command50-retry-integrity.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'integrity_check': retryIntegrity,
          'foreign_key_violations': retryForeignKeys.length,
        }),
      );
    } finally {
      await db.close();
    }

    final nullDb = File(root.path + '/command50-null.sqlite');
    final unknownDb = File(root.path + '/command50-unknown.sqlite');
    await nullFixture.copy(nullDb.path);
    await unknownFixture.copy(unknownDb.path);
    final nullEvidence = await _installAndCapture(nullDb);
    final unknownEvidence = await _installAndCapture(unknownDb);
    expect(nullEvidence['error'], contains('Occurrence migration parity mismatch for Task c50-explicit-null'));
    expect(unknownEvidence['error'], contains('Occurrence migration parity mismatch for Task c50-unknown-state'));
    for (final evidence in [nullEvidence, unknownEvidence]) {
      expect(evidence['sources_after_failure'], hasLength(1),
          reason: 'The original legacy JSON record must remain after a rejected migration.');
      expect(evidence['occurrences_after_failure'], isEmpty,
          reason: 'A failed first transfer must not leave a partial destination row.');
      expect((evidence['integrity_check'] as List).single['integrity_check'], 'ok');
      expect(evidence['foreign_key_violations'], 0);
    }
    final nullSourceRow = (nullEvidence['sources_after_failure'] as List).single as Map;
    final nullEnvelope = jsonDecode(nullSourceRow['legacy_payload_json'] as String) as Map;
    expect(nullEnvelope.containsKey('occurrenceHistory'), isTrue);
    final nullState = (nullEnvelope['occurrenceHistory'] as Map).values.single as Map;
    expect(nullState.containsKey('completionDate'), isTrue);
    expect(nullState['completionDate'], isNull);
    expect(nullState.containsKey('result'), isTrue);
    expect(nullState['result'], isNull);

    final unknownSourceRow = (unknownEvidence['sources_after_failure'] as List).single as Map;
    final unknownEnvelope = jsonDecode(unknownSourceRow['legacy_payload_json'] as String) as Map;
    expect(unknownEnvelope.containsKey('occurrenceHistory'), isTrue);
    final unknownState = (unknownEnvelope['occurrenceHistory'] as Map).values.single as Map;
    expect(unknownState['futureField'], 'must-not-disappear');
    File(root.path + '/command50-null-failure.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(nullEvidence),
    );
    File(root.path + '/command50-unknown-failure.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(unknownEvidence),
    );

    File(root.path + '/command50-verdict.txt').writeAsStringSync(
      'SOURCE_SNAPSHOT_CAPTURED=PASS\\n'
      'EXPECTED_ROWS_DERIVED_FROM_SOURCE_JSON=PASS\\n'
      'IDENTITY_BASED_SQL_COMPARISON=PASS\\n'
      'FIRST_INSTALL_BASE_MATRIX=PASS\\n'
      'STATUSES_PENDING_COMPLETED_CANCELLED_MISSED_SKIPPED=PASS\\n'
      'MULTIPLE_OCCURRENCES_PER_TASK=PASS\\n'
      'MULTIPLE_TASK_IDENTITIES=PASS\\n'
      'RECURRENCE_LINKED_AND_UNLINKED=PASS\\n'
      'RECURRENCE_LINK_IS_TASK_LEVEL=PASS\\n'
      'NULL_STORAGE_FOR_OMITTED_OPTIONAL_FIELDS=PASS\\n'
      'TIMESTAMP_BOUNDARIES=PASS\\n'
      'OCCURRENCE_OFFSET_PRESERVED_AS_TEXT=PASS\\n'
      'RECURRENCE_OFFSET_NORMALIZED_TO_UTC=PASS\\n'
      'UNKNOWN_TASK_LEVEL_FIELD_PRESERVED=PASS\\n'
      'TASK_STORE_READBACK_FIRST_CONNECTION=PASS\\n'
      'SECOND_INSTALL_AFTER_REOPEN=FAIL_CONFIRMED\\n'
      'EXPLICIT_NULL_OPTIONAL_KEYS=FAIL_CONFIRMED\\n'
      'UNKNOWN_OCCURRENCE_STATE_KEY=FAIL_CONFIRMED\\n'
      'FAILED_FIRST_TRANSFER_ROLLBACK_AND_SOURCE_PRESERVATION=PASS\\n'
      'OVERALL=BLOCKED_HISTORICAL_V19_OCCURRENCE_CODEC\\n',
    );  });
}
