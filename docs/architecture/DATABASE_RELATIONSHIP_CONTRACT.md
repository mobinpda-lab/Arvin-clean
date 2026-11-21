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