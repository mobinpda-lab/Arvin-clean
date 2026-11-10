# Arvin Final Repository Health Report — REV8

**Snapshot:** 2026-11-10  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Working branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Working/PR SHA:** `9846f10850031c63964fdc81ae0ab1cdb3028517`

## Executive status

**BLOCKED — RELEASE: NO-GO.** The governance and inventory evidence is substantially reconciled, but technical acceptance is not. Main remains read-only. PR #3052 remains OPEN / DRAFT / UNMERGED.

## Repository counts

| Question | Evidence-based answer |
|---|---:|
| Branches | 1,412 |
| Branches with open PRs | 100 |
| Branches without open PR | 1,312 (not automatically stale) |
| Duplicate branch-head groups | 35 groups / 109 refs |
| Open PRs | 100 |
| Open draft PRs | 75 |
| Open ready PRs | 25 |
| Open PRs not updated since 2026-11-01 | 99 |
| Closed PRs | 1,138 |
| Closed merged / unmerged | 629 / 509 |
| Reused PR head-branch groups | 33 groups / 72 PR records |
| Main-reachable commits | 1,812 |
| PR #3052 commits ahead | 2,130 |
| Main merge commits | 181 |
| Repeated Main commit-subject groups | 36 groups / 107 records |
| Same-tree Main commit groups | 148 groups / 300 records |
| Arvin test files | 302 (293 test/, 9 integration_test/) |
| Current exact-head failed tests | 78 unique labels |
| Current exact-head passed test executions | 1,296 |
| Workflow files on working branch / Main | 25 / 23 |
| Docs files on working branch / Main | 259 / 209 |
| Canonical continuity files before REV8 audit | 33 |
| Internal links checked in continuity docs | 99; 0 broken |
| Open / closed GitHub issues | 1,679 / 418 |
| Tags / Releases | 3 / 2; both releases are draft prereleases |

## PR #3052

- OPEN / DRAFT / UNMERGED.
- Base Main SHA matches Main HEAD.
- Head SHA matches authorized working branch.
- 2,130 ahead / 0 behind.
- 368 changed files: 123 added, 244 modified, 1 removed.
- 0 review submissions; 51 issue/PR comments.
- 99 other open PRs are stale candidates by update date; do not close automatically.

## Current exact-head CI

- Build 42795405617: FAILURE.
- Six shards: 1,296 passed / 78 failed; 78 distinct failing test labels.
- Analyze, Visual, Debug APK, Release APK build and Staging APK: SUCCESS.
- Calendar Provider 42795405362: SUCCESS.
- Follow-up Persistence 42795405561: SUCCESS.
- Device Smoke 42795405388: PENDING; physical device acceptance NOT VERIFIED.
- Current failures are not the historical 79 from SHA b789.

## Architecture status

- Canonical TaskStore/Drift schema v16 exists.
- Reminder four-state contract is incomplete in code; TaskReminder has isEnabled/isAllDay but no four-state enum.
- Auto-Save is product-approved but full-field persistence acceptance remains PARTIAL.
- Home/Quick Capture/filter, Follow-up/People, Checklist, Calendar, Notebook and Report tests have current failures.
- Notebook hard-delete preservation, Template deep-clone/date-base semantics, full Backup/Restore integrity, and Sync/P2P E2E remain NOT VERIFIED.
- One generic TaskStore interface and one unused TaskDetailPage callback are code cleanup candidates; no code was changed.

## NIRA health

- 112 branches; none protected.
- 7 open PRs; 381 closed (60 merged, 321 unmerged).
- 292 closed PRs are repeated `docs(nira): sync derived project state`; 289 are unmerged.
- 26 workflows; 23 factory tests; 132 Main commits.
- 30,005 workflow runs; latest 100 include 10 failures, 27 cancellations and 10 skips.
- Queue Scheduler run 42777810609 fails when posting to issue #162 (>2,500 comments).
- L10 remains UNVERIFIED.

## What was corrected / consolidated

- Complete branch inventory (1,412) and full PR inventory (1,238) were generated from GitHub pagination.
- Main commit history (1,812) and PR-ahead count (2,130) were reconciled.
- Exact-head CI failure count corrected from historical 79 to current 78.
- 302 Arvin test files and 23 NIRA factory test files inventoried.
- 99 internal links in all 33 pre-existing continuity files checked; zero broken.
- Duplicate branch heads, repeated PR heads, repeated commit subjects/tree SHAs, legacy docs, and NIRA state-sync churn registered.
- No code, tests, migrations, data, workflows, branches, PRs, tags, releases, or Main refs were deleted or modified by this audit.

## Remaining limitations

- Branch API does not expose last-commit dates for all 1,412 branches; 1,312 no-open-PR branches cannot safely be called stale/abandoned without per-branch commit-date and PR dependency review.
- All 1,238 PR metadata records are inventoried; CI/review evidence was not expanded individually for every closed PR.
- 3,942 reachable commit history records are reconciled structurally; every individual patch was not semantically reviewed.
- All 302 test paths are inventoried; historical/obsolete/flaky classification of every test is not complete.
- All 259 docs paths are counted; links in 226 docs outside continuity were not exhaustively checked.
- No local working tree or physical Android device state is available through this GitHub audit.

## Next execution order

1. Keep Release NO-GO.
2. Define the four Reminder states and transitions with Mobin before implementing.
3. Fix the 78 current test failures without weakening tests; begin with Home/filter/Quick Capture and Task Details.
4. Complete Device Smoke on the exact current SHA and verify on a physical device.
5. Verify Notebook deletion preservation, Template deep clone, recurrence/checklist history and real Backup/Restore integrity.
6. Repair NIRA scheduler feedback for issue #162 and make state-sync PR creation idempotent.
7. Review duplicate branches/PRs and dead-code candidates; request explicit approval before destructive cleanup.
