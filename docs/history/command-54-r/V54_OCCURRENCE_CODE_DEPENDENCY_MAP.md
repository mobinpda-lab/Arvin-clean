# COMMAND 54-R — Occurrence Code Dependency Map

**Historical pin:** `310c0e20e3447c488c1e1c102c38bea5040708ca`

## Primary files and verified blobs

| File | Blob | Role |
|---|---|---|
| `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | Schema v19, transaction, installer call site |
| `lib/services/occurrence_sql_codec.dart` | `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` | Occurrence migration, SQL read/write, parity |
| `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` | Legacy JSON decode/encode, occurrence model fields |
| `lib/services/task_store.dart` | `625f7b24523e621adba7ae7a59e4c3e13c272a09` | Runtime entry, Task readback and writes |
| `lib/services/recurrence_sql_codec.dart` | `29ee7c0c778d99135daf376ba19f7773e4760ce4` | Adjacent recurrence migration and normalized recurrence read/write |
| `lib/models/recurrence.dart` | `470418b9d76f66117a9e6b3c9372a0856c01fd17` | Status enum, recurrence model |

## Exact source locations (line numbers at the pinned V19 blob)

- Schema version and `schemaVersion`: `g1_drift_schema.dart:11-16`.
- Serialized installer and `ensureOpen` / transaction setup: `g1_drift_schema.dart:108-132` (installer body continues below).
- Occurrence migration invocation: `g1_drift_schema.dart:242`.
- Occurrence codec ID and writer: `occurrence_sql_codec.dart:15-86`.
- Occurrence SQL readback: `occurrence_sql_codec.dart:88-115`.
- Legacy-envelope migration: `occurrence_sql_codec.dart:118-190`.
- Existing-row identity/content conflict check: `occurrence_sql_codec.dart:211-238`.
- Task occurrence decoding: `task.dart:553-581`; JSON serialization: `task.dart:626-649`.
- TaskStore install entry: `task_store.dart:796-816`.
- TaskStore load/readback: `task_store.dart:867-918` and `1002-1008`.
- TaskStore normalized write path: `task_store.dart:1304-1305`.

## Call graph

```text
TaskStore.load()
  └─ _loadUnlocked()
      └─ _ensureReady()
          └─ G1DriftSchema.install(executor)
              └─ _installSchema()
                  ├─ ensureOpen(G1DriftSchema)   [schemaVersion = 19]
                  ├─ CREATE TABLE / PRAGMA table_info / ALTER TABLE
                  ├─ migrateTaskPeople()
                  ├─ migrateCanonicalEntities()
                  ├─ _retireLegacyTaskColumns()
                  ├─ OccurrenceSqlCodec.migrateLegacyEnvelopes()
                  │   ├─ read tasks.legacy_payload_json
                  │   ├─ Task(occurrenceHistory, checklistOccurrences)
                  │   ├─ writeTask()
                  │   │   └─ _ensureOccurrence()
                  │   ├─ readTask()
                  │   ├─ canonical parity comparison
                  │   └─ remove old envelope keys after parity
                  ├─ RecurrenceSqlCodec.migrateLegacyRules()
                  ├─ foreign_key_check
                  └─ COMMIT / ROLLBACK

TaskStore._decodeTask()
  ├─ RecurrenceSqlCodec.readTask()
  └─ OccurrenceSqlCodec.readTask()

TaskStore._writeRelations()
  ├─ OccurrenceSqlCodec.writeTask()
  └─ RecurrenceSqlCodec.writeTask()
```

## Direct dependencies of OccurrenceSqlCodec
- Dart `dart:convert`: JSON and deterministic Base64URL occurrence ID encoding.
- Drift `QueryExecutor`: SQL operations.
- `models/task.dart`: constructs a Task-shaped transfer object and accesses occurrence maps.
- `models/recurrence.dart`: validates the allowed `RecurrenceOccurrenceStatus` values.

## Indirect/runtime dependencies
- `G1DriftSchema` owns the transaction and creates the two destination tables plus metadata table before invoking the codec.
- `TaskStore` invokes installation on the normal load path and invokes codec read/write for ongoing Task persistence.
- `RecurrenceSqlCodec` runs immediately after Occurrence transfer and shares the enclosing installer transaction.
- The Task model decoders copy occurrence state maps and serialize them back into JSON maps. That model-level copying does not provide normalized SQL storage for unknown nested occurrence keys.

## Identity, conflict and data-shape rules
- Occurrence ID: deterministic Base64URL encoding of `taskId|scheduledAt`, prefixed `occ-`.
- Table constraint: unique `(task_id, scheduled_at)`.
- Existing rows are checked for ID, status, completed_at, result and ordinal equality; mismatches throw a conflict.
- Checklist rows are checked by ordinal and value; a mismatch throws.
- The codec currently has no receipt table/key for Occurrence migration.
- The codec's SQL projection only includes scheduled timestamp, status, completion timestamp, result and ordinal. It has no opaque JSON payload or key-presence metadata for optional NULL fields.

## Important distinction
Task-level unknown JSON fields and nested Occurrence-state unknown fields are different preservation problems. The Task model's legacy metadata handling must not be treated as proof that unknown keys inside each Occurrence state map survive SQL normalization.
