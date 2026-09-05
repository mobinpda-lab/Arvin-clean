# Arvin Project State

## Purpose
Single recovery point for continuing development after interruption. GitHub is the source of truth; this file records only evidence verified from repository state, PR/Issue metadata, commits, and GitHub Actions.

## Current Mode
Maximum Speed Continuous Production Mode.

## Verified Checkpoint — 2026-09-01 15:15 +03:30

### Main
- Default branch: `main`.
- Verified main head: `2ee2adc22a45ab5fda1dcd548672ddaf77717afc`.
- Main head is merge commit for PR #605: `feat(calendar): add bounded read-only device event query`.
- Recent verified main milestones also include:
  - #601 Worker reliability hardening at `a9078ee58263b7d8fa8cf862305467992e178575`.
  - #598 Android device-calendar discovery at `a4c2a3eca5838808ed0dee7c389f2d0dce997ba6`.
  - #592 device-calendar settings foundation at `6dcb368db8565018384c4a6fb7aad9be22ea9e8c`.
  - #582 non-destructive backup restore confirmation at `377da2dfe0a5de6b998e2cfa520d13972918b4a9`.

### RC / Release Path
- Issue #612 records the RC Feature Freeze and one-canonical-path policy.
- Issue #614 records the active RC Closure + parallel Post-RC execution mode.
- Calendar provider-selection validation is still an active release path.
- PR #604 and PR #607 currently resolve to the same feature head SHA: `6cdd6cd49ecb038851cce76a2a37e9c499f139fb`.
- PR #607 describes itself as the canonical fresh Fast proof for that exact commit; PR #604 describes itself as the serial promotion lane.
- Current `main` advanced after those branches through #605. Compare evidence shows #607 is now `diverged`, ahead by 4 and behind by 1, with merge-base `a9078ee58263b7d8fa8cf862305467992e178575`.
- Therefore old exact-head validation remains evidence for `6cdd6cd...`, but merge promotion must reconcile against current main before final merge. Do not restart healthy historical evidence unnecessarily.

### CI / Build / Device Evidence for `6cdd6cd...`
Verified workflow runs on the exact feature head include:
- `Arvin Build` run 1605 — success.
- `Arvin Device Smoke` run 850 — success.
- `ARVIN Orchestrator` runs 83 and 84 — success.
- `ARVIN Production Loop` runs 240 and 242 — success.
- `Arvin Parallel Wave` run 1307 — success.
- Later duplicate `Arvin Build` run 1606 and `Arvin Device Smoke` run 851 were skipped; skipped runs are not counted as new positive proof.

### Production Orchestrator / Automation
- Production orchestration is active in repository workflow evidence.
- Main contains Worker reliability hardening from #601: one normal launch authority through ARVIN Orchestrator plus bounded patch-recount behavior.
- Issue #610 tracks the broader autonomous software-factory v2 operating model; it is not evidence that every proposed automation layer is already implemented.

### Calendar
- Main contains Android calendar discovery (#598), Calendar integration settings foundation (#592), and bounded read-only device event querying (#605).
- Provider-selection Settings work remains outside main on the `6cdd6cd...` validation head and must be reconciled with the #605 main advance before promotion.
- No WRITE_CALENDAR or bidirectional provider mutation is claimed by this checkpoint.

### Backup
- Main contains the verified non-destructive restore confirmation change from #582.
- No newer verified Backup change was found in the repository evidence used for this checkpoint.

### Core / Data
- No new verified Core/Data schema or storage migration was identified in the repository changes inspected for this checkpoint.
- Existing production data architecture must remain unchanged unless a future merged PR proves otherwise.

### Parallel Post-RC Tracks
- Issue #613: Smart Multi-Instance FollowUp Engine — open Post-RC feature track.
- PR #611: Multi Device Sync Architecture v15 — open Draft documentation track; direct device-to-device and offline-first are design priorities, not yet claimed as merged implementation.
- PR #609: resilient production checkpoints — this branch carries `PROJECT_STATE.md`, `ROADMAP_QUEUE.md`, and `DECISIONS.md`.

## Current Priority
1. Preserve healthy evidence for the Calendar selection head.
2. Reconcile the Calendar promotion lane with current main without reopening product design.
3. Run only the exact-head gates required after reconciliation.
4. Keep independent Post-RC preparation parallel and isolated from RC.

## Release Rules
- No new feature enters RC.
- Old or superseded PRs are historical evidence, not production blockers.
- One canonical promotion path per feature after reconciliation.
- CI, Build/APK, and Device proof must match the exact candidate head used for promotion.
- Skipped, stale-head, or failed runs do not count as passing evidence.
- Documentation work must not rewrite or invalidate healthy product-validation branches.

## Recovery Order
1. Read this file.
2. Verify latest `main` SHA.
3. Verify open release PR heads and compare them with `main`.
4. Check exact-head workflow evidence.
5. Read `ROADMAP_QUEUE.md` and `DECISIONS.md`.
6. Continue only from evidence-backed state.

## History
- Initial resilient workflow checkpoint created on PR #609.
- 2026-09-01: refreshed from live GitHub evidence after RC freeze/execution Issues #612/#614 and after main advanced through Calendar event-read PR #605.
