# ARVIN_REPOSITORY_HEALTH_AND_CONSOLIDATION
**Repository:** `mobinpda-lab/Arvin-clean`  
**Audit date:** 2026-11-12  
**Execution PR:** #3384  
**Documentation PR:** #3388  
**Canonical REV9 PR:** #3340  
**Policy:** NO MERGE / NO RELEASE / NO DEPLOYMENT

## 1. Executive disposition
- Repository is accessible; linked GitHub permission reports admin/push access.
- Default branch is `main`; latest commit returned by commit search: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Live branch inventory returned 1,429 refs over 16 pages. This is a name inventory only; the branch search endpoint did not expose per-branch HEAD SHA or last-commit dates. No branch is labelled stale or deleted based only on name/prefix.
- Five relevant PRs (#3380, #3382, #3384, #3388, #3340) remain unmerged in this audit. No merge, release, deployment, branch deletion, PR closure or history rewrite was performed.
- Current execution candidate after the fixture repair: `eea746dbf2a58cd4f04c66a149ae3441264da5b2`.
- Release disposition: **NO-GO**. Migration gates, 60 prior-candidate failures, exact-SHA Build, Device Smoke and D05 recovery remain open.

## 2. Repository and branch inventory
The live branch search returned 1,429 branch names. Prefix counts (not a stale/active classification):
| Prefix | Count | Prefix | Count |
|---|---:|---|---:|
| fix | 381 | feat | 328 |
| docs | 237 | feature | 89 |
| ci | 60 | test | 60 |
| wave | 25 | automation | 24 |
| chore | 23 | gate | 18 |
| factory | 15 | ai | 13 |
| audit | 13 | backup | 13 |
| nira | 12 | ui | 9 |
| Other prefixes | 109 | | |

**Limitations:** branch names are searchable and paginated, but this audit interface did not provide a complete branch ref object with commit SHA, commit date, protection, or open-PR association for every branch. Therefore ACTIVE / LEGACY / UNUSED cannot be assigned globally yet. Historical/backup/diagnostic names are preserved; no automatic cleanup is permitted.

## 3. PR and branch dependency register
| PR | Purpose / changed scope | Base and head evidence | Disposition |
|---|---|---|---|
| #3380 | COMMAND 06-E diagnostic executor lifecycle; 2 changed files: `.github/workflows/arvin-command06c-diagnostic.yml` and `test/services/sql_task_migration_writer_test.dart` | Correlated branch `diagnostic/w3-c3-command06e-harness-recovery`, head `33a8fb14a9979d0d86775cb5457970c7e445077b`; common base `8c4c23f0c2a4f9b2374a2092c931782c4455fd41` on `fix/wave3-cycle3-calendar-product-repair`. | TEST INFRASTRUCTURE / HISTORICAL EVIDENCE. PR body says one test file and no workflow changes, but live changed-file inventory shows 2 files including a workflow; reconcile PR description. |
| #3382 | COMMAND 06-H raw SQL evidence; 2 files: raw-SQL workflow and diagnostic test | Branch `diagnostic/command-06-h-raw-sql-evidence`, head `adee525e94fa2daec617255d57f9cfb65e3efe66`; base/head relationship confirms it is 3 commits ahead of #3380 branch `33a8fb14...` with no divergence. | STACKED DIAGNOSTIC EVIDENCE. Preserve raw artifact and stop condition until evidence is reviewed. |
| #3384 | COMMAND 07-A.2 implementation; 61 changed files spanning SQLite schema/migration, Task model/store, UI, tests, workflows, typography assets and continuity docs | Branch `feature/command-07-a-sqlite-contract-remediation`; base `fix/wave3-cycle3-calendar-product-repair`; compare: 110 commits ahead / 0 behind; it does not include the 8 #3380-only commits; base SHA `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`; current commit `eea746dbf2a58cd4f04c66a149ae3441264da5b2`. | ACTIVE EXECUTION PR. Keep unmerged. Do not treat prior SHA `492a5c4...` as current acceptance. |
| #3388 | Wave 0 documentation/governance package; 8 changed files including CODEOWNERS, operating package, project state, roadmap, typography contract, decision/evidence/handoff docs | Branch `docs/wave-0-canonical-governance`; body records base Main SHA `45e4202b03a434459e4c021a04efa7e8396359db`; exact current head SHA not surfaced. | DOCUMENTATION PR WITH AUTHORITY CONFLICT. Preserve for review; reconcile with REV9 before any merge. This report is added on this branch. |
| #3340 | REV9 canonical master charter and permanent AI continuity; 66 documentation/agent-instruction files | Branch `docs/rev9-governance-continuity-2026-11-10`; body records base Main SHA `45e4202b03a434459e4c021a04efa7e8396359db`; latest audit addendum commit created here: `7cb9da610ff75d9da289187e5b6c7bdc6b098608`. | CANONICAL REV9 DOCUMENTATION LANE. Keep unmerged pending owner review; this audit added the COMMAND 07-A.2.33 updates to its six canonical documents. |

### PR overlap and dependency conclusions
- #3382 is stacked directly on #3380: its head is 3 commits ahead of #3380's head with no divergence. Preserve this dependency; do not treat the two as independent duplicate PRs.
- #3384 is a sibling implementation branch from the same `8c4c23f...` integration base. It is 110 commits ahead of that base and does not include the 8 #3380-only commits or the 3 #3382 additions. Both #3380 and #3384 change `test/services/sql_task_migration_writer_test.dart`; manual patch-level reconciliation is required before any integration.
- #3380 and #3382 are diagnostic/test-evidence slices; they do not replace production migration acceptance.
- #3384 is the active implementation lane and has 110 commits beyond its named base branch. Its base is not Main; do not retarget or merge by assumption.
- #3388 and #3340 are parallel documentation lanes. #3340 carries the REV9 master and canonical six-document set; #3388 changes a separate set of governance/state documents. The #3388 state document still identifies operating package v49.0, while #3340 installs REV9. This is a real documentation authority conflict.
- The six canonical REV9 documents are under `docs/project-continuity/`: `MASTER_GOVERNANCE.md`, `CURRENT_STATE.md`, `ROADMAP.md`, `DECISIONS.md`, `IMPLEMENTATION_LOG.md`, `HANDOFF.md`. REV8 is preserved as an archive. The six files were updated on #3340's branch with the current execution checkpoint.
- The #3384 branch also carries copies of these six documents with REV8-era snapshots. They are branch-local historical copies, not a second canonical governance authority.
- No PR or branch was closed, deleted, rebased or merged.

## 4. Workflow inventory and overlap
### Directly verified workflow roles
| Workflow | Role | Exact evidence / status |
|---|---|---|
| `build.yml` / Arvin Build | Analyze, six test shards, visual/PDF, Debug/Staging/Release APK build lanes | Run `43247842294` on old SHA `492a5c4...`: overall FAILURE from test shards; Analyze, Visual, APK build jobs succeeded. New SHA run `43269800292` was QUEUED at last poll. |
| `device-smoke.yml` / Arvin Device Smoke | Seven Android smoke scenarios with exact checkout SHA | Old run `43247842521` queued. New run `43269800280` queued. No device acceptance. |
| `arvin-command-07-a2-20-sqlite-snapshots.yml` | A–D SQL snapshots and five actual reopen cycles | Old run `43247842246` succeeded on old SHA. New run `43269800257` was in progress at last poll. This workflow does not prove D05 interruption/recovery. |
| Arvin Follow-up File Persistence | Focused file-backed SQLite persistence and close/reopen tests | Old run `43247842181` succeeded; new run `43269800526` succeeded. This is a narrow test, not full migration acceptance. |
| ARVIN Orchestrator / PR Wakeup | Queue/orchestration wake-up | New SHA runs `43269800263` and `43269800271` succeeded. |
| ARVIN Production Loop | Automated production feedback/queue loop | Old run `43247842300` succeeded; new run `43269800282` queued at last poll. |

### Workflow disposition
- Build, Device Smoke, SQLite Snapshot, Follow-up Persistence, Orchestrator, PR Wakeup and Production Loop are active and serve distinct roles. Keep them; do not cancel active jobs to free the queue.
- Snapshot and Follow-up Persistence overlap only partially: one captures SQL A–D snapshots/reopen cycles; the other covers file-backed persistence. Neither replaces the complete migration and recovery suite.
- The complete inventory of all workflow YAML files, including every Release/Promotion/Parallel Wave/Regression workflow, was not available through the current paginated workflow-list interface. Their global ACTIVE/DUPLICATE/LEGACY status is therefore **UNRESOLVED**. No workflow deletion or broad rewrite is recommended until a complete tree/run inventory is available.
- Existing workflow changes on #3384 must be reviewed against actual triggers and dependencies before consolidation. No active workflow was cancelled in this execution.

## 5. SQLite migration and acceptance
### Confirmed prior-candidate evidence
- Previous candidate: `492a5c433ee215d0188a6075b159d4d72329d35e`.
- Build `43247842294`: 1,338 passed / 61 failed across six shards.
- SQLite Snapshot `43247842246`: success for A–D snapshots and five real close/reopen cycles; artifact `13958416974`, digest `sha256:0e57caf9e4357d8d4d43e82ad0f60377f69d3ebd4c7cbaefb89b6818fa93565b`.
- Follow-up Persistence `43247842181`: success.
- None of these historical results transfers to `eea746d...`.

### D01–D05 status
| Gate | Status | Remaining proof |
|---|---|---|
| D01 Schema Migration Compatibility | INCOMPLETE | Full historical schema/index/trigger/FK parity and source-data preservation. |
| D02 Missing / NULL / FALSE / TRUE | PARTIAL | All four states independently asserted through migration, serialization and reopen on one exact SHA. |
| D03 Follow-up Metadata | PARTIAL | IDs, order, Person relations, unknown fields and metadata round-trip through relational migration/reopen. |
| D04 Backup / Restore | NOT ACCEPTED | Actual backup, isolated restore, independent reopen and record-level parity. |
| D05 Atomicity / Recovery | INCOMPLETE | Injected interruption, rollback, retained source, repair/retry and no inconsistent partial state. |

### Root cause confirmed and corrected
Test: `test/services/g1_drift_schema_test.dart` — `malformed legacy task_people payload aborts migration without retiring source rows`.

The fixture inserted a legacy `task_people` row with `task_id='legacy-task'` but did not insert the parent Task. Migration correctly copied the relation into `task_persons`, whose schema has a real FK to `tasks(id)`; `PRAGMA foreign_key_check` correctly detected the orphan. This is a TEST HARNESS DEFECT, not evidence that the FK check is wrong.

Correction on #3384: insert the parent Task in the fixture before adding the malformed JSON relation. Commit `eea746dbf2a58cd4f04c66a149ae3441264da5b2`. No production migration, FK, rollback or assertion was weakened. Rerun on the new SHA is pending Build `43269800292`.

## 6. Previous-candidate 61 Failure Records
All 61 test failure records from Build `43247842294` are preserved below. Three records now have a grounded initial classification: one TEST HARNESS DEFECT corrected in `eea746d...`; two TEST CONTRACT DEFECTS identified for correction; the remaining 57 are UNRESOLVED pending root-cause inspection. The list is historical to SHA `492a5c4...` and must not be carried forward as the new candidate's result.

| # | Shard | File | Test | Classification |
|---:|---:|---|---|---|
| 1 | 0 | `test/task_detail_checklist_flow_test.dart` | task detail displays checklist and toggles an item | UNRESOLVED — RETEST REQUIRED |
| 2 | 0 | `test/widgets/task_dialog_test.dart` | creates a task with trimmed text and a unique tag | UNRESOLVED — RETEST REQUIRED |
| 3 | 0 | `test/quick_capture_dialog_test.dart` | Quick Capture can create a center inline and immediately select it | UNRESOLVED — RETEST REQUIRED |
| 4 | 0 | `test/task_detail_due_date_action_test.dart` | Task Details explicit today action aligns with Due Date and persists only the date change | UNRESOLVED — RETEST REQUIRED |
| 5 | 0 | `test/device_feedback_home_regression_test.dart` | Home keeps backup in the More menu instead of the header | UNRESOLVED — RETEST REQUIRED |
| 6 | 0 | `test/primary_bottom_navigation_test.dart` | primary navigation exposes exactly five canonical destinations | UNRESOLVED — RETEST REQUIRED |
| 7 | 0 | `test/home/home_filter_contract_test.dart` | Home keeps completed past tasks visible in a separate non-overdue group | UNRESOLVED — RETEST REQUIRED |
| 8 | 0 | `test/follow_up_office_page_test.dart` | follow-up office exposes the shared five filter dimensions | UNRESOLVED — RETEST REQUIRED |
| 9 | 0 | `test/task_people_page_test.dart` | empty People UI adds and removes a local Person explicitly | UNRESOLVED — RETEST REQUIRED |
| 10 | 0 | `test/task_editor_category_project_integration_test.dart` | new task saves typed category without an extra apply step | UNRESOLVED — RETEST REQUIRED |
| 11 | 0 | `test/home_today_about_test.dart` | Today menu action shows only active canonical tasks due today | UNRESOLVED — RETEST REQUIRED |
| 12 | 1 | `test/widgets/home_page_test.dart` | Home uses the five checkbox filters as combined filters and preserves time grouping | UNRESOLVED — RETEST REQUIRED |
| 13 | 2 | `test/settings_page_test.dart` | settings exposes date, swipe, projects and canonical backup controls | UNRESOLVED — RETEST REQUIRED |
| 14 | 2 | `test/widgets/home_quick_capture_test.dart` | Home primary add persists canonical task and preserves history | UNRESOLVED — RETEST REQUIRED |
| 15 | 2 | `test/quick_capture_dialog_test.dart` | Quick Add shows the selected scheduling time and uses injected now | UNRESOLVED — RETEST REQUIRED |
| 16 | 2 | `test/follow_up_entry_page_test.dart` | waiting FollowUp can add, select, reopen and remove a stable person | UNRESOLVED — RETEST REQUIRED |
| 17 | 2 | `test/home_last_follow_up_real_record_test.dart` | Home shows last FollowUp only for a real record and does not create one | UNRESOLVED — RETEST REQUIRED |
| 18 | 2 | `test/device_smoke_workflow_contract_test.dart` | device smoke defines exactly seven canonical lanes on one exact target SHA | TEST CONTRACT DEFECT — FIX PENDING: smoke uses pumpAndSettle |
| 19 | 2 | `test/widget_test.dart` | Home exposes the canonical workflow controls | UNRESOLVED — RETEST REQUIRED |
| 20 | 2 | `test/task_editor_dialog_test.dart` | Back-style close prompts and can save Task edits without data loss | UNRESOLVED — RETEST REQUIRED |
| 21 | 2 | `test/home/home_owner_reference_test.dart` | Home follows the owner header, real summary values and Today navigation | UNRESOLVED — RETEST REQUIRED |
| 22 | 2 | `test/home/home_filter_boolean_logic_test.dart` | Home filters combine OR within each dimension and AND across dimensions | UNRESOLVED — RETEST REQUIRED |
| 23 | 2 | `test/task_editor_due_date_preservation_test.dart` | editing preserves canonical due date independently | TEST CONTRACT DEFECT — FIX PENDING: getter is reminder projection |
| 24 | 2 | `test/follow_up_office_page_test.dart` | selects one of multiple tasks and persists only to that task | UNRESOLVED — RETEST REQUIRED |
| 25 | 2 | `test/task_detail_person_persistence_test.dart` | Task Details Follow-up person selection persists through canonical Person and relation tables | TEST HARNESS DEFECT — FIX PENDING: scrollUntilVisible expects Scrollable, test passes ListView |
| 26 | 2 | `test/task_detail_master_screen_test.dart` | Task Details persists checklist reorder and additions immediately without changing Follow-up history | UNRESOLVED — RETEST REQUIRED |
| 27 | 2 | `test/notebook_page_test.dart` | editor tag picker replaces tags on the same canonical note | UNRESOLVED — RETEST REQUIRED |
| 28 | 2 | `test/task_detail_checklist_crud_test.dart` | checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps | UNRESOLVED — RETEST REQUIRED |
| 29 | 2 | `test/home_today_about_test.dart` | Today menu action has a dedicated empty state | UNRESOLVED — RETEST REQUIRED |
| 30 | 2 | `test/quick_capture_project_create_test.dart` | Quick Add offers Project create-new and selects the created project | UNRESOLVED — RETEST REQUIRED |
| 31 | 2 | `test/report_center_page_test.dart` | Report Center exposes center and searchable task controls | UNRESOLVED — RETEST REQUIRED |
| 32 | 2 | `test/home_stat_filters_test.dart` | Home time filter exposes precise date and time range controls | UNRESOLVED — RETEST REQUIRED |
| 33 | 2 | `test/home_stat_filters_test.dart` | category checkbox selection applies OR only after confirmation | UNRESOLVED — RETEST REQUIRED |
| 34 | 3 | `test/widgets/home_page_test.dart` | RTL Move-to-Today does not dismiss and None is a no-op | UNRESOLVED — RETEST REQUIRED |
| 35 | 3 | `test/widgets/home_page_test.dart` | Home four filters stay in one RTL row without horizontal scrolling at phone widths and with keyboard | UNRESOLVED — RETEST REQUIRED |
| 36 | 3 | `test/widgets/home_page_test.dart` | Home Past time filter excludes today and prioritizes incomplete tasks | UNRESOLVED — RETEST REQUIRED |
| 37 | 3 | `test/quick_capture_dialog_test.dart` | Quick Add custom recurrence exposes every canonical time unit | UNRESOLVED — RETEST REQUIRED |
| 38 | 3 | `test/device_feedback_home_regression_test.dart` | normal-height Home keeps empty groups and floating add action | UNRESOLVED — RETEST REQUIRED |
| 39 | 3 | `test/task_editor_dialog_test.dart` | task editor recurrence uses RollBox and preserves interval | UNRESOLVED — RETEST REQUIRED |
| 40 | 3 | `test/home/home_filter_contract_test.dart` | Home task card expands in place with real FollowUp history and preserves details route | UNRESOLVED — RETEST REQUIRED |
| 41 | 3 | `test/follow_up_office_page_test.dart` | legacy Next Follow-up dates never create an automatic due filter | UNRESOLVED — RETEST REQUIRED |
| 42 | 3 | `test/task_detail_master_screen_test.dart` | Smart visibility keeps an ordinary Task detail compact | UNRESOLVED — RETEST REQUIRED |
| 43 | 4 | `test/widgets/home_page_test.dart` | overdue active task uses red text while card and icons stay neutral | UNRESOLVED — RETEST REQUIRED |
| 44 | 4 | `test/g6_swipe_rtl_acceptance_test.dart` | configured left and right swipes open Follow-up form and write only after save | UNRESOLVED — RETEST REQUIRED |
| 45 | 4 | `test/task_editor_dialog_test.dart` | Task editor saves a real all-day deadline from inside the clock dialog | UNRESOLVED — RETEST REQUIRED |
| 46 | 4 | `test/task_detail_master_screen_test.dart` | Smart visibility shows rich sections only when canonical data exists | UNRESOLVED — RETEST REQUIRED |
| 47 | 4 | `test/task_detail_master_screen_test.dart` | Task Details presents summary, metadata and due date once in RTL order | UNRESOLVED — RETEST REQUIRED |
| 48 | 4 | `test/issue_1891_lane_d_rollbox_test.dart` | issue 1891 tag roll box supports multi-select with apply/cancel | UNRESOLVED — RETEST REQUIRED |
| 49 | 4 | `test/home_today_about_test.dart` | About menu action opens the built-in Arvin about dialog | UNRESOLVED — RETEST REQUIRED |
| 50 | 4 | `test/calendar_page_test.dart` | prayer cards use mosque icon and subdued unregistered status | UNRESOLVED — RETEST REQUIRED |
| 51 | 4 | `test/home_stat_filters_test.dart` | time checkbox selections use OR without a numeric badge | UNRESOLVED — RETEST REQUIRED |
| 52 | 5 | `test/widgets/home_page_test.dart` | Focus Today is reachable from drawer More and global funnel with one result set | UNRESOLVED — RETEST REQUIRED |
| 53 | 5 | `test/quick_capture_dialog_test.dart` | timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder | UNRESOLVED — RETEST REQUIRED |
| 54 | 5 | `test/services/g1_drift_schema_test.dart` | malformed legacy task_people payload aborts migration without retiring source rows | TEST HARNESS DEFECT — FIXED IN eea746d |
| 55 | 5 | `test/widget_test.dart` | HomePage shows the empty-state message after loading | UNRESOLVED — RETEST REQUIRED |
| 56 | 5 | `test/task_editor_dialog_test.dart` | Task Editor cancelling the circular clock does not commit a partial date | UNRESOLVED — RETEST REQUIRED |
| 57 | 5 | `test/follow_up_office_page_test.dart` | asks the user to create a task when the list is empty | UNRESOLVED — RETEST REQUIRED |
| 58 | 5 | `test/task_detail_master_screen_test.dart` | Task Details does not present related people as assignees and keeps bottom content clear | UNRESOLVED — RETEST REQUIRED |
| 59 | 5 | `test/notebook_page_test.dart` | Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries | UNRESOLVED — RETEST REQUIRED |
| 60 | 5 | `test/canonical_calendar_launcher_test.dart` | repeat occurrence actions resolve back to the canonical Task | UNRESOLVED — RETEST REQUIRED |
| 61 | 5 | `test/report_center_page_test.dart` | Report Center quick presets apply from a dedicated bottom sheet | UNRESOLVED — RETEST REQUIRED |

## 7. Product regression status
The failed test set spans Task/Person persistence, Home filters and grouping, Follow-up Office, Checklist CRUD, Quick Capture and Project creation, Due Date preservation, Calendar, RTL swipe, RollBox, Reports, Navigation, Settings and Device Smoke workflow contracts. Presence of a Widget or class is not acceptance. Each failure needs source location, root cause, corrective commit and exact-SHA retest. No assertion was removed or weakened.
- Home clock contract (`_iranWallClockNow` / `_groupJalaliDate`): NOT VERIFIED. Require one injectable `nowProvider` and deterministic 09:00 current / 10:00 due test.
- Person/Task relation migration: INCOMPLETE pending malformed-payload retry and valid-parent/foreign-key tests.
- Follow-up Office, Checklist, Quick Capture, Project creation, Boolean filters, Due Date, Calendar, RTL Swipe, RollBox, Reports and Navigation: INCOMPLETE / UNRESOLVED against the 61 old failure records.
- Real physical device behavior: NOT VERIFIED.

## 8. Typography and asset disposition
- Current direct owner instruction dated 2026-11-12: **Vazirmatn is the only official/default Arvin UI font**; VazirHarf is not official; System Default is optional; weights 300/400/500/600/700; Theme is the source of truth; Dialog/Overlay follow it; PDF is separately validated; APK must package the font; user choice survives Force Stop/restart.
- This instruction is recorded as a dated controlling addendum in the REV9 master and DECISIONS on PR #3340. It supersedes the unresolved typography wording in the 2026-11-10 REV9 source section without deleting the source text.
- On #3384, `pubspec.yaml` declares only the Vazirmatn five-weight family. `lib/theme/font_registry.dart` exposes Vazirmatn and optional System Default. `lib/core/theme/arvin_theme.dart` uses Vazirmatn. `assets/fonts/README.md` correctly marks VazirHarf assets historical and not to be registered/packaged.
- VazirHarf binary/license files and `docs/typography/VAZIRHARF_V34_003_PROVENANCE.md` are retained as historical provenance only. They are not an approved active font family. The test filename `test/task_report_vazirharf_contract_test.dart` is misleading: its assertions check the Vazirmatn PDF/font contract; rename is a non-functional cleanup candidate, not yet changed.
- Old-candidate PDF evidence: artifact `13962129206`, digest `sha256:e6b8fdae57d74bd780b2b166878cf84300a0387b7bf44da1cecb0657b0a4989c`; it is tied to SHA `492a5c4...`, not the current candidate.

## 9. APK, signing and artifact audit
All artifact IDs below belong to old SHA `492a5c433ee215d0188a6075b159d4d72329d35e`, run `43247842294`; they are historical build artifacts, not acceptance evidence for `eea746d...`.
| Artifact | Artifact ID | SHA-256 digest | Meaning |
|---|---:|---|---|
| arvin-release-apk | 13962644376 | `a2b59aaf06bb32477938f56d882e393bcfeb868920f92afbb5dfbfe2ddc945fa` | Release APK build uploaded; production signing not verified. |
| arvin-staging-apk-audit-candidate | 13962594082 | `4d32990cff0cbbef98498b200a69239379f1091f65c018ab9ccf59a2ce7f644c` | Staging audit candidate. |
| arvin-debug-apk | 13962439670 | `f3709db89349bd91ff3901e79665c941960947293c15cfd46f7fefe829c3b678` | Debug APK. |
| arvin-staging-apk | 13962344441 | `4d32990cff0cbbef98498b200a69239379f1091f65c018ab9ccf59a2ce7f644c` | Staging APK. |
| arvin-staging-verification | 13962289560 | `92676f81bde2e24e0a8ec950ad8738498ad5e1a8f64608a4a631f7cd805e692a` | Staging verification logs. |
| arvin-vazirmatn-persian-pdf | 13962129206 | `e6b8fdae57d74bd780b2b166878cf84300a0387b7bf44da1cecb0657b0a4989c` | PDF/font evidence. |
| SQLite A–D snapshot | 13958416974 | `0e57caf9e4357d8d4d43e82ad0f60377f69d3ebd4c7cbaefb89b6818fa93565b` | Five reopen cycles and A–D snapshots. |

Staging job used an ephemeral staging signing key and passed its staging signature/manifest checks. The Release APK job built and uploaded an APK, but its staging-signature verification steps were skipped; this does not prove production signing. Protected production signing remains NOT VERIFIED and no production secret was changed.

## 10. Documentation authority and consolidation
- Canonical REV9 master: `docs/project-continuity/MASTER_GOVERNANCE.md` on PR #3340. REV8 is retained as `MASTER_GOVERNANCE_REV8_ARCHIVE.md`.
- Canonical six-document set: MASTER_GOVERNANCE, CURRENT_STATE, ROADMAP, DECISIONS, IMPLEMENTATION_LOG, HANDOFF under `docs/project-continuity/` on the REV9 branch.
- PR #3384 contains older REV8 copies of these documents and should not become a second active governance source.
- PR #3388 contains a parallel docs package (`ARVIN_PROJECT_OPERATING_PACKAGE.md`, `ARVIN_PROJECT_STATE.md`, `PROJECT_ROADMAP_2026-08-14.md`, memory decision/evidence/handoff and typography contract). Its state page references v49.0, while PR #3340 is the REV9 source. The two PRs must be reconciled before any documentation merge.
- Historical evidence and archives are retained. No duplicate docs were deleted. The requested report is this file; future status updates should link here rather than create another parallel health report.

## 11. Code, tests, dependencies and legacy components
| Component | Classification | Evidence / action |
|---|---|---|
| G1 Drift schema and canonical relational tables | ACTIVE | Production migration path; protect FKs and transactional recovery. |
| `task_people` legacy table migration | LEGACY INPUT / ACTIVE MIGRATOR | Preserve until migration acceptance and backup proof; do not drop source on failure. |
| `follow_ups`, `follow_up_people`, `people` legacy inputs | LEGACY INPUT / ACTIVE MIGRATOR | Retain compatibility tests and verify all data copied before retirement. |
| VazirHarf assets/provenance | HISTORICAL / INACTIVE | Retain; do not register or package as active font. |
| `test/task_report_vazirharf_contract_test.dart` | MISNAMED TEST FILE | Content asserts Vazirmatn. Rename only after confirming all references and CI discovery. |
| COMMAND 06-E / 06-H diagnostic tests | DIAGNOSTIC / HISTORICAL | Preserve evidence until migration root cause and source lineage are reviewed. |
| Old REV8 docs on #3384 | HISTORICAL COPY / CONFLICTING | Do not treat as canonical alongside REV9. |
| Dependencies in `pubspec.yaml` | UNRESOLVED AUDIT | Drift/sqlite3 and app packages are present; no full static reference/usage audit was completed, so no package is declared unused. |

No duplicate Repository/Service/Widget/Helper class was deleted in this pass. Full symbol-level dependency graph and test-duplication review remain INCOMPLETE. No data, source history, artifacts or tests were destructively removed.

## 12. Governance and protection
- Linked GitHub identity reports repository permission `admin=true`, `push=true`.
- `.github/CODEOWNERS` is present in PR #3388's changed-file set; it is not evidence that the file is merged or currently effective on Main.
- Branch protection/ruleset state could not be independently queried through the available connector actions in this audit. Effective owner approval requirements are therefore NOT VERIFIED here.
- Main was not written. No Secrets, credentials, access grants or rulesets were changed.

## 13. Required cleanup and next actions
1. Poll new Build `43269800292`, Device Smoke `43269800280`, SQLite Snapshot `43269800257`; confirm exact checkout SHA `eea746d...`.
2. Confirm the corrected malformed-payload test passes, then run independent migration recovery, rollback, retry and FK checks.
3. Complete D01–D05 separately, including actual Backup/Restore and interrupted migration.
4. Inspect and classify the remaining 60 failure records; preserve all assertions and rerun relevant tests on the new SHA.
5. Implement and test the shared Home `nowProvider` contract.
6. Reconcile PR #3388 with canonical REV9 PR #3340; keep one authority per domain and retain the REV8 archive.
7. Complete workflow inventory and exact trigger/dependency analysis before changing or retiring any workflow.
8. Complete per-branch SHA/last-commit/protection inventory before any branch disposition.
9. Verify PDF, APK font packaging, user font preference persistence and physical-device smoke on one exact candidate SHA.
10. Verify production signing only through the protected CI environment; do not touch secrets.
11. Preserve all branches, PRs, artifacts, historical decisions and migration sources until separately reviewed and approved.

## 14. Final decision
**NO-GO — NOT ACCEPTANCE READY.**  
The fixture defect has a corrective commit, but new-candidate Build/Device Smoke/SQLite Snapshot were not complete at the last poll. D01–D05 are not all accepted; 60 prior failure records remain unresolved; real Backup/Restore, D05 interruption/recovery, Home clock, physical-device acceptance and production signing remain open. No merge, release or deployment is authorized.
