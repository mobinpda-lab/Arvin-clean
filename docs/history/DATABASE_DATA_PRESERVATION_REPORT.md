# DATABASE DATA PRESERVATION REPORT — COMMAND 40-R
**Status:** NOT PROVEN — NO DATA-LOSS ACCEPTANCE  
**Policy:** preserve all valuable records and IDs; no production migration was run.

## Evidence available
- Main v7 schema defines text primary keys for Task, Follow-up, Project, Tag, Person and metadata records, with composite keys on relation tables.
- Main v7 `project_items`, `task_tags`, `checklist_items`, `task_people` and `follow_up_people` have relational keys; exact cascade/delete semantics require complete PRAGMA/source extraction.
- PR #3384 v19 code includes a `task_reminders` rebuild that snapshots selected columns, recreates the table without `is_legacy_task_reminder`, copies rows, compares row counts and selected values, then drops the temporary table.
- PR #3384 v19 code includes a Task rebuild that copies a canonical projection to `tasks__canonical_v19`, compares row counts and values, then drops and renames tables. The implementation defers retirement if it detects unknown columns, custom indexes, triggers, constraints or outgoing foreign keys.
- The same source preserves explicit JSON key presence for legacy reminder/follow-up fields and merges Follow-up metadata rather than blindly replacing an existing record.
- PR #3463 description documents proposed D01–D05 tests including independent SQLite-file restore and injected failure points, but explicitly says those suites were not accepted until exact-SHA workflows complete.

## Not proven
- No exact v7→v20 file-backed migration was executed in this COMMAND 40-R run.
- No real source fixture with named test IDs was migrated and compared.
- No complete before/after row-count or field-by-field preservation matrix exists for versions 7–20.
- No full FK/orphan/unique validation across all historical edges was run.
- No complete retry, rollback, interruption or crash-recovery proof was produced here.
- No independent production backup/restore round trip was performed.
- No claim is made that any historical destructive step is lossless.

## Preservation gate
Before destructive retirement, capture each source table's row count, primary-key set, complete field mapping, relation mapping, unresolved-exception inventory and recovery artifact. After migration compare all values and IDs, run `PRAGMA foreign_key_check` and `PRAGMA integrity_check`, then repeat after close/reopen and retry. Any mismatch is FAIL; missing evidence is BLOCKED.

**Result: BLOCKED.** No valuable record is authorized for deletion.
