# Arvin live completion audit — 2026-08-28

This note is the current GitHub recovery checkpoint for humans and AI agents. It records verified repository reality and the active Maximum Parallel execution map. It does not replace detailed product contracts.

## Verified baseline

Current validated `main`: `6ffbb81ee32a08501b40ab1e18917bff4fa499fc`.

Post-merge validation for #407 is green:
- Arvin Build #1258 — success
- Arvin Device Smoke #504 — success

#407 delivered the canonical Task bulk mutation core for safe batch trash, category reassignment and additive multi-tag operations while preserving Task identity, history, due dates and reminders.

## Active current-main lanes

### #408 — Task due-date editor

Rebuilt from current main after stale #406 was retired.

- dedicated `موعد کار` block in `ArvinTaskEditorDialog`
- Jalali date and explicit time
- independent from Task reminder and FollowUp time
- create/edit/preserve/clear through canonical `Task.dueDate`
- exact-head Fast gate is green
- Ready/full Build + Device validation is running

Remaining owner boundary after this editor lands: canonical Home/Task Detail edit must assign `edited.dueDate` back to the existing Task and persist it end-to-end.

### #409 — independent FollowUp reminder core

Rebuilt from current main after stale #404 was retired.

- optional `FollowUp.reminderDate`
- same canonical Task `followUps[]` JSON envelope
- no second model/store/storage key/scheduler
- legacy FollowUps without reminder remain valid
- legacy Task `followUpDate` stays scheduling/enablement data and does not fabricate a real FollowUp history entry
- migration adapter/reader/store/unified-item contracts are covered together
- Draft Fast validation is running

After the core is validated, UI and the existing notification/scheduler path should consume this same field in a separate slice.

## Important audit corrections

### Home remains a P0 integration boundary

The model/service foundations already exist. Do not rebuild them. Remaining work is canonical Home wiring, discoverability and final device/visual acceptance.

### Task due date is a real user-path gap until Home persistence is wired

`Task.dueDate`, serialization and scope/projection foundations exist. #408 covers editor create/edit/clear. The Home edit-copy boundary remains the final persistence gap.

### FollowUp history and legacy scheduling are different concepts

A historical legacy `followUpDate` must not be fabricated into a real FollowUp history event. Real history begins only when a real FollowUp exists. This distinction is now the target migration contract in #409.

### Bulk work is partially delivered, not complete

#407 provides the canonical mutation core. #367 still owns user-facing multi-selection/select-all, category/tag actions and report/share/PDF/print completion.

### Open PR count is not active work count

Historical/superseded PRs are preserved for evidence but are not merge candidates. Stale implementation lanes are rebuilt from current main rather than force-merged.

## Active P0 order

1. finish #408 full gates and merge safely
2. persist due date through canonical Home/Task Detail edit path
3. finish #409 Fast/full gates and merge safely
4. add FollowUp reminder UI + existing scheduler/notification wiring
5. continue #367 bulk UI/export lanes
6. finish Home final integration/visual acceptance

P1/P2/P3 work may run independently when files and gates do not conflict, but must not starve the P0 path.

## Maximum Parallel operating rule

- one blocker pauses only its own lane
- Draft PRs receive exact-head Fast validation
- Ready production PRs receive full Build/APK/Device validation
- current-main sanity is checked before promotion/merge
- post-merge main is validated again
- CI wait time is reused for independent implementation, testing and documentation
- stale/diverged/red PRs are never force-merged
- superseded history is closed, not deleted
- no duplicate Task/FollowUp/Note/Calendar/Sync model, repository, database, storage key or scheduler
- no destructive rewrite of `main`

## Reporting rule

User-facing reports stay short and nontechnical: what entered the app, what is actively being completed and whether the latest validated base is healthy. Detailed evidence stays in GitHub.
