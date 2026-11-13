# SQL-ONLY Consolidation Report — WAVE 4

**Authority:** Mobin — Product Owner  
**Checkpoint SHA:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`  
**Status:** PARTIAL / NOT VERIFIED  
**Release:** BLOCKED — NO-GO

## Confirmed SQL ownership

The reviewed schema and current changes establish relational SQL ownership for Tasks, Task Reminders, Follow-up records and people relations, Persons, Centers, Projects and Project membership, Categories, Tags, Task checklists, Recurrence rules, Occurrences and occurrence-specific checklist items, and Project/Task template parent and child records.

## Changes in this execution

- Added `task_recurrence_rules` with frequency, interval, start/end, count, active and tracking-level columns.
- Added `task_occurrences` and `occurrence_checklist_items`.
- Routed TaskStore reads/writes for recurrence and occurrence state through relational SQL.
- Removed recurrence and occurrence maps from newly written Task legacy envelopes.
- Kept historical JSON values as migration evidence where retirement gates are not yet met.
- Added relational Project ordering and unified the Project migration writer path.

## Remaining non-SQL or duplicated persistence

- `tasks.legacy_payload_json` remains and still contains other Task fields that have not all been normalized.
- `projects.legacy_payload_json` remains as a transitional unknown-field preservation envelope.
- `tasks.recurrence_json` remains as a legacy source column; new canonical recurrence writes use the relational table.
- Task-template columns still contain `tags_json`, `checklist_json`, `people_json`, `reminders_json` and `recurrence_json`.
- Project-template task rows still contain `tags_json` and `checklist_json`.
- Settings, Calendar integration, and other operational state still have SharedPreferences persistence.
- Prayer Completion, Notification State, remote sync and all backup/restore entity coverage remain unproven.

## Conclusion

SQL-ONLY is the approved architecture, but consolidation is **not complete**. Do not claim zero durable JSON or complete SQL ownership until every listed source is migrated, parity-checked, backed up/restored and accepted. Legacy JSON remains retained; no unproven deletion occurred.
