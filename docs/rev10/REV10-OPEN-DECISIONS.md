# REV10 Open Decisions Register
Unresolved decisions block only dependent work. No agent may decide for the Product Owner.

| ID | Decision | Impact/entities | Blocking workstream | Owner | Required date | Status | Evidence |
|---|---|---|---|---|---|---|---|
| D-001 | Retain current IDs or adopt UUIDv7 | All IDs, SQLite FKs, migration, backup | Identifier migration only | Product Owner | Pending owner scheduling | OPEN | Compatibility matrix and reversible migration proposal |
| D-002 | Shared activity identity | Task, Reminder, Follow-up, Calendar | Shared identity projections | Product Owner | Pending owner scheduling | OPEN | Ownership map and lifecycle invariants |
| D-003 | Recurrence semantics | Task, Reminder, Occurrence, Calendar | Recurrence implementation | Product Owner | Pending owner scheduling | OPEN | Rules, timezone, history, edits, missed occurrences |
| D-004 | Waiting For lifecycle | Task, Person, Follow-up | Waiting For UX/query semantics | Product Owner | Pending owner scheduling | OPEN | State machine, next-action and persistence contract |
| D-005 | Encryption boundary and key recovery | Local DB, backup, restore | SQLCipher/local DB encryption decisions | Product Owner | Pending owner scheduling | OPEN | Threat model, key lifecycle, recovery, compatibility |
| D-006 | Reconcile ProjectExecution with direct optional Task links | Project, Center, Category, Task | Changes to relation ownership | Product Owner | Pending owner scheduling | OPEN | Reconciled ADR and migration plan |
| D-007 | Category-to-Project scope and ambiguous history | Category, Project, Task | Inferred links and scope-dependent UI | Product Owner | Pending owner scheduling | OPEN | Cardinality decision and no-guess migration |
| D-008 | Soft-delete retention/permanent deletion | All entities/edges | Irreversible delete/retention jobs | Product Owner | Pending owner scheduling | OPEN | deleted_at/archive/delete/restore matrix |

Isolation: D-001 does not block stable-ID CRUD; D-002 does not block Center CRUD or optional selection; D-003 does not block non-recurring reminders; D-004 does not block ordinary Follow-ups; D-005 does not block current backup UX; D-006/D-007 block only ownership changes or inferred edges; D-008 does not block archive/restore but blocks irreversible deletion.
