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
