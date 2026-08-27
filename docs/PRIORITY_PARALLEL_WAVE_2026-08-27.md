# Priority Parallel Delivery Wave — 2026-08-27

Refs #92 #195 #278 #284 #285 #286 #287 #293.

## Goal
Deliver the user's priority capabilities with maximum safe parallelism while preserving production stability and GitHub as the source of truth.

## Permanent execution rules
- Independent work stays on separate branches/PRs.
- `main` is never edited directly.
- Draft PRs use Parallel Fast CI first; heavy Build/Device gates are promoted only after Fast CI is green.
- Development and validation are parallel, but Merge is serialized: one verified PR at a time.
- After every Merge, remaining lanes are reconciled onto the new `main` without force-push and receive fresh exact-head validation.
- Dependent work consumes merged foundations instead of duplicating logic.
- No second Task/FollowUp/Calendar storage path is allowed.
- Documentation and automation run in independent lanes so they do not invalidate product heads under test.
- Progress/scorecards change only from merged evidence.

## Merged in this wave

### #288 — Schedule conflict core ✅
- Squash-merged to `main` as `d3671b608928821f926ea216b346d7fe386afeed`.
- Exact-head Parallel Wave #818 ✅
- Exact-head Build #924 ✅
- Exact-head Device Smoke #170 ✅
- Post-merge main quality + Debug APK + Release APK + Android smoke all verified successful.
- Pure deterministic overlap engine; no Task/schema/storage/UI side effect.

### #290 — Multi-device sync merge foundation ✅
- Squash-merged to `main` as `265dc84c4f081f37a59abd71d72ea3a04f9a9388`.
- Exact-head Parallel Wave #823 ✅
- Exact-head Build #930 ✅
- Exact-head Device Smoke #176 ✅
- Divergent edits become explicit conflicts; timestamps never silently overwrite data.
- No provider/network/background write or new Task store.

Current main at this checkpoint: `265dc84c4f081f37a59abd71d72ea3a04f9a9388`.

## Active product lanes

### #289 — Goal → Project → Item foundation
- Reconciled without force-push onto current main.
- Current head: `c29589abbbdda1cfdc09643b5a651b09dc86db8c`.
- Goal/Project references canonical Task IDs only; Task payload is not copied.
- No new Task store/schema/persistence in the foundation.
- Fresh exact-head validation is required after the #290 merge before Merge eligibility returns.

### #291 — Safe rescheduling planner
- #288 dependency is now merged and the PR targets `main` directly.
- Reconciled without force-push onto current main.
- Current head: `c9118468df0dfe13f5202060820b3cea03b4a6b2`.
- Consumes the single merged conflict engine; no duplicate overlap logic.
- Suggestion-only; no automatic Task/Calendar mutation.
- Feature-specific documentation lives with the branch in `docs/RESCHEDULING_PRIORITY_LANE_2026-08-27.md`.

### #294 / Issue #293 — Calendar conflict projection
- Reconciled without force-push onto current main.
- Current head: `89d24ca8830979d6a06478707be9524fa135385b`.
- Reuses existing FollowUp → CalendarReminder projection and the existing 30-minute timed-event convention.
- Completed and all-day reminders do not block clock-time availability.
- No second Calendar/storage/repository.

## Automation lane

### #282 — stale heavy gate guard
- Reconciled without force-push onto current main.
- Current head: `a6eb178cfa81921aa26fe0fb086a96e3f621f6ef`.
- Cancels only stale queued/in-progress PR Build/Device runs after `main` advances and only with positive GitHub ancestry evidence.
- Never cancels main validation or Parallel Fast Lane.
- No auto-rebase, force-push, or auto-merge.
- Workflow, Python self-test, Flutter contract test and dedicated documentation remain isolated from product files.
- Must pass fresh exact-head validation before activation/merge.

## Existing priority capabilities reused, not rebuilt
FollowUp automation, Timeline, and Quick Capture already have canonical implementations/evidence. New scheduling/planning/sync work must integrate with those foundations rather than creating parallel implementations.

## Next merge protocol
1. Confirm post-#290 main Build/Device validation.
2. Let #289/#291/#294/#282 validate independently on current main.
3. Merge the first fully-green product lane whose exact head still contains current main.
4. Immediately reconcile the remaining lanes and invalidate old-base evidence.
5. Activate #282 only after its own exact-head review/gates are green, then let GitHub automatically stop stale heavy PR gates on future main advances.
6. Refresh current-state/handoff and scorecards only after merged evidence warrants it.

## Safety result at checkpoint
Code delivery, CI, GitHub automation and documentation are progressing concurrently. Product branches touch separate files, no direct writes go to `main`, force-push is not used, and no duplicate domain storage has been introduced.