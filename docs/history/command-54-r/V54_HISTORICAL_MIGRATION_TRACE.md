# COMMAND 54-R — Historical Migration Trace

**Disposition:** TRACE COMPLETE / READ-ONLY. No migration was executed and no application source was changed.
**Historical source pin:** `310c0e20e3447c488c1e1c102a2fbd85b8697c` (as recorded by COMMAND 50 forensic reports)
**V19 schema blob:** `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`
**V19 Occurrence codec blob:** `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e`

## 1. Historical version and entry point
At the pinned historical source:
- `lib/services/g1_drift_schema.dart` defines `G1DriftSchema.version = 19` and returns it from `schemaVersion`.
- `G1DriftSchema.install(QueryExecutor)` serializes installation per executor using an `Expando<Future<void>>`, then calls private `_installSchema`.
- `_installSchema` calls `executor.ensureOpen(G1DriftSchema())`, creates missing tables with `CREATE TABLE IF NOT EXISTS`, inspects existing columns with `PRAGMA table_info`, and adds missing columns with `ALTER TABLE`.
- The installer opens one explicit transaction with `BEGIN`. It invokes the Occurrence transfer inside that transaction, checks `PRAGMA foreign_key_check`, commits on success, and attempts `ROLLBACK` on error. Foreign keys are re-enabled after commit or rollback.

This is not evidence of a sequence of individually invoked migration classes named V7→V8→…→V19. In the inspected execution path, compatibility is performed by the version-19 schema installer using table/column introspection and additive DDL. The V7 fixture is a historical source fixture, not proof that every customer's database has identical version metadata or shape.

## 2. Exact Occurrence call site
In `lib/services/g1_drift_schema.dart`, the ordered installer calls include:
1. `migrateTaskPeople(executor)`
2. `_removeLegacyTaskReminderMarker(executor)`
3. `migrateCanonicalEntities(executor)`
4. `_retireLegacyTaskColumns(executor)`
5. `OccurrenceSqlCodec.migrateLegacyEnvelopes(executor)`
6. `RecurrenceSqlCodec.migrateLegacyRules(executor)`

The Occurrence call is therefore part of the V19 schema installation transaction, after legacy Task-column retirement and before recurrence migration.

## 3. Runtime route used by TaskStore
`TaskStore._ensureReady()` calls `G1DriftSchema.install(executor)` before it checks the legacy SharedPreferences migration marker. The same path is reached from `TaskStore._loadUnlocked()`, which is used by `load()`. Consequently, opening/reading through TaskStore reaches the schema installer; this is not merely a one-time test helper.

After installation:
- `TaskStore._decodeTask` calls `OccurrenceSqlCodec.readTask(executor, taskId)` and injects normalized history/checklists into the Task envelope.
- `TaskStore._writeRelations` calls `OccurrenceSqlCodec.writeTask(executor, task)` for Task writes.

If the legacy SharedPreferences migration is incomplete, TaskStore separately calls `SqlTaskMigrationWriter.migrateFromPreferences` after schema installation. This is a distinct import route; it does not replace the V19 SQL-envelope migration call.

## 4. Source and destination representation
Legacy source: `tasks.legacy_payload_json`, with `occurrenceHistory` keyed by scheduled timestamp and optional `checklistOccurrences` keyed by the same timestamp.

V19 destination:
- `task_occurrences(id, task_id, scheduled_at, status, completed_at, result, ordinal)`
- `occurrence_checklist_items(occurrence_id, ordinal, value)`

The destination identity is deterministic from Task ID + scheduled timestamp. There is no independent legacy Occurrence ID in the recorded source shape.

## 5. Re-entry and parity behavior
The codec selects Task envelopes and reads the two source keys. It builds maps, writes/validates normalized rows, reads them back, compares canonical JSON, and removes the legacy keys only after parity. On a later installer invocation, a Task whose source keys were retired still has destination rows; the codec nevertheless compares those rows with empty source maps. COMMAND 50 physically reproduced the resulting retry failure.

The codec readback emits `completionDate` and `result` only when SQL values are non-NULL. Thus explicit NULL keys are not reconstructed. Unknown per-occurrence state keys have no corresponding SQL columns or opaque occurrence payload and are not reconstructed. These are parity failures, not evidence that the negative-fixture source was silently committed as deleted: the forensic report records rollback and source retention for those negative cases.

## 6. Scope boundary
This trace establishes the V19 execution path from the pinned source and file blobs. It does not establish that all deployed user databases are byte-identical to the V7 fixture, nor does it execute an upgrade, inspect production data, or approve a repair. The active investigation branch's current schema-v9 tree is a different source state and must not be substituted for the historical V19 source when implementing or testing the repair.
