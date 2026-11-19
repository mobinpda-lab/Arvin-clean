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
- PR #3567 establishes Persian Teal (#0F766E) tokens. The older decision register contains competing historical palette entries. Its colors must be checked against the actual REV10 authority before acceptance; no color decision is inferred from an older note.
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
