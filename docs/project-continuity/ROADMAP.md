# Product Roadmap
This roadmap orders work by release risk and verified dependencies. It does not authorize scope expansion beyond the owner-approved PR/issue scope.

## P0 — Release and reliability gates
1. Complete all seven Device Smoke lanes on one exact candidate SHA.
2. Diagnose and rerun Calendar Provider Acceptance after the Dart Development Service startup failure; preserve the test and assertions.
3. Obtain exact-SHA Build, Follow-up Persistence, Calendar Provider and Device Smoke evidence; do not combine results across SHAs.
4. Complete the required physical-device startup/install/runtime acceptance and record evidence. Any unverified device behavior remains open.
5. Obtain product-owner acceptance and close all governing release blockers before considering release.

## P1 — Product correctness and usability
1. Resolve the Quick Capture empty-title feedback decision with the product owner; preserve compact layout and validation.
2. Retain unified Report Center Filters and verify all filter dimensions and combinations with focused tests and fresh screenshots.
3. Audit Center > Project > Category > Task terminology and behavior across every relevant creation, edit, selection, report and filter flow.
4. Continue only explicitly authorized Task Details / inline-edit / clone work under the current PR scope and its acceptance requirements.
5. Preserve Reminder, Follow-up, recurrence and calendar independence; no legacy-field removal or destructive migration without real-data inspection and a safe migration plan.

## P2 — Future architecture
1. Local P2P phase 1: threat model, data ownership, protocol contract, pairing security, durable operations, idempotency, acknowledgements, recovery, conflict handling and physical-device tests. QR/PIN and LWW are not implementation approvals.
2. Cloud / Dropbox phase 2: separate future design; not a dependency for phase 1.

## Explicitly not promoted from examples
A feature mentioned only as an illustrative example (such as periodic tasks or a particular edit screen) is not automatically an approved backlog item. Require prior evidence or an explicit owner directive.


## Task Details visual acceptance — blocked checkpoint (2026-11-04)
- Authorized Task Details redesign remains in scope, but image-to-image comparison is blocked until both named screenshots are actually accessible.
- Do not guess layout, color, spacing or remove repeated metadata without reference and product approval.
- After screenshots arrive: build approved visual matrix, make UI-only changes preserving all canonical actions/data pathways, add focused RTL widget and golden/screenshot acceptance, then run exact-SHA Build, Calendar Provider and all seven Device Smoke lanes.
- Current exact-SHA evidence and blockers are tracked in OPEN_ISSUES.md and docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md.


## Task Details reference-driven implementation — 2026-11-04
1. UI implementation is present on the active PR branch: summary/status/priority, separate description, ordered metadata, conditional template, single due-date card and preserved lower sections.
2. Run focused widget/RTL tests and full Build on the final post-documentation SHA; no prior-SHA PASS may be transferred.
3. Complete all seven Device Smoke lanes plus Calendar Provider and Follow-up Persistence on that same final SHA.
4. Produce a real revised-page screenshot from an emulator/device and obtain product-owner visual approval. Pixel comparison remains NOT VERIFIED until the installed screenshot is available too.
5. Do not create or claim a golden image without an actual generated rendering and review.
6. Task execution-time and assignee concepts require explicit canonical model decisions before data fields or migration are introduced.


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
