import 'package:drift/drift.dart';

/// Additive, marker-versioned support for explicit Person Directory removal.
///
/// Task and Follow-up references remain historical snapshots. This table only
/// records that the owner removed a Person from the standalone directory, so
/// the legacy hydrator cannot silently recreate that directory entry.
class G1PersonDirectoryExclusionV1Migration {
  const G1PersonDirectoryExclusionV1Migration();

  static const String markerKey = 'person_directory_exclusions_v1';
  static const String tableName = 'person_directory_exclusions';

  Future<void> migrate(QueryExecutor executor) async {
    final markers = await executor.runSelect(
      'SELECT value FROM arvin_storage_meta WHERE key = ?',
      <Object?>[markerKey],
    );
    if (markers.isNotEmpty) {
      if (markers.single['value'] == '1') {
        final table = await executor.runSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          <Object?>[tableName],
        );
        if (table.isEmpty) {
          throw StateError('Person Directory exclusion marker exists without its table.');
        }
        return;
      }
      throw StateError('Unexpected Person Directory exclusion migration marker.');
    }

    await executor.runCustom('BEGIN');
    try {
      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS person_directory_exclusions (
          person_id TEXT NOT NULL PRIMARY KEY,
          excluded_at TEXT NOT NULL
        )
      ''');
      await executor.runInsert(
        'INSERT INTO arvin_storage_meta (key, value) VALUES (?, ?)',
        <Object?>[markerKey, '1'],
      );
      await executor.runCustom('COMMIT');
    } catch (_) {
      try {
        await executor.runCustom('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }
}
