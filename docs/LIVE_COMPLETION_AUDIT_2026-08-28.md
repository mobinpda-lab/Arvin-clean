# Arvin live completion audit — 2026-08-28

This note is the current GitHub recovery checkpoint for humans and AI agents. It records verified repository reality and the active Maximum Parallel execution map. It does not replace detailed product contracts.

## Current main

Current `main`: `4e30b7da2fb5dc3a68f297c577e01de60c5cfd51`.

Merged in the current wave:
- #407 canonical Task batch mutation core
- #409 independent FollowUp reminder core + safe legacy scheduling/history separation
- #411 canonical Task multi-select/select-all/reconcile semantics

#409 and #411 each completed exact-head Fast, Build/APK and Device Smoke before merge. Post-wave Build and Device validation for combined `main` is running and remains the authority before calling the combined wave fully locked.

## Active product lane

### #408 — Task due-date editor

The canonical Task editor exposes a dedicated `موعد کار` block with Jalali date + explicit time, independent from Reminder and FollowUp time, using the existing `Task.dueDate` field.

Current head: `af1a74e145894eda87902502b7e0acbfed2fa8bb`.

The first Device failure was traced to the Android People smoke trying to tap the longer editor's Save button at the extreme bottom edge. The test now uses Flutter `Scrollable.ensureVisible(..., alignment: 0.5)` so Save is centered in the tappable viewport. A fresh Build + Device run is executing against the newer main that already contains #409/#411.

After #408 lands, the remaining due-date owner boundary is Home/Task Detail edit persistence: copy `edited.dueDate` back onto the same canonical Task and persist it end-to-end.

## Delivered foundations that must not be rebuilt

### FollowUp reminder

#409 is merged.
- optional `FollowUp.reminderDate`
- stored inside canonical Task `followUps[]`
- no second model/store/storage key/scheduler
- legacy FollowUps without reminder remain valid
- legacy Task `followUpDate` remains scheduling/enablement data and does not fabricate real FollowUp history

Next slice: expose/edit reminder in FollowUp UI and connect the same field to the existing scheduler/notification path.

### Bulk operations

#407 is merged: canonical safe batch trash, category reassignment and additive multi-tag mutation core.

#411 is merged: canonical Task selection semantics for single/multi/select-all, filtered visible scopes, stale-selection reconciliation and selected Task projection while preserving canonical identity/order.

#367 remains open for real Notes/Tasks selection UX plus PDF/share/print/delete/category/tag action wiring. Existing report/PDF foundations must be reused.

### Notebook

Existing canonical Notebook persistence, simple-note/checklist split, autosave, explicit edit and same-id category reassignment remain valid foundations. Do not create a second Note store/model.

## Important remaining boundaries

### Home integration — P0

Existing Task due/scope/sort/presentation services remain the foundation. Remaining work is wiring/discoverability, correct edit persistence and final device/visual acceptance; do not create another Home list/store model.

### FollowUp reminder end-to-end — P0

Core persistence is merged. Remaining work is UI + existing notification/scheduler consumption of the same `FollowUp.reminderDate` field.

### Bulk UX/export — P0

Mutation + selection cores are merged. Remaining work is first-class selection UI and action wiring for Tasks and Notes, reusing canonical PDF/report/share/print foundations and safe trash/category/tag semantics.

## Active P0 order

1. finish #408 fresh full gates and merge safely
2. wire/persist `edited.dueDate` through canonical Home/Task Detail edit
3. add FollowUp reminder UI + existing scheduler/notification wiring
4. wire #407 + #411 into real Task/Notebook bulk selection/actions
5. complete PDF/share/print surfaces for selected Notes/Tasks using existing report foundations
6. finish Home final integration/visual acceptance

P1/P2/P3 may proceed independently only when files/gates do not conflict and must not starve P0 completion.

## Maximum Parallel operating rule

- one blocker pauses only its own lane
- Draft PRs receive exact-head Fast validation
- Ready production PRs receive full Build/APK/Device validation
- independent changes may validate on a shared base and merge as a wave when file ownership does not overlap
- latest combined `main` is validated after every merge wave
- CI wait time is reused for independent implementation, testing and documentation
- stale/diverged/red PRs are never force-merged
- superseded history is closed, not deleted
- no duplicate Task/FollowUp/Note/Calendar/Sync model, repository, database, storage key or scheduler
- no destructive rewrite of `main`

## Reporting rule

User-facing reports stay short and nontechnical: what entered the app, what is actively being completed and whether the latest combined validation is healthy. Detailed evidence stays in GitHub.
