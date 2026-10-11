# Arvin Data Model

**Canonical source:** [ADR-2026-10-10-PCTADP](../ADR/ADR-2026-10-10-PCTADP-project-category-tag.md) and [existing implementation-oriented data model](../DATA_MODEL_PROJECT_CATEGORY_TAG.md).

## Canonical concepts
| Concept | Meaning | Canonical evidence |
|---|---|---|
| Task | Actionable work item; single source of truth | `lib/models/task.dart`; `lib/services/task_store.dart` |
| Project | Broad domain/workspace | `lib/models/goal_project.dart`; `lib/services/project_store.dart` |
| Category | Primary classification; Group synonym only | `Task.category`; Category catalog in TaskStore |
| Tag | Flexible multi-value attribute | `Task.tags`; Tag catalog and task-tag persistence |
| Checklist | Task-owned definition with execution state for repeat occurrences | Existing Task/editor/store fields; validate lifecycle |
| Repeat | Task repeat definition plus scheduled occurrences and execution/history state | Existing recurrence contract; see Issue #2254 |
| Follow-up / Tracking | Task-attached next action and history | Existing Task/follow-up paths; validate end-to-end |
| Calendar link | Mapping from canonical Task to external event | Existing Calendar Provider bridge/link metadata |

## Invariants
- No duplicate task system, parallel taxonomy, independent checklist store or CRM.
- A Task has zero/one Project, zero/one Category and zero/many Tags.
- Category and Tag remain distinct. No independent Group model/table/store or mapping.
- Repeat occurrences do not become duplicate canonical Tasks.
- Past history is immutable; future scheduling changes must not rewrite historical outcomes.
- Calendar is a projection, not Task owner.
- Backup/Restore preserves canonical records, relations, catalogs and external-event link metadata.

## Schema caveat
The accepted taxonomy ADR explicitly states that Project membership currently appears as Project-to-Task membership and Category is a separate Task field/catalog. A physical Category-to-Project foreign key is not established by the domain diagram. Any such schema change requires source inspection, an explicit owner-approved decision, migration/rollback plan and tests before implementation.

## Data change gate
Before any persisted field/schema/serialization change:
1. Inspect current schema, store, callers, backups and legacy payloads.
2. Record compatibility, migration and rollback plan.
3. Validate candidate input before mutation.
4. Add focused persistence, failure/rollback and restore round-trip tests.
5. Validate old data and exact-head build/tests.
6. Do not claim integrity without evidence.
