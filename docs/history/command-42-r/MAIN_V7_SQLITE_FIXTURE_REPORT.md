# MAIN V7 SQLITE FIXTURE REPORT — COMMAND 42-R
**Disposition:** FIXTURE CREATED / MIGRATION NOT RUN
**Main commit:** `45e4202b03a434459e4c021a04efa7e8396359db`
**Schema blob:** `cd065ff25c680ed064e89068b3d063e737091025`
**Fixture:** `test/fixtures/database/historical/main_v7_fixture.sqlite.gz` (gzip archive of a real SQLite database)
**Uncompressed SHA-256:** `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`
**Uncompressed size:** 106,496 bytes
**Creation/runtime SQLite:** Python sqlite3 / SQLite 3.46.1. This is not a claim about Android's bundled SQLite version.
## Provenance
The DDL was transcribed from the exact Main v7 `G1DriftSchema._statements` and the fixture uses only the 12 tables declared there. No schema objects were invented to make later versions appear present.
## Seeded deterministic records
- Tasks: `task-active-001`, `task-done-002`
- Project: `project-001`
- Follow-up: `followup-001`
- Person: `person-001`
- Tag: `tag-001`
- Checklist rows: 2
- Project membership rows: 2
- Task-person, Task-tag and Follow-up-person links: 1 each
- Category and storage metadata marker: 1 each
Total: 14 rows across 12 tables.
The active Task contains legacy reminder date, recurrence JSON, NULL values, and unknown extension keys in JSON payloads. The person JSON also includes an unknown field.
## Snapshot counts
| Table | Rows |
|---|---:|
| arvin_storage_meta | 1 |
| checklist_items | 2 |
| follow_up_people | 1 |
| follow_ups | 1 |
| people | 1 |
| project_items | 2 |
| projects | 1 |
| tags | 1 |
| task_people | 1 |
| task_tags | 1 |
| tasks | 2 |
| taxonomy_categories | 1 |
## Verification performed
- Database closed and reopened.
- `PRAGMA integrity_check`: `ok`.
- `PRAGMA foreign_key_check`: zero rows.
- Stable Task IDs re-read after reopen.
## Explicit limits
Main v7 has no `task_templates` / `project_templates` tables and no dedicated `task_reminders` table. Reminder information is represented in legacy Task columns/JSON. The fixture therefore does not fabricate Template or normalized Reminder rows. Templates and normalized Reminder rows must be introduced only by the exact historical installer/migration that owns them.
This fixture proves only that a physical Main v7-shaped SQLite file was created and its initial structure/data are readable and internally consistent. It does not prove migration, ID preservation after migration, or rollback/recovery.
