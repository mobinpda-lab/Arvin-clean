# PR #3547 ACCEPTANCE REPORT — COMMAND 60-R.1
**Observed:** 2026-11-19 / ۲۸ آبان ۱۴۰۵
**PR:** #3547 — OPEN / DRAFT / UNMERGED
**Head tested:** `1c83db84145675aa31e67feef95c23ddd84c181c`
**Build run:** `44417802140`
**Device Smoke run:** `44417802091`
**Follow-up Persistence run:** `44417801990`

## Exact-head result
| Gate | Result |
|---|---|
| Analyze | PASS |
| Test Shards 0, 1, 3, 4, 5 | PASS |
| Test Shard 2 | FAIL |
| Debug APK | PASS |
| Release APK | PASS |
| Device Smoke selected scenarios | PASS |
| Follow-up File Persistence | PASS |

## Root cause
Shard 2 exposed a real Person Directory data defect: after an owner removes a Person from the active directory, a subsequent `migrateTaskPeople` pass can reconstruct the directory entry from historical Task-person references. The expected behavior is to retain Task/Follow-up history while keeping the directory deletion effective.

This is not a reason to change the test expectation, skip the test, remove data, or weaken CI.

## Revalidation rule
PR #3549's later Build passing all six shards is evidence for PR #3549's SHA only. It does not transfer to PR #3547's head. PR #3547 must be re-run after the reviewed fix is integrated onto the canonical route, with all six shards and the complete Build on the exact resulting SHA.

## Decision
**NOT ACCEPTED / IN PROGRESS.** No merge or release authorization. The failing result remains part of the permanent history.
