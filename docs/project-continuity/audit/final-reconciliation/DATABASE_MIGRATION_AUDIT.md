# DATABASE / SQLITE MIGRATION AUDIT
Main source: 45e4202b03a434459e4c021a04efa7e8396359db  
Canonical source inspected: d3a82ebe0e517a2ae4a3b58d32ea4c86cbc53d92  
Owner target: v7 → v9  
Status: BLOCKED — NOT ACCEPTED

## Observed schema versions
- Main lib/services/g1_drift_schema.dart: G1DriftSchema.version = 7.
- PR #3495 lib/services/g1_drift_schema.dart: G1DriftSchema.version = 9.
- Canonical code imports g1_rev10_hierarchy_v9_migration.dart.
- G1Rev10HierarchyV9Migration.sourceSchemaVersion = 8; target = 9.
- Migration marker: rev10_hierarchy_schema_version.

## P0 migration sequence gap
The v9 migration class documents and declares v8→v9. The canonical installer performs a group of additive CREATE TABLE IF NOT EXISTS / ALTER TABLE operations before invoking the v9 migration, but that v7→v8 work is not represented as a separately versioned, auditable migration stage in the inspected source. The sourceSchemaVersion constant is not used to verify a formal v8 source marker before migration. Therefore the required v7→v9 chain is not yet proven as an explicit sequential migration contract.

## v9 hierarchy operations observed
- Creates centers, center_projects, categories, project_categories and arvin_migration_exceptions.
- Uses foreign keys and unique relation pairs.
- Preserves legacy project_items and legacy fields while adding normalized hierarchy relations.
- Records unresolved mapping exceptions rather than inventing missing Center/Project/Category edges.
- Uses a transaction with rollback and a marker write.
- Enables and checks PRAGMA foreign_keys.

## Data-preservation risks requiring evidence
- Prove IDs, explicit NULL, absent keys, FALSE/TRUE, unknown top-level and nested fields, legacy metadata, Reminder/Follow-up history, checklist, occurrences, People and tombstones.
- Prove no stale envelope values overwrite normalized SQL values.
- Prove migration retry, idempotency, close/reopen, foreign-key integrity and rollback from a real Main-derived v7 file.
- Prove no duplicate/orphan relationship rows and no inferred taxonomy links from names or Task text.
- Do not import v19/v20 migration scripts as the active path under the latest owner command.

## Backup / Restore
test/independent_sqlite_backup_restore_test.dart exists and exercises file-backed Database A, portable backup, independent Database B, repeated restore and injected rollback. PR #3620/#3634 describe further coverage for a distinct second physical backup file. The current exact-SHA test suite is failing elsewhere and this audit has not observed a complete green run proving this test and every required parity assertion.

## Required next work
1. Define and implement explicit v7→v8 migration (or prove the existing installer is the formally versioned v7→v8 stage with a persisted marker and source guards).
2. Verify explicit source schema and migration markers; reject unsupported versions safely.
3. Build real v7 fixture from Main schema and seed NULL/unknown/M2M/history/tombstone cases.
4. Run v7→v8→v9 on physical file; close/reopen; rerun; compare every row/ID/field/relation.
5. Inject failure at each transactional stage; prove rollback/retry.
6. Run independent A→B restore, distinct second backup, repeated restore and rollback.
7. Only then accept v7→v9. No production user database was touched.