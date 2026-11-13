# REV9 — CURRENT LIVE STATE / REPOSITORY CLEANUP WAVE 0
**Live baseline date:** 2026-11-10
**Main HEAD:** `45e4202b03a434459e4c021a04efa7e8396359db`
**Documentation branch:** `docs/rev9-governance-continuity-2026-11-10`
**PR #3340:** OPEN / READY FOR REVIEW / UNMERGED; HEAD before this update `fe85e64199cfdb468228830ecfff3bcf3d8bea5c`
**Protected PR #3052:** OPEN / DRAFT / UNMERGED; HEAD `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`
**Repository inventory:** 1,413 branches; 35 duplicate-head groups / 109 refs; 101 open PRs; 75 drafts; 99 open PRs last updated before 2026-11-01.
**PR #3340 baseline diff:** 66 Markdown/agent-instruction files; zero non-documentation files.
**Product direction:** LOCAL-FIRST standalone; local SQL is the sole durable source of truth; all multi-device sync is SUSPENDED pending separate explicit authorization.
**Active cleanup sequence:** WAVE 0 Live Repository Baseline → WAVE 1 Git History Forensic Audit → WAVE 2 Test Governance & CI Audit → WAVE 3 Architecture & Documentation Audit → WAVE 4 Safe Cleanup & Consolidation.
**Current authorization:** documentation-only on PR #3340's existing branch. Main, PR #3052, source, schema, migration, tests, workflows, features, branch/PR deletion, merge and release are protected.
**Baseline report:** [REPOSITORY_CLEANUP_WAVE0_BASELINE.md](audit/REPOSITORY_CLEANUP_WAVE0_BASELINE.md)
**Release:** BLOCKED — RELEASE: NO-GO.

> The REV8 snapshots below are preserved historical evidence. Their SHAs, counts, workflow IDs and status labels are not current unless reverified against live GitHub.

---

## REV8 post-audit exact-head refresh — 2026-11-10 11:10 UTC

- Main: `45e4202b03a434459e4c021a04efa7e8396359db`; protected=true.
- Working branch / PR #3052 HEAD: `a934cabebc814aea13c1800ab151821d12714226`; parent `9846f10850031c63964fdc81ae0ab1cdb3028517`.
- PR #3052: OPEN / DRAFT / UNMERGED; 2,131 ahead / 0 behind; 380 changed files; 0 reviews.
- Build `42801502260`: FAILURE; six shards 1,296 passed / 78 failed. Shards: 0=299/25, 1=194/6, 2=184/10, 3=148/12, 4=231/14, 5=240/11.
- Device Smoke `42801502310`: PENDING. Calendar Provider `42801502275`: SUCCESS. Follow-up Persistence `42801502256`: SUCCESS. Draft Review APK `42801502270`: SUCCESS.
- Tree: 953 entries; 302 Dart test files (293 test/, 9 integration_test/); 25 workflows; docs/ 271 files (266 Markdown); project-continuity 45 files.
- NIRA Main: `7a27ee63b65d343e45c5786f782f2567611722dc`; latest Queue Scheduler `42803607805` FAILED while reporting to issue #162 (HTTP 403; >2,500 comments). L10 remains UNVERIFIED.
- Earlier 9846-based snapshots below are historical. Release: BLOCKED — RELEASE: NO-GO.

---

## REV8 live checkpoint — 2026-11-10

Repository: mobinpda-lab/Arvin-clean
Main HEAD / PR base: 45e4202b03a434459e4c021a04efa7e8396359db (Main READ-ONLY).
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31.
Working HEAD / PR #3052 head before this documentation commit: 9846f10850031c63964fdc81ae0ab1cdb3028517.
PR #3052: OPEN / DRAFT / UNMERGED; 2,130 ahead / 0 behind; 368 changed files; 0 review submissions; 51 issue comments.
Repository inventory: 1,412 branches; 1,238 PRs (100 open, 1,138 closed); 1,812 Main commits; 302 Arvin test files; 25 working-branch workflows; 259 docs files.
Current Build 42795405617: FAILURE; six shards: 1,296 passed / 78 distinct failed labels. Analyze, Visual, Debug APK, Release APK and Staging APK succeeded.
Calendar Provider 42795405362: SUCCESS. Follow-up Persistence 42795405561: SUCCESS. Device Smoke 42795405388: PENDING; no device acceptance claim.
NIRA: 112 branches, 7 open PRs, 381 closed PRs, 132 Main commits, 26 workflows, 23 factory tests; L10 UNVERIFIED. Queue Scheduler run 42777810609 failed while commenting on issue #162 (>2,500 comments).
Release: BLOCKED — RELEASE: NO-GO.
GitHub API does not expose local working-tree state or physical device state; both remain NOT VERIFIED.

---

## Historical REV7.2 checkpoint — SHA b789 (preserved)

# CURRENT STATE — REV8 live checkpoint

Last audited: 2026-11-10



## REV7.2 live checkpoint — 2026-11-10

- Repository: mobinpda-lab/Arvin-clean
- Branch: fix/recovery-calendar-device-smoke-2026-10-31
- Exact source SHA: b789343c9699ca440d043d71d47db3dcdfafa57c
- Main/base SHA: 45e4202b03a434459e4c021a04efa7e8396359db
- PR #3052: OPEN / DRAFT / UNMERGED; base main; head matches this branch.
- Compare: 2,129 commits ahead, 0 behind. Existing PR diff: 367 files, including 61 docs files and 32 docs/project-continuity files. These are pre-existing PR changes, not this governance commit.
- Source of Truth: live GitHub Repository, exact branch HEAD, code/schema/migrations/tests/workflows and exact-SHA Actions evidence. Historical Source ZIP is archive-only and is not a prerequisite. Do not request or wait for it.
- Main remains read-only. No executable code, test, schema, migration, workflow, security configuration, PR metadata, merge or release changes are authorized by this checkpoint.
- GitHub cannot reveal the operator's local working tree; local clean/dirty status is NOT VERIFIED.
- Main protection ruleset main-protection is active. It blocks deletion and non-fast-forward updates and requires PR-based changes. The ruleset permits zero required approvals; this is not evidence of owner acceptance for release.
- Canonical master governance is docs/project-continuity/MASTER_GOVERNANCE.md. No MASTER_CHARTER.md exists at the checked canonical path; no legacy charter content was available to migrate.

### Exact-SHA CI checkpoint

- Build run 42763952581 on this SHA: FAILURE. Analyze PASS; Visual structural smoke PASS; Debug APK PASS; Release APK build PASS; Staging APK build/signature/manifest/font audit PASS; all six test shards FAIL.
- Shard 0: 231 passed / 14 failed. Shard 1: 195 / 5. Shard 2: 299 / 25. Shard 3: 148 / 12. Shard 4: 240 / 11. Shard 5: 182 / 12. Total: 1,295 passed / 79 failed.
- Follow-up File Persistence run 42763952346: SUCCESS on this SHA.
- Calendar Provider Acceptance run 42763952813: SUCCESS on this SHA; the run executed the Android Provider instrumentation acceptance path.
- Device Smoke run 42763952498: incomplete at last poll (updated 2026-11-10T09:17:55Z). Preparation PASS; Boot IN_PROGRESS; Navigation, Quick Capture, Follow-up Persistence, Reminder/Vazirmatn, Task Lifecycle and Calendar Segmented View QUEUED. No seven-lane completion claim and no physical-device acceptance claim.
- Other orchestration runs may be green, but they do not override the failed exact-head Build or incomplete Device Smoke.
- Release remains BLOCKED — RELEASE: NO-GO.


## Product architecture checkpoint

- Task, TaskReminder and historical Follow-up are distinct in Task model and Drift tables. TaskReminder does not define the required four-state lifecycle.
- G1DriftSchema schemaVersion is 16. TaskStore uses the shared Drift executor and transaction-based persistence. Migration code copies legacy Follow-up records/people before dropping legacy tables; no real user DB or backup was inspected.
- Recurrence repository stores occurrence history and per-occurrence checklist states. A new occurrence starts with unchecked checklist definitions.
- Shared filters support single/multi select, inline creation and auto-selection, selection count and 48dp list controls. Full global order/responsive acceptance is incomplete.
- Home time grouping uses Task.dueDate and includes overdue/today/tomorrow/future/no-date plus a separate completed-past group. Sort service has helper methods; the complete approved user-facing sort menu is not proven.
- Notebook uses canonical Task identity and soft trash/restore. Hard deletion/unlink preservation and auto-title on first save remain unverified.
- Task Templates share G1 Drift; they store definitions but not Task dueDate. Current instantiation restores reminder date/time, category/tags/priority/checklist/people/recurrence but does not assign Center/Project membership in the reviewed path.
- Calendar Provider workflow passed on exact SHA; physical device and all internal/external/prayer/tafweez acceptance remains incomplete.
- Report/PDF source exists; report-related tests fail in current Build shards.
- NIRA L10 remains UNVERIFIED.

## Exact-SHA status matrix

See MASTER_GOVERNANCE.md §9 for the complete three-axis matrix and file/test evidence. All product claims remain evidence-bound; no feature is VERIFIED solely because its class or file exists.
- Follow-up compact pass commit message: `ui(quick-capture): compact vertical padding and tighter icon/chip sizing matching reference layout`.
## Quick Capture tighter visual compression — 2026-11-04
- Follow-up UI-only pass on the existing compact Quick Capture form. No field order, row membership, widget keys, horizontal selector structure, selected values, priority enum, color palette, Vazirmatn font family, semantics, callbacks, validation, task construction or persistence behavior was changed.
- Compact ArvinRollBox and ArvinTagRollBox controls reduced from 42dp to 40dp; compact icons reduced from 18dp to 16dp, icon/text gap from 6dp to 4dp, horizontal inset from 10dp to 8dp, compact label size from 11.5sp to 10.5sp. The 40dp minimum touch target is retained.
- Quick Capture cards reduced from 8dp to 6dp padding; top/bottom sheet padding tightened; title/header and description TextFields use dense decoration and reduced vertical content padding; inter-card/row gaps and horizontal gaps tightened without changing order.
- Four priority controls remain 40dp with the same Persian labels, explanatory helper row, colors and selected enum values. Footer actions remain at least 40dp and aligned in their existing row.
- Inner vertical scrolling remains as a safety fallback for keyboard, short screens and text scaling. A claim of zero vertical scrolling on every device is not made until verified on the physical SM-A528B/DS.
- Updated geometry test from 42dp to 40dp; no test/assertion removed, weakened, skipped or bypassed. Fresh exact-SHA CI is required.
- Physical before/after screenshot: NOT VERIFIED in this environment.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; BLOCKED — RELEASE: NO-GO.

- Required implementation commit message: `ui(quick-capture): compact single-screen layout, no logic changes`.
## Quick Capture priority helper row refinement — 2026-11-04
- Four canonical priority chips now show only «اولویت ۱» through «اولویت ۴» in 40dp-high controls; the four existing explanatory labels appear in a separate compact helper-text row immediately below.
- Existing priority enum values, ordering, selected-state animation, color mapping, tap callbacks and Semantics labels (including the explanatory text) remain unchanged.
- This refinement supersedes the in-flight CI started on prior SHA `d83683e47c0d3f6c3ca3fdf10504bc93aebd39d0`; its results are not acceptance evidence for the final SHA.

- Requested commit-message checkpoint: `ui(quick-capture): compact single-screen layout, no logic changes`.
## Quick Capture compact layout — 2026-11-04
- Scope: UI/layout only. Current form field inventory, order, keys and selection flow are preserved. No Task model, validation, draft-building, persistence, field names, callbacks, center/project relationship, reminder synchronization, recurrence mapping or priority values were changed.
- The existing description TextField remains present (compressed from 2–3 visible lines to 1–2); title placeholder remains «عنوان کار را وارد کنید». Header title and full-form shortcut remain.
- Existing two horizontally scrollable selector groups remain in their current order so every selector remains reachable on narrow screens: center/project/category/tag, then due date/reminder/recurrence. No selector was removed or hidden; horizontal scrolling remains intentionally available for narrow widths.
- Added opt-in compact presentation to `ArvinRollBox` and `ArvinTagRollBox`: 42dp control height, 18dp icons, 6dp icon/text spacing, 10dp horizontal inset, compact Vazirmatn-inherited labels with ellipsis. Existing popup menu items and callbacks are unchanged.
- Priority remains the same four `TaskPriority.values` with Persian labels and helper descriptions, existing color mapping, Semantics labels and selected state; only chip/card vertical padding, font sizing and line height were compressed. No P1–P4 codes introduced.
- Reduced card padding/vertical gaps, compacted title/header/description, and aligned «ثبت کار» + «لغو» in a 44dp-height footer row. Touch targets are asserted >=40dp.
- Bottom sheet remains `isScrollControlled: true`, now capped at 66% of screen height. The inner vertical scroll view remains as a fallback for smaller screens, keyboard display and accessibility text scaling; the intended 7-inch view is tested for compact geometry rather than claiming physical-device proof.
- Added/updated widget assertions for 42dp selectors, 40dp minimum actions, same-row footer, all existing selector keys, four priorities and preserved description. No tests/assertions were removed, skipped, softened or timed out.
- Physical before/after screenshots from Samsung SM-A528B/DS are NOT VERIFIED / not captured by this GitHub-only execution environment.
- Fresh CI must run against the final documentation-synchronized SHA. No previous SHA's result transfers.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.

## Task Details UI — final verification checkpoint update — 2026-11-04
- Final focused test adjustment: bottom completion action assertion now checks canonical `ArvinColors.primary` (`#4A4CAB`), not the darker AppBar shade. Commit: `b511d51d172a57656fdae12dd15ed559a27fcfb7`.
- The Task Details redesign remains limited to `lib/task_detail_page.dart`, `test/task_detail_master_screen_test.dart`, and these three continuity documents. No Task model, repository, DAO, persistence, alarm, calendar, or backend source was modified.
- The exact current branch HEAD must be read after this documentation sync. No workflow result is currently verified for the new Task Details implementation SHA; do not infer CI success from earlier runs.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.

## Task Details UI redesign — 2026-11-04
- Owner-approved presentation-only scope applied on the authorized PR branch. Source commit: `a654da9262004b57fab591fcd2a72e48481e57f7`; checklist presentation commit: `dc6e2aa6a3af26f474b9b02c1ccb24742228208b`; focused test commits: `43813096e93abd31388e1eceeb8dfef3fb3d4aba`, `86c6c9bbaaa8bc83626effb9aa52f6e52c94a3d0`.
- UI: icy `#F5F6FA` page background; dark indigo AppBar with rounded lower corners, Vazirmatn title and left-side back action; white 16px rounded cards with soft shadow; existing title/status/priority card retained; metadata, template, due-date, independent reminder, recurrence and checklist cards remain.
- Checklist retains its existing fractional progress and LinearProgressIndicator; the add control is now a full-width «افزودن مرحله جدید» action after the checklist items, using the same existing add callback and text controller.
- The entire «افراد مرتبط» display block is removed from Task Details. No `Task.people` model/data/storage logic was changed; the regression test confirms person data remains on the Task while no person UI is rendered.
- Bottom actions retain their original keys and callbacks: red outlined Delete, indigo filled Complete, indigo outlined Edit.
- Test file `test/task_detail_master_screen_test.dart` now asserts absence of people UI, retained underlying person data, page/card styling, back action, bottom-action colors, checklist progress and add-stage label. No test was deleted, skipped or weakened.
- Current source/test implementation HEAD before continuity sync: `86c6c9bbaaa8bc83626effb9aa52f6e52c94a3d0`. CI on this new SHA has not yet been verified; all acceptance gates are NOT VERIFIED until fresh exact-SHA runs finish.
- PR #3052 remains OPEN / DRAFT / UNMERGED. No main edits, merge, publication or release. **BLOCKED — RELEASE: NO-GO.**

## Quick Capture test reconciliation — 2026-11-04
- Build run `41834832972` on SHA `2549a98ab6d3de3498ab17fc007debf34f105055`: Analyze PASS; Shard test-1 FAILED with 174 passed / 1 failed.
- Exact failure: `test/quick_capture_dialog_test.dart:321`, test `canonical capture keeps title-only path and optional choices`; the old assertion expected the approved description field to be absent. A second obsolete absence assertion existed in the full-form handoff test.
- Updated both finders to assert the description field exists and added empty-description assertions for title-only / no-description handoff. No test was deleted, skipped, timed out or weakened; the assertion now checks the newly approved UI contract.
- Test correction commit: `fdbb6f10bb2fed4233384478c74c86c9778def90`. All workflows on SHA 2549 remain evidence only for that older SHA; the correction requires a fresh exact-SHA run.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## Quick Capture implementation refinement — 2026-11-04
- Latest source/test checkpoint before this continuity refresh: `2349dc2cdffeae440e525a89842912d681123b26`.
- Focused test commits: `15212f6f5151c8436f041021d96ca7042bcf0015` (ensure-visible interaction and full-width submit geometry) and `2349dc2cdffeae440e525a89842912d681123b26` (remove obsolete test import).
- Live PR metadata at this checkpoint: OPEN / DRAFT / UNMERGED; branch HEAD equals the checkpoint SHA.
- GitHub Actions query for this SHA returned zero workflow runs; commit status is pending with zero contexts. CI is NOT VERIFIED and must not be reported as passing.
- Keep release BLOCKED — RELEASE: NO-GO.

## Quick Capture UI — owner-approved redesign (2026-11-04)
- Owner decision APPROVED: UI-only redesign of QuickCaptureDialog; retain all four canonical TaskPriority values and exact enum persistence (high/medium/low/none; sort orders 1–4). No priority remapping.
- Source checkpoint before continuity updates: `9aaa51dea8957a8f755e57f6d9bb05724a6f00f1`; changes in `lib/quick_capture_dialog.dart` and focused tests in `test/quick_capture_dialog_test.dart`.
- UI implementation adds an icy `#F5F6FA` canvas, indigo header with close/full-form actions, white rounded cards, title and description fields, RTL pastel four-level priority chips with the exact four Persian labels and helper text, and full-width submit action. Existing center/project/category/tag, due date, reminder and recurrence controls remain connected through their existing callbacks/services.
- Description now binds to canonical `Task.description`; it is cleared only after successful capture/full-form handoff. Title validation and capture callbacks remain unchanged.
- Focused test updates preserve priority-value assertions, add exact helper-label / no-English-P-code assertions and description persistence coverage, and update the compact-form description expectation. No test was deleted, skipped or weakened.
- Runtime and focused tests are IMPLEMENTED; Analyze, widget tests, full Build, Device Smoke and other exact-SHA gates remain NOT VERIFIED until CI completes on the final documentation-synchronized SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.

## Quick Capture UI — owner-approved redesign (2026-11-04)
- Owner decision APPROVED: UI-only redesign of QuickCaptureDialog; retain all four canonical TaskPriority values and exact enum persistence (high/medium/low/none; sort orders 1–4). No priority remapping.
- Source checkpoint before continuity updates: `9aaa51dea8957a8f755e57f6d9bb05724a6f00f1`; changes in `lib/quick_capture_dialog.dart` and focused tests in `test/quick_capture_dialog_test.dart`.
- UI implementation adds an icy `#F5F6FA` canvas, indigo header with close/full-form actions, white rounded cards, title and description fields, RTL pastel four-level priority chips with the exact four Persian labels and helper text, and full-width submit action. Existing center/project/category/tag, due date, reminder and recurrence controls remain connected through their existing callbacks/services.
- Description now binds to canonical `Task.description`; it is cleared only after successful capture/full-form handoff. Title validation and capture callbacks remain unchanged.
- Focused test updates preserve priority-value assertions, add exact helper-label / no-English-P-code assertions and description persistence coverage, and update the compact-form description expectation. No test was deleted, skipped or weakened.
- Runtime and focused tests are IMPLEMENTED; Analyze, widget tests, full Build, Device Smoke and other exact-SHA gates remain NOT VERIFIED until CI completes on the final documentation-synchronized SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.

# Current Verified State
Checkpoint: 1405/08/13 — 2026-11-04
Repository: mobinpda-lab/Arvin-clean
Branch: fix/recovery-calendar-device-smoke-2026-10-31
Exact audited HEAD: 940b22f4dc30aef083e5116843ac9457bd1bd37a
PR: #3052 — OPEN / DRAFT / UNMERGED
Base main SHA: 45e4202b03a434459e4c021a04efa7e8396359db
Release: BLOCKED — RELEASE: NO-GO

## Task Details UI audit
- Revalidated source on exact HEAD 940b22f4dc30aef083e5116843ac9457bd1bd37a. No runtime UI change was made because photo_1793790367954.webp and photo_1793790413647.webp are not accessible as current conversation or Library files in this execution.
- Findings and exact file/blob evidence: docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md.
- TaskDetailPage: lib/task_detail_page.dart (blob 269a48aee948d00ab453d1d4e82b2b9e2510d4b9); route _openTaskDetail in lib/main.dart (blob 97e2f872e69b24dd47ffe936e921c8001ace9388); model lib/models/task.dart (blob d5ba37c5bdac479b5c3381fea30f5ea510b64d51).
- Current model has people but no assignee field; do not infer responsibility from related people.
- Code confirms repeated due date, priority, category/tags across sections. No metadata was removed without reference image/product approval.
- Description multiline editing, canonical save callbacks, independent TaskReminders, recurrence, Follow-up history, clone, calendar action and fixed bottom actions remain intact.
- Official bundled font: Vazirmatn only.

## Exact-SHA CI — 940b22f4dc30aef083e5116843ac9457bd1bd37a
- Build run 41819344155 SUCCESS: Analyze + six test shards SUCCESS; APK matrix SKIPPED by Draft guard.
- Focused Task Details cases logged PASS: inline title/multiline description, independent reminder toggle, clone, smart visibility, due-date action, checklist, Follow-up, calendar export and report entry. RTL/Vazirmatn contracts logged PASS. No dedicated Task Details screenshot/golden evidence found.
- Follow-up persistence run 41819344361 SUCCESS.
- Draft Review APK run 41819344101 SUCCESS; artifact 13316861010; SHA-256 12a51684cf661bb8dd318b97694f1b6bb5b1b47cae63e12fb71fef40bea0ef08; review/staging only.
- Calendar Provider run 41819344729 IN_PROGRESS at last poll.
- Device Smoke run 41819344258: Boot/Navigation SUCCESS; Quick Capture/Calendar Segmented View IN_PROGRESS; Reminder/Vazirmatn, Follow-up Persistence and Task Lifecycle QUEUED. Seven-lane acceptance NOT VERIFIED.

## Governance
- No main write, merge or release. PR #3052 remains OPEN / DRAFT / UNMERGED.
- No tests/assertions were deleted, weakened, skipped or bypassed.
- Full audit: docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md.
- Backlog: docs/project-continuity/OPEN_ISSUES.md and ROADMAP.md.


## Task Details UI implementation — 2026-11-04
- Implementation checkpoint: d7ae03c8cc74e9f38c739cd84dba77606acc56ff (code/test checkpoint; subsequent documentation checkpoint will be audited independently).
- Runtime changes are limited to lib/task_detail_page.dart; focused layout/RTL tests are in test/task_detail_master_screen_test.dart.
- Pixel comparison and actual-page screenshot acceptance remain NOT VERIFIED. The owner-provided desired image is available; the installed-app image is not available as an executable attachment.
- Build, Device Smoke, Calendar Provider, Follow-up Persistence and review APK are triggered/pending/in progress at this checkpoint. No PASS is claimed until terminal results are checked on the exact final SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release NO-GO.


## 2026-11-04 — Exact-SHA CI failure and review APK evidence (a85145de7be4b0d23854e320885f665d50eb35cc)
- Build run 41823721080: FAILURE. Analyze failed at lib/task_detail_page.dart:1158:30 with unnecessary_string_interpolations. APK matrix was SKIPPED by the Draft guard.
- Test shards: test-4 SUCCESS; test-0, test-1, test-2, test-3 and test-5 FAILURE. Do not report the suite as passing.
- Task Details evidence from task_detail_master_screen_test.dart: PASS — clone action invokes canonical handler; title and multiline description save inline; summary/metadata/due date appear once in RTL order; related people are not presented as assignees and bottom content remains clear.
- Task Details failures: independent Reminder toggle could not find key task-detail-reminder-reminder-toggle-1 (line 83); ordinary-task smart visibility could not find task-detail-add-reminder (line 110); rich-section visibility could not find task-detail-independent-reminders (line 163). Related checklist failures: task_detail_checklist_flow_test could not find task-detail-checklist (line 29), and task_detail_checklist_crud_test could not find task-detail-add-checklist (line 72). These are real assertion/finder failures, not skipped tests.
- Related Task Details flow failures: add Follow-up key task-detail-add-followup absent (task_detail_followup_flow_test lines 58 and 193); existing FollowUp edit path raised StateError: No element in ensureVisible at line 252; Today action vertical-order assertion expected >520.5 but observed 478.0 (line 403; same 478.0 vs >520.5 in task_detail_due_date_action_test line 62).
- Calendar Provider run 41823721063: SUCCESS; artifact 13318164013.
- Draft Review APK run 41823721031: SUCCESS; artifact 13317704369, 38,206,200 bytes ZIP. Extracted review APK: 76,806,159 bytes, SHA-256 f3f3efdf74bff2b239f24145c69bbd98fbcf2ac0e2f3bb043e70c6f8d9dcea57. Manifest: applicationId com.example.arvin.staging, android_debuggable=false, v2/v3 signature verified, ephemeral test-only signing key, publishable=false, release_created=false. Review/install testing only; not a production/release APK.
- Device Smoke run 41823721013: still incomplete at last poll. Boot, Navigation, Quick Capture and Task Lifecycle SUCCESS; Reminder/Vazirmatn and Calendar Segmented View IN_PROGRESS; Follow-up Persistence QUEUED. No seven-lane PASS.
- No tests/assertions were modified, removed, weakened, skipped or bypassed during this audit. No timeout workaround was applied. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## Quick Capture compact layout — compile correction and live CI checkpoint (2026-11-04)
- Previous PR HEAD `c918f2bb8ce73ffa82dd601ab30eb077b9d49fa4`; PR #3052 was OPEN / DRAFT / UNMERGED.
- Build run `41842459267` on that exact SHA failed during Staging APK compilation: `ArvinTagRollBox` constructor accepted `compact` and its build method read `widget.compact`, but the widget class did not declare the corresponding field. This is a source compile error, not an APK signing or CI runner issue.
- Corrected by adding `final bool compact;` to `ArvinTagRollBox` in commit `642a4016cbaa1994b4dfe2d278066941ef8a65c2`. No behavior/data/test assertion was changed by this correction.
- The compact Quick Capture layout already reduces selector height to 40dp, horizontal padding to 8dp, icons to 16dp and label text to 10.5sp; tag selector uses the same compact contract. The main dialog uses tighter card/field spacing and 40dp priority chips. Existing vertical scroll remains as a safe fallback for short screens, keyboard and text scaling; fit-without-scroll on physical hardware is NOT VERIFIED.
- Exact-head Build, Device Smoke, Calendar Provider, Follow-up Persistence and Draft Review APK must be checked again on the final documentation-synchronized SHA. Prior results do not transfer.
- On pre-fix SHA `c918f2b`, Follow-up File Persistence run `41842459045` SUCCESS; Device Smoke `41842458990` was still running; Calendar Provider `41842459090` was in progress; Draft Review APK `41842459134` failed because the same missing `compact` property prevented Staging assembly. No all-green claim.
- The user-referenced image `photo_1793800214435.webp` was not available for pixel-level inspection in this execution. Pixel-perfect matching and physical-device screenshot acceptance remain NOT VERIFIED.
- No tests were deleted, skipped, weakened or bypassed. PR #3052 remains OPEN / DRAFT / UNMERGED; no `main` edits, merge or release. **BLOCKED — RELEASE: NO-GO.**


## Exact-SHA CI follow-up — 2026-11-04 (a657691)
- Target SHA verified across all five requested runs: `a65769133c32cf51480f6ec68febed6eeba1e3b0`; PR #3052 remains OPEN / DRAFT / UNMERGED.
- Build run `41843444962`: exact checkout and dependency resolution succeeded; `flutter analyze` FAILED on one info-level lint: `unnecessary_const` at `lib/quick_capture_dialog.dart:587:42`. Six test shards were still running at last inspection; the APK matrix job was skipped after Analyze failed. Therefore Build is not green.
- Device Smoke run `41843451312`: seven-lane matrix prepared successfully. Boot and Navigation were running; Task Lifecycle, Quick Capture, Reminder/Vazirmatn, Follow-up Persistence and Calendar Segmented View were queued at last inspection. No seven-lane conclusion yet.
- Calendar Provider run `41843445191`: still running its real Provider instrumentation acceptance; no final conclusion yet.
- Follow-up Persistence run `41843445148`: SUCCESS on exact SHA. File-backed Repository persistence and alarm-overlay SQLite close/reopen checks completed successfully.
- Draft Review APK run `41843444971`: exact checkout, target-SHA verification, Flutter setup, ephemeral staging key and dependency resolution succeeded; Staging APK assembly was still in progress. Artifact listing returned empty at inspection, and signature/font/manifest verification plus artifact upload had not started. APK production/upload therefore NOT VERIFIED; no artifact link exists yet.
- The missing `ArvinTagRollBox.compact` field was fixed before this SHA; Build and APK jobs reached Analyze/assemble stages rather than failing on that prior missing-field compiler error. Full APK compilation success remains pending.
- Quick Capture widget tests in `test/quick_capture_dialog_test.dart` include compact RTL layout and 40dp selector/priority-chip assertions, but their test shard(s) were still running. No result is claimed. The dialog still wraps its content in `SingleChildScrollView`; a no-vertical-scroll fit is not proven by the current test suite or a physical screenshot.
- No tests were removed, skipped, weakened or given artificial timeout extensions in this follow-up. No `main` changes; release remains BLOCKED — RELEASE: NO-GO.


## ممیزی زنده CI — ۱۴۰۵/۰۸/۱۳ (2026-11-04)

- SHA ممیزی: `3f849eefed2afe08c3d3662cf66d9c488388e737`؛ شاخه مجاز PR #3052.
- Build & Analyze [41852047631](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047631): Analyze PASS و شش شارد test-0 تا test-5 همگی PASS؛ test-3 نیز PASS. فقط برای همین SHA معتبر است.
- Follow-up file-backed SQLite [41852047684](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047684): PASS، شامل persistence و close/reopen diagnostic.
- Device Smoke [41852048093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852048093): Preparation PASS؛ Boot و Navigation در حال اجرا؛ Quick Capture، Reminder/Vazirmatn، Follow-up Persistence، Calendar Segmented View و Task Lifecycle در صف. هفت سناریو تکمیل نشده؛ نتیجه نهایی NOT VERIFIED.
- Calendar Provider [41852047809](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047809): اجرای instrumentation/provider acceptance در حال انجام؛ نتیجه NOT VERIFIED.
- Review APK [41852047701](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047701): ساخت staging APK در حال انجام؛ Artifact هنوز موجود نیست، پس لینک دانلود/تأیید APK NOT VERIFIED.
- اصلاح test-3 در این SHA: scrollUntilVisible قبل از pumpAndSettle و assertion اجرا می‌شود؛ Finder و assertion حفظ شده و تست تضعیف نشده است.
- PR #3052 هنگام ممیزی OPEN / DRAFT / UNMERGED؛ main تغییر نکرد؛ Vazirmatn و فیلدهای canonical Task حفظ؛ Release: BLOCKED — RELEASE: NO-GO.
- این snapshot فقط وضعیت runهای SHA ممیزی‌شده را ثبت می‌کند؛ commit مستندات SHA تازه‌ای می‌سازد و PASSهای قبلی را به SHA تازه منتقل نمی‌کند.

## R6 — exact-SHA review APK and live smoke checkpoint (2026-11-04; source SHA: 1815ef72864f3e792661eee08cc932b29ff94c88)
- Review Staging APK run [41874160600](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160600) completed SUCCESS on the exact source SHA. Artifact [13345822544](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip), name `arvin-review-staging-apk-1815ef72864f3e792661eee08cc932b29ff94c88`, ZIP size 38,211,551 bytes, SHA-256 `0821c0b1749e5e852d68283eb5c4181bbb15877f9c701954f56e18db685a5ab1`, expires 2026-11-11 17:12:04 UTC. Direct ZIP: https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip
- Extracted APK: `Arvin-review-staging-1815ef72864f3e792661eee08cc932b29ff94c88.apk`, 76,822,515 bytes, SHA-256 `24295b19eea0300623167fbe400320a961feefbc3e6045e1015c43560a306e75`; application ID `com.example.arvin.staging`; `android_debuggable=false`; APK Signature v2/v3 verified. Signer certificate SHA-256 `f3c4ffe277b87daa789596ae3275fc8d9d59fc1d1236b83a7fa1190cb7a3d37b`. Ephemeral review-only test key; `publishable=false`, `release_created=false`. This artifact is for private review/install testing only, not production or release acceptance.
- Build #9553 run [41874160729](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160729): Analyze and all six test shards (0–5) SUCCESS on the exact SHA. Draft-guarded ordinary APK matrix job was SKIPPED as expected; this is not the Review Staging APK job.
- Device Smoke #6800 run [41874160773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160773): matrix preparation SUCCESS. At the latest job-level poll: Boot IN_PROGRESS; Navigation IN_PROGRESS; Quick Capture QUEUED; Follow-up Persistence QUEUED; Task Lifecycle QUEUED; Calendar Segmented View QUEUED; Reminder/Vazirmatn QUEUED. Screenshot/evidence upload steps had not started. Seven-lane acceptance is NOT VERIFIED. The run-level API status was reported as queued while two lane jobs were already in progress; job-level states are recorded above.
- Calendar Provider Acceptance #1698 run [41874160623](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160623): exact-SHA checkout and setup succeeded; real Provider instrumentation/acceptance step remained IN_PROGRESS; evidence publication pending. Final acceptance NOT VERIFIED.
- Repository cleanup audit on the same source SHA: complete recursive tree (790 entries, not truncated); no tracked APK/AAB, generated build/output/cache/temp directories, or safe deletion candidates found. No cleanup deletion or cleanup commit was made.
- PR #3052 remains OPEN / DRAFT / UNMERGED with head `1815ef72864f3e792661eee08cc932b29ff94c88`; branch is unchanged at this checkpoint. `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`. No code changes, merge, release, or publication were made.
- **BLOCKED — RELEASE: NO-GO.** Physical tablet installation/behavior, seven-lane Device Smoke, Calendar Provider terminal result, and product-owner release acceptance remain separate gates. This evidence applies only to source SHA `1815ef72864f3e792661eee08cc932b29ff94c88`; any documentation commit creates a new HEAD and does not inherit these exact-SHA CI results.


## 2026-11-05 — Exact-SHA audit checkpoint (source SHA: 7e61b8d1ac81dca08c99cc5694fb3f5ab21e9e19)

- GitHub branch and PR #3052 HEAD independently agree on `7e61b8d1ac81dca08c99cc5694fb3f5ab21e9e19`; PR remains OPEN / DRAFT / UNMERGED. `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- Build run [41906289196](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41906289196) SUCCESS: Analyze Job `126841699898`; Test-0 Job `126841699596`; Test-1 Job `126841699599`; Test-2 Job `126841699836`; Test-3 Job `126841699676`; Test-4 Job `126841699192`; Test-5 Job `126841699700`. All six shards PASS. APK matrix Job `126841701237` SKIPPED (not a PASS).
- Review Staging APK run [41906289264](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41906289264) SUCCESS, Job `126841699243`; Calendar Provider run [41906289430](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41906289430) SUCCESS, Job `126841699246`; Follow-up Persistence run [41906289135](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41906289135) SUCCESS, Job `126841698186`.
- Device Smoke run [41906289219](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41906289219) conclusion CANCELLED, not seven-lane PASS. Lane results: Boot Job `126841759601` CANCELLED; Navigation `126841759655` CANCELLED; Calendar Segmented View `126841759834` CANCELLED; Quick Capture `126841759611` PASS; Task Lifecycle `126841759928` PASS; Reminder/Vazirmatn `126841759616` PASS; Follow-up Persistence `126841759792` PASS.
- Reminder lane's dedicated legacy compatibility step (step 10) and emulator smoke both PASS; log shows two targeted Flutter tests and integration test completed. Do not infer Reminder lane status from other lanes' skipped conditional steps.
- Emulator/ADB evidence: initial ADB daemon connection failure and transient `device offline` occurred during startup, but each affected lane subsequently logged `ADB_DEVICE=emulator-5554 ADB_STATE=device ADB_BOOT_COMPLETED=1 ADB_API_LEVEL=35`. Therefore the captured logs do not establish a persistent ADB transport failure. Emulator also logged `bad color buffer handle`; its causal relationship to test execution is NOT VERIFIED.
- Boot, Navigation and Calendar jobs ended as CANCELLED after approximately 29 minutes of job execution, against workflow `timeout-minutes: 30`. Their emulator setup and ADB readiness completed, but the redirected Flutter driver log did not reach its post-run printout before cancellation. No assertion failure is evidenced in the available logs; exact stalled test operation/cancellation trigger remains NOT VERIFIED. This is not a justified basis to raise timeout, skip assertions, or mark lanes PASS.
- Screenshot upload is a separate failure: Boot and Navigation Android screenshot uploads and Calendar evidence upload report no matching PNG files after cancellation. This is a missing-evidence consequence; it does not prove a test assertion failure and does not explain the original test stall.
- Exact-head Review APK artifact ID `13361675761`, archive `arvin-review-staging-apk-7e61b8d1ac81dca08c99cc5694fb3f5ab21e9e19.zip`; archive SHA-256 `4f0b5bfa4d4e9095d8b8cd0f0bdf4502920d2a97aec45abffd4196b2acf2fb24`. Extracted APK `Arvin-review-staging-7e61b8d1ac81dca08c99cc5694fb3f5ab21e9e19.apk`, 76,822,529 bytes; APK SHA-256 `eb27a5ed0b7d2639cb5e5711c8e45da8cb5d94b5cf758f51599b415a8ecdc1eb`. Manifest source SHA exactly matches; package `com.example.arvin.staging`; `android_debuggable=false`; v2/v3 signatures verified; signer certificate SHA-256 `50c411ca240e50620114b767250be4f8234a27a592840ac29a1cf0dfdf3f2d17`; ephemeral review-only test key; `publishable=false`, `release_created=false`. Archive digest and APK digest are distinct values.
- APK archive contains Vazirmatn Regular, Medium and Bold font assets and FontManifest. No local ADB/emulator/APK install tooling was available in the inspection environment; physical-device installation and screenshots are NOT VERIFIED.
- Reference image `photo_1793816062206.webp` was not present in current conversation attachments or located in Library search. No visual comparison was performed. Request original reference plus uncut top and lower screenshots from the exact APK/device before making any visual claim.
- No code/test change was made to mask the cancelled lanes. No rerun/fix of the three incomplete lanes has yet been performed; exact root cause remains open. Documentation commit itself creates a new SHA; all results above remain historical evidence for source SHA `7e61b8d1ac81dca08c99cc5694fb3f5ab21e9e19` only.
- PR remains OPEN / DRAFT / UNMERGED; no main edit, merge, publication or release. **BLOCKED — RELEASE: NO-GO.**


## 2026-11-05 — Module-Core-Logic v1.0 audit checkpoint
- Live PR #3052: OPEN / DRAFT / UNMERGED. Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`. Reviewed HEAD: `4021c84ceb14faf4f6559379cf67dd94955bffe4`. Base `main`: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Module record is in `PRODUCT_DECISIONS.md`; no parallel Module document was created. The exact prior module text was not retrievable, so full verbatim review is NOT VERIFIED.
- Due Date / TaskReminder separation and FollowUp.dateTime persistence are present. `completedAt` on FollowUp is an alias of dateTime.
- Legacy Task fields `followUpEnabled` / `followUpDate` and FollowUp `reminderDate` / `nextFollowUp` remain in active model/SQL serialization. No real user DB inventory/backup was inspected; schema retirement remains BLOCKED.
- Reminder delivery gap: `FollowUpReminderDeliveryService.due` does not filter disabled TaskReminders; `TaskStore.addTaskReminder` has no idempotency guard. No logic fix was made.
- Alarm: scheduler ID 42002; notification IDs are stable-key hashes with 42002 fallback. Stop only cancels notification; Snooze changes the selected Reminder; Follow-up shortcut disables adding another Reminder.
- Exact-SHA CI: Analyze PASS; test-0/1/3/5 PASS; test-2/test-4 FAIL; visual golden FAIL; Persistence PASS; Calendar Provider PASS; Device Smoke 4/7 PASS and 3/7 CANCELLED.
- Test-scenario preservation across the entire PR is NOT VERIFIED: the PR diff rewrites/removes multiple previous test scenarios, although no explicit new skip/timeout directive was detected. Replacement coverage requires review.
- No source/test/schema/main changes, merge, or release. **BLOCKED — RELEASE: NO-GO.**
## Uniform UI token implementation checkpoint — 2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- Owner-approved active tokens: primary `#3F3D56`, header `#2D2B42`, background `#F7F8FC`, card `#FFFFFF`, radius 16px, soft 4% shadow blur 10 offset (0,4), font Vazirmatn.
- New token source: `lib/core/theme/arvin_theme.dart`; compatibility semantic palette: `lib/arvin_colors.dart`.
- Global light CardTheme and AppBar, shared Home shell/navigation/add button, radio/project selector and recurrence chip were routed through tokens. Priority mapping/status/taxonomy semantics were retained; visible priority labels remain Persian «اولویت ۱»…«اولویت ۴».
- New focused test: `test/arvin_theme_tokens_test.dart`. Existing tests unchanged. Exact-SHA CI and widget tests pending; full custom-card conversion and physical visual acceptance NOT VERIFIED.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; release BLOCKED — RELEASE: NO-GO.

### Target-screen card alignment — 2026-11-05 10:03 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- Targeted card styling now also uses the shared token set in Task Details, Task Editor, Quick Capture and Calendar reminder cards; Task Lists retain their 16px card material surface.
- No product behavior/data/persistence/test assertion changes. Full secondary-screen inventory and physical visual acceptance remain NOT VERIFIED; exact-SHA CI pending.

 
## TaskHomeScreen — live implementation checkpoint (2026-11-05 13:02 Asia/Tehran — ۱۴۰۵/۰۸/۱۴)
- Canonical owner-approved Home contract: `docs/project-continuity/task_home_screen_spec.md`.
- Authorized PR branch: `fix/recovery-calendar-device-smoke-2026-10-31`; PR #3052 remains OPEN / DRAFT / UNMERGED; main is not modified.
- Home source alignment commits: `65122e4`, `e89ee5f`, `0ad42cb`, `da311c2` (full SHAs in `IMPLEMENTATION_LOG.md`).
- Implemented on branch: drawer hamburger/right; general filter funnel/left; no notification bell or header search icon; search field preserved with exact placeholder; five filters plus independent sort button in one RTL row; Follow-up Date default sort; Center/Project/Category/Tag task-card metadata; Past/Today/Tomorrow/Future/Timeless group order; dynamic weekday + Jalali dates for Today/Tomorrow.
- Primary navigation source was inspected and already contains five visible tabs in the approved order.
- Existing tests/assertions were not edited or weakened. Exact-SHA Analyze and widget test results for the final documentation-synchronized HEAD are NOT VERIFIED until the current run completes.
- Naskh glyph-level appearance is NOT VERIFIED: the header currently uses a system serif fallback, and no bundled Naskh font asset was found in inspected paths.
- Release remains BLOCKED — RELEASE: NO-GO. Do not merge, publish, release, or touch main.

 
## TaskHomeScreen analyzer correction — 2026-11-05
- An intermediate Analyze run on source checkpoint `da311c2f7e4ef9b96fc20a26e31eca996fa63d50` found the plugin import had also been removed even though the app-level notification tap handler still uses `NotificationResponse`, and found an orphan private `_openPendingReminder` helper after removing the Home bell.
- Corrected in `c0766a5e602d04426486816e95cad4038b667fa7`: restored the plugin type import for the retained notification-response path and removed the now-unreferenced pending-notification helper. The Home header remains bell-free.
- No test files or assertions were changed. Analyze and widget tests on the corrected/final SHA remain NOT VERIFIED until a fresh exact-SHA run completes.

 
## TaskHomeScreen final source delta — 2026-11-05
- Added an explicit accessible semantic label to the independent Home sort action: `72e6779f268bb0ca971b651ad0228604b504f4c8`.
- Ensured the Past group heading also uses the calendar icon when Past is selected directly from the Time filter: `460a40b6411c6c63691817e45ef00aab61544bd8`.
- These are source-only follow-ups; no test file or assertion was changed. The latest exact-SHA Build and Device Smoke runs must complete before any PASS is recorded.


## Calendar UI/UX canonical specification registration — 2026-11-05 — ۱۴۰۵/۰۸/۱۴
- Canonical owner-approved fourteen-section Calendar specification: `calendar_ui_ux_spec.md`.
- Header: centered «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ»; search right; Today full Persian date pill + adjacent «برو به تاریخ» picker left; Help removed.
- Selected-date bar: Jalali bold center, Gregorian right, Hijri lunar left.
- View modes «روزانه / هفتگی / ماهانه / سالانه» above the calendar grid; default weekly.
- Seven-column Saturday–Friday RTL grid; date cells show Jalali primary and Gregorian/Hijri lunar secondary.
- Five filters «همه / تقویم آروین / تقویم گوشی / یادآورها / انجام‌نشده» strictly below the grid and above the agenda. Agenda is selected-day scoped; Task/Event/Reminder cards must not overlap.
- Hijri adjustment options: +1 day, −1 day, Official Iranian Calendar Match.
- No runtime implementation or test changes were made as part of specification registration.
- Exact-SHA audit on base `5bea1ed67549e26aa2ceeb0882477d4cfc2c1f53`: Build #42011495370 FAILURE (test-0, test-2 and visual failed; Analyze and test-1/3/4/5 passed; APK skipped); Device Smoke #42011495381 CANCELLED (4/7 pass, 3/7 cancelled). Calendar Provider, Follow-up Persistence and Parallel Wave Contract passed.
- The above CI results do not transfer to any subsequent documentation SHA. Re-run exact-head gates after documentation synchronization.
- PR #3052 OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.


## STD-GOV-AIPOS-v1.0 — Live checkpoint — ۱۴۰۵/۰۸/۱۴ — 2026-11-05
- Repository: `mobinpda-lab/Arvin-clean`
- Active branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- PR #3052: OPEN / DRAFT / UNMERGED; base main. No main edits authorized or performed by this work.
- HEAD observed before this documentation update: `7327c4e0f472e52b12ecd330cb0331132d8aa396`. Documentation commits below create a newer HEAD; re-read GitHub for the resulting SHA.
- Package: `flutter_svg ^2.3.2` declared in pubspec.yaml; pubspec.lock contains flutter_svg 2.3.2 and its vector dependencies. G1 lock-sync workflow on the observed HEAD: SUCCESS.
- Follow-up file-backed SQLite persistence run 42090629520: SUCCESS.
- Calendar Provider run 42090629465: IN_PROGRESS at last poll.
- Build/Analyze run 42090629467: PENDING; no job result yet. flutter analyze and flutter test exact-SHA results: NOT VERIFIED.
- Device Smoke run 42090629594: preparation SUCCESS; boot and navigation IN_PROGRESS; five remaining lanes QUEUED. Seven-lane acceptance NOT VERIFIED.
- Draft Review APK run 42090629583: IN_PROGRESS; APK artifact not yet verified.
- SVG assets `assets/images/branding/bismillah.svg` and `tafweez.svg`: NOT FOUND at observed HEAD. Home and Calendar sacred phrases still need verified vector replacement. Approved reference image unavailable in searchable project/conversation sources; exact calligraphy match BLOCKED.
- Physical-device visual inspection: NOT VERIFIED. Do not equate emulator smoke or Review APK with physical-device acceptance.
- Release: **BLOCKED — RELEASE: NO-GO**.


## AIPOS v1.0 final documentation checkpoint — 2026-11-05
- Source/CI checkpoint HEAD before the AIPOS documentation series: `7327c4e0f472e52b12ecd330cb0331132d8aa396`.
- Documentation series last commit before this state snapshot: `53e5f7427bbc0dcc09a5419a58dc2ed59c702b65`. This CURRENT_STATE update itself creates a new docs-only HEAD; the live PR head must be queried after commit and no prior-SHA CI status transfers.
- Seven continuity files and root CHANGELOG/Ledger have been updated under STD-GOV-AIPOS-v1.0.
- No Build/Analyze or full test workflow was triggered/available for the documentation-only HEAD at the time of this snapshot; local Flutter CLI is not available through the GitHub repository connector. Exact-SHA `flutter analyze`, `flutter test`, Debug APK and Release APK: NOT VERIFIED.
- Latest known evidence is limited to G1 lock-sync SUCCESS and Follow-up persistence SUCCESS on 7327c4e; Calendar Provider, Build/Analyze, Device Smoke and Draft Review APK were incomplete at last poll.
- SVG assets remain NOT FOUND. Reference art remains unavailable. Release BLOCKED — RELEASE: NO-GO.


## SVG sacred branding implementation — 2026-11-05 (۱۴۰۵/۰۸/۱۴)
- Product assets received from the product owner and validated as single-path SVGs: one `path` element per file, no background/image/text/gradient elements, path fill `#1A2B4C`.
- Added `assets/images/branding/bismillah.svg` and `assets/images/branding/tafweez.svg`; registered `assets/images/branding/` in `pubspec.yaml`. Existing `flutter_svg: ^2.3.2` dependency and lock resolution were retained.
- Home header now renders the Bismillah SVG at width 210; Calendar header renders Tafweez SVG at width 240. Both use the approved navy color filter and one outer Semantics label; the inner SVG excludes duplicate semantics.
- Updated Home/Calendar sacred-phrase widget tests to assert SVG keys, dimensions, semantics labels and absence of duplicate Text widgets. Existing Vazirmatn-only text family remains the only declared text family in `pubspec.yaml` and `AppFonts`.
- Source/test implementation commit (before continuity-doc sync): `507503611b08d2cfdfbee7d37c05e4fbd72ad85e`.
- `flutter pub get`, `flutter analyze`, and full `flutter test` have not been run locally in this GitHub connector environment. Exact-SHA CI is required; do not claim test success until its jobs finish.
- PR #3052 remains OPEN / DRAFT / UNMERGED; no main changes; **BLOCKED — RELEASE: NO-GO**.


## Exact-SHA CI result — 2026-11-05 — target d57a6b572ef14361f5354fa1840d950bf01e9506
- Build run 42094217896 completed with FAILURE on the requested exact SHA. `quality (analyze)` SUCCESS; all six test shards FAILED. Shard totals: test-0 210 passed / 7 failed; test-1 172 / 7; test-2 293 / 7; test-3 133 / 5; test-4 227 / 1; test-5 163 / 5. Aggregate: **1,198 passed / 32 failed** (1,230 executed test cases across the six shards).
- Failed tests, by shard:
  - test-0: `test/task_detail_followup_flow_test.dart` (Task detail removes redundant status badge / description placeholder); `test/backup_page_encryption_ux_test.dart` (encrypted backup confirmation); `test/widget_test.dart` (canonical centered Home identity); `test/home/home_filter_contract_test.dart` (five collapsible time groups); `test/home_settings_integration_test.dart` (font-size preference); `test/task_detail_master_screen_test.dart` (due time/all-day pickers; add reminder).
  - test-1: `test/task_detail_followup_flow_test.dart` (inline description edit); `test/project_template_service_test.dart` (Project-to-template conversion); `test/device_feedback_home_regression_test.dart` (canonical Home identity); `test/task_detail_master_screen_test.dart` (edit reminder title; remove selected reminder; edit reminder date/time); `test/home_stat_filters_test.dart` (short Android viewport).
  - test-2: `test/alarm_overlay_page_test.dart` (snooze exact Reminder); `test/task_detail_master_screen_test.dart` (recurrence; Follow-up presentation; checklist staging/reorder); `test/task_detail_checklist_crud_test.dart` (checklist CRUD); `test/home_today_about_test.dart` (Today empty state); `test/task_template_management_page_test.dart` (Task Template conversion).
  - test-3: `test/alarm_overlay_page_test.dart` (explicit Follow-up Save); `test/home/home_filter_contract_test.dart` (Home card expansion/history); `test/task_detail_master_screen_test.dart` (scroll offset; independent Reminder; compact visibility).
  - test-4: `test/task_detail_master_screen_test.dart` (rich-section visibility).
  - test-5: `test/alarm_overlay_page_test.dart` (all-day Reminder Snooze); `test/widgets/home_page_test.dart` (complete Task from Past); `test/task_detail_master_screen_test.dart` (summary/metadata/due date RTL; add Checklist); `test/canonical_calendar_launcher_test.dart` (repeat occurrence action).
- Exact failure signatures visible in job logs include: `pumpAndSettle timed out` in `test/alarm_overlay_page_test.dart`; `Bad state: No element` from `ensureVisible` in `test/home/home_filter_contract_test.dart` and `test/task_detail_checklist_crud_test.dart`; expected one Scrollable but found two in `test/task_detail_master_screen_test.dart`; missing key `task-detail-checklist`; missing key `task-detail-description-input`; missing key `task-template-confirm`; and a 66px bottom RenderFlex overflow at `lib/main.dart:1277` in `test/home_today_about_test.dart`. The exact source file/test names above are preserved from the failed-test log headers.
- APK matrix inside Build run: Debug and Release APK jobs SUCCESS; Staging APK job FAILED during Gradle distribution download with `java.net.SocketException: Broken pipe`; staging APK file was absent and no staging artifact was uploaded by this job.
- Draft Review APK run 42094218155: SUCCESS. Review-only APK artifact exists: ID 13447431967, name `arvin-review-staging-apk-d57a6b572ef14361f5354fa1840d950bf01e9506`, 39,103,986 bytes, SHA-256 `d4b1de0f3a21a0292759bf49ed1847824491b429ac5c135bedf5b7ab044961ec`, expires 2026-11-12. This is a review/staging artifact, not a production release.
- Calendar Provider run 42094217973: SUCCESS.
- Device Smoke run 42094217975: NOT COMPLETE at last poll; preparation job SUCCESS, navigation and boot lanes IN_PROGRESS, remaining five lanes QUEUED. No seven-lane PASS is claimed.
- Follow-up Persistence run 42094218060: SUCCESS. G1 lock sync run 42094218111: SUCCESS.
- `flutter analyze`: PASS on target SHA. `flutter test`: FAIL, aggregate 1,198 PASS / 32 FAIL. Do not mark the test suite green.
- PR #3052 governance remains OPEN / DRAFT / UNMERGED by instruction; no main write, merge, or release is authorized. **BLOCKED — RELEASE: NO-GO**.

## زیرساخت برندینگ، فونت و تداوم — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Target branch: `fix/recovery-calendar-device-smoke-2026-10-31`; baseline SHA before this documentation commit: `25dfa7e9adb50570b2c9a23bb9edd1e0a4a34893`.
- Sacred vector assets were already present at the canonical paths on the target branch; no duplicate or replacement files were created:
  - `assets/images/branding/bismillah.svg` (blob `421f2fbaa27764c0b11962465cc351b2537239c8`, 30,058 bytes).
  - `assets/images/branding/tafweez.svg` (blob `dd5db5b401eceef981b417dd7f781d9994ac4e10`, 22,553 bytes).
- `pubspec.yaml` already declares active dependency `flutter_svg: ^2.3.2` and includes `assets/images/branding/` under Flutter assets. No dependency or asset-registration edit was necessary.
- Global text-family contract verified in source: `ArvinTheme.fontFamily = 'Vazirmatn'` in `lib/core/theme/arvin_theme.dart`; `AppFonts.vazirmatnFamily = 'Vazirmatn'` in `lib/theme/app_fonts.dart`; light and dark MaterialApp ThemeData both set `fontFamily: AppFonts.vazirmatnFamily` in `lib/main.dart`. No Amiri/Neyriz references were found in these inspected global font configuration files. This is a scoped source inspection, not a repository-wide proof that no secondary font string exists anywhere.
- Recent test-helper correction: commit `25dfa7e9adb50570b2c9a23bb9edd1e0a4a34893`, message `test: select primary task detail scrollable`; `_taskDetailPageScrollable` now selects the first downward-axis Scrollable within `task-detail-content-list` using `.first`.
- Exact-SHA CI for `25dfa7e9adb50570b2c9a23bb9edd1e0a4a34893`, latest observed status:
  - Build run `42140371675`: Analyze SUCCESS; test-0 SUCCESS; test-1 SUCCESS; test-5 SUCCESS; test-2 FAILURE; test-3 FAILURE; test-4 FAILURE. Debug, Staging and Release APK jobs were still IN_PROGRESS at this observation. Overall Build: IN_PROGRESS; test suite is NOT green.
  - Device Smoke run `42140371697`: preparation SUCCESS; boot and navigation IN_PROGRESS; calendar-segmented-view, reminder-vazirmatn, quick-capture, follow-up-persistence and task-lifecycle QUEUED. Overall NOT COMPLETE.
  - Draft Review APK run `42140371696`: IN_PROGRESS.
  - Follow-up Persistence run `42140371677`: SUCCESS.
  - Calendar Provider run `42140371756`: IN_PROGRESS.
- This continuity update is documentation-only and does not cancel, modify, or replace any active workflow. Results from the previous SHA do not transfer to a later SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED by instruction. No write to `main`, merge, or release is authorized. **BLOCKED — RELEASE: NO-GO** until all required exact-SHA test shards and validation lanes pass and product-owner approval is recorded.

## اصلاحات یکپارچه Task Details، الگو و کنتراست SVG — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- مبنای بررسی: branch HEAD `cbc56e0db2695dc6c578ecfb841e6fd916613080`. Device Smoke run `42141526859` روی همین SHA با نتیجه `CANCELLED` خاتمه یافته بود؛ هیچ Job فعالی از آن اجرا باقی نمانده بود، بنابراین تغییرات بدون لغو/دست‌کاری اجرای فعال انجام شد.
- Build run `42141526931` روی همان SHA: Analyze PASS؛ test-0 و test-1 و test-5 PASS؛ test-2 و test-3 و test-4 FAIL. شکست‌ها در لاگ‌ها به‌ترتیب شامل پیام موفقیتِ ساخت کار از الگو که پس از SnackBar قبلی دیده نمی‌شد، پیمایش معکوس بخش‌های lazy در تست Smart visibility، و وجود دو نمونه از کارت منشأ الگو با کلید یکسان بودند.
- `lib/task_template_management_page.dart`: صف SnackBarهای قبلی پیش از پیام موفقیت ساخت کار از الگو پاک می‌شود؛ هیچ عملیات ذخیره‌سازی یا داده‌ای تغییر نکرده است.
- `test/task_detail_master_screen_test.dart`: پیمایش تست Smart visibility مطابق ترتیب واقعی صفحه شد: Reminder → Recurrence → Checklist → Follow-up → Timeline. assertion نشان «در انتظار انجام» حفظ شده است.
- `lib/task_detail_page.dart`: کارت منشأ الگو از داخل Summary خارج شد و فقط در جایگاه مستقل فهرست جزئیات، پس از Summary/Description و پیش از Due Date باقی ماند. تست rich details یکتایی آن را بررسی می‌کند.
- Home و Calendar: رنگ SVG در تم روشن سرمه‌ای برند `#1A2B4C` و در تم تاریک `Theme.of(context).colorScheme.onSurface` است؛ فیلتر `BlendMode.srcIn` حفظ شد. تست‌های اختصاصی هر دو حالت روشن/تاریک افزوده شدند. متن جایگزین Semantics و اندازه/fit فایل‌های SVG تغییر نکرد.
- Calendar Provider run `42141526861` و Follow-up Persistence run `42141526818` روی SHA مبنا SUCCESS بودند؛ Draft Review APK run `42141526865` SUCCESS و review-only بود. Device Smoke روی SHA مبنا CANCELLED؛ نصب/استفاده واقعی دستگاه NOT VERIFIED.
- Release APK داخل Build قبلی ساخته شد، اما سه شارد شکست داشتند؛ ساخت APK به‌تنهایی پذیرش محصول یا انتشار را اثبات نمی‌کند.
- این ثبت همراه تغییرات منبع/تست در یک commit واحد قرار می‌گیرد. تمام CI باید روی SHA این commit تازه اجرا شود؛ نتایج SHA مبنا به آن منتقل نمی‌شوند.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاح تکمیلی کنتراست پویا و تثبیت Finder کارت منشأ الگو — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- کپسول SVG بسم‌الله Home در Light از زمینه برند روشن `#F0F0F6` استفاده می‌کند و در Dark به `colorScheme.surfaceContainerLow` تغییر می‌کند؛ رنگ SVG در Dark همچنان به‌صورت پویا از `colorScheme.onSurface` دریافت می‌شود.
- آزمون‌های SVG در Home و Calendar به دو تست مستقل Light/Dark تفکیک شدند؛ مقدار پویا از خود Theme خوانده می‌شود و رنگ زمینه کپسول نیز جداگانه assert می‌شود.
- کارت منشأ الگو در Task Details کلید ثابت `task_detail_template_source_card` دارد و تنها در فهرست اصلی، پس از Summary/Description و پیش از Due Date رندر می‌شود.
- آزمون ترتیب RTL ابتدا Description را پیدا و آشکار می‌کند، سپس وجود کارت منشأ الگو را پیش از اسکرول به آن assert می‌کند؛ ترتیب Description → Template Source → Due Date → Assignee حفظ شده است.
- هیچ تستی حذف، skip یا تضعیف نشده است. assertion نشان «در انتظار انجام» و پوشش Smart visibility حفظ شده‌اند.
- تغییرات باید روی HEAD جدید در شش شارد Build و Device Smoke کامل اعتبارسنجی شوند؛ هیچ PASS از SHA قبلی منتقل نمی‌شود. PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاح Analyze تست Home و تثبیت کامیت دوم — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- SHA مبنا: `0d7d76b0889aac972764594db1eee8b8dfa29b7b`. در `test/home/home_visual_integration_test.dart` دو عملگر غیرضروری `!` از `capsule.decoration` حذف شدند؛ هیچ assertion، تست، انتظار یا پوشش رفتاری حذف یا تضعیف نشد.
- تغییر صرفاً برای رفع دو هشدار `unnecessary_non_null_assertion` است. نتیجه قطعی Analyze روی SHA جدید فقط پس از اجرای CI همان SHA اعلام می‌شود.
- روی SHA مبنا، شش شارد `test-0` تا `test-5` موفق بودند؛ Analyze به علت همین دو هشدار شکست خورد. ساخت APKهای Debug، Release و Staging موفق بود؛ Device Smoke هنوز نتیجه نهایی نداشت.
- این اصلاح همراه به‌روزرسانی این سند و `CHANGELOG.md` در یک کامیت واحد ثبت می‌شود. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ **BLOCKED — RELEASE: NO-GO**.


# Live State — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06


## Live execution checkpoint — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06
- Repository: `mobinpda-lab/Arvin-clean`; authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`; checkpoint parent SHA: `105737b1e4d5f9e2d6e35dfc7c9f4bfd5b1cbdda`.
- PR #3052 was verified OPEN / DRAFT / UNMERGED, based on `main`; do not merge, close, or mark ready.
- Release remains **BLOCKED — RELEASE: NO-GO**. No main-branch write is authorized.
- Device Smoke run `42169009238` (run #7146) is still `IN_PROGRESS` on exact SHA `105737b1e4d5f9e2d6e35dfc7c9f4bfd5b1cbdda`. The observed lane snapshot: Preparation SUCCESS; Quick Capture SUCCESS; Follow-up Persistence SUCCESS; Reminder/Vazirmatn SUCCESS; Task Lifecycle SUCCESS; Calendar Segmented View IN_PROGRESS; Boot and Navigation jobs CANCELLED. Therefore the seven-lane Smoke gate is NOT VERIFIED / incomplete. The cancelled lanes are not PASS and must not be treated as skipped acceptance.
- Exact-SHA Build run `42169009592` (#9904) reports SUCCESS; this does not replace the incomplete Device Smoke gate.
- GitHub exposes committed branch state only. Local working-tree status and local test execution are NOT VERIFIED from this remote audit.

## Verified source/test observations at checkpoint SHA
- `lib/report_center_page.dart`: completed Follow-up reporting is selected inside the comprehensive `_ReportFilterSheet` under `report-filter-type-completed-follow-ups`; no separate top-level action is exposed.
- `test/report_center_page_test.dart`: asserts `report-center-completed-follow-ups` is absent, opens the unified filter sheet, selects the completed-follow-up report type, applies it, and verifies the report output.
- `lib/quick_capture_dialog.dart`: empty-title validation sets compact inline `errorText` and presents a floating SnackBar with «عنوان برای ثبت کافی است».
- `test/quick_capture_dialog_test.dart`: retains the test `quick capture rejects empty input with visible feedback`, asserting both visible feedback instances and the Quick Capture title. No assertion was removed or weakened in this checkpoint.
- Exact source blob SHAs: report page `0459fc0a1cfe239eb09fecdd7dd5d42c6ec0845d`; report test `18d5b59fae5d3f127d4ccaedb2963b55b0ad781b`; Quick Capture source `a6b0fa76cd1fed494b0e72d8f66e7db3e47e2a85`; Quick Capture test `875bac562caa55b60bfa2e3871f1e2e2b3ae6abf`.
- The source and focused assertions are present. Build run SUCCESS is exact-SHA evidence, while the overall Device Smoke acceptance remains incomplete as detailed above.


## Device Smoke final recheck — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Audited source/branch checkpoint: `49401bd4fcfa5622282d0fd80ec607d12daf467a`; Device Smoke run [42175115690](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42175115690) checks out this exact SHA on `fix/recovery-calendar-device-smoke-2026-10-31`.
- Latest GitHub run metadata remains `status=queued`, `conclusion=null`, updated at `2026-11-06T06:32:55Z`. Job-level state is authoritative for this snapshot: Preparation SUCCESS; Boot IN_PROGRESS; Navigation IN_PROGRESS; Calendar Segmented View QUEUED; Quick Capture QUEUED; Task Lifecycle QUEUED; Reminder/Vazirmatn QUEUED; Follow-up Persistence QUEUED.
- Seven requested product lanes are therefore **NOT COMPLETE / NOT ACCEPTED**. No lane has a terminal result available in this poll; do not convert IN_PROGRESS/QUEUED into PASS or FAIL.
- Artifact list for this run is empty. Screenshot upload steps have not completed. Fetching logs for Boot and Navigation returned HTTP 404 (BlobNotFound); this is unavailable log evidence, not proof of a product failure.
- No code, tests, workflow definitions, run state, or main-branch content was changed to obtain this report. No rerun, cancellation, retry, or fabricated device evidence was performed.
- Previous UI/source audit findings remain open until corrected and independently retested: Quick Capture description field remains present; Reports uses a filter sheet rather than the required visible five-filter row; Calendar does not render the required three-calendar date display; horizontal swipe changes the displayed period rather than transferring the event to the phone calendar; the Tafweez phrase/accessible label does not yet exactly match the newly mandated «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ» wording. These are source-inspection findings, not outcomes of this Smoke run.
- Global Vazirmatn configuration and the two standalone SVG assets were observed in source; this does not establish physical-device glyph/rendering acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. Release remains **BLOCKED — RELEASE: NO-GO**.
- This entry is documentation-only. The active Smoke run remains bound to SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`; its results do not automatically transfer to a later documentation HEAD.

## Continuity sync checkpoint — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Current code/evidence baseline recorded above: `49401bd4fcfa5622282d0fd80ec607d12daf467a`. This document update advances the branch HEAD; re-read the resulting branch SHA after all continuity files are updated.
- Product deviations are tracked in `OPEN_ISSUES.md`; this checkpoint does not claim their implementation or acceptance.
- No write to `main`, no PR merge/close/ready-for-review transition, and no release action.


## Device Smoke subsequent poll — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- A later GitHub job poll supersedes the earlier QUEUED snapshot in this document. Run `42175115690` remains on exact SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`; run-level status is `in_progress`, conclusion null.
- Preparation: SUCCESS. Boot: IN_PROGRESS. Navigation: IN_PROGRESS. Reminder/Vazirmatn: CANCELLED. Task Lifecycle: CANCELLED. Calendar Segmented View: CANCELLED. Quick Capture: CANCELLED. Follow-up Persistence: CANCELLED.
- Thus 0/7 product lanes have a terminal PASS; 5/7 are CANCELLED and 2/7 remain IN_PROGRESS. This is an incomplete/blocked run, not a seven-scenario success. Cancelled jobs expose no step summaries in the available endpoint; root cause NOT VERIFIED.
- Artifact list remains empty. Boot and Navigation are still inside the canonical smoke execution step; screenshot uploads remain pending. No final screenshot or device proof is available.
- Do not cancel or retry the two active jobs solely to manufacture a green matrix. Wait for their terminal results, then investigate cancelled lanes from available workflow/job diagnostics. No acceptance claim is permitted meanwhile.
- The documentation branch HEAD has advanced to include this note; the run is still bound to the pre-documentation code SHA above. PR #3052 remains OPEN / DRAFT / UNMERGED; main remains `45e4202b03a434459e4c021a04efa7e8396359db`; release remains **BLOCKED — RELEASE: NO-GO**.


## Device Smoke terminal result — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Final poll of run [42175115690](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42175115690): `status=completed`, `conclusion=cancelled`, checkout SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`.
- Preparation job SUCCESS. All seven product lanes ended CANCELLED: Boot, Navigation, Calendar Segmented View, Quick Capture, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence. Final acceptance: **0/7 PASS; 7/7 CANCELLED; Device Smoke FAILS THE COMPLETION GATE / NOT ACCEPTED**. Cancellation is not evidence that product behavior failed; it is evidence that the scenarios did not complete.
- Artifact endpoint returned an empty list; no screenshot/device evidence was uploaded. Job-step summaries for cancelled lanes were empty. Earlier log retrieval attempts returned 404; cancellation initiator/root cause is **NOT VERIFIED** from the available evidence.
- Do not relabel cancelled lanes as skipped/pass, and do not infer a device test failure from cancellation alone. A fresh authorized run is required after investigating why this run was cancelled; preserve all tests/assertions and do not add timeout/skip/retry masking.
- Run is pinned to code SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`. Continuity docs were subsequently synchronized on the authorized branch; those documentation commits do not retroactively change the run's checkout SHA or make its result apply to the new HEAD.
- PR #3052 remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. Release remains **BLOCKED — RELEASE: NO-GO**.


## ممیزی و اصلاحات UX / Home و فرم‌ها — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Code checkpoint SHA:** `f614fab584cd149db7aa9234dbe825b14198c292`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**main:** untouched  
**Release:** BLOCKED — RELEASE: NO-GO.

### Commits روی شاخه
- `6d7a48de45a4fc07a5f1c6dd70455e3484218ec8` — توکن‌های برند اصلی از بنفش/سرمه‌ای به آبی‌فیروزه‌ای تغییر کردند: primary `#087F8C`، header `#075E66`، soft `#DDF7F5`. رنگ‌های معنایی اولویت و taxonomy در تست توکن‌ها بدون تغییر باقی ماندند؛ رنگ SVG بسم‌الله `#1A2B4C` دست‌نخورده است.
- `1e63de1b39327ca569283a7bf6ea0cea9d328917` — ردیف انتخاب مرکز/پروژه/دسته/برچسب و ردیف موعد/یادآور/تکرار در ثبت سریع از اسکرول افقی به Wrap چندردیفی تغییر کرد؛ تست اندازه‌های 320 و 1024 پیکسل، نبود اسکرول افقی فرم را بررسی می‌کند.
- `c3e2b522ee72b74a4366648d09f19fc847a791f3` — نسخه اولیه Wrap برای taxonomy فرم کامل ثبت شد؛ ساختار این نسخه در کامیت بعدی اصلاح شد و این SHA به‌تنهایی مبنای پذیرش نیست.
- `5164319f5262e458ee85af127c83d3fc5bdd0d08` — ساختار Wrap فرم کامل اصلاح و برای Category / Project / Tag کلیدهای آزمون‌پذیر اضافه شد؛ چیدمان در عرض باریک دو ستونه و در عرض عریض سه‌ستونه است.
- `670e092f2bc4a0b3220f58d449a825637c1ea880` — عبارت نمایش پروژه به APIهای سازگار Dart محدود شد؛ از extension غیرضروری استفاده نمی‌شود.
- `f614fab584cd149db7aa9234dbe825b14198c292` — اولویت ثبت سریع تا انتخاب صریح کاربر `TaskPriority.none` است؛ تاریخ موعد و یادآور نیز بدون انتخاب کاربر null می‌مانند. تست عدم‌تولید پیش‌فرض‌ها افزوده شد.

### مواردی که پیش از این وجود داشتند
- هدر اصلی Home با منوی راست، SVG بسم‌الله، عنوان و زیرعنوان مرکزی و فیلتر عمومی چپ؛ کادر جستجو زیر هدر؛ ردیف پنج فیلتر RTL با مرتب‌سازی مستقل؛ پنج گروه زمانی؛ FAB و پنج مقصد Bottom Navigation از قبل در `lib/main.dart` وجود داشتند.
- مرتب‌سازی پیش‌فرض در Home از قبل `TaskListSort.lastFollowUp` با جهت صعودی بود. طبق قرارداد، موارد فاقد Follow-up پس از موارد تاریخ‌دار می‌آیند و تساوی با اولویت و سپس شناسه Task شکسته می‌شود. گروه‌بندی پنج‌گانه از Due Date استفاده می‌کند.
- فیلترهای Home از قبل منطق OR داخل بُعد و AND بین ابعاد را پیاده کرده بودند؛ آزمون موجود ترکیب Category و Tag را پوشش می‌دهد، اما پوشش کامل پنج بُعد و تمام ترکیب‌ها هنوز اثبات نشده است.
- مدل `PersonReference`، سرویس `TaskPeopleService`، فیلد `Task.people` و `FollowUp.personIds` و فیلتر اشخاص در Report Center از قبل وجود دارند؛ این به‌معنای وجود انتخاب/افزودن شخص در فرم Follow-up نیست.
- `allDay` برای Due Date از قبل وجود دارد؛ این وضعیت جایگزین پشتیبانی عمومی «بدون ساعت» در Follow-up و Reminder نیست.

### تطبیق Home و فرم‌ها — شکاف‌های باز
- **Home:** هدر، جستجو، فیلترها، گروه‌ها و navigation از نظر ساختاری موجودند. گروه «آینده» در کد عنوان تجمیعی دارد و نمایش تاریخ کامل برای آن هنوز نیازمند تطبیق دقیق با بند ۱۰ سند است. آزمون Home موجود viewport 320×640 و 390×844 را پوشش می‌دهد؛ آزمون DPR کسری 0.333px، بزرگ‌نمایی فونت و صفحه‌کلید برای Home هنوز اضافه/اجرا نشده است.
- **فرم کامل Task:** کنترل‌های Category / Project / Tag اکنون Wrap می‌شوند؛ انتخاب‌گر Center در این فرم هنوز وجود ندارد. Project دارای `centerId` است و نباید بدون انتخاب/رابط صریح، Center مستقل جعل شود.
- **اشتراک فیلترها:** ردیف Home از `ActionChip` و Report Center از بخش‌های مستقل `_Section` / `_MultiSelectChips` استفاده می‌کند. ادغام واقعی در یک جزء مشترک و یکسان‌سازی وضعیت/تعامل پنج فیلتر هنوز انجام نشده است؛ فیلتر شخص گزارش مستقل باقی می‌ماند.
- **Follow-up / Person:** فرم `FollowUpEntryPage` وضعیت «منتظر پاسخ» را ذخیره می‌کند، اما انتخاب شخص موجود/افزودن شخص جدید و تغییر/حذف پیوند شخص را در UI ارائه نمی‌کند. گزارش‌ها فقط از `personIds` موجود استفاده می‌کنند؛ آزمون ذخیره، بازگشایی و گزارش یک شخص واقعی هنوز انجام نشده است.
- **تاریخ/ساعت:** در چند فرم، انتخاب تاریخ و ساعت هنوز کنترل‌های جدا دارد. Due Date از `allDay` استفاده می‌کند، اما جریان واحد یک‌دکمه‌ای و گزینهٔ صریح «بدون ساعت» در همهٔ محل‌های اختیاری پیاده نشده است. پشتیبانی ذخیره/نمایش بدون ساعت برای Follow-up و عدم ساخت اعلان زمان‌دار بدون ساعت هنوز باز است؛ Due Date، Follow-up Date و Reminder Date مستقل باقی می‌مانند.
- **چیدمان تقویم:** تغییر قبلی به پیمایش عمودی و guard خطای startup در کد وجود دارد؛ این guard به‌تنهایی رفع منشأ RenderFlex را اثبات نمی‌کند. گزارش دستگاه با سرریز 0.333px در منابع قابل دسترس این ممیزی پیدا نشد؛ اصلاح منشأ و آزمون DPR کسری/فونت بزرگ/RTL هنوز NOT VERIFIED است.
- **SVG و فونت:** توکن رنگ بسم‌الله در Home حفظ شده است. وجود دو asset بسم‌الله و تفویض در مخزن به‌تنهایی اثبات path-only بودن، نبود عنصر text/raster، و render صحیح روی دستگاه نیست؛ این گیت‌ها باید با آزمون asset و screenshot تأیید شوند. Vazirmatn تنها فونت متنی مجاز باقی می‌ماند.

### وضعیت شواهد روی Code SHA بالا
- Build run `42261229876`: PENDING؛ در آخرین بررسی هنوز job آغاز نشده بود. بنابراین `flutter analyze` و مجموعه کامل تست‌ها روی این SHA نتیجه ندارند.
- Device Smoke run `42261230051`: PENDING؛ هنوز job و مدرک دستگاه/اسکرین‌شات ارائه نشده است.
- Follow-up File Persistence run `42261230162`: SUCCESS؛ checkout SHA دقیق تأیید شد؛ تست file-backed Repository و diagnostic بستن/بازگشایی SQLite هر دو SUCCESS شدند. این گیت محدود، جایگزین آزمون شخص/گزارش یا Device Smoke نیست.
- Calendar Provider run `42261229778`: IN_PROGRESS؛ آزمون instrumentation/provider در حال اجرا بود.
- Draft Review APK run `42261229806`: IN_PROGRESS؛ ساخت Staging APK در حال اجرا بود؛ در لحظه بررسی هیچ artifactی بارگذاری نشده بود. APK Debug مستقل ساخته/تحویل نشده است.
- نتیجهٔ orchestration/factory SUCCESS جایگزین Analyze، تست، APK، Device Smoke یا پذیرش مالک محصول نیست.

هیچ تست یا قابلیتی حذف، skip یا تضعیف نشده است. هیچ تغییر روی `main`، Merge، Release یا انتشار انجام نشده است. این ثبت مستندات، نتیجهٔ CI را به PASS ارتقا نمی‌دهد.


## آخرین اصلاح منبع چیدمان و آزمون‌های اندازه‌ناپذیر — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent code SHA:** `9e1c9f3e4e52f5168fb3749195b32926fa28bc0a`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO.

- Home header، search، filter row و active-filter chips اکنون داخل یک viewport عمودی قابل پیمایش با `FlexFit.loose` قرار می‌گیرند؛ در viewport کوتاه یا هنگام بازبودن صفحه‌کلید، محتوای کنترل‌ها به‌جای فشرده‌سازی اجباری و سرریز، در همان ناحیه پیمایش می‌شود. لیست کارها همچنان viewport مستقل Expanded دارد.
- آزمون‌های جدید منبعی برای Calendar و Home عرض منطقی 360.333px (1081 physical px در DPR=3)، فونت بزرگ 1.4، RTL و inset صفحه‌کلید Home اضافه شده‌اند. آزمون‌های Quick Capture و Task Editor نیز با بزرگ‌نمایی فونت اجرا می‌شوند.
- این‌ها آزمون‌های منبعی هستند؛ تا نتیجهٔ exact-SHA Build، هیچ‌کدام PASS محسوب نمی‌شوند و جای نصب روی دستگاه واقعی را نمی‌گیرند.
- گزارش دقیق مالک محصول از دستگاه فعلی (مدل دستگاه، مقیاس، مسیر صفحه، و screenshot مربوط به overflow 0.333px) در PR comments/Issue #823 comments و فایل‌های فعلی مخزن قابل بازیابی نبود. این خلأ به‌عنوان NOT VERIFIED ثبت می‌شود؛ گزارش قدیمی نصب APK از 2026-08-14 مربوط به PR دیگر است و مبنای این پذیرش نیست.
- Home spec چهارده‌بندی در منبع خوانده شد. بخش‌های ساختاری موجود (header، Bismillah SVG، search، پنج فیلتر و sort مستقل، گروه‌بندی Due Date، navigation پنج‌تب) از قبل پیاده بودند؛ تست‌ها و پذیرش بصری کامل هنوز لازم‌اند. شکاف‌های Center در فرم Task، یکپارچه‌سازی جزء فیلتر Home/Report، انتخاب Person در Follow-up و مدل/جریان بدون ساعت همچنان بازند.
- وضعیت runهای دقیق parent SHA `9e1c9f3`: Build `42261916395` PENDING بدون job؛ Device Smoke `42261916305` PENDING بدون job؛ Draft Review APK `42261916169` IN_PROGRESS؛ Calendar Provider `42261916279` IN_PROGRESS؛ Follow-up Persistence `42261916393` IN_PROGRESS. نتایج این runها فقط به همان SHA تعلق دارند.
- آزمون‌های قبلی روی SHA `f614fab` برای file-backed Repository و SQLite close/reopen هر دو SUCCESS بودند؛ نتیجه به SHA جدید منتقل نمی‌شود.

هیچ تستی حذف، skip، bypass یا تضعیف نشده است. main دست‌نخورده، PR OPEN/DRAFT/UNMERGED و انتشار NO-GO باقی می‌ماند.


## اصلاح خطای تحلیل و ساخت Quick Capture — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent SHA:** `1c14c801a2b04cc70a4a617e2e7626d6c35d4331`  
**Evidence run:** Build `42262323182` on SHA `b5c8892a7aa5dad5d83abbf717bc19ea5c63140c`; Draft Review APK `42262323487` on the same SHA.

- Analyze در SHA `b5c8892` با سه خطای syntax در `lib/quick_capture_dialog.dart` شکست خورد: دو خطای positional arguments و یک پرانتز بسته‌نشده (log lines around 762, 833, 863). Staging APK نیز در مرحلهٔ compile Flutter با همان دو parenthesis mismatch شکست خورد؛ هیچ APKی upload نشد.
- علت: در تبدیل دو ردیف ثبت سریع به Wrap، یک لایهٔ بسته‌شدن `_surfaceCard` از هر بلوک جا افتاده بود. این مورد پنهان یا skip نشد؛ در این commit دو closure مربوط به هر دو Wrap کامل می‌شود.
- این اصلاح فقط syntax را ترمیم می‌کند؛ پذیرش layout هنوز منوط به Analyze و آزمون‌های exact-head است.
- SHA `b5c8892` همچنان FAIL برای Analyze و Review APK ثبت می‌شود؛ نتیجه به SHA جدید منتقل نمی‌شود.
- برای parent SHA `1c14c80`: Build `42262966593` PENDING، Device Smoke `42262966560` PENDING، Draft Review APK `42262966666` IN_PROGRESS، Calendar Provider `42262966580` IN_PROGRESS، Follow-up Persistence `42262966838` IN_PROGRESS. Artifactی هنوز ثبت نشده بود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ هیچ merge یا release انجام نشده است؛ **BLOCKED — RELEASE: NO-GO**.


## پیوند شخص به پیگیری — اجرای UI و ذخیرهٔ شناسهٔ پایدار (۱۴۰۵/۰۸/۱۵)

- **Parent SHA:** `277117469ff586a9529c5ab23c655cc2d6eb2e0e`
- **Scope:** فقط فرم ثبت/ویرایش Follow-up و اتصال آن به فهرست canonical اشخاص.
- هنگام فعال بودن «منتظر پاسخ دیگران»، فهرست اشخاص با شناسهٔ پایدار و گزینهٔ افزودن شخص جدید نمایش داده می‌شود. انتخاب قبلی در ویرایش بازسازی می‌شود و انتخاب/حذف از همان مجموعهٔ `FollowUp.personIds` ذخیره می‌شود.
- ایجاد شخص از مسیر `TaskStore.mergePeopleDirectory` انجام می‌شود؛ دادهٔ شخص در فهرست canonical باقی می‌ماند و Follow-up فقط شناسه‌ها را نگه می‌دارد. افراد حذف‌شده با برچسب تاریخی «شخص حذف‌شده» قابل مشاهده و حذف از پیوند هستند.
- مسیر ثبت از Home و مسیر افزودن/ویرایش در Task Details به همان فرم و مخزن داده وصل شدند. آزمون widget برای افزودن، انتخاب، بازگشایی و حذف پیوند اضافه شد.
- **هنوز نیازمند CI exact-SHA:** Analyze، تست‌های کامل، گزارش person projection و آزمون persistence واقعی با بازگشایی برنامه. این تغییر به‌تنهایی اثبات نصب یا پذیرش دستگاه نیست.
- **موارد باز:** جریان زنجیره‌ای تاریخ/ساعت و «بدون ساعت» برای Follow-up/Reminder، یکپارچه‌سازی جزء مشترک فیلترهای Home و Report، و ممیزی نهایی Home/تبلت.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ هیچ merge یا release انجام نشود؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاح شکست‌های CI پس از پیوند شخص و سرریز Calendar — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `52205ba2ff5964e34d96acc0b3cb3c2db338890d`

- CI روی SHA `5c522e7`، `flutter analyze` را PASS کرد و persistence file-backed و SQLite close/reopen نیز PASS شدند.
- آزمون `task_detail_followup_flow_test.dart` نشان داد مسیر پیش‌نمایش Task Details ممکن است فاقد provider دیتابیس اشخاص باشد؛ بارگذاری دایرکتوری اکنون fail-soft است و در این حالت فقط افراد پیوندخوردهٔ همان Task را برای بازکردن فرم ارائه می‌کند. مسیر اصلی برنامه همچنان دایرکتوری canonical را از TaskStore می‌خواند.
- آزمون Task Details یک رنگ قدیمی indigo را assert می‌کرد؛ assertion به توکن واقعی `ArvinColors.primary` به‌روزرسانی شد، نه اینکه تست حذف یا شل شود.
- آزمون Calendar در عرض باریک و text scale 1.4 یک سرریز 47px را در سلول‌های هفته نشان داد. ارتفاع ثابت 68px به حداقل ارتفاع تبدیل شد و Column با `MainAxisSize.min` اندازهٔ واقعی محتوا را می‌پذیرد. آزمون دست‌نخورده باقی ماند تا رفع منشأ layout را بررسی کند.
- این اصلاحات نیازمند اجرای مجدد exact-SHA هستند. نتیجهٔ FAIL روی parent SHA حفظ می‌شود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاح تعامل افزودن شخص و واکنش‌گرایی سربرگ فرم — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `35098527149ed94808330108938ec1c531892918`

- کنترل نام شخص به یک Dialog دارای چرخهٔ عمر مستقل منتقل شد؛ در نسخهٔ قبلی controller پیش از پایان unmount شدن TextField آزاد می‌شد و CI خطای `TextEditingController was used after being disposed` ثبت کرده بود.
- سربرگ فرم Task در عرض کمتر از 420px دکمهٔ ذخیرهٔ آیکونی با tooltip نشان می‌دهد تا در بزرگ‌نمایی فونت، Row سربرگ از عرض دستگاه خارج نشود؛ در عرض عریض، دکمهٔ متنی حفظ می‌شود.
- آزمون ارتفاع نوار هفته با پیاده‌سازی واقعی (حداقل 68px) همسو شد؛ انتظار قدیمی 56px دیگر با layout فعلی سازگار نبود. آزمون overflow باریک/فونت بزرگ جداگانه حفظ می‌شود و نتیجهٔ آن فقط پس از CI جدید قابل پذیرش است.
- این تغییرات هنوز نیازمند Analyze و تست‌های exact-SHA هستند.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## حذف وابستگی ناخواستهٔ Task Details به بارگذاری هم‌زمان اشخاص — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `1845c5a071beb7e087d21453a31753db905506d8`

- آزمون‌های CI نشان داد بازکردن فرم ویرایش Follow-up از Task Details به انتظار مستقیم برای `TaskStore.loadPeopleDirectory()` وابسته شده و در مسیرهای isolated/preview تست، فرم باز نمی‌شود.
- دایرکتوری اشخاص اکنون به‌صورت دادهٔ ورودی اختیاری به Task Details تزریق می‌شود؛ مسیر اصلی Home و Report Center آن را از مخزن canonical می‌خوانند. اشخاص پیوندخوردهٔ خود Task نیز در فهرست قرار می‌گیرند و شناسه‌های تاریخی ناموجود با عنوان «شخص حذف‌شده» حفظ می‌شوند.
- افزودن شخص همچنان از `TaskStore.mergePeopleDirectory` استفاده می‌کند؛ خواندن دایرکتوری دیگر در لحظهٔ بازکردن فرم، navigation را متوقف نمی‌کند.
- نیازمند CI exact-SHA جدید است؛ نتایج قبلی به SHAهای خودشان محدود می‌مانند.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## Five-gap implementation checkpoint — ۱۴۰۵/۰۸/۱۵

- Starting HEAD: `4e3136e4dde44bd0b41896265d6ddc6423845046`.
- Code commits: `957f18bf2e5fe8a6f91e950cd963b2a1d03344dd` (direct Task Center, chained date/time and all-day controls) and `eaddf66fd512e11a1e16bb0e056dac4824699d54` (shared Home/Report filter pill and direct Center matching).
- Added focused regression coverage for Task Center/all-day JSON, edit application, personId projection and direct Center report filtering. Exact-head CI remains required; flutter analyze is not yet claimed PASS.
- PR #3052 remains OPEN / DRAFT / UNMERGED. main unchanged. Release remains BLOCKED — RELEASE: NO-GO.
- Detailed evidence: `docs/project-continuity/WAVE_5_GAPS_IMPLEMENTATION_2026-11-06.md`.


## اصلاح انتخاب تاریخ فقط بدون ساعت — ۱۴۰۵/۰۸/۱۵

- در فرم کامل و ثبت سریع، گزینهٔ «بدون ساعت» از حالت بدون تاریخ نیز قابل استفاده است؛ انتخاب تاریخ شمسی بدون بازکردن انتخابگر ساعت انجام می‌شود.
- انتخابگر ساعت در فرم کامل همچنان با انتخاب تاریخ به‌صورت زنجیره‌ای باز می‌شود؛ انتخاب «بدون ساعت» حالت `allDay=true` را نگه می‌دارد و یادآور خودکار ساعت‌دار را حذف می‌کند.
- کامیت: `286485ad1d73231dfb2b7f891803026cf190fd87`.
- آزمون Widget برای مسیر Quick Capture به مجموعهٔ آزمون‌های قرارداد مرکز/پیگیری افزوده شد؛ نتیجهٔ آن فقط پس از CI exact-HEAD قابل تأیید است.


## گزارشات شخص و پیگیری — تکمیل شرط انتظار پاسخ — ۱۴۰۵/۰۸/۱۵

- فیلتر personId در Report Center اکنون فقط تسک‌هایی را برمی‌گرداند که یک Follow-up فعال، تکمیل‌نشده و دارای `waitingForResponse=true` با همان شناسهٔ پایدار شخص داشته باشند.
- ارتباط مستقیم `Task.centerId` در فیلتر Home و Report اولویت دارد؛ در نبود آن، مرکز پروژه‌های متصل بررسی می‌شود.
- آزمون‌های رگرسیون برای تفکیک پیگیری منتظر پاسخ از پیگیری عادی اضافه شده‌اند.
- آخرین SHA کد/آزمون: `3ac5e55841de027b18b8b2daa8f843fde1cae60a`؛ CI exact-HEAD هنوز در انتظار است.
- PR #3052: OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ RELEASE: NO-GO.


## یکپارچه‌سازی رنگ حالت انتخاب‌شده در تم سراسری — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `50b1e99164fea7c03110e2641c786a78f8c94752`

- رنگ انتخاب‌شدهٔ پنج فیلتر Home و پنج فیلتر مشترک Report Center اکنون از `ArvinColors.primary` و `primarySoft` استفاده می‌کند؛ رنگ accent هر بُعد فقط در حالت غیرفعال/نشانهٔ معنایی باقی می‌ماند.
- چیپ‌های فیلتر فعال نیز فیروزه‌ای هستند. `ColorScheme.secondary` و `secondaryContainer` به توکن برند متصل شدند تا ChoiceChipهای Material از رنگ پروژه به‌عنوان رنگ انتخاب استفاده نکنند.
- FAB، NavigationBar، ProgressIndicator و ChipTheme به توکن‌های برند متصل شدند. رنگ‌های معنایی اولویت/وضعیت و رنگ سرمه‌ای SVGهای مقدس تغییر نکردند.
- آزمون widget برای رنگ حالت فعال HomeFilterPill، HomeFilterCard و HomeFilterChip اضافه شد.
- نتیجهٔ Analyze، مجموعهٔ کامل تست‌ها و ساخت APK باید روی SHA نهایی ثبت شود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## Exact HEAD continuation — 2026-11-06 22:24 Asia/Tehran
- Authorized branch advanced through df5295fe2464d99cc5b2abe83515822ee7c136af and 5f8cfefcb849816f3d16936f4b6bbb0f77c4cf68.
- df5295fe: preserve Home no-Center matching, make full-form taxonomy controls responsive at larger text scale, keep Quick Capture priority unset by default, and omit the Gregorian year in the selected-day summary.
- 5f8cfef: align focused regression tests for date-only/time affordance, Semantics time label, RTL wrapping, unset Quick Capture priority, vertical scrollable discovery, scoped Home chip styling and Report Center filter-sheet scrolling.
- These are follow-up hardening/test-contract commits; they do not by themselves close all five gaps or prove device acceptance.
- Exact-HEAD workflows: Build 42274180002 pending; Draft Review APK 42274179979 in progress; Calendar Provider 42274179939 in progress; Device Smoke 42274179896 pending. No PASS is recorded before completion on this exact SHA.
- A prior assistant message showed a sandbox APK path for SHA 7644fc08; that path was not verified in this execution context. Do not treat it as a valid downloadable artifact. New-head APK and APK SHA-256 remain pending artifact publication and verification.
- PR #3052 verified OPEN / DRAFT / UNMERGED at HEAD 5f8cfefcb849816f3d16936f4b6bbb0f77c4cf68. No main update or merge.
- Release remains BLOCKED — RELEASE: NO-GO pending exact-head CI, verified APK artifact and owner physical-device acceptance.


## ۱۴۰۵/۰۸/۱۶ — ریشه‌یابی شکست‌های CI و اصلاحات پاسخ‌گو به لاگ (checkpoint)

- مبنای این ثبت: Build run `42335681385` روی SHA دقیق `d2e27baea747ddedf42f744297be09ab86753294`. مجموع شش شارد: ۱۲۳۴ تست موفق و ۲۴ تست ناموفق؛ شاردها به‌ترتیب `test-5: 2`، `test-4: 3`، `test-3: 7`، `test-2: 2`، `test-1: 9` و `test-0: 1` شکست داشتند. Analyze و Visual موفق بودند؛ شکست شش شارد، نتیجه Build را FAIL کرد.
- تفکیک علت‌ها از لاگ: کلید قدیمی Scroll در تست‌های Home، برچسب قدیمی ساخت پروژه، جست‌وجوی متن Tooltip به‌جای Tooltip finder، انتظار یک ردیف ثابت برای اولویت‌ها و نوع دکمه ذخیره قدیمی، ناسازگاری قرارداد آزمون با رابط فعلی بودند. سرریز ۴ پیکسلی سلول ماه Calendar و سرریز ۵۳ پیکسلی فرم Task Editor خطاهای واقعی layout بودند. خطاهای `No element` و `Too many elements` جداگانه ثبت شدند و تا اجرای مجدد exact-head PASS فرض نمی‌شوند.
- اصلاحات ثبت‌شده روی شاخه مجاز: `84aa643` افزایش ارتفاع سلول ماه به ۴۸dp و هم‌ترازسازی آزمون ایجاد پروژه؛ `8ada195`، `fc5debd` و `f965448` اصلاح قراردادهای آزمون Home/Calendar/Task Editor؛ `9b8e4cd` چیدمان عمودی کنترل تاریخ/ساعت در عرض بسیار باریک یا مقیاس متن بزرگ؛ `79fee1b` کلید پایدار ساخت مرکز/دسته؛ `2a777fe` هم‌ترازسازی آزمون‌های ایجاد درون‌فرمی؛ `52ecbef` افزودن راهنمای زمینه‌ای Calendar و اصلاح finder آزمون رنگ.
- این اصلاحات هنوز PASS محسوب نمی‌شوند؛ اجرای Build جدید برای SHA نهایی لازم است. هیچ تست یا قابلیت حذف، Skip یا عمداً تضعیف نشده است.
- شواهد SHA قدیمی `d2e27ba`: Calendar Provider run `42335681413` SUCCESS؛ Draft Review APK run `42335681420` SUCCESS؛ Device Smoke run `42335681478` CANCELLED. Artifactهای Staging/Debug از Build همان SHA موجودند؛ digest گزارش‌شده GitHub مربوط به ZIP آرشیو است و **SHA-256 خود APK نیست**.
- SHA فعلی این ثبت: `52ecbef18d7bbc26d2915270e28297d272342634`. Build `42336933347` و Device Smoke `42336933508` در صف و بدون Job؛ Draft Review APK `42336933225` در حال اجرا؛ Calendar Provider `42336933308` در حال اجرا پس از تأیید SHA؛ Follow-up Persistence `42336934664` در حال اجرا. هیچ‌یک هنوز PASS نیستند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ Merge و انتشار انجام نشده؛ **BLOCKED — RELEASE: NO-GO** تا قبولی همه دروازه‌ها روی یک SHA، Device Smoke کامل و پذیرش روی گوشی واقعی.


## اصلاحیه وضعیت exact-HEAD — ۱۴۰۵/۰۸/۱۶

- پس از ثبت checkpoint قبلی، دو اصلاح تکمیلی آزمون ثبت شد: آزمون تاریخ تقویم تعداد دو نمایش معتبر تاریخ را صریحاً می‌سنجد؛ آزمون رنگ Home تمام لایه‌های AnimatedContainer کارت را بررسی می‌کند، نه یک لایهٔ تصادفی.
- آخرین SHA کد/آزمون پیش از همگام‌سازی اسناد: `0d6ac9f44debc6ca6955f8940826979604f3636b`. این ثبت اسناد، commit بعدی و فقط مستندسازی است؛ هیچ نتیجه CI از SHA قبلی به HEAD مستندات منتقل نمی‌شود.
- برای HEAD نهایی پس از این ثبت، Build شش‌شارد، Draft Review APK، Calendar Provider، Follow-up Persistence و Device Smoke باید دوباره اجرا و جداگانه بررسی شوند.
- اصلاحات کد و آزمون تا این نقطه ثبت شده‌اند؛ **رفع‌شدن شکست‌ها هنوز تأیید CI ندارد**. آزمون گوشی واقعی و پذیرش مالک محصول نیز انجام/اثبات نشده‌اند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ بدون Merge و انتشار؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاحیه تکمیلی Home — ۱۴۰۵/۰۸/۱۶

- commit کد/آزمون بعد از checkpoint قبلی: `467e7f76aced41a123f00a99dd334f32f09ad70c`.
- آزمون Quick Capture اکنون رفتار واقعی محصول را بررسی می‌کند: پس از ثبت، فرم عمداً باز می‌ماند؛ ابتدا ذخیره و حفظ تاریخچه از Store بررسی می‌شود، سپس فرم بسته و نمایش Task در Home تأیید می‌شود.
- Finder پیمایش آزمون کارت Home به Scrollable داخل `home-task-list-viewport` محدود شد تا به Scrollable نامرتبط/غایب در بخش‌های دیگر وابسته نباشد.
- این تغییرات فقط اصلاح آزمون بر اساس قرارداد فعلی‌اند؛ بررسی ذخیره واقعی، حفظ تاریخچه و نمایش Home همچنان باید با اجرای تازه Build روی HEAD نهایی تأیید شوند.
- آخرین نتایج قبلی Build متعلق به SHA `d2e27ba` هستند و برای این commit یا HEAD بعدی اعتبار ندارند. وضعیت انتشار همچنان **BLOCKED — RELEASE: NO-GO** است.


## اصلاحیهٔ هدف لمس Quick Add — ۱۴۰۵/۰۸/۱۶

- آخرین commit کد/آزمون: `c0b3715f16b4fd46e67a2c157559f1de71e2d812`.
- چهار گزینهٔ اولویت Quick Add از ارتفاع ۴۰dp به ۴۸dp رسیدند تا حداقل هدف لمس ۴۸dp رعایت شود.
- ماتریس آزمون Quick Add اکنون عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp را با مقیاس متن بزرگ بررسی می‌کند و برای هر چهار گزینه، عرض و ارتفاع حداقل ۴۸dp را assert می‌کند.
- این تغییر به‌همراه اصلاحات قبلی Calendar و Task Editor هنوز در انتظار اجرای مجدد روی HEAD نهایی است؛ تا دریافت نتیجه، PASS محسوب نمی‌شود.
- وضعیت انتشار: **BLOCKED — RELEASE: NO-GO**؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched.


---

## ابلاغ Master و وضعیت اجرایی — ARVIN-DIR-1405/08/16-02-MASTER
**ثبت: ۱۴۰۵/۰۸/۱۶ | شاخه مجاز PR #3052**

- PRODUCT FIRST: نقص محصول در کد محصول رفع می‌شود؛ هیچ آزمونی حذف، Skip یا تضعیف نمی‌شود. اصلاح Finder فقط برای قرارداد واقعاً منسوخ و با حفظ پوشش رفتاری مجاز است.
- فونت یگانه رابط: **Vazirmatn**؛ بررسی `pubspec.yaml`، `lib/theme/app_fonts.dart` و `lib/theme/font_registry.dart` فقط همین خانواده را نشان می‌دهد.
- تم روشن فیروزه‌ای: Primary `#078B91`، Header `#066F75`، Soft `#DDF7F5`، Background `#F0FAF9`، Border `#D9ECEA`. رنگ‌های خطا/اولویت و وضعیت برای معنای وضعیت حفظ می‌شوند.
- SVG بسم‌الله با عرض نمایشی `210dp` حفظ شده؛ آزمون عرض ۲۱۰dp اضافه شده است.
- ترتیب فیلترهای Home: زمان ← مرکز ← پروژه ← دسته ← برچسب؛ مرتب‌سازی جدا و پس از پنج فیلتر است؛ Wrap راست‌به‌چپ و بدون پیمایش افقی.
- «پیگیری‌های انجام‌شده» فقط از بخش «نوع گزارش» در پنل فیلترها انتخاب می‌شود؛ دکمهٔ بالای صفحه وجود ندارد و آزمون آن را کنترل می‌کند.
- Calendar: محتوای سلول ماه درون سلول مقیاس می‌شود و هدف لمس حداقل ۴۸dp حفظ می‌شود؛ ارتفاع اضافهٔ نمای هفتگی کاهش یافته است.
- Task Editor و Quick Capture برای ۳۶۰/۳۹۰/۴۱۲dp، کیبورد باز/بسته و متن بزرگ پوشش آزمون دارند؛ کنترل‌های اولویت Quick Add حداقل ۴۸dp هستند.
- ایجاد مرکز/دسته/برچسب در Quick Capture دیگر کنترل متن موقت را پیش از پایان انیمیشن Sheet آزاد نمی‌کند؛ Sheetها قابل پیمایش‌اند.
- کامیت‌های کد/آزمون: `9de8f221`, `7125e828`, `895c7ad`, `21606a9`, `9946f15`, `4a64d50`, `4f65800`.
- Build روی SHA قبلی `21606a9f3050337d57c0ada2ca4c14c2febe907f` به‌علت توکن تعریف‌نشدهٔ `ArvinTheme.primarySoft` در Analyze/Visual و شاردها شکست کامپایل داشت؛ Follow-up Persistence run `42339727992` نیز به همان علت شکست خورد. توکن مرکزی در commit `4a64d50` تعریف شد؛ نتایج SHA قدیمی به SHA جدید منتقل نمی‌شوند.
- آخرین کد/آزمون پیش از این ثبت: `4f65800612bd0cce95448f39eee67d683e0e6504`. اجرای اختصاصی این SHA هنوز در فهرست GitHub ظاهر نشده؛ هیچ PASS برای آن ادعا نمی‌شود.
- فایل مستقل Master در پیوست‌های این گفتگو یا جست‌وجوی Library پیدا نشد؛ این یادداشت بر متن ابلاغ‌شده در گفتگو متکی است، نه بر ادعای مطالعهٔ فایل پیوست‌نشده.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` بدون تغییر؛ Merge و انتشار ممنوع. Device Smoke و پذیرش نصب واقعی هنوز مانع‌اند.
- **BLOCKED — RELEASE: NO-GO** تا Build، تمام شاردها، Provider، Persistence، Device Smoke و پذیرش گوشی واقعی روی یک SHA واحد PASS شوند.


## پیوست اصلاحیه Master — ۱۴۰۵/۰۸/۱۶

- کامیت تکمیلی محصول پس از ثبت قبلی: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`.
- سطح خالی کارت‌های فیلتر و لهجهٔ سربرگ پنل فیلتر نیز به توکن فیروزه‌ای/سطح خنثی مشترک منتقل شد؛ رنگ‌های برند غیر فیروزه‌ای در کنترل‌های فیلتر باقی نماند.
- آخرین کد پیش از این به‌روزرسانی اسناد: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`. نتیجهٔ CI این SHA تا لحظهٔ ثبت این پیوست هنوز قابل تأیید نیست؛ PASS از SHAهای قبلی به آن منتقل نمی‌شود.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ بدون Merge/انتشار؛ **BLOCKED — RELEASE: NO-GO**.

## checkpoint اجرای ARVIN-DIR-1405/08/16-02-MASTER — ۱۴۰۵/۰۸/۱۶
- ممیزی زنده شاخه و PR تأیید کرد HEAD هر دو 2553f27f040287b0cf225a4c054777db94821679 است.
- PR #3052 برابر OPEN / DRAFT / UNMERGED است؛ base=main و main در این عملیات تغییر نکرده است.
- Build run 42340630768 روی همین SHA شکست خورد: Analyze و Visual موفق؛ سه شارد test-0، test-1 و test-2 ناموفق؛ APKهای Debug/Release/Staging ساخته شدند.
- شکست‌های ثبت‌شده: انتظار رنگ بنفش قدیمی در نوار هفته در برابر رنگ فیروزه‌ای مصوب؛ انتظار رنگ سرمه‌ای SVG در حالی که رندر فعلی فیروزه‌ای است؛ دو assertion ناسازگار با تمایز توکن‌های معنایی؛ جابه‌جایی مورد انتظار در Home filter groups؛ Quick Capture history count؛ و اندازه‌گیری گام پیمایش تقویم. این موارد هنوز تفکیک/اصلاح محصول در برابر آزمون نشده‌اند و PASS نیستند.
- Calendar Provider 42340630862 و Draft Review APK 42340630793 موفق‌اند؛ Device Smoke 42340630785 هنوز PENDING و فاقد Job قابل اجراست.
- Device Smoke قدیمی #7233 / run 42335301964 با SHA قدیمی 1c8f0a5c66c2e24b96f84281466ed784d83f17b5 هنوز QUEUED است؛ Workflow از cancel-in-progress: false استفاده می‌کند. برای آزادسازی صف، لغو دستی آن توسط مالک لازم است.
- قرارداد زمان کار/موعد در این checkpoint به‌صورت تصمیم APPROVED ثبت شد؛ پیاده‌سازی ویجت مشترک، جایگزینی فرم‌ها، آزمون‌های رفتاری و پذیرش آن هنوز NOT VERIFIED هستند. هیچ ادعای پیاده‌سازی یا قبولی برای این بخش ثبت نمی‌شود.
- وضعیت انتشار بدون تغییر: **BLOCKED — RELEASE: NO-GO** تا همه دروازه‌ها روی یک SHA و پذیرش APK روی دستگاه واقعی.

## اصلاحیه HEAD پس از ثبت تصمیم زمان کار / موعد — ۱۴۰۵/۰۸/۱۶
- commit مستندسازی: 70b32df0bb903b3647a206fd63dc15e94f0df78e؛ تغییرات فقط در PRODUCT_DECISIONS.md، CURRENT_STATE.md و CHANGELOG.md است.
- HEAD فعلی شاخه و PR #3052 اکنون 70b32df0bb903b3647a206fd63dc15e94f0df78e است؛ PR همچنان OPEN / DRAFT / UNMERGED و base=main است.
- این commit صرفاً مستندسازی تصمیم محصول است؛ کد ویجت مشترک و اتصال فرم‌ها در این commit تغییر نکرده‌اند.
- برای SHA جدید هنوز Workflow run ثبت نشده است؛ بنابراین تمام نتایج Build/Provider/Smoke/APK قبلی فقط به SHA 2553f27f040287b0cf225a4c054777db94821679 تعلق دارند و به HEAD جدید منتقل نمی‌شوند.
- Device Smoke قدیمی #7233 همچنان مانع صف است و لغو دستی آن توسط مالک لازم است.
- **BLOCKED — RELEASE: NO-GO** بدون تغییر باقی می‌ماند.

## ممیزی زنده exact-HEAD — ۱۴۰۵/۰۸/۱۶ (GitHub، PR #3052)
- HEAD شاخه و PR در لحظهٔ ممیزی: 11919b87b309897a7b2f59fdd34a327730188e6e؛ main: 45e4202b03a434459e4c021a04efa7e8396359db. PR #3052 OPEN / DRAFT / UNMERGED، base=main. main تغییر نکرد.
- اجرای exact-HEAD: Build run 42343978253 FAILED؛ Calendar Provider 42343978239 SUCCESS؛ Device Smoke 42343978229 PENDING و بدون Job؛ Draft Review APK run 42343978230 SUCCESS.
- Build: Analyze و Visual موفق؛ APKهای Debug، Release و Staging ساخته شدند؛ test-0: 220 passed / 2 failed؛ test-1: 182 passed / 2 failed؛ test-2: 302 passed / 2 failed.
- شکست‌های دقیق: test/widgets/home_quick_capture_test.dart «Home primary add persists canonical task and preserves history» انتظار ۲ Task، فقط Task قبلی را دید و tap هشدار hit-test داشت؛ test/calendar_view_modes_test.dart ارتفاع نمای ماه ۳۱۸ در برابر سقف آزمون ۲۸۰؛ test/issue_1891_lane_d_rollbox_test.dart انتظار تفاوت توکن‌های معنایی درحالی‌که توکن‌های تعاملی همگی فیروزه‌ای‌اند؛ test/calendar_page_test.dart انتظار پس‌زمینه بنفش قدیمی به‌جای #DDF7F5؛ test/home/home_filter_contract_test.dart اختلاف جایگاه فیلتر آخر و دکمه مرتب‌سازی (۲۰۲٫۵ در برابر ۳۰۳٫۵)؛ test/calendar_page_test.dart انتظار ColorFilter سرمه‌ای #1A2B4C در برابر فیروزه‌ای #078B91. هیچ‌کدام هنوز رفع یا با تغییر آزمون تعیین تکلیف نشده‌اند.
- Runهای قبلی 42340630768 / 42340630862 / 42340630785 / 42340630793 همگی متعلق به SHA قدیمی 2553f27f040287b0cf225a4c054777db94821679 هستند؛ به HEAD فعلی قابل انتساب نیستند.
- Device Smoke قدیمی #7233 / run 42335301964 با SHA 1c8f0a5c66c2e24b96f84281466ed784d83f17b5 هنوز QUEUED است؛ Job «calendar-segmented-view» IN_PROGRESS و پنج Job دیگر QUEUED هستند. Workflow concurrency با cancel-in-progress=false صف را خودکار آزاد نمی‌کند. لغو دستی این Run توسط مبین لازم است. Run جدید 42343978229 نیز PENDING و بدون Job است.
- بررسی commit 895c7ad12212074e9798400a1a6b3e15ca7ede15: تست‌های عرض ۳۶۰/۳۹۰/۴۱۲dp و کیبورد باز/بسته افزوده شدند؛ حداقل لمس ۴۸dp افزوده شد؛ تست Home از پیمایش افقی به Wrap راست‌به‌چپ و نبود پیمایش افقی تغییر کرد. تستی حذف یا Skip نشده؛ تغییر Finder برای محدود کردن دامنهٔ جست‌وجو است. این commit پوشش را تضعیف نکرده است.
- کد فعلی: رنگ‌های اصلی دقیقاً با پالت مصوب هماهنگ‌اند؛ Vazirmatn برقرار است؛ پنج فیلتر Home و منطق چندانتخابی OR/AND موجود است؛ اتصال اشخاص به FollowUp منتظر پاسخ و فیلتر اشخاص گزارش در سورس موجود است.
- شکاف‌های زمانی سورس: Time Picker فعلی گزینه «بدون ساعت» داخل دیالوگ ندارد؛ Quick Capture دکمه بدون ساعت را بیرون دیالوگ دارد؛ Task Editor کنترل بدون ساعت جدا دارد؛ یادآور مستقل تاریخ/ساعت و چک‌باکس جدا دارد. HomeGroupingService معوق‌شدن را فقط با قبل‌بودن روز بررسی می‌کند و موعد ساعت‌دارِ گذشته در همان روز را معوق نمی‌کند. این موارد پیاده‌سازی/تست نشده‌اند.
- Draft Review artifact برای exact-HEAD در دسترس و استخراج شد: APK با اندازه 79,103,825 بایت، applicationId=com.example.arvin.staging، امضای v2/v3 معتبر، کلید موقت review-only و غیرقابل انتشار. SHA-256 بایت‌های خود APK: cdd8cc9e7b478e8fe485cfac6465f265b3c1b3ae501f78abc40edbbfa80814d6. این فایل فقط برای بررسی خصوصی است؛ نصب روی SM-A528B/DS انجام نشده.
- تصمیم و وضعیت: رنگ‌ها، فیلترها و پیگیری شخصی از قبل در سورس حاضرند؛ زمان مشترک/All-Day داخل دیالوگ و Overdue دقیق هنوز کامل نیست. **BLOCKED — RELEASE: NO-GO**.

## وضعیت اجرایی exact-HEAD — ۱۴۰۵/۰۸/۱۶ (به‌روزرسانی کنترل زمان)
- HEAD شاخه و PR #3052: 26e635265593a10afc43759c6457220ccb8f084a; main: 45e4202b03a434459e4c021a04efa7e8396359db. PR OPEN / DRAFT / UNMERGED؛ main بدون تغییر.
- روی والد قبلی ae9a6db230032f4f74883e903833b8c323be4fd5، Runهای 42346709560 (Build) و 42346709549 (Device Smoke) در PENDING؛ 42346709502 (Calendar Provider) و 42346709491 (Draft Review APK) در حال اجرا بودند؛ Follow-up File Persistence run 42346709492 و G1 lock sync run 42346709506 موفق بودند. این نتایج به HEAD فعلی منتقل نمی‌شوند.
- برای HEAD فعلی 26e635265593a10afc43759c6457220ccb8f084a در زمان ثبت، Run تازه‌ای در فهرست Actions مشاهده نشد؛ بنابراین وضعیت همهٔ دروازه‌ها روی این SHA UNKNOWN / NOT RUN است.
- Run قدیمی Device Smoke #7233 / 42335301964 اکنون COMPLETED / CANCELLED است؛ مانع قدیمی صف برداشته شده و درخواست لغو دستی دیگری لازم نیست. Device Smoke جدید همچنان باید روی HEAD فعلی اجرا و PASS شود.
- اصلاح منطق Overdue در ae9a6db: ساعت مرجع تزریق‌پذیر شد؛ موعد ساعت‌دار پس از عبور لحظهٔ موعد معوق می‌شود؛ All-Day تا شروع روز بعد معوق نمی‌شود؛ کار انجام‌شده معوق نمی‌شود. آزمون رگرسیون اضافه شده است؛ CI آن هنوز تأیید نشده.
- کنترل زمان جدید: نتیجهٔ صریح All-Day داخل دیالوگ ساعت گرد؛ Quick Capture و Task Details برای موعد سفارشی به آن متصل‌اند؛ TaskReminderهای مستقل نیز از آن استفاده می‌کنند. legacy Task.reminderDate و FollowUp.reminderDate هنوز All-Day مستقل ندارند.
- آخرین APK استخراج‌شده و هش قبلی فقط متعلق به SHA 11919b87b309897a7b2f59fdd34a327730188e6e است؛ هش آن نباید به HEAD فعلی نسبت داده شود. APK exact-HEAD فعلی هنوز در دسترس نیست.
- تغییرات آزمون 895c7ad همچنان به‌عنوان افزایش پوشش Wrap/حداقل لمس ارزیابی شده‌اند؛ تستی حذف یا Skip نشده است. تغییرات جدید زمان نیز فقط تست‌های افزوده‌اند.
- **BLOCKED — RELEASE: NO-GO** تا پاس کامل Build/تمام شاردها/Provider/Persistence/Device Smoke روی یک SHA، بررسی APK همان SHA و تست نصب و کارکرد روی SM-A528B/DS.

## اصلاحیه وضعیت — یادآور تمام‌روز و HEAD کد
- آخرین HEAD کد پیش از ثبت این اصلاحیه: d969728523d402a72647f608e635dd1c42ed54ab؛ PR #3052 همچنان OPEN / DRAFT / UNMERGED؛ main=45e4202b03a434459e4c021a04efa7e8396359db و بدون تغییر.
- FollowUpEntryPage میانبر یادآور مستقل را به انتخاب پیوستهٔ تاریخ شمسی و ساعت گرد متصل کرد؛ All-Day داخل دیالوگ انتخاب و به TaskReminder.isAllDay ذخیره می‌شود. اعلان تمام‌روز طبق planner در ۰۹:۰۰ محلی است.
- یادآورهای مستقل TaskReminder در Task Details نیز به همین قرارداد متصل‌اند. Quick Capture برای موعد سفارشی از All-Day پشتیبانی می‌کند.
- شکاف‌های باقی‌مانده: فیلد legacy Task.reminderDate و FollowUp.reminderDate هنوز پرچم All-Day ندارند؛ کنترل‌های قدیمی مربوط به آن‌ها باید با قرارداد مهاجرت سازگار تکمیل شوند. فیلترهای گزارش/پشتیبان‌گیری ساعت‌محورند و گزینهٔ All-Day در آن‌ها موضوعیت ندارد.
- اجرای Device Smoke قدیمی #7233 / 42335301964 CANCELLED است؛ اما اجرای قدیمی‌تر Device Smoke شماره 7268 / run 42346612483 روی SHA db91... پس از انتظار وارد اجرای فعال شده و اجرای جدیدتر را در صف نگه می‌دارد. این run قدیمی‌تر را نباید PASS برای HEAD جدید شمرد؛ اجرای جدید باید پس از پایان آن روی SHA فعلی شروع شود.
- Build روی SHA 844b794... هنوز PENDING و بدون Job بود؛ Calendar Provider، Draft Review APK و Persistence در حال اجرا بودند؛ Persistence سپس SUCCESS شد. این SHA پیش از تغییر یادآور پیگیری است و نتیجهٔ آن به HEAD d969... منتقل نمی‌شود.
- برای HEAD d969728... در لحظهٔ ثبت، Run جدیدی در Actions مشاهده نشد؛ بنابراین دروازه‌های آن UNKNOWN / NOT RUN هستند.
- **BLOCKED — RELEASE: NO-GO** تا Build/تمام شاردها/Provider/Persistence/Device Smoke و نصب و آزمون واقعی گوشی SM-A528B/DS روی یک SHA واحد PASS شوند.

## جدول شکست‌های قبلی و اصلاحات — exact evidence path
- کد/آزمون فعلی پیش از ثبت اسناد: 7a1890fa8c1933fb230cdfa92dcd762209eae95c؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main=45e4202b03a434459e4c021a04efa7e8396359db.
- جدول شکست‌های Build run 42343978253 روی SHA 11919b87b309897a7b2f59fdd34a327730188e6:
  1. Home Quick Capture: hit-test روی دکمه افزودن خارج از viewport پیش‌فرض 800×600 بود و تست فقط یک Task دید؛ fixture اکنون 390×844 و ensureVisible دارد؛ assertion حفظ تاریخچه و ثبت دو Task باقی است.
  2. Calendar month: شش ردیف 48dp با header/spacing حدود 318dp است؛ انتظار کمتر از 280dp با حداقل هدف لمس 48dp ناسازگار بود. آزمون اکنون حداقل 288 و حداکثر 320dp را assert می‌کند؛ حداقل 48dp هر روز حفظ شده است.
  3. RollBox semantic colors: تست قدیمی توکن‌های تعاملی متمایز می‌خواست؛ تصمیم محصول رنگ تعاملی یکسان فیروزه‌ای است. تست اکنون تمام توکن‌های time/reminder/project/category/tag را به primary، primaryDark و primarySoft مقایسه می‌کند.
  4. Calendar selected week day: انتظار بنفش قدیمی بود؛ تست اکنون #DDF7F5 مصوب را می‌سنجد.
  5. Home filter/sort: مرتب‌سازی در سمت راست فیلترها قرار گرفته بود؛ کنترل به سمت چپ منتقل شد تا بعد از پنج فیلتر در ترتیب RTL باشد.
  6. Calendar sacred SVG: رنگ روشن به primary فیروزه‌ای تغییر کرده بود؛ رنگ برند #1A2B4C در تم روشن بازگردانده شد؛ تم تاریک همچنان onSurface است و خود SVG دست‌نخورده است.
- خطای بیلد موقت در SHA 068d8489821463f5f8f55cd69a74496f94192656: ArvinTimeSelection در _pickReminderTime به DateTime? انتساب داده شده بود. در commit 26e635265593a10afc43759c6457220ccb8f084a، فیلد legacy Task.reminderDate با wrapper زمان‌محور سازگار شد؛ All-Day فقط در مدل‌های دارای پرچم مستقل ثبت می‌شود.
- اصلاح Overdue: ae9a6db230032f4f74883e903833b8c323be4fd5؛ ساعت‌دار پس از لحظه موعد، All-Day از ابتدای روز بعد و completed هرگز overdue نمی‌شود.
- تغییر 895c7ad ممیزی شد: در همان فایل‌های تست، ۵۵ خط افزوده و ۱۱ خط قدیمی با قرارداد Wrap/ماتریس عرض جایگزین شد؛ تست پیمایش افقی به نبود Scroll افقی و Wrap RTL تبدیل شد؛ هیچ تستی حذف/Skip یا assertion رفتاری تضعیف نشد.
- روی SHA کد 7a1890f، Runهای Build 42347751661 و Device Smoke 42347751648 در PENDING؛ Calendar Provider 42347751668، Draft Review APK 42347751728 و Follow-up Persistence 42347751664 در حال اجرا بودند. این نتایج تا پایان اجرا نهایی نیستند.
- گلوگاه صف: #7233 / 42335301964 CANCELLED؛ اما #7268 / 42346612483 روی SHA قدیمی db91a78 هنوز در وضعیت کلی QUEUED است، درحالی‌که job smoke-boot در IN_PROGRESS و شش lane دیگر QUEUED هستند. این اجرای قدیمی، Device Smoke جدید را پشت خود نگه می‌دارد؛ اگر ادامه یابد، لغو دستی توسط مبین لازم است.
- شکاف‌های باقی‌مانده محصول: یادآور legacy Task.reminderDate و FollowUp.reminderDate هنوز All-Day مستقل ندارند؛ سلکتورهای مرکز/پروژه/دسته/برچسب در Task Details هنوز از ArvinRollBox استفاده می‌کنند و هم‌شکلی کامل آن‌ها با HomeFilterPill در UI واقعی تأیید نشده است.
- **BLOCKED — RELEASE: NO-GO** تا Build تمام شاردها، Calendar Provider، Persistence، Device Smoke و APK exact-HEAD سبز شوند و APK روی SM-A528B/DS نصب و آزمون شود.


## وضعیت تجمیعی جدید — ۱۴۰۵/۰۸/۱۶
- HEAD کد پیش از این ثبت مستنداتی: `72963f7f69f9dc5e4846f52880e2a5deb283815d`. PR #3052 روی همین شاخه OPEN / DRAFT / UNMERGED است؛ main روی `45e4202b03a434459e4c021a04efa7e8396359db` بدون تغییر مانده است.
- اجرای Device Smoke قدیمی #7268 / `42346612483` اکنون CANCELLED است. اجرای تازه روی HEAD کد `72963f7...` با شماره #7299 / `42350206655` ثبت شده، اما هنوز PENDING است و Job دستگاه شروع نشده است.
- دروازه‌های ثبت‌شده روی SHA کد `72963f7...`: Build #10066 / `42350206647` PENDING؛ Calendar Provider #2201 / `42350206625` QUEUED؛ Follow-up Persistence #1224 / `42350206608` PENDING؛ G1 Lock #4693 / `42350206596` QUEUED؛ Draft Review APK #873 / `42350206660` PENDING؛ Device Smoke #7299 PENDING. هیچ‌کدام هنوز PASS نهایی نیستند.
- Build قبلی #10044 روی SHA قدیمی `f69ef3ae...` به علت دو شکست تست (ترتیب فیلترهای Home و تست قدیمی کنترل بدون ساعت) FAILED شد. کد و آزمون‌ها اصلاح شده‌اند؛ این اصلاحات تا پاس Build تازه روی SHA جدید VERIFIED محسوب نمی‌شوند.
- All-Day legacy: فیلدهای `Task.reminderDate` و `FollowUp.reminderDate` اکنون پرچم‌های مستقل `reminderAllDay` دارند؛ JSON round-trip و مهاجرت Task به `TaskReminder.isAllDay` پوشش داده شده است. ویرایش یادآور legacy در فرم Task و فرم FollowUp گزینه «بدون ساعت» را داخل دیالوگ ساعت می‌دهد. نیمه‌شب بدون پرچم صریح همچنان زمان‌دار باقی می‌ماند.
- Selectorهای مرکز/پروژه/دسته/برچسب در Task Editor اکنون از Sheet مشترک با فیلترهای Home استفاده می‌کنند؛ سه مورد نخست انتخاب تک‌گزینه‌ای و برچسب چندگزینه‌ای است؛ ایجاد مورد جدید حفظ شده است. رنگ pill و Wrap RTL نیز همسان شده‌اند.
- APK review-only قبلی متعلق به SHA `f69ef3ae...` است و برای HEAD جدید قابل استفاده/استناد نیست. آرتیفکت Draft Review روی SHA فعلی هنوز تولید/دریافت نشده است؛ پس از موفقیت Run exact-head استخراج و SHA-256 بایت APK جداگانه ثبت می‌شود.
- هیچ تست فیزیکی روی Samsung SM-A528B/DS هنوز ثبت نشده است.
- **BLOCKED — RELEASE: NO-GO** تا پاس تمام دروازه‌ها روی یک SHA نهایی، APK همان SHA، نصب و آزمون واقعی گوشی و تأیید مالک.


## اصلاحیهٔ پس از تکمیل فرم یادآور legacy پیگیری — ۱۴۰۵/۰۸/۱۶
- تکمیل کد پیش از این اصلاحیه: `de60c3a53309183a69b3a94b2f74e2ae9b40d7cb`.
- فرم ویرایش FollowUp اکنون یادآور قدیمی را قابل انتخاب/حذف می‌کند؛ انتخاب تاریخ شمسی و سپس «بدون ساعت» داخل دیالوگ ساعت، `reminderAllDay` را ذخیره می‌کند. لغو هر مرحله مقدار قبلی را حفظ می‌کند.
- تست UI برای حفظ یادآور قبلی و انتخاب All-Day در FollowUp افزوده/به‌روزرسانی شد. مدل Task نیز در JSON از ذخیرهٔ پرچم All-Day بدون تاریخ جلوگیری می‌کند.
- این ثبت مستنداتی HEAD شاخه را تغییر می‌دهد؛ تمام دروازه‌ها باید روی SHA نهایی همین ثبت دوباره بررسی شوند. نتایج SHAهای قبلی به آن منتقل نمی‌شوند.
- **BLOCKED — RELEASE: NO-GO** تا PASS روی SHA نهایی، APK همان SHA و تست نصب/عملکرد روی SM-A528B/DS.

## Layout Fix: Enforced Single-Row Filter — ۱۴۰۵/۰۸/۱۶
- علت رگرسیون: پنج HomeFilterPill در ArvinTaskSelectorWrap (Wrap) قرار داشتند؛ در عرض محدود موبایل به ردیف دوم می‌شکستند و تست قدیمی نیز پیمایش افقی را انجام می‌داد.
- اصلاح در `lib/main.dart`: فیلترهای زمان، مرکز، پروژه، دسته و برچسب اکنون در یک Row با `mainAxisSize: MainAxisSize.max`، `mainAxisAlignment: MainAxisAlignment.spaceBetween` و پنج `Expanded` قرار گرفته‌اند؛ فاصله‌ها ۴dp است و پیمایش افقی/Wrap در این ردیف وجود ندارد.
- اصلاح در `lib/home/home_filter_ui.dart`: HomeFilterPill به کنترل فشرده با ارتفاع ثابت ۴۸dp، آیکون ۱۴dp، متن تک‌خطی و کوچک‌سازی متن در فضای محدود تبدیل شد. حداقل سطح لمس ۴۸dp حفظ شده است.
- آزمون `test/home/home_filter_contract_test.dart` اکنون عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp را بررسی می‌کند: هر پنج فیلتر باید top/bottom یکسان، ارتفاع حداقل ۴۸dp، قرارگیری داخل عرض و نبود Scrollable افقی داشته باشند. مسیر انتخاب فیلترها بدون drag افقی آزمایش می‌شود.
- این اصلاح در زمان ثبت مستندات کد است و تا اجرای موفق تست/CI روی SHA نهایی VERIFIED محسوب نمی‌شود. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main بدون تغییر.
- **BLOCKED — RELEASE: NO-GO** تا اجرای exact-HEAD CI و پذیرش دستی دستگاه.

## Quick Add + Task Editor — پنج فیلتر تک‌ردیفه و All-Day فقط داخل ساعت — ۱۴۰۵/۰۸/۱۶

- **Quick Add:** کنترل مستقل `quick-capture-no-time` و مسیر جداگانهٔ `_pickDateOnlyDue` حذف شد. گزینهٔ All-Day برای موعد سفارشی فقط از `universal-time-no-time` داخل دیالوگ ساعت مشترک انتخاب می‌شود؛ منطق ذخیرهٔ `Task.allDay` و حذف یادآور خودکار برای موعد تمام‌روز حفظ شده است.
- پنج فیلتر Quick Add اکنون در `lib/quick_capture_dialog.dart` با یک `Row` راست‌به‌چپ و پنج `Expanded` قرار دارند؛ ترتیب از راست به چپ: زمان، مرکز، پروژه، دسته، برچسب. فاصلهٔ افقی ۴dp است و هیچ Wrap یا پیمایش افقی در این ردیف وجود ندارد.
- **Task Editor / ویرایش کار:** ردیف جداگانهٔ تاریخ انجام و Wrap چهار سلکتور با یک ردیف پنج‌تایی در `lib/task_editor_dialog.dart` جایگزین شد. فیلتر زمان، تاریخ شمسی و ساعت را از مسیر انتخابگر یکپارچه باز می‌کند؛ مرکز، پروژه، دسته و برچسب در همان ردیف هستند. All-Day موعد فقط از گزینهٔ داخل دیالوگ ساعت انتخاب می‌شود؛ کنترل بیرونی «بدون ساعت» در این مسیر وجود ندارد.
- همهٔ پنج کنترل در هر دو صفحه از `ArvinRollBox` و `HomeFilterPill` مشترک استفاده می‌کنند؛ ارتفاع هدف لمس ۴۸dp حفظ شده است. سایر بخش‌های فرم، ذخیره‌سازی، روابط مرکز/پروژه، یادآورها و انتخاب چندبرچسبی تغییر قراردادی نکرده‌اند.
- آزمون‌های `test/quick_capture_dialog_test.dart` و `test/task_editor_dialog_test.dart` برای عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp به‌روزرسانی شدند: هم‌ترازی عمودی پنج فیلتر، ارتفاع حداقل ۴۸dp، ترتیب RTL، قرارگیری در محدودهٔ ردیف و نبود کنترل بیرونی «بدون ساعت» بررسی می‌شود. تست‌های جریان All-Day همچنان انتخاب `universal-time-no-time` داخل دیالوگ را بررسی می‌کنند.
- کامیت‌های اجرایی این اصلاح: Quick Add source `4ec4a5173c53092f4eb1fc8c172190becebc24dd`؛ Task Editor source `bdf6abf9ba5833a1bc6fab38599f8135a45c2acf`؛ Quick Add tests `b4bafd504316c573dacd26657beefff25bedcb7d`؛ Task Editor tests `7cf1a7d49dff277d0eafde4d7cff6f9d1a2d93aa`.
- نتیجهٔ CI روی SHA قبلی `1437c79e3a1528a91895b51b06f675bcaeeb29f4` فقط متعلق به همان کد قبلی است و برای این اصلاح اعتبار ندارد. اجرای تازهٔ Build، Device Smoke، Calendar Provider، Persistence و Draft Review APK باید روی SHA نهایی پس از ثبت این مستندات بررسی شود. تست فیزیکی روی Samsung SM-A528B/DS نیز هنوز تأیید نشده است.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ شاخهٔ `main` بدون تغییر؛ هیچ Merge، انتشار یا تحویل APK به‌عنوان نسخهٔ قابل انتشار مجاز نیست. **BLOCKED — RELEASE: NO-GO**.


## 2026-11-07 — ادامه اصلاح تجربه کاربری تم و کنترل‌های زمان (شواهد پذیرش در انتظار)

**Source checkpoint before documentation sync:** `9e66820d161131b947bcc91cf333b3acf426a51c`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31` · **PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO

### تغییرات ثبت‌شده
- پالت انتخابی کاربر در `AppThemeManager` بدون تغییر باقی مانده است: گزینه ۸ و پیش‌فرض `#3A86EF`. توکن‌های پایهٔ فیروزه‌ای رابط (`#078B91`، `#066F75`، `#DDF7F5`) از رنگ انتخابی کاربر جدا شده‌اند؛ این کار پیش‌فرض پالت را تغییر نمی‌دهد و سطوح روشن/فیروزه‌ای را از accent انتخابی مستقل نگه می‌دارد. Source: `lib/core/theme/arvin_theme.dart`، commit `a58098c0a6a6afcc55ec194a751961fd1bad9848`.
- رنگ زندهٔ Theme به Home filter pill/card/chip و sheet، پوستهٔ Home، دکمهٔ افزودن، انتخاب‌گرهای taxonomy، Quick Capture، Task Details و کنترل‌های Report Center متصل شد. Source commits: `93d4cf75`, `a133fa8a`, `1e9db5fe`, `f7f3ceca`, `901078af`, `7932da2e`, `2261d28d`, `a2d54f27`, `fb47dfba`, `62b82598`, `89e7e914`, `01caa0d4`, `561a8b2e`, `dd968b25`, `9e66820d`.
- ترتیب پنج فیلتر Home در ردیف RTL از راست به چپ به زمان، مرکز، پروژه، دسته و برچسب تنظیم شد و کل ردیف کلید آزمون پایدار گرفت. Source: `lib/main.dart`, commit `dffefdd1bd0e32e1405f3c7a95fa405263eafd3d`.
- کنترل موعد Task Editor و Quick Capture از فهرست میانی انتخاب‌ها خارج شد: لمس کنترل مستقیماً تقویم شمسی را باز می‌کند و پس از تأیید تاریخ، ساعت‌گرد باز می‌شود. انتخاب «بدون ساعت» همچنان فقط داخل ساعت‌گرد است؛ لغو انتخاب ساعت، تاریخ نیمه‌کاره را ثبت نمی‌کند. Source commits: Task Editor `5650c5e152465c6df557739a130c42a887f5eb6d`، Quick Capture `65c319f2cf265dc4e6a06d88fa97ed18b0a5b198`.
- رنگ برند Task Details و Task Editor به Theme زنده متصل شد. Source commits: `6cff0d92`, `aff66d4e`.
- آزمون Home برای ردیف پنج‌فیلتر از انتظار Wrap قدیمی به قرارداد تک‌ردیفهٔ بدون پیمایش افقی در ۳۶۰/۳۹۰/۴۱۲dp و کیبورد باز تغییر کرد؛ حداقل عرض/ارتفاع ۴۸dp و نبود overflow بررسی می‌شود. Test commit: `ce0c68097d2bc183785c755aa5c6b2a27bb20e8f`؛ import test: `ed7a4c7f0735f1f703d5650819cdd4f4a272c069`.
- آزمون Theme filter به‌جای ActionChip قدیمی، رنگ زندهٔ Theme و هدف لمس ۴۸dp را برای کامپوننت واقعی می‌سنجد. Test commit: `d9b2df3ab6e5cdf5cb0588b8abc729ee5a2e6797`.
- آزمون‌های Task Editor و Quick Capture برای جریان تک‌لمسی تاریخ ← ساعت‌گرد و «بدون ساعت» به‌روزرسانی شدند؛ test commits: `8235c5142ff94205a484054caae62538ca6cda54` و `0ebf6790579caaec031ffed38324975b087b45e8`.

### وضعیت پذیرش و موارد باز
- Analyze روی SHA پیشین `8300e473a49c4e0b574cfd764ba31baf0ee472e3` PASS بود؛ هر شش Shard همان SHA FAIL بودند. این نتایج برای source checkpoint حاضر معتبر نیستند.
- Build/Review/Device Smoke برای source checkpoint حاضر در لحظهٔ ثبت هنوز نتیجهٔ نهایی نداشتند؛ اجرای بعدی پس از این ثبت اسناد باید روی SHA نهایی خوانده شود. هیچ PASS به این SHA منتقل نمی‌شود.
- رنگ زنده در تمام مصرف‌کننده‌های اختصاصی، Report Center و سایر فرم‌ها هنوز نیازمند ممیزی/آزمون کامل است؛ وضعیت را «اتصال بخش‌های نام‌برده‌شده انجام شده، پذیرش سراسری تأییدنشده» نگه دارید.
- آزمون‌های person-specific FollowUp/Report، category clear، Reminder All-Day، ردیف Home و چند تست Quick Capture/Task Editor در Run قبلی شکست داشتند؛ علت‌ها و اصلاحات باید با Run تازه بررسی شوند. تست‌های مربوط به زمان و تمام‌روز فقط روی SHA دقیق خودشان معتبرند.
- همگام‌سازی محلی P2P همچنان در حد طراحی/برنامه است؛ امنیت جفت‌سازی، لغو دسترسی، تعارض و انتقال دوسویه روی دو دستگاه اثبات نشده است. فاز ابری برنامهٔ آینده است.
- Device Smoke فیزیکی و تصویر نصب/تعامل روی Samsung SM-A528B/DS تأییدنشده است.

PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ بدون Merge یا انتشار؛ فونت Vazirmatn و قرارداد SVG عبارات مقدس حفظ شود. **BLOCKED — RELEASE: NO-GO**.


## 2026-11-07 — اصلاح اعتبارسنجی یادآور تمام‌روز در پیگیری
- در `lib/follow_up_entry_page.dart` اعتبارسنجی یادآور تمام‌روز از ساعت مصنوعی ۹ صبح به مقایسهٔ تاریخ تقویمی تغییر کرد؛ یادآور تمام‌روز برای امروز صرفاً به‌دلیل سپری‌شدن ساعت ۹ رد نمی‌شود. زمان‌دارها همچنان باید در آینده باشند.
- Source commit: `0e63449dd122065314c97f7d81f320dfccca3460`.
- آزمون مرتبط `test/follow_up_entry_page_test.dart` از قبل حالت تمام‌روز و ذخیرهٔ Reminder را پوشش می‌دهد؛ اجرای exact-SHA این اصلاح هنوز در انتظار نتیجه است. Run Build `42361252514`، Draft Review APK `42361252886`، Device Smoke `42361252423` و Persistence `42361252554` در زمان ثبت Pending/Queued هستند؛ هیچ‌کدام PASS محسوب نمی‌شوند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## 2026-11-07 — تثبیت تست‌های شش‌شارد و شناسنامه APK بازبینی (abecec1)

- شاخه مجاز: `fix/recovery-calendar-device-smoke-2026-10-31`.
- Source commit: `abecec1ec895e6c7df83913247c1cc9ecc083d02` — اصلاح Finder تست `issue 1891 tag roll box` بدون حذف یا تضعیف assertionها.
- Build run `42370095017`: نتیجه کلی SUCCESS؛ Analyze و Visual نیز SUCCESS.
- شمارش قطعی شش شارد از لاگ‌ها: Shard 0 = 224، Shard 1 = 185، Shard 2 = 308، Shard 3 = 145، Shard 4 = 236، Shard 5 = 173؛ جمع 1,271/1,271؛ ALL SHARDS PASSED = YES.
- تست `issue 1891 tag roll box supports multi-select with apply/cancel` در Shard 4 موفق شد.
- Staging review artifact: Run `42370095057`، Artifact ID `13573433210`. APK استخراج و هش روی خود فایل اجرایی محاسبه شد:
  - File: `Arvin-review-staging-abecec1ec895e6c7df83913247c1cc9ecc083d02.apk`
  - SHA-256: `6e259567386481fa14621bd35d133a4d7f1959bb9ff6a0820ac4a994c583cbc2`
  - Size: 79,120,215 bytes = 75.455 MiB (79.120 MB decimal).
  - applicationId: `com.example.arvin.staging`; `android_debuggable=false`; V2/V3 signature verification passed.
  - Signing key is ephemeral/review-only; `publishable=false`. This is not a release APK.
- Device Smoke Run `42370095088` targets the exact source SHA above but remains PENDING; latest job query returned zero jobs. The workflow definition has `pull_request` triggers (opened/synchronize/reopened/ready_for_review) and `workflow_dispatch`; its matrix jobs run on GitHub-hosted `ubuntu-latest` and provision Android API 35 emulator through the emulator-runner action. Therefore no evidence currently indicates a dedicated self-hosted emulator runner is the blocker. The run appears not to have progressed to job creation; the exact scheduler/approval/concurrency cause is not exposed by available run/job evidence and remains UNKNOWN.
- A manual workflow-dispatch / full-run rerun was not issued: the available GitHub actions expose job-level rerun and failed-job rerun only; this pending run has no jobs to rerun. Do not report a retry as triggered. Manual `workflow_dispatch` with `target_sha=abecec1ec895e6c7df83913247c1cc9ecc083d02` remains the supported workflow-level route when an authorized GitHub Actions dispatch control is available.
- PR #3052 must remain OPEN / DRAFT / UNMERGED. main remains at `45e4202b03a434459e4c021a04efa7e8396359db`; no merge or main update. Release remains **BLOCKED — RELEASE: NO-GO** until Device Smoke and all remaining acceptance gates pass on one exact candidate SHA.


## Parallel execution checkpoint — 2026-11-07 — source 6fa57ce

- Source fix: removed the unused `_dateRollBox` declaration from `lib/task_editor_dialog.dart`; source commit `6fa57ce5231f73d67304bed46263a02af1e1cb90`, exact message: `fix(analyzer): remove unused _dateRollBox in task_editor_dialog`. No tests were changed, deleted, skipped, or weakened by this source commit.
- Exact-SHA GitHub Actions run: `42406373769`; Analyze job `128504856906` completed **SUCCESS**. The Flutter Analyze step itself is **SUCCESS**. This confirms the prior unused-element warning is resolved on source SHA `6fa57ce5231f73d67304bed46263a02af1e1cb90`.
- Test shards are independent. At this checkpoint, Shard 1 job `128504856909` is still `IN_PROGRESS`; Shard 2 is `IN_PROGRESS`; Shard 3 and Shard 4 have completed with `FAILURE`; Shard 5 test step has failed while its job is still finishing. Do not treat the earlier completed Shard 1 run as current-SHA acceptance evidence.
- Latest completed Shard 1 evidence available at checkpoint: run `42405042863`, job `128500803200`, source SHA `44f4dfbbb3db846765d4ea2e67dffa263aa4cac2`; result **173 passed / 14 failed**. Analyze in that shard was skipped by workflow design; the dedicated Analyze job is the authoritative check.
- Previous Shard 1 failures, exact test titles and failure messages:
  1. `test/task_detail_followup_flow_test.dart:151` — `inline description edit updates updatedAt and preserves completion and Follow-up history`: expected `DateTime(2026-11-02 12:00:00)`, actual `null`.
  2. `test/integration_task_reminders_migration_backup_test.dart:36` — `deleted migrated legacy reminder does not return after SQL and backup restore`: expected ID `legacy-task-reminder-task-reminder-integration`, actual ID `legacy-task-reminder-deleted-legacy-reminder`.
  3. `test/widgets/home_page_test.dart:193,198,200` — `Home uses the five checkbox filters as combined filters and preserves time grouping`: horizontal `RenderFlex overflowed by 158 pixels on the right`; interaction assertions failed.
  4. `test/services/task_migration_writer_test.dart:122` — `Home snapshot deletes omitted items and serializes new items canonically`: expected `true`, actual `null`.
  5. `test/services/home_today_projection_test.dart:55` — `legacy scheduling fields alone never create a Home FollowUp entry`: expected `DateTime(2026-08-27 08:00:00)`, actual `null`.
  6. `test/services/g1_drift_schema_test.dart:132` — `materializes multiple Task reminders, historical Follow-ups and Persons canonically`: SQLite error `Invalid argument (parameters): Expected 3 parameters, got 2`.
  7. `test/services/calendar_inbound_sync_service_test.dart:54` — `retired inbound reconciliation never mutates native Task ownership`: expected ID set containing `legacy-task-reminder`, actual contains `legacy-task-reminder-task-1` instead.
  8. `test/follow_up_repository_test.dart:48` — `appends a FollowUp while preserving the task envelope`: expected `DateTime(2026-08-14 09:30:00)`, actual `null`.
  9. `test/task_editor_dialog_test.dart:220` — `Task editor saves a new follow-up record with separate title and note`: expected `false`, actual `true`.
  10. `test/task_detail_metadata_selector_test.dart:42,45,48` — `Task Details category and tags use shared filter selectors`: expected category `شخصی`, actual `کاری`; also horizontal overflow by 158px.
  11. `test/follow_up_reminder_projection_test.dart:51` — `only independent TaskReminder records enter the projection`: expected collection length 1, actual length 2.
  12. `test/reusable_multi_select_filter_bottom_sheet_test.dart:50,53` — `multi-select sheet persists inline-created option and auto-selects it`: expected set `['new-شخصی', 'work']`, actual `null`; also horizontal overflow by 158px.
  13. `test/report_center_page_test.dart:246,253,256` — `Report Center shows separate person-specific active waiting rows`: expected text `نتیجه: 1 پیگیری` not found; also horizontal overflow by 158px.
  14. `test/task_edit_apply_service_test.dart:100` — `metadata edits preserve completion timestamp without future follow-up schedule`: expected `true`, actual `false`.
- Initial root-cause grouping (diagnostic hypotheses, not yet proven): (a) 158px horizontal overflow and resulting unreachable controls in shared filter/UI layout; (b) null/mismatched timestamp or snapshot values in Task/Follow-up editing and projection; (c) legacy reminder identity/migration normalization mismatch; (d) Drift insert SQL placeholder/bind count mismatch; (e) multi-select inline-created value not persisted/selected; (f) report projection missing the expected person-specific row. Fix production behavior and retain all regression tests; do not weaken assertions to match defects.
- Universal filter contract: `ReusableMultiSelectFilterBottomSheet`; checkbox multi-select; OR within a dimension and AND across dimensions; inline creation auto-selects the new value; active-selection count badges; dimensions Time, Center, Project, Category and Tag where applicable.
- Typography contract: **Vazirmatn**. Default accent color: **#3A86EF** (palette option 8); do not confuse this dynamic accent with legacy semantic teal tokens.
- Governance: PR #3052 remains **OPEN / DRAFT / UNMERGED**; `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`; release remains **BLOCKED — RELEASE: NO-GO**. No merge, publication or release.
- Documentation synchronization itself changes the branch SHA; all exact-SHA acceptance gates must be checked again on the resulting documentation commit. Current physical Samsung SM-A528B/DS Device Smoke is not claimed as passed.


## CI completion addendum — Run 42406373769 — 2026-11-07

- This addendum supersedes the in-progress Shard 1 status above. On source SHA `6fa57ce5231f73d67304bed46263a02af1e1cb90`, Shard 1 job `128504856909` has now completed with **FAILURE: 173 passed / 14 failed**. The 14 failed test titles and failure messages are the same 14 listed above; no new failure category appeared in this shard. Analyze job `128504856906` on the same SHA completed **SUCCESS**.
- The Shard 1 UI overflow is now directly localized in the reusable filter sheet: the log for `test/reusable_multi_select_filter_bottom_sheet_test.dart` identifies `Row` at `lib/widgets/reusable_multi_select_filter_bottom_sheet.dart:206:17` and reports `A RenderFlex overflowed by 158 pixels on the right`. This is confirmed for that test. Other UI tests report missed hit-tests at filter/apply controls; verify each affected screen against the shared component before assigning a common cause.
- Shard 1 is therefore **not green**. The source Analyze fix is verified, but the full quality gate remains failed until all 14 regressions are fixed without weakening tests.
- Documentation commit `cb89261753adc2d935798e85d0a3ed8b9ef66b37` was created after the source run; no workflow run for that documentation SHA was visible at the time of this addendum. Re-check exact-SHA CI for the documentation commit; do not transfer PASS from source SHA `6fa57ce` to the documentation SHA.


---

## TODO / CI checkpoint — 2026-11-07 — branch HEAD `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`

- مرجع کارهای باز: [`docs/project-continuity/TODO.md`](TODO.md). فقط مواردی در فهرست فعال‌اند که بازبودن یا نیاز به تأییدشان در کد، CI یا همین اسناد قابل ردیابی است.
- شاخه مجاز و PR #3052 هر دو روی SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a` هستند. PR وضعیت `OPEN / DRAFT / UNMERGED` دارد؛ `main` روی `45e4202b03a434459e4c021a04efa7e8396359db` باقی است.
- **Staging Review APK — تکمیل‌شده برای بازبینی، نه انتشار:** run `42407484426` روی همین SHA با SUCCESS پایان یافت. Artifact ID `13588087657`، نام `arvin-review-staging-apk-b1ad86a164f9d8f8363e29313163f1be0ee53d4a`، اندازه ZIP برابر `39,226,420` بایت. فایل APK: `Arvin-review-staging-b1ad86a164f9d8f8363e29313163f1be0ee53d4a.apk`، اندازه `79,185,749` بایت، SHA-256 برابر `04482b5595eb7666a9a47076eb7c8fdcec480ca7911ab2a8f718ef442276fd90`. شناسه بسته `com.example.arvin.staging`، `android_debuggable=false)، امضای V2/V3 و فایل‌های Vazirmatn تأیید شدند. کلید امضا موقت و مخصوص بازبینی است؛ `publishable=false` و این APK نسخه انتشار نیست. [Run](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484426) · [Artifact](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484426/artifacts/13588087657)
- **Build و تست‌های اصلی — در جریان:** run `42407484460` روی همین SHA؛ Analyze و Visual موفق‌اند؛ هر شش شارد تست و jobهای Debug/Staging/Release APK هنوز `IN_PROGRESS` هستند. بنابراین نتیجه نهایی تست‌ها، از جمله تست‌های فیلتر، هنوز «در انتظار تأیید» است. [Run](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460)
- **Device Smoke — در انتظار:** run `42407484403` دقیقاً همین SHA را هدف گرفته و در وضعیت `PENDING` است؛ در زمان ثبت این checkpoint هنوز jobای برای آن برنگشته است. [Run](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484403)
- روی همین SHA، G1 lock sync run `42407484429`، Follow-up file persistence run `42407484432` و Calendar Provider run `42407484406` هر سه SUCCESS هستند. این شواهد فقط به همین SHA نسبت داده می‌شوند.
- اصلاح سرریز ۱۵۸ پیکسلی پنل فیلتر در commit `2baad457ba0bdd89114566afb4b42e2315904bb2` ثبت شده است؛ قبولی تست‌های مرتبط باید از شاردهای اجرای جاری و همین SHA تأیید شود. شکست‌های قدیمی run `42406373769` روی SHA `6fa57ce5231f73d67304bed46263a02af1e1cb90` به HEAD فعلی تعمیم داده نمی‌شوند.
- نصب و رفتار واقعی روی Samsung SM-A528B/DS هنوز **در انتظار تأیید** است؛ Artifact بازبینی به‌تنهایی اثبات نصب و پذیرش گوشی واقعی نیست.
- انتشار همچنان **BLOCKED — RELEASE: NO-GO** است. PR باید OPEN/DRAFT/UNMERGED بماند؛ هیچ Merge، انتشار یا تغییری در `main` مجاز نیست.


---

## TODO / Staging APK execution update — 2026-11-07 — HEAD `ad58025592690515020de2c4e3bf0fd0ac65db1b`

- دفتر کارهای باز مطابق آخرین درخواست مالک در [`TODO.md`](TODO.md) با شناسه‌های TSK-01 تا TSK-04 و دروازه انتشار ARV-REL-01 همگام شد.
- **Staging APK run `42406934575`: SUCCESS روی SHA `2baad457ba0bdd89114566afb4b42e2315904bb2`.** Artifact ID `13588285590`، APK `Arvin-review-staging-2baad457ba0bdd89114566afb4b42e2315904bb2.apk`، حجم `79,185,752` bytes، APK SHA-256 `dd990f90a1441423c3214e915d528f5f78e6d65ce0045b45b75791ddd1873416`. Artifact ZIP برابر `39,226,418` bytes با digest `29369cb751c75055198b69252cd49461d47bf8e50a7e4da3d289393ce6cb89aa`. package `com.example.arvin.staging`، non-debuggable، امضای V2/V3 و Vazirmatn تأیید شده‌اند. کلید امضا موقت و مخصوص بازبینی است؛ `publishable=false`. [Run](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575) · [Artifact](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575/artifacts/13588285590)
- Build run `42406934619` روی همان SHA با وضعیت CANCELLED پایان یافته است؛ موفقیت Review APK را نباید به معنی قبولی Build و همه شاردها دانست.
- Build run `42407484460` روی SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a` نیز بعد از پیش‌روی شاخه CANCELLED شده است. job شارد ۱ پیش از لغو، **174 passed / 13 failed** گزارش کرده است؛ از جمله شکست‌های timestamp/Reminder، Drift binding، و overflow عمودی در سناریوهای UI. این نتایج فقط به همان SHA تعلق دارند.
- روی HEAD فعلی این checkpoint، `ad58025592690515020de2c4e3bf0fd0ac65db1b`، Build run `42408265669` در جریان است؛ Analyze و Visual موفق‌اند، اما شش شارد و APKها در انتظار نتیجه نهایی‌اند. Device Smoke run `42408265703` در وضعیت PENDING و بدون job قابل مشاهده است. Calendar Provider و Review APK مربوط به همین HEAD نیز در زمان ثبت در حال اجرا هستند.
- **Samsung SM-A528B/DS:** نصب و رفتار واقعی، نبود کرش و اعمال رنگ `#3A86EF` هنوز در انتظار تأیید است؛ Artifact به‌تنهایی اثبات نصب فیزیکی نیست.
- **پالت رنگ:** گزارش `ARVIN_DYNAMIC_THEME_PALETTE_2026-11-07.md` وجود AppThemeManager، ۹ رنگ و کلید `arvin.settings.primaryColor` را مستند کرده؛ آزمون نهایی SharedPreferences، پوشش کامل صفحات و پذیرش بصری/دستگاهی هنوز باز است.
- **فیلترها:** اصلاح قبلی overflow در commit `2baad457ba0bdd89114566afb4b42e2315904bb2` ثبت شده؛ آزمون میدانی مستقل در عرض‌های 360، 390 و 412dp هنوز انجام/تأیید نشده است.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` بدون تغییر؛ Merge/انتشار ممنوع؛ **BLOCKED — RELEASE: NO-GO**.


## Product architecture decision — Connected Notebook — 2026-11-07
- Owner-approved product direction is documented in `docs/project-continuity/ARCHITECTURE_NOTEBOOK.md`: Notebook as a fast-capture “second brain and action platform”, bidirectional visibility/linking with Tasks and Follow-up records, preservation of source note text when creating a Task, and integration with the shared filter experience.
- This is a product/architecture decision and future-work specification only. **No implementation code, Dart file, database schema, migration, or test was changed for this feature in this phase.** Current release stability takes priority.
- Gap analysis inspected the branch sources: canonical Notebook records currently reuse Task with `notebook_kind`; Drift has `tasks`, `follow_up_records`, `task_reminders`, project/taxonomy relation tables, but no dedicated Notebook-to-Follow-up link table; `NotebookPage` currently exposes separate Category/Project/Tag selectors and its own search. Fast-capture ergonomics, linked-entry chips, Center filter and shared five-axis filtering remain future verification/implementation items.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.


---

## TSK-02 — تحلیل تفصیلی ۱۳ شکست شارد ۱ — 2026-11-07


### فهرست ۱۳ شکست — job quality (test-1)
مرجع: [Build run 42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460)، job ID `128509578970`، [لاگ job](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460). Checkout دقیقاً روی SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a` انجام شده است. نتیجه: **174 passed / 13 failed**. این گزارش تاریخی است و به HEAD فعلی تعمیم داده نمی‌شود.

| # | تست ناموفق | فایل و خط تست | علت ثبت‌شده در لاگ | دسته |
|---:|---|---|---|---|
| 1 | `inline description edit updates updatedAt and preserves completion and Follow-up history` | `test/task_detail_followup_flow_test.dart:151` | زمان تکمیل مورد انتظار `2026-11-02 12:00` بود؛ مقدار واقعی `null` برگشت. | Assertion — مقدار/تاریخچه |
| 2 | `deleted migrated legacy reminder does not return after SQL and backup restore` | `test/integration_task_reminders_migration_backup_test.dart:36` | شناسه مورد انتظار `legacy-task-reminder-task-reminder-integration` بود؛ شناسه واقعی `legacy-task-reminder-deleted-legacy-reminder` بود. | Assertion — شناسه/بازیابی |
| 3 | `Home uses the five checkbox filters as combined filters and preserves time grouping` | `test/widgets/home_page_test.dart:197`؛ ویجت مسبب: `lib/widgets/reusable_multi_select_filter_bottom_sheet.dart:82` | `TextEditingController was used after being disposed` هنگام ساخت مجدد TextField. | Widget lifecycle — استفاده پس از dispose |
| 4 | `search filters the currently loaded legacy tasks` | `test/widgets/home_page_test.dart:221` | خطای چارچوب Flutter: `_dependents.isEmpty` هنگام غیرفعال‌سازی Focus؛ سپس Finder متن «تماس فروش» را پیدا نکرد (۰ مورد به‌جای ۱). | Widget lifecycle / Assertion — وابستگی و نتیجه جست‌وجو |
| 5 | `Home snapshot deletes omitted items and serializes new items canonically` | `test/services/task_migration_writer_test.dart:122` | مقدار مورد انتظار `true` بود؛ مقدار واقعی `null` بود. | Assertion — خروجی مهاجرت |
| 6 | `legacy scheduling fields alone never create a Home FollowUp entry` | `test/services/home_today_projection_test.dart:55` | تاریخ مورد انتظار `2026-08-27 08:00` بود؛ مقدار واقعی `null` بود. | Assertion — Projection |
| 7 | `materializes multiple Task reminders, historical Follow-ups and Persons canonically` | `test/services/g1_drift_schema_test.dart:132` | SQLite: `Expected 3 parameters, got 2` هنگام اجرای INSERT؛ تعداد bindها با placeholderها هم‌خوان نبود. | SQL binding — خطای اجرا |
| 8 | `retired inbound reconciliation never mutates native Task ownership` | `test/services/calendar_inbound_sync_service_test.dart:54` | مجموعه مورد انتظار شامل `legacy-task-reminder` بود؛ مقدار واقعی `legacy-task-reminder-task-1` داشت. | Assertion — شناسه یادآور |
| 9 | `appends a FollowUp while preserving the task envelope` | `test/follow_up_repository_test.dart:48` | تاریخ مورد انتظار `2026-08-14 09:30` بود؛ مقدار واقعی `null` بود. | Assertion — داده Follow-up |
| 10 | `Task editor saves a new follow-up record with separate title and note` | `test/task_editor_dialog_test.dart:220` | انتظار `false` بود؛ مقدار واقعی `true` بود. | Assertion — رفتار ویرایشگر |
| 11 | `only independent TaskReminder records enter the projection` | `test/follow_up_reminder_projection_test.dart:51` | تعداد مورد انتظار ۱ بود؛ Projection دو `FollowUpReminderCandidate` برگرداند. | Assertion — تعداد/Projection |
| 12 | `multi-select sheet persists inline-created option and auto-selects it` | `test/reusable_multi_select_filter_bottom_sheet_test.dart`؛ ویجت مسبب: `lib/widgets/reusable_multi_select_filter_bottom_sheet.dart:96` | `TextEditingController was used after being disposed` هنگام ساخت مجدد TextField. | Widget lifecycle — استفاده پس از dispose |
| 13 | `metadata edits preserve completion timestamp without future follow-up schedule` | `test/task_edit_apply_service_test.dart:100` | انتظار `true` بود؛ مقدار واقعی `false` بود. | Assertion — حفظ وضعیت/زمان تکمیل |

**جمع‌بندی دسته‌ها:** ۹ مورد Assertion/اختلاف داده و خروجی؛ ۲ مورد چرخه عمر Widget/Controller؛ ۱ مورد خطای SQL binding؛ ۱ مورد خطای چارچوب Widget همراه با Finder ناموفق. در لاگ این ۱۳ مورد، Timeout یا Mock failure مشاهده نشد. این دسته‌بندی تشخیص اولیه از خروجی تست است، نه اعلام علت ریشه‌ای قطعی؛ برای تعیین علت نهایی باید کد همان SHA و مسیر داده بررسی شود.

**محدودیت این فاز:** فقط مستندسازی و تحلیل لاگ مجاز است. هیچ تغییری در `lib/` یا `test/`، هیچ اصلاح assertion، حذف/Skip تست یا تغییر اسکیما انجام نشود.


## Connected Notebook — وضعیت سند معماری

- فایل `docs/project-continuity/ARCHITECTURE_NOTEBOOK.md` پیش از این به‌روزرسانی در شاخه مجاز موجود بود (Blob SHA: `75b3e24135cd497665dc2f39a5bd8cc75ab62509`). محتوای آن بررسی شد و مشخصات «مغز دوم»، Fast Capture، اتصال دوطرفه، استفاده از فیلتر مشترک و Gap Analysis را پوشش می‌دهد؛ سند تکراری ساخته نشد.
- سند، چهار محور نام‌برده‌شده مرکز/پروژه/دسته/برچسب را مشخص کرده و به‌درستی یادآور شده که محور پنجم در عبارت درخواست روشن نیست؛ پیش از پیاده‌سازی باید مالک محصول آن را تعیین کند.
- Gap Analysis فعلی صرفاً نیازمندی فاز بعدی است؛ هیچ کد، جدول Drift، مهاجرت یا تستی در این فاز تغییر نکرده است.
- وضعیت انتشار همچنان **BLOCKED — RELEASE: NO-GO**؛ PR #3052 باید OPEN / DRAFT / UNMERGED بماند و main دست‌نخورده باشد.


## Exact-SHA CI checkpoint — 2026-11-08 — d02cb2df2a46b6c600158bda35709e7c3854ffbc

- PR #3052 HEAD was verified as this exact SHA; PR remains OPEN / DRAFT / UNMERGED. No main-branch change was made.
- Draft Review APK run 42451351162 (job 128641055464): FAILURE. The staging APK assembly failed before signature/package/font verification and before artifact upload. The run exposes zero artifacts; no APK filename, package ID, APK SHA-256, or APK size is available for this SHA.
- Draft Review compiler errors in lib/task_detail_page.dart: undefined getter/name `due` at lines 1940–1941 (four analyzer references) and missing method `_templateSourceCard()` at line 2182. Build log confirms :app:compileFlutterBuildStaging failed.
- Build run 42451350930 was IN_PROGRESS at the checkpoint. Its Analyze job 128641863102: FAILURE (7 issues: 4 undefined-name diagnostics for due, missing _templateSourceCard method, and unused_element warnings for _cancelInlineEdit and _metadataChip). Visual job 128641863043: FAILURE; task_detail_visual_test.dart could not compile because of the same two source defects; 0 tests passed. Six quality shards test-0 through test-5 were still IN_PROGRESS at the checkpoint; their final conclusions are NOT VERIFIED. APK debug/release/staging jobs were still IN_PROGRESS at the checkpoint; no artifacts were listed for the Build run.
- Calendar Provider run 42451350939 / job 128641045795: FAILURE. Its instrumentation stage could not compile the app because of the same `due` and `_templateSourceCard` errors. The run uploaded only diagnostic evidence artifact 13606295730 (8,798 bytes; ZIP SHA-256 73db3facfee388a6d0750f2126690ec8f1f98396b7c5943f88eac18c9b32ca8d); this is NOT an APK.
- Follow-up File Persistence run 42451350822 / job 128641054577: SUCCESS. File-backed repository persistence and alarm-overlay SQLite close/reopen diagnostic tests completed successfully on this SHA.
- Device Smoke run 42451350903 remained PENDING with no jobs exposed; no device acceptance is verified.
- Orchestrator, Orchestrator PR Wakeup, Parallel Wave, Production Loop and G1 lock sync runs completed SUCCESS, but these are orchestration outcomes and do not replace app build, test, visual, calendar or device acceptance.
- Next action: repair the source compilation defects without removing or weakening tests, then rerun every required gate on one exact new candidate SHA. Do not claim the six shards passed until their completed exact-SHA results are available.
- Governance unchanged: PR #3052 OPEN / DRAFT / UNMERGED; no merge, publication or release; **BLOCKED — RELEASE: NO-GO**.


## Persian Teal foundation — 2026-11-09
- On the authorized PR branch, the default brand accent now starts from Persian Teal (#0F766E) with a deeper teal header and matching soft/glow surfaces. Legacy theme token names remain compatibility aliases to the new brand token.
- Taxonomy and grouping accents are separated instead of inheriting one blue: time/brand teal, reminders amber, projects violet, categories blue, tags green; Eisenhower priorities retain red, amber, blue and neutral-gray semantics.
- The five visible primary-navigation icons retain independent colors; Home now uses the Persian Teal brand token. The shared multi-select create actions now use their supplied semantic accent instead of a hard-coded blue.
- Vazirmatn and the existing 0.8dp card outline / transparent surface tint are preserved. This is the first bounded visual-foundation slice, not completion of the full MASTER-FINAL directive.
- Validation baseline before this commit (SHA f561465c): Analyze PASS; Debug, Release and Staging APK jobs PASS; all six test shards FAILED (test-0: 22; test-1: 23; test-2: 23; test-3: 20; test-4: 13; test-5: 13 failing tests). Device Smoke was still running at the checkpoint and had failures including a SQLite native-asset hash mismatch. Fresh exact-head CI is required after this commit.
- No test was removed, skipped or weakened. The navigation color assertion was updated only to match the new approved brand color.

- Follow-up test-contract update: the retired sky-blue palette value (#3A86EF) is explicitly rejected; the default and first palette choice are Persian Teal (#0F766E). Theme token and preference-manager tests now assert the approved multicolor semantics and the retired-value fallback. This is an assertion correction, not a skipped or softened test.


---

## ممیزی زنده CI و قراردادهای Notebook / Template / Triple Calendar — ۱۴۰۵/۰۸/۱۸ — 2026-11-09

**مرجع دقیق ممیزی:** PR #3052 و شاخه `fix/recovery-calendar-device-smoke-2026-10-31` روی HEAD `76a89e72956325149c090a25caf9cf9e642f3dc7`. HEAD شاخه با HEAD PR برابر بود؛ `main` روی `45e4202b03a434459e4c021a04efa7e8396359db` باقی بود.

### وضعیت قطعی Build #10646 — run `42589063339`

| Job | Job ID | نتیجه دقیق |
|---|---:|---|
| Analyze + Android V2 audit | `129066729343` | SUCCESS؛ هر دو Step موفق |
| Visual | `129066729085` | SUCCESS؛ Task Details structural smoke و upload موفق |
| Shard 0 | `129066729337` | FAILURE — 213 passed / 20 failed |
| Shard 1 | `129066729221` | FAILURE — 186 passed / 10 failed |
| Shard 2 | `129066729550` | FAILURE — 294 passed / 24 failed |
| Shard 3 | `129066729233` | FAILURE — 138 passed / 19 failed |
| Shard 4 | `129066729332` | FAILURE — 227 passed / 14 failed |
| Shard 5 | `129066728935` | FAILURE — 175 passed / 13 failed |
| APK Staging | `129066728729` | SUCCESS؛ Build، signature/manifest، font audit، verify و upload موفق |
| APK Debug | `129066728942` | SUCCESS؛ Build، font audit و verify موفق |
| APK Release | `129066729321` | SUCCESS؛ Build، font audit و verify موفق |

**جمع شش شارد:** 1,233 تست موفق، 100 تست ناموفق، 1,333 تست اجراشده. Build workflow به علت شکست شاردها در سطح کلی SUCCESS نیست.

### دروازه‌های مستقل روی همین SHA

| Workflow | Run / Job | نتیجه |
|---|---|---|
| Device Smoke #7866 | run `42589063306` | PENDING؛ در آخرین بررسی هیچ Job قابل مشاهده نبود؛ پذیرش دستگاهی VERIFIED نیست |
| Draft Review APK #1439 | run `42589063190` / job `129065910125` | SUCCESS؛ staging review APK non-debuggable، signature/package/font checks و artifact upload موفق |
| Calendar Provider #2766 | run `42589063376` / job `129065910586` | SUCCESS؛ Provider instrumentation و acceptance موفق |
| Follow-up File Persistence #1789 | run `42589063325` / job `129065910382` | SUCCESS؛ file-backed persistence و close/reopen diagnostic موفق |
| G1 lock sync #5258 | run `42589063294` / job `129065909311` | SUCCESS |

موفقیت APK یا Provider جایگزین Device Smoke و پذیرش فیزیکی Samsung SM-A528B/DS نیست. امضای Review/Staging نیز مجوز انتشار محسوب نمی‌شود.

### وضعیت شکست شاردها
- شارد ۰: از جمله `Bad state: No element` در تست ساخت مرکز در Quick Capture و نبودن متن مورد انتظار «زمان کار / موعد».
- شارد ۱: از جمله نبودن گزینه «پروژه» در تست ثبت سریع و شکست تست گزارش ردیف‌های انتظار شخص‌محور.
- شارد ۲ و ۳: شکست تست‌های Quick Capture در مسیرهای موعد، Reminder، تکرار و نمایش ساعت انتخاب‌شده.
- شارد ۴ و ۵: شکست‌های متعدد در تقویم، Task Details، فیلترها و گزارش‌ها.
- مجموع شکست‌ها باید بر اساس لاگ هر تست اصلاح شود؛ این فهرست دسته‌بندی اولیه است و جایگزین تحلیل ریشه‌ای همه 100 مورد نیست.

### قراردادهای محصولی ثبت‌شده
- Notebook: Fast Capture، استخراج عنوان فقط در اولین auto-save، دو حالت مستقل/متصل، unlink و حذف Task بدون حذف Note، تبدیل غیرمخرب به Task جدید.
- روابط: Center/Project/Category هرکدام حداکثر یک انتخاب و اختیاری؛ Tags چندانتخابی؛ زنجیره Center→Project→Category.
- Templates: تکثیر عمیق فیلدهای مصوب، حذف تاریخچه و وضعیت اجرا، جابه‌جایی Due Date/Reminder بر اساس offset نسبت به تاریخ مبنای جدید.
- Calendar: شمسی پیش‌فرض، قمری و میلادی در همه انتخابگرها و تبدیل به تاریخ canonical داخلی.

### مرز تغییرات این مرحله
این ثبت و هم‌راستاسازی فقط مستندات است. هیچ کد، تست، schema، migration، workflow یا APK تغییر نکرده است. نتایج CI بالا متعلق به SHA دقیق ذکرشده‌اند و به commit مستندات بعدی منتقل نمی‌شوند.

**حاکمیت:** PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## WAVE 4 REV8 live implementation addendum — 2026-11-10

Mobin has now explicitly authorized implementation and testing, superseding the earlier read-only Wave 4 status.

Implementation checkpoint: `dbfcdb02879ed3939cb6a69d3a150e2237283a51`. Changes include pre-COMMIT Task/Project migration parity, same-ID conflict detection, deferred legacy drops/rebuilds, relational Project ordering, unknown Project field retention, and relational Recurrence/Occurrence/per-occurrence checklist storage.

Verification is NOT YET PASS: Build run `42864431438` and Device Smoke run `42864430851` were pending at the last exact-SHA lookup; Calendar Provider `42864431259` and Follow-up Persistence `42864430953` were queued. No local Flutter tests were run. See `audit/P0_C_IMPLEMENTATION_REPORT.md`, `audit/MIGRATION_PARITY_REPORT.md`, `audit/OCCURRENCE_DATA_OWNERSHIP_REPORT.md` and `audit/TEST_VALIDATION_REPORT.md`.

Remaining: G1 legacy relation parity, a single multi-source transaction, remaining JSON/SharedPreferences owners, full Backup/Restore, complete test/Android evidence, and the four Reminder states decision. Legacy sources remain. PR #3052 OPEN / DRAFT / UNMERGED; Main READ-ONLY; Release NO-GO.


---

## REV9 deployment baseline — 2026-11-10

**Decision status:** REV9 APPROVED as the current owner-supplied master charter. **Implementation status:** not established by this documentation deployment. **Verification status:** UNVERIFIED unless exact-SHA evidence is cited.

Live repository facts at deployment start: Main `45e4202b03a434459e4c021a04efa7e8396359db`; PR #3052 OPEN / DRAFT / UNMERGED at `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; independent documentation branch `docs/rev9-governance-continuity-2026-11-10` based on that Main SHA. No changes were made to PR #3052. Related PRs #3022, #2598, #2600 and #2866 remain open/unmerged and are recorded as competing/proposed documentation sources, not merged truth. Font issue #2974 records the earlier Vazirmatn owner decision; REV9 is newer and explicitly reopens the Vazirmatn/VazirHarf conflict as NEEDS OWNER DECISION. Release remains BLOCKED — RELEASE: NO-GO.


---

## Post-PR deployment checkpoint — 2026-11-10

- Separate documentation PR created: #3340, OPEN / UNMERGED, base `main`, branch `docs/rev9-governance-continuity-2026-11-10`.
- Head at PR creation: `b9dc37804a69cd2292a071e008b50bd261bae512`; a follow-up docs-only commit is being added to record the PR link and handoff. Re-fetch live branch HEAD before any further action.
- Main base: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3052: OPEN / DRAFT / UNMERGED, head `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; unchanged.
- The final pre-PR diff contained 66 files, all Markdown/agent-instruction files; 0 non-documentation files.
- Release remains BLOCKED — RELEASE: NO-GO.


---

## WAVE 0 pre-final validation checkpoint — 2026-11-10

- Last verified branch HEAD before this final handoff record: `cd1d52e752ac10c0040738f655d5a288d2523399`.
- PR #3340 remains OPEN / READY FOR REVIEW / UNMERGED; base Main `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3052 remains OPEN / DRAFT / UNMERGED at `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`.
- Final diff must remain documentation-only. Re-fetch final HEAD and exact-SHA workflow state after the handoff commit.
- No source/test/schema/migration/workflow change, Main write, PR #3052 write, merge or release.



---

## COMMAND 07-A.2.33 — live continuity addendum (2026-11-12)

- Main HEAD observed: `45e4202b03a434459e4c021a04efa7e8396359db` (latest commit returned by repository commit search).
- Execution PR #3384 branch: `feature/command-07-a-sqlite-contract-remediation`; current commit created by this command: `eea746dbf2a58cd4f04c66a149ae3441264da5b2`.
- PR #3384 remains open; no merge performed. Its previous candidate `492a5c433ee215d0188a6075b159d4d72329d35e` is historical for acceptance after the new commit.
- Build on previous candidate: run `43247842294`, failed with 1,338 passed / 61 failed across six shards. Analyze, Visual, Debug APK, Staging APK and Release APK build jobs passed; test shards failed.
- Previous-candidate SQLite snapshot run `43247842246` succeeded for A–D snapshots and five reopen cycles; it is not D01–D05 acceptance and does not prove D05 recovery.
- Previous-candidate Follow-up persistence run `43247842181` succeeded.
- On new candidate `eea746d`: Follow-up persistence run `43269800526` succeeded; Build `43269800292`, Device Smoke `43269800280`, SQLite Snapshot `43269800257` were queued at last poll. Orchestrator `43269800263` succeeded. Re-poll before reporting completion.
- One of the 61 old failure records was identified as a test-fixture defect and corrected in commit `eea746d`; the other 60 remain individually unresolved until source-level review. No old result transfers to the new SHA.
- Live branch inventory: 1,429 branch refs returned over 16 pages. The connector exposes branch names but not per-branch SHA/last-commit metadata in this query; no branch is classified stale or deleted on prefix/name alone.
- PR #3380 and #3382 are diagnostic/test-evidence PRs; #3384 is the implementation PR; #3388 is a separate documentation PR; #3340 contains the REV9 canonical governance branch. All remain unmerged in this work.
- PR #3340's REV9 branch contains the canonical six-document set and prior audit reports. PR #3388 changes a different set of governance/state files and its state document still references v49.0; treat this as a documentation-authority conflict, not as a second canonical source.
- Typography owner clarification dated 2026-11-12: Vazirmatn only; VazirHarf not official; System Default optional; weights 300/400/500/600/700.
- Release remains BLOCKED — RELEASE: NO-GO. No merge, release, deployment, destructive cleanup or history rewrite.



---

## COMMAND 07-A.2.33 — evidence refresh (2026-11-12, later poll)

- New-candidate SQLite Snapshot run `43269800257` completed SUCCESS on `eea746dbf2a58cd4f04c66a149ae3441264da5b2`; artifact `13966864535`, SHA-256 `74a1b84cd67b932177da14982fe82256df68c79b6a0ae5a4451d970f42bc6f72`. It contains A–D snapshot evidence and five reopen cycles; it does not complete D05 interruption/recovery or D04 independent Backup/Restore.
- New-candidate Follow-up Persistence run `43269800526` completed SUCCESS. Orchestrator `43269800263` completed SUCCESS.
- New-candidate Build `43269800292`: at latest poll, test-1/test-5 and Debug APK were IN_PROGRESS; remaining quality, Visual, Staging and Release jobs were QUEUED. Device Smoke `43269800280` remained QUEUED. These are not acceptance results yet.
- Source-level review of prior-candidate failures identified six grounded classifications: one TEST HARNESS DEFECT fixed in `eea746d...`; three additional TEST HARNESS DEFECTS pending correction (two bad TextField finders using `widgetWithText` against InputDecoration hint/label text, and one `scrollUntilVisible` call passing a ListView instead of its Scrollable); two TEST CONTRACT DEFECTS pending correction (alarm smoke uses forbidden unbounded `pumpAndSettle`; due-date test expects null from a compatibility getter that projects the enabled reminder). Remaining 55 records are UNRESOLVED. All classifications remain historical to SHA `492a5c4...` until independently retested.
- PR ancestry: #3382 is stacked three commits on #3380. #3384 is a sibling implementation branch from common base `8c4c23f...`, 110 commits ahead and does not include #3380's eight unique commits; both #3380 and #3384 change `test/services/sql_task_migration_writer_test.dart`. Resolve this overlap before integration.
- Documentation audit report is on PR #3388 at `docs/ARVIN_REPOSITORY_HEALTH_AND_CONSOLIDATION.md`; #3388's state page now points to REV9 PR #3340 as the canonical documentation candidate, still unmerged.



---

## COMMAND 07-A.2.33 — Home clock regression evidence (2026-11-12)

- Build run `43269800292` on candidate `eea746dbf2a58cd4f04c66a149ae3441264da5b2`: quality test-1 completed FAILURE, 202 passed / 1 failed. Failing test: `test/widgets/home_page_test.dart — Home uses the five checkbox filters as combined filters and preserves time grouping`.
- Root cause confirmed by source inspection: `_iranWallClockNow()` reads `IranClock.now()`, while `_groupJalaliDate()` reads `DateTime.now()`; HomePage/ArvinApp have no injectable `nowProvider`. The failing fixture sets due time to 10:00 based on today's date; the live CI Iran clock is later, so the item is correctly classified overdue instead of today's group. This is a PRODUCTION DEFECT in deterministic clock ownership and a time-dependent test fixture, not a reason to weaken the assertion.
- Required fix per COMMAND 07-A.2.33: inject one `nowProvider` into Home and use it in both clock paths; test fixed current time 09:00 with due time 10:00. Keep the five-filter contract (Time, Center, Project, Category, Tag) from the later 2026-11-10 owner directive; do not remove Center based on older four-filter wording.
- SQLite Snapshot `43269800257` and Follow-up Persistence `43269800526` remain SUCCESS on this candidate; Device Smoke `43269800280` remains QUEUED. Build is still incomplete and failed at least one shard.



---

## COMMAND 07-A.2.33 — correction to G1 fixture disposition (2026-11-12)

- Correction: the earlier description of commit `eea746d...` as a fixed G1 fixture was premature. New Build `43269800292`, test-5, proves the fixture still fails before Migration with `SqliteException: no such table: tasks` because the fixture attempts to insert its parent before creating the table.
- Therefore G1 malformed-payload fixture remains TEST HARNESS DEFECT / INCOMPLETE. The production FK check was not the failure in this new run; the test setup failed at its parent insert. No D01/D05 acceptance is claimed.
- Correct next step: create a schema-compatible `tasks` table in the fixture before inserting `legacy-task`; then create `task_people` with malformed JSON; verify FormatException, transaction rollback, retained source, FK enforcement, JSON repair and same-executor retry.
- Build `43269800292`: test-1 FAILURE (202/1), test-3 FAILURE (155/9), test-5 FAILURE (189/10; includes the G1 fixture error); Debug APK SUCCESS; remaining jobs QUEUED at latest poll. SQLite Snapshot `43269800257` and Follow-up Persistence `43269800526` SUCCESS. Device Smoke `43269800280` QUEUED.


---

## COMMAND 07-A.2.34 — execution continuity addendum (2026-11-12)

**Disposition:** IMPLEMENTATION IN PROGRESS / ACCEPTANCE BLOCKED.  
**Main HEAD verified at start:** `45e4202b03a434459e4c021a04efa7e8396359db`.  
**Execution PR:** #3384, branch `feature/command-07-a-sqlite-contract-remediation`.  
**Latest recorded execution commit:** `ee703dfa82e356039ef32c0b2a9f1bc9a00dc1e9`.  
**Merge / Release / Deployment:** NOT AUTHORIZED.

### New implementation commits (not yet CI-accepted)
- `446f04a6f8cc94871eea0982d9f0f896b8fba8fe` — G1 malformed legacy relation fixture now creates the canonical parent `tasks` table before inserting the parent row. This is a test-fixture correction; migration rollback/retry acceptance remains pending.
- `ab06e7bdf3233d3d971aa64d11782efff71089f1` — Home due-status and Jalali group-date projection now share the injectable Iran wall-clock source.
- `235bfb98e45af68f0d68b00099f97d599504b575` — deterministic Home clock widget coverage added for 09:00 and 10:00.
- `5af39a34ee19e090de30cf6d3e0a5848852fab48` — Home expanded Task card now presents the chronologically latest real Follow-up through `HomeFollowUpPresentationService`; legacy Follow-up date metadata does not fabricate a record.
- `ee703dfa82e356039ef32c0b2a9f1bc9a00dc1e9` — Home regression test now activates the canonical expand control and uses the existing accordion keys; assertions remain present.

### Exact-SHA evidence available before these commits
Build run `43269800292` tested `eea746dbf2a58cd4f04c66a149ae3441264da5b2`, not the new candidate:
- Analyze: PASS; Visual: PASS.
- Test shards 0–5: all FAILED; 1,338 passed / 61 failed.
- Shard failure counts: 0=11, 1=1, 2=21, 3=9, 4=9, 5=10.
- Debug, Staging and Release APK build jobs: SUCCESS. This does not establish release approval or complete artifact acceptance.
- SQLite Snapshot run `43269800257`: SUCCESS, artifact `13966864535`; this is not D01–D05 acceptance.
- Follow-up File Persistence run `43269800526`: SUCCESS; narrow scope only.
- Device Smoke run `43269800280`: preparation succeeded; all seven scenario jobs remained QUEUED at the last inspection.

The six-shard failure inventory remains exactly 61 on the tested historical candidate. Each failure still requires individual root-cause classification; test failures are not presumed to be test defects.

### Clock and Home Follow-up
- Previous clock discrepancy was confirmed in `lib/main.dart`: `_iranWallClockNow()` used `IranClock.now()`, while `_groupJalaliDate()` used `DateTime.now()`.
- The new provider seam makes both projections use the same Iran-local components. New widget tests are committed but not yet executed by CI.
- The Home Follow-up presentation service and its focused unit tests already existed; the Home Task card had not wired the service into the expanded card. The new integration is committed; end-to-end acceptance is pending.

### Governance and preservation
- The old staging branch `staging/command-07-a2-33-recovery` exists but compares 2,371 commits ahead / 0 behind Main; it is not the selected execution lane.
- PRs #3380 and #3382 remain diagnostic evidence lanes and are preserved.
- PR #3388 remains a parallel governance documentation lane with a v49-era authority statement. REV9 on PR #3340 remains the canonical documentation lane; resolve the authority conflict before any documentation integration.
- Vazirmatn is the active owner-directed product font for this command. VazirHarf remains historical/inactive; APK/PDF verification is still required.

### Next actions
1. Obtain CI on the latest execution head `ee703dfa...`; verify the G1 fixture, Home clock and Follow-up integration before further edits.
2. Reclassify all 61 failures from their exact assertions and production contracts; retain coverage.
3. Complete D01–D05 independently, including Backup/Restore and interrupted migration recovery.
4. Complete Category / Project / Tag cross-feature workflows and relationship/deletion policy.
5. Complete PDF, APK font audit, and all seven Device Smoke scenarios on one exact SHA.
6. Keep all changes unmerged and preserve all branches, PRs, artifacts and source data.


---

## COMMAND 07-A.2.34 — live repository checkpoint (2026-11-12)

**Disposition:** IMPLEMENTATION IN PROGRESS / ACCEPTANCE BLOCKED.  
**Main HEAD:** `45e4202b03a434459e4c021a04efa7e8396359db`.  
**Execution PR:** #3384 — OPEN / DRAFT / UNMERGED.  
**Execution branch:** `feature/command-07-a-sqlite-contract-remediation`.  
**Current execution SHA:** `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`.  
**PR base:** `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.  
**PR size at checkpoint:** 121 commits / 73 changed files.  
**Merge / Release / Deployment:** NOT AUTHORIZED.

### Exact-head Actions state

All runs below target the current execution SHA `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`:
- Arvin Draft Review APK (1f4ff4898a5a9278e067c795a8fc14791b8ecbed) — Run `43291144596`: **COMPLETED/SKIPPED**.
- Arvin Device Smoke — Run `43291144527`: **QUEUED**.
- Arvin Build (1f4ff4898a5a9278e067c795a8fc14791b8ecbed) — Run `43291144776`: **PENDING**.
- Arvin Follow-up File Persistence — Run `43291144575`: **PENDING**.
- Arvin COMMAND 07-A.2.20 SQLite Snapshot Evidence — Run `43291144675`: **QUEUED**.
- ARVIN Orchestrator — Run `43291144442`: **PENDING**.
- ARVIN Orchestrator PR Wakeup — Run `43291144484`: **PENDING**.
- ARVIN Production Loop — Run `43291144513`: **QUEUED**.
- The Build run has no allocated jobs yet; pending is not a test result.
- Device Smoke has not allocated the seven scenario jobs yet; preparation queued is not Device Smoke PASS.
- SQLite Snapshot and Follow-up Persistence remain queued/pending; no artifacts are attached to this exact head.
- The previous head `6914b55a...` had Build/Follow-up/Orchestrator runs cancelled after the branch advanced. Its outcomes do not validate the current SHA.
- No current-head APK, PDF, SQLite snapshot or Device Smoke artifact is available.

### New commits since the previous 07-A.2.34 checkpoint

- `019b477f5a9a577a456f208c0389aee91542dd39` — Quick Capture test locates the icon-only Project selector by its canonical key.
- `fb135349869fdcd6916db1e07a1635ae148940e5` — Task Editor test targets the canonical taxonomy create field.
- `41710714ffc2c9678dc1675d9ae9159611c91e30` — Device Smoke font-preference reboot test uses bounded frames.
- `6914b55a887fba26ab387bdf4a111bc533102411` — Navigation test rebuilds the selected destination in its widget harness.
- `bc37933ca591b135b4b943d4187e1f19c695e4b1` — Home displays the latest real Follow-up in the compact Task card.
- `1f4ff4898a5a9278e067c795a8fc14791b8ecbed` — Task Details test passes the actual Scrollable to `scrollUntilVisible`.

These commits are IMPLEMENTED; none is accepted until its focused and exact-head regression evidence is available.

### Historical 61-failure inventory — shard-count correction

The verified distribution on historical Build `43269800292`, SHA `eea746dbf2a58cd4f04c66a149ae3441264da5b2`, is:

| Shard | Failure records |
|---|---:|
| 0 | 11 |
| 1 | 1 |
| 2 | 21 |
| 3 | 9 |
| 4 | 9 |
| 5 | 10 |
| **Total** | **61** |

This is confirmed by the six original job logs: 131362983437, 131362983185, 131362983684, 131362983229, 131362983512 and 131362983153. A prior shard distribution written in this document was transposed; the table above is the corrected source-of-truth distribution. The records remain historical to `eea746d...`; the current candidate must be judged only by its own run.

### Static product-integrity findings

- **SQLite:** D02 has explicit Missing / NULL / FALSE / TRUE preservation coverage. D03 has Follow-up ID/order/unknown-field and Person-link coverage. D04 has a real backup file read and restore into a different file-backed SQLite database, followed by close/reopen and Reminder/Follow-up/Person/FK assertions. D05 has a malformed `task_people` source test for rollback, source retention, FK re-enable, repair and same-executor retry. These are test implementations, not accepted gates until executed on `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`. D01 still requires full historical schema/index/trigger/FK parity acceptance.
- **Category / Tag:** canonical runtime reads and writes use `TaskStore` and SQLite. Referenced Task values are protected from deletion.
- **Project:** `ProjectStore` persists Project and Task-ID membership in the canonical SQL database. Non-empty Projects are not deletable; archive preserves their item references.
- **Confirmed cross-feature gap:** `ProjectTemplateManagementPage` still edits template Category and Tags through free-text fields, rather than the canonical Category/Tag selectors. Task/Project template snapshots also retain Category/Tag values, while current catalog deletion checks only inspect canonical Task references. This leaves template-to-catalog consistency and deletion semantics unresolved. Fix the UI and add template-reference-aware deletion tests before C01/C03/C04/C05 can be accepted.
- **Consolidation candidates:** `TaskTaxonomyLifecycleService` overlaps `TaskTaxonomyMutationService` (the management page uses the latter; the former has a separate unit-test file). `TagStore` still contains a SharedPreferences implementation while current runtime catalog operations are in `TaskStore`; do not delete either until a complete reference/compatibility audit proves it safe.
- **Typography:** the candidate declares Vazirmatn weights 300/400/500/600/700 and optional System Default. VazirHarf assets remain historical files, not registered in `pubspec.yaml`; current-head PDF/APK packaging evidence is still pending.

### Repository / governance inventory

- Branch API inventory: **1,430 branches**, **1,356 unique head SHAs**, **35 duplicate-head groups covering 109 refs**. Duplicate heads are review candidates only; no branch is presumed safe to delete.
- Open PR count: **117**.
- PR #3380 remains OPEN / DRAFT and contains the diagnostic executor-lifecycle evidence.
- PR #3382 remains OPEN / DRAFT and is stacked on #3380; it carries separate raw-SQL diagnostic evidence.
- PR #3384 is the active execution lane described above.
- PR #3340 remains the REV9 canonical documentation lane (OPEN, not merged).
- PR #3388 remains a parallel v49-era documentation/CODEOWNERS lane (OPEN / DRAFT, not merged); preserve its unique evidence while resolving its authority conflict with REV9.
- `staging/command-07-a2-33-recovery` remains present at `1db6675958b27674e9f46d9c9ea68009f546f96d`; its Main comparison is 2,371 ahead / 0 behind. It is not the selected execution lane.
- Main ruleset `main-protection` (ID 20952260) is ACTIVE, with deletion and non-fast-forward protections. It currently requires zero approving reviews and `require_code_owner_review=false`.
- `.github/CODEOWNERS` is absent from Main. A typography-scoped CODEOWNERS file exists only on unmerged PR #3388; it is not effective on Main.

No branch, PR, artifact, source history, user data, rule or release was deleted or rewritten. No merge, release or deployment was performed.


---

## COMMAND 07-A.2.34 — taxonomy template-reference follow-up (2026-11-12)

A deeper source pass confirmed that the Project Template inconsistency affects more than its editor UI:
- `TaskStore.renameCategoryAndTasks` and `renameTagAndTasks` update canonical Task rows/catalogs in their transaction, but do not rewrite `task_templates.category`, `task_templates.tags_json`, `project_template_tasks.category` or `project_template_tasks.tags_json`.
- `deleteCategoryCatalog` and `deleteTagCatalog` currently delete catalog rows without checking Task Template or Project Template references.
- `ProjectTemplateManagementPage._taskDialog` still uses free-text Category and Tags, so it can create taxonomy values outside the central catalog.

This is a confirmed C01/C03/C04/C05 product-integrity defect, not a test-only issue. The corrective contract is: use the canonical SQLite-backed selectors; update Task and both template domains atomically on rename; block deletion while any Task, Task Template or Project Template definition references the value; preserve all historical template snapshots. Add tests for rename, blocked deletion and generated-Task parity before acceptance.


---

## COMMAND 07-A.2.34 — follow-up checkpoint (2026-11-12)

**Latest execution branch HEAD:** `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`  
**Execution branch:** `feature/command-07-a-sqlite-contract-remediation`  
**Main HEAD at last live check:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Status:** IMPLEMENTATION IN PROGRESS / ACCEPTANCE BLOCKED.

### Additional commits after the previous checkpoint
- `bc37933ca591b135b4b943d4187e1f19c695e4b1` — latest real Follow-up now appears in the compact Home Task card, not only after expansion. The Home record test expects this compact presentation.
- `1f4ff4898a5a9278e067c795a8fc14791b8ecbed` — Task Detail Person persistence test now passes the actual descendant Scrollable to `scrollUntilVisible`.

### Exact-head Actions at last poll
For `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`:
- Build: `43291144776` — PENDING, no jobs started at last poll.
- Device Smoke: `43291144527` — QUEUED.
- SQLite Snapshot: `43291144675` — QUEUED.
- Follow-up File Persistence: `43291144575` — PENDING.
- Orchestrator: `43291144442` — PENDING.
- Production Loop: `43291144513` — PENDING.
- Orchestrator PR Wakeup: `43291144484` — PENDING.
- Draft Review APK: `43291144596` — SKIPPED.

No result above is a PASS. Do not use historical SHA results as current acceptance evidence.

### Additional root-cause classifications from historical 61-failure inventory
- G1 malformed legacy relation fixture: TEST HARNESS DEFECT; corrected fixture committed.
- Home clock source mismatch: PRODUCTION DEFECT; injectable shared clock committed.
- Home latest real Follow-up absent from Task card: PRODUCTION DEFECT; compact-card integration committed.
- Home accordion test used the wrong interaction/key: TEST CONTRACT DEFECT; now uses canonical expand control and widget keys.
- Quick Capture Project selector finder used hidden text instead of icon-only control key: TEST HARNESS DEFECT; corrected.
- Task Editor taxonomy create finder used a stale TextField label: TEST HARNESS DEFECT; corrected to the real create-field key.
- Device Smoke contract rejected unbounded `pumpAndSettle` in an integration smoke test: TEST HARNESS DEFECT; replaced with bounded frames.
- Bottom Navigation test did not rebuild its selected destination: TEST HARNESS DEFECT; StatefulBuilder added.
- Task Detail Person test passed a ListView finder where a Scrollable was required: TEST HARNESS DEFECT; corrected.
- Follow-up Entry selected-person assertion still fails on the historical candidate and remains UNRESOLVED pending exact-head CI and deeper reproduction.

### Remaining acceptance gaps
- D04 remains RED: existing backup format is a portable JSON document; no test yet proves restore into an independent SQLite file, close/reopen of that restored file, and integrity/FK checks with Reminder, Follow-up and Person relations.
- D01 custom legacy Index/Trigger preservation lacks a focused fixture test. Migration code fails closed when unsafe custom objects prevent table retirement; preserve this behavior.
- C07 comprehensive end-to-end workflow across Category, Project, Tags, Person, Task, Reminder, Follow-up, Home, Calendar, Search, Reports and controlled deletion has not been demonstrated as one isolated-database scenario.
- CODEOWNERS was not found at root, `.github/CODEOWNERS` or `docs/CODEOWNERS`. Rulesets/branch protection remain unverified because no direct repository ruleset action was available.

### Repository topology
- PR #3384 base relationship reported as `fix/wave3-cycle3-calendar-product-repair`; execution branch compares 120 commits ahead / 0 behind that base.
- Execution branch compares 2,320 commits ahead / 0 behind Main; do not treat this as a direct merge candidate.
- PR #3380 and #3382 remain separate diagnostic/evidence lanes.
- PR #3388 remains the v49-era documentation lane; REV9 PR #3340 remains the canonical documentation lane. Preserve both pending explicit reconciliation.


---

## COMMAND 07-A.2.34 — SQLite acceptance test additions (2026-11-12)

**Latest execution candidate:** `fd22fe37f0190818084f011bfcce00e241da6933`  
**Execution branch:** `feature/command-07-a-sqlite-contract-remediation`  
**Status:** IMPLEMENTATION IN PROGRESS / ACCEPTANCE BLOCKED.

### New P0 tests committed
- `f6db4d9a043b93d3477fa96ae9f88c4f504385a0` — added `test/services/sqlite_backup_restore_file_test.dart`. It creates separate source and destination `NativeDatabase(File)` files, writes the canonical portable backup document, restores into the independent destination database, closes/reopens it, and verifies Task, TaskReminder, Follow-up, Person, Project, Category/Tag relationships, `PRAGMA integrity_check`, `PRAGMA foreign_key_check` and enabled foreign keys.
- `1bc1cc99c8562d42917ba27f4fa5110faa955515` — added a G1 migration fixture with a custom Task index and trigger. The expected safe behavior is fail-closed deferral of legacy column retirement, preserving both custom objects and proving the trigger still fires.
- `fd22fe37f0190818084f011bfcce00e241da6933` — explicitly terminates the custom trigger fixture SQL statement.

These are test additions, not acceptance results. D01 and D04 remain YELLOW until focused tests and full exact-head Build pass.

### Exact-head Actions
For `fd22fe37f0190818084f011bfcce00e241da6933`:
- Build `43293411996`: PENDING.
- Device Smoke `43293412058`: QUEUED.
- SQLite Snapshot `43293411971`: QUEUED.
- Follow-up File Persistence `43293412060`: QUEUED.
- Orchestrator PR Wakeup `43293411950`: QUEUED.
- Orchestrator `43293412413`: QUEUED.
- Production Loop `43293411953`: PENDING.
- Draft Review APK `43293412082`: SKIPPED.

No PASS is recorded for this candidate. All historical evidence remains tied to its original SHA.


## COMMAND 07-A.2.34 — live continuation update (2026-11-13)

- Main HEAD verified: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Execution PR #3384 branch: `feature/command-07-a-sqlite-contract-remediation`; pre-correction tested HEAD `d6af169ca5eab6a639a2251a5da658936fa119a5`; two analyzer-only corrections committed as `b13f72628272b9d172fd84d297c6417abf1e2a9e` and `cde28b0925708439f48a49a9b85257ef40ccc4ef`. Current branch HEAD: `cde28b0925708439f48a49a9b85257ef40ccc4ef`.
- The two corrections replace string concatenation with interpolation and remove a dead null-aware fallback in the independent-file restore test. No test assertion was removed or weakened.
- Build `43295216022` on prior SHA `d6af169...`: Analyze failed on those two warnings; all six test shards failed with 61 records (distribution 11/1/21/8/9/11); Debug, Staging and Release APK build jobs and Visual structural smoke passed. These results do not validate the new SHA `cde28b...`.
- SQLite Snapshot `43295215993` and Follow-up Persistence `43295215997` passed on `d6af169...` only. They are not full D01–D05 acceptance.
- Device Smoke `43295216057` on `d6af169...`: Task Lifecycle passed; Reminder/Follow-up lane failed its person-selection assertion; Calendar lane was cancelled; remaining lanes were cancelled or still running at the recorded poll. Seven-scenario acceptance is NOT VERIFIED.
- No exact-SHA workflow run or status check was returned for `cde28b...` at this checkpoint. Re-run Analyze and applicable tests on that SHA before treating the lint correction as verified.
- SQLite D01–D05 remain unaccepted. D04 independent-file test code exists but needs exact-SHA execution; D05 controlled interruption/rollback/retry/reopen remains unverified.
- Regression inventory remains 61 failure records on the last fully observed Build SHA; classify each only after matching its exact test/log to production code. No aggregate test-defect classification.
- Typography: the 2026-11-13 owner command resolves REV9-004: Vazirmatn only as official/default; System Default optional; VazirHarf inactive/historical. APK/PDF and SHA256 acceptance remain pending.
- Mission: IMPLEMENTATION IN PROGRESS; acceptance blocked. No merge, release, deployment, branch deletion or history rewrite.
