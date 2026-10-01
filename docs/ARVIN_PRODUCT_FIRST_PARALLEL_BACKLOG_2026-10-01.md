# Arvin — Product-First Parallel Backlog (2026-10-01)

Base main: `9e3811815bb99956c91cd2b8bd24455225397267`

## Gate 0 — Current PR #2076
Current head: `ea512b5cdb328a4c3412164d4ef37c6d3448b479`
- Passed: Production Loop, Orchestrator, PR Wakeup, G1.
- Running: Build, Device Smoke, Calendar Provider Acceptance.
- Merge remains blocked until all required exact-head gates pass.

## Remaining product work

### Lane A — Calendar / Task lifecycle (P0/P1)
Authority: #2066, #1901, existing calendar infrastructure.
- Prove create/edit/clear/complete/archive/trash/delete behavior for Task → device Calendar.
- Prove stable Task↔calendar event linkage and duplicate prevention.
- Prove selected destination calendar and Calendar Sync setting behavior.
- Prove reminderDate is distinct from dueDate and both project correctly.
- Prove recurrence update/delete behavior.
- Physical-device acceptance remains separate from emulator evidence.

### Lane B — Quick Add / Task Editor scheduling (P1)
Authority: #1901 and existing Quick Add contracts.
- Date + time entry must open correctly; no blank page.
- Reminder date + time must open correctly.
- Persian/RTL time presentation.
- Keep date/time controls in the required single-row product layout.
- Validate persistence and reload.

### Lane C — Taxonomy + Notebook (P1)
Authority: #847, #1862, #1901.
- Project/Category/Tag management from Settings.
- New taxonomy item immediately appears in the active roll box.
- Creating a Category must not depend on selecting it for the current Task.
- Task and Notebook must consume the same canonical taxonomy.
- Notebook Project/Category/Tag selectors and Tag creation/selection must work in-place.
- Destructive deletion must be dependency-safe; archive/reassign when referenced.

### Lane D — Home + Appearance (P1)
Authority: #1901 and existing UI contracts.
- Reconcile Home four grouping modes against the current implementation.
- Fix clipping/layout/touch-target issues proven on device.
- Restore required Home filters/settings where still missing.
- Font picker and font-size control through canonical AppSettingsService.
- Preserve official colorful palette and accessibility/contrast rules.

### Lane E — Scope cleanup / dependency audit (P2)
- Audit Checklist, Shopping List and Travel List removal before deleting any UI/path.
- Remove only after dependency/data-safety review.
- No user data deletion by UI cleanup.

## Parallelization rules
- A/B/C/D can be prepared independently when their touched files do not overlap.
- Calendar engine/storage/recurrence semantics are a gated lane; no parallel model/storage/engine.
- Device acceptance is a final cross-lane gate and must use the exact promoted APK.
- Every implementation lane: Issue → branch → commit → exact-head validation → PR.
- Unknown evidence stays explicitly unknown; stale workflow results are never reused.

## Next execution order
1. Finish #2076 gates.
2. In parallel, perform independent current-main audits/implementation for A/B/C/D.
3. Merge only exact-head green PRs.
4. Run final physical-device acceptance across the product journey:
   Task create/edit → persistent save → selected phone Calendar sync → reminder → update/delete/complete → recurrence.
