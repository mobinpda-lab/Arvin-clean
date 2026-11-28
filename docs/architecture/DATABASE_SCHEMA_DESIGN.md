## Canonical owner-locked data architecture — 2026-11-28

**Authority:** reconcile the explicit owner decisions in `docs/project-continuity/PRODUCT_DECISIONS.md`, especially `ARVIN-DEC-2026-11-14-CENTER-PROJECT-CATEGORY-M2M` and LOCAL-FIRST. This section supersedes conflicting proposals in the historical draft below. It defines the target; it does not claim the implementation is accepted.

### One source of truth
- One local SQLite database; local SQL is the durable product source of truth. Multi-device sync remains suspended.
- One schema definition, one ordered/versioned migration registry, one Database Executor/lock, and one authoritative Store owner per entity/relationship.
- No second database, parallel repository, duplicate catalog, duplicate relationship writer, or shadow persistence path.
- Schema v9 is the inspected branch baseline, not proof of final migration or product acceptance.

### Canonical entities and relationship semantics
- `centers`, `projects`, `categories`, `tasks`, `tags`, `people`, `follow_ups`, and Task-owned `checklist_items`.
- Center↔Project is many-to-many, owned only by `center_projects` / CenterStore.
- Project↔Category is many-to-many, owned only by `project_categories` / the future single CategoryStore.
- Task→Center, Task→Project, and Task→Category are three independent optional 0..1 assignments, represented by the Task's canonical nullable FK fields. They are not a ProjectExecution aggregate; do not introduce `project_executions`.
- Task↔Tag is many-to-many, owned only by `task_tags`.
- Task↔Person and Follow-up↔Person retain their separate canonical relation tables.
- Task due date, independent TaskReminder, recurrence, Follow-up history, and checklist state remain separate concepts; do not conflate or duplicate them.

### Legacy representations that must be reconciled before retirement
- `tasks.project_id` is the target canonical Task→Project assignment. Existing `project_items` is a legacy competing representation, not a second runtime authority. Reconcile every edge against Task IDs and existing direct assignments. If one Task has multiple or conflicting Project references, preserve all source evidence and record a migration exception; never choose a Project silently. Keep the legacy table until file-backed parity, backup/restore, rollback and retry are proven; only then may a separately verified migration retire it.
- `categories` is the target Category identity/catalog for both Task assignments and Project↔Category links. `taxonomy_categories` is the legacy name-only catalog. Preserve every name and its Task references while transferring ownership to one CategoryStore; do not dual-write both catalogs.
- Existing Task/Project JSON envelopes and unknown keys are preservation data. Unknown metadata must survive read→write, migration, backup and restore.

### Single ownership map
- CenterStore: Center records and `center_projects` only.
- ProjectStore: Project records only; no competing Project↔Task membership writer.
- CategoryStore (not yet implemented/accepted): Category records and `project_categories` only.
- TaskStore: Task records, optional direct Task FKs, Task-owned checklist, Task↔Tag, Task↔Person and Follow-up persistence; it must not own a second Category catalog.
- One shared executor/lock coordinates every Store. No Store may open a parallel database for the same product data.

### Acceptance boundary
The source audit found schema v9, an explicit v8→v9 hierarchy migration, both legacy/new Category catalogs, and the competing `project_items` / `tasks.project_id` representations. Therefore this target architecture is **DEFINED; implementation and historical migration are NOT ACCEPTED**. The complete Main v7→current ordered migration path, identity/relationship parity, failure rollback/retry, independent-file Backup→Restore, and exact-SHA product acceptance remain mandatory. No destructive DDL or real-user-database migration is permitted before those gates pass.

---

## Historical working draft — retained for traceability
# Database Schema Design — Working Contract
- Status: DESIGN REQUIRED / NOT APPROVED AS IMPLEMENTED
- Recorded: 2026-11-18 | Governing decision: [ADR-001](ADR-001-project-execution-model.md)

## Target principles
One SQLite database, one final schema, one migration registry, one Database Executor, one authoritative Store set, one backup/restore contract. Preserve IDs and history. Enforce FKs, uniqueness, atomic transactions, safe retry and failure recovery. No parallel storage for the same domain data.

## Candidate entities to inventory
Core: `centers`, `projects`, `categories`, `tasks`, `tags`, `people`, `follow_ups`, `reminders`, `checklist_items`.
Relations: `center_projects`, `project_executions`, `project_categories`, `task_tags`, `task_people`, `follow_up_people`.
Existing Task and Project membership structures must also be inventoried.

## Required semantics
- `projects`: shared identity.
- `center_projects`: Center↔Project membership.
- `project_executions`: one independent execution per (Project, Center), unique pair.
- `tasks`: optional execution reference; Tasks without Project/Center/Category remain valid.
- `categories`: independent reusable identity; Task cardinality awaits consumer audit.
- `tags`: one SQLite-backed source.
- Reports aggregate by distinct Task identity and report per execution/Center separately.

## Explicitly unresolved
1. Final table/column definitions and indexes.
2. Whether current schema represents optional Task→ProjectExecution without losing legacy meaning.
3. Category cardinality per Task.
4. Fate and migration semantics of `tasks.project_id` and `project_items`.
5. Existing Center/Project/Task membership tables.
6. Reminder and Checklist ownership and persistence.
7. Complete backup inclusion list and format version.

Do not implement destructive DDL until these questions have documented answers and exact historical SQLite fixtures prove lossless migration.