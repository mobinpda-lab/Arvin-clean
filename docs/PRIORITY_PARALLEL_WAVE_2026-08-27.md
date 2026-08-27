# Priority Parallel Delivery Wave — 2026-08-27

Refs #92 #195 #278 #284 #285 #286 #287 #293 #296 #298 #301 #303 #305.

## Goal
Deliver Arvin capabilities in hours rather than days through safe coordinated parallelism: product implementation, CI/GitHub automation, validation, scorekeeping and documentation move concurrently while production merges remain serialized.

## Permanent execution rules
- Independent product, automation, scorecard and documentation work stays on separate branches/PRs.
- `main` is never edited directly.
- Draft product PRs use Parallel Fast CI first; heavy Build/APK/Device gates start only after a green fast lane.
- Development, CI, automation and documentation run in parallel; product Merge remains one verified PR at a time.
- After every Merge, remaining lanes are reconciled onto the new `main` without force-push; old-base CI becomes historical immediately.
- Dependent capabilities consume merged foundations instead of copying logic or storage.
- No duplicate Task/FollowUp/Calendar/Sync storage path.
- GitHub automation may cancel only proven-stale heavy PR runs; it never auto-merges, force-pushes, rewrites product branches or cancels main validation/Parallel Fast Lane.
- Scorecards change only from merged, validator-backed evidence.

## Current main
Current `main`: `76d651f2540f59121cce657a7dab7305e4f35f0d`.

## Merged in the current priority wave
- #288 — pure schedule conflict core ✅
- #289 — Goal -> Project -> Item domain foundation ✅
- #290 — deterministic safe sync merge foundation ✅
- #291 — suggestion-only rescheduling planner ✅
- #294 — CalendarReminder -> ScheduleInterval conflict projection ✅
- #299 — canonical Task -> stable SyncRevision bridge ✅
- #297 — Goal/Project progress projected from canonical Task state ✅
- #302 — real calendar conflict evidence -> safe replacement-time advice ✅

### Latest merge #302
Exact reconciled head `3d7a5aa310c3494a9e3cf2621eb42b1df9805204` passed:
- Arvin Parallel Wave #862 ✅
- Arvin Build #976 ✅
- Arvin Device Smoke #222 ✅

The merged path remains read-only and suggestion-only: no automatic Calendar/Task/FollowUp mutation and no duplicate conflict/rescheduling engine.

## Active product lane — capability #18 Task-set sync planning
Issue #303 / Draft PR #304 — `feat(sync): plan canonical Task-set merge decisions`

Current reconciled head: `5373ba5df7172d1f0a0d4c4492162614420c5740`.

- composes the already-merged TaskSyncRevisionService and SyncMergeService across complete local/remote canonical Task sets;
- deterministic union-by-id plan;
- explicit local-only / remote-only / identical / use-local / use-remote / conflict outcomes;
- common-ancestor fingerprint evidence can prove a one-sided change;
- duplicate/empty ids fail closed;
- no network/provider/cloud choice, persistence, background write or second sync store;
- the previous Fast CI evidence is historical after #302; fresh exact-head Fast CI is required before promotion.

## Automation lane — stale heavy PR gate guard
PR #282 — `ci: cancel stale heavy PR gates when main advances`

Current reconciled head: `a5eef2a5a4ea61c2d8f27446717e4fd686016545`.

- product files untouched;
- examines only queued/in-progress PR `Arvin Build` / `Arvin Device Smoke` runs;
- uses immutable exact run `head_sha`;
- cancels only with positive compare evidence that a run no longer contains current main;
- uncertain evidence is skipped;
- no auto-merge/rebase/force-push and no cancellation of main validation or Parallel Fast Lane;
- exact-head validation must be fresh again after #302 before activation.

## Scorecard lane
PR #306 — scorecard-only evidence reconciliation.

Current reconciled head: `8c99aa03976a12fa6e0b1fac99f2cef30d3cd91a`.

Candidate evidence-backed stages:
- #13 Smart Conflict Detection: 40
- #14 Smart Rescheduling: 40
- #15 Goal -> Project -> Item: 40
- #17 Privacy / Encryption: 85
- #18 Sync / Backup multi-device: 40

Candidate 19-feature extension metric: **37.4%**.
This is not official until `Arvin Progress Score` validates the exact head and the scorecard PR is merged.

## Documentation lane
PR #292 — this live record.

Documentation remains independent from product files and is refreshed after product merges so future chats can resume from GitHub reality rather than conversational memory.

## Current merge protocol
1. Let #304, #282 and #306 validate independently on the current main.
2. Keep product work highest priority; promote #304 only after fresh Fast CI.
3. Merge only an exact fully-green head whose ancestry still contains current main.
4. After any Merge, reconcile the other lanes and discard stale-base validation evidence.
5. Merge #282 once current-main gates are green so future stale heavy PR runs can be removed automatically.
6. Merge #306 only after the progress validator recomputes the committed metrics exactly.

## Non-technical status
Three meaningful product steps have now landed in rapid sequence: canonical Sync revisions, Goal/Project progress, and smart calendar rescheduling advice. The next Sync layer, GitHub runner automation, evidence-based progress reporting and documentation are continuing in parallel, without direct main edits or force-push.
