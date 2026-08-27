# Arvin Maximum Parallel — operational plan 2026-08-28

Status: active execution plan.
Baseline at creation: `main` `e31beddb5305f00b4c89f7881c5a47abbeab1365`.

## Permanent no-stop rule
Arvin production must never become globally idle because one lane is waiting, failing, validating, documenting, reviewing or depending on another lane.

- A real blocker pauses only the affected lane.
- Every non-conflicting ready lane continues automatically.
- Documentation, audit and reporting never block independent product production.
- CI waiting time is used to audit/start/advance independent work.
- Stale/conflicted work is never merged merely to keep motion; it is reconciled while other lanes continue.
- Main is advanced only by exact-head verified, mergeable changes and receives post-merge validation.
- User data safety, canonical Task/FollowUp storage, architecture and evidence rules are never weakened for speed.

## Current execution lanes

### Lane A — export/PDF
- PR #374 merged to current main.
- Post-merge Build/APK/Device validation owns final closure for Issue #373.

### Lane B — Follow-up Task UX
- Issue #357 / PR #363.
- Explicit follow-up Task state is implemented.
- Android Home smoke was corrected to the new explicit-toggle contract after a real-device test exposed the stale expectation.
- Fast gate reruns first; then full exact-head Build/APK/Device.
- Stacked PR #366 owns blank FollowUp title -> `پیگیری` after parent reconciliation.

### Lane C — Notebook / category UX
- Issue #362 / PR #365.
- Simple Note and Checklist UI separation, visible edit and immediate same-Task category move are implemented.
- Fresh ready-state Build/Device validation is active; reconcile against latest main before merge when needed.

### Lane D — Reminder widget visual
- Issue #361 / PR #364.
- Approved reminder visual hierarchy is implemented without a second widget data store.
- Fresh ready-state Build/Device validation is active; final launcher/keyguard screenshot acceptance remains a later closure item.

### Lane E — independent Task due date foundation
- Issue #375 / PR #376.
- Additive canonical `Task.dueDate` is independent from Reminder and FollowUp timestamps.
- Draft Fast validation first.
- Follow-on slices own Jalali editor/detail UI and Today/Future/Overdue semantics.

### Lane F — list/bulk operations
- Issue #369.
- After due-date foundation is accepted, Today/Future/Overdue and Move-to-Today use `Task.dueDate`, not reminder/follow-up timestamps.
- Also owns current-list search/sort/filter integration and owner-required list behavior without a second Task store.

### Lane G — calendar UX
- Issue #350 / PR #352.
- Owner-approved compact Persian RTL Jalali day/week/month contract exists.
- Reconcile against latest main and close exact-head Build/APK/Device before merge.

### Lane H — remembered owner requirements
Independent issues remain active and must not disappear:
- #370 Auto Save / safe Back
- #371 Category + Tag management
- #372 independent FollowUp Reminder
- #367 long-press selection / bulk archive / filtered-list PDF-share-print
- #341 Quick Capture Android E2E
- #339 People final roadmap DoD/handoff closure

## Integration order
There is no global serial queue. Merge any lane as soon as its own requirements are satisfied.

Preferred near-term integration order when several become ready simultaneously:
1. smallest already-validated low-overlap fixes;
2. canonical domain/persistence foundations;
3. user-facing surfaces depending on those foundations;
4. E2E/scorecard/handoff closure.

A newer main commit does not invalidate unrelated work automatically. Before merge, verify current main, exact PR head, mergeability, overlap and required CI evidence. Re-run only evidence that became materially stale.

## Documentation and score rule
- GitHub reality is the source of truth.
- Product Contract Matrix must retain Missing/Partial ownership until acceptance is genuinely complete.
- Project completion and Product Extension scorecards remain separate.
- No percentage is increased from plans, code-only work or Draft CI.
- Historical documents remain preserved; stale active snapshots are reconciled or marked superseded, not deleted.

## Reporting rule
Owner reports stay short and non-technical:
- what merged;
- what is moving in parallel;
- blocker only if real;
- immediate next integration.

The phrase `ادامه با حالت Maximum Parallel` means: audit live GitHub, resume nearest unfinished work, keep every independent lane moving, validate, document and integrate without waiting for the owner to repeat technical instructions.
