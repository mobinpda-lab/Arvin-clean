# REV10 REQUIREMENTS TRACEABILITY — INITIAL
**Status:** IN PROGRESS. This is a traceability starter, not a complete implementation claim.

## Confirmed from canonical PRODUCT_DECISIONS.md / ROADMAP.md
- Home filters: Time, Center, Project, Category, Tag.
- Filter semantics: OR within each dimension; AND across dimensions.
- Home time grouping: five due-date groups; overdue prioritized.
- Hierarchy/relations: Center↔Project M2M; Project↔Category M2M; Task→Center, Project and Category optional 0..1; Task↔Tag M2M.
- Local-first, offline-capable product; multi-device sync remains suspended.
- Legacy Follow-up fields remain for compatibility; no retirement without separate owner decision and safe migration.
- Main read-only; release manual and owner-gated.

## Required product traceability — pending detailed source mapping
Task, Project, Center, Category, Tag, People, Follow-up, Checklist, Calendar, Reminder, Recurrence, Occurrence, Search/Filter, Notebook, Quick Add, Reports, Settings, Backup/Restore.

For each capability, lane C must link requirement → screen → service/repository → persistence → tests → exact SHA → evidence. No feature is ACCEPTED merely because a document describes it.
