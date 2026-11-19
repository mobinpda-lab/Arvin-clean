# COMMAND 63-R — MASTER TRACKER
**Mission:** Product completion, REV10 UI/UX, quality recovery and release readiness  
**Repository:** mobinpda-lab/Arvin-clean  
**Operational PR:** #3052 — OPEN / DRAFT / UNMERGED  
**Authorized working branch:** fix/recovery-calendar-device-smoke-2026-10-31  
**Last audited:** 2026-11-19  
**Release:** BLOCKED — NO-GO  
**Authority:** Latest explicit product-owner instructions in COMMAND 63-R supersede older conflicting design, typography and architecture notes. Historical records remain intact.

> This tracker was absent at the repository root, under docs/qa/, and on the operational branch at inspection time. This file is the initial evidence-led register, not a rewrite of historical reports. Every acceptance status is SHA-scoped.

## 1. Live GitHub baseline

| Item | Observed value |
|---|---|
| Main | 45e4202b03a434459e4c021a04efa7e8396359db |
| PR #3052 head | a2825e003bb9e6b5c2413b0dc74b085273b6148b |
| PR #3052 base SHA | 45e4202b03a434459e4c021a04efa7e8396359db |
| PR #3052 state | OPEN / DRAFT / UNMERGED |
| PR #3052 commits / files | 2,214 commits / 401 changed files |
| Repository permission | Read, Write, Admin, Maintain, Push and Pull available |
| Main protection | Main is treated as read-only under this mission |

The supplied Main SHA was confirmed by the live recent-commit listing. No Main mutation, merge, release or deployment was performed.

## 2. Owner decisions governing this mission

1. REV10 is the controlling design authority. Older UI specifications are historical wherever they conflict.
2. Vazirmatn is the only approved product font for this mission.
3. Local P2P is Sync Phase 1. It must work without Internet, account, cloud or Dropbox. Cloud/Dropbox is Phase 2 only.
4. The new Task Details experience is governed by the current COMMAND 63-R combination: Single-Column Focus Detail View, Actionable Linear List / Action Rows, Quick Presets / Quick Action Menu, and shared Universal Bottom Sheet.
5. Current product-owner instructions override older project notes and PR descriptions. No inferred Reminder state semantics or destructive migration is permitted.
6. Tests must not be deleted, skipped, bypassed, weakened or made green by changing expected product behavior to match a defect.
7. No result transfers from one SHA to another.

## 3. Exact-SHA CI evidence — PR #3052 head a2825e003bb9e6b5c2413b0dc74b085273b6148b

Build workflow run: **44490319550**.

| Job | Result |
|---|---|
| Analyze | SUCCESS |
| Test shard 0 | FAILURE — 302 passed / 25 failed |
| Test shard 1 | FAILURE — 151 passed / 10 failed |
| Test shard 2 | FAILURE — 234 passed / 12 failed |
| Test shard 3 | FAILURE — 242 passed / 9 failed |
| Test shard 4 | FAILURE — 186 passed / 10 failed |
| Test shard 5 | FAILURE — 195 passed / 6 failed |
| Debug APK | SUCCESS |
| Release APK build | SUCCESS |
| Staging APK | SUCCESS |
| Visual | SUCCESS |

**Total:** 1,310 test passes and 72 test failures across six shards. Build is FAILED overall. The six-shard green gate is NOT MET.

Independent exact-head workflows:
- Calendar Provider run 44490319483: SUCCESS.
- Follow-up File Persistence run 44490319367: SUCCESS.
- Device Smoke run 44490319359: PENDING; no jobs were returned at inspection. Device acceptance is NOT VERIFIED.
- Draft Review APK run 44490319361: SUCCESS. This is review/staging evidence only, not release authorization.
- Orchestrator / Production Loop success does not override the failed Build or pending Device Smoke.

### 3.1 Failed test inventory — shard 0 (25)

- test/settings_page_test.dart — settings exposes date, swipe, projects and canonical backup controls
- test/widgets/home_quick_capture_test.dart — Home primary add persists canonical task and preserves history
- test/quick_capture_dialog_test.dart — Quick Add opens an independent Persian reminder date/time picker
- test/quick_capture_dialog_test.dart — Quick Add shows the selected scheduling time and uses injected now
- test/follow_up_entry_page_test.dart — waiting FollowUp can add, select, reopen and remove a stable person
- test/home_last_follow_up_real_record_test.dart — Home shows last FollowUp only for a real record and does not create one
- test/task_contract_test.dart — due date stays independent from reminder and follow-up timestamps
- test/task_store_reminder_persistence_test.dart — legacy reminder-table migration removes its flag without losing reminder rows
- test/widget_test.dart — Home exposes the canonical workflow controls
- test/task_editor_dialog_test.dart — Back-style close prompts and can save Task edits without data loss
- test/home/home_owner_reference_test.dart — Home follows the owner header, real summary values and Today navigation
- test/home/home_filter_boolean_logic_test.dart — Home filters combine OR within each dimension and AND across dimensions
- test/task_editor_due_date_preservation_test.dart — editing preserves canonical due date independently
- test/follow_up_office_page_test.dart — selects one of multiple tasks and persists only to that task
- test/task_detail_person_persistence_test.dart — Task Details Follow-up person selection persists through canonical Person and relation tables
- test/task_detail_master_screen_test.dart — Task Details presents canonical follow-up title, note and waiting-for-response state
- test/task_detail_master_screen_test.dart — Task Details persists checklist reorder and additions immediately without changing Follow-up history
- test/home_wave2_editor_wiring_guard_test.dart — Home add/edit stay wired to the canonical Wave 2 coordinator
- test/notebook_page_test.dart — editor tag picker replaces tags on the same canonical note
- test/canonical_home_boundary_test.dart — normal save, Quick Capture, edit and completion never export automatically
- test/task_detail_checklist_crud_test.dart — checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps
- test/home_today_about_test.dart — Today menu action has a dedicated empty state
- test/quick_capture_project_create_test.dart — Quick Add offers Project create-new and selects the created project
- test/report_center_page_test.dart — Report Center exposes center and searchable task controls
- test/home_stat_filters_test.dart — category checkbox selection applies OR only after confirmation

### 3.2 Failed test inventory — shard 1 (10)

- test/widgets/home_page_test.dart — RTL Move-to-Today does not dismiss and None is a no-op
- test/widgets/home_page_test.dart — Home five filters stay in one RTL row without horizontal scrolling at phone widths and with keyboard
- test/widgets/home_page_test.dart — Home Past time filter excludes today and prioritizes incomplete tasks
- test/quick_capture_dialog_test.dart — Quick Add reminder presets match the product contract
- test/quick_capture_dialog_test.dart — Quick Add custom recurrence exposes every canonical time unit
- test/device_feedback_home_regression_test.dart — normal-height Home keeps empty groups and floating add action
- test/task_editor_dialog_test.dart — task editor recurrence uses RollBox and preserves interval
- test/home/home_filter_contract_test.dart — Home task card expands in place with real FollowUp history and preserves details route
- test/follow_up_office_page_test.dart — legacy Next Follow-up dates never create an automatic due filter
- test/task_detail_master_screen_test.dart — Smart visibility keeps an ordinary Task detail compact

### 3.3 Failed test inventory — shard 2 (12)

- test/task_detail_checklist_flow_test.dart — task detail displays checklist and toggles an item
- test/widgets/task_dialog_test.dart — creates a task with trimmed text and a unique tag
- test/quick_capture_dialog_test.dart — Quick Capture can create a center inline and immediately select it
- test/services/task_report_filter_test.dart — combined filters use AND semantics without mutating tasks
- test/device_feedback_home_regression_test.dart — Home keeps backup in the More menu instead of the header
- test/primary_bottom_navigation_test.dart — primary navigation exposes exactly five canonical destinations
- test/home/home_filter_contract_test.dart — Home keeps completed past tasks visible in a separate non-overdue group
- test/follow_up_office_page_test.dart — follow-up office exposes the shared five filter dimensions
- test/canonical_home_boundary_test.dart — Home owns canonical Task state without legacy ArvinTask projection
- test/task_people_page_test.dart — empty People UI adds and removes a local Person explicitly
- test/task_editor_category_project_integration_test.dart — new task saves typed category without an extra apply step
- test/home_today_about_test.dart — Today menu action shows only active canonical tasks due today

### 3.4 Failed test inventory — shard 3 (9)

- test/calendar_page_test.dart — prayer cards use mosque icon and subdued unregistered status
- test/task_detail_master_screen_test.dart — Smart visibility shows rich sections only when canonical data exists
- test/task_detail_master_screen_test.dart — Task Details presents summary, metadata and due date once in RTL order
- test/issue_1891_lane_d_rollbox_test.dart — issue 1891 tag roll box supports multi-select with apply/cancel
- test/g6_swipe_rtl_acceptance_test.dart — configured left and right swipes open Follow-up form and write only after save
- test/task_editor_dialog_test.dart — Task editor saves a real all-day deadline from inside the clock dialog
- test/work_agenda_pdf_renderer_test.dart — existing PDF renderer builds grouped Work Agenda bytes
- test/widgets/home_page_test.dart — overdue active task uses red text while card and icons stay neutral
- test/home_today_about_test.dart — About menu action opens the built-in Arvin about dialog

### 3.5 Failed test inventory — shard 4 (10)

- test/canonical_calendar_launcher_test.dart — repeat occurrence actions resolve back to the canonical Task
- test/task_detail_master_screen_test.dart — Task Details does not present related people as assignees and keeps bottom content clear
- test/notebook_page_test.dart — Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries
- test/widget_test.dart — HomePage shows the empty-state message after loading
- test/report_center_page_test.dart — Report Center quick presets apply from a dedicated bottom sheet
- test/widgets/home_page_test.dart — Home separates calendar today from selected focus and persists toggle removal
- test/widgets/home_page_test.dart — Focus Today is reachable from drawer More and global funnel with one result set
- test/quick_capture_dialog_test.dart — timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder
- test/task_editor_dialog_test.dart — Task editor cancelling the circular clock does not commit a partial date
- test/follow_up_office_page_test.dart — asks the user to create a task when the list is empty

### 3.6 Failed test inventory — shard 5 (6)

- test/task_timeline_page_test.dart — renders canonical task history in chronological order
- test/calendar_explicit_export_contract_test.dart — normal Task save, capture, edit and completion contain no outbound sync
- test/widgets/home_page_test.dart — completed tasks remain visible in All and Completed filters
- test/widgets/home_page_test.dart — Home uses the five checkbox filters as combined filters and preserves time grouping
- test/quick_capture_dialog_test.dart — canonical capture keeps title-only path and optional choices
- test/quick_capture_dialog_test.dart — Quick Add scheduling uses the canonical circular date/time picker

### 3.7 Root-cause triage status

The workflow logs show multiple distinct failure signatures, including:
- Missing expected widgets, labels, keys and selectors.
- Date preservation assertion receiving null where a canonical due date was expected.
- Scroll/tap failures caused by missing or ambiguous finder matches.
- pumpAndSettle timeouts.
- RangeError in source-boundary tests.
- Duplicate finder cardinality and unexpected taxonomy/filter output.

These are observed symptoms only. They do not establish a shared root cause. Each failure must be mapped to its exact source behavior, reproduced, corrected minimally and rerun on a new exact SHA. No test expectation may be weakened merely to match the current UI.

## 4. Parallel PR audit and integration dependencies

| PR | Head SHA | Base branch | Changed files | Current state |
|---|---|---|---:|---|
| #3567 Design System | 6d9cb754cd5bade41dac130653d03e852774cbb1 | operational branch | 10 | OPEN / DRAFT |
| #3570 Task/Reminder/Occurrence/Checklist | fd4954d773e039cb56ed31806fd2b4790b82d3b5 | operational branch | 11 | OPEN / DRAFT |
| #3573 Vazirmatn | 6d0dc85ed2ce8bb144c157e39aabd94fe7a049ba | operational branch | 8 | OPEN / DRAFT |
| #3574 Person exclusions | 8aca2bd36ea28ae8c291e7418541453d12847de2 | operational branch | 4 | OPEN / DRAFT |
| #3575 Backup/Restore exclusions | 6b1a03f502d5c642ba28a8884186f4a348b0e572 | PR #3574 branch | 9 | OPEN / DRAFT |

Shared-file collision watch:
- #3570 and #3574 both change lib/services/g1_drift_schema.dart. Their diffs must be reconciled before either is integrated.
- #3574 and #3575 both change lib/services/task_store.dart. #3575 is dependent on #3574 and must be reviewed as a sequence.
- #3567 changes lib/main.dart, which is also part of the operational PR's large diff. Compare against the operational branch before integration.
- PR #3575 reports base SHA 90a8100c0e58fe0b6cedc9e1df3b234adf951b5d, while PR #3574 head is 8aca2bd36ea28ae8c291e7418541453d12847de2. Resolve this base/head discrepancy before accepting the dependency chain.
- Do not merge these PRs directly into Main. The authorized target remains the operational branch and the integration order must be explicit.

Workflow checkpoints on child PR heads:
- #3567: Build queued; Device Smoke pending; Follow-up File Persistence success.
- #3570: Build queued; Device Smoke pending; Follow-up File Persistence success.
- #3573: Build in progress; Device Smoke pending; Follow-up File Persistence success.
- #3574: Build pending; Device Smoke pending; Follow-up File Persistence success.
- #3575: Build queued; Device Smoke pending; Follow-up File Persistence success.
No child PR has complete six-shard and device acceptance evidence in this checkpoint.

## 5. Vazirmatn asset audit

The PR #3573 branch contains all nine static TTF files. Their OpenType OS/2 weight classes were read from the actual font binaries and match the declared Flutter weights:

| Flutter weight | File | OS/2 weight class | Git blob SHA |
|---:|---|---:|---|
| 100 | Vazirmatn-Thin.ttf | 100 | b7a7d233e2a78b48d2eaa6733dd4ba683a92d847 |
| 200 | Vazirmatn-ExtraLight.ttf | 200 | b7b947e6acda06dd5c545a2fcd506900500afaa8 |
| 300 | Vazirmatn-Light.ttf | 300 | 2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42 |
| 400 | Vazirmatn-Regular.ttf | 400 | 64e4a8189557a17b63fd7a77794207483e592972 |
| 500 | Vazirmatn-Medium.ttf | 500 | 1e08dd54d90a4879451ef0f80fe0d8068fb7462f |
| 600 | Vazirmatn-SemiBold.ttf | 600 | 6b3842aca6055c8258404b1758133b81c961a13f |
| 700 | Vazirmatn-Bold.ttf | 700 | efa9b095da01d299310bdcae293e24e657fe6da9 |
| 800 | Vazirmatn-ExtraBold.ttf | 800 | 380bd15866f3364d7c34af1cbd3c15a2e209dfee |
| 900 | Vazirmatn-Black.ttf | 900 | 4b9bd66179952e5b2edcfd97acbdef6d4acd0ea2 |

The PR pubspec maps all nine files to weights 100–900. The PR adds the four missing weights (100, 200, 800, 900); the five existing weights are already present in the operational baseline. The branch also includes AUTHORS and existing license assets.

**ZIP status:** No vazirmatn-v*.zip archive was found in the repository or attached to the inspected PR file list. The repository font README identifies upstream release v33.003 and records archive SHA-256 0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb. The actual ZIP could not be downloaded through the available GitHub/web retrieval path in this session; therefore ZIP checksum and archive contents are NOT VERIFIED. The nine committed TTF binaries themselves were inspected.

Remaining font acceptance: runtime rendering on Android, Persian/Arabic shaping, Persian digits, ZWNJ, punctuation, fallback behavior, long/multiline layout and screenshot review. Font metadata alone does not close these gates.

## 6. Design and architecture reconciliation

- The current Task Details specification found in docs/project-continuity/task_detail_ui_ux_spec.md describes an older explicit display/edit-mode flow. COMMAND 63-R's newer three-pattern interaction model and Universal Bottom Sheet supersede conflicting portions. Do not treat the old spec as final acceptance.
- PR #3567's theme branch uses the owner-approved REV10 palette: Primary #078B91, Dark/Header #066F75, Soft #DDF7F5, Background #F0FAF9, Border #D9ECEA. Its palette is aligned; token/component coverage remains partial.
- Current continuity documents describe earlier REV8/REV9-era states. Their migration and design notes remain historical evidence; COMMAND 63-R governs the current mission.
- The Local P2P specification already defines a Phase 1 draft: same local network, authenticated encrypted transport, QR/PIN pairing, bidirectional resumable exchange, idempotent apply and explicit trust revocation. The document explicitly says implementation is NOT VERIFIED. Cloud/Dropbox is deferred Phase 2.
- Legacy follow-up scheduling columns and migration retirement remain a data-safety risk. No destructive DDL or schema retirement is accepted without real database inspection, backup, parity, rollback and readback evidence.

## 7. Acceptance matrix

| Workstream | Current status | Evidence required to close |
|---|---|---|
| Main / governance protection | VERIFIED for this audit | Recheck before every write |
| Six-shard CI | FAILED | All six green on one exact SHA |
| Analyze | PASS on a2825e0 | Repeat on final candidate SHA |
| Calendar Provider | PASS on a2825e0 | Repeat on final candidate SHA and device |
| Follow-up persistence | PASS on a2825e0 | Repeat on final candidate SHA |
| Device Smoke | NOT VERIFIED | All required lanes complete on exact candidate |
| Design System | PARTIAL | REV10 comparison, shared-component rollout, light/dark and RTL tests |
| Task Details / Universal Bottom Sheet | PARTIAL | Runtime implementation, interaction tests, visual review |
| Vazirmatn nine weights | FILES + METADATA VERIFIED on #3573 branch | Merge-safe integration, Android rendering and glyph/fallback acceptance |
| SQLite / Persistence | PARTIAL | Full entity parity, NULL/unknown fields, duplicate prevention, retry, rollback and readback |
| Backup / Restore | PARTIAL | Real file-backed round trip, independent DB restore, IDs/relations and rollback |
| People / Notebook | PARTIAL | History preservation, relation integrity, unlink/delete behavior |
| Local P2P Phase 1 | DESIGN DRAFT | Protocol review, implementation, security and two-device acceptance |
| APK release readiness | NOT VERIFIED | Final candidate artifact, manifest, signature and owner authorization |
| Owner acceptance | PENDING | Explicit product-owner approval |

## 8. Next execution order

1. Reconfirm Main, operational branch, all PR heads and workflow runs before any code change.
2. Re-run/inspect the exact failing Build job logs as needed; maintain the 72-test inventory and identify root cause per test.
3. Prioritize failure clusters by shared runtime behavior: Home/filtering, Quick Capture/date-time, Task Editor/Details/checklist, Follow-up/People, Notebook, Reports and Calendar.
4. Inspect and reconcile #3570 and #3574 schema diffs before integration; verify #3575's base/head discrepancy and preserve its dependency.
5. Compare #3567 tokens and components against REV10 before accepting its palette or shared widgets.
6. Integrate the Vazirmatn files only through the authorized PR chain; finish runtime glyph and layout acceptance.
7. Complete real-data migration/backup safety before any legacy schema retirement.
8. Document and review Local P2P protocol/data contract before implementation.
9. Run all six shards, Analyze, independent workflows and Device Smoke on one exact candidate SHA.
10. Keep PR #3052 OPEN / DRAFT / UNMERGED. No merge, release or deploy without separate explicit authorization.

## 9. Immutable release gate

**RELEASE = NO-GO** until every required acceptance criterion passes on one exact candidate SHA, data safety and device evidence are complete, the Master Tracker is current, and the product owner explicitly accepts the candidate. This tracker does not grant merge, release or deployment permission.


## 10. REV10 continuity and additional UI PR audit — 2026-11-19

The Library search found the COMMAND 28 REV10 Migration Engineering Draft, explicitly marked NOT REV10-approved. It states that the full authoritative REV10 governance package and 14 November addendum were not present in that archive. The repository also contains older REV8/REV9-era documents. Therefore the exact owner-approved constraints recovered from prior product discussions are recorded here, but no claim is made that the complete REV10 package has been located:
- Brand palette: Primary #078B91; Dark/Header #066F75; Soft #DDF7F5; Background #F0FAF9; Border #D9ECEA.
- Home: five visible RTL filters including Center; four grouping modes: Time, Projects, Categories, Tags.
- Task Details: single-column focus, actionable rows and quick presets; shared Universal Bottom Sheet; Jalali date/time; checklist, reminders, recurrence, Center, Project, Category, Tags, people follow-up, attachments and Notebook note.
- Vazirmatn is the only official font under the current owner instruction.

### 10.1 Additional UI PRs

| PR | Head SHA | Scope | Current assessment |
|---|---|---|---|
| #3569 Home grouping / five filters | 19a657503bd7b1a28576a5a0676a0a48af7ffa34 | Home grouping service, filter UI and tests | PARTIAL |
| #3572 Task Details | be9248d77348421bd044e2480634e804f5782aba | Task Details and history tests | PARTIAL |

Branch comparison against the current operational branch reports #3567, #3569 and #3572 as DIVERGED, with each child branch 13 commits behind the operational branch at the comparison checkpoint. Rebase/port and compare diffs before integration; do not merge these branches directly.

### 10.2 Design System PR #3567

The actual theme constants in #3567 match the approved palette above. Its current tokens cover spacing, radius, motion, touch targets, typography, shadows, buttons, inputs, cards, navigation and dialogs. The PR does not yet establish the full requested shared component set: Universal Bottom Sheet, Action Rows, Empty/Loading/Error States and complete RTL component coverage remain open.

### 10.3 Home PR #3569

The branch provides a HomeGroupingService for Time, Projects, Categories and Tags and a five-filter row including Center with visible labels. However, its main.dart still invokes HomeGroupMode.time only; no user-facing mode selector was found for Projects, Categories and Tags. Therefore the four-mode Home grouping experience is NOT COMPLETE. The Home test on the operational branch had stale plural labels; it has been updated to assert the five actual REV10 filter controls and their singular labels. This test change is not yet validated by a fresh completed CI run.

### 10.4 Task Details PR #3572 and operational page

PR #3572 is not a complete REV10 Task Details implementation. Its inspected branch has no Universal Bottom Sheet, no TaskReminder section, no attachments and no Notebook integration. The operational branch's current Task Details includes reminders, recurrence, Center, Project, Category, Tags, checklist and Follow-up, but the inspected file still has no shared Universal Bottom Sheet, no attachment section and no Notebook note connection. These remain product gaps.

### 10.5 New test/storage corrections on the operational branch

The following source-grounded corrections were committed on the authorized operational branch after the original a2825e0 audit:
- Replaced stale source-boundary anchors in canonical_home_boundary_test.dart and calendar_explicit_export_contract_test.dart with method-body extraction; this preserves the original outbound-sync assertions and prevents RangeError from an obsolete method name.
- Updated canonical_calendar_launcher_test.dart to exercise the actual Task Details inline auto-save title field instead of a non-existent edit-mode toggle; it also verifies the same Task ID is retained.
- Updated home_wave2_editor_wiring_guard_test.dart to account for the additional Task Details Project callback and explicitly assert that callback wiring.
- Updated task_contract_test.dart and task_editor_due_date_preservation_test.dart to construct canonical TaskReminder rows rather than using the deprecated constructor-only reminderDate input.
- Added an idempotent, transactional task_reminders migration that retires the obsolete is_legacy_task_reminder SQL column only when legacy rows have the canonical stable ID. It compares the complete row payload before/after, including unknown columns and explicit NULL values, and verifies the remaining schema columns.
- Strengthened task_store_reminder_persistence_test.dart to verify unknown payload, explicit NULL, stable reminder identity and TaskStore readback.
- Updated task_editor_dialog_test.dart to match ArvinTagRollBox's immediate onChanged selection contract; it no longer looks for a nonexistent Apply button.
- Updated widget_test.dart to assert the five REV10 Home filters including Center and their visible labels.

These are implementation/test changes, NOT accepted fixes yet. They must pass the focused tests and all six shards on one exact SHA before any failure is marked resolved.

### 10.6 Shared schema conflict

PR #3570 already contains a separate _dropLegacyTaskReminderFlag implementation in g1_drift_schema.dart. The operational branch now has a more defensive version with stable-ID validation and full row/unknown-column/NULL parity checks. Do not combine both methods or integrate the schema file wholesale. Reconcile the single migration path during controlled integration. PR #3570's inspected branch is schema version 17, not v19/v20. Its code includes a legacy reminder-flag retirement and its Occurrence/Checklist test uses file-backed NativeDatabase with three installs, close/reopen, unknown nested fields, explicit NULL, integrity_check and foreign_key_check. A separate Library engineering draft references v19/v20, but that migration chain was not found in PR #3570 and is NOT VERIFIED or accepted.

### 10.7 Current validation status for the new changes

At the last lookup, the latest operational candidate was 0535e78ff6f271086c259fadcfd088d52efcf79b. Its Build run 44504242136 was PENDING with no jobs returned; Calendar Provider 44504241833 QUEUED; Follow-up Persistence 44504241878 QUEUED; Device Smoke 44504241926 PENDING; Draft Review APK 44504241933 QUEUED. No new test fix is accepted until the exact latest candidate has completed validation.

**Release remains NO-GO.**


## 11. Persistence / Backup evidence refinement — 2026-11-19

### PR #3570 — actual schema scope
- The inspected PR #3570 branch declares G1DriftSchema.version = 17. It is not a v19/v20 schema implementation.
- Its command63_occurrence_checklist_persistence_test.dart creates a real temporary SQLite file, performs three schema installs, closes/reopens with a fresh executor, checks full Task JSON parity, nested unknown Occurrence state, explicit NULL fields, integrity_check and foreign_key_check.
- The PR #3570 schema includes a separate _dropLegacyTaskReminderFlag helper using SQLite 3.35+ DROP COLUMN. The operational branch's current implementation adds stable-ID validation and before/after parity over all remaining columns and values. Keep one reconciled implementation only.
- No DROP TABLE statement was found in the inspected PR #3570 g1_drift_schema.dart. Its current branch is version 17. Do not label it v19/v20.
- The Library COMMAND 28 draft mentions v19/v20 in a separate historical context, but no matching v19/v20 implementation was verified in the current PR set. That historical chain remains unaccepted until its actual source and migration evidence are located.

### PR #3574 / #3575 — Person and Backup/Restore evidence
- PR #3574's person_directory_exclusion_migration_test.dart uses a file-backed SQLite database, closes/reopens it, checks retained Person identity, Task and Follow-up links, exclusion tombstone behavior, explicit re-add and database integrity.
- PR #3575's person_directory_exclusion_backup_test.dart uses separate file-backed source and target SQLite databases and validates the backup document, reconciliation, restore of exclusions, historical relations, integrity_check and foreign_key_check.
- These are meaningful file-backed database tests. However, the backup service itself is faked in the round-trip test; the test does not perform an actual Android Storage Access Framework file write/read. Android device-level backup/restore remains NOT VERIFIED.
- canonical_backup_manager_test.dart and home_restore_orchestration_test.dart also use fake backup services for orchestration and rollback; they do not replace an actual file IO/device acceptance test.

### Remaining unknown-field risk
- The current TaskReminder model's JSON serialization contains only declared fields and has no opaque unknown-field envelope. TaskStore's reminder relation mapping likewise serializes the known SQL columns. The schema migration above preserves unknown SQL columns and explicit NULL during that migration, but this does not prove arbitrary unknown TaskReminder JSON fields survive a later load/save cycle.
- Do not claim complete unknown-field preservation for TaskReminder until a canonical opaque-payload contract and a round-trip test are added. This is a data-contract issue requiring controlled design, not a reason to drop unknown data.



## 12. Exact failure-log triage and live workflow refresh — 2026-11-19

### 12.1 Operational branch moved during audit
- Main was re-read from GitHub: `45e4202b03a434459e4c021a04efa7e8396359db`, protected=true.
- PR #3052 remained OPEN / DRAFT / UNMERGED, base Main SHA unchanged.
- Operational branch HEAD at this checkpoint: `760cc7a4e4ff9f08d08f2a84a1e474137889a466`, commit message: `docs(command-63-r): correct schema and backup evidence`.
- The prior `0535e78` observation is no longer the branch head. Do not treat its pending Build as current-head evidence.
- Exact-head workflow runs associated with `760cc7a`: Build #11807 PENDING; Device Smoke #8966 PENDING; Calendar Provider #3010 QUEUED; Follow-up Persistence #2889 QUEUED; Draft Review APK #2095 QUEUED; orchestration/parallel jobs QUEUED. No current-head acceptance result exists yet.

### 12.2 Confirmed six-shard failure inventory on Build #11720 / SHA a2825e0
The six actual job logs were downloaded and parsed. The failed test counts are exactly 25 + 10 + 12 + 9 + 10 + 6 = 72. The 72 test names remain recorded in Sections 3.1–3.6. Distinct, directly observed failure signatures include:
- Settings / Quick Capture / Task Editor / Today actions: missing Persian labels or controls (e.g. `انتخاب تم و رنگ اصلی برنامه`, `یادآور`, `تکرار`, `پروژه`, `اعمال`).
- Quick Capture scheduling: selected time finder returned one match where the test expected two; this requires checking the due/reminder display contract, not mechanically changing the assertion.
- Home / Follow-up / Task Details: missing real-record labels, missing selected-person key, missing filter/group labels and incomplete detail sections.
- Task contract and due-date preservation: actual dueDate was null or differed from the expected canonical date/time.
- Reminder migration: obsolete marker column remained in the observed database on that SHA.
- Widget harness failures: casts of SizedBox/ListView/KeyedSubtree to Scrollable/Container and pumpAndSettle timeouts. These are harness/runtime tree symptoms; each needs its own reproduction and must not be dismissed as flaky.
- Notebook / Reports / Calendar / PDF: taxonomy mismatch, missing report controls, export-contract and PDF output mismatches.
- Other exact failures include unexpected report filter output, swipe result false, wrong Home overdue color and missing expected prayer-card presentation.
These are confirmed symptoms. Root cause is NOT YET PROVEN for every test. No tests or assertions were removed.

### 12.3 Child PR exact-head workflow refresh
- #3567 head `6d9cb754`: Build #11776 QUEUED; Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3569 head `19a65750`: Build #11781 QUEUED; Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3570 head `fd4954d7`: Build #11782 QUEUED; Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3571 head `60de06ec`: Build #11774 FAILED; all six shards failed (11, 8, 23, 4, 9, 9 tests respectively); Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3572 head `be9248d7`: Build #11770 FAILED; all six shards failed (25, 12, 10, 10, 8, 6 respectively); Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3573 head `6d0dc85e`: Build #11743 FAILED; all six shards failed (25, 9, 6, 10, 10, 12 respectively); Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3574 head `8aca2bd3`: Build #11748 QUEUED; Device Smoke PENDING; Follow-up Persistence SUCCESS.
- #3575 head `6b1a03f5`: Build #11747 IN PROGRESS at last poll; Device Smoke PENDING; Follow-up Persistence SUCCESS.
Child PR Build failures include the same inherited broad product/test failures and are not evidence that the narrow child change caused all failures. Their branches are based on older operational SHA a2825e0 and are not an integrated candidate.

### 12.4 Source-diff findings requiring correction before acceptance
- #3567: the new token file defines card shadow blur=8 and offset=(0,2), while the existing theme-token test still asserts blur=10 and offset=(0,4); the newly added design-token test separately asserts offset=(0,2). This is an internal token/test contradiction. Preserve the existing visual contract unless a new owner-approved shadow value is documented; reconcile code and tests without deleting assertions.
- #3569: grouping service supports Time/Projects/Categories/Tags, but the inspected app wiring still selects Time only. A user-facing grouping-mode selector and persisted/accessible selection are not evidenced; four-mode grouping is not accepted.
- #3571: adding `showLabel: true` to Quick Capture roll boxes addresses missing labels. The time test expects one visible due-time value before a reminder is selected, then selects 15 minutes before and verifies the independent 14:20 reminder value. This matches the due-date/reminder independence contract and is not a weakened assertion. It remains UI-level evidence only; persistence still needs separate validation.
- #3572: the page adds a Task Details section heading and scrolls tests to off-screen content. This is a narrow presentation improvement, not the complete Task Details contract; Universal Bottom Sheet, attachments and Notebook linkage remain absent in the inspected PR.
- #3570: its `_dropLegacyTaskReminderFlag` uses SQLite 3.35+ DROP COLUMN. Reconcile with the operational branch's more defensive stable-ID and row-parity migration; do not combine two independent implementations or silently assume every supported Android SQLite version meets 3.35.
- #3574/#3575: retain the explicit dependency and file-overlap controls recorded above. Their fake backup-service tests do not prove Android SAF file IO.

### 12.5 Next controlled actions
1. Wait for and inspect all jobs of current operational HEAD `760cc7a`; collect exact six-shard logs before claiming any test resolved.
2. Fix narrow, proven source/test contradictions in their own authorized child branches; do not bulk merge stale branches.
3. Reconcile the #3567/#3569 shared Home/theme files and #3570/#3574 schema overlap by diff, then validate one candidate SHA.
4. Keep all 72 baseline failures tracked until each has a reproduced root cause, minimal fix, focused rerun and full-shard evidence.
5. Preserve Device Smoke, Android file backup/restore, full REV10 page review, Local P2P implementation/security and owner acceptance as independent release gates.

**Checkpoint disposition:** six-shard baseline remains FAILED; current operational Build is PENDING; child PRs #3571/#3572/#3573 have failed Builds; no child PR is integration-accepted. Main unchanged; no merge/release/deploy. RELEASE = NO-GO.


## 13. Design System internal token correction — 2026-11-19

PR #3567 was source-reviewed and an internal contradiction was confirmed: its new shared card shadow tokens were set to blur 8 / offset (0,2), while the pre-existing theme regression test still requires blur 10 / offset (0,4). The new token test also encoded the new offset (0,2). To preserve the established visual shadow contract and keep both tests meaningful, the isolated Design System branch was corrected:
- `lib/theme/arvin_design_tokens.dart`: cardBlur restored to 10 and cardOffset to (0,4).
- `test/theme/arvin_design_tokens_test.dart`: explicitly asserts blur 10 and offset (0,4), alongside the existing positive/relative shadow checks.
- Commits: `65e1a07de5b7254e66ed772956c1d690bd5d26a2` (token correction), `7ba6036dfaa3bc7485413b956500f1272f0fecb3` (test contract alignment).
- PR #3567 current head: `7ba6036dfaa3bc7485413b956500f1272f0fecb3`, still OPEN / DRAFT and based on stale operational SHA `a2825e0`.
- Exact-head Build #11810 is PENDING; Device Smoke #8969 is PENDING; Follow-up Persistence #2892 is QUEUED. The correction is NOT ACCEPTED until focused and six-shard tests pass on this exact head and the branch is reconciled against the current operational head.

This was a minimal token/test consistency correction on the child PR branch only. No Main or operational code was changed by this correction; no PR was merged.


### 13.1 Quick Capture assertion review
PR #3571's change from two visible 14:35 labels to one is consistent with the product contract: a due-time value must not be mirrored as a reminder when no reminder has been selected. The same test then selects the 15-minute preset and expects 14:20. This is a correct UI-level distinction, not a test weakening. It does not prove persisted reminder data and remains subject to exact-head CI/device validation.


## 14. Live checkpoint after subsequent operational-branch movement — 2026-11-19

### 14.1 Current verified GitHub state
- Main: `45e4202b03a434459e4c021a04efa7e8396359db`, protected=true; unchanged.
- PR #3052: OPEN / DRAFT / UNMERGED; base=main; base SHA remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- Operational branch HEAD at this checkpoint: `3482cab6fea8a9dbf03f6fffdf32f3b7915ea491`. It has advanced beyond `760cc7a`; all evidence must be evaluated at this exact SHA.
- Tracker itself is being updated on the operational branch; this update must not be confused with an application-code fix.

### 14.2 Exact-head CI state for `3482cab6`
- Build #11813: PENDING; job matrix not yet exposed by GitHub at the time of this poll.
- Device Smoke #8972: PENDING.
- Follow-up File Persistence #2895: PENDING.
- Draft Review APK #2101: PENDING.
- Parallel Wave #8149, Orchestrator #8685, PR Wakeup #7418, Production Loop #31614: PENDING.
- G1 lock sync #5668 and Calendar Provider Acceptance #3014: QUEUED.
- No six-shard result is available yet for this SHA. Do not carry forward any previous SHA's test results.

### 14.3 Child PR integration readiness
- #3567 current head `7ba6036d`; still OPEN / DRAFT, based on stale `a2825e0`.
- #3569 `19a65750`; #3570 `fd4954d7`; #3571 `60de06ec`; #3572 `be9248d7`; #3573 `6d0dc85e`; #3574 `8aca2bd3`: all remain based on stale `a2825e0`.
- #3575 `6b1a03f5`: based on intermediate branch `command-63-r/path-f-person-directory-exclusion` at `90a8100c`, not on the current operational HEAD.
- All eight child PRs remain OPEN / DRAFT. None is approved for merge or integration by status alone. Rebase/cherry-pick only after dependency and overlapping-file review.

### 14.4 Decision
- Continue the 72-test failure inventory from the original six-shard run; do not call the count fixed until each failure has a demonstrated root cause and a passing focused rerun.
- Keep the #3567 shadow-token correction isolated pending its exact-head Build and stale-base reconciliation.
- Quick Capture's due-time/reminder distinction has a coherent product explanation, but no persisted-data or device acceptance is claimed.
- No application code was changed in this checkpoint. No merge, release, or deploy was performed.

**Checkpoint disposition:** Main protected and unchanged; current operational HEAD CI pending; six-shard acceptance unavailable; child PRs stale-base and unintegrated; Device Smoke pending; persistence, UI, sync, and APK acceptance remain open. RELEASE = NO-GO.


## 15. COMMAND 64-R live execution checkpoint — 2026-11-19

### 15.1 Repository and protected baseline
- Repository access verified: admin/maintain/push/pull permissions are true.
- Main branch API re-read: SHA `45e4202b03a434459e4c021a04efa7e8396359db`; `protected=true`. Main was not modified.
- PR #3052 remains OPEN / DRAFT / UNMERGED, base `main`, base SHA `45e4202b03a434459e4c021a04efa7e8396359db`, head `c10fbe3f7ccd5b2aee34bc4f987c4f3276fba878`. This head is a documentation checkpoint, not an application-code fix.

### 15.2 Exact-head CI refresh
- Build run `44505964469` for #3052 head `c10fbe3`: QUEUED. The job matrix is present; Analyze, test-0 through test-5, visual, and Debug/Release/Staging APK jobs are all QUEUED. No test result exists yet.
- Device Smoke `44505964461`: PENDING.
- Follow-up File Persistence `44505964476`: PENDING.
- Calendar Provider Acceptance `44505964482`: QUEUED.
- Draft Review APK `44505964555`: PENDING.
- Parallel Wave `44505964430`, Orchestrator `44505964506`, Production Loop `44505964422`, G1 lock sync `44505964471`: QUEUED/PENDING as reported by GitHub. No exact-head acceptance is claimed.

### 15.3 Design System correction — PR #3567
- PR #3567 remains OPEN / DRAFT, head `7ba6036dfaa3bc7485413b956500f1272f0fecb3`, base operational branch at stale SHA `a2825e003bb9e6b5c2413b0dc74b085273b6148b`.
- The correction history recorded in Section 13 remains: token correction commit `65e1a07de5b7254e66ed772956c1d690bd5d26a2`; current head commit `7ba6036...` aligns the token regression assertion with blur 10 / offset (0,4). The fetched current commit changes `test/theme/arvin_design_tokens_test.dart`; token source was changed in the preceding commit.
- Exact-head Build run `44505240154`: QUEUED; Analyze and six shards are all QUEUED. Device Smoke run `44505240086`: PENDING. Therefore the shadow correction is source-aligned but NOT CI-ACCEPTED and NOT integration-accepted.

### 15.4 Dependent PR status at this poll
All listed PRs remain OPEN / DRAFT; none was merged or integrated. Each branch is still based on stale operational SHA `a2825e0`, except #3575 which is based on #3574 branch SHA `90a8100c0e58fe0b6cedc9e1df3b234adf951b5d`:
- #3567 Design System: `7ba6036dfaa3bc7485413b956500f1272f0fecb3`; Build QUEUED; Device Smoke PENDING.
- #3569 Home/five filters: `19a657503bd7b1a28576a5a0676a0a48af7ffa34`; Build FAILED (run `44499411767`; Analyze and all six shards failed); Persistence SUCCESS; Device Smoke PENDING.
- #3570 Task/Reminder/Occurrence/Checklist: `fd4954d773e039cb56ed31806fd2b4790b82d3b5`; Build FAILED (run `44499570840`; six shards failed, Analyze SUCCESS); Persistence SUCCESS; Device Smoke PENDING.
- #3571 Quick Capture: `60de06ecb0dae94fdbe3ebc6a4c0d93ce81f156e`; Build FAILED (run `44498710771`; six shards failed, Analyze SUCCESS); Persistence SUCCESS; Device Smoke PENDING.
- #3572 Task Details: `be9248d77348421bd044e2480634e804f5782aba`; Build FAILED (run `44498204462`; six shards failed, Analyze SUCCESS); Persistence SUCCESS; Device Smoke PENDING.
- #3573 Vazirmatn: `6d0dc85ed2ce8bb144c157e39aabd94fe7a049ba`; Build FAILED (run `44494326998`; six shards failed, Analyze SUCCESS); Persistence SUCCESS; Device Smoke PENDING.
- #3574 Person directory exclusion: `8aca2bd36ea28ae8c291e7418541453d12847de2`; Build FAILED (run `44496047708`; six shards failed, Analyze SUCCESS); Persistence SUCCESS; Device Smoke PENDING.
- #3575 Backup exclusions: `6b1a03f502d5c642ba28a8884186f4a348b0e572`; Build FAILED (run `44495959431`; Analyze and six shards failed); Persistence SUCCESS; Device Smoke PENDING.
- PR #3568 returned 404 from GitHub and is not treated as an existing dependent PR.

### 15.5 72-failure reconciliation and disposition
- The historical baseline remains 72 failed tests on Build #11720 / SHA `a2825e0`, six shards. No new six-shard execution has completed on the current operational head; therefore no baseline failure can be marked resolved from the present queued run.
- The six shards are independent execution partitions, not 72 proven independent root causes. The existing signature clusters (labels/controls, due-time vs reminder semantics, Home/Follow-up/Details, due-date contract, reminder migration, widget harness, Notebook/Reports/Calendar/PDF, swipe/color/prayer card) remain symptom groups. Root cause is still unproven for every individual test.
- Current child PR builds show repeated all-shard failures on stale-base heads; these do not establish that the narrow child changes caused all failures. No tests/assertions were deleted or weakened in this checkpoint.

### 15.6 Integration and product safety
- No branch rebase, cherry-pick, merge, release, deployment, or Main write was performed. Shared-file overlaps and stale bases remain a hard integration gate; #3574 -> #3575 dependency is preserved.
- TaskReminder unknown JSON-field round-trip, Android SAF Backup/Restore, physical-device font/UI smoke, complete REV10 page audit, Universal Bottom Sheet, full Home grouping selector, and Local P2P implementation remain unaccepted as described in earlier sections.
- No APK artifact from the current exact operational head has completed or been reviewed. The queued Build includes APK jobs but no artifact is yet evidenced.

**COMMAND 64-R checkpoint:** current operational candidate `c10fbe3f7ccd5b2aee34bc4f987c4f3276fba878`; Main protected and unchanged; current Build queued; 72 historical failures remain open; #3567 correction pending CI; child PRs stale-base and unintegrated. RELEASE = NO-GO.


## 16. COMMAND 65-R live evidence checkpoint — 2026-11-19

### 16.1 Protected refs and operational HEAD
- Repository: `mobinpda-lab/Arvin-clean`.
- Main SHA re-confirmed by repository commit search: `45e4202b03a434459e4c021a04efa7e8396359db`. No Main write was performed.
- PR #3052 remains OPEN / DRAFT / UNMERGED, base=main, base SHA `45e4202b03a434459e4c021a04efa7e8396359db`.
- Live PR HEAD at the start of this checkpoint was `c7248dac5c547c3c2682b5b956d007487cb36b1d`, not the previously reported `c10fbe3f7ccd5b2aee34bc4f987c4f3276fba878`.
- Two proven analyzer blockers were fixed on the authorized #3052 branch only: moved the existing import directives before top-level declarations in `test/calendar_explicit_export_contract_test.dart` and `test/canonical_home_boundary_test.dart`. No assertion was removed or weakened.
- Fix commits: `fa8774d3eeebc96df979f047b7deadb3cb83938a` and `8274347cc23b991c37764965a2719e12b6f148bf`.
- Latest HEAD after these edits: `8274347cc23b991c37764965a2719e12b6f148bf`. It has not yet received a fresh Build/six-shard run in the observed Actions results. Only G1 lock sync run `44512971214` was visible for this SHA at the poll. Do not treat the previous SHA's results as exact-head acceptance.

### 16.2 Build #44505964469 exact-SHA disposition
- Run `44505964469` checked out `c10fbe3f7ccd5b2aee34bc4f987c4f3276fba878`, not current #3052 HEAD.
- Run conclusion: CANCELLED. Analyze, Visual, all six test shards and Device Smoke were cancelled. Debug, Release and Staging APK jobs completed successfully; staging signature v2/v3, APK_DEBUGGABLE=false, manifest and bundled Vazirmatn checks passed in the fetched logs.
- The Release APK job did not validate a publishable signing certificate: the log reported v2/v3 verification PASS but v1 FAIL and signer-certificate SHA unavailable. The Staging key was ephemeral/test-only. These APK artifacts are not release acceptance.
- Artifacts belong to the old `c10fbe3` SHA. No artifact from that run is evidence for `c7248da` or `8274347`.

### 16.3 Build #11815 / run 44509057409 on SHA c7248da
- Visual job: SUCCESS.
- Analyze: FAILED with four analyzer errors, all caused by the two test files placing imports after declarations (two diagnostics in each file). These two source-order defects were corrected in the subsequent commits above.
- Test shard 3: FAILED, 150 passed / 12 failed. Other shards were not all complete at the time of inspection; test-0 and test-5 were cancelled, while test-1, test-2 and test-4 were still running. Therefore this was not a complete six-shard acceptance.
- APK Debug/Release/Staging jobs were still running at that poll.
- Follow-up File Persistence run `44509057501`: SUCCESS on `c7248da`.
- Calendar Provider Acceptance run `44509057346`: SUCCESS on `c7248da`.
- Device Smoke run `44509057587`: pending; no job list was returned at the poll.
- Draft Review APK run `44509057524`: SUCCESS on `c7248da`; this does not replace the full Build or Device Smoke gates.

### 16.4 Failure inventory from test shard 3 on c7248da
The twelve failed tests are recorded as symptoms, not twelve proven independent root causes:
1. `task_detail_master_screen_test.dart`: ordinary Task detail did not expose key `task-detail-independent-reminders`.
2. `home/home_filter_contract_test.dart`: expected `task-card-details-accordion-real` key was absent.
3. `canonical_home_boundary_test.dart`: compile failure from imports after declarations — corrected in commit `8274347`.
4. `device_feedback_home_regression_test.dart`: expected Home group label «آینده» was not found.
5. `calendar_explicit_export_contract_test.dart`: compile failure from imports after declarations — corrected in commit `fa8774d`.
6. `widgets/home_page_test.dart`: expected `none` key was absent in Move-to-Today flow.
7. `widgets/home_page_test.dart`: expected project label «کار الف» was not found in five-filter responsive test.
8. `widgets/home_page_test.dart`: Past filter test could not find its expected element before ensureVisible.
9. `quick_capture_dialog_test.dart`: expected «یادآور» control was not found.
10. `quick_capture_dialog_test.dart`: expected «تکرار» control was not found.
11. `task_editor_dialog_test.dart`: expected recurrence label «روزانه» was not found although recurrence RollBox key existed.
12. `follow_up_office_page_test.dart`: `pumpAndSettle` timed out in legacy Next Follow-up filter test.
- The remaining ten failures need focused reproduction and code-path inspection. No assertion is to be deleted, relaxed, or rewritten merely to turn CI green.

### 16.5 Related PRs — live metadata
The seven direct feature/design PRs are still OPEN / DRAFT / UNMERGED and target the operational branch using stale base SHA `a2825e003bb9e6b5c2413b0dc74b085273b6148b`:
- #3567 Design System: HEAD `7ba6036dfaa3bc7485413b956500f1272f0fecb3`, mergeable=false.
- #3569 Home/five filters: HEAD `19a657503bd7b1a28576a5a0676a0a48af7ffa34`, mergeable=false.
- #3570 Task/Reminder/Occurrence/Checklist persistence: HEAD `fd4954d773e039cb56ed31806fd2b4790b82d3b5`, mergeable=false.
- #3571 Quick Capture: HEAD `60de06ecb0dae94fdbe3ebc6a4c0d93ce81f156e`, mergeable=false.
- #3572 Task Details: HEAD `be9248d77348421bd044e2480634e804f5782aba`, mergeable=true (metadata only; not acceptance).
- #3573 Vazirmatn: HEAD `6d0dc85ed2ce8bb144c157e39aabd94fe7a049ba`, mergeable=false.
- #3574 Person Directory exclusions: HEAD `8aca2bd36ea28ae8c291e7418541453d12847de2`, mergeable=false.
- Additional stacked dependency #3575 is OPEN / DRAFT / UNMERGED, HEAD `6b1a03f502d5c642ba28a8884186f4a348b0e572`, based on #3574 at `90a8100c0e58fe0b6cedc9e1df3b234adf951b5d`; its portable backup work cannot be promoted independently of #3574.
- No child PR was merged or integrated. Metadata mergeability is not a substitute for fresh exact-head CI or dependency review.

### 16.6 Next execution gates
1. Poll the fresh Actions run for `8274347`; require Analyze and all six shards on that exact SHA. If no Build is automatically created, use an authorized workflow trigger only if available; do not substitute another SHA.
2. Reproduce and fix the ten remaining shard-3 symptoms while preserving assertions; rerun focused tests before full shards.
3. Collect logs for every remaining shard and deduplicate only after matching test names, stack traces and source paths.
4. Reconcile the seven child PRs against the current operational SHA by dependency and overlapping-file review. Keep #3574 → #3575 ordering.
5. Continue backup/restore, TaskStore/SQLite, all-page REV10, Android device smoke, and Local P2P as independent acceptance gates.

**COMMAND 65-R disposition:** two analyzer source-order defects corrected on the authorized operational branch; current SHA `8274347` still lacks exact-head Build and six-shard evidence; ten shard-3 failures remain unresolved; Main protected and unchanged; all related PRs remain unmerged. No release or deploy. RELEASE = NO-GO.


### 16.7 Seven related PRs — Build job and failure-log audit
Build jobs and selected real failure logs were fetched for each related PR head:
- #3567 / run `44505240154`: Analyze SUCCESS; all six test shards FAILED; Debug/Release/Staging APK jobs SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. The fetched test-0 log includes a real combined-filter regression: expected Task ID `a`, actual empty result. It also includes a brittle source-boundary test helper throwing `RangeError(end)` because the searched method boundary was not found.
- #3569 / run `44499411767`: Analyze FAILED on warning `_showHomeFilterMenu` unused at `lib/main.dart:3100`; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING.
- #3570 / run `44499570840`: Analyze SUCCESS; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. Fetched shard-5 failures span Home focus/today, Quick Capture all-day/reminder, Notebook taxonomy, Calendar occurrence routing and Report Center preset sheet.
- #3571 / run `44498710771`: Analyze SUCCESS; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. Fetched test-0 log repeats the combined-filter empty-result regression and source-boundary helper `RangeError` seen on #3567, plus Task/Checklist/People/Quick Capture integration failures.
- #3572 / run `44498204462`: Analyze SUCCESS; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. Fetched test-2 log reports canonical Task due date expected `2026-09-09 10:00` but actual null; Wave 2 editor wiring guard expected five editor paths but found six; source-boundary helper also throws `RangeError`.
- #3573 / run `44494326998`: Analyze SUCCESS; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. Fetched test-2 log repeats due-date loss and editor wiring-count mismatch; additional failures include Quick Capture reminder/date-time, Task Details follow-up/checklist, People relations and persistence migration.
- #3574 / run `44496047708`: Analyze SUCCESS; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. Fetched test-4 log includes Work Agenda PDF expected two events but got one; other failures span Task Details visibility, Task editor all-day deadline, RTL swipe, RollBox, Home/Calendar and About.
- #3575 / run `44495959431`: Analyze FAILED; all six shards FAILED; APK Debug/Release/Staging SUCCESS; Visual SUCCESS; Persistence SUCCESS; Device Smoke PENDING. The fetched Analyze log proves a real contract mismatch: `_RecordingBackupManager.backupCanonicalTasks` omits the newly required `personDirectoryExclusions` named parameter, and `CanonicalBackupCandidate` is instantiated with 9 named arguments where the current contract requires 11. It also reports an unused import and two unnecessary non-null assertions.
- All selected Build logs are from each PR's own head SHA listed in 16.5. They are not evidence for the current operational branch head. The repeated failure signatures across child PRs indicate shared base/API drift and cross-feature regressions; they must be reconciled before integration rather than fixed by blind cherry-picks.

### 16.8 Cross-PR root-cause clusters and current action
- **Confirmed source/test compile defects:** imports after declarations in two operational tests (fixed on #3052 in 16.1); #3575 backup interface/test fixtures not updated for the new exclusion parameter and candidate shape; #3569 unused Home filter method warning causes Analyze failure.
- **Confirmed behavioral regressions requiring repair:** combined Home/report filters return no Task where ID `a` is expected; canonical Task due date is lost in editor/serialization path; Home Wave 2 source-wiring guard is stale at five vs six legitimate full-form paths (the guard needs source review, not automatic assertion removal).
- **Confirmed UI/interaction failures requiring source-level inspection:** missing Task Details independent-reminder/accordion keys, missing Home filter/group/None controls, Quick Capture reminder/recurrence controls not found, Task recurrence label mismatch, and Follow-up office settle timeout.
- **Confirmed PDF/report discrepancy:** Work Agenda PDF projection produces one event where the regression expects two; inspect projection eligibility and grouping before touching renderer assertions.
- **Unresolved until focused reproduction:** multiple Task Details, checklist, people, backup/restore, calendar occurrence, notebook and swipe failures in the remaining shards. Do not label these fixed or root-caused from one representative log.
- No stale child PR branch was modified in this audit. No tests/assertions were weakened. The two operational import-order corrections are the only code edits made in COMMAND 65-R so far; no focused rerun or exact-head CI has yet proven them.



## 17. COMMAND 66-R — live audit checkpoint (2026-11-19)

### 17.1 Exact refs and PR inventory
- PR #3052 re-read from GitHub: OPEN / DRAFT / UNMERGED; head branch `fix/recovery-calendar-device-smoke-2026-10-31`; exact HEAD `b86d402a9928cc7dfa09ce4a22ea14b3866d9fb2`; base `main` at `45e4202b03a434459e4c021a04efa7e8396359db`. No new HEAD was observed during this checkpoint.
- Main latest commit search returned `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR range #3564–#3575: #3564 OPEN/DRAFT (tracker/docs branch, HEAD `8ff372326ead7f853a9092385e37e8362e341f70`, base operational branch at `bc2b3d61...`); #3565, #3566 and #3568 returned GitHub 404 (not assumed merged or deleted); #3567, #3569–#3574 OPEN/DRAFT; #3575 OPEN/DRAFT. No PR in this range is merged.
- Child PRs #3567, #3569, #3570, #3571, #3572, #3573 and #3574 still target the operational branch from stale base `a2825e003bb9e6b5c2413b0dc74b085273b6148b`; #3575 targets #3574 at `90a8100c0e58fe0b6cedc9e1df3b234adf951b5d`. Do not integrate without dependency reconciliation.

### 17.2 Requested workflow runs — exact evidence
All five runs are associated with commit `b86d402a9928cc7dfa09ce4a22ea14b3866d9fb2`:
- Build `44513194318`: started; job inventory now includes APK Release, Debug, Staging; Analyze; six quality shards test-0 through test-5; Visual. At last poll all were in progress or queued; no final conclusion yet. Each created job's exact-revision verification step completed successfully before the toolchain/build steps.
- Device Smoke `44513194257`: job `135523919846` “Prepare selected smoke scenarios” queued; no smoke result yet.
- Follow-up File Persistence `44513194224`: SUCCESS. Real file-backed SQLite test `alarm_overlay_file_persistence_test.dart` passed. Log shows temp SQLite file creation, Task+Reminder+FollowUp save, TaskStore reload, snooze mutation, close/reopen using a second connection, Task readback, actual Complete button interaction, TaskStore completion mutation, notification cancellation, and final readback. This validates that specific scenario only, not all TaskStore, backup/restore, or Task due-date paths.
- Calendar Provider `44513194364`: in progress. Exact-SHA verification completed; provider acceptance instrumentation still running.
- Draft Review APK `44513194389`: in progress. Exact-SHA verification completed; staging APK assembly not yet completed. This uses an ephemeral review signing key and is not a release-signing acceptance.

### 17.3 Correction to the Task Date root-cause diagnosis
- The historical failure from #3572 run `44498204462` / test shard-2 and #3573 run `44494326998` was in `test/task_contract_test.dart`, test “due date stays independent from reminder and follow-up timestamps”.
- Inspection of the exact failing test and the associated patch shows the expected `2026-09-09 10:00` value is the *legacy reminderDate projection*, not the Task dueDate. The failing assertion is `restored.reminderDate == reminder`, while the same test's `restored.dueDate == due` assertion precedes it.
- The old fixture constructs a Task using deprecated Task-level `reminderDate`, then calls `Task.fromJson(task.toJson())`. Current `Task.fromJson` intentionally does not migrate legacy reminder fields; migration is explicitly isolated in `Task.fromLegacyJson`. The test is stale relative to the canonical independent `taskReminders` model.
- PR #3570 changes that fixture to construct a canonical `TaskReminder` and adds assertions for the reminder collection. This is the appropriate compatibility-contract correction; do not change Task due-date serialization to make the old test pass. Preserve separate dueDate, TaskReminder and FollowUp history semantics.
- This is a confirmed test-fixture/API-boundary mismatch, not evidence of a confirmed current product dueDate persistence defect. A separate exact-head file-backed test for dueDate create/edit/save/reopen is still required.

### 17.4 Home and Backup integration findings
- PR #3569 changed `HomeGroupingService` to remove the separate `completed_past` group and include completed past Tasks in `overdue`; tests were also changed to assert the new grouping. This is a behavior change, not just a color/layout adjustment. It requires product-contract review against the approved Home information architecture before adoption. Do not accept solely because its revised tests pass.
- PR #3569 also modifies the five-filter Home row and adds visible Center control; its patch touches `lib/main.dart`, `lib/home/home_filter_ui.dart`, grouping service and multiple Home tests. The branch also had an Analyze failure in its own run from unused `_showHomeFilterMenu`.
- Current #3052 `lib/backup_manager.dart` does not yet contain `personDirectoryExclusions` in `backupCanonicalTasks`, the backup document, or `CanonicalBackupCandidate`.
- PR #3575 supplies the exclusion serialization/decode/reconciliation API and adds file-backed backup/restore tests, but it depends on PR #3574's schema migration and TaskStore exclusion persistence. Preserve #3574 → #3575 order. Do not copy only the backup-manager signature or fake fixtures; review full migration, transactional persistence, rollback and restore orchestration together.
- PR #3570 changes tests and schema handling, but does not modify the canonical Task model or TaskStore due-date code. Its changed tests include a real file-backed migration/reopen test preserving a future extension column; this is a useful preservation contract but is not yet integrated into #3052.

### 17.5 Current acceptance and next actions
- The only newly completed acceptance gate among the five requested runs is Follow-up File Persistence on exact SHA `b86d402...`.
- Analyze, six shards, Visual, APKs, Device Smoke and Calendar Provider have not yet returned final results at the last poll. No claim of six-shard success or release readiness is allowed.
- Continue polling Build `44513194318`, Device Smoke `44513194257`, Calendar `44513194364` and review APK `44513194389`; fetch logs for every failed shard before deduplication.
- Reproduce the Home filter combined logic against canonical Center/Project/Category/Tag data. Inspect the actual source predicate and ensure semantics remain explicit; do not simply alter expected IDs.
- For Backup/Restore, reconcile #3574 migration + TaskStore changes and #3575 manager + UI orchestration as one dependency chain, then run a real independent-database restore and compare Task IDs, relation IDs, tombstones, NULL and unknown envelope fields.
- For Task dates, add/retain a file-backed exact test proving dueDate survives Task creation, editor save, SQLite close/reopen and TaskStore readback while reminders and Follow-up history remain distinct.
- No code fix was made in this checkpoint because the reviewed child-branch patches are not yet safely reconciled with the current operational HEAD. No assertions were removed or weakened. Main unchanged; no merge, release or deploy.

**COMMAND 66-R checkpoint disposition:** exact operational SHA remains `b86d402...`; one focused file-backed SQLite/TaskStore alarm-overlay persistence scenario passed on that SHA; remaining requested workflows are still running/queued; legacy reminder test mismatch has been distinguished from Task dueDate; Home grouping and Backup dependencies require controlled reconciliation. RELEASE = NO-GO.


## 18. COMMAND 66-R — six-shard inventory, fixture corrections and backup integration audit

### 18.1 Complete six-shard evidence from PR #3570
- Run: `44499570840`; source PR head SHA: `fd4954d773e039cb56ed31806fd2b4790b82d3b5`.
- Analyze SUCCESS; Visual SUCCESS; APK Debug/Release/Staging SUCCESS.
- Shard failures: test-0=12, test-1=4, test-2=23, test-3=10, test-4=9, test-5=6.
- Total failed test instances=64; unique test names=64; exact duplicate test names across shards=0.
- Full per-shard test-name inventory and initial evidence classification: `docs/history/command-66-r/COMMAND-66-R-SHARD-FAILURE-INVENTORY.md`.
- These 64 failures are from the PR #3570 head, not current #3052. They are not all one product defect. UI finder/hit-test issues, asynchronous settling, data contracts, schema envelopes, navigation, Home grouping and Report filter fixtures must be triaged independently.
- Three observed Follow-up Office `pumpAndSettle` timeouts are separate from data persistence failures. The `canonical_home_boundary_test.dart` `RangeError(end)` is a source-boundary test-helper failure where a searched marker was not found. The Wave 2 editor wiring guard reports 5 expected vs 6 actual paths; review the sixth path before changing the guard.

### 18.2 Corrected test-fixture root causes
- Legacy reminder compatibility tests on old child branches used Task-level deprecated `reminderDate` but asserted it survives `Task.fromJson(task.toJson())`. Current architecture keeps that legacy import at `Task.fromLegacyJson`; canonical Task serialization uses `taskReminders`. PR #3570 updates the fixtures to canonical `TaskReminder` entries. Do not restore a synthetic Task-level reminder field or merge reminder and due-date semantics.
- The editor due-date test in the old Vazirmatn branch likewise used deprecated `reminderDate` in the Task constructor. The expected null reminder projection is consistent with the canonical editor; the fixture must construct a `TaskReminder`. PR #3570 already carries that fixture correction.
- The Report combined-filter failure was `test/services/task_report_filter_test.dart`, not Home filter logic. Its Follow-up record was at 09:00 while the selected record-time range was 14:00–17:00. The operational fixture now uses 15:00, preserving the original AND assertion and expected Task ID `a`.
- No assertion was deleted or relaxed for these corrections.

### 18.3 Operational code/test commits since checkpoint 17
- File-backed Task due-date regression test added to `test/task_store_reminder_persistence_test.dart`:
  - Commit `1209af784ae7701b617b9f1cbe6237e5d648f9b8`.
  - Covers timed dueDate, independent TaskReminder, FollowUp history, SQLite file close/reopen and exact identity/date readback.
- Report filter fixture corrected:
  - Commit `46d8af4f29260ead3a7a3bfadb91673002c55309`.
  - Follow-up timestamp changed 09:00 → 15:00 within the existing 14:00–17:00 window; expected result and assertions unchanged.
- Six-shard inventory document added:
  - Commit `e19927a27a1d481796dce44fe21fda8d31b3150c`.
- Current PR #3052 HEAD at the time of this update: `e19927a27a1d481796dce44fe21fda8d31b3150c`. The latest code-bearing SHA is `46d8af4f29260ead3a7a3bfadb91673002c55309`; the subsequent `e19927a` commit only adds the failure-inventory document.

### 18.4 Exact-head acceptance for code SHA 46d8af4
- Build `44514323956`: PENDING, no jobs returned at the last poll. No Analyze or six-shard result yet.
- Device Smoke `44514323986`: PENDING, no jobs returned.
- Follow-up File Persistence `44514323993`: SUCCESS. Its log explicitly ran only `test/alarm_overlay_file_persistence_test.dart` and passed the SQLite close/reopen snooze+completion scenario. It did **not** run the newly added timed due-date test.
- Calendar Provider `44514324115`: IN_PROGRESS; exact target SHA verification passed; provider acceptance still running.
- Draft Review APK `44514324131`: IN_PROGRESS at last poll; this is review/staging-only and not release signing acceptance.
- Earlier Build `44513194318` on `b86d402` had quality Analyze, five shards and Visual cancelled while test-3 and APK jobs were still active. It is not a completed six-shard run. Earlier Build `44514100889` on `1209af7` was also cancelled. Do not count either as pass or failure of product assertions.
- The current code SHA `46d8af4` therefore has one focused file-backed alarm persistence success, but the new due-date test, Analyze, six shards and Device Smoke remain unproven.

### 18.5 Backup/Restore root integration gap
- PR #3574 adds the durable exclusion tombstone migration and TaskStore semantics; PR #3575 extends the backup candidate, backup document, validation, reconciliation and a new BackupPage flow. Their intended dependency remains #3574 → #3575.
- Current operational `lib/main.dart` has an active `_backupToFolder` / `_restoreFromFile` flow. It still calls `backupCanonicalTasks` without `personDirectoryExclusions`, does not snapshot previous exclusions, and restores only `peopleDirectory` via `reconcilePeopleById` / `savePeopleDirectory`.
- The #3575 patch updates `lib/backup_page.dart`, but the current `main.dart` operational flow independently owns the backup/restore handlers and was not updated by #3575. Thus even if the child PRs are combined, this active main path would still omit tombstones unless explicitly wired.
- Current #3052 `TaskStore` also has no `loadPersonDirectoryExclusions` / `replacePersonDirectoryExclusions` methods and current G1 schema does not create the tombstone table. The #3575 child TaskStore/schema files are based on an older base and must not replace current files wholesale: the child schema is missing current `_migrateLegacyTaskReminderFlag` logic. Port only the reviewed additive migration and TaskStore changes while preserving the current migration.
- This is a confirmed product integration gap, not yet corrected in this checkpoint. No partial backup API signature was copied into the active path. Next safe implementation must port model + migration + TaskStore in dependency order, then backup manager + active main backup/restore + rollback, with file-backed source/independent-target database tests for Task IDs, Person IDs, Task/Follow-up relations, tombstones, NULL and unknown fields.

### 18.6 Home filter and grouping disposition
- Current #3052 Home predicate applies sequential filters (AND across Center/Category/Project/Tags) and any selected member within the multi-select dimension (OR within that dimension). Center uses canonical Task.centerId first and falls back to linked Project.centerId for legacy Tasks.
- The observed combined-filter failure in the six-shard PR #3570 run is a Report Center Follow-up record-time fixture mismatch, not proof that the Home predicate is wrong. The Home boolean logic test separately failed to find its expected Task in the PR #3570 widget test; its UI/data setup still requires focused reproduction.
- PR #3569 changes completed-past group behavior by merging it into overdue. This is a user-visible product behavior change. Keep current separate completed-past grouping until an owner-approved contract says otherwise; do not accept the child PR's revised expectation as a test-only cleanup.

**COMMAND 66-R disposition:** two assertion-preserving test-fixture/persistence test changes committed; 64 failures across six shards inventoried from PR #3570; one exact-head file-backed alarm persistence workflow passed on code SHA `46d8af4`; current Build/Device Smoke pending and Calendar/Review APK in progress; Backup/Restore active-main integration gap confirmed and not yet fixed; no merge, release or deploy. RELEASE = NO-GO.
