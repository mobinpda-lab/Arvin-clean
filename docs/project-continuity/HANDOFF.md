# REV8 NEXT-AGENT HANDOFF — 2026-11-10

## First actions
1. Read MASTER_GOVERNANCE.md, CURRENT_STATE.md, OPEN_ISSUES.md, PRODUCT_DECISIONS.md, then audit/FINAL_REPOSITORY_HEALTH_REPORT.md.
2. Re-read live Main and authorized branch refs. Main expected 45e4202b03a434459e4c021a04efa7e8396359db; working branch was 9846f10850031c63964fdc81ae0ab1cdb3028517 before this audit commit. Never assume it is still current without fetching.
3. Confirm PR #3052 remains OPEN / DRAFT / UNMERGED. Main is READ-ONLY.
4. Recheck Build, six shards, Device Smoke, Calendar Provider and Follow-up Persistence on one exact SHA. Current recorded Build failed 78 distinct labels; Device Smoke is pending.
5. Do not transfer older 79-failure results from SHA b789 to the current SHA.
6. No code/test/schema/migration/workflow/security changes are authorized by this documentation audit. Wait for a valid technical implementation authorization before modifying executable code.
7. Do not delete branches/PRs/commits/tags/releases, tests, migrations, tables or workflows. Review cleanup candidates with Mobin first.

## Current blockers
- Build 42795405617 on SHA 9846 failed six shards (1,296 passed / 78 failed).
- Device Smoke 42795405388 is PENDING; no physical-device acceptance.
- Reminder four-state semantics are undefined; do not guess.
- Auto-Save is APPROVED but full-field durability remains PARTIAL.
- Home/Quick Capture/filter, Follow-up/People, Checklist, Notebook and Report acceptance have failing tests.
- Notebook hard-delete preservation, Template deep clone/date-base, full Backup/Restore integrity and Sync/P2P E2E are NOT VERIFIED.
- NIRA Queue Scheduler failed while reporting on issue #162 (>2,500 comments); underlying dispatch error may be masked.
- NIRA state-sync PR churn and L10 remain unresolved/UNVERIFIED.

## Recommended next execution order
1. Obtain explicit Reminder state names/transitions from Mobin.
2. Diagnose current 78 failing tests; fix root causes only under valid authorization, never weaken tests.
3. Complete Device Smoke and physical-device acceptance on the exact candidate SHA.
4. Verify migration/Backup/Restore, Notebook deletion, Template Deep Clone and occurrence/checklist history.
5. Repair NIRA scheduler feedback and state-sync idempotency in NIRA's own authorized lane.
6. Review duplicate branch/PR/code cleanup candidates; destructive actions require separate explicit approval.

## Release gate
BLOCKED — RELEASE: NO-GO. No merge or release without all exact-SHA gates, physical-device acceptance, data/security evidence and explicit Mobin acceptance.

---

## Historical handoff entries (preserved)

# REV7.2 NEXT-AGENT HANDOFF — 2026-11-10

## First action
1. Read MASTER_GOVERNANCE.md, then CURRENT_STATE.md, OPEN_ISSUES.md and PRODUCT_DECISIONS.md.
2. Re-read live Main and branch refs before any write. Expected authorized branch: fix/recovery-calendar-device-smoke-2026-10-31; last audited head: b789343c9699ca440d043d71d47db3dcdfafa57c; Main: 45e4202b03a434459e4c021a04efa7e8396359db.
3. Confirm PR #3052 is still OPEN/DRAFT/UNMERGED. Main is read-only.
4. Check exact-head Build, six shards, Device Smoke, Calendar Provider and Follow-up Persistence. Do not transfer a PASS across SHAs.
5. Continue only the documentation deployment if it was not yet completed; if completed, verify the single commit and all eight files before any further work.
6. Do not change code/tests/schema/migrations/workflows/security, PR metadata, Main, merge or release under this governance order.

## Current blockers
- Build 42763952581 failed all six test shards (79 failures); logs and test names are in OPEN_ISSUES.md.
- Device Smoke 42763952498 is incomplete; only preparation passed, Boot was in progress and six lanes queued at last poll.
- Reminder four-state semantics are not defined in the reviewed TaskReminder model; do not guess.
- Auto-save is APPROVED (ARVIN-DEC-2026-11-10-001) but full-field and exit/reopen acceptance is not verified.
- Template due-date/center/project propagation and Notebook hard-delete/unlink/title-on-first-save remain gaps.
- Actual user database and backup have not been inspected; do not run destructive migrations.
- NIRA L10 remains UNVERIFIED; Queue Scheduler last run failed.

## Execution order
Wave 0 docs first; Wave 1 data integrity next after Reminder semantics and real DB/backup inspection; Wave 2 core lifecycle; Wave 3 Home/Quick Capture/filters; Wave 4 Notebook/Calendar/Templates; Wave 5 reports/sync/NIRA and enterprise acceptance. See ROADMAP.md for detailed acceptance criteria.

## Release gate
BLOCKED — RELEASE: NO-GO. No merge or release without all exact-SHA gates, physical-device acceptance, data/security evidence and explicit Mobin acceptance.

---

## Quick Capture tighter visual compression — 2026-11-04
- Follow-up UI-only pass on the existing compact Quick Capture form. No field order, row membership, widget keys, horizontal selector structure, selected values, priority enum, color palette, Vazirmatn font family, semantics, callbacks, validation, task construction or persistence behavior was changed.
- Compact ArvinRollBox and ArvinTagRollBox controls reduced from 42dp to 40dp; compact icons reduced from 18dp to 16dp, icon/text gap from 6dp to 4dp, horizontal inset from 10dp to 8dp, compact label size from 11.5sp to 10.5sp. The 40dp minimum touch target is retained.
- Quick Capture cards reduced from 8dp to 6dp padding; top/bottom sheet padding tightened; title/header and description TextFields use dense decoration and reduced vertical content padding; inter-card/row gaps and horizontal gaps tightened without changing order.
- Four priority controls remain 40dp with the same Persian labels, explanatory helper row, colors and selected enum values. Footer actions remain at least 40dp and aligned in their existing row.
- Inner vertical scrolling remains as a safety fallback for keyboard, short screens and text scaling. A claim of zero vertical scrolling on every device is not made until verified on the physical SM-A528B/DS.
- Updated geometry test from 42dp to 40dp; no test/assertion removed, weakened, skipped or bypassed. Fresh exact-SHA CI is required.
- Physical before/after screenshot: NOT VERIFIED in this environment.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; BLOCKED — RELEASE: NO-GO.

## Quick Capture priority helper row refinement — 2026-11-04
- Four canonical priority chips now show only «اولویت ۱» through «اولویت ۴» in 40dp-high controls; the four existing explanatory labels appear in a separate compact helper-text row immediately below.
- Existing priority enum values, ordering, selected-state animation, color mapping, tap callbacks and Semantics labels (including the explanatory text) remain unchanged.
- This refinement supersedes the in-flight CI started on prior SHA `d83683e47c0d3f6c3ca3fdf10504bc93aebd39d0`; its results are not acceptance evidence for the final SHA.

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

## Task Details UI redesign handoff — 2026-11-04
- Review `lib/task_detail_page.dart` and `test/task_detail_master_screen_test.dart`.
- UI-only source checkpoint before continuity sync: `86c6c9bbaaa8bc83626effb9aa52f6e52c94a3d0`.
- Key acceptance: no «افراد مرتبط», person chips, or avatar presentation anywhere in Task Details; the Task.people collection itself must remain untouched. Bottom buttons must remain wired to the existing delete/complete/edit callbacks.
- Checklist: progress fraction and progress bar must remain; «افزودن مرحله جدید» uses the original checklist add handler. Existing CRUD tests must continue to pass.
- Verify Analyze and the focused Task Details / checklist CRUD / checklist flow / Follow-up flow / due-date / calendar export tests, then all required full CI gates on the final documentation-synchronized SHA. No result from an earlier SHA transfers.
- Keep PR #3052 OPEN / DRAFT / UNMERGED; do not touch main or release. **BLOCKED — RELEASE: NO-GO.**

## Quick Capture test reconciliation — 2026-11-04
- Build run `41834832972` on SHA `2549a98ab6d3de3498ab17fc007debf34f105055`: Analyze PASS; Shard test-1 FAILED with 174 passed / 1 failed.
- Exact failure: `test/quick_capture_dialog_test.dart:321`, test `canonical capture keeps title-only path and optional choices`; the old assertion expected the approved description field to be absent. A second obsolete absence assertion existed in the full-form handoff test.
- Updated both finders to assert the description field exists and added empty-description assertions for title-only / no-description handoff. No test was deleted, skipped, timed out or weakened; the assertion now checks the newly approved UI contract.
- Test correction commit: `fdbb6f10bb2fed4233384478c74c86c9778def90`. All workflows on SHA 2549 remain evidence only for that older SHA; the correction requires a fresh exact-SHA run.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

Next: verify all fresh workflow runs on the final documentation SHA. In particular confirm the Quick Capture widget tests now pass, then inspect each Build shard, seven Device Smoke lanes, Calendar Provider, Follow-up Persistence and review APK. Never transfer older-SHA results.

## Quick Capture implementation refinement — 2026-11-04
- Latest source/test checkpoint before this continuity refresh: `2349dc2cdffeae440e525a89842912d681123b26`.
- Focused test commits: `15212f6f5151c8436f041021d96ca7042bcf0015` (ensure-visible interaction and full-width submit geometry) and `2349dc2cdffeae440e525a89842912d681123b26` (remove obsolete test import).
- Live PR metadata at this checkpoint: OPEN / DRAFT / UNMERGED; branch HEAD equals the checkpoint SHA.
- GitHub Actions query for this SHA returned zero workflow runs; commit status is pending with zero contexts. CI is NOT VERIFIED and must not be reported as passing.
- Keep release BLOCKED — RELEASE: NO-GO.

Next operator: run/dispatch the complete Build (Analyze + six shards) and required exact-SHA Device Smoke, Calendar Provider, Follow-up Persistence and review APK workflows on the final docs-synchronized SHA. Inspect failures and do not weaken assertions.

## Quick Capture redesign handoff — 2026-11-04
- Owner-approved scope: redesign only the Quick Task Registration UI; preserve four-level canonical priority enum/data and all existing selection/capture pathways.
- Source/test implementation checkpoint: `9aaa51dea8957a8f755e57f6d9bb05724a6f00f1`. Inspect `lib/quick_capture_dialog.dart` and `test/quick_capture_dialog_test.dart` before further edits.
- Four priority chips must remain in enum order high/medium/low/none and persist the same TaskPriority values; visible labels are «اولویت ۱» … «اولویت ۴», with Persian helper captions. Do not display P1–P4.
- Description is captured in canonical Task.description. Confirm success/reset behavior, empty-title feedback, RTL layout at 320px and tablet widths.
- Verify exact-SHA Analyze and all test shards, especially quick_capture_dialog_test.dart. Do not treat this code checkpoint as verified until final SHA workflows complete.
- Continuity update is required after every subsequent material source or CI checkpoint. PR remains OPEN/DRAFT/UNMERGED; main untouched; release NO-GO.

## Quick Capture redesign handoff — 2026-11-04
- Owner-approved scope: redesign only the Quick Task Registration UI; preserve four-level canonical priority enum/data and all existing selection/capture pathways.
- Source/test implementation checkpoint: `9aaa51dea8957a8f755e57f6d9bb05724a6f00f1`. Inspect `lib/quick_capture_dialog.dart` and `test/quick_capture_dialog_test.dart` before further edits.
- Four priority chips must remain in enum order high/medium/low/none and persist the same TaskPriority values; visible labels are «اولویت ۱» … «اولویت ۴», with Persian helper captions. Do not display P1–P4.
- Description is captured in canonical Task.description. Confirm success/reset behavior, empty-title feedback, RTL layout at 320px and tablet widths.
- Verify exact-SHA Analyze and all test shards, especially quick_capture_dialog_test.dart. Do not treat this code checkpoint as verified until final SHA workflows complete.
- Continuity update is required after every subsequent material source or CI checkpoint. PR remains OPEN/DRAFT/UNMERGED; main untouched; release NO-GO.

# Handoff — First Actions for the Next Operator
Checkpoint: 1405/08/13 — 2026-11-04 12:53 Asia/Tehran
Repository: mobinpda-lab/Arvin-clean
Branch: fix/recovery-calendar-device-smoke-2026-10-31
Last verified app/source baseline: 33f9489b4c7f3fa6173459b6994cea2a5469f500
Last verified documentation branch HEAD before this handoff refresh: e02fd9cc6a880bf7f717902755edcb38d82b14e2 (refresh live branch HEAD before acting)
PR #3052: OPEN / DRAFT / UNMERGED
Release: BLOCKED — RELEASE: NO-GO

## First action — refresh live state
1. Read the current branch ref and PR #3052. Confirm they still point to the same head and PR remains open/draft/unmerged.
2. Record Device Smoke run 41805555579 as CANCELLED on SHA 33f9489. Preparation, Boot, Navigation and Quick Capture succeeded; Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View and Task Lifecycle were cancelled. Do not treat it as a complete pass. Inspect workflow runs for the latest documentation HEAD before starting any new run, to avoid duplicate dispatches.
3. Inspect Calendar Provider run 41805555462 and preserve its failure classification: Dart Development Service failed to start; zero tests executed. Diagnose the test-runner/emulator startup issue without changing or skipping the acceptance test, then rerun on the new exact SHA.
4. Confirm Build 41805555476 and Persistence 41805555397 remain the historical exact-HEAD successes; do not transfer them to any later commit.
5. Obtain a current-SHA Draft Review APK only through the existing workflow; the last known run 41805393577 was cancelled on older SHA b85ed7b.

## Product-owner decision gate
Do not change Quick Capture validation behavior or its test until the owner explicitly decides whether the compact form should show one inline message or both inline and floating SnackBar presentations. Preserve all assertions and the current compact layout meanwhile.

## Then continue
- Re-run Report Center filter tests and produce a fresh screenshot on the active candidate SHA.
- Verify Center > Project > Category > Task consistency across the actual app flows; report gaps rather than infer full coverage.
- Keep Local P2P QR/PIN and LWW/tombstones as proposals only until security review and owner approval.
- Do not remove legacy scheduling/schema fields or perform destructive migrations without real database inspection and a data-preserving plan.
- Update CURRENT_STATE.md and this HANDOFF.md after each meaningful checkpoint; append chronology to root CHANGELOG.md and detailed evidence to docs/ARVIN_CONTINUATION_LEDGER.md.

## Non-negotiable guardrails
- No main edits/pushes; no merge; PR #3052 stays OPEN / DRAFT / UNMERGED.
- No test deletion, skip, weakening or artificial timeout.
- Vazirmatn only.
- No unverified PASS claims; every result tied to exact SHA.
- Release remains BLOCKED — RELEASE: NO-GO.

## Local working tree
NOT VERIFIED. GitHub branch data does not reveal uncommitted local modifications.


## Quick Capture compact-layout handoff — 2026-11-04
- Latest source correction: `642a4016cbaa1994b4dfe2d278066941ef8a65c2` adds the missing `ArvinTagRollBox.compact` field. The pre-fix Staging compile failure is documented in `CURRENT_STATE.md`.
- Next action: refresh branch/PR HEAD, then validate Analyze + all six Build shards, full seven-lane Device Smoke (including `smoke-quick-capture`), Calendar Provider, Follow-up Persistence and Draft Review APK on one exact final SHA. Inspect job logs for failures; do not change assertions to make them pass.
- Compact values: roll-box/tag selectors 40dp high, 8dp horizontal inset, 16dp icons and 10.5sp labels; priority chips 40dp; tighter dialog/card/field vertical spacing. Field order, names, callbacks, persistence and actions must remain unchanged.
- Keep the vertical scroll fallback for small screens, keyboard and text scaling until physical-device evidence demonstrates safe full-screen fit. Never claim no-scroll acceptance without a current screenshot/device run.
- Reference image `photo_1793800214435.webp` was not available for inspection in this execution; pixel-level conformity remains NOT VERIFIED.
- PR #3052 OPEN / DRAFT / UNMERGED; no `main` writes; no test removal/skip/weakening; release BLOCKED — RELEASE: NO-GO.


## CI follow-up handoff — target `a657691` (2026-11-04)
- Analyze blocker on exact SHA: `unnecessary_const` at `lib/quick_capture_dialog.dart:587:42`; Build run `41843444962`. Inspect the precise widget expression and remove only the redundant const if confirmed; do not touch tests or timeouts. Then rerun exact-head Build and all dependent gates.
- Quick Capture widget test assertions for compact RTL layout and 40dp chips exist, but shard results were not final at this checkpoint. Scroll-free fit remains unverified: dialog still uses a `SingleChildScrollView`; require measured layout assertion or emulator screenshot evidence before acceptance.
- Draft Review APK run `41843444971` was still assembling; no artifact had been published at the last artifact-list check. Recheck run conclusion and artifacts before sharing any APK.
- Persistence run `41843445148` passed exact SHA; Device Smoke `41843451312` and Calendar Provider `41843445191` were still running/queued. Do not claim all gates green.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; no main edits, no test deletion/skip/weakening/artificial timeout; release BLOCKED — RELEASE: NO-GO.


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


## Module-Core-Logic audit handoff — 2026-11-05
- Last reviewed source SHA: `4021c84ceb14faf4f6559379cf67dd94955bffe4`; refresh PR/branch before acting.
- Canonical audit record: `docs/project-continuity/PRODUCT_DECISIONS.md` → “Module-Core-Logic v1.0 — live code crosswalk”. Do not create a second module document.
- Important implementation gap: `FollowUpReminderDeliveryService.due` currently includes disabled TaskReminders; the planner's enabled check does not protect the actual background delivery path. Also `TaskStore.addTaskReminder` has no explicit idempotency key/duplicate guard.
- Legacy fields remain in model and SQL. Do not remove or destructively migrate them until real user DB values and backup/rollback are inspected.
- Fixed Android scheduler ID is 42002; notification IDs are stable-key hashes, with 42002 only as hash-zero fallback.
- Exact-SHA results on the last reviewed SHA: Analyze PASS; test-0/1/3/5 PASS; test-2/test-4 FAIL; visual golden FAIL; Follow-up Persistence PASS; Calendar Provider PASS; Device Smoke 4 PASS / 3 CANCELLED.
- Review removed/rewritten tests in the PR diff and produce an owner-approved scenario replacement map. No explicit skip/timeout addition was detected, but complete preservation is NOT VERIFIED.
- The previous Module-Core-Logic verbatim text was not retrievable during this audit; obtain it before declaring the full v1.0 text validated.
- No code or test fix is authorized by this audit record. PR remains OPEN / DRAFT / UNMERGED; main untouched; release NO-GO.
## UI design system handoff — 2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- Canonical token source: `lib/core/theme/arvin_theme.dart`; semantic palette: `lib/arvin_colors.dart`.
- Active tokens: #3F3D56 primary, #2D2B42 header, #F7F8FC canvas, #FFFFFF cards, 16px radius, 4% black soft shadow (blur 10 / offset 0,4), Vazirmatn.
- Keep Persian visible priority labels «اولویت ۱»…«اولویت ۴» (mapping high/medium/low/none); do not introduce English P1–P4 text. Preserve status semantic colors and Center → Project → Category → Tags.
- Global CardTheme is in place, but audit/convert remaining custom-decorated surfaces in Task Lists, Task Details, Calendar and Quick Entry before claiming whole-app uniformity. No UI business logic or data model change is intended.
- Run Analyze, new token test, focused widget tests and full CI on final SHA; capture physical-device screenshots for visual acceptance.
- PR #3052 OPEN / DRAFT / UNMERGED; main untouched; release NO-GO.

 
## TaskHomeScreen handoff — 2026-11-05 13:02 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- Start with `docs/project-continuity/task_home_screen_spec.md`; it is the canonical fourteen-point approved Home contract.
- Review the Home implementation in `lib/main.dart` (`HomePage` / `_HomePageState`), sorting in `lib/services/task_list_sort_service.dart`, metadata chips in `lib/widgets/taxonomy_icon_row.dart`, and primary navigation in `lib/widgets/arvin_primary_navigation.dart`.
- The latest source changes are recorded in `IMPLEMENTATION_LOG.md`. Do not assume any prior-SHA test result validates the latest documentation SHA.
- Poll Build Analyze and all widget-test shards on the final HEAD. Current baseline on SHA `e0af4008aacf2beba173e5f1af87852e016e3113`: Analyze PASS; test-2/test-4/test-5 failed and the Task Details visual golden timed out; the Device Smoke run was cancelled with only some lanes completed. These are historical baseline findings, not evidence for later commits.
- Preserve all existing tests and assertions. Do not skip, weaken, remove, bypass or time out any test. Fix only genuine product/source defects and retain failing evidence.
- Physical Naskh glyph rendering and full Home visual acceptance remain NOT VERIFIED until a physical-device screenshot is inspected.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

 
## TaskHomeScreen analyzer correction — 2026-11-05
- An intermediate Analyze run on source checkpoint `da311c2f7e4ef9b96fc20a26e31eca996fa63d50` found the plugin import had also been removed even though the app-level notification tap handler still uses `NotificationResponse`, and found an orphan private `_openPendingReminder` helper after removing the Home bell.
- Corrected in `c0766a5e602d04426486816e95cad4038b667fa7`: restored the plugin type import for the retained notification-response path and removed the now-unreferenced pending-notification helper. The Home header remains bell-free.
- No test files or assertions were changed. Analyze and widget tests on the corrected/final SHA remain NOT VERIFIED until a fresh exact-SHA run completes.

 
## TaskHomeScreen final source delta — 2026-11-05
- Added an explicit accessible semantic label to the independent Home sort action: `72e6779f268bb0ca971b651ad0228604b504f4c8`.
- Ensured the Past group heading also uses the calendar icon when Past is selected directly from the Time filter: `460a40b6411c6c63691817e45ef00aab61544bd8`.
- These are source-only follow-ups; no test file or assertion was changed. The latest exact-SHA Build and Device Smoke runs must complete before any PASS is recorded.


## AIPOS v1.0 handoff — 2026-11-05
### نخستین گام بعدی دقیق
1. تصاویر مرجع تأییدشده بسم‌الله و تفویض را از مالک محصول دریافت کن؛ بدون آن‌ها خوشنویسی path-based را حدس نزن و تطابق را تأیید نکن.
2. HEAD زنده PR #3052 را بخوان؛ ثبت مستندات SHA را تغییر داده است.
3. سپس SVGهای واقعی را اضافه و در Home/Calendar با SvgPicture.asset و Semantics یکتا جایگزین کن؛ تست ساختاری و روشن/تاریک/چنداندازه را حفظ/تکمیل کن.
4. Build/Analyze، همه شاردهای تست، هفت Device Smoke lane، Calendar Provider و APK Debug/Release را روی یک SHA نهایی اجرا کن.
- Lock sync و Follow-up persistence موفق بودند؛ سایر وضعیت‌ها در CURRENT_STATE و OPEN_ISSUES ثبت شده‌اند.
- PR #3052 OPEN/DRAFT/UNMERGED؛ main untouched؛ BLOCKED — RELEASE: NO-GO.


## Next operator handoff — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06
**Current truth:** authorized branch HEAD `105737b1e4d5f9e2d6e35dfc7c9f4bfd5b1cbdda`; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO. Smoke run `42169009238` is IN_PROGRESS but not complete: Boot and Navigation are CANCELLED, Calendar is still running, and the other listed lanes succeeded.

**First action:** inspect the live status and logs of run `42169009238`, determine why Boot and Navigation were cancelled, and let the Calendar lane reach a terminal result. Then run/confirm a complete seven-lane Device Smoke on the latest post-documentation commit SHA. Do not accept partial lanes, suppress failures, weaken assertions, or add artificial timeouts.

**Already present at the audited source SHA:** completed Follow-up reporting is inside the unified Report Filters sheet and the standalone top-level action is absent; Quick Capture empty-title feedback is both inline and a floating SnackBar, with its original widget test asserting both. Preserve these implementations and tests.

**After the new documentation commit:** read branch HEAD, PR metadata, new workflow run IDs, each test shard and artifact status. Record only exact-SHA evidence. Do not edit main, close/ready/merge PR #3052, or release. Local working-tree state remains NOT VERIFIED by this remote handoff.


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

## TODO handoff — 2026-11-07 — verified branch HEAD `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`

- نخست `docs/project-continuity/TODO.md` را بخوان؛ این فایل فهرست فعال کارهای باز و معیارهای تکمیل را نگه می‌دارد.
- Staging Review APK برای SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a` آماده و بارگذاری شده است: run `42407484426`، artifact `13588087657`؛ APK SHA-256 `04482b5595eb7666a9a47076eb7c8fdcec480ca7911ab2a8f718ef442276fd90`، اندازه `79,185,749` bytes، package `com.example.arvin.staging`، non-debuggable، V2/V3 و Vazirmatn PASS. این artifact فقط review/test است؛ publishable=false.
- Build run `42407484460` روی همین SHA هنوز کامل نیست: Analyze و Visual PASS؛ شش شارد تست و APK Debug/Staging/Release در جریان‌اند. تست‌های فیلتر تا پایان همین run در انتظار تأیید بمانند.
- Device Smoke run `42407484403` روی همین SHA در وضعیت PENDING و بدون job قابل مشاهده است؛ هیچ نتیجه‌ای از SHAهای قبلی به آن منتقل نکن.
- G1 lock sync `42407484429`، Follow-up file persistence `42407484432` و Calendar Provider `42407484406` روی همین SHA SUCCESS هستند.
- نصب و پذیرش فیزیکی Samsung SM-A528B/DS هنوز تأیید نشده است. Artifact را با نصب واقعی یکی ندان.
- اصلاح overflow فیلتر در commit `2baad457ba0bdd89114566afb4b42e2315904bb2` ثبت شده؛ نتیجه تست‌های مرتبط باید از run جاری استخراج شود.
- پس از تکمیل CI و Device Smoke، پذیرش گوشی واقعی را ثبت کن و TODO را با شواهد جدید به‌روزرسانی کن. هیچ تستی حذف/تضعیف نشود.
- PR #3052: OPEN / DRAFT / UNMERGED؛ `main` در SHA `45e4202b03a434459e4c021a04efa7e8396359db`؛ بدون Merge یا انتشار؛ **BLOCKED — RELEASE: NO-GO**.


---

## Handoff — TODO and Staging APK verification — 2026-11-07

1. ابتدا `docs/project-continuity/TODO.md` را بخوان و وضعیت TSK-01 تا TSK-04 را با شواهد SHA-محور به‌روزرسانی کن.
2. برای تست دستی، از [Staging Artifact run 42406934575](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575/artifacts/13588285590) استفاده کن. این APK روی SHA `2baad457ba0bdd89114566afb4b42e2315904bb2` ساخته شده، نه HEAD فعلی. SHA-256 APK: `dd990f90a1441423c3214e915d528f5f78e6d65ce0045b45b75791ddd1873416`؛ حجم `79,185,752` bytes؛ package `com.example.arvin.staging`. فقط review/test است و publishable نیست.
3. اجرای Build فعلی در زمان handoff: [42408265669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42408265669)، هدف SHA `ad58025592690515020de2c4e3bf0fd0ac65db1b`. Analyze و Visual موفق؛ شش شارد و APKها هنوز در جریان‌اند. Device Smoke [42408265703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42408265703) روی همین SHA در وضعیت PENDING و بدون job است.
4. شارد ۱ اجرای قبلی [42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460) روی SHA `b1ad86a...` برابر 174 passed / 13 failed بود و کل run بعداً CANCELLED شد. این شکست‌ها را به HEAD فعلی نسبت نده؛ منتظر شارد ۱ اجرای جدید بمان و شکست‌ها را بدون حذف یا تضعیف تست‌ها رفع کن.
5. TSK-03 را فقط با شواهد واقعی عرض‌های 360، 390 و 412dp ببند. TSK-04 را فقط پس از بررسی ذخیره/بازیابی SharedPreferences، مقدار پیش‌فرض `#3A86EF`، ۹ گزینه، و رفتار رنگ در صفحات روشن/تاریک ببند.
6. پس از نصب candidate روی Samsung SM-A528B/DS، نتیجه نصب، اجرای بدون کرش، رفتار فیلترها و رنگ سازمانی را با شواهد ثبت کن.
7. PR #3052 باید OPEN / DRAFT / UNMERGED باقی بماند؛ `main` تغییر نکند؛ بدون Merge یا انتشار؛ **BLOCKED — RELEASE: NO-GO**.


---

## Handoff — Connected Notebook architecture decision — 2026-11-07

1. مرجع تصمیم محصول و برنامه شکاف‌ها: `docs/project-continuity/ARCHITECTURE_NOTEBOOK.md` را بخوان.
2. هدف: دفترچه یادداشت «مغز دوم و سکوی اقدام» با Fast Capture، ارتباط دوطرفه با کارها و پیگیری‌ها و فیلترهای هم‌راستا با آروین.
3. Gap Analysis بر پایه کد شاخه در زمان بررسی تهیه شده است: `Task.notebookKind` و `CanonicalNotebookRepository` دفترچه را روی Task canonical نگه می‌دارند؛ Drift جدول مستقل Notebook یا رابطه صریح Note↔Follow-up ندارد؛ صفحه Notebook فیلترهای Category/Project/Tag را جداگانه دارد. جزئیات در سند معماری ثبت شده‌اند.
4. **در این فاز هیچ تغییر کدی برای این قابلیت انجام نشده است**: هیچ فایل `.dart`، اسکیما/مهاجرت دیتابیس یا تستی تغییر نکرده؛ هیچ تستی حذف یا Skip نشده است. این تصمیم صرفاً مستندسازی و برنامه‌ریزی آینده است تا پایداری ریلیز جاری حفظ شود.
5. پیش از پیاده‌سازی، محور پنجم فیلتر پنج‌گانه که در درخواست نام‌گذاری نشده باید با مالک محصول روشن شود. هیچ رفتار فعلی بدون آزمون و تأیید تغییر نکند.
6. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ بدون Merge یا انتشار؛ **BLOCKED — RELEASE: NO-GO**.


---

## Handoff — Notebook architecture + Shard 1 failure analysis — 2026-11-07

1. سند معماری موجود `docs/project-continuity/ARCHITECTURE_NOTEBOOK.md` را مرجع تصمیم محصول بدان؛ آن را دوباره نساز مگر اینکه نیاز مشخصی برای اصلاح متن ثبت شود. فایل در شاخه مجاز موجود و محتوایش بررسی شده است.
2. سند Notebook فقط هدف و Gap Analysis آینده را ثبت می‌کند: Fast Capture با فوکوس فوری، عنوان از خط اول، حفظ متن، یادداشت‌های مستقل و متصل، نمایش «📌 متصل به: [عنوان کار]»، پیمایش دوطرفه و استفاده از فیلتر مشترک. در فاز حاضر هیچ پیاده‌سازی انجام نده.
3. ابهام بُعد پنجم فیلتر را پیش از هر پیاده‌سازی با مالک محصول حل کن؛ چهار محور مشخص‌شده عبارت‌اند از مرکز، پروژه، دسته و برچسب.
4. شارد ۱ run `42407484460`، job `128509578970`، روی SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`: 174 passed / 13 failed. نام و مسیر و علت ثبت‌شده هر ۱۳ مورد در `CURRENT_STATE.md` زیر TSK-02 درج شده است.
5. این شکست‌ها را به HEAD جدید تعمیم نده. در فاز مجاز فعلی فقط گزارش/تحلیل مستند است؛ هرگونه اصلاح بعدی باید پس از مجوز جداگانه و با حفظ همه تست‌ها انجام شود.
6. در این فاز به هیچ وجه `lib/`، `test/`، اسکیما یا migration را تغییر نده؛ هیچ تستی حذف، غیرفعال، Skip یا بازنویسی نشود.
7. مشخصات APK را حفظ کن: حجم `79,185,752` bytes؛ SHA-256 `dd990f90a1441423c3214e915d528f5f78e6d65ce0045b45b75791ddd1873416`؛ artifact `13588285590` از run `42406934575`. این APK از SHA قدیمی `2baad457...` است، نه لزوماً HEAD فعلی.
8. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ Merge و انتشار ممنوع؛ **BLOCKED — RELEASE: NO-GO**.


## Next operator — exact-SHA CI failure on d02cb2df

1. The Draft Review APK run `42451351162` failed during staging APK compilation; it uploaded no APK artifact. Do not provide an APK download link or claim package/hash/size for this SHA.
2. Fix `lib/task_detail_page.dart` compile defects: undefined `due` at lines 1940–1941 and missing `_templateSourceCard()` at line 2182. Analyze also reported unused `_cancelInlineEdit` and `_metadataChip`; resolve warnings without hiding diagnostics.
3. The same compile defects caused Analyze and Visual failure in Build run `42451350930`, and Calendar Provider run `42451350939`. The six test shards and APK debug/release/staging jobs were still running at the checkpoint; re-query final job results rather than assuming outcomes.
4. Follow-up File Persistence run `42451350822` passed. Device Smoke run `42451350903` was pending with no jobs; physical-device acceptance remains unverified.
5. Preserve all tests. No deletion, skip, weakening, timeout or assertion relaxation. After correction, rerun Analyze, all six shards, Visual, Calendar Provider, Follow-up Persistence, Device Smoke and Draft Review APK against one exact SHA.
6. Diagnostic artifact `13606295730` is Calendar Provider evidence only, not an APK. Draft Review APK run has zero artifacts.
7. Keep PR #3052 OPEN / DRAFT / UNMERGED; do not touch main; no merge/release. **BLOCKED — RELEASE: NO-GO**.


---

## Handoff جاری — ممیزی CI و قراردادهای Notebook/Template/Calendar — 2026-11-09

**نقطه شروع اجباری:** ابتدا HEAD زنده شاخه و PR #3052 را دوباره بررسی کن. آخرین SHA ممیزی‌شده پیش از این handoff برابر `76a89e72956325149c090a25caf9cf9e642f3dc7` بود؛ main در `45e4202b03a434459e4c021a04efa7e8396359db`. هر تغییر HEAD یعنی تمام شواهد exact-SHA باید دوباره استخراج شوند.

1. سند مرجع Notebook: `docs/project-continuity/ARCHITECTURE_NOTEBOOK.md` نسخه 2.0؛ این فایل پیش‌تر وجود داشت و اکنون با قرارداد بقای یادداشت، Fast Capture، کاردینالیتی، آبشار taxonomy، فیلتر پنج‌گانه و Gap Analysis به‌روزرسانی شده است.
2. قرارداد الگو: `docs/project-continuity/TASK_TEMPLATE_DATA_CONTRACT.md` نسخه 2.0؛ این نسخه بندهای قدیمیِ عدم انتقال Due Date/انتخاب مجدد دستی Reminder را supersede می‌کند و انتقال offset را الزام می‌داند.
3. `CURRENT_STATE.md` و همین `HANDOFF.md` شامل ممیزی exact-SHA Build #10646 و گیت‌های مستقل هستند. شش شارد 100 شکست دارند؛ Analyze و Visual موفق‌اند؛ APKهای Build و Review موفق‌اند؛ Provider و File Persistence موفق‌اند؛ Device Smoke هنوز PENDING و بدون Job قابل مشاهده است.
4. مجموع شاردها: 1,233 passed / 100 failed از 1,333 تست. هیچ تستی نباید حذف، Skip، تضعیف یا دور زده شود. برای هر شکست لاگ همان Job را بخوان و نقص محصول را در مسیر اصلی رفع کن.
5. وضعیت فعلی Notebook: Task canonical + CanonicalNotebookRepository؛ جدول/رابطه مستقل Note↔Task وجود ندارد. حذف کار و unlink غیرمخرب هنوز به‌صورت قرارداد محصول ثبت شده و نیازمند طراحی و تست است.
6. وضعیت فعلی taxonomy: Center اختیاری در Task، Project membership canonical از ProjectPlan.itemIds و سرویس تخصیص تک‌پروژه، Category تک‌مقداری و Tags چندمقداری. جدول taxonomy_categories فعلاً project_id ندارد؛ آبشار Category از Project gap است.
7. وضعیت Template: G1 Drift v16 و task_templates موجود؛ مدل فعلی anchor و offset تاریخ ندارد؛ Reminder Template فقط hour/minute نگه می‌دارد؛ TaskCloneService dueDate را جابه‌جا نمی‌کند و taskReminders را خالی می‌کند. Deep Clone زمان‌محور هنوز پیاده‌سازی/تأیید نشده است.
8. وضعیت Calendar: PersianDatePicker در HEAD مبنا شمسی + میلادی است و گزینه قمری ندارد. مشخصات Calendar سه‌گانه مصوب است؛ همه انتخابگرها باید سه تقویم را پشتیبانی کنند و تاریخ canonical داخلی را حفظ کنند.
9. این مرحله فقط مستندسازی است؛ هیچ فایل .dart، تست، schema، migration یا workflow تغییر نکرده است. برای پیاده‌سازی‌های بعدی ابتدا شکاف‌ها و migration plan را به تفکیک بررسی کن؛ هیچ DDL مخرب یا حدس در تبدیل تاریخ مجاز نیست.
10. Device Smoke و نصب/پذیرش واقعی Samsung SM-A528B/DS جداگانه الزامی‌اند. موفقیت ساخت APK یا Review Artifact، پذیرش فیزیکی را ثابت نمی‌کند.
11. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ بدون Merge، انتشار یا انتشار عمومی. **BLOCKED — RELEASE: NO-GO**.


## WAVE 4 REV8 execution handoff — 2026-11-10

**Authorization:** Mobin explicitly authorized AUDIT + IMPLEMENTATION + TESTING. This supersedes older read-only handoff language.

**Implementation checkpoint:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`. Source changes: Task migration pre-COMMIT parity and conflict detection; Project migration consolidation, ordering and unknown-field retention; legacy drops/rebuilds deferred; relational Recurrence and Occurrence/checklist storage added. Seven Wave 4 audit reports were created under `docs/project-continuity/audit/`.

**Do next:** fetch the latest live PR HEAD; inspect Build run `42864431438` and Device Smoke run `42864430851` (pending at the checkpoint); repair any failures without changing test strength; then complete G1 Follow-up/Person field parity, atomic migration orchestration, remaining SQL ownership, and full Backup/Restore.

**Unresolved owner decision:** four Reminder states and their transitions/terminal/snooze semantics. Do not invent them.

Main READ-ONLY. PR #3052 OPEN / DRAFT / UNMERGED. No force push, merge, release or legacy deletion. Release NO-GO.


---

# REV9 — Next-agent handoff (2026-11-10)

## Mandatory first actions
1. Read root `AGENTS.md`, `AI_CONTINUITY_PROTOCOL.md`, `PROJECT_STATE.md`.
2. Read `docs/project-continuity/AI_GOVERNANCE_POLICY.md` and its complete mandatory reading sequence.
3. Re-fetch live Main, this branch HEAD, PR #3052, the new documentation PR, related open documentation PRs and exact-SHA CI/check evidence.
4. Read the full REV9 charter in `MASTER_GOVERNANCE.md`; read `MASTER_GOVERNANCE_REV8_ARCHIVE.md` only for historical context.
5. Preserve every decision and status label. Never promote a proposal to approved or an implementation to verified without evidence.

## Verified deployment baseline
- Main at branch creation: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Source PR #3052: OPEN / DRAFT / UNMERGED, head `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; untouched.
- Documentation branch: `docs/rev9-governance-continuity-2026-11-10`.
- Initial commit: `1a849751b931028581f6ce721952aaa987474053`; reconciliation commit: `4825e04335292dcc20dedbed39d614969a85f4cb`; later commit(s) are recorded in the PR.
- Related PRs #3022, #2598, #2600 and #2866 remain open/unmerged; PR #2918/#2975/#2932 and Issue #2974 are historical typography authority inputs now reopened by REV9 §32.

## Guardrails
- Current authorization: DOCUMENTATION-ONLY on this branch. No product code, SQL/schema, migration, tests, workflows, Main, PR #3052, merge or release.
- Keep font unresolved until Mobin decides. Keep Reminder four-state machine unresolved. Do not add a Commitment model/table.
- SQL-only durable source of truth remains approved. Preserve historical data and decision records.
- Release remains BLOCKED — RELEASE: NO-GO.

## Next action
Review the independent documentation PR, verify the final diff contains only approved documentation/agent instruction files, and request Mobin's review. Do not merge.


---

## PR #3340 — owner review handoff

- Review this PR: https://github.com/mobinpda-lab/Arvin-clean/pull/3340
- State at creation: OPEN / UNMERGED. Head at creation: `b9dc37804a69cd2292a071e008b50bd261bae512`; one documentation-only follow-up commit updates continuity records after PR creation, so fetch the live head now.
- Verify changed files remain documentation/agent-instruction only; PR #3052 must remain unchanged and OPEN / DRAFT / UNMERGED.
- Do not merge, release, change code/schema/tests/workflows, or resolve typography without explicit Mobin authorization.
- Next action: Mobin reviews PR #3340 and decides whether to approve or request documentation revisions.


---

# REV9 — Repository Cleanup WAVE 0 handoff (2026-11-10)

## Current verified baseline
- Main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3340: OPEN / READY FOR REVIEW / UNMERGED; branch `docs/rev9-governance-continuity-2026-11-10`; pre-update HEAD `fe85e64199cfdb468228830ecfff3bcf3d8bea5c`.
- PR #3052: OPEN / DRAFT / UNMERGED; HEAD `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; protected and untouched.
- 1,413 branches; 35 duplicate-head groups / 109 refs; 101 open PRs (75 drafts); 99 stale-open-PR candidates by last-update date before 2026-11-01.
- PR #3340 baseline diff: 66 Markdown/agent-instruction files; zero non-documentation files.

## Latest owner direction
- Arvin is LOCAL-FIRST and standalone. Essential product capabilities must work locally/offline; local SQL is the sole durable source of truth.
- All multi-device synchronization (P2P, LAN, Cloud, Dropbox, remote) is SUSPENDED pending separate explicit Mobin authorization.
- The only active Repository Cleanup Program sequence is WAVE 0–4 as recorded in ROADMAP.md. Do not create parallel numbering.

## Changes in this authorized documentation pass
- Corrected REV8 archive link and clarified that REV9 is on PR #3340's branch, not yet in Main.
- Recorded LOCAL-FIRST / SYNC SUSPENDED in the decision ledger, roadmap, AI governance and P2P specification.
- Added current live baseline and historical-snapshot labels to continuity documents.
- No historical document, branch, PR or implementation file was deleted.

## Protected boundaries
No Main or PR #3052 change; no source/schema/migration/test/workflow/feature change; no branch deletion, PR closure, merge or release. Release remains NO-GO.

## Next action
Re-fetch the final PR #3340 HEAD and validate the docs-only diff and internal links. Review remaining documentation candidates in WAVE 3 before any consolidation. Git-history analysis belongs to WAVE 1; CI/test governance to WAVE 2. No sync work is active.


---

## WAVE 0 final pre-handoff checkpoint — 2026-11-10

- Latest verified PR #3340 branch HEAD before this final handoff record: `cd1d52e752ac10c0040738f655d5a288d2523399`.
- Main remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3052 remains OPEN / DRAFT / UNMERGED at `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; untouched.
- Documentation reconciliation commits: `fe85e64199cfdb468228830ecfff3bcf3d8bea5c` and `cd1d52e752ac10c0040738f655d5a288d2523399`.
- The commit containing this handoff advances PR #3340; always re-fetch the live PR head after this commit.
- Next action: validate the final tree and present PR #3340 for Mobin's review. No merge.



---

## COMMAND 07-A.2.33 — live continuity addendum (2026-11-12)

## First actions for the next execution pass
1. Re-read live refs and verify execution branch HEAD is still `eea746dbf2a58cd4f04c66a149ae3441264da5b2`; do not assume this SHA remains current.
2. Poll Build run `43269800292`, Device Smoke `43269800280`, SQLite Snapshot `43269800257` and Follow-up Persistence `43269800526`; verify every job's actual checkout SHA.
3. Confirm the malformed `task_people` payload test now reaches the expected `FormatException`, preserves source rows, rolls back canonical writes, allows repair/retry and leaves `PRAGMA foreign_key_check` empty.
4. Review the remaining 60 old-candidate failure records independently. Their status is UNRESOLVED until root cause, source location and retest evidence are documented.
5. Complete D01–D05 independently, including real Backup/Restore and injected interruption/recovery. Do not use the A–D snapshot or five reopen cycles as a substitute for D05.
6. Complete the Home clock injection contract and the seven Device Smoke lanes on one exact SHA.
7. Reconcile #3388's parallel documentation package with REV9 on #3340. Keep one canonical source per domain; do not merge either PR without explicit owner authorization.
8. Preserve all historical branches, PRs, artifacts and test assertions. No destructive cleanup, merge, release or deployment.

Current typography owner decision (2026-11-12): Vazirmatn only; VazirHarf is not official; System Default is optional; preserve weights 300/400/500/600/700.



---

## COMMAND 07-A.2.33 — evidence refresh (2026-11-12, later poll)

1. Poll Build `43269800292` and Device Smoke `43269800280`; verify actual checkout SHA for every job. SQLite Snapshot `43269800257` and Follow-up Persistence `43269800526` have passed on `eea746d...`.
2. Before the next implementation commit, allow current Build to finish; do not cancel it to free queue capacity.
3. Fix the three proven harness defects without weakening assertions: use the create TextField finder directly instead of `widgetWithText(TextField, ...)`; locate the actual Scrollable under `task-detail-content-list` for `scrollUntilVisible`.
4. Fix the two test-contract defects: replace `pumpAndSettle` in alarm overlay smoke with the existing bounded frame pump helper; assert the Task reminder compatibility projection instead of incorrectly expecting a null getter while an enabled reminder exists.
5. Re-run affected tests and the full Build on the resulting new SHA. Then re-run Device Smoke and SQLite Snapshot on that same final candidate.
6. Continue D01–D05, real Backup/Restore, D05 injected interruption/retry, Home clock injection and 55 unresolved regression records.
7. Reconcile PR #3380/#3382/#3384 shared migration-writer test; reconcile PR #3388 documentation package with REV9 PR #3340. Preserve all PRs and history until owner review.



---

## Immediate P0/P1 correction — Home clock (2026-11-12)

- Before the next full acceptance candidate, add one injectable `nowProvider` through `ArvinApp` and `HomePage`.
- Replace the direct `DateTime.now()` in `_groupJalaliDate()` with the shared `_iranWallClockNow()` source; ensure both grouping and overdue checks use the exact same injected instant.
- Add/adjust the deterministic test: now=09:00, due=10:00. Do not use current live time for a fixed-time assertion and do not weaken the group assertion.
- Preserve the later owner-approved five Home filters in RTL order: Time, Center, Project, Category, Tag. Older four-filter wording is superseded.
- The current candidate `eea746d...` is not accepted: Build test-1 failed; wait for the other jobs, then commit the clock correction and rerun full Build/Device Smoke/SQLite Snapshot on the new SHA.



---

## G1 fixture correction — immediate next step (2026-11-12)

- Do not treat `eea746d...` as a successful G1 fix. Build test-5 proves the fixture fails with `no such table: tasks` before Migration begins.
- In `test/services/g1_drift_schema_test.dart`, create the complete schema-compatible `tasks` table first (matching the canonical task table columns used by `G1DriftSchema`), insert the `legacy-task` parent row, then create the malformed `task_people` row.
- Re-run the test and prove it reaches the expected FormatException, preserves the source row, rolls back canonical writes, leaves FK enforcement enabled, repairs the JSON and retries successfully on the same executor.
- Do not remove `PRAGMA foreign_key_check`, alter production FK definitions, or claim the migration is fixed before the test passes.


---

## COMMAND 07-A.2.34 handoff — 2026-11-12

### Current execution lane
- Repository: `mobinpda-lab/Arvin-clean`
- Execution PR: #3384
- Execution branch: `feature/command-07-a-sqlite-contract-remediation`
- Latest recorded execution SHA: `ee703dfa82e356039ef32c0b2a9f1bc9a00dc1e9`
- Main baseline: `45e4202b03a434459e4c021a04efa7e8396359db`
- Do not switch to `staging/command-07-a2-33-recovery` without a fresh dependency audit; its Main comparison is 2,371 ahead / 0 behind.

### Work already committed, not yet accepted
1. G1 malformed `task_people` fixture creates the canonical `tasks` parent table before inserting the parent Task.
2. Home time grouping and Jalali date labels share an injectable Iran wall-clock provider.
3. Home clock widget regression covers 09:00 and 10:00.
4. Expanded Home Task card displays the latest real Follow-up via `HomeFollowUpPresentationService`; legacy date metadata alone remains excluded.
5. Home test now uses the actual expand control and canonical widget keys.

Relevant commits:
- `446f04a6f8cc94871eea0982d9f0f896b8fba8fe`
- `ab06e7bdf3233d3d971aa64d11782efff71089f1`
- `235bfb98e45af68f0d68b00099f97d599504b575`
- `5af39a34ee19e090de30cf6d3e0a5848852fab48`
- `ee703dfa82e356039ef32c0b2a9f1bc9a00dc1e9`

### CI state and evidence boundary
The last completed full Build run is `43269800292` on historical SHA `eea746dbf2a58cd4f04c66a149ae3441264da5b2`, not the current execution SHA:
- Analyze / Visual / Debug APK / Staging APK / Release APK build: SUCCESS.
- All six test shards: FAILURE; 1,338 passed / 61 failed.
- SQLite Snapshot `43269800257`: SUCCESS, but not D01–D05 acceptance.
- Follow-up Persistence `43269800526`: SUCCESS, narrow scope.
- Device Smoke `43269800280`: all seven scenario jobs were QUEUED at last inspection.
- Orchestrator Wakeup `43288112147` was later CANCELLED after the branch advanced; no new Build or Device Smoke run was returned for `ee703dfa...` at handoff creation.

Do not copy old SHA results onto the new candidate. Poll for a fresh exact-head run before treating any new change as validated.

### Mandatory continuation sequence
1. Recheck live #3384 head and Actions. Confirm checkout SHA, not only PR title or branch name.
2. Validate the new G1 fixture test. If it fails, inspect transaction state, source-table retention, canonical table rollback, FK state and retry behavior; do not weaken assertions.
3. Validate the new Home clock test and Follow-up presentation integration.
4. Triage all 61 historical failure records individually. Keep original assertion, classification, root cause, code/test change, focused result and run ID.
5. Continue D01–D05, then Category / Project / Tag workflows and cross-feature consistency.
6. Verify Vazirmatn weights, persistent font preference, PDF embedding/rendering, APK font audit and all seven Device Smoke scenarios on one candidate SHA.
7. Update the canonical six documents on this REV9 branch as decisions/evidence mature. Keep PR #3388's v49-era documentation lane separate until its authority conflict is reconciled.
8. Never merge, release, deploy, delete branches, rewrite history, or destructively modify user data without explicit Mobin authorization.

**Status:** IMPLEMENTATION IN PROGRESS / ACCEPTANCE BLOCKED.


---

## COMMAND 07-A.2.34 — latest live handoff (2026-11-12)

### Exact execution identity
- Current execution PR: #3384 OPEN / DRAFT / UNMERGED.
- Branch: `feature/command-07-a-sqlite-contract-remediation`.
- Current HEAD at this checkpoint: `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`.
- Base branch/SHA: `fix/wave3-cycle3-calendar-product-repair` / `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.
- Main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Do not switch to `staging/command-07-a2-33-recovery`: it compares 2,371 ahead / 0 behind Main and is not the active execution lane.

### Current exact-head Actions
- Arvin Draft Review APK (1f4ff4898a5a9278e067c795a8fc14791b8ecbed) — Run `43291144596`: **COMPLETED/SKIPPED**.
- Arvin Device Smoke — Run `43291144527`: **QUEUED**.
- Arvin Build (1f4ff4898a5a9278e067c795a8fc14791b8ecbed) — Run `43291144776`: **PENDING**.
- Arvin Follow-up File Persistence — Run `43291144575`: **PENDING**.
- Arvin COMMAND 07-A.2.20 SQLite Snapshot Evidence — Run `43291144675`: **QUEUED**.
- ARVIN Orchestrator — Run `43291144442`: **PENDING**.
- ARVIN Orchestrator PR Wakeup — Run `43291144484`: **PENDING**.
- ARVIN Production Loop — Run `43291144513`: **QUEUED**.
- Build run has no allocated jobs; Device Smoke and SQLite Snapshot are queued; Follow-up Persistence is pending with its job queued.
- No current-head artifacts or passing scenario jobs are available. A queued/pending workflow is not a PASS.
- The 6914b55 head's Build/Follow-up/Orchestrator runs were cancelled after later commits; do not reuse them.

### Historical failure correction
The 61 failure records on `eea746d...` are distributed as shard 0=11, 1=1, 2=21, 3=9, 4=9, 5=10. Use the original six logs/job IDs in the implementation log; a prior document distribution was transposed. Do not transfer the historical count to the current candidate.

### New product-integrity issue to fix
`ProjectTemplateManagementPage` still uses free-text Category and Tags. Reusable Task/Project templates persist taxonomy snapshots, but the current deletion checks only account for Task references. Before C01/C03/C04/C05 acceptance:
1. Replace free-text template Category/Tag entry with the canonical SQLite-backed selectors.
2. Define a fail-closed rule for deleting taxonomy values referenced by Task Templates or Project Templates; preserve historical template payloads.
3. Add tests for template selection, rename consistency, blocked deletion and generated Task catalog parity.
4. Re-run focused tests and full exact-head validation on the resulting SHA.

### Other consolidation candidates
- `TaskTaxonomyLifecycleService` overlaps `TaskTaxonomyMutationService`; management UI currently uses MutationService. Audit references and tests before consolidating.
- `TagStore` still contains a SharedPreferences path; current Home/management flows use TaskStore/SQLite. Prove no active compatibility use before retirement.
- Preserve PR #3380 and #3382 diagnostic evidence; #3382 is stacked on #3380.
- Keep PR #3340 as the REV9 canonical docs lane. PR #3388 is a parallel v49-era docs/CODEOWNERS lane and remains an authority conflict; do not merge either without owner review.

**Status:** IMPLEMENTATION IN PROGRESS / ACCEPTANCE BLOCKED. No merge, release or deployment.


---

## P0 handoff — complete taxonomy/template consistency

The taxonomy audit is deeper than the editor-field finding:
1. Replace free-text Category/Tags in `ProjectTemplateManagementPage` with canonical TaskStore-backed selectors. A newly created value must be written to the central catalog.
2. Make Category rename update `tasks`, `task_templates` and `project_template_tasks` in the same SQLite transaction.
3. Make Tag rename update `task_tags`, `task_templates.tags_json` and `project_template_tasks.tags_json` in the same SQLite transaction, preserving order and de-duplicating only the renamed collision.
4. Make Category/Tag deletion fail closed if referenced by Tasks, Task Templates or Project Template tasks. Include archived templates; do not erase historical definitions.
5. Add file-backed and focused tests for each reference domain, rename atomicity/rollback, blocked deletion, and Task generation from the renamed template.
6. Keep `TaskTaxonomyLifecycleService`, `TaskTaxonomyMutationService` and `TagStore` intact until their reference/compatibility audit is complete.

No production code correction for this finding has yet been committed. Treat C01/C03/C04/C05 as BLOCKED until the above tests pass on one exact candidate SHA.


---

## COMMAND 07-A.2.34 handoff refresh — 2026-11-12

**Current execution HEAD:** `1f4ff4898a5a9278e067c795a8fc14791b8ecbed` on `feature/command-07-a-sqlite-contract-remediation`.

### Current exact-head runs
- Build `43291144776`: PENDING.
- Device Smoke `43291144527`: QUEUED.
- SQLite Snapshot `43291144675`: QUEUED.
- Follow-up File Persistence `43291144575`: PENDING.
- Orchestrator `43291144442`: PENDING.
- Production Loop `43291144513`: PENDING.
- Orchestrator PR Wakeup `43291144484`: PENDING.

### Newly committed work
- `bc37933ca591b135b4b943d4187e1f19c695e4b1`: Home compact Task card shows latest real Follow-up.
- `1f4ff4898a5a9278e067c795a8fc14791b8ecbed`: Task Detail Person test uses the actual Scrollable finder.
- Earlier checkpoint commits are recorded above; all new changes remain unvalidated until exact-head Actions finish.

### Next safe work while CI is queued
1. Do not mutate the execution branch until the current exact-head Build result is available unless a confirmed P0 data-loss/security defect requires immediate repair.
2. Prepare D04 test using two disposable `NativeDatabase(File)` instances: source SQLite → portable backup file → restore candidate → independent destination SQLite → close/reopen → Task/Reminder/Follow-up/Person/Project verification → `PRAGMA integrity_check` and `PRAGMA foreign_key_check`.
3. Add D01 fixtures with custom Index and Trigger objects to prove either safe preservation or explicit fail-closed rollback without dropping them.
4. Investigate the remaining Follow-up Entry person-selection failure; do not override a user's deliberate deselection and do not weaken assertions.
5. Build the C07 isolated end-to-end scenario using the canonical TaskStore, ProjectStore, taxonomy mutation service and feature projections.
6. Poll exact-head Build/Device/SQLite/Follow-up runs. If any new commit is made, discard no history; the acceptance SHA changes and affected gates must rerun.
7. Keep Merge, Release and Deployment unauthorized.


---

## COMMAND 07-A.2.34 — D01/D04 test handoff (2026-11-12)

**Current execution HEAD:** `fd22fe37f0190818084f011bfcce00e241da6933`.

### Newly added tests
- `test/services/sqlite_backup_restore_file_test.dart`: separate source and destination SQLite files; portable backup; restore into destination; destination close/reopen; Task, Reminder, Follow-up, Person and Project relation checks; category/tag catalog checks; SQLite integrity and FK checks.
- `test/services/g1_drift_schema_test.dart`: legacy Task fixture with custom index and trigger; verify safe migration deferral preserves both objects and the trigger remains operational.

### Current exact-head workflow state
- Build `43293411996`: PENDING.
- Device Smoke `43293412058`: QUEUED.
- SQLite Snapshot `43293411971`: QUEUED.
- Follow-up Persistence `43293412060`: QUEUED.
- Orchestrator Wakeup `43293411950`: QUEUED.
- Orchestrator `43293412413`: QUEUED.
- Production Loop `43293411953`: PENDING.
- Draft Review APK `43293412082`: SKIPPED.

### Validation instructions
1. Wait for the latest exact-head Build to start; confirm its checkout SHA equals `fd22fe37...`.
2. Run focused tests for `sqlite_backup_restore_file_test.dart` and the custom Index/Trigger fixture.
3. If D04 fails, inspect restore ordering, FK parent creation, Person directory membership, Follow-up relation restoration, Project membership and destination close/reopen. Do not weaken checks.
4. If D01 fails, preserve the original database and investigate whether any migration path drops a custom object; do not bypass the fail-closed guard.
5. Re-run all required gates on the final candidate after any correction.
6. C07 full cross-feature workflow and unresolved Follow-up Entry Person selection still require separate work.


## COMMAND 07-A.2.34 — next continuation (2026-11-13)

1. Fetch the live head of `feature/command-07-a-sqlite-contract-remediation`; expected last observed SHA is `cde28b0925708439f48a49a9b85257ef40ccc4ef`. Never assume it remains current.
2. Obtain exact-SHA Analyze/Test/Build evidence for the two analyzer corrections. The previous Build SHA `d6af169...` failed Analyze and all six test shards; do not transfer any result to `cde28b...`.
3. Diagnose the Follow-up Entry selected-Person chip failure and remaining 60 regression records individually; do not weaken assertions.
4. Complete D01 schema/index/trigger parity, D04 independent-file backup/restore, and D05 controlled failure/rollback/retry/reopen evidence.
5. Complete seven Device Smoke scenarios on one exact candidate SHA and record emulator/device, OS, logs and artifacts.
6. Continue Category/Project/Tag cross-feature tests, including Task Template and Project Template references; preserve historical task/template data.
7. Validate Vazirmatn-only packaging, PDF embedding/rendering and independent APK/font SHA256 values. System Default remains optional; VazirHarf remains inactive historical provenance.
8. Keep PRs #3380/#3382/#3384/#3388 and historical evidence intact. No merge, release, deployment, branch deletion or history rewrite.


## COMMAND 07-A.2.35 — continuation handoff (2026-11-13)

- Re-fetch execution branch before work. Last observed HEAD: `cde28b0925708439f48a49a9b85257ef40ccc4ef`; main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Build run `43337010522`: Analyze PASS; shards 0/2/3/4/5 FAIL with 11/9/8/21/13 failures respectively; shard 1 PASS. Total **62** failed records. Read each raw job log and compare test contract with canonical product specs before classifying or changing source/tests.
- SQLite Snapshot `43337010196` PASS with five reopen cycles but is partial evidence only. D04 independent backup/restore and D05 controlled rollback/interrupted migration/retry remain unproven. Fixture Person names are empty; check Person-name migration separately.
- Follow-up Persistence `43337010442` PASS. Device Smoke `43337010594`: only Task Lifecycle and Follow-up Persistence PASS; Reminder/Vazirmatn FAIL; Boot/Navigation/Quick Capture/Calendar CANCELLED.
- Artifact audit: staging APK SHA256 `c06771aab8da745861165eef5fc85ee29d07c1797c4309a4b15cade1e8c6f8f5`; debug `25a065e4117266dcd47172f3afc2b1958a01cbb8edb78cecdf4dee1db078f23c`; release build `9423fdc242351cc21e3c527e243b04c3b9374a7550ddb3b2e22f6df351b3f5f5`. Staging uses an ephemeral test-only key and is not publishable.
- All APKs contain Vazirmatn 300/400/500/600/700; embedded font hashes match source font hashes. PDF artifact `13998370513` validates embedded Regular/Bold and Persian text. Physical-device typography acceptance remains pending.
- Next: root-cause the 62 tests (do not weaken assertions); diagnose Reminder/Vazirmatn smoke; run D04/D05; execute Category/Project/Tag and Person/Checklist/Task/Reminder/Follow-up E2E on isolated DB; then consolidate only with evidence. Preserve PR/branch/history. No merge/release/deployment.


## COMMAND 07-A.2.35 — post-checkpoint test-harness correction (2026-11-13)

- Execution branch moved from `cde28b0925708439f48a49a9b85257ef40ccc4ef` to `bb08f21bd2a5ab2a7f7affe4c8e5e3bc28c81c96` by one test-only commit: `test: disambiguate nested Task Details scrollable finder`.
- Confirmed classification: `TEST HARNESS DEFECT` in `test/task_detail_person_persistence_test.dart`. The failure was thrown inside Flutter's `WidgetController.scrollUntilVisible` via `Iterable.single` at test line 39, before the Person picker or persistence assertions ran. The supplied descendant finder matched multiple Scrollable widgets. The test now selects the first matching descendant Scrollable; no assertion, expected behavior or coverage was removed.
- New SHA `bb08f21bd2a5ab2a7f7affe4c8e5e3bc28c81c96` currently has no workflow runs returned by the commit-run lookup and no status checks. Therefore the test-harness correction is IMPLEMENTED / NOT YET VERIFIED. Do not report it as fixed until the focused test passes on this exact SHA.
- Source audit found canonical taxonomy operations in TaskStore: create Category/Tag; category/tag rename paths; deletion guards count Task and template references; `renameCategoryAndTasks` / `renameTagAndTasks` update Task/Template references transactionally. ProjectStore persists canonical Project records and memberships in a transaction, retaining template application rows only where memberships still exist. These are source-inspection findings, not end-to-end acceptance. The distinct catalog-only rename methods and their call sites still require audit; no destructive cleanup was performed.
- Follow-up Person creation/selection failure remains unresolved: `follow_up_entry_page_test.dart:229` does not find the newly selected Person chip after the multi-select sheet closes. The code path was inspected, but the root cause is not proven; no production change was made.
- `task_detail_person_persistence_test.dart` must be rerun on SHA `bb08f21...` before its Person/SQLite assertions can be evaluated. The prior failure was the test harness finder, not evidence of a Person persistence failure.
- Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. No merge/release/deployment, workflow rerun, branch deletion, history rewrite or production-data operation occurred.



# REV10 continuation handoff — 2026-11-13

## Active authority
Read `MASTER_GOVERNANCE.md` (REV10) first. REV9 is preserved verbatim in `MASTER_GOVERNANCE_REV9_ARCHIVE.md`. The current authority order and decision statuses are recorded in `PRODUCT_DECISIONS.md`; conflict reconciliation is in `audit/CONFLICT_REGISTER.md`.

## Live refs at checkpoint
- Arvin Main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- REV10 docs branch: `docs/rev10-master-charter-2026-11-13`.
- SQLite execution branch: `feature/command-07-a-sqlite-contract-remediation` at `3f471e6b88764446eabd33752d0aa3d820f52628`.
- NIRA Main: `7a27ee63b65d343e45c5786f782f2567611722dc`; separate factory only.
- PR #3340 and #3388 remain unmerged competing governance lines; #3384 remains unmerged product execution.

## Immediate next actions
1. Poll optional-relationship Run `43431160695` and Build Run `43431160736` on exact SHA `3f471e6...`; inspect job logs and artifacts. Do not reuse earlier SHA results.
2. If the corrected harness passes, inspect the test's actual coverage against the real production schema and distinguish diagnostic fixture evidence from production schema acceptance.
3. Inspect the current PR #3384 head, base and exact checks. Do not merge.
4. Create/update a Draft REV10 PR based on the REV9 documentation branch; keep PR #3340 as its dependency and do not merge either without explicit approval.
5. Reconcile #3388's six canonical docs, v49.1 operating package, adapters and CODEOWNERS proposal into the REV10 structure without duplicate generic files.
6. Continue WAVE 1: audit actual G1 schema, Center/Project/Category ownership, optional Task links, Tag and Person relationships, then implement only evidenced gaps.
7. Continue independent D01–D05, regression, typography/PDF and device lanes in parallel where file ownership permits.
8. Keep Main unchanged. Merge, release and deployment remain prohibited.

## Evidence boundaries
- REV10 docs are implemented on the REV10 branch; they are not in Main.
- Run `43431160695` was queued and Run `43431160736` pending at last poll.
- D01–D05 are not accepted as complete.
- Device Smoke is not accepted.
- NIRA factory progress is not Arvin product progress.


## Wave 1 data architecture findings — 2026-11-13

See `audit/REV10_WAVE1_DATA_ARCHITECTURE_BASELINE_2026-11-13.md`.

Critical implementation gaps: Task Center is only inside the JSON envelope; direct Task Project/Category IDs are absent; Project membership is many-to-many; Categories are global/unowned; Project Center is nullable. The optional-link CI test is a miniature fixture, not the real production schema.

Next safe work: read-only consumer and legacy-data inventory, then additive candidate schema and exact-G1 file-backed migration tests. Preserve `project_items` and `taxonomy_categories` until every consumer is migrated and D01–D05 pass. No cutover or destructive retirement.
