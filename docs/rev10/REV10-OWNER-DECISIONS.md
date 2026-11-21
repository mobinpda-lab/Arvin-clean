# REV10 OWNER DECISIONS
**Record date:** 2026-11-21
**Authority:** explicit Product Owner decisions preserved in REV10 and current owner register.
## Immutable decisions
### Primary Blue
- Exact value: `#4169A1`.
- Single canonical token source: `lib/arvin_colors.dart`.
- No independent or conflicting Primary token is allowed.
- Changes require a subsequent explicit owner decision with a traceable supersession record.
### Center
- Center is a first-class, independently managed product entity.
- It must have persistent identity, lifecycle, search, relationships, selectors, management UI, Home integration and report integration.
- A table, DTO, model or visual-only filter alone is not product acceptance.
### Home
- Five independent dimensions: Time, Center, Project, Category, Tags.
- Multi-select uses OR within one dimension and AND across dimensions.
- Five due-date groups remain distinct: Overdue, Today, Tomorrow, Future, No Date.
- A filter dimension must not be conflated with a due-date group.
### Relationship graph
- Center↔Project: many-to-many.
- Project↔Category: many-to-many.
- Task→Center, Task→Project and Task→Category: independently optional 0..1.
- Task↔Tag: many-to-many.
- Removing an edge must not delete endpoints or unrelated edges.
- Never infer an ambiguous historical relationship from names, labels or task text.
### Data and release authority
- Local SQL is the durable source of truth.
- Preserve IDs, history, NULL, unknown fields, recurrence, occurrences, checklist and metadata.
- Do not run production-user migrations without explicit owner permission.
- Main remains read-only.
- PR #3495 is the only active development route.
- Merge, release and deployment require explicit owner approval.
### Reminder
- Preserve the existing canonical Task, Reminder, scheduler and notification foundations.
- The four independent actions are Stop Bell, Follow-up, Snooze and Complete.
- No parallel scheduler or reminder storage is allowed.
## Change-control rule
A historical implementation, test, ADR, issue, branch, PR or report cannot silently supersede an owner decision. If evidence conflicts, stop the affected change, register the conflict, inspect the canonical source and request owner clarification where necessary. Do not remove a requirement to make a test pass.


## Historical recovery matrix
The canonical source-to-acceptance recovery ledger is maintained in [REV10-HISTORICAL-RECOVERY-MATRIX.md](REV10-HISTORICAL-RECOVERY-MATRIX.md). This matrix is evidence-oriented and does not supersede REV10 or owner decisions.
