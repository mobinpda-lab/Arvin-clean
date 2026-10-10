# Task Form ↔ Canonical Task Model Mapping

**Status:** Contract only; implementation audit is not yet complete.  
**Owner issue:** [#2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593)

This mapping deliberately does not invent model fields. Before changing code, inspect the current `Task` and related services at the target branch and document exact field names and persistence behavior.

| Form concept | Canonical owner / constraint | Validation to prove |
|---|---|---|
| Title | Existing Task title | Create/edit retains same identity on update |
| Short description | Existing description field, if semantically appropriate; otherwise audit before reuse | Must not silently overwrite Note |
| Due date/time | Existing Task scheduling fields and shared picker/date UI | Jalali display, exact saved value, reminders/repeat/calendar compatibility |
| Repeat | Existing recurrence definition on Task | Start/end/count behavior only where supported; preserve past history |
| Checklist definition | Existing Task checklist fields | Add/edit/delete/reorder/toggle and persistence |
| Checklist occurrence state | Existing canonical occurrence-keyed state/history | State of one occurrence does not alter another |
| Project | Canonical Project assignment | 0 or 1; no catalog loss |
| Category | Canonical Category field/catalog | No duplicate Group entity; selector refreshes immediately |
| Tags | Canonical Tag list/catalog | Multi-select and persistence; distinct from Category |
| Tracking level | Existing Task field/behavior, to be verified in code | Conditional UX without a parallel Tracking entity |
| Follow-up / Next Action | Existing Follow-up contract and Task integration | History, next action and reminders remain intact |
| Note | Existing note/attachment relationship, to be verified | Distinct semantics; no accidental replacement of description |
| Cancel / Save | Existing editor state and canonical Task write path | Cancel is non-mutating; edit preserves Task ID and unrelated fields |
| Calendar link | Existing Task↔device-event link metadata | Update same event when linked; no duplicate event creation |
| Backup/Restore | Existing backup schema and migration path | Round-trip preserves all fields and relationships |

## Data safety
- No new Task store, model, Checklist repository or occurrence Task records.
- Before model/migration changes, prove legacy data readability, backup availability, rollback and restore tests.
- Do not change recurrence/occurrence persistence semantics under a UI-only decision.
- Unknown field mapping is an audit item, not permission to create a new field or duplicate storage.

## Open audit items
- Inspect actual model field semantics and editor save/load wiring.
- Verify whether short description and Note are distinct in current schema; preserve both meanings.
- Verify Tracking Level and detailed fields against current Task/Follow-up model.
- Verify Checklist reorder persistence and per-occurrence state behavior.
- Verify all Task editor launch points use the canonical editor and same draft identity.
- Verify serialization, migration, backup and restore for every displayed field.
