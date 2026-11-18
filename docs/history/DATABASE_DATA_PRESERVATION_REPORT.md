# DATABASE DATA PRESERVATION REPORT — COMMAND 41-R
**Status:** NOT PROVEN — NO DATA-LOSS ACCEPTANCE  
**Production data:** Not accessed or modified.

## Destructive operations and preservation controls found in source
### v13 — legacy Follow-up and People retirement
Source: `7bcd218254c7931a766bdd091bb3d39483c1888e`, `lib/services/g1_drift_schema.dart`, lines 218–367.
- Copies legacy People into canonical `persons`.
- Copies legacy Follow-up rows into `follow_up_records`.
- Copies Follow-up/Person links into `follow_up_record_people`.
- Converts old reminder schedules into `task_reminders`.
- Drops `follow_up_people`, `follow_ups`, `people` at lines 361, 364, 367.
- Potential risk: malformed legacy rows, duplicate IDs, missing Person references or failed/partial source mappings. The transaction and fixture must prove all source IDs and relation rows survive before table retirement.
- Rollback/retry: source code has transactional installation; no independent v13 physical-file failure/retry proof retrieved in this run.

### v14 and v15 — Task and Task-person rebuilds
Sources: v14 commit `102e7d4f...`, v15 commit `1313c3e5...`.
- v14 builds `tasks_canonical_v14`, copies a selected Task projection, then drops/renames Tasks at lines 409–421.
- v15 copies `task_people` into `task_persons`, drops `task_people` at line 266, and rebuilds Tasks again at lines 455–467.
- Potential risk: fields omitted from the projection, unknown columns, custom indexes/triggers, outgoing/incoming FK behavior and unrecognized data shapes.
- IDs are included in the canonical projection, but full ID/value preservation has not been tested from a Main v7 physical fixture.

### v18 — Reminder table rebuild
Source: `bceadc8f...`, lines 351–439.
- Captures selected reminder columns before rebuild.
- Renames old table, creates canonical table, copies id/task_id/title/remind_at/is_all_day/sequence/is_enabled.
- Compares row counts and every selected canonical value.
- Drops retired table.
- Risk: noncanonical extra columns, indexes/triggers or unselected data are not represented in the copied projection; exact guard behavior and rollback need fixture tests.

### v19 — canonical entity transfer and rebuild
Source: `3bede0d3...`, blob `9f0243df...`.
- Installer temporarily disables FK enforcement during the transaction and checks FK violations before commit.
- Transfers legacy People, Task People, Follow-ups and Reminder information into canonical tables.
- Preserves explicit JSON missing/NULL/FALSE/TRUE states in the Task envelope.
- Reminder rebuild compares selected columns before/after.
- Task rebuild preserves the declared canonical projection and fails closed on unknown columns, custom indexes, triggers or outgoing foreign keys; legacy scheduling fields are copied into JSON before retirement.
- Risk: preservation is proven only for the selected projection and covered fixture cases, not all possible production shapes.

### v20 — M2M hierarchy
Source: `81208296...`, `lib/services/g1_many_to_many_hierarchy_migration.dart`.
- Adds `center_projects`, `categories`, `project_categories`, three optional Task FK columns, indexes and compatibility triggers.
- Uses stable generated IDs for legacy categories.
- Copies only valid source relationships; ambiguous or missing links are written to an exception table.
- Does not delete v19 source membership tables.
- Risk: unresolved relationship exceptions remain intentionally unresolved; no claim of semantic relationship parity for every Task.

## Existing test evidence (not Main v7 acceptance)
- PR #3463 exact SHA `812082964c649be7660c41213209ec34aea7167b`: v20 lifecycle and historical parity workflow passed; tests include injected failure stages and independent physical SQLite backup/restore.
- Same historical SHA: A-D SQLite snapshot workflow passed five real reopen cycles.
- These results are not evidence for Main v7→v20 or current #3495 HEAD because the source branch is diverged and its base is not the same tested commit.

## Current exact canonical SHA
At `f5c64285687cd2665cc383e10277cb6e0266f4c2`:
- Build failed: two test shards failed.
- One failure is `g1_drift_schema_test.dart` v8→v9 test; test setup attempted an executor operation before `ensureOpen()`.
- Another failure is a Person Directory UI assertion.
- COMMAND 20-E storage-persistence phase passed, but final evidence acceptance failed and reported NO-GO.
- Follow-up file persistence and Device Smoke passed.
- No historical Main v7 fixture or v7→v20 migration test was run.

**Result: BLOCKED.** No record or identifier is certified as preserved across the full historical path.
