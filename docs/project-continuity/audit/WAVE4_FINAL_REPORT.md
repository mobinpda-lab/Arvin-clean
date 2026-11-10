# ARVIN REV8 — WAVE 4 FINAL REPORT

**Product Owner:** Mobin  
**Repository:** mobinpda-lab/Arvin-clean  
**Working Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052  
**Implementation Candidate SHA:** `271633dcf1793773738097ad6021ceca98ad1784`  
**Base Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Status:** `PARTIAL — BLOCKED — NOT COMPLETE`  
**Release:** `BLOCKED — NO-GO`

## 1. Executive decision

WAVE 4 has made real source/schema/test changes, but the full SQL-only consolidation and all owner acceptance criteria are not proven. WAVE 4 MUST NOT be marked COMPLETE. PR #3052 remains OPEN / DRAFT / UNMERGED. Main was not modified. No merge, release, force push or history rewrite was performed.

## 2. Implemented source changes

### Task migration
- Added pre-COMMIT validation for row count, ordered IDs/storage ordinals, scalar fields, unknown/non-SQL envelope fields, reminders, Follow-up history, checklist items, people/tags relations, Recurrence and Occurrence relations, and foreign keys.
- Same ID with different content is a conflict; it is no longer skipped based only on ID.
- Removed the old post-COMMIT ID-only validator.
- New Task envelopes omit fields now owned by SQL relations/columns.

### Project migration
- ProjectStore now uses SqlProjectMigrationWriter as the single preference migration path.
- Added relational `projects.storage_ordinal`.
- Added metadata, envelope/unknown-field, membership, order, row-count and foreign-key parity checks before COMMIT.
- ProjectStore preserves unknown fields during ordinary saves.

### Recurrence and Occurrence
- Added `task_recurrence_rules`.
- Added `task_occurrences`.
- Added `occurrence_checklist_items`.
- Added normalized Recurrence and Occurrence codecs, legacy conversion, TaskStore SQL reads/writes and round-trip tests.
- Bumped G1 schema version to 17 and added the missing legacy `recurrence_json` column upgrade.

### Legacy safety
- Disabled unproven legacy Follow-up/People table drops.
- Disabled the Task-table rebuild path and legacy Reminder-table rebuild path.
- Legacy sources remain available; no physical legacy source deletion was performed.

## 3. Changed source and test files

- `lib/services/sql_task_migration_writer.dart`
- `lib/services/task_store.dart`
- `lib/services/g1_drift_schema.dart`
- `lib/services/project_store.dart`
- `lib/services/sql_project_migration_writer.dart`
- `lib/services/occurrence_sql_codec.dart` (new)
- `lib/services/recurrence_sql_codec.dart` (new)
- `test/services/sql_task_migration_writer_test.dart`
- `test/services/sql_project_migration_writer_test.dart`
- `test/services/g1_drift_schema_test.dart`
- `test/sql_task_store_cutover_test.dart`

## 4. Tests added or updated

- Same Task ID with different content must fail.
- Same Project ID with different content must fail.
- Project ordering and unknown-field preservation.
- Occurrence history and per-occurrence checklist migration and round-trip.
- Recurrence rule relational round-trip.
- G1 schema assertions for new tables and version 17.
- Legacy source retention assertions.
- Task envelope assertions for SQL-owned fields.

**Results:** the exact candidate SHA `271633dcf1793773738097ad6021ceca98ad1784` had not completed its Build or Device Smoke workflows at the time this report was authored. No PASS is claimed for these new tests.

## 5. CI evidence

Candidate SHA `e036590a935d7c73ce5ea184ec1aeee70547146b`:
- Analyze failed due an unnecessary import; corrected in candidate SHA 271633.
- One Task Follow-up history test failed due envelope parity normalization; corrected in candidate SHA 271633.
- Ten other UI/widget test failures matched failures observed on the earlier P0-B baseline SHA `28abfa4390adbb7523eb003417f2007ea44e5293`; these were not introduced by the WAVE 4 source changes and were not weakened or skipped.
- Remaining test shards were cancelled when the branch advanced.

Candidate SHA `271633dcf1793773738097ad6021ceca98ad1784`:
- Build run `42866834521`: PENDING.
- Device Smoke run `42866834509`: PENDING.
- Follow-up File Persistence run `42866835166`: SUCCESS.
- G1 Lock Sync run `42866834996`: SUCCESS.
- Calendar Provider Acceptance run `42866834969`: IN PROGRESS.
- Draft Review APK run `42866835023`: IN PROGRESS.
- Orchestrator and Production Loop runs: SUCCESS.

No local Flutter, integration or Android test command was run in this session. Exact-SHA Build, full test shards and Device Smoke remain required.

## 6. P0 status

| P0 item | Result |
|---|---|
| ID-only validator | FIXED for Task migration |
| Validation after Commit | FIXED for Task and Project preference writers |
| skippedExisting without content comparison | FIXED for Task and Project |
| Legacy table deletion without parity | SAFE: destructive drops disabled; full parity still open |
| Task table rebuild field parity | SAFE: rebuild disabled |
| task_reminders rebuild parity | SAFE: rebuild disabled |
| ProjectStore / Project writer mismatch | FIXED |
| Unknown Project fields | PRESERVED across ProjectStore saves |
| Independent Occurrence ownership | IMPLEMENTED in SQL |
| Permanent JSON Envelope / Recurrence | PARTIAL; Recurrence/Occurrence moved, other JSON remains |

## 7. Remaining blockers

1. G1 legacy Follow-up, Person and relation migrations still need complete source/target field, duplicate, conflict, ordering and null/empty parity.
2. The entire migration is not yet one atomic, recoverable transaction across all stores and legacy sources.
3. Task/Project envelopes and template JSON columns remain; complete SQL-only ownership is not proven.
4. Settings, Calendar configuration, Prayer Completion and Notification State still require complete SQL ownership and migration.
5. Backup/Restore does not yet prove Center, Project Templates, Task Templates, Notification State, Prayer Completion, migration markers and all operational state.
6. Remote Sync was not changed because a complete product sync contract and durable implementation were not established by the reviewed source.
7. Four Reminder states and their transitions remain a Mobin decision; no contract was invented.
8. Exact-SHA Build, all test shards, integration tests and Android Device Smoke remain unverified.

## 8. Legacy retirement register

No legacy table, column, preference or JSON source was physically deleted. The retained sources include legacy Follow-up/People/Task-People tables, old Task scheduling columns, Reminder legacy layout/flag, Task and Project envelopes, recurrence legacy JSON, template JSON fields and SharedPreferences-backed operational state.

Retirement is blocked until complete parity, round-trip, backup/restore, rollback, independent tests and Mobin acceptance are all evidenced.

## 9. Criteria assessment

- SQL ownership for every persistent product entity: **NOT COMPLETE**
- Zero permanent parallel JSON: **NOT COMPLETE**
- One atomic/recoverable global migration: **NOT COMPLETE**
- Full parity across every entity: **NOT COMPLETE**
- Independent Occurrence and checklist: **IMPLEMENTED; CI PENDING**
- Complete Backup/Restore: **NOT COMPLETE**
- All tests on final candidate SHA: **PENDING**
- No weakened tests: **CONFIRMED — no test was deleted, skipped, bypassed or weakened in this execution**
- Canonical documents reconciled: **UPDATED; final head reconciliation pending**

## 10. Next wave

1. Complete candidate SHA Build and Device Smoke; inspect all test shards and repair failures without reducing test strength.
2. Add full parity/conflict validation to G1 legacy Follow-up, Person and relation migrations.
3. Complete one atomic migration coordinator with source/target snapshots, retry, rollback and crash recovery.
4. Normalize remaining Task/Project fields, template child data and SharedPreferences state.
5. Extend Backup/Restore to every approved persistent entity and prove round-trip after SQLite reopen.
6. Resolve the four Reminder states with Mobin.
7. Retire legacy sources only after every gate and explicit owner acceptance.
8. Keep PR #3052 unmerged and Release NO-GO until all acceptance criteria pass.

**FINAL STATUS: WAVE 4 PARTIAL / BLOCKED — NOT COMPLETE.**  
**ONE PRODUCT · ONE SQL SOURCE OF TRUTH · ZERO DATA LOSS · FULL TEST INTEGRITY.**
