# Arvin live completion audit — 2026-08-28

This is the current GitHub recovery checkpoint for Arvin. It records verified repository reality and the active Maximum Parallel execution map so work can resume safely without relying on chat history.

## Current validated baseline

Current product `main`: `66aa997c1cccdea349772b3e1c639398083ab731` after #418.

Recent delivered foundations include:
- #407 canonical Task batch mutation core
- #409 independent FollowUp reminder persistence/migration core
- #411 canonical Task multi-select/select-all/reconcile semantics
- #412 reusable responsive bulk-selection action bar
- #414 canonical non-invasive FollowUp reminder projection
- #415 canonical category/tag lifecycle core
- #418 canonical Task editor-result apply core, including `dueDate` persistence while preserving Task identity/history

#418 exact-head Fast, Build quality, release/debug APK and both Android Home/People Device Smoke gates were green before merge.

## Active fresh lanes

### #422 — independent due-date editor

Fresh current-main rebuild superseding historical #408 without force merge.
- dedicated `موعد کار` block in the canonical Task editor
- Jalali date + explicit time
- independent from Reminder and FollowUp
- create/edit/preserve/clear through `Task.dueDate`
- Android editor interaction is scroll/hit-test safe
- no second model/store/storage key/scheduler
- initial exact-head Fast was green; branch was then merged forward with #418 and is re-running Fast on the real current-main combination

### #421 — Home scope/sort projection

Fresh current-main rebuild superseding historical #417.
- All / Notes / FollowUp-enabled / Today / Future / Overdue scopes
- date / latest meaningful activity / title sorts
- dueDate takes precedence with legacy Home follow-up fallback during migration
- no Home UI/persistence ownership in this slice
- initial Fast green; merged forward with #418 and re-validating exact head

### #420 — canonical bulk report coordinator

Fresh current-main rebuild superseding historical #416.
- selected-items and visible/current-scope reports
- delegates to existing `TaskReportProjection`
- preserves canonical FollowUp history
- no duplicate PDF renderer/report/share path
- initial Fast green; merged forward with #418 and re-validating exact head

## Superseded history

#408, #416 and #417 are closed historical evidence only. They are not merge candidates. Their validated behavior was rebuilt on current main as #422, #420 and #421 respectively.

Historical documentation PRs may remain for evidence, but this file is the live recovery source once its own fresh gates pass.

## Canonical boundaries — do not duplicate

- `Task` and `FollowUp` models
- `TaskStore` and existing `arvin.tasks` persistence
- FollowUp reminder field inside canonical FollowUp data
- Task multi-selection semantics and bulk mutation core
- category/tag lifecycle core
- Task report projection/PDF/print/share foundation
- canonical Notebook repository on the same Task storage foundation
- Task editor-result apply service from #418

## Active P0 order

1. finish fresh exact-head Fast for #422, #421 and #420 after #418
2. promote each independent green lane only while current-main compatible; require full Build/APK/Device before production merge
3. land #422 due-date editor, then wire Home/Task edit to the #418 apply service for end-to-end due-date persistence
4. integrate #421 Home scopes/sorts into the real Home UI with focused interaction/device acceptance
5. connect #420 report scope with #412 selection UI and existing PDF/print/share foundation
6. continue FollowUp reminder UI + existing scheduler/notification wiring using the canonical field already delivered
7. finish Home final device/visual acceptance

P1/P2/P3 work may continue independently when files and gates do not conflict, but must not starve the P0 path.

## Maximum Parallel operating rule

- one blocker pauses only its own lane
- Draft PRs receive exact-head Fast validation
- Ready production PRs require full Build/APK/Device validation
- current-main sanity is checked before promotion and merge
- stale/diverged/conflicted/red work is rebuilt or merged forward safely; never force-merged
- CI wait time is reused for independent product, test, documentation and CI/CD work
- historical/superseded records are preserved rather than deleted
- no duplicate Task/FollowUp/Note/Calendar/Sync foundation, repository, database, storage key or scheduler
- no destructive rewrite of `main`

## Reporting rule

User-facing reports stay short and nontechnical. Detailed evidence, gate status and continuation instructions stay in GitHub.
