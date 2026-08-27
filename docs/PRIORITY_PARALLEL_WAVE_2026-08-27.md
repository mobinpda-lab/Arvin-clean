# Priority Parallel Delivery Wave — 2026-08-27

Refs #92 #195 #278 #284 #285 #286 #287.

## Goal
Deliver the user's priority capabilities with maximum safe parallelism while preserving production stability and GitHub as the source of truth.

## Execution rules
- Independent work stays on separate branches/PRs.
- `main` is never edited directly.
- Draft PRs use Parallel Fast CI first; heavy Build/Device gates are promoted only after Fast CI is green.
- Merge is serialized even when development is parallel: one verified PR at a time, then remaining lanes are reconciled against the new `main`.
- Dependent work is stacked explicitly instead of duplicating logic.
- No second Task/FollowUp/Calendar storage path is allowed.
- Documentation and automation run in independent lanes so they do not invalidate product heads under test.

## Active product lanes

### #288 — Schedule conflict core
- Head `1a4dc7c6320cd69e3bba94df805220b367c22d9d`.
- Pure deterministic interval conflict engine + focused tests.
- No Task/schema/storage/UI side effect.
- Parallel Wave #818: success.
- Device Smoke #170: success.
- Full Build #924: running at this checkpoint.

### #291 — Safe rescheduling planner
- Head `ada6241d0a74fd1fb0ae56dcd0ec24d9049ef756`.
- Stacked on #288 intentionally.
- Consumes the conflict engine; does not duplicate overlap logic.
- Suggestion-only foundation; no automatic task/calendar mutation.
- Must not retarget/merge before #288 lands and the branch is reconciled with resulting `main`.

### #289 — Goal → Project → Item foundation
- Head `3e8565f064edb830b7a003b6d70d557cd57ad524`.
- Goal/Project references canonical Task IDs only; Task payload is not copied.
- No new Task store/schema/persistence in foundation.
- Parallel Wave #819: success.
- Device Smoke #171: success.
- Full Build #925: running at this checkpoint.

### #290 — Multi-device sync merge foundation
- Head `62ee251b4917f4c92b000763682bbbc41138027b`.
- Pure deterministic merge-decision contract.
- Divergent edits become explicit conflicts; timestamps never silently overwrite data.
- No provider/network/background write or new Task store.
- Parallel Wave #820: success.
- Device Smoke #172: success.
- Full Build #926: running at this checkpoint.

## Automation lane

### #282 — stale heavy gate guard
- Head `9a8311e045440c0995ddbbf3ae356ede90429ae7`.
- Cancels only stale queued/in-progress PR Build/Device runs after `main` advances, and only with positive GitHub ancestry evidence.
- Never cancels main validation or Parallel Fast Lane.
- No auto-rebase, force-push, or auto-merge.
- Parallel Wave #805: success.
- Remains independent of product files.

## Existing priority capabilities
FollowUp automation, Timeline, and Quick Capture already have canonical implementations/evidence. This wave must integrate and extend them instead of rebuilding parallel foundations.

## Merge/reconciliation order
1. First fully-green dependency-unlocking product lane (prefer #288 because it unlocks #291).
2. Post-merge main validation.
3. Reconcile #291/#289/#290 against the new main and re-run exact-head gates as required.
4. Merge remaining independent product lanes one-by-one.
5. Merge/activate automation #282 only after fresh exact-head review on current main.
6. Refresh live handoff/status and scorecards only from merged evidence.

## Safety result at checkpoint
Product development, documentation, and automation are proceeding concurrently without direct writes to `main`, without shared file edits between active product lanes, and without duplicate domain storage.