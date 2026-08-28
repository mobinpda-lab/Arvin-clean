# Arvin live completion audit — 2026-08-28

This note is the current GitHub recovery checkpoint for humans and AI agents. It records verified repository reality and the active Maximum Parallel execution map. It does not replace detailed product contracts.

## Current validated main

Current `main`: `ef3ebae6e5b13e7f7da37442d316b22a1737c9f1`.

Latest merged product wave includes:
- #407 canonical Task batch mutation core
- #409 independent FollowUp reminder persistence/migration core
- #411 canonical Task multi-select/select-all/reconcile semantics
- #415 canonical category/tag lifecycle core

Current-main Build and Device Smoke are green.

## Active fresh lane

### #418 — canonical Task editor-result apply core

Fresh from exact current main.
- persists editor `dueDate` together with the existing canonical Task fields
- preserves Task identity, creation time, FollowUp history and lifecycle flags
- copies mutable collections rather than aliasing editor state
- no second model/store/editor state
- exact-head Fast is green
- promoted to Ready; full Build/APK + Device gates are running

Do not merge until full gates are green and current main remains compatible.

After #418 lands, the next narrow P0 slice is Home wiring through this canonical apply path so due-date edits survive end-to-end.

## Independent lanes requiring reconciliation before promotion/merge

### #417 — Home scope/sort projection

Exact-head Fast is green, but its base predates current main. Keep Draft and rebuild/reconcile from current main before heavy validation.

### #416 — bulk report coordinator

Its historical exact head completed Fast + Build/APK + Device successfully, but current main has advanced. Preserve that evidence; rebuild/reconcile rather than merge stale/diverged work.

### #408 — due-date editor

The editor implementation is valuable evidence but the branch is behind current main. Do not force-merge. Reuse/rebuild only the validated behavior needed by the current integration path.

### #413 and older documentation lanes

Historical documentation is preserved, but stale documentation PRs are not merge candidates. This file supersedes their live-status role without deleting history.

## Delivered foundations that must not be duplicated

- canonical `Task` and `FollowUp` models
- canonical `TaskStore` / existing `arvin.tasks` persistence
- FollowUp reminder field inside canonical FollowUp data
- Task selection semantics
- safe bulk trash/category/tag mutation core
- canonical category/tag lifecycle core
- existing Task report projection/PDF/print/share foundation
- canonical Notebook repository on the same Task storage foundation

## Active P0 order

1. finish #418 full Build/APK/Device gates and merge only if still current-main compatible
2. wire Home/Task edit through the canonical apply service and lock due-date persistence end-to-end
3. rebuild/reconcile #417 on current main and integrate final Home scopes/sorts
4. continue FollowUp reminder UI + existing scheduler/notification wiring
5. rebuild/reconcile bulk report/action lanes on current main and connect selection/mutation/report foundations
6. finish Home final device/visual acceptance

P1/P2/P3 work may continue independently when files and gates do not conflict, but must not starve P0 completion.

## Maximum Parallel operating rule

- one blocker pauses only its own lane
- Draft PRs receive exact-head Fast validation
- Ready production PRs require full Build/APK/Device validation
- current-main sanity is checked before promotion and merge
- stale/diverged/conflicted/red work is rebuilt or reconciled, never force-merged
- independent CI wait time is reused for product, test, documentation and CI/CD work
- historical/superseded records are preserved rather than deleted
- no duplicate Task/FollowUp/Note/Calendar/Sync foundation, store, storage key or scheduler
- no destructive rewrite of `main`

## Reporting rule

User-facing reports stay short and nontechnical. Detailed evidence, head SHAs, gate status and continuation instructions stay in GitHub.
