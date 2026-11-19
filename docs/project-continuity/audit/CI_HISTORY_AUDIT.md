## Current exact-head CI refresh — 2026-11-10

All Arvin runs below target `a934cabebc814aea13c1800ab151821d12714226`.

| Workflow | Run ID | Result |
|---|---:|---|
| Arvin Build | 42801502260 | FAILURE — 6 shards, 1,296 passed / 78 failed |
| Device Smoke | 42801502310 | PENDING |
| Calendar Provider Acceptance | 42801502275 | SUCCESS |
| Follow-up File Persistence | 42801502256 | SUCCESS |
| Draft Review APK | 42801502270 | SUCCESS |
| G1 lock sync | 42801502295 | SUCCESS |
| Orchestrator PR Wakeup | 42801502306 | SUCCESS |
| Production Loop | 42801502548 | SUCCESS |
| Parallel Wave | 42801502735 | SUCCESS |
| Orchestrator | 42801502768 | SUCCESS |

Shard pass/fail: 0=299/25, 1=194/6, 2=184/10, 3=148/12, 4=231/14, 5=240/11. Device Smoke job list was empty while pending; no device acceptance is inferred.

---

# Arvin CI History Audit — REV8

**Current exact SHA:** `9846f10850031c63964fdc81ae0ab1cdb3028517`

## Current exact-head runs

| Workflow | Run ID | Status | Conclusion |
|---|---:|---|---|
| Arvin Build | 42795405617 | completed | FAILURE |
| Device Smoke | 42795405388 | pending | NOT COMPLETE |
| Calendar Provider Acceptance | 42795405362 | completed | SUCCESS |
| Follow-up File Persistence | 42795405561 | completed | SUCCESS |
| Draft Review APK | 42795404991 | completed | SUCCESS |
| G1 Lock Sync | 42795405168 | completed | SUCCESS |
| Parallel Wave | 42795405940 | completed | SUCCESS |
| Production Loop | 42795405588 | completed | SUCCESS; feedback step SKIPPED |
| Orchestrator | 42795404989 | completed | SUCCESS |
| Orchestrator PR Wakeup | 42795405041 | completed | SUCCESS |

## Build jobs

- Analyze: SUCCESS.
- Visual structural smoke: SUCCESS.
- Debug APK: SUCCESS.
- Release APK build: SUCCESS.
- Staging APK/signing: SUCCESS.
- Six quality test shards: all FAILURE.

| Shard | Job ID | Passed | Failed |
|---|---:|---:|---:|
| 0 | 129759216113 | 231 | 14 |
| 1 | 129759216673 | 194 | 6 |
| 2 | 129759216164 | 299 | 25 |
| 3 | 129759215931 | 148 | 12 |
| 4 | 129759215878 | 240 | 11 |
| 5 | 129759216126 | 184 | 10 |
| **Total** | | **1,296** | **78** |

All 78 failing labels were unique across the six shard logs. They cluster around Home/filter behavior, Quick Capture, Task Details/checklist/due dates, Follow-up Office/People, Calendar, Notebook, reports/PDF, and one export-contract RangeError. See `TEST_INVENTORY.md` for the full failed-test list.

## Device Smoke

Run 42795405388 is PENDING and has no completed job records. No physical-device acceptance is established. Do not infer Device Smoke PASS from APK build or Calendar Provider PASS.

## Historical comparison

Build 42763952581 ran on `b789343c...` and reported 79 failures. That count is historical. The current exact-head count is 78. No result was transferred between SHAs.

## Workflow inventory

- Working branch tree: 25 workflow files.
- Main tree: 23 workflow files.
- PR #3052 changes 10 workflow files: 2 added and 8 modified.
- Workflow overlap candidates exist across orchestrator, production-loop, factory-worker, task-dispatcher, test-worker, and recovery-dispatcher families. No workflow was disabled or deleted in this audit.

## NIRA operational signals

- NIRA Queue Scheduler run 42777810609: FAILURE.
- NIRA Main Closure run 42777826931: SUCCESS.
- NIRA Failure Feedback run 42777796050: SUCCESS.
- NIRA Production Orchestrator run 42777795705: SUCCESS.
- The scheduler log shows a 403 while attempting to comment on issue #162: GitHub disables commenting on issues with more than 2,500 comments. This failure occurs in the scheduler's error-reporting path and may mask the original dispatch error.
- NIRA's latest 100 workflow runs: 53 success, 10 failure, 27 cancelled, 10 skipped. Total recorded runs: 30,005.

No tests were removed, skipped, bypassed or weakened.
