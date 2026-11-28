## Canonical owner-locked relationship contract — 2026-11-28

**Authority:** explicit Product Owner decisions in `docs/project-continuity/PRODUCT_DECISIONS.md`. This addendum supersedes the working-draft rows below wherever they conflict. It defines the target contract; current implementation is not thereby accepted.

| Relationship | Canonical representation / sole owner | Required rule |
|---|---|---|
| Center↔Project | `center_projects` / CenterStore | M2M; unique pair; unlink never deletes either endpoint |
| Project↔Category | `project_categories` / CategoryStore (not yet accepted) | M2M; unique pair; reusable Category identity |
| Task→Center | nullable `tasks.center_id` / TaskStore | independently optional 0..1 |
| Task→Project | nullable `tasks.project_id` / TaskStore | independently optional 0..1; `project_items` is legacy evidence only and must be reconciled before retirement |
| Task→Category | nullable `tasks.category_id` / TaskStore | independently optional 0..1; references canonical `categories` |
| Task↔Tag | `task_tags` / TaskStore | M2M; unique pair |
| Task↔Person | `task_people` / TaskStore | M2M; preserve historical identity snapshots |
| Follow-up↔Person | `follow_up_people` / Follow-up persistence owner | separate relation; preserve IDs/history |
| Task→Checklist | `checklist_items` / TaskStore | ordered child records; Task owns lifecycle |

### Explicitly superseded / forbidden
- `project_executions` is not part of the approved product model; do not create it.
- A second Project↔Task runtime relation through `project_items` is not allowed alongside `tasks.project_id`. Reconcile source edges without guessing; preserve ambiguous/conflicting cases in an exception ledger until owner-approved recovery.
- `taxonomy_categories` and `categories` must not remain dual writable catalogs. `categories` is the target identity source; migrate name-only legacy rows and Task references losslessly.
- Do not infer Project↔Category links from category text or names where the historical relationship is ambiguous.
- Task due date, TaskReminder, recurrence and Follow-up history remain separate.

### Live source gap — 2026-11-28
- Branch source reports `G1DriftSchema.version = 9`; the explicit hierarchy migration is v8→v9.
- CenterStore already owns `center_projects`.
- ProjectStore still reads/writes `project_items` and only checks `project_categories` during deletion; it does not load/save Project↔Category links.
- TaskStore still owns the legacy `taxonomy_categories` catalog while Task rows also carry `category_id`.
- No accepted single CategoryStore / ProjectCategory owner or complete Main v7→current migration ledger is established.
- Consequently the architecture target is defined, but Store integration, migration, backup/restore parity and product acceptance remain NOT ACCEPTED.

### Preservation rules
Never drop legacy tables/columns until every source row and relation has a deterministic destination or a recorded unresolved exception, independent-file backup/restore is proven, rollback/retry is tested, and exact-SHA acceptance passes. Keep IDs, timestamps, ordering, unknown JSON keys, historical relations and tombstones. Never test destructive migration on a real user database.

---

## Historical working draft — retained for traceability
# Database Relationship Contract — Working Draft
- Status: CONTRACT DRAFT / IMPLEMENTATION NOT ACCEPTED
- Recorded: 2026-11-18 | Governing ADR: [ADR-001](ADR-001-project-execution-model.md)

| Relationship | Intended owner | Required rule | Open verification |
|---|---|---|---|
| Center↔Project | `center_projects` | many-to-many; unique pair | inventory existing membership tables |
| Project↔Center execution | `project_executions` | unique (project_id, center_id) | schema/FK implementation |
| Task↔execution | one canonical optional FK or documented equivalent | one semantic owner | resolve `tasks.project_id` vs `project_items` |
| Project↔Category | `project_categories` | reusable Category identity | audit consumers |
| Task↔Category | existing canonical relation, to be decided | optional; cardinality from product contract | do not assume one/many |
| Task↔Tag | `task_tags` | many-to-many; unique pair | eliminate parallel Tag persistence |
| Task↔Person | `task_people` | unique pair and valid FK | verify current schema |
| Follow-up↔Person | `follow_up_people` | unique pair and valid FK | verify current schema |

## Global invariants
- Every declared FK is enabled and validated; no orphan relation rows.
- Duplicate relationship pairs are rejected.
- Migrations are atomic or expose deterministic recovery; retry does not duplicate data.
- IDs remain stable across migration and backup/restore.
- Optional Task links remain optional.
- Aggregate reports count each Task ID once.
- No two tables/columns own the same semantic relationship without an explicit documented reason.

This is not a claim that the current database satisfies these invariants.