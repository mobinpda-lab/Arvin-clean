# Priority Parallel Delivery Wave — 2026-08-27

Refs #92 #195 #278 #284 #285 #286 #287 #293 #296 #298 #301 #303 #305 #307.

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
Current `main`: `75a93f4df550c79a67bb0c168d5c320d1393c347`.

## Merged in the current priority wave
- #288 — pure schedule conflict core ✅
- #289 — Goal -> Project -> Item domain foundation ✅
- #290 — deterministic safe sync merge foundation ✅
- #291 — suggestion-only rescheduling planner ✅
- #294 — CalendarReminder -> ScheduleInterval conflict projection ✅
- #299 — canonical Task -> stable SyncRevision bridge ✅
- #297 — Goal/Project progress projected from canonical Task state ✅
- #302 — real calendar conflict evidence -> safe replacement-time advice ✅
- #304 — deterministic canonical Task-set sync merge planning ✅

### Latest merge #304
Exact reconciled head `5373ba5df7172d1f0a0d4c4492162614420c5740` passed:
- Arvin Parallel Wave #868 ✅
- Arvin Build #988 ✅ quality + Release APK + Debug APK
- Arvin Device Smoke #234 ✅

The merged Sync path now plans complete local/remote canonical Task sets and keeps real divergence as an explicit conflict. It still owns no provider/network/persistence/background write and never uses timestamps as a silent winner.

## Active product lane — real scheduling UI
Issue #307 / Draft PR #308 — `feat(calendar): expose safe conflict advice in real UI`

Current reconciled head: `4b0da8bf64b0c1715ee9fc2d5c05ca1c067eb3c2`.

- real Home-accessible `تداخل‌ها` action on `CanonicalCalendarLauncher`;
- reuses merged `CalendarReschedulingAdvisor` directly;
- checks canonical Task/FollowUp reminders from the existing projection;
- Persian read-only sheet shows affected reminders and deterministic replacement times;
- explicit no-conflict result and explicit no-automatic-change message;
- no duplicate scheduling algorithm, model, storage or write path;
- fresh exact-head Fast CI is required before promotion to full Build/APK/Device.

## Automation lane — stale heavy PR gate guard
PR #282 — `ci: cancel stale heavy PR gates when main advances`

Current reconciled head: `5c59265ae65788f98772bed41028f60fd20f89c9`.

- product files untouched;
- examines only queued/in-progress PR `Arvin Build` / `Arvin Device Smoke` runs;
- uses immutable exact run `head_sha`;
- cancels only with positive compare evidence that a run no longer contains current main;
- uncertain evidence is skipped;
- no auto-merge/rebase/force-push and no cancellation of main validation or Parallel Fast Lane;
- fresh exact-head gates are running after #304.

## Scorecard lane
PR #306 — scorecard-only evidence reconciliation.

Current reconciled head: `be843a1a5248cd12666625ac164027aa6162d103`.

Evidence-backed candidate stages:
- #13 Smart Conflict Detection: 40
- #14 Smart Rescheduling: 40
- #15 Goal -> Project -> Item: 40
- #17 Privacy / Encryption: 85
- #18 Sync / Backup multi-device: 40

Candidate 19-feature extension metric: **37.4%**.
On the current-main reconciled head, Arvin Progress Score #30 and Parallel Wave #878 are green. The value becomes official only after the scorecard PR is merged.

#304 adds stronger Sync evidence but does not justify a stage increase above 40 because provider transport, persisted multi-device state and real user-facing conflict resolution remain open gaps.

## Documentation lane
PR #292 — this live record.

Documentation remains independent from product files and is refreshed after product merges so future chats can resume from GitHub reality rather than conversational memory.

## Current merge protocol
1. Let #308, #282 and #306 validate independently on current main.
2. Give #308 product delivery priority; do not move main with docs/automation while its heavy gates are active.
3. Promote #308 only after fresh exact-head Fast CI succeeds, then require full Build/APK/Device.
4. Merge only an exact fully-green head whose ancestry still contains current main.
5. After a product Merge, reconcile #282/#306/#292 again and discard old-base validation evidence.
6. Activate #282 once fresh current-main gates are green and it will not create avoidable product CI churn.
7. Merge #306 only from validator-backed evidence; update #13/#14 again only if the real UI merge earns a higher stage under the committed metric contract.

## Non-technical status
Four meaningful product steps have landed rapidly: canonical Sync revisions, Goal/Project progress, smart calendar rescheduling advice and full Task-set Sync planning. The real scheduling UI, GitHub runner automation, evidence-based progress reporting and documentation are continuing in parallel, with no direct main edits and no force-push.
