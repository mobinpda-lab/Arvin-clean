# DATABASE MIGRATION HISTORY — COMMAND 41-R
**Status:** PARTIAL HISTORICAL RECONSTRUCTION — NO UPGRADE PATH ACCEPTED  
**Reference canonical HEAD:** `f5c64285687cd2665cc383e10277cb6e0266f4c2`  
**Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`

## Historical Schema source index
The exact commit and blob ledger for versions 7–20 is in [DATABASE_SOURCE_EVIDENCE.md](DATABASE_SOURCE_EVIDENCE.md). Version sources found:

| Version | Commit short | Main source lineage / note |
|---:|---|---|
| 7 | `5e974519` | Main baseline, schema version 7 |
| 8 | `874dd8b5` | Centers, project templates and project template tasks |
| 9-A | `708c112a` | Task Template lineage |
| 9-B | current canonical #3495 | REV10 hierarchy v8→v9 migration; separate lineage |
| 10 | `00e3d800` | Template context snapshots |
| 11 | `96651f76` | Template checklist_enabled |
| 12 | `01238b00` | Canonical Reminder, Follow-up record and Person tables |
| 13 | `7bcd2182` | Retires legacy Follow-up and People tables after transfer |
| 14 | `102e7d4f` | Rebuilds Tasks to remove retired scheduling columns |
| 15 | `1313c3e5` | Task-person canonicalization and another Task rebuild |
| 16 | `0b5df95f` | Occurrence, checklist occurrence and recurrence rule tables |
| 17 | `e12d86c7` | recurrence_json and recurrence conversion |
| 18 | `bceadc8f` | task_reminders rebuild |
| 19 | `3bede0d3` | canonical installer, data transfer and legacy column retirement |
| 20 | `81208296` | additive Center↔Project and Project↔Category M2M migration |

## Lineage finding
Git ancestry confirms the v7 Main commit is an ancestor of v8, v9-A and v19. The v20 PR head is descended from v19. However, the current canonical #3495 HEAD is not on that v20 line: Git compare reports a diverged history with Main as merge base. It contains the distinct v9-B migration instead.

Therefore:
- Historical v9-A→v10→…→v19→v20 is a real Git source lineage.
- v9-B is a different schema-9 source and is not proven to be a continuation of v9-A.
- A sequential Git lineage is not proof that a physical Main v7 database can execute each operation without data loss.
- No Main v7→v20 upgrade is accepted until exact SQLite fixture execution proves it.

## Historical destructive operations found
- v13: `follow_up_people`, `follow_ups`, `people` are dropped after transfer.
- v14: `tasks` is dropped and `tasks_canonical_v14` renamed to `tasks`.
- v15: `task_people` is dropped; `tasks` is rebuilt again.
- v18: `task_reminders` is renamed, recreated, copied, compared and retired.
- v19: repeats reminder and Task rebuild/retirement safeguards and transfers legacy entities.
- v20: adds junction tables and Task FK columns; it keeps v19 source membership tables.

**Result: BLOCKED.** Full literal DDL and exact supported edge proofs remain outstanding.
