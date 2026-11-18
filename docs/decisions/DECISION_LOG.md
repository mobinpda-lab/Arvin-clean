# Decision Log — Arvin
- Updated: 2026-11-18
- Append-only in intent. Corrections must be dated amendments, not silent rewrites.

## 2026-11-18 — ADR-001 Project Execution Model
- Status: APPROVED PRODUCT DECISION; implementation not accepted.
- Project is shared identity; Center↔Project is many-to-many.
- ProjectExecution is independent per Project/Center pair.
- Task attaches to ProjectExecution, not directly to shared Project identity.
- Task may have no Project, Center or Category.
- Category identity is independent/shareable.
- Tag has one SQLite-backed source.
- Aggregate and per-Center reports required; aggregate counts each Task ID once.
- Source: COMMAND 39-R, based on COMMAND 37-R / 38-R product decision.

## 2026-11-18 — COMMAND 38-R NO-GO
The audited implementation did not provide ProjectExecution; duplicate Task↔Project semantic ownership remained; historical migration, Store consolidation, reports and backup/restore were not accepted; workflows had failures. See COMMAND-38-R.md and TEST_RESULTS.md. No Main merge or release authorized.

## Open decisions — evidence required
Category cardinality per Task; exact canonical Task relation; existing membership-table disposition; Reminder/Checklist ownership; migration lineage handling for historical schema version 9.