# ARVIN — WAVE 3 / CYCLE 3
## Duplicate HEAD groups: dependency and product-value review
**Repository:** `mobinpda-lab/Arvin-clean`  
**Current Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Review date:** 2026-11-11  
**Mode:** READ-ONLY / NON-DESTRUCTIVE

## Integrity results

- 35 representative branch refs were compared with current Main. Their `ahead_by` / `behind_by` results exactly matched the recorded checkpoint values.
- 109 branch names across the 35 groups were confirmed to exist.
- 74 pairwise comparisons between every non-representative branch and its group's representative returned `identical`, `ahead_by=0`, `behind_by=0`.
- Therefore all 35 recorded groups are genuine duplicate-HEAD groups at the checked refs; all 109 branch refs remain present.
- 18 groups have zero commits ahead of Main. 17 groups have unique ancestry ahead of Main.
- No branch was deleted, archived, force-updated, or modified. No PR was closed or merged.

## Group-by-group product/dependency disposition

| Group | Main comparison | Product/dependency finding | Safe disposition now |
|---:|---|---|---|
| 01 | 12 ahead / 190 behind | Backup branch associated with the still-open documentation/release-evidence PR #2913 family. Not the current PR head. | PRESERVE |
| 02 | 18 ahead / 190 behind | Exact current head of open Draft PR #2913; documentation/evidence workflow only. | PRESERVE — OPEN PR |
| 03 | 52 ahead / 172 behind | Backup snapshot associated with open PR #2918 typography work. Current PR #2918 head is a different ref; retain historical evidence. | PRESERVE — OPEN PR |
| 04 | 0 ahead / 892 behind | Product-first autonomous queue branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 05 | 0 ahead / 1,385 behind | Exact-ref Device CI lane; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 06 | 0 ahead / 1,458 behind | Issue #200 exact-head CI branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 07 | 0 ahead / 1,380 behind | PR #242/semantic-search branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 08 | 5 ahead / 1,246 behind | PR #366 closed unmerged; Issue #357 is closed with current-main same-tree Build + Device Smoke evidence. Blank Follow-up title defaults to `پیگیری` and current product tests exist. | SUPERSEDED PRODUCT BEHAVIOR; PRESERVE HISTORY |
| 09 | 248 ahead / 172 behind | Open Draft PR #2989 is diagnostic-only Calendar edit callback/editor-route tracing. Not a product release candidate. | PRESERVE — OPEN DIAGNOSTIC PR |
| 10 | 0 ahead / 861 behind | Canonical authority documentation branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 11 | 1 ahead / 1,286 behind | Tip commit updates `docs/progress_scorecard.json`; Issue #305 is closed and the commit is documentation-only. | DOCS HISTORY; NO PRODUCT MERGE |
| 12 | 0 ahead / 610 behind | Calendar product redesign branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 13 | 4 ahead / 1,025 behind | Calendar target selection uses the same current-main `ListTile` target control and stable calendar identity; main file has subsequent surrounding updates. | CURRENT-MAIN BEHAVIOR EXISTS; NO PORT |
| 14 | 0 ahead / 1,455 behind | Notebook core branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 15 | 0 ahead / 1,457 behind | PDF/Print core branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 16 | 0 ahead / 1,451 behind | Prayer Times core branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 17 | 0 ahead / 1,279 behind | Device feedback/Jalali Home swipe branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 18 | 2 ahead / 1,067 behind | ProjectPlanCodec and tests exist on Main. Main test now includes archive-state validation beyond this branch's older codec fixture. | SUPERSEDED BY RICHER MAIN CONTRACT |
| 19 | 0 ahead / 1,673 behind | Simple Notebook session branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 20 | 0 ahead / 1,687 behind | UI reconstruction branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 21 | 2 ahead / 1,067 behind | Work Agenda report adapter was merged through PR #464; current-main adapter, page, PDF renderer and expanded tests exist. | MERGED / CURRENT-MAIN EQUIVALENT |
| 22 | 0 ahead / 1,572 behind | Earlier production fast-track/architecture branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 23 | 65 ahead / 714 behind | PR #1532 merged the Device Smoke isolation contract; current Main has a later, broader workflow contract test. | MERGED / SUPERSEDED TEST CONTRACT |
| 24 | 0 ahead / 569 behind | Calendar retry/visual branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 25 | 0 ahead / 608 behind | Home appearance/taxonomy refresh branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 26 | 0 ahead / 1,598 behind | Home latest-Follow-up branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 27 | 0 ahead / 1,430 behind | Canonical backup/Home refactor branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 28 | 1 ahead / 1,456 behind | Prayer Times implementation was merged through PR #197; current Main has `iranian_prayer_time_source.dart`, official Calendar wiring and focused tests. | MERGED / CURRENT-MAIN EQUIVALENT |
| 29 | 1 ahead / 1,456 behind | Recurrence UI/repository was merged through PR #209; current Main has canonical recurrence repository/page and tests. | MERGED / CURRENT-MAIN EQUIVALENT |
| 30 | 0 ahead / 1,387 behind | Placeholder/no-op branch family; no unique commit relative to Main. | NO UNIQUE CODE; NO ARCHIVE ACTION |
| 31 | 9 ahead / 1,010 behind | PR #659 closed unmerged; current-main rebuild PR #670 merged the selected target calendar label and test. | SUPERSEDED BY MERGED #670 |
| 32 | 1 ahead / 300 behind | Reminder migration tombstone regression file has the exact same blob SHA on this branch and Main. | EXACT TEST DUPLICATE ON MAIN |
| 33 | 14 ahead / 1,266 behind | Reconciliation branch; PR #326 merged the Jalali/Home/swipe corrections into Main. Tip is a merge/reconciliation commit with no additional changed files. | MERGED / RECONCILIATION HISTORY |
| 34 | 1 ahead / 607 behind | Older Calendar projection test includes legacy Follow-up-history projection. Current Main has a broader projection contract that excludes legacy Follow-up scheduling and projects only explicit canonical reminders. | OBSOLETE TEST CONTRACT; DO NOT PORT |
| 35 | 5 ahead / 1,678 behind | Issue #357 is closed with current-main same-tree Build + Device Smoke evidence; current UI/tests cover canonical Follow-up detail, append-only history and blank-title default. | COMPLETED / CURRENT-MAIN EQUIVALENT |

## Protected references

- Open PRs preserved: #2913, #2918, #2989.
- Closed-unmerged historical PRs left untouched: #366, #659.
- Merged equivalence references: #1532, #197, #209, #326, #464, #670.
- Completed issue reference: #357.
- No group is approved for deletion or archival in this review. Branch retention and future archival require a separate explicit authorization after reference mapping.

## Historical Set A / Set B

Repository search for the exact set labels, 198-ID artifact references, 509-member artifact references, and likely artifact filenames found no recoverable source artifact. Historical Set A identity and Historical Set B membership remain **UNVERIFIED**. Do not compute intersections or the previously mentioned 311 difference without the original exact ID lists.

## Conclusion

The duplicate-HEAD structure itself is now verified across all 35 groups and 109 branch refs. The remaining cleanup decision is not a technical duplicate check: it is a separate authorization/reference-retention decision. Current evidence supports keeping all refs unchanged while preserving the open PRs and the diagnostic branch.


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
