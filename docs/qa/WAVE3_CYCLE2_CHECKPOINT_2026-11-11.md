# ARVIN — WAVE 3 / CYCLE 2 CHECKPOINT
**Date:** 2026-11-11 (UTC)  
**Repository:** mobinpda-lab/Arvin-clean  
**Governance:** ARVIN-MASTER-CHARTER-REV9  
**Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db` (protected)  
**Protected PR #3052 HEAD:** `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`  
**Release:** NO-GO

## Executive result
Cycle 2 is **INCOMPLETE**. No merge, release, deletion, branch archival, PR closure, schema change, or Main write was performed. PR #3052 and PR #3340 remain open and unmerged. Main remains unchanged.

## A — Product repair

### PR #3052 exact-head test evidence
Exact HEAD `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; Build run `42867838702`.
- Analyze: PASS.
- Release APK, Debug APK, Staging APK, Visual: PASS.
- Test shards: 6/6 FAILED; **1,297 passed / 82 failed**.
- Per-shard results: test-0 232/14; test-1 196/5; test-2 298/27; test-3 148/12; test-4 240/11; test-5 183/13 (passed/failed).
- Failures cluster across distinct contracts: Home/filter/shell visibility; Quick Add controls and picker; Task editor due-date/recurrence; Notebook canonical taxonomy/tag selection; Checklist visibility/CRUD; Follow-up history/office and due-date isolation; SQL migration envelope parity; Calendar launcher/detail keys; Report Center; People; PDF grouping; visual color/geometry assertions.
- Evidence does **not** support one universal cause: different shards show independent finder/contract mismatches, missing canonical state, expected-vs-actual model values, and one deterministic SQL envelope parity failure.
- P0 migration diagnosis: on SQLite reopen, `SqlTaskMigrationWriter._assertExistingTaskParity` fails before relation parity checks with **mismatched key: `followUpEnabled`**. The test is `preserves complete Follow-up history across closing and reopening SQLite`. This localizes the blocker to retired Follow-up compatibility-envelope parity, not proven loss of Follow-up rows. Exact direction/value of the mismatch still requires a focused assertion and regression.
- Diagnostic child PR **#3356**: `fix/wave3-cycle2-sql-envelope-parity`, head `f9cb078953e31e3f99f2685d689a0b1a5cb581fa`, draft/open, targets protected #3052 branch. It only reports mismatched key names; it does not fix migration semantics. Its inherited suite remains failing. Do not merge.

### PR #1901
PR #1901 remains OPEN, not draft, unmerged; head `ba8e26c2388c4b74bc0ecc40cf50b0fd0b02960a`; 86 commits ahead / 645 behind current Main; 27 changed files. It contains product work across Home, Quick Add, Notebook, Task editor, taxonomy, TaskStore, model, tests and contracts. This is too divergent for wholesale cherry-pick. Selected behavior requires per-feature diff against current Main and focused tests; no PR #1901 code was ported in this cycle.

### Database PRs #2959 and #2961
Both remain open/unmerged and each is a single test-only commit on an older Main base (`18cbeecc...`), 172 commits behind current Main. Their original tests were reviewed:
- #2959: file-backed Project/Task membership survives closing and reopening SQLite.
- #2961: legacy reminder migration, stable IDs, multiple reminders, edit/delete, repeated reopen, idempotency.
A current-Main test-only rebuild is PR **#3348**, head `2b3bc278b444f45ffd522f7a06a6480a2c59cd68`, draft/open, based directly on current Main. Exact-head Analyze PASS; all six test shards PASS: **1,094 tests passed, 0 failed**. Release/Debug APK builds were still in progress at checkpoint; Device Smoke selected scenarios were partly running/queued. Therefore CI is promising but not fully complete. PR #3348 adds tests only; it does not yet establish Backup/Restore or all migration compatibility.

## B — Historical recovery
- The requested continuation was performed exactly once: Page 4 / Chunk 2 / `slice(10,20)`.
- Raw response saved at `docs/qa/historical-recovery/page-4-chunk-2-prs-417-426.json` on this evidence branch.
- Source query: closed+all PR API, ascending created, page 4, 100 records; slice yields PR #417–#426.
- Integrity: 10 records, 10 unique PR numbers, required fields `id, number, state, title, created_at, updated_at, head, base` all present.
- Cumulative 400 is a reported checkpoint total, not revalidated here.
- Historical Set A (198 IDs): original source and exact identities **not recovered**.
- Historical Set B (509 IDs): prior checkpoint reported 509 closed-unmerged IDs, but the original 509-member artifact is not available here; membership is **not independently proven**. A separate live closed-PR snapshot previously reported 509 null-`merged_at` entries, but that does not prove identity with Historical Set B.
- No intersection, subset, or difference calculation is valid. **311 remains unverified.**

## C — Duplicate HEAD inventory (35 groups)
Compared each recorded group HEAD against current Main SHA `45e4202b...`. Classification is preliminary and intentionally non-destructive:
- 18 groups: zero commits ahead; the group HEAD is already an ancestor of Main. Marked **ARCHIVE CANDIDATE**, pending PR/branch reference mapping and dependency check.
- 17 groups: one or more commits ahead and diverged from Main. Marked **INVESTIGATE**; unique commits may contain valuable work.
- No group is marked DELETE CANDIDATE or MERGE CANDIDATE because branch-to-PR mapping, open review state, and hidden dependencies have not yet been proven. No refs were changed.

| Group | HEAD | Branches sharing this HEAD | Ahead | Behind | Status |
| 01 | `4e9312a18ac6` | backup/wave-6-58-pr-2913-4e9312a-20261022; backup/wave-6-62-pr-2913-4e9312a-20261022; backup/wave-6-63-pr-2913-4e9312a-20261022 | 12 | 190 | **INVESTIGATE** |
| 02 | `80d3100e9107` | backup/wave-6-73-pr-2913-pre-audit; docs/wave-6-10-exact-sha-evidence | 18 | 190 | **INVESTIGATE** |
| 03 | `4da8c895edcc` | backup/wave-6-73-pr-2918-pre-audit-4da8c89; backup/wave-6-76-pr2918-4da8c895 | 52 | 172 | **INVESTIGATE** |
| 04 | `aebe4a9e4f2d` | chore/product-first-autonomous-queue-2; chore/product-first-autonomous-queue-3; chore/product-first-autonomous-queue-4; chore/product-first-autonomous-queue-5; chore/product-first-autonomous-queue-final; chore/product-first-autonomous-queue-final-2 | 0 | 892 | **ARCHIVE CANDIDATE** |
| 05 | `c9dfc657cd6d` | ci/device-exact-ref-lane; device/device-exact-ref-ci; gate/device-exact-ref-ci | 0 | 1385 | **ARCHIVE CANDIDATE** |
| 06 | `c1802683d469` | ci/issue-200-exact-head-gate; gate/pr-201; gate/recheck-pr-201 | 0 | 1458 | **ARCHIVE CANDIDATE** |
| 07 | `fb8e3b32c1ba` | ci/pr-242-exact; device/pr-242-exact; feat/issue-241-semantic-search-v1; gate/pr-242-exact | 0 | 1380 | **ARCHIVE CANDIDATE** |
| 08 | `3aa851f120be` | device/validate-366-v2; feat/357-follow-up-entry-default; gate/validate-366-v2; wave/validate-366-v2 | 5 | 1246 | **INVESTIGATE** |
| 09 | `2626a5f9ee43` | diagnostic/calendar-editor-callback-trace-wave-7-48; wave-7-55-probe-no-code | 248 | 172 | **INVESTIGATE** |
| 10 | `6acff3ca490c` | docs/arvin-canonical-authority-final2; docs/arvin-canonical-cleanup-2026; docs/canonical-authority-cleanup | 0 | 861 | **ARCHIVE CANDIDATE** |
| 11 | `943bfdcfb7ee` | docs/issue-305-progress-reconcile-post-304-ci; docs/issue-305-progress-reconcile-post-304-ready; docs/issue-305-progress-reconcile-post-304 | 1 | 1286 | **INVESTIGATE** |
| 12 | `36f05599e17e` | feat/calendar-product-redesign-20260930-v2; feat/calendar-product-redesign-20260930 | 0 | 610 | **ARCHIVE CANDIDATE** |
| 13 | `6cdd6cd49ecb` | feat/calendar-provider-selection-settings-v2; feat/calendar-provider-selection-settings-v3 | 4 | 1025 | **INVESTIGATE** |
| 14 | `750648a07827` | feat/issue-195-notebook-core; gate/recheck-pr-198 | 0 | 1455 | **ARCHIVE CANDIDATE** |
| 15 | `dcd5bc311181` | feat/issue-195-pdf-print-core; gate/pr-196 | 0 | 1457 | **ARCHIVE CANDIDATE** |
| 16 | `10be46374d22` | feat/issue-195-prayer-times-core; gate/pr-197 | 0 | 1451 | **ARCHIVE CANDIDATE** |
| 17 | `1b5f15023d0a` | feat/issue-314-confirmed-reschedule-ui-clean; fix/device-feedback-2026-08-27-ui-jalali-swipe; fix/device-feedback-2026-08-27-ui-jalali-swipe-2; fix/device-feedback-2026-08-27-ui-jalali-swipe-final; fix/device-feedback-2026-08-27-ui-jalali-swipe-use; fix/device-feedback-final-use; fix/device-feedback-jalali-home-swipe; fix/device-feedback-live; fix/device-feedback-live-2; fix/device-feedback-live-3; fix/device-feedback-live-final; fix/device-feedback-use-this; fix/device-feedback-use-this-2 | 0 | 1279 | **ARCHIVE CANDIDATE** |
| 18 | `8bbf3f39a46b` | feat/project-plan-codec-main-v2-build; feat/project-plan-codec-main-v2-check; feat/project-plan-codec-main-v2-heavy; feat/project-plan-codec-main-v2-nondraft; feat/project-plan-codec-main-v2-pr; feat/project-plan-codec-main-v2-review; feat/project-plan-codec-main-v2 | 2 | 1067 | **INVESTIGATE** |
| 19 | `bc88df1118b6` | feat/simple-notebook-session-independent; wave/followup-calendar-bridge-v2 | 0 | 1673 | **ARCHIVE CANDIDATE** |
| 20 | `f9cb98e41d15` | feat/ui-reconstruction-v1; fix/calendar-ci-overflow; fix/task-trash-calendar-regression | 0 | 1687 | **ARCHIVE CANDIDATE** |
| 21 | `162993f38c16` | feat/work-agenda-report-adapter-main-v3-build; feat/work-agenda-report-adapter-main-v3-check; feat/work-agenda-report-adapter-main-v3-heavy; feat/work-agenda-report-adapter-main-v3-nondraft; feat/work-agenda-report-adapter-main-v3-pr; feat/work-agenda-report-adapter-main-v3-review; feat/work-agenda-report-adapter-main-v3 | 2 | 1067 | **INVESTIGATE** |
| 22 | `d3d5664b3261` | feature/production-fast-track; feature/wave1-architecture-foundation | 0 | 1572 | **ARCHIVE CANDIDATE** |
| 23 | `cb0337f01688` | fix/arvin-device-smoke-contract-20260924; gate/arvin-1490-validation-20260924 | 65 | 714 | **INVESTIGATE** |
| 24 | `c766f9f07e3b` | fix/calendar-manual-retry-reconcile-main-20261002; fix/2144-calendar-visual-main-20261002; fix/2155-taxonomy-row-main-20261002 | 0 | 569 | **ARCHIVE CANDIDATE** |
| 25 | `9e3811815bb9` | fix/home-appearance-contract-current-main; fix/taxonomy-refresh-current-main | 0 | 608 | **ARCHIVE CANDIDATE** |
| 26 | `bf68c54fc72a` | fix/home-followup-latest-view; fix/home-show-latest-followup-v2 | 0 | 1598 | **ARCHIVE CANDIDATE** |
| 27 | `abf0d19012ae` | fix/issue-221-canonical-backup; gate/pr-222; refactor/issue-225-canonical-home | 0 | 1430 | **ARCHIVE CANDIDATE** |
| 28 | `4e4579e3049e` | gate/post-notebook-pr-197; gate/recheck-pr-197 | 1 | 1456 | **INVESTIGATE** |
| 29 | `541943967062` | gate/post-notebook-pr-209; gate/recheck-pr-209 | 1 | 1456 | **INVESTIGATE** |
| 30 | `562832689556` | gate-placeholder-not-used; noop-do-not-use | 0 | 1387 | **ARCHIVE CANDIDATE** |
| 31 | `ac827a833627` | nira/issue-658-calendar-target-label; nira/security-evidence-659 | 9 | 1010 | **INVESTIGATE** |
| 32 | `dfef3a5e143f` | rebase/reminder-migration-tombstone-20261016; test/reminder-migration-tombstone-20261016 | 1 | 300 | **INVESTIGATE** |
| 33 | `7b7dd55c77c8` | reconcile/326-clean; reconcile/326-final; reconcile/326-work; reconcile/326-work2 | 14 | 1266 | **INVESTIGATE** |
| 34 | `c4b52c724810` | test/calendar-task-lifecycle-current-main; test/calendar-task-lifecycle-current-main-v2 | 1 | 607 | **INVESTIGATE** |
| 35 | `1a698d6f0184` | wave/followup-integration-v1; wave/followup-office-v3 | 5 | 1678 | **INVESTIGATE** |

## Durable next actions
1. On the #3356 child branch, add a focused regression that captures both existing and expected envelope values for `followUpEnabled` (without exposing user data); determine which side is stale and align legacy compatibility serialization without reviving active Follow-up scheduling. Then rerun only the focused test and full exact-head CI.
2. Continue product repair by independent failure clusters; do not alter #3052 directly. First P0: migration envelope parity. Next P1: dueDate persistence/independent reminder semantics, Home and Quick Add canonical contracts, Notebook taxonomy, Checklist persistence.
3. Wait for exact-head #3348 APK and Device Smoke outcomes. Extend database coverage to Backup/Restore and real old-schema migration only after safe backup fixture exists.
4. Recover Set A's original 198-ID source and the actual Set B 509-ID artifact. Do not derive either from counts.
5. For all 35 HEAD groups, map each branch to open/closed PRs and inspect latest commit message/ancestry and dependent references. Only then refine ARCHIVE CANDIDATE / INVESTIGATE into final safe actions.
6. Preserve all historical raw JSON and REV9 canonical docs. Keep Local-First, SQLite source-of-truth, Multi-device Sync suspended.

## Guardrail audit
- Main untouched; #3052 untouched; #3340 untouched.
- No tests deleted or skipped.
- No data or historical source deleted.
- No schema/migration behavior changed.
- No merge/release, branch deletion, branch archival, or PR closure.


## WAVE 3 / CYCLE 3 — execution update (2026-11-11)

### Workstream A — P0 SQLite
- Created independent child branch `fix/wave3-cycle3-followup-envelope` from diagnostic child #3356.
- Root cause is now localized: `G1DriftSchema.migrateCanonicalEntities` synthesizes `followUpEnabled: false` even when the original SQL schema has no `follow_up_enabled` column. On the next migration pass, the synthetic key conflicts with a source envelope where the key is absent.
- Implemented conditional preservation: materialize the value only if the legacy SQL column exists.
- Updated Task legacy metadata decoding to preserve an explicitly stored `false` value as inert metadata.
- Added regression coverage for fresh-schema reopen parity, independent Due Date, no reminder creation from Follow-up history, and false-value model round-trip.
- Draft PR #3364 created against the #3356 branch. Exact-head SHA: `dfff2ffb5e15272f614b2126ad4237441281138d`.
- Tests/CI on this SHA: PENDING. No merge.

### Workstream B — PR #3348 Device Smoke recovery
- Verified #3348 exact head `2b3bc278b444f45ffd522f7a06a6480a2c59cd68`: 1,094 tests passed; Analyze and Debug/Release builds passed; Calendar Device Smoke failed before interaction at the missing selected-day list.
- The Task and two independent Reminder records had already survived a fresh TaskStore reload. The failure is before the UI card assertion; it is not evidence of SQLite data loss.
- Created isolated branch `test/wave3-cycle3-device-smoke-recovery` and draft PR #3365 against #3348.
- Changes: satisfy the exact Fast Lane checkout contract without using PR merge refs; add stable primary-navigation destination keys; navigate to Calendar by key and wait for the Calendar surface before asserting.
- Exact-head SHA: `4508902e0c772c80f975fc86a49d19a4f5c814a5`. CI: PENDING. #3348 remains unchanged and open/draft.

### Workstream C — product editor repair
- Created isolated branch `fix/wave3-cycle3-calendar-product-repair` from protected #3052 head.
- Found an existing editor regression gap: editor save omitted `legacyFollowUpMetadata`, so unrelated edits could discard retained legacy compatibility metadata.
- Updated editor save to retain this metadata without activating legacy Follow-up scheduling.
- Corrected the regression fixture to use a canonical `TaskReminder`; the deprecated direct constructor `reminderDate` is intentionally not an active Reminder.
- Added assertions that Due Date, independent Reminder, inert legacy metadata and Follow-up history survive editor save.
- Draft PR #3366 created against protected #3052 branch. Exact-head SHA: `d4b16b1600b5daaf721f3f007584ae6d0b70e961`. CI: PENDING. No merge.

### Workstream D — historical recovery
- Verified the saved Page 4 / Chunk 2 JSON: 10 records, PR #417–#426, 10 unique numbers; all required checkpoint fields present. Existing JSON path unchanged.
- Continued with PR #427–#436 and saved a separate normalized extraction at `docs/qa/historical-recovery/page-4-chunk-3-prs-427-436.json`.
- Important provenance limitation: the GitHub connector exposes normalized per-PR fields but not the REST numeric `id` or the raw 100-record list page. Those IDs are explicitly null and no raw-response equivalence is claimed.
- Slice findings: #427, #428, #430, #432 and #435 are merged; #429, #431, #433, #434 and #436 are closed unmerged. #429 says superseded by #433; #433's single-alarm arbiter and #431's notification reuse still need current-Main equivalence/dependency checks. #434's due-date editor needs comparison with current Main; #436's archive action needs current UI equivalence.
- Historical Set A (198 IDs) source and Set B (509 IDs) membership remain unproven. No intersection/difference arithmetic is valid.
- 35 duplicate-HEAD groups remain non-destructive: 18 archive candidates and 17 investigate groups from prior evidence. Dependency/product-equivalence mapping still pending.

### Current guardrails
- Main remains untouched at `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3052 and #3340 remain untouched/open.
- #3348 remains open/draft.
- New PRs #3364, #3365 and #3366 are open/draft; no merge or release.
- No PR closed, branch deleted/archived, test skipped, or migration data removed.
- Release remains NO-GO.


### 35 duplicate-HEAD groups — CYCLE 3 verification completed
- Rechecked all 35 representative refs against Main SHA `45e4202b03a434459e4c021a04efa7e8396359db`; each ahead/behind count exactly matches the recorded inventory.
- Verified all 109 branch names still exist.
- Compared all 74 non-representative branch refs against their group representative; every comparison returned `identical`, 0 ahead / 0 behind.
- Confirmed 18 groups have zero commits ahead of Main and 17 have unique ancestry ahead.
- Product/dependency review is recorded in `docs/qa/WAVE3_CYCLE3_DUPLICATE_HEAD_REVIEW_2026-11-11.md`.
- Important dependencies/equivalence: #2913/#2918 open and preserved; #2989 open diagnostic-only and preserved; #357 completed; #464/#670 and #1532/#197/#209/#326 merged equivalents; #32 tombstone test file exactly matches Main; group 34's legacy Follow-up-history projection test conflicts with the current canonical Calendar contract and must not be ported.
- No group is authorized for deletion or archival. No branch, PR or ref was changed.

### Historical Set A / Set B search
- Exact-label, ID-count and likely artifact-name searches returned no original 198-ID Set A source and no original 509-member Set B artifact.
- Set A identities and Set B membership remain UNVERIFIED; no intersection/difference arithmetic is valid.

### Exact-head CI observations after first Cycle 3 implementation
- PR #3364 first implementation head `dfff2ffb5e15272f614b2126ad4237441281138d`: Analyze and APK builds passed, but test shards remained red. The explicit legacy `followUpEnabled=false` metadata regression passed. Reopen parity still failed; its top-level mismatch diagnostic reported an empty key list, exposing a second synthetic-null issue.
- Root cause refinement: schema migration also inserted `reminderDate:null` and `followUpDate:null` from absent SQL-column aliases. Those are not historical values and produce an envelope mismatch with no differing non-null key. The fix now preserves these fields only if their source SQL columns existed.
- PR #3364 latest pushed head: `06c57bc20ec9bc415e705684206a52cd95e82dad`. Build run `42973881233` queued at checkpoint refresh; result pending.
- PR #3365 head `4508902e0c772c80f975fc86a49d19a4f5c814a5`: exact-head Build run `42972151218` passed Analyze, all six test shards and Debug/Release APKs. Device Smoke run `42972151243` remained queued.
- PR #3366 latest head: `c1118f0803e1cefdaeaa468793e255647b9e70ac`. The canonical editor regression passed. The inherited Task Detail Due Date test fixture has been changed to use an explicit canonical TaskReminder rather than deprecated direct constructor input; exact-head CI after this update is pending.


### Latest Cycle 3 checkpoint refresh — 2026-11-11 (GitHub event timestamp 06:45 UTC; no runtime-local clock assertion)
- Documentation/evidence continuation submitted as draft PR #3369, base `docs/wave-3-cycle-2-evidence-2026-11-11`, head branch `docs/wave3-cycle3-historical-recovery`. PR head before this refresh: `b19def8f11f3b148c796177663f183b15602f57e`; this checkpoint update advances the branch again.
- PR #3364 latest head `c1fef37096138485a8f906b748b1622bf4ceea8e`: root-cause patch now avoids synthetic false and null legacy metadata; parity diagnostics distinguish missing vs explicit null. Exact-head Build run `42974329525` had not started jobs yet; Follow-up file-backed persistence run `42974329448` queued. Final regression result pending.
- PR #3365 latest head `4508902e0c772c80f975fc86a49d19a4f5c814a5`: Build run `42972151218` SUCCESS (Analyze, six test shards, Debug and Release APK). Device Smoke run `42972151243`: prepare, People, Backup/Restore, SQL Persistence, Home, Quick Capture and SQL Migration SUCCESS; Calendar job `130362894801` still IN_PROGRESS. Device validation is not complete.
- PR #3366 latest head `c1118f0803e1cefdaeaa468793e255647b9e70ac`: canonical Task Editor regression and Task Detail Due Date/Reminder fixture updated. Build run `42973888541`: test shard 3 IN_PROGRESS; remaining shards and APK jobs queued. Final result pending.
- Protected PR state rechecked: #3052 OPEN/DRAFT, #3340 OPEN/READY, #3348 OPEN/DRAFT, #3356 OPEN/DRAFT. No changes to their heads.
- Cycle 3 remains INCOMPLETE; Release remains NO-GO. No merge, closure, archive, deletion, or Main update.


### Latest run outcomes after the checkpoint refresh
- PR #3364 exact head `c1fef37096138485a8f906b748b1622bf4ceea8e`:
  - `Arvin Follow-up File Persistence` run `42974329448` SUCCESS. This validates independent Reminder file-backed persistence/snooze lifecycle, not the migration-envelope regression itself.
  - `Arvin Build` run `42974329525` still PENDING; Device Smoke run `42974329442` PENDING. The migration Reopen Regression is not yet proven green.
- PR #3365 previous head `4508902e0c772c80f975fc86a49d19a4f5c814a5`:
  - Build SUCCESS; Device Smoke FAILED on Calendar because the test waited for nonexistent `calendar-date-triplet`.
  - The device log proves SQLite reload, both Reminder projections, independent Due Date projection and all three expected Card keys were present. Navigation reached the Calendar page.
  - Corrected the test to wait for the real `calendar-selected-day-list` key. New exact head: `50f99c743b6dc5192b01fc87733d3a1eaa4e7a51`; Build and Device Smoke runs `42974843650` / `42974843683` QUEUED.
- PR #3366 exact head `c1118f0803e1cefdaeaa468793e255647b9e70ac`:
  - `Arvin Follow-up File Persistence` run `42973888593` SUCCESS.
  - Build run `42973888541` QUEUED; Device Smoke `42973888770` PENDING. Updated Task Detail fixture now uses a canonical TaskReminder; the new exact-head regression result remains pending.
- PR #3369 documentation head was advanced by this checkpoint update; it remains OPEN/DRAFT, based on the Cycle 2 evidence branch.
- No product or device acceptance gate is green end-to-end yet. Cycle 3 remains INCOMPLETE and Release NO-GO.


### Cycle 3 continuation — refreshed exact-head evidence and historical page 4

#### Workstream A — SQLite / Follow-up
- Source-of-truth boundary: `follow_up_enabled` is a retired legacy SQL compatibility field, preserved only as inert metadata when the legacy source column exists. The actual boolean value `false` is preserved; it must not create or enable a Reminder. Canonical Follow-up history remains the append-only FollowUp records, not the legacy flag/date.
- Legacy schema regression was extended with a third fixture: legacy `follow_up_enabled=0` and no `follow_up_date`. The previous exact-head run failed because the test still expected 2 rows after introducing 3 fixtures. Corrected the expected count to 3; this is a test-fixture count correction, not a production-data mutation.
- PR #3364 latest head: `d98f19b025b649f9de3b92fd9f9a28a4514c9f80`.
  - Follow-up file-backed SQLite persistence run `42977362567`: SUCCESS.
  - Build run `42977362768`: Analyze SUCCESS; visual SUCCESS; test shards and APK staging/debug/release still IN PROGRESS at last poll.
  - Device Smoke run `42977362644`: PENDING.
  - Therefore the new three-fixture regression and Reopen envelope parity are not yet proven green on the latest head.
- Previous Build run on parent head `c1fef37096138485a8f906b748b1622bf4ceea8e` exposed the test fixture count mismatch in `g1_drift_schema_test.dart`; this was fixed in `d98f19b...`. It also showed multiple existing UI/widget test failures. Do not claim the parent-head CI is passing.

#### Workstream B — PR #3348 Device Smoke completion path
- Original PR #3348 head `2b3bc278b444f45ffd522f7a06a6480a2c59cd68`: Build SUCCESS, but Device Smoke run `42968820801` FAILED only in Calendar; Home, Quick Capture, People, SQL Migration, SQL Persistence and Backup/Restore passed.
- The Calendar failure was a route/FutureBuilder timing race: the integration test asserted `calendar-selected-day-list` immediately after navigation, before the official Calendar surface mounted.
- Follow-up PR #3365 head `50f99c743b6dc5192b01fc87733d3a1eaa4e7a51`: Build run `42974843650` SUCCESS; Device Smoke run `42974843683` SUCCESS across all seven lanes: Home, Quick Capture, People, SQL Migration, SQL Persistence, Backup/Restore and Calendar.
- PR #3348 itself remains OPEN/DRAFT and its original exact-head smoke remains red. PR #3365 supplies a green downstream repair/evidence branch; do not describe #3348 as independently green or ready for acceptance until its own target head is validated.

#### Workstream C — editor / due-date separation
- PR #3366 latest head: `a9c2b8711be76738c7dda08c7befe6969b4c88a5`.
- Its exact-head Build run `42977379696`: Analyze SUCCESS; six test shards and APK staging/debug/release jobs queued/in progress at last poll. File-backed Follow-up persistence run `42977380150`: SUCCESS. Device Smoke `42977380188`: PENDING.
- This branch includes `lib/task_editor_dialog.dart` plus regression tests. Existing focused tests on the preceding head confirmed manual Reminder is not overwritten by Due Time changes and canonical Due Date is independently preserved; the final branch still requires full exact-head CI and Device Smoke.

#### Protected PRs / release gates
- #3052 remains OPEN/DRAFT, head `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; exact-head Build FAILED and Device Smoke CANCELLED. Protected; unchanged.
- #3340 remains OPEN/READY (non-draft), head `28f2a57c8feb61c8e587e93955f32685b930b2d7`; Build and Device Smoke SUCCESS. Protected; unchanged.
- #3356 remains OPEN/DRAFT, head `f9cb078953e31e3f99f2685d689a0b1a5cb581fa`; Build FAILED, Device Smoke QUEUED. Unchanged.
- Release remains NO-GO. No merge, close, deletion, archive, direct Main update, or Multi-device Sync activation.

#### Historical recovery — page 4
- Verified existing Chunk 2 file (#417–#426) and Chunk 3 file (#427–#436) against the exact page-4 raw REST list response.
- Chunk 3 was upgraded from normalized metadata to raw REST records, restoring the actual numeric IDs; all 10 PR numbers matched the prior checkpoint exactly.
- Added Chunk 4 raw JSON at `docs/qa/historical-recovery/page-4-chunk-4-index-30-39.json`: page 4, `slice(30,40)`, 10 unique records with raw IDs present. Actual PR numbers in source order: #437, #439, #440, #441, #442, #443, #445, #448, #449, #450. Gaps are present in the raw page slice and were not filled by inference.
- Historical Set A (198 IDs) and Set B (509 members) original source artifacts still not located; membership/intersection remain UNVERIFIED.


### Cycle 3 latest refresh — 2026-11-11 (UTC event times in Actions)

#### SQLite regression follow-up
- PR #3364 was advanced to `2238fa063faf781ea905f861fb0ae8f58ccf6d57`.
- On the immediately preceding head `d98f19b...`, exact-head logs showed these targeted regressions PASS:
  - complete Follow-up history survives closing/reopening the same SQLite file;
  - explicit legacy `followUpEnabled=false` survives as inert metadata;
  - G1 pre-taxonomy upgrade preserves task data;
  - legacy disabled reminders remain disabled after database close/application restart;
  - migrated reminder backup/restore does not resurrect deleted reminders;
  - SQL migration preserves original JSON envelope byte-for-byte and is idempotent.
- That run also exposed one legacy Home serializer test asserting retired `dateTime`; canonical Follow-up serialization uses `completedAt`. The test now asserts `completedAt` and absence of `dateTime` in commit `2238fa0...`.
- New exact-head Build run `42978067648`, Device Smoke `42978067622`, and Follow-up persistence run `42978067609` were PENDING/QUEUED at last poll. Do not treat the preceding targeted green tests as a pass for the new SHA until rerun completes.
- The previous full Build on `d98f19b...` still failed six test shards for a mix of legacy Home/Quick Capture/Settings/Task Editor widget assertions and the now-corrected Follow-up timestamp assertion; Analyze passed, APK jobs were still running at last poll. The corrected test has not yet been revalidated.

#### Device validation
- PR #3365 exact head `50f99c743b6dc5192b01fc87733d3a1eaa4e7a51`: all seven Device Smoke lanes now terminal SUCCESS, including Calendar. Its Build remains SUCCESS. This is the first complete green Device Smoke set for this Cycle 3 Calendar repair.
- PR #3348 original head remains unchanged and its Device Smoke remains FAILED on Calendar due immediate assertion before route/FutureBuilder completion. The downstream #3365 branch adds a bounded wait for the actual selected-day list and proves all lanes green. #3348 remains OPEN/DRAFT pending integration/revalidation; not accepted as independently green.

#### Product editor branch
- PR #3366 latest head `a9c2b8711be76738c7dda08c7befe6969b4c88a5`; Analyze had passed on the prior build, test shards/APKs remained running, File Persistence passed, Device Smoke pending. Exact-head terminal result still required.

#### History page 4 — continued
- Chunk 4 stored at `docs/qa/historical-recovery/page-4-chunk-4-index-30-39.json`: 10 raw REST records, 10 unique PRs, IDs present; PR numbers #437, #439, #440, #441, #442, #443, #445, #448, #449, #450.
- Chunk 5 stored at `docs/qa/historical-recovery/page-4-chunk-5-index-40-49.json`: 10 raw REST records, 10 unique PRs, IDs present; PR numbers #451–#459 and #461 (no inferred #460).
- Chunk 3 was revalidated against the same raw page and updated to include true REST numeric IDs. Its PR list #427–#436 exactly matches the earlier checkpoint.
- Historical Set A / Set B source membership remains UNVERIFIED.
