# Arvin live completion audit — 2026-08-28

This is a current-main recovery note for humans and AI agents. It summarizes verified GitHub/code reality after the 2026-08-28 Maximum Parallel merge wave. It does not replace detailed product contracts.

## Verified baseline

Audit baseline: `main` `6054a423f2c83769cfcbc9c49d6f6fbdc2e6c1df`.

Post-wave current-main validation is green:
- Arvin Build #1236 — success
- Arvin Device Smoke #482 — success

Recently merged product slices include:
- #385 Task Detail + add/edit canonical FollowUp flow
- #391 canonical Vazirmatn release entrypoint
- #387 Jalali legacy FollowUp Flutter surfaces
- #393 Jalali/Persian Android widget FollowUp timestamps
- #388 canonical latest-real-FollowUp sort core
- #397 single Task PDF/Print/Share entry with full FollowUp history
- #398 latest-real-FollowUp Home presentation core

Previously merged #365 already provides Notebook simple-note/checklist separation, autosave, explicit edit and immediate same-id category reassignment. Do not rebuild these foundations.

## Important audit corrections

### Home is still an integration gap
`lib/main.dart` still uses legacy FollowUp-based Today/Overdue behavior. Correct foundations already exist:
- `Task.dueDate`
- `TaskDueScopeService`
- `TaskListScopeService`
- `TaskListSortService`
- `TaskMoveToTodayService`
- `HomeFollowUpPresentationService`

Issue #369 was therefore reopened. Remaining work is wiring/discoverability, not another list/store foundation.

### Compact Home + is not yet wired
`ArvinHomePrimaryAddButton` was merged in #368, but the canonical Home still uses the older extended primary action. Treat #360 as open until real Home integration + screenshot/device acceptance are complete.

### Task due date is persistence-complete but UI-incomplete
`Task.dueDate`, serialization, detail display and Today/Future/Overdue projection exist. `ArvinTaskEditorDialog` currently preserves an existing due date but cannot create/edit/clear it. #375 remains a real user-path gap.

### Independent FollowUp reminder was absent
Canonical FollowUp currently had no independent reminder timestamp before the new #372 core lane. The safe implementation is an optional backward-compatible field inside the existing `followUps[]` envelope followed by UI/scheduler wiring; never create a second reminder store/scheduler.

### Product Contract Matrix is stale
Several rows report old Missing/Partial states that newer merged code has superseded. Always verify current code and specific owner Issues before using matrix status for planning. Update the matrix in the documentation lane rather than regressing working product code.

### Open PR count is not active work count
The repository contains many historical/superseded open PRs. #358 owns controlled classification into Active / Stacked / Superseded-history / Needs migration / Close-not-planned. Do not mass-close and do not treat all open PRs as merge candidates.

## Remaining execution map

### P0
1. Home integration/final visual — #369 #395 #360 #253
2. Task due-date create/edit/clear — #375
3. independent FollowUp reminder end-to-end — #372
4. Task/Note bulk selection/actions/export/category/tags — #367

### P1
1. safe Back/autosave for editors — #370 (Notebook autosave already exists)
2. category/tag lifecycle — #371
3. Widget visual/physical acceptance — #361
4. Quick Capture Android E2E — #341
5. Product Contract Matrix + stale PR classification — #358

### P2 real integrations
- multi-device remote Sync/CAS/retry/conflict flow — #342 #349
- Android Calendar Provider idempotent sync — #348

### P3 extension roadmap
Keep remaining X2/X3 items visible under #92, but do not let them starve the accepted P0/P1 completion path.

## Maximum Parallel operating rule

- one blocker pauses only its lane
- Draft PRs receive Fast validation; Ready PRs receive full Build/APK/Device
- independent files validate on a shared base and merge as a wave
- latest combined `main` is validated after a wave
- superseded main Build/Device runs should cancel automatically once #402 lands
- docs and audit run beside product code and never block unrelated implementation
- no duplicate Task/FollowUp/Note/Calendar/Sync model, repository, database, storage key or scheduler
- no force push or destructive `main` rewrite

## Reporting rule

User-facing status should stay short and nontechnical: what entered the app, what is actively being completed, and whether latest combined validation is green. Detailed evidence stays in GitHub.