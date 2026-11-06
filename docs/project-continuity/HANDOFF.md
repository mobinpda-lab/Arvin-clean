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
