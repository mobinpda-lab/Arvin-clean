# Priority Parallel Delivery Wave — 2026-08-27

Refs #92 #195 #278 #284 #285 #286 #287 #293 #296 #298.

## Goal
Deliver the priority Arvin capabilities in hours rather than days by maximizing safe parallel work while keeping GitHub, CI evidence and documentation synchronized.

## Permanent execution rules
- Independent product, automation and documentation work stays on separate branches/PRs.
- `main` is never edited directly.
- Draft product PRs use Parallel Fast CI first; heavy Build/APK/Device gates start only after the fast lane is green.
- Development, CI, automation and documentation run in parallel; product Merge remains serialized one verified PR at a time.
- After each Merge, remaining lanes are reconciled onto the new `main` without force-push and old-base CI evidence is treated as historical.
- Dependent capabilities consume merged foundations instead of copying domain logic or storage.
- No duplicate Task/FollowUp/Calendar/Sync storage path is allowed.
- Automation may remove proven-stale runner work but must never auto-merge, force-push, rewrite product branches or cancel main validation.
- Scorecards change only from merged, validator-backed evidence.

## Current verified main
Current `main`: `4b8b9a1f139303e112b53a61e4fee4ef237df065`.

Latest merged product step in this wave:
- #294 — CalendarReminder -> ScheduleInterval conflict projection ✅

Previously merged foundations in the same priority wave:
- #288 — canonical pure schedule conflict core ✅
- #289 — Goal -> Project -> Item domain foundation ✅
- #290 — deterministic safe multi-device sync merge foundation ✅
- #291 — suggestion-only safe rescheduling planner ✅

These merged foundations remain additive: no second Task store, no silent timestamp winner, no automatic calendar mutation and no duplicate conflict algorithm.

## Active product lane A — capability #15 Goal -> Project -> Item progress
PR #297 — `feat(planning): project Goal/Project progress from canonical Tasks`

Current exact head: `588e4b1151a6ef73aa6fe10db5969dd36b9b0651`.

State at this checkpoint:
- reconciled onto current `main`;
- merge-base evidence is current `main`;
- Parallel Fast CI #845 ✅;
- promoted from Draft to Ready only after fast validation;
- full Arvin Build #958 and Device Smoke #204 started on the exact head;
- progress is read-only and derives only from canonical `Task.id` + `Task.completed`;
- no new Task database/repository/storage/migration;
- invalid/missing/duplicate Goal references never expose a misleading completion ratio.

Merge rule: do not merge until the exact-head heavy gates are green and `main` still matches the validated ancestry.

## Active product lane B — capability #18 Task sync revision bridge
PR #299 — `feat(sync): derive stable revisions from canonical Tasks`

Current exact head: `28c1d9c69e172dbdc680f4cdfb4c7c8cc28a0bf5`.

State at this checkpoint:
- reconciled onto current `main`;
- compare evidence: ahead of current main, behind by zero;
- only the canonical Task sync revision service + focused test remain as the live diff;
- Parallel Fast CI #846 ✅;
- promoted from Draft to Ready only after fast validation;
- full Arvin Build #959 and Device Smoke #205 started on the exact head;
- SHA-256 fingerprint is derived from canonical `Task.toJson()` using the existing cryptography dependency;
- no provider/cloud/network/background write choice;
- no second Task/sync storage model;
- timestamps are evidence only and never silently choose a conflict winner.

Merge rule: do not merge until exact-head heavy gates are green and current-main ancestry remains valid.

## Automation lane — stale heavy PR gate guard
PR #282 — `ci: cancel stale heavy PR gates when main advances`

Current reconciled head: `40d207a2c19c70ffe1e5e57c0fbbf4b3cefb5db3`.

State at this checkpoint:
- rebuilt as a non-force merge reconciliation onto current `main`;
- product files are untouched;
- Build #960 and Device Smoke #206 started; Parallel Wave #848 entered the queue;
- runs only after push to `main`/`master`;
- inspects only queued/in-progress pull-request runs for `Arvin Build` and `Arvin Device Smoke`;
- classifies staleness from the immutable exact run `head_sha`;
- cancellation requires positive GitHub compare evidence that the exact run head no longer contains current main;
- uncertain API evidence is skipped, never cancelled;
- main validation and Parallel Fast Lane are never cancelled;
- no auto-rebase, no force-push and no auto-merge.

Purpose: reduce wasted heavy-runner time after a product merge moves `main`, without serializing independent development lanes.

## Documentation lane
PR #292 — this document.

The documentation branch is reconciled onto current `main` independently from product and automation branches. It remains Draft while product heads continue to move, so documentation never blocks or invalidates product delivery.

## Merge coordination rule from this checkpoint
1. Let #297 and #299 complete heavy gates in parallel.
2. Let #282 validate independently without competing for product merge priority.
3. Merge only the first product PR whose exact head is fully green and still contains current main.
4. Immediately treat the other product PR's old heavy evidence as stale if main moves; reconcile and rerun only what is required.
5. After product delivery stabilizes, merge #282 if its exact-head gates are green so future stale heavy runs are cancelled automatically.
6. Refresh this documentation and the official scorecard only after merged evidence justifies a stage change.

## Non-technical status
The priority wave is moving on three tracks at once: product capability #15, product capability #18, and GitHub automation. Their fast checks are already passing; full Android checks are running in parallel. Documentation is being updated at the same time, with no direct writes to `main` and no force-push.