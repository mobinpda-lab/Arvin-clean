# WAVE 4 — P0-C Implementation Report

**Repository:** mobinpda-lab/Arvin-clean  
**Working branch:** fix/recovery-calendar-device-smoke-2026-10-31  
**PR:** #3052 — OPEN / DRAFT / UNMERGED  
**Implementation checkpoint SHA:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`  
**Status:** PARTIAL — source changes committed; exact-SHA CI still pending  
**Release:** BLOCKED — NO-GO

## Implemented in source

1. Task preference migration now validates target row count, ordered IDs, storage ordinals, scalar fields, unknown-field envelope parity, TaskReminder rows, Follow-up history, checklist rows, Task-Person links, Task-Tag links, Follow-up-Person links, and SQLite foreign-key integrity before COMMIT.
2. Existing Task IDs are no longer treated as proof of equivalence. Existing rows are skipped only after content and relation parity succeeds; conflicting content throws and rolls back.
3. The post-COMMIT ID-only validator was removed from TaskStore; the full validation now runs inside the migration transaction.
4. Destructive schema retirement paths were disabled: legacy Follow-up/People/Task-People tables are retained, the Task-table rebuild is no longer invoked, and the legacy Reminder-table rebuild is no longer invoked.
5. ProjectStore now delegates legacy preference migration to SqlProjectMigrationWriter. Project migration validates metadata, envelope/unknown fields, membership order, row count, ID order, and foreign keys before COMMIT.
6. Projects now have relational `storage_ordinal`; ProjectStore reads and writes order through that column.
7. ProjectStore save preserves unknown Project envelope fields across a normal update rather than silently discarding them.
8. Recurrence definitions now have a normalized `task_recurrence_rules` table and a migration/read/write codec.
9. Occurrence history and per-Occurrence checklist state now have independent relational tables: `task_occurrences` and `occurrence_checklist_items`. Stable occurrence IDs are derived from Task ID and scheduled timestamp.

## Tests added or updated

- Task migration: same ID with different content is a conflict.
- Project migration: same ID with different content is a conflict.
- Project ordering and unknown-field retention.
- Occurrence history and per-occurrence checklist relational round-trip.
- Recurrence relational round-trip.
- Schema tests assert the new relational tables and that legacy sources remain present.

## Still incomplete / blocked

- `G1DriftSchema.migrateCanonicalEntities` still needs full field-by-field conflict/parity checks for every legacy Follow-up, Person and relation before any future retirement.
- The entire multi-source migration is not yet one transaction spanning Task preferences, Project preferences, schema upgrades and all other stores.
- Backup/Restore coverage for all approved persistent entities is not yet proven.
- JSON envelopes, template JSON columns and several SharedPreferences owners remain.
- CI, integration tests and Android Device Smoke have not yet completed on this checkpoint SHA.

No legacy source was physically deleted. No tests were removed, skipped, bypassed or weakened. No Main, merge or release action was performed.
