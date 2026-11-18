# DATABASE HISTORICAL DDL — COMMAND 40-R
**Status:** PARTIAL DDL INVENTORY — NOT COMPLETE  
**Reference HEAD:** `6005fb58f6c40db404353cf695445726e933d5cd`

## Main schema v7 — verified DDL inventory
Source: `main:lib/services/g1_drift_schema.dart`, blob `cd065ff25c680ed064e89068b3d063e737091025`. The file's `_statements` list creates:

| Table | Primary key / uniqueness | Foreign keys and notable columns |
|---|---|---|
| tasks | `id TEXT PRIMARY KEY` | storage_ordinal, title, description, dates, follow-up/reminder flags, category, priority, completed, recurrence_json, legacy_payload_json |
| follow_ups | `id TEXT PRIMARY KEY`; UNIQUE(task_id, ordinal) | task_id → tasks(id); date_time, title, note, result, reminder_date, next_follow_up, completed, waiting_for_response |
| projects | `id TEXT PRIMARY KEY` | name, color_value, is_archived, legacy_payload_json |
| project_items | PRIMARY KEY(project_id, task_id) | project_id → projects(id); task_id → tasks(id); ordinal |
| taxonomy_categories | `name TEXT PRIMARY KEY` | created_at |
| tags | `id TEXT PRIMARY KEY` | name |
| task_tags | PRIMARY KEY(task_id, tag_id) | task_id → tasks(id); tag_id → tags(id); ordinal |
| checklist_items | PRIMARY KEY(task_id, ordinal) | task_id → tasks(id); value |
| task_people | PRIMARY KEY(task_id, person_id) | task_id → tasks(id); person_id plus person_json snapshot |
| people | `id TEXT PRIMARY KEY` | name, created_at, updated_at |
| follow_up_people | PRIMARY KEY(follow_up_id, person_id) | follow_up_id → follow_ups(id); person_id stored as relation value |
| arvin_storage_meta | `key TEXT PRIMARY KEY` | key/value migration markers |

The source also conditionally ALTERs tasks, follow_ups and projects and performs task-person backfill. It is an installer/reconciliation routine, not proof of a complete sequential upgrade ledger. Exact conditional ALTER statements still require a full transcription.

## Version 9 sources — separate lineages
- Legacy v9 Task Template source: commit `708c112a82c753f1dcdb77f1cf9712a6336a725d`, schema blob `617c05e4416bede903e78b65bd32a839d2d7c65a`.
- Canonical REV10 v9 source: schema blob `3bd140f9a07b54c1e4a1dff26d64f965b437ec52`; separate migration blob `f9569182a1d79a116e1e1f4c400e69f7c47863b4`. Its header describes additive migration from live G1 v8 to REV10 relationship-graph v9 and retaining legacy tables/text fields until dependent readers/writers/backups migrate.
- These two v9 sources are not assumed compatible or sequential.

## v19/v20 DDL source references
- v19: PR #3384 schema blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
- v20: PR #3463 schema blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`; migration source is `lib/services/g1_many_to_many_hierarchy_migration.dart` in that PR.
- PR #3384 patch shows conditional Task-column additions and table rebuilds for `task_reminders` and `tasks`; rebuilds copy selected rows, compare counts/values, then drop/rename tables. These are destructive operations and cannot be accepted from source inspection alone.
- PR #3463 complete CREATE/ALTER/index/trigger DDL has not yet been fully transcribed here.

## Explicit omissions
Complete DDL for every version 7–20, all index definitions, FK actions, triggers, ALTER/rebuild operations and complete data-copy/delete mappings are not yet present. No completeness claim is made.

**Result: BLOCKED.** Continue exact source extraction; do not execute destructive operations.
