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
