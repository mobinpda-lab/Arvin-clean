import 'package:drift/drift.dart';

/// Adds a durable tombstone for people explicitly removed from the active
/// directory. The tombstone is intentionally not foreign-keyed to persons:
/// historical task/follow-up references and future migrations must be able to
/// remember an exclusion even if a Person row is temporarily absent.
class G1PersonDirectoryExclusionV1Migration {
  static const String migrationKey = 'person_directory_exclusions_v1';

  Future<void> migrate(QueryExecutor executor) async {
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS person_directory_exclusions (
        person_id TEXT NOT NULL PRIMARY KEY,
        excluded_at TEXT NOT NULL
      )
    ''');

    final marker = await executor.runSelect(
      'SELECT value FROM arvin_storage_meta WHERE key = ?',
      const <Object?>[migrationKey],
    );
    if (marker.isNotEmpty) return;

    await executor.runCustom(
      'INSERT OR REPLACE INTO arvin_storage_meta (key, value) VALUES (?, ?)',
      const <Object?>[migrationKey, '1'],
    );
  }
}
