# Priority Parallel Delivery Wave — 2026-08-27

Refs #92 #195 #278 #284 #285 #286 #287 #293 #296 #298 #301.

## Goal
Deliver Arvin capabilities in hours rather than days through safe coordinated parallelism: product implementation, CI/GitHub automation, validation and documentation move concurrently while production merges remain serialized.

## Permanent execution rules
- Independent product, automation and documentation work stays on separate branches/PRs.
- `main` is never edited directly.
- Draft product PRs use Parallel Fast CI first; heavy Build/APK/Device gates start only after a green fast lane.
- Development, CI, automation and documentation run in parallel; product Merge remains one verified PR at a time.
- After each Merge, every remaining lane is reconciled onto the new `main` without force-push; old-base CI is historical immediately.
- Dependent capabilities consume merged foundations instead of copying logic or storage.
- No duplicate Task/FollowUp/Calendar/Sync storage path.
- GitHub automation may cancel only proven-stale heavy PR runs; it never auto-merges, force-pushes, rewrites product branches or cancels main validation/Parallel Fast Lane.
- Scorecards change only from merged, validator-backed evidence.

## Current main
Current `main`: `806860ca0dcd75e342c388858397d05e0c360336`.

Latest merged product step:
- #299 — canonical Task -> stable SyncRevision bridge ✅
  - exact-head Parallel #846 ✅
  - exact-head Build #959 ✅
  - exact-head Device Smoke #205 ✅
  - squash merged after current-main ancestry lock
  - SHA-256 comes from canonical `Task.toJson()`; no second Task/sync store and no timestamp-based silent conflict winner.

Earlier merged foundations in this priority wave:
- #288 — pure schedule conflict core ✅
- #289 — Goal -> Project -> Item domain foundation ✅
- #290 — deterministic safe sync merge foundation ✅
- #291 — suggestion-only rescheduling planner ✅
- #294 — CalendarReminder -> ScheduleInterval conflict projection ✅

## Active product lane — capability #15 Goal -> Project -> Item progress
PR #297 — `feat(planning): project Goal/Project progress from canonical Tasks`

Fresh post-#299 reconciled head: `60cf15c2d1776bf08fe04f881a135b48a97ec101`.

- reconciled onto `806860c...` without force-push;
- prior #845/#958/#204 evidence belongs to the pre-#299 head and is now historical;
- fresh exact-head CI is required before Merge;
- read-only progress derives only from canonical `Task.id` + `Task.completed`;
- no new Task store/schema/repository/migration.

## Active product lane — capabilities #13/#14 calendar rescheduling advisor
Issue #301 / Draft PR #302 — `feat(schedule): advise safe calendar rescheduling`

Fresh post-#299 reconciled head: `8242959ed2709b14513fd701186349033684b730`.

Composition only:
`CalendarReminder -> CalendarScheduleProjection -> ScheduleConflictService -> ReschedulingPlanner`

- no duplicate conflict or rescheduling algorithm;
- only a real conflict on the selected reminder produces suggestions;
- selected reminder is excluded from the busy set before suggestion search;
- projected duration is preserved;
- no Task/FollowUp/Calendar write, persistence, notification or scheduler mutation;
- later write remains explicit user-confirmed canonical work;
- remains Draft until fresh exact-head Fast CI is green.

## Automation lane — stale heavy PR gate guard
PR #282 — `ci: cancel stale heavy PR gates when main advances`

Fresh post-#299 reconciled head: `3de4c5f13920a64d9288e0e391ab0997b575d48a`.

- reconciled without force-push;
- product files untouched;
- examines only queued/in-progress PR `Arvin Build` / `Arvin Device Smoke` runs;
- uses immutable exact run `head_sha`, not a possibly newer PR head;
- cancels only with positive compare evidence that the run head no longer contains current main;
- uncertain evidence is always skipped;
- no auto-merge/rebase/force-push and no cancellation of main validation or Parallel Fast Lane;
- requires fresh exact-head gates before merge/activation.

## Documentation lane
PR #292 — this live record.

It is independently reconciled after every product merge and remains Draft while product heads move. Documentation therefore advances in parallel without blocking product delivery.

## Current merge protocol
1. Validate fresh post-#299 heads for #297, #302 and #282 in parallel.
2. Merge the first fully-green product lane whose exact head still contains current main.
3. Immediately reconcile all remaining lanes; never reuse old-base CI as current evidence.
4. Activate #282 once its own fresh gates are green and product merge coordination permits.
5. Refresh this file and official scorecard only from merged evidence.

## Non-technical status
Sync has moved forward and is now merged. Goal/Project progress, smart calendar rescheduling and GitHub runner automation are already continuing in parallel on the new main. Documentation is moving with them, with no direct main edits and no force-push.