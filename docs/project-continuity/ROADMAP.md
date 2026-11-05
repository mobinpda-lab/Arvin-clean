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


## 2026-11-05 — Module-Core-Logic backlog (audit only)
1. **P0 / Reminder delivery correctness:** ensure disabled `TaskReminder` entries are excluded by the actual delivery service, not only by the next-alarm planner; add direct delivery-service regression tests.
2. **P0 / Idempotency:** define and test an idempotency rule for repeated Reminder creation so retry/double-submit cannot create unintended duplicate records. Do not collapse distinct Reminders that intentionally share a time.
3. **P0 / Legacy migration safety:** inspect real user DB counts/values and verified backup/restore before deciding how `followUpEnabled`, `followUpDate`, `FollowUp.reminderDate` and `nextFollowUp` are preserved, converted or retired. No destructive DDL before approval.
4. **P0 / Test scenario mapping:** map each removed/rewritten PR test scenario to its approved replacement or obtain explicit owner disposition. Current PR-wide preservation claim remains NOT VERIFIED.
5. **Acceptance:** run focused tests and all required exact-SHA workflows after any authorized code change. This registration does not authorize source, schema, migration or test changes.
## UI design system rollout — 2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
1. **P1 / Cross-screen card audit:** inventory every custom card-like Container/BoxDecoration in Task Lists, Task Details read-only/edit, Calendar and Quick Entry; migrate only presentation to shared card tokens without changing behavior.
2. **P1 / Visual regression:** add/retain widget assertions for token application, Persian RTL labels, contextual icons, P1–P4 semantic mapping, status and Center → Project → Category → Tags chips. Do not remove or weaken existing scenarios.
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
6. Typography: Product Decisions records owner clarification required for the Naskh sacred-phrase treatment versus the global Vazirmatn rule. Do not change rendering before decision.
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
