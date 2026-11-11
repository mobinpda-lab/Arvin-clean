# ARVIN — WAVE 3 / CYCLE 2 EXECUTION CHECKPOINT
**Date:** 2026-11-11  
**Repository:** mobinpda-lab/Arvin-clean  
**Governance:** ARVIN-MASTER-CHARTER-REV9  
**Release:** NO-GO  
**Execution:** Parallel product repair / historical recovery / repository cleanup

## 0. Exact baseline and safety
- Main SHA: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3052: OPEN / DRAFT / UNMERGED; HEAD `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; base Main.
- PR #3340: OPEN / READY / UNMERGED; HEAD `28f2a57c8feb61c8e587e93955f32685b930b2d7`; base Main.
- Neither protected PR was modified. Main was not modified.
- No merge, close, branch deletion, rebase, force-push, schema change, migration, backup mutation, or release was performed.
- Local-first remains authoritative; local SQL is the durable source of truth; multi-device sync remains suspended.

## 1. WORKSTREAM A — PRODUCT REPAIR

### A1. PR #3052 exact-head test triage
Exact HEAD inspected: `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`.

Latest inspected six-shard totals:
| Shard | Passed | Failed |
|---|---:|---:|
| 0 | 195 | 6 |
| 1 | 298 | 27 |
| 2 | 240 | 11 |
| 3 | 148 | 12 |
| 4 | 232 | 14 |
| 5 | 185 | 11 |
| **Total** | **1,298** | **81** |

Analyze and Debug/Release APK jobs passed on this inspected run; the six test shards did not. The previous 82-failure count belongs to an older run; do not reuse it.

**Root-cause correction and verified P0 risk:**
- The tests `task_contract_test.dart`, `task_editor_due_date_preservation_test.dart` and `task_detail_due_date_action_test.dart` construct Tasks with deprecated constructor parameters such as `reminderDate` / `followUpDate`, then expect the old first-class fields to round-trip. The new #3052 model intentionally ignores those direct legacy constructor inputs; actual legacy migration is an explicit `Task.fromLegacyJson` / migration-adapter boundary. These assertions are fixture/contract mismatches, not proof of due-date loss.
- `release_critical_path_test.dart` also expects the computed `reminderDate` compatibility getter to be null while a canonical `TaskReminder` exists; the assertion should inspect canonical reminder state and the legacy migration marker instead.
- A separate, real data-integrity risk is visible in `ArvinTaskEditorDialog._save`: it creates a new Task but does not carry forward existing `completedAt`, `isFavorite`, `focusDate`, `templateTaskId`, `checklistOccurrences`, `occurrenceHistory`, or `legacyFollowUpMetadata`. TaskStore treats these as known canonical keys, not unknown envelope fields, and rewrites relational occurrence state from the returned Task. Editing an existing Task can therefore reset/drop these values. This is a static code-path finding; a dedicated runtime regression test is still required.
- The SQL migration writer's close/reopen test fails on the second migration pass with `Task envelope/unknown-field conflict for persist-task`. The writer is intended to be idempotent, so this remains a migration blocker until the exact envelope mismatch is isolated.
- Two source-contract tests fail with `RangeError` from brittle `String.substring` checks; these are test implementation defects, not runtime export failures.
- Migration tests expect retired columns to disappear, while the current migration copies legacy values into the envelope / canonical Reminder boundary but leaves the old columns present. Do not drop those columns until data parity, backup and restore are proven.
- All 81 failed test names have now been enumerated. Major repeated files: Home page (9), Quick Capture dialog (8), Task Detail master screen (6), Task Editor dialog (4), Follow-up Office (4), Home Today menu (3), Home stat filters (3). Full classification into product defects versus outdated test contracts is still open.

**Disposition:** keep #3052 protected and unmodified. Do not merge until the TaskEditor preservation gaps, SQL migration idempotency, legacy-schema transition and remaining UI/test contract mismatches are resolved on an independently reviewable path.

### A2. PR #1901 selective recovery
- PR #1901 remains OPEN / READY / UNMERGED.
- HEAD: `ba8e26c2388c4b74bc0ecc40cf50b0fd0b02960a`.
- Comparison to current Main: 86 commits ahead / 645 behind; 27 changed files.
- Useful historical themes: canonical taxonomy catalog, Task checklist-enabled state, Notebook shared taxonomy, Quick Capture date/time controls and additional tests.
- Main already contains `Task.checklistEnabled`, canonical TaskStore category/tag catalog operations, Notebook taxonomy delegation to TaskStore, current Quick Capture and G1 Drift schema version 7.
- PR #1901 contains an older schema-v5 migration and an RTL Task-to-Follow-up swipe conversion. The latter conflicts with the current Reminder-only owner contract; Main currently sanitizes `convertToFollowUp` to `none`.
- No bulk cherry-pick or source transfer was performed. The PR is not a merge candidate; only any future independently proven missing behavior should be rebuilt on current Main.

### A3. File-backed SQLite tests from #2959 and #2961
Historical sources:
- #2959 HEAD `4db08a1a6bd6b77acc19aa4d0d86daff55da911f`.
- #2961 HEAD `dd5279b48a99d0b19b5a64fc9b4686dba2a3da4b`.

A current-Main test-only port was created:
- Branch: `test/wave3-cycle2-file-backed-sqlite-current-main`.
- Draft PR #3348: https://github.com/mobinpda-lab/Arvin-clean/pull/3348
- HEAD: `86beb865aea692738bc4d8362c2abefbc6ae37e7`.
- Base: Main `45e4202b03a434459e4c021a04efa7e8396359db`.
- Files:
  - `test/project_store_file_backed_sqlite_test.dart`
  - `test/task_reminders_file_backed_sqlite_test.dart`
- No runtime source, schema, migration, backup format or stored data was changed.

Exact-head Build run `42966000663`: SUCCESS.
- Analyze: PASS.
- Six Quality shards: PASS.
- Total: 1,094 tests passed, zero failed.
- Debug APK: PASS.
- Release APK: PASS.
- Logs explicitly show both new file-backed SQLite tests passed.
- Existing `task_editor_due_date_preservation_test.dart` also passed in this run.

Exact-head Device Smoke run `42966000635`: IN PROGRESS at last poll.
- Preparation: PASS.
- Home, Quick Capture, People, Backup/Restore, SQL Persistence and SQL Migration: PASS.
- Calendar: IN PROGRESS.
- Full Device Smoke is not yet PASS.

Parallel Wave run `42966000643`: FAILED at the Fast Lane workflow-contract validator. The validator reports that `.github/workflows/device-smoke.yml` is missing the expected exact-ref expression:
`ref: ${{ github.event_name == 'workflow_dispatch' && inputs.target_sha || github.sha }}`.
This is a workflow-contract failure, not a failure in either added test. No workflow file was changed.

PR #3348 remains OPEN / DRAFT. Do not merge until all seven Device Smoke scenarios terminate and are reviewed.

## 2. WORKSTREAM B — HISTORICAL RECOVERY

### 2.1 Page 4 / Chunk 2
Raw artifact is preserved in PR #3343:
- PR #3343: OPEN / DRAFT, branch `docs/wave3-cycle2-recovery-evidence-20261111`.
- Head: `eb690beb41f56a6089ca51e717619ccd3699557d`.
- Raw file: `docs/project-continuity/audit/PAGE_4_CHUNK_2_RAW_API_2026-11-11.json`.
- Raw file blob SHA: `7a2d558c4bde5ac1ec7d629247af6048b9f54129`.

API request: `GET /pulls?state=all&per_page=100&sort=created&direction=asc&page=4`; extraction `slice(10,20)`.
- Exactly 10 records: #417–#426.
- All 10 records match the live API fields checked: number, title, state, draft, head/base refs and SHAs, created/updated/closed/merged timestamps and merge SHA.
- No duplicate PR number; no overlap with Chunk 1 (#407–#416); page boundary follows #406.
- Required head/base/date fields are present for all 10.
- Merged: #418, #420, #421, #423.
- Closed-unmerged: #417, #419, #422, #424, #425, #426. A non-null `merge_commit_sha` does not override `merged_at`.

Titles:
- #417 — feat(home): add canonical list scope and sort projection
- #418 — feat(task): apply editor results onto canonical Task safely
- #419 — docs(audit): refresh live completion checkpoint on current main
- #420 — feat(bulk): rebuild canonical report scopes on current main
- #421 — feat(home): rebuild canonical scope and sort projection on current main
- #422 — feat(task): rebuild independent due-date editor on current main
- #423 — feat(followup): add independent reminder editor
- #424 — feat(followup): plan nearest canonical reminder alarm
- #425 — feat(followup): rebuild reminder alarm planner on current main
- #426 — feat(bulk): preselect canonical items in report export

Page 4 contains 100 API records. Its previously checked aggregate was 43 Draft, 35 merged and 65 closed-unmerged. The page-level cumulative count remains 400 (Page 3: 300 + Page 4: 100). Detailed Page 4 extraction is 20/100 records (Chunk 1 and Chunk 2); do not describe all 400 as individually detailed in these chunk reports.

### 2.2 Historical Sets A and B
PR #3343 also preserves:
- `docs/project-continuity/audit/CLOSED_UNMERGED_PR_INVENTORY_2026-11-11.json`
- Blob SHA: `e3fd266661e2fbc4b1a789ba798a60e195de87d9`
- 509 unique PR IDs, no internal duplicates.
- Exact reconciliation against the 2026-11-10 closed-unmerged API snapshot: 509/509 intersection, zero source-only and zero API-only.

**Important identity limitation:**
- This is an exact 2026-11-10 Closed-Unmerged snapshot, not proven to be the original PHASE 4.1 Historical Set B artifact.
- Historical Set A's original 198 IDs and source artifact remain UNRECOVERED. Prior PHASE 3/4.3 records report only the count, not the membership list or extraction rules.
- Do not reconstruct or guess Set A.
- Do not calculate or approve 311. Set A/B membership overlap is unproven.

## 3. WORKSTREAM C — REPOSITORY CLEANUP

Current live inventory:
- Branch refs: 1,418 (all 15 pages; last page 18; rechecked after creating the checkpoint branch).
- Open PRs: 106 (page 1: 100; page 2: 6; rechecked after opening the checkpoint PR).
- The 35 duplicate-HEAD groups from the prior audit still exist: all 109 referenced branch refs were found, and each ref still points to its recorded group SHA.
- Compared with Main `45e4202b03a434459e4c021a04efa7e8396359db`: 17 groups diverged (have unique ahead commits); 18 groups are behind-only (zero ahead commits).
- Exact branch names and group membership remain in `docs/project-continuity/audit/BRANCH_AUDIT.md`, blob SHA `f7a9c97b80bcf6d4a3ec23e4f7d5e2f636f19ab9`.
- PR associations were cross-checked against the 1,238-row `PULL_REQUEST_AUDIT.md` snapshot, blob SHA `5db74a36db30ba79d50e712a96cfc07016912f41`; open PR associations #2913 and #2989 were also confirmed live.

| Group | HEAD SHA | Refs | Last commit (UTC) | Ahead / behind Main | PR association | Disposition |
|---:|---|---:|---|---:|---|---|
| 1 | `1b5f15023d0ab5b8038063bcbc81696df79c471c` | 13 | 2026-08-27 — docs(calendar): record confirmed reschedule UI | 0 / 1279 | #319 merged | ARCHIVE CANDIDATE |
| 2 | `8bbf3f39a46bdd24fb0bae5d906b6a5bcdb67039` | 7 | 2026-08-28 — test(projects): restore codec coverage | 2 / 1067 | #465, #463 closed-unmerged | INVESTIGATE |
| 3 | `162993f38c164876a04e20cf12919501120c86f4` | 7 | 2026-08-28 — test(reports): restore adapter coverage | 2 / 1067 | #464 merged; #462 closed-unmerged | INVESTIGATE |
| 4 | `aebe4a9e4f2d39fb41f2e0870708985b1ec67db1` | 6 | 2026-09-12 — feat(wave1): wire Notebook items to canonical Projects | 0 / 892 | no direct PR head match | ARCHIVE CANDIDATE |
| 5 | `fb8e3b32c1ba2591b6e37f533a0f17f20d054e4d` | 4 | 2026-08-27 — docs(search): align semantic slice | 0 / 1380 | #242 merged | ARCHIVE CANDIDATE |
| 6 | `3aa851f120be3eb93f9485ad1f3198f0285cedfc` | 4 | 2026-08-28 — docs(follow-up): checkpoint entry slice | 5 / 1246 | #366 closed-unmerged | INVESTIGATE |
| 7 | `7b7dd55c77c8f833d636a1bc0478b9fa22de55c2` | 4 | 2026-08-27 — merge(ui): establish reconciliation parentage | 14 / 1266 | no direct PR head match | INVESTIGATE |
| 8 | `4e9312a18ac637cb7b41b02cccabb8d9b22b9c67` | 3 | 2026-10-22 — docs: record latest Wave 6.51 head check | 12 / 190 | backup refs | KEEP |
| 9 | `c9dfc657cd6db32b070902f74a63752bb6bdc12d` | 3 | 2026-08-27 — ci(device): validate exact-ref smoke contract | 0 / 1385 | #243 merged | ARCHIVE CANDIDATE |
| 10 | `c1802683d4695c0bd4cd3cef376af9a9f2bf8c5b` | 3 | 2026-08-26 — ci: make exact-head Fast Lane deterministic | 0 / 1458 | #201, #203, #213 merged | ARCHIVE CANDIDATE |
| 11 | `6acff3ca490c6c3758e51a52d0a61fbdad2b7538` | 3 | 2026-09-13 — feat(wave2): canonical Home/More/Today UX | 0 / 861 | no direct PR head match | INVESTIGATE |
| 12 | `943bfdcfb7ee82c09bee7fba5d4dad0483edad81` | 3 | 2026-08-27 — docs(progress): reconcile after sync plan merge | 1 / 1286 | #309 closed-unmerged | INVESTIGATE |
| 13 | `f9cb98e41d15b5cfb32d0f1f6a1c0ed1ff8fbe61` | 3 | 2026-08-13 — fix: use package import in calendar test | 0 / 1687 | no direct PR head match | ARCHIVE CANDIDATE |
| 14 | `c766f9f07e3b6122866b85d1da75f71aa0c030c5` | 3 | 2026-10-02 — fix(calendar): reconcile device-calendar changes | 0 / 569 | commit references #2177 | ARCHIVE CANDIDATE |
| 15 | `abf0d19012aee2f78a2f87e9931dc4191a0c19c7` | 3 | 2026-08-26 — test(backup): scope legacy guard | 0 / 1430 | #222 merged | ARCHIVE CANDIDATE |
| 16 | `80d3100e91075167768dcb6916a05ad3bf57ef2b` | 2 | 2026-10-23 — ci: record dependency resolution result | 18 / 190 | #2913 OPEN / DRAFT + backup ref | KEEP |
| 17 | `4da8c895edcc6aec28ef318240b015d2bf63caeb` | 2 | 2026-10-23 — docs(typography): verify tracked fonts | 52 / 172 | backup refs | KEEP |
| 18 | `2626a5f9ee43661a1cfd2802b022deeeb7e74ef9` | 2 | 2026-10-25 — test(calendar): await async editor preparation | 248 / 172 | #2989 OPEN / DRAFT | KEEP |
| 19 | `36f05599e17ea5359f92ad62667aac76abccb301` | 2 | 2026-09-30 — feat(notebook): reuse canonical taxonomy | 0 / 610 | commit references #2037 | ARCHIVE CANDIDATE |
| 20 | `6cdd6cd49ecb038851cce76a2a37e9c499f139fb` | 2 | 2026-08-31 — fix(calendar): avoid deprecated RadioListTile API | 4 / 1025 | #607, #604 closed-unmerged | INVESTIGATE |
| 21 | `750648a07827d8a101695386903b306963f697c5` | 2 | 2026-08-26 — feat(notebook): revalidate Notebook | 0 / 1455 | #198, #215 merged | ARCHIVE CANDIDATE |
| 22 | `dcd5bc31118102f6e61df293320fdafbdbd51a4f` | 2 | 2026-08-26 — docs(pdf): record Gate H baseline | 0 / 1457 | #196, #205 merged | ARCHIVE CANDIDATE |
| 23 | `10be46374d221e92848ab82f788a0a2ee1a8609f` | 2 | 2026-08-26 — feat(calendar): revalidate Prayer Times | 0 / 1451 | #197, #219 merged; #206 closed-unmerged | ARCHIVE CANDIDATE |
| 24 | `bc88df1118b656d3acd8e025821155af443a810c` | 2 | 2026-08-14 — feat(followup): integrate TaskStore operations | 0 / 1673 | no direct PR head match | ARCHIVE CANDIDATE |
| 25 | `d3d5664b3261c7d92762c39ffc7526261feca074` | 2 | 2026-08-21 — docs: formalize continuation command | 0 / 1572 | no direct PR head match | ARCHIVE CANDIDATE |
| 26 | `cb0337f01688e4de7df91a3b781869c4c1ee3f90` | 2 | 2026-09-24 — test(ci): align device smoke contract | 65 / 714 | #1532 merged; #1533 closed-unmerged | INVESTIGATE |
| 27 | `9e3811815bb99956c91cd2b8bd24455225397267` | 2 | 2026-10-01 — feat(calendar): unify Task Reminder/calendar sync | 0 / 608 | commit references #2073 | ARCHIVE CANDIDATE |
| 28 | `bf68c54fc72a1018ca1b45d6510ef3388937f912` | 2 | 2026-08-17 — docs: extend UI canonical migration plan | 0 / 1598 | no direct PR head match | ARCHIVE CANDIDATE |
| 29 | `4e4579e3049e3a09814e4f50c96cd3573f37dd8e` | 2 | 2026-08-26 — feat(calendar): revalidate Prayer Times | 1 / 1456 | #217, #214 closed-unmerged | INVESTIGATE |
| 30 | `541943967062e21d9fd4b99b9c11c360419c0d89` | 2 | 2026-08-26 — feat(recurrence): revalidate recurrence | 1 / 1456 | #218, #216 closed-unmerged | INVESTIGATE |
| 31 | `56283268955686636ecdf5db44382858ffdd6b71` | 2 | 2026-08-26 — merge PR #240 (CI dedupe) | 0 / 1387 | no direct PR head match; placeholder/noop refs | INVESTIGATE |
| 32 | `ac827a8336274a6db18470b80d60ea812d3fc700` | 2 | 2026-09-05 — fix(calendar): restore Issue 658 test | 9 / 1010 | #659 closed-unmerged | INVESTIGATE |
| 33 | `dfef3a5e143ffeb0bf773468284503d349e8f1d9` | 2 | 2026-10-16 — test(reminders): rebase tombstone regression | 1 / 300 | #2738 merged | INVESTIGATE |
| 34 | `c4b52c724810b8382de65087614888f242404c57` | 2 | 2026-10-01 — test(calendar): recurrence projection acceptance | 1 / 607 | #2086, #2081 closed-unmerged | INVESTIGATE |
| 35 | `1a698d6f0184f5f2162b6358269e47af7ff24cf5` | 2 | 2026-08-14 — fix(followup): import MaterialApp in widget test | 5 / 1678 | #40 closed-unmerged | INVESTIGATE |

**Disposition totals:** KEEP 4; ARCHIVE CANDIDATE 16; INVESTIGATE 15; MERGE CANDIDATE 0; DELETE CANDIDATE 0.
These are preparation classifications only. No cleanup operation is authorized by this checkpoint. In particular, ARCHIVE CANDIDATE does not mean safe to delete: workflow refs, tags, all historical PR associations and product dependencies must be checked before any action.

## 4. Historical and governance references
- PR #3343: https://github.com/mobinpda-lab/Arvin-clean/pull/3343 — raw Page 4 Chunk 2 and 509-ID snapshot are preserved there.
- PR #3348: https://github.com/mobinpda-lab/Arvin-clean/pull/3348 — current-Main file-backed SQLite test port.
- Current owner product acceptance ledger: Issue #1139. Its Reminder-only contract supersedes legacy Next Follow-up scheduling; historical FollowUp interaction records remain data to preserve, not a reason to reactivate retired scheduling paths.
- Historical Set A (198 IDs) remains unrecovered. Historical Set B identity remains unproven. 311 remains unverified.

## 5. Next actions
1. Poll #3348 Device Smoke run `42966000635` until all seven scenarios terminate; inspect any failing lane's exact log and do not weaken assertions.
2. Keep #3052 protected. Use the current-Main passing compatibility-preservation test as the P0 baseline; complete root-cause classification for the remaining 79/81 failures before proposing any repair.
3. Review #1901 only as individual behavior candidates; do not cherry-pick its stale schema or retired Follow-up conversion.
4. Continue Page 4 from Chunk 3: `slice(20,30)`. Do not repeat Chunk 1 or Chunk 2.
5. Preserve Set A as UNRECOVERED until an original 198-ID artifact and membership rule are found. Do not infer 311.
6. For the 15 INVESTIGATE branch groups, map unique commits to all PRs, workflows, tags and product dependencies. For 16 ARCHIVE CANDIDATE groups, verify complete historical linkage before recommending archival.
7. No deletion, PR closure, merge, Main write, schema migration or release in this cycle.

**Cycle status:** IN PROGRESS — Release NO-GO.
