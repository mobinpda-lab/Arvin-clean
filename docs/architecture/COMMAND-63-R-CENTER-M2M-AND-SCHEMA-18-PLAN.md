# COMMAND 63-R — Center / Project / Category relationship audit
Status: **DESIGN REVIEW ONLY — NO SCHEMA CHANGE AUTHORIZED BY THIS DOCUMENT**
Operational source: `fix/recovery-calendar-device-smoke-2026-10-31`
Inspected operational PR #3052 HEAD: `a2825e003bb9e6b5c2413b0dc74b085273b6148b` (2026-11-19)
Main remains untouched. Do not merge, deploy or run destructive migrations from this proposal.

## 1. Verified current #3052 schema facts
- `G1DriftSchema.version == 17`.
- The active schema creates `centers`, `projects`, `project_items`, and `taxonomy_categories`.
- `projects.center_id` is a nullable scalar foreign key to `centers.id`: one Project can reference at most one Center through this field.
- `project_items` is the existing Project↔Task membership table.
- No `center_projects` or `project_categories` join table is present in the inspected schema source.
- `ProjectPlan` exposes a scalar `centerId`, not a collection of Center IDs.
- `ProjectStore.load` reads `projects.center_id`; `ProjectStore.save` transactionally deletes/rebuilds `project_items` and `projects`, then restores template application records. Any future relation tables must be included in that transaction and preserved through the save path.
- Task category is currently a Task-level string; `taxonomy_categories` stores category names. There is no verified Project↔Category relation in this #3052 schema.
- Home already has Center filter state, filtering logic, selected chips and a Center selector. Draft PR #3569 adds the visible Center pill in the five-filter RTL row; it is not merged and does not create M2M persistence.

## 2. Architecture mismatch / critical warning
The #3495 Issue #3550 description references a different schema lineage where schema 9 contains `center_projects` and `project_categories`. Those tables and assumptions are not present in the #3052 schema 17 source inspected above. Copying #3547/#3548/#3549 or the #3495 schema directly into #3052 would cross incompatible storage lineages.

**🔴 P0 ARCHITECTURE / DATA-MIGRATION REVIEW REQUIRED:** #3052 currently implements scalar Project→Center membership, not Center↔Project M2M or Project↔Category M2M. A UI-only selector cannot satisfy the requested relationship semantics. Do not claim the M2M acceptance gate complete.

## 3. Safe additive evolution proposal (not implemented)
A future schema version should add normalized relation tables without dropping or rewriting the existing scalar columns:
- `center_projects(center_id, project_id, ordinal)`, composite primary key `(center_id, project_id)`, foreign keys to existing Center and Project rows, plus indexes in both lookup directions.
- `project_categories(project_id, category_name, ordinal)`, composite primary key `(project_id, category_name)`, foreign keys to Project and the exact existing category-name key where SQLite constraints permit it.
- If product semantics require direct Task↔Center M2M independent of Project membership, add `task_centers(task_id, center_id, ordinal)`; do not infer it from ambiguous legacy links.

Migration rules:
1. Add tables and indexes only; retain `projects.center_id`, Task legacy payloads and `project_items`.
2. Idempotently backfill each non-null `projects.center_id` as one `center_projects` relation using INSERT OR IGNORE. Re-running migration must not duplicate links.
3. Do not infer Project categories from Task.category. Those are different ownership levels. New Project↔Category relations begin only from explicit user selections unless a separately verified source exists.
4. If Task↔Center is approved, backfill only an explicit persisted Task.centerId; never infer a Center from the first Project when multiple or conflicting memberships exist.
5. Keep the scalar compatibility fields readable until all callers, backups and restore paths use the relation repository.
6. Do not drop or null legacy columns in this phase.

## 4. Required code work after schema contract approval
- Add typed Center↔Project and Project↔Category relation APIs with explicit add/remove operations; avoid replacing the full relation set from stale UI state.
- Extend ProjectPlan with collection-based canonical relations while retaining a documented compatibility boundary for scalar centerId.
- Refactor ProjectStore.save so replacing Project metadata cannot silently erase relation rows; all relation writes and template/task memberships must remain transactionally consistent.
- Update Home Center filter to query the canonical relation graph, with OR within selected Centers and AND across Time/Project/Category/Tags.
- Update Project, Center, Category, Task Editor and Task Details selectors consistently.
- Include relation collections in the existing portable backup snapshot and its rollback path; do not introduce a parallel backup format.

## 5. Mandatory tests before accepting this path
- File-backed SQLite migration from schema 17 to the additive target version.
- Legacy scalar Center association backfills exactly once and remains readable.
- Multiple Centers per Project and multiple Categories per Project survive save/load/reopen.
- Add/remove one relation does not mutate unrelated relations.
- Repeated save and migration are idempotent.
- Injected failure rolls back all relation and Project writes.
- Backup/restore to an independent SQLite file preserves IDs and every relation.
- SQLite integrity and foreign_key_check are clean after reopen.
- Home Center filter OR semantics and AND composition are verified with real stored relationships.
- RTL/device screenshots and small-screen tests cover all five Home filter controls.

## 6. Current PR / issue linkage
- Issue #3550 remains OPEN / IN PROGRESS; the visible Home filter is being addressed in draft PR #3569.
- PR #3569 is UI/filter integration only. It does not add `center_projects`, `project_categories`, or `task_centers` tables and does not satisfy the M2M acceptance gate.
- PR #3574 and #3575 address Person-directory deletion/backup semantics; they do not change Center/Project/Category relationships.

## 7. Explicit non-claims
This document is a source-backed design proposal only. No schema v18 code, relation table, production data migration, backup format change, M2M UI or physical-device acceptance has been implemented by this document.
