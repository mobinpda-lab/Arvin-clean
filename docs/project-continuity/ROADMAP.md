## COMMAND 07-A.2.81 — current delivery status — 2026-11-14

1. Complete exact-SHA rerun after the historical parity, FK assertion, Analyze and legacy fixture corrections.
2. Require D01–D05 independent evidence on one final post-documentation SHA.
3. Complete seven Device Smoke scenarios on that same SHA.
4. Resolve inherited regression blockers: exact base Build run `43575749904` had 41 failing labels, all reproduced on b3d6; do not delete, skip or weaken these tests. Diagnose their product/test-contract causes after SQLite scope is stable.
5. Only after SQLite v20 acceptance, begin Canonical Repository Integration: CenterStore, ProjectStore, CategoryStore, TaskStore, Entity Management, selectors, Home/Calendar/Reports filters, Search and product Backup/Restore.

### Gate status evidence boundary

- D01: YELLOW — real Drift lifecycle and fresh/v19 tests passed on b3d6; final-SHA rerun pending.
- D02: YELLOW — four-state value test passed on b3d6; full historical parity test failed on b3d6 and has a corrected comparison awaiting rerun.
- D03: RED on b3d6 — historical Person/Follow-up/Reminder/Metadata parity assertion failed; migration metadata preservation corrected, rerun pending.
- D04: YELLOW — independent physical SQLite file-copy/restore test passed on b3d6; full final-SHA evidence pending and product integration remains separate.
- D05: YELLOW — all seven real lifecycle failure-injection/recovery cases passed on b3d6; final-SHA rerun pending.

No gate is accepted until all mandatory checks pass on one exact SHA.


## 2026-11-14 — Active REV10 SQLite v20 delivery lane

**Primary execution:** PR #3463 / `rev10-m2m-v19-test-expansion`.  
**Main:** read-only. **Merge / Release / Deployment:** not authorized.  
**Approved architecture:** Center↔Project M2M; Project↔Category M2M; Task→Center/Project/Category each optional 0..1; Task↔Tag M2M.

### Current wave order
1. Exact-SHA CI reconciliation and root-cause repair.
2. Real Drift lifecycle acceptance: fresh install, v19 upgrade, pre-opened Executor, version registration and reopen.
3. Historical v19 data parity across entities, relationships, NULL/FALSE/TRUE and unresolved references.
4. Failure injection at every lifecycle boundary, transaction rollback and interrupted post-commit recovery.
5. Physical SQLite backup and independent-file restore of the migrated v20 database.
6. Independent D01–D05 acceptance on one exact SHA.
7. Canonical Repository Integration: first repair CenterStore/ProjectStore/TaskStore and Category CRUD against the M2M joins; then Entity Management, selectors, Home/Calendar/Reports filters, Search and production Backup/Restore. ProjectStore's current full-table delete conflicts with the new RESTRICT join FKs and must be replaced by transaction-safe edge-aware upserts before real migration is enabled.
8. Update the seven canonical continuity documents and preserve dated history.

### Acceptance gates
- D01: Schema and Migration Compatibility — BLOCKED pending exact-SHA lifecycle test results.
- D02: Missing / NULL / FALSE / TRUE — BLOCKED pending historical parity run.
- D03: Person / Follow-up / Reminder / Metadata — BLOCKED pending historical parity run.
- D04: Physical SQLite Backup / Independent Restore — BLOCKED pending physical-file test.
- D05: Atomicity / Rollback / Recovery — BLOCKED pending seven-stage failure-injection run.

Do not promote authored tests to VERIFIED. No old single-parent candidate is an active architecture. No relationship may be guessed from Task text. Preserve all unresolved historical evidence.

---

# REV8 Wave Roadmap — current state

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

## Wave readiness

| Wave | Current status | Gate / dependency |
|---|---|---|
| Wave 0 — Governance & Source of Truth | COMPLETE for audit documentation | 12 audit inventories and canonical index; verify final pushed HEAD after commit. |
| Wave 1 — Data Integrity & Architecture | BLOCKED | Define four Reminder states; verify Drift v16 migrations and real Backup/Restore integrity before data changes. |
| Wave 2 — Core Task Lifecycle | PARTIAL / BLOCKED | Auto-Save full-field acceptance, Due Date/Reminder/Follow-up boundaries, recurrence and checklist regressions. |
| Wave 3 — Home, Quick Capture & Filters | BLOCKED | Fix current Home, Quick Capture, five-filter OR/AND and taxonomy failures without weakening tests. |
| Wave 4 — Notebook, Calendar & Templates | PARTIAL | Calendar Provider passed; Device Smoke pending; verify Notebook hard-delete preservation and Template date/assignment semantics. |
| Wave 5 — Reports, Sync & Enterprise Acceptance | BLOCKED | Report/PDF failures, P2P/Sync E2E and NIRA L10 remain unverified. |

## Wave acceptance criteria

### Wave 0 — Governance & Source of Truth
- Goal: one canonical authority and traceable branch/PR/commit/test/CI inventories.
- Acceptance: current SHAs, exact CI, inventories, internal links and safety restrictions recorded.
- Status: audit documentation prepared for the authorized branch.

### Wave 1 — Data Integrity & Architecture
- Goal: canonical TaskStore/Drift integrity, Reminder states, migrations, Backup/Restore.
- Dependencies: explicit four-state Reminder contract; real DB/backup fixture and migration plan.
- Acceptance: no parallel store; lossless migration/restore; foreign keys and occurrence history validated.
- Tests: Drift migration, file-backed persistence, backup/restore round-trip, data-integrity regression.
- Status: BLOCKED pending Reminder semantics and full DB evidence.

### Wave 2 — Core Task Lifecycle
- Goal: Task, Due Date, Reminder, Follow-up, recurrence, occurrence and checklist lifecycle.
- Acceptance: independent timestamps; Follow-up is historical action; Reminder is future scheduling; Auto-Save is durable.
- Tests: Task contract, reminder persistence, follow-up persistence, recurrence and checklist occurrence tests.
- Status: PARTIAL; current Build failures remain.

### Wave 3 — Home, Quick Capture & Filters
- Goal: five filters, OR within dimensions, AND across dimensions, inline taxonomy creation, sorting, Focus Today and Inbox.
- Acceptance: 360/390/412dp RTL, 48dp touch target, no horizontal overflow, unclassified quick capture supported.
- Tests: Home, Quick Capture, filter Boolean logic, category/project integration and accessibility.
- Status: BLOCKED by current shard failures.

### Wave 4 — Notebook, Calendar & Templates
- Goal: note preservation, deep clone, calendar separation and provider safety.
- Acceptance: deleting/unlinking Task never destroys independent note; template excludes execution history; external event deletion cannot delete internal Task.
- Tests: Notebook deletion/restore/convert, template deep clone/date-base, Calendar provider, Device Smoke.
- Status: PARTIAL; Provider pass, Device Smoke pending, other acceptance incomplete.

### Wave 5 — Reports, Sync & Enterprise Acceptance
- Goal: management reports, Follow-up Office, PDF, sync/P2P, NIRA E2E and L10.
- Acceptance: accurate reports, idempotent sync, reconstructible registered-client E2E, L10 evidence.
- Tests: report/PDF suites, sync conflict/transport, NIRA factory tests and actual registered-client run.
- Status: BLOCKED; NIRA L10 UNVERIFIED.

---

## Historical roadmap (preserved)

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
3. Audit the approved Center↔Project↔Category relationship graph and its optional Task links across every relevant creation, edit, selection, report and filter flow.
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


## 2026-11-05 — Module-Core-Logic backlog (audit only)
1. **P0 / Reminder delivery correctness:** ensure disabled `TaskReminder` entries are excluded by the actual delivery service, not only by the next-alarm planner; add direct delivery-service regression tests.
2. **P0 / Idempotency:** define and test an idempotency rule for repeated Reminder creation so retry/double-submit cannot create unintended duplicate records. Do not collapse distinct Reminders that intentionally share a time.
3. **P0 / Legacy migration safety:** inspect real user DB counts/values and verified backup/restore before deciding how `followUpEnabled`, `followUpDate`, `FollowUp.reminderDate` and `nextFollowUp` are preserved, converted or retired. No destructive DDL before approval.
4. **P0 / Test scenario mapping:** map each removed/rewritten PR test scenario to its approved replacement or obtain explicit owner disposition. Current PR-wide preservation claim remains NOT VERIFIED.
5. **Acceptance:** run focused tests and all required exact-SHA workflows after any authorized code change. This registration does not authorize source, schema, migration or test changes.
## UI design system rollout — 2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
1. **P1 / Cross-screen card audit:** inventory every custom card-like Container/BoxDecoration in Task Lists, Task Details read-only/edit, Calendar and Quick Entry; migrate only presentation to shared card tokens without changing behavior.
2. **P1 / Visual regression:** add/retain widget assertions for token application, Persian RTL labels, contextual icons, P1–P4 semantic mapping, status and Center → Project → Category → Tags display order. This is visual order only; M2M cardinality is authoritative. Do not remove or weaken existing scenarios.
3. **P1 / Device visual acceptance:** compare all four target surfaces on the physical Android device at supported viewport/text scales. Until then, whole-app uniformity remains NOT VERIFIED.

### Remaining visual rollout
- Continue inventorying custom card-like panels in secondary routes (Reports, Notebook, Follow-up Office, Backup, People, Projects, Settings and Work Agenda); migrate only presentation and preserve all semantic status/taxonomy distinctions.
- Capture before/after physical-device screenshots for Home/Task List, Task Details read-only/edit, Calendar and Quick Capture at supported viewport and text scales. Do not claim whole-app uniformity before this gate.


## P1 — Calendar UI/UX canonical specification and acceptance
**Status:** SPECIFICATION APPROVED / RUNTIME ALIGNMENT NOT VERIFIED.
1. Use `docs/project-continuity/calendar_ui_ux_spec.md` as the canonical fourteen-section Calendar presentation reference.
2. Preserve the approved RTL header zones, selected-date display, four view modes above the grid, Saturday–Friday triple-date grid, five content filters below the grid, selected-day agenda, non-overlapping cards and Hijri adjustment choices.
3. Keep View Modes and Content Filters as distinct control groups in their mandated positions; do not transpose them.
4. Before any runtime changes, audit current Calendar implementation and existing provider/data/persistence contracts against the canonical specification. Do not alter provider, identity, schema or persistence behavior as part of visual alignment without separate authorization.
5. Run focused Calendar widget tests, all six Build shards, independent visual golden, Calendar Provider and all seven Device Smoke lanes on one exact final SHA. No prior-SHA result transfers.
6. Calendar CI checkpoint on SHA `5bea1ed67549e26aa2ceeb0882477d4cfc2c1f53`: Build #42011495370 FAILURE (test-0/test-2/visual failed); Device Smoke #42011495381 CANCELLED (4 PASS / 3 CANCELLED); Calendar Provider #42011495562 SUCCESS; Follow-up Persistence #42011495565 SUCCESS; Parallel Wave Contract #42011495436 SUCCESS.
7. No code/test change is authorized by this backlog registration. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; Release BLOCKED — RELEASE: NO-GO.


---

## مصوبه محصولی — یکپارچه‌سازی UI/UX سه صفحه اصلی آروین (2026-11-05)
**Status:** APPROVED — DOCUMENTED / IMPLEMENTATION NOT AUTHORIZED BY THIS ENTRY  
**Canonical documents:**
- Home: `docs/project-continuity/task_home_screen_spec.md`
- Task Master-Detail: `docs/project-continuity/task_detail_ui_ux_spec.md`
- Calendar: `docs/project-continuity/calendar_ui_ux_spec.md`

**Product backlog / acceptance slices:**
1. Home: تثبیت هدر و جستجو، منوی فیلتر عمومی، منطق OR/AND پنج فیلتر، مرتب‌سازی Follow-up Date، تفکیک Due/Follow-up/Reminder، پنج گروه زمانی، کارت‌ها، FAB و Bottom Navigation.
2. Task Detail: پیاده‌سازی یک فرم واحد View/Edit بدون جابه‌جایی اسکرول؛ هدر و پنج کارت متادیتا؛ هویت/status/priority؛ Due Date؛ مسئول؛ Reminderها؛ recurrence؛ checklist؛ آخرین Follow-up؛ timeline؛ نوار عملیات ثابت.
3. Calendar: هدر سه‌ناحیه‌ای و Today/Go-to-Date؛ سه‌گانه شمسی/میلادی/قمری؛ Day/Week/Month/Year؛ grid سه‌گانه؛ پنج فیلتر agenda؛ کارت‌های محتوا؛ تنظیم offset قمری و معماری سه‌لایه.
4. Cross-screen design: زبان بصری Microsoft To Do-inspired، Vazirmatn، Persian RTL، رنگ‌های معنایی و کارت‌های گوشه‌گرد.

**Cross-cutting constraints:** عدم ساخت مدل/مخزن موازی؛ استقلال Due Date، Reminder Date، Follow-up Date؛ عدم حدس درباره زمان اجرا و assignment مسئول؛ حفظ قراردادهای Provider و migration. هر slice برای انتقال از APPROVED به IMPLEMENTED/VERIFIED به مجوز اجرایی جداگانه و شواهد exact-SHA نیاز دارد. این ثبت backlog به‌تنهایی هیچ کد یا تستی را مجاز نمی‌کند.

 
## 2026-11-05 — Execution audit and current backlog disposition

**Audit:** docs/audit/ARVIN_ISSUE_823_UIUX_EXECUTION_AUDIT_2026-11-05.md  
**Audit baseline:** c35929c1cc2022b8470cd86b6f6fe8e2ae771e5b  
**Status:** execution authorized on PR #3052 branch; implementation remains incomplete.

1. Home: five active filters plus independent sort are present. Active Category label corrected to «دسته‌ها». OR/AND code exists but requires combined-result widget coverage. Past/completed ordering needs a focused assertion. Future aggregate heading date behavior needs product clarification before changing presentation.
2. Task Templates: BLOCKED pending a separate approved Task Template definition and non-destructive G1 migration contract. Existing Project Template infrastructure must be reused; no parallel storage. Then implement real Settings tabs and confirmed conversion from existing Task/Project detail surfaces.
3. Task Clone: existing TaskCloneService and Persian sequential «— رونوشت» behavior retained; rerun focused tests on final SHA.
4. Task Detail: canonical eleven-section spec exists; current runtime form is partial. Implement one-page View/Edit and scroll-offset preservation only after mapping each section to canonical fields and existing stores; no guessed runtime/assignee values.
5. Calendar: preserve existing local/provider paths. Retry Provider acceptance after the baseline Dart Development Service startup failure; distinguish single event deletion from external calendar deletion.
6. Typography: owner decision is final — Vazirmatn for all UI; only the two exact sacred Arabic phrases use the scoped Naskh-style system serif family via `AppFonts.familyForText`. Physical-device glyph shaping remains NOT VERIFIED.
7. Current CI status must always be re-read against the live branch HEAD. No PASS transfers from c35929c or any other historical SHA.
8. PR #3052 stays OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.



## 2026-11-05 — اجرای مهندسی موازی پس از دستور صریح مالک محصول

این checkpoint، وضعیت اجرایی را نسبت به ممیزی قبلی به‌روزرسانی می‌کند؛ ممیزی قبلی حذف نمی‌شود.

1. **Home:** اصلاحات پنج فیلتر و sort در مسیر فعال حفظ شد؛ تست تعاملی ترکیب OR بین چند دسته و AND با فیلتر زمان، Past و اولویت کارت‌های گذشته اضافه/تکمیل شد. exact-SHA CI هنوز NOT VERIFIED است.
2. **Task Templates / Project Templates:** قرارداد داده در TASK_TEMPLATE_DATA_CONTRACT.md ثبت شد؛ G1 v11 جدول Task Template و مهاجرت غیرمخرب checklist_enabled را دارد؛ نصب هم‌زمان schema برای هر executor serialized شد؛ دو تب عملیاتی تنظیمات، تبدیل Task از فهرست و جزئیات، تبدیل Project از مسیر Projects → Project Details و نمایش الگوهای ذخیره‌شده پیاده‌سازی و تست‌های سرویس/UI اضافه شدند. همه این موارد تا exact-SHA tests/CI «پیاده‌سازی‌شده اما تأییدنشده» هستند.
3. **Task Detail:** مسیر فعال یک فرم واحد View/Edit با هدر ذخیره/لغو، حفظ scroll controller، draft چندفیلدی، Checklist اتمیک با افزودن/ویرایش/حذف/جابجایی، Reminder، Due Date، Recurrence شامل تاریخ پایان، وضعیت/اولویت و نمایش عنوان/یادداشت Follow-up را دارد. تست حفظ scroll offset و تست تعامل Checklist/Recurrence/Due Date اضافه شد.
4. **بندهای غیرقابل حدس Task Detail:** زمان اجرا همچنان بدون فیلد canonical و «نامشخص» است؛ assignment مسئول در مدل فعلی اثبات نشده و NOT VERIFIED می‌ماند. People مرتبط به‌عنوان مسئول نمایش داده نمی‌شود. مرکز/پروژه فقط از رابطه و context موجود نمایش داده می‌شوند.
5. **Visual:** علت قطعی ticker از کد TaskDetailPage اثبات نشد؛ کد صفحه فاقد AnimationController/Ticker/Timer.periodic است و fixture نیز CircularProgressIndicator فعال ندارد. شکست مشاهده‌شده در انتظار ۱۰ دقیقه‌ای pumpAndSettle رخ داده است. تست به pump قطعی ۳۵۰ms و assertion idle-frame تغییر یافت؛ این اصلاح تا اجرا NOT VERIFIED است. Golden مرجع task_detail_visual_test.png در شاخه و main موجود نیست؛ تولید/تأیید Golden بدون تصویر واقعی و بازبینی بصری ممنوع است.
6. **Calendar Provider / Device Smoke:** هیچ Run روی HEAD فعلی در زمان ثبت این checkpoint موجود نبود؛ اجرای exact-SHA تأیید نشده است. تست‌های قدیمی یا PASS روی SHA دیگر قابل انتقال نیستند.
7. **Typography:** تصمیم مالک ثبت و در کد اعمال شد؛ Vazirmatn فونت عمومی UI است و فقط دو عبارت «بسم‌الله الرحمن الرحیم» و «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» از whitelist خط نسخ استفاده می‌کنند. آزمون glyph روی دستگاه هنوز انجام‌نشده است.
8. **Release gate:** Issue #823 هنوز کامل نیست. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## 2026-11-05 — اجرای تکمیلی تصمیم تایپوگرافی و آزمون‌های فرم
- `AppFonts.familyForText` فقط دو عبارت قرآنی مصوب را به خانواده serif/Naskh-style نگاشت می‌کند؛ سایر متن‌ها Vazirmatn می‌مانند. Home و Calendar از این whitelist استفاده می‌کنند.
- تست Home برای عبارت بسم‌الله و تست Calendar برای عبارت تفویض و متن فارسی عادی، مرز استثنا را بررسی می‌کنند.
- تست حفظ Scroll Offset فرم Task Details هم ورود/لغو و هم ورود/ذخیره موفق را پوشش می‌دهد.
- Visual test از `pumpAndSettle` نامحدود به pump قطعی و assertion نبود frame معلق تغییر کرده است. Golden مرجع هنوز در مخزن موجود نیست؛ بنابراین Visual acceptance همچنان BLOCKED تا ایجاد و بازبینی Golden واقعی.
- تمام نتایج تست و CI باید به HEAD نهایی همین شاخه منتسب شوند؛ وضعیت انتشار NO-GO باقی است.


## اجرای تجمعی — آخرین پوشش محصولی
- Task Template / Project Template: G1 v11, canonical Drift, Settings two-tab hub, list/detail conversion and non-destructive migration tests are implemented; all exact-HEAD acceptance remains pending CI.
- Task Details: unified 11-section layout and inline save/cancel; scroll offset is tested for entering, cancelling and successful save in `test/task_detail_master_screen_test.dart`.
- Home: interactive OR/AND test is `test/home/home_filter_boolean_logic_test.dart`.
- Visual: deterministic pump removes the 10-minute `pumpAndSettle` wait; Golden file remains absent and Visual acceptance remains BLOCKED pending actual reviewed screenshot.

## 2026-11-05 — Exact-SHA G1 compile blocker disposition
- On SHA `9d095113ac83d827868473a65b0fd2a83d15ac99`, Follow-up File Persistence run `42069322654` failed before executing its test: Dart rejected `Expando<Future<void>?>` because `Expando` requires a non-nullable `Object` value type. The log reported `0 tests passed`.
- The type issue was corrected on the authorized branch using `Expando<Object>` with a checked `Future<void>?` read. Changelog records the correction. Re-run on the new exact SHA is required; no PASS is inferred.
- Golden baseline remains absent. Do not fabricate or auto-update it. The two sacred phrases still use system `serif`; a bundled Naskh family and both-phrase rendering test remain outstanding.
- Keep PR #3052 OPEN / DRAFT / UNMERGED and release **BLOCKED — RELEASE: NO-GO**.

## 2026-11-05 — Typography and Task Details visual smoke recovery

- Sacred phrase styling is scoped to the two exact approved Arabic phrases. Current implementation uses system serif plus an ordered Naskh family fallback list; Vazirmatn remains the app-wide default. Bundled Naskh font asset is not yet present; physical-device shaping is NOT VERIFIED.
- Home and Calendar const-expression compile errors and Task Details missing TaskTemplateStore getter/runtime PopupMenuItem const errors were found in exact-SHA CI logs on f44fb03 and corrected on the authorized PR branch.
- Task Details visual test now verifies nine actual content sections plus AppBar and fixed bottom actions, checks measurable geometry, vertical scroll extent, and render exceptions. It no longer depends on a missing golden PNG. This is structural/layout acceptance, not pixel-golden approval.
- Fresh exact-SHA Build, Drift v11, Follow-up Persistence, Home filter, sacred phrase and Task Details tests are required. No previous-SHA PASS carries forward.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; BLOCKED — RELEASE: NO-GO.


## قرارداد نهایی تایپوگرافی و بردارسازی دو عبارت — ۱۴۰۵/۰۸/۱۴ (2026-11-05)
- Vazirmatn تنها خانواده فونت متنی مجاز برای تمام UI است؛ حذف تمام استثناهای serif/Naskh/Amiri و fallbackهای متنی الزامی است.
- دو عبارت مقدس دیگر Text widget نیستند: بسم‌الله در هدر Home و دعای تفویض در سربرگ تقویم باید SVG اختصاصی path-based باشند.
- معیار SVG: vector path واقعی، مقیاس‌پذیری گوشی/تبلت، روشن/تاریک، رنگ سرمه‌ای برند، بدون shadow/background سنگین، semantics متنی قابل دسترس؛ SVG مبتنی بر font/text یا raster embedded رد است.
- عرض هدف بسم‌الله در موبایل حدود ۱۸۰–۲۳۰px و در تبلت responsive است.
- مرجع تصویری خوشنویسی مورد تأیید در دارایی‌های قابل بازیابی یافت نشد؛ تطبیق دقیق calligraphy تا دریافت همان مرجع NOT VERIFIED است. نباید شکل خوشنویسی حدسی به‌عنوان نسخه تأییدشده ثبت شود.
- اصلاحات فوری CI در HEAD قبلی: const invocation در home_visual_integration، fixture غیر const در task_detail_template_conversion_test، و ListTile/Material warning در Task Details card. Layout Smoke ابعاد finite را نیز assert می‌کند.
- Build exact-head قبلی FAILED: Analyze دارای خطای const در home_visual_integration و fixture تست؛ visual smoke با FlutterError مربوط به ListTile/Material شکست خورد؛ شاردهای تست نیز assertion failures دارند. APK matrix در PR Draft اجرا نشده است.
- Device Smoke همان SHA کامل نشده و نتیجه هفت‌مسیره NOT VERIFIED است.
- هیچ PASS از SHA قبلی به HEAD بعدی منتقل نمی‌شود. PR #3052 OPEN/DRAFT/UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## به‌روزرسانی اجرای قرارداد نهایی — ۱۴۰۵/۰۸/۱۴ (2026-11-05)
- در کد، AppFonts به یک خانواده متنی واحد Vazirmatn محدود شد؛ serif سیستم، Naskh fallback و هرگونه fontFamilyFallback از Home و Calendar حذف شد.
- تا زمان ثبت SVGهای path-based، دو عبارت به‌طور موقت در Text widget با Vazirmatn رندر می‌شوند؛ این وضعیت فقط گذار ایمن است و پذیرش نهایی vector typography محسوب نمی‌شود.
- تست Home/Calendar برای نبود fallback و یگانگی Vazirmatn به‌روزرسانی شد؛ تست HomeVisualIntegration نیز دیگر انتظار فونت ثانویه ندارد.
- موانع exact-head قبلی در کد اصلاح شدند: const نامعتبر در HomeVisualIntegration، fixture غیر const در Task Template Conversion، Material surface در کارت‌های Task Details، و finite width/height در Layout Smoke.
- HEAD کد پس از اصلاحات: `2a50457cde537ca02544839397c88c998153f5b4`. پس از آن، این ثبت مستندات SHA را تغییر می‌دهد و تست‌های exact-SHA باید روی آخرین HEAD جدید اجرا شوند.
- GitHub workflow API برای HEAD کد فعلی اجرای جدیدی گزارش نکرد؛ بنابراین نتیجه اصلاحات و Layout Smoke روی این HEAD هنوز **NOT VERIFIED** است. هیچ نتیجه قدیمی به این SHA منتقل نمی‌شود.
- مسیر SVGها، dependency رندر SVG و تست روشن/تاریک/چندرزولوشن تا دسترسی به تصویر مرجع و پیاده‌سازی واقعی باقی است.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## AIPOS v1.0 delivery sequence — 2026-11-05
1. Keep flutter_svg 2.3.2 and pubspec.lock synchronized; validate with enforce-lockfile.
2. After the approved calligraphy references are accessible, create authentic path-only Bismillah and Tafweez SVG assets; use SvgPicture.asset with one semantic label in Home and Calendar.
3. Test SVG path-only structure, Vazirmatn-only text, RTL, light/dark, phone/tablet sizing and overflow. Preserve all existing tests.
4. Resolve Flutter Analyze and all Home/Calendar/Task Details test failures without skipping or weakening tests.
5. Run flutter analyze, full flutter test, Debug and Release APK builds on one candidate SHA.
6. Complete seven Device Smoke lanes, Calendar Provider acceptance and APK artifact inspection on that same SHA.
7. Obtain product-owner acceptance. Until then PR #3052 stays OPEN/DRAFT/UNMERGED and release stays NO-GO.
- Reference images are not currently accessible; exact calligraphy match remains NOT VERIFIED.


## Delivery phases — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06
1. **P0 — Release/Device Smoke recovery:** complete and validate all seven canonical Device Smoke lanes on one exact candidate SHA; preserve screenshots/artifacts and diagnose cancelled Boot/Navigation jobs and the still-running Calendar lane. No gate is promoted by partial success.
2. **P1 — Product completion and regression closure:** finish remaining product/quality work only through canonical stores and repositories; retain the unified Report Filters route and Quick Capture empty-title feedback; run exact-SHA Analyze, all test shards, visual checks, provider and persistence gates.
3. **Phase 1 — Local P2P:** design and implement authenticated, secure local-network synchronization only after threat model, pairing lifecycle, conflict semantics, deletion/tombstone retention, clock-skew handling and owner approval. No parallel data store.
4. **Phase 2 — Cloud synchronization:** separate future phase, after Local P2P is accepted; cloud/Dropbox is not a prerequisite or substitute for Phase 1.

Current checkpoint: Smoke run `42169009238` remains IN_PROGRESS with cancelled Boot/Navigation and Calendar still in progress; P0 is NOT VERIFIED. Release remains NO-GO.


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


# REV7.2 Wave Roadmap — 2026-11-10

## Wave 0 — Governance & Source of Truth
- Goal: establish one master governance source, synchronized decision register, exact-SHA current state, issue ledger, roadmap, implementation log and handoff.
- Dependencies: none beyond live GitHub read access and authorized branch.
- Files: all eight canonical files in docs/project-continuity/.
- Acceptance: eight canonical files exist; master links to the seven supporting files; prior history retained; no source ZIP gate; commit is a single documentation-only commit on the authorized branch; verify branch SHA after push.
- Tests/evidence: GitHub file fetches, diff review, internal-link/path check, parent SHA lease, post-push ref and file fetch.
- Status: READY for documentation-only deployment on the authorized branch; Main remains read-only.

## Wave 1 — Data Integrity & Architecture
- Goal: settle four-state Reminder semantics; verify Task/Reminder/Follow-up separation; review Drift v16 migrations, backups, restore, referential integrity, data-loss and rollback behavior.
- Dependencies: Wave 0 baseline; explicit product semantics for the four Reminder states; inspection of an actual user DB and backup before any destructive migration.
- Files: lib/models/task.dart; lib/services/g1_drift_schema.dart; lib/services/task_store.dart; lib/services/canonical_backup_manager.dart or active backup implementation; migration/backup tests.
- Acceptance: state-transition table approved; no parallel store; schema/backup compatibility tests; real DB row-count and backup evidence; injected failure/rollback tests; no data loss.
- Status: BLOCKED for execution pending Reminder-state contract and real-data/backup inspection. Audit findings are documented; no code changes authorized here.

## Wave 2 — Core Task Lifecycle
- Goal: complete always-editable auto-save, due date, independent Reminder, Follow-up, recurrence, occurrence history and per-occurrence checklist behavior.
- Dependencies: Wave 1 data invariants; REV7.2 decision ARVIN-DEC-2026-11-10-001.
- Files: lib/task_detail_page.dart; lib/models/task.dart; lib/services/task_store.dart; lib/services/task_recurrence_repository.dart; follow-up/reminder services and focused tests.
- Acceptance: every field persists via canonical store; no separate edit mode; no partial writes; exit/reopen preserves confirmed values; recurrence history immutable; reminder and due date independent; Follow-up remains historical and independent.
- Tests: Task Details widget tests; task contract; reminder persistence; recurrence repository; checklist occurrence; follow-up persistence; restart/close-reopen tests.
- Status: PARTIAL / BLOCKED by six failing test shards and incomplete auto-save proof. No tests may be removed or weakened.

## Wave 3 — Home, Quick Capture & Filters
- Goal: complete five filters in required order, OR within group/AND across groups, full sort options, Inbox behavior, Home grouping, Follow-up summaries and responsive geometry.
- Dependencies: Wave 1 hierarchy/data contract and Wave 2 lifecycle semantics.
- Files: lib/main.dart; lib/home/home_filter_ui.dart; lib/home/grouping/home_grouping_service.dart; lib/services/task_list_sort_service.dart; lib/widgets/reusable_multi_select_filter_bottom_sheet.dart; lib/quick_capture_dialog.dart; related tests.
- Acceptance: time → center → project → category → tag; single-select Center/Project/Category; multi-select Tags; no mandatory classification; Inbox contract; complete alphabetical/date/priority/oldest/newest/reverse sorting; 360/390/412dp tests; all touch targets >=48dp.
- Status: PARTIAL / BLOCKED by failing Home and Quick Capture tests and incomplete 48dp/viewport proof.

## Wave 4 — Notebook, Calendar & Templates
- Goal: preserve independent/linked notes, safe deletion/unlink, first-save title behavior, deep template cloning and full internal/external calendar separation.
- Dependencies: Waves 1–3; template membership contract and Notebook deletion semantics.
- Files: lib/notebook_page.dart; lib/services/canonical_notebook_repository.dart; lib/models/task_template.dart; lib/task_template_management_page.dart; lib/calendar_page.dart; lib/services/system_calendar_bridge.dart; lib/services/calendar_provider_sync_executor.dart.
- Acceptance: note survives Task deletion/unlink; convert preserves text; title generated only at first save; templates preserve requested definition fields and omit execution history; new dates shift correctly; external event deletion never deletes internal Task; Jalali/Hijri/Gregorian and prayer/tafweez layers independently accepted.
- Status: PARTIAL. Calendar Provider run PASS on exact SHA; Notebook/template edge contracts and physical calendar acceptance remain NOT VERIFIED.

## Wave 5 — Reports, Sync & Enterprise Acceptance
- Goal: correct reports/PDF/instalments, validate data accuracy, establish Local P2P end-to-end and close full product/device/security acceptance.
- Dependencies: Waves 1–4; approved sync threat model and conflict semantics; NIRA end-to-end proof.
- Files: lib/report_center_page.dart; lib/services/task_report_pdf_renderer.dart; sync services/specifications; NIRA client adapter and evidence workflows.
- Acceptance: report totals reconcile to canonical rows; PDF/print/share evidence; secure pairing and conflict tests; exact-SHA Build, all six test shards, seven Device Smoke lanes, Calendar Provider, Follow-up Persistence, backup/restore, security and owner acceptance.
- Status: BLOCKED. Report-related tests fail; Local P2P E2E and NIRA L10 remain NOT VERIFIED; Device Smoke incomplete.


## WAVE 4 REV8 — SQL consolidation delivery status (2026-11-10)

**Status: PARTIAL / BLOCKED.** Task and Project migration conflict/parity checks, relational Project ordering, unknown Project field preservation, Recurrence SQL and Occurrence/per-occurrence checklist SQL have been implemented in the working branch. Destructive legacy retirement was deferred.

Remaining sequence:
1. Complete exact-SHA Build, test-shard, integration and Device Smoke validation.
2. Add full parity/conflict checks to G1 legacy Follow-up, Person and relation migration.
3. Build one recoverable multi-source migration transaction.
4. Normalize remaining Task/Project envelopes, template JSON columns and SharedPreferences owners.
5. Complete Backup/Restore for all approved entities and verify close/reopen round-trip.
6. Prove every legacy retirement gate and obtain Mobin acceptance.
7. Keep Release NO-GO until every acceptance gate passes.


## 2026-11-12 — COMMAND 07-A.2.21 checkpoint

### فونت
- VazirHarf v34.003 UI-Farsi-Digits به‌عنوان خانواده canonical برنامه ثبت شد؛ پنج وزن و مجوز OFL 1.1 همراه منبع upstream pin‌شده مستند شده‌اند.
- Vazirmatn legacy assetها برای حفظ تاریخچه نگهداری می‌شوند، اما runtime/public APK نباید به آن‌ها وابسته باشد.

### SQLite
- Snapshotهای A-D و پنج چرخه Reopen روی SHA b9d88bf موفق بوده‌اند.
- D01 تست‌های مستقل حفظ custom index، custom trigger و outgoing foreign key دارد؛ برای پذیرش نهایی باید Shardهای همان SHA نهایی سبز شوند.
- D02 تست Missing و NULL صریح و مقادیر boolean/ستون legacy را پوشش می‌دهد؛ بررسی اجرای کامل روی SHA نهایی همچنان لازم است.
- D03 شناسه/ترتیب Follow-up، Person links و futureFollowUpField را در round-trip و پنج چرخه بررسی می‌کند.
- D04 شناسه، تاریخ، ترتیب و enabled state یادآورها در migration/reopen تست شده‌اند؛ Backup/Restore کامل هنوز باید با شواهد مستقل نهایی شود.
- D05 rollback در صورت constraint violation تست شده؛ recovery پس از خطای migration باید در گیت نهایی تعیین تکلیف شود.

### Regression و Device
- اصلاح تست‌های Home، Task Details و PDF ثبت شده‌اند، اما سه Shard باقیمانده و مجموعه کامل شش Shard هنوز پذیرش نهایی ندارند.
- Device Smoke شامل Boot، Navigation، Calendar، Task Lifecycle، Follow-up Persistence، Reminder و Quick Capture است؛ فقط نتایج همان SHA نهایی معتبرند.

### Exit gates
Analyze، شش Shard، Visual، Debug/Staging/Release APK، هفت Device Smoke و Artifact SHA256 باید همگی روی یک SHA واحد موفق باشند. Merge/Release/Deployment مجاز نیست.


## COMMAND 07-A.2.24 — typography acceptance lane

Add a blocking owner-approved typography lane: restore Vazirmatn as the only official default; inventory/pin upstream source and license; bundle five local weights with verified SHA-256; centralize Theme and explicit weight mapping; implement accessibility-preserving global rendering; expose exactly Vazirmatn and System Default preferences with restart persistence; audit actual APK assets; inspect actual PDF font embedding; and validate Persian/RTL on device. A source registration or test-only assertion is not acceptance. The detailed contract is proposed in PR #3388 at `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md`.


## COMMAND 07-A.2.25 — 2026-11-12

Canonical typography authority: `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md` (recorded on documentation PR #3388). Vazirmatn is the sole official/default family; System Default is the only optional preference. This entry supplements historical records and does not erase them.

Live checkpoint at this entry: PR #3384 HEAD `2ac3580985a23e6ac5342d49c33343c8b4f01816`; PR remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. PR #3388 remains OPEN / DRAFT / UNMERGED.

Implementation changes on PR #3384: corrected Alarm Overlay and Calendar font-family references; removed their local family overrides so the root Theme controls Vazirmatn/System Default; aligned Device Smoke scenario `smoke-reminder-vazirharf` with `smoke-reminder-vazirmatn`; aligned its workflow contract test. Related commits include `415cb976ad280f28ff8b780ffe6b4d3a6a8ff17b`, `951d5bd1b359d59ec84662ededcd2f1515083d70`, `8f159f5597a020b3d1e06665c5c123b686872162`, `8127c7a3bc85e9d155ec7131cec25b570eaa787f`, `fbf1b6502a7baed655a9a479fbc28abc6789be3b`, `6fe8a2fbdbb47c6cac402b4d0cf61eb75c23043c`, `83208c93d06ac42b478d0f46212338873f5c7e95`, `a3001d2ac5f81ef44b12514f1f90418f283b9409`, `f63f38b332df68ddc2588eb256378842f9705cfd`, `195e8a9e3802c8637b597c23245dbe86561791ee`, `e8c27100ffa70ebe183e66975380d861d34cb973`, `bcb2d24f94f6c23a8f3131aa5853ad8afb6bf507`, and final `2ac3580985a23e6ac5342d49c33343c8b4f01816`.

Exact-head CI at `2ac3580985a23e6ac5342d49c33343c8b4f01816`: Build run `43217473284` PENDING; Device Smoke `43217473090` QUEUED; SQLite Snapshot `43217473138` QUEUED; Follow-up File Persistence `43217473064` IN_PROGRESS. No outcome is claimed. Older Snapshot run `43212724352` passed on `e94105443e7516ed38eda6feaaee125d92fabaf4` only and cannot be transferred to the current SHA.

The active `main-protection` ruleset remains insufficient: zero required approvals and `require_code_owner_review=false`. CODEOWNERS is present on PR #3388 but effective enforcement is not yet enabled. Release remains NO-GO; no merge, release, deployment, data-destructive operation or history rewrite is authorized.

## Remaining P0 gates
- Complete exact-head Build, Analyze, six regression shards and seven Device Smoke lanes.
- Complete five-weight APK audit for Debug/Release and actual PDF embedding/shaping validation.
- Complete SQLite D01-D05 and five persistence cycles on one exact SHA; do not transfer older snapshot evidence.
- Enable required CODEOWNER approval in the active Ruleset; current ruleset remains at zero approvals and code-owner review disabled.

## COMMAND 07-A.2.82 — prioritized delivery sequence — 2026-11-14

1. P0 — Exact-SHA SQLite acceptance: poll and complete D01–D05, Snapshot, Follow-up Persistence and Build on one current candidate. Never transfer parent SHA PASS.
2. P0 — Regression recovery: investigate the 41 inherited test failures individually; distinguish production defects from outdated expectations only with approved contract evidence.
3. P0 — Coverage preservation: execute the 24-test historical coverage reconciliation; preserve M2M equivalents and explicitly document only the four superseded single-parent behaviors.
4. P0 — Typography: normalize w800/w900 custom styles where no approved exception exists; run exact-SHA Analyze, APK, PDF embed/Unicode and actual rendered-device validation.
5. P1 — Canonical repository integration after SQLite acceptance: migrate CenterStore, ProjectStore, TaskStore, Category CRUD, selectors, Home filters, Calendar, Reports, Search, Notebook and Backup/Restore to one M2M SQL source of truth. No parallel repositories or destructive legacy retirement.
6. P1 — Product backup parity: integrate physical SQLite backup/restore in the production service path and verify independent restore, IDs, metadata, foreign keys and rollback.

Release remains NO-GO. No merge, deployment or production data migration is authorized.
