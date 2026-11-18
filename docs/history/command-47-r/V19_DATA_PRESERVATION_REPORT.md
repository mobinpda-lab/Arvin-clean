# V19 Data Preservation Report — Updated Evidence

**Status: FIXTURE-LEVEL PRESERVATION ASSERTIONS PASS; FULL COMMAND 47 ACCEPTANCE PENDING RETRY/RECOVERY.**

The original v19 Installer was run on an independent copy of the approved fixture. The tracked source fixture was not modified.

## Fixture-level identity and row preservation

| Entity / relation | Before | After / canonical target | Result |
|---|---:|---:|---|
| Task IDs | 2 | 2 | PASS |
| Project IDs | 1 | 1 | PASS |
| Follow-up IDs | 1 | 1 | PASS |
| Person IDs | 1 | 1 | PASS |
| Tag IDs | 1 | 1 | PASS |
| Checklist rows | 2 | 2 | PASS |
| Task-Person rows | 1 | 1 | PASS |
| Follow-up-Person rows | 1 | 1 | PASS |
| Task-Tag rows | 1 | 1 | PASS |
| Project-Task rows | 2 | 2 | PASS |

The corrected runner compares Task core SQL columns, retained source-table rows and canonical relation projections. It verifies the migrated Follow-up ID, Person identity set, Task-Person links, Follow-up-Person links, Checklist, tags and project membership.

## Migrated values

- Legacy Task reminder materialized as `legacy-task-reminder-task-active-001`.
- Recurrence rule materialized for `task-active-001`.
- Follow-up record retained ID `followup-001` and its historical timestamp.
- Legacy next-follow-up value retained in compatibility metadata.
- Task, Project, Person and Recurrence unknown fixture values remain in their raw/compatibility sources.
- Task core SQL fields, including completed state, completion timestamp, priority, description and timestamps, compare equal before/after.
- Source fixture SHA remains the approved value; only the separate working copy was mutated.

## Important qualification

The v19 installer generates some default values in the duplicated Task JSON envelope that differ from SQL-owned Task columns. The historical TaskStore read path overwrites those envelope keys from SQL before model decoding. This is recorded as E48-001 and is not counted as SQL-row data loss. Do not consume those duplicated envelope keys outside the canonical TaskStore read boundary.

The fixture contains no occurrence-history rows; non-empty occurrence transfer is therefore not proven by this fixture.

## Remaining work

Retry/idempotency and controlled failure/backup recovery remain untested. No claim of complete COMMAND 47 acceptance is made.
