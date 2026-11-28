# DATABASE ID PRESERVATION REPORT — COMMAND 42-R
**Status:** BASELINE SNAPSHOT COMPLETE / AFTER-MIGRATION COMPARISON BLOCKED
## Before-migration stable IDs
| Entity | IDs |
|---|---|
| Tasks | `task-active-001`, `task-done-002` |
| Project | `project-001` |
| Follow-up | `followup-001` |
| Person | `person-001` |
| Tag | `tag-001` |
## Other identity-bearing relations
- `project_items`: (`project-001`, `task-active-001`), (`project-001`, `task-done-002`)
- `task_people`: (`task-active-001`, `person-001`)
- `task_tags`: (`task-active-001`, `tag-001`)
- `follow_up_people`: (`followup-001`, `person-001`)
## Evidence boundary
These values are recorded from the physical v7 fixture before migration. Since no historical Dart migration has been run, there is no after-state to compare. ID preservation is therefore NOT PROVEN. A migration test must compare complete identity sets and relation keys, not merely row counts.
