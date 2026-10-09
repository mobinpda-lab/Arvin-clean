# ARVIN MASTER EXECUTION PROTOCOL (AMEP)

Repository: mobinpda-lab/Arvin-clean

## Mission
رساندن آروین به محصول نهایی: Complete, Beautiful, Fast, Stable, Reliable, Daily Usable, Release Ready.

## Core
PRODUCT > FACTORY  
USER DATA > CONVENIENCE  
EVIDENCE > CLAIM  
GSoT > CHAT MEMORY  
FINISH EXISTING > START NEW  
QUALITY + SPEED

GitHub حافظه رسمی پروژه است. Factory، CI و Automation ابزار هستند؛ معیار موفقیت، استفاده واقعی و روزانه کاربر از محصول است.

## GitHub Source of Truth
تصمیم‌ها و وضعیت‌های مهم باید در GitHub ثبت شوند: ARC, UXD, VR, BUG, SOL, STATUS, EV, REL.

## Continue Arvin / Reality Snapshot
هر اجرای «ادامه آروین» ابتدا بدون تغییر کد Reality Snapshot تهیه می‌کند: Current Version, Current Branch, Active PR, Open Issues, CI Status, Release Status, Top Bottleneck؛ سپس MAIN/COMMIT/BRANCH/ISSUE/PR/CI-CD/WORKFLOW/DOCUMENTATION/DECISION/AUTOMATION/RELEASE بررسی و به DONE/IN PROGRESS/BLOCKED/FAILED/UNKNOWN طبقه‌بندی می‌شوند.

## Decision / Create / Anti-Repeat
پیش از تغییر مهم: Goal / Problem / Solution / Impact / Protected ثبت می‌شود؛ پس از اجرا: Changed / Evidence / Remaining / Next Step.  
پیش از Create، Issue/PR/Branch/Commit/Code/Test/Docs/Decision/Workflow/Automation/CI/Evidence مرتبط بررسی می‌شوند. اولویت: UPDATE EXISTING → COMPLETE EXISTING → VALIDATE EXISTING → REPAIR EXISTING → CREATE NEW فقط با دلیل. Duplicate Feature/Architecture/Storage/Task System ممنوع.

## Execution / Priority / Parallelism
RECOVER → READ GH → RS → AGR → BOTTLENECK → DEC → EXECUTE → VALIDATE → EVIDENCE → RECORD → CONTINUE

P0: Data Loss, Crash, Release Blocker, Core Failure  
P1: Severe UX/Visual/Performance  
P2: Improvement

Trackهای مستقل Core/UX/Test/Build-Release/Documentation می‌توانند موازی اجرا شوند، مشروط به نبود Conflict/Duplicate/Data Risk.

## Factory / CI
Automation باید Build/Test/Validate/Evidence/Report تولید کند؛ Factory برای Factory ممنوع. Analyze, Unit, Widget, Integration, Build و Android Smoke بدون کاهش پوشش موازی شوند و Smokeهای مستقل تا حد امکان جدا اجرا شوند.

## UX / Visual
آروین باید Personal Assistant باشد، نه Generic Task Manager. UI: Persian, RTL, Modern, Calm, Professional, Readable.  
Visual Reference: Primary #4A4CAB; Light #E9EAFF; Background #F8F8FB; Card #FDFDFE; Text #232433; Secondary #80829C.  
Home, Task Form/Detail, Follow-up, Calendar, Date/Time و Report Center مشمول Visual Gate هستند.

## Home Contract
Home = Daily Command Center، نه Report. چهار فیلتر واقعی: Time / Project / Category / Tag؛ هرکدام Card/State/Active State و Bottom Sheet اختصاصی آروین دارد. Time: Today/Tomorrow/This Week/Past/Future/No Date/From Date/To Date/From Time/To Time. ترکیب فیلترها AND است. گروه‌ها: Past/Today/Tomorrow/Future/No Date با Header/Icon/Count/Expand-Collapse.

## Report Filter Center
Report Center مستقل است و Home را تغییر نمی‌دهد. Filter/Analysis/View/Share/Print/Export. فیلترها: Time/Project/Category/Tag/Status/Priority/Repeat/Follow-up/Checklist/Date Range/Time Range. ترکیب چند فیلتر الزامی؛ Share/Print موجود استفاده شود؛ Report Engine جدید ممنوع.

## Task / Checklist
Task هسته محصول است: Title/Description/Date-Time/Project/Category/Tag/Priority/Checklist/Repeat/Follow-up/Next Action. برای سناریوهای مختلف Entity جدید ساخته نمی‌شود.

Checklist مستقل نیست: ONE TASK + OPTIONAL CHECKLIST + EXECUTION STATE. Checklist متعلق به Task است؛ Storage/Page/System موازی ممنوع. Create/Edit دارای Toggle است؛ ON حالت Add/Delete/Edit/Reorder/Check را در همان Task فراهم می‌کند. در Repeat، Definition متعلق به Task و Execution State متعلق به Occurrence است و وضعیت قبلی منتقل نمی‌شود.

## Repeat Lifecycle Contract
طبق تصمیم معماری Issue #2254: یک Task اصلی؛ برای هر تکرار Task جدید ساخته نمی‌شود. Repeat Definition: Start/Pattern/Interval/End/Count/Active. Occurrence: Scheduled Date/Completion Date/Status/Checklist State/Result. History immutable؛ تغییر Repeat فقط آینده را تغییر می‌دهد. Status: Pending/Completed/Missed/Skipped/Cancelled.

## User Data / Migration Compatibility
هیچ تغییر نباید Data/Storage/Backup/Restore را خراب کند. پیش از تغییر داده بررسی شود: Old Data Readable / Migration Required / Rollback Possible / Backup Safe. تغییرات Task/Repeat/Checklist/Backup/Restore مشمول Compatibility/Migration/Rollback/Old Version Support هستند.

## Validation / Golden Flow / DoD
هر تغییر: Analyze+Test، Feature Test، Flow Test، Real Build و برای UI Screenshot+Visual Review. Golden Flows: Create/Edit/Complete Task، Date-Time، Checklist، Repeat، Follow-up، Project/Category/Tag Filter، Search، Report، Backup، Restore. Full Flow: Create → Schedule → Checklist → Repeat → Follow-up → Complete → Backup → Restore.

هیچ موردی بدون Evidence Done نیست. UI: Build + Screenshot + Visual Review. Data: Compatibility + Backup + Restore. Core: End-to-End Evidence.

## Release / Device
نزدیک RC، Feature جدید غیرضروری ممنوع؛ تمرکز Bug Fix/UX-Visual Polish/Performance/Regression/Data Safety/Release. RC فقط با تأیید Home/Filter/Task/Date-Time/Checklist/Repeat/Follow-up/Calendar/Report/Backup/Restore/Data Safety/Golden Flow/Build/Device Validation.

گوشی کاربر ابزار توسعه نیست؛ فقط برای Final Verification پس از RC. مشکل Emulator/CI فقط همان بخش را Block می‌کند.

## Reporting / Final
گزارش کاربر حداکثر ۳ خط: Status / Done / Block، ساده و محصول‌محور.

هیچ چیزی دوباره ساخته نشود؛ تصمیم‌ها فراموش نشوند؛ کار بدون GH Review شروع نشود؛ هیچ چیز بدون Evidence تمام‌شده اعلام نشود.

GITHUB REMEMBERS  
FACTORY EXECUTES  
AUTOMATION ACCELERATES  
EVIDENCE PROVES  
PRODUCT WINS

FINISH THE PRODUCT


## Calendar Repeat Projection Window — Product Decision

تقویم برای هر Repeat فقط **۷ تکرار بعدی** را به‌صورت projection نمایش می‌دهد. این عدد عمداً برابر پنجره یک‌هفته‌ای تقویم انتخاب شده تا تکرارهای روزانه کل هفته را پوشش دهند و تقویم شلوغ نشود.

- با وقوع/عبور هر تکرار، پنجره به‌صورت rolling دوباره محاسبه می‌شود و تکرار بعدی وارد می‌شود.
- این تکرارهای تقویمی Task یا رکورد ذخیره‌سازی مستقل نیستند.
- Count و End Date همچنان محدوده معتبر Repeat را تعیین می‌کنند.
- Task canonical، تاریخچه، Checklist occurrence state و Backup/Restore منبع حقیقت باقی می‌مانند.

## Repeat Tracking Level Contract

Repeat می‌تواند دو سطح تجربه داشته باشد، بدون ساخت سیستم جدید:

- **NORMAL:** برای کارهای روزمره، عادت‌ها و یادآوری‌های ساده؛ نمایش Current Status، Next Occurrence و Completion.
- **TRACKING:** برای تعهدها، پرداخت‌های دوره‌ای، قراردادها و پیگیری‌های مهم؛ نمایش Start Date، Total Occurrences، Completed، Missed، Remaining، Next Occurrence، Last Status، History و Progress.

در رابط کاربر اصطلاحات فنی مانند Recurrence، Occurrence، Lifecycle و Tracking Level نمایش داده نشود. کاربر فقط انتخابی ساده مانند «نوع پیگیری: عادی / مهم و قابل پیگیری» می‌بیند. امکانات TRACKING فقط با Progressive Disclosure و هنگام نیاز آشکار می‌شوند.

**Protected:** یک Task canonical، Repeat architecture #2254، Checklist per occurrence، Backup/Restore و User Data Guard.

## 56. Autonomous Product Completion Mode
عامل اجرایی پس از «ادامه آروین» فقط گزارش نمی‌دهد؛ Reality Snapshot می‌گیرد، تصمیم می‌گیرد، در GitHub ثبت می‌کند، اجرا می‌کند، Validate و Evidence تولید می‌کند و ادامه می‌دهد. فقط تصمیم محصولی، ریسک Data، انتخاب رفتاری مبهم یا دسترسی ضروری نیازمند توقف و سؤال از کاربر است.

## 57. No Idle Development
هیچ blocker محیطی نباید کل محصول را متوقف کند. Blocker ثبت و ایزوله شود و کارهای مستقل ادامه یابد.

## 58. Bottleneck Management
در هر چرخه فقط مهم‌ترین Release Bottleneck انتخاب شود. معیار انتخاب Release Impact است، نه آسانی یا جذابیت کار.

## 59. Product Decision Rule
در ابهام: سادگی کاربر، حفظ داده، تجربه روزانه، سازگاری معماری موجود و سپس سرعت توسعه اولویت دارند. پیچیدگی فقط با ارزش واقعی اضافه شود.

## 60. No Over Engineering
Framework، abstraction، سیستم عمومی، معماری یا Storage جدید بدون نیاز واقعی ممنوع. راه‌حل باید Simple, Reliable, Maintainable باشد.

## 61. Feature Completion Rule
Feature فقط وقتی کامل است که User Flow، UX، Visual، Data، Test و Evidence کامل باشند.

## 62. Product Consistency Rule
قابلیت‌ها باید با Task Model، Design System، Navigation، Data Model، Backup/Restore، Search و Filter موجود هماهنگ باشند و جزیره جدا نسازند.

## 63. Release Cleanup
پیش از Release، Unused Code، Dead Feature، Duplicate Logic، Temporary Solution، Debug Element و Incomplete UI بررسی و حذف/اصلاح شوند.

## 64. Final Delivery Report
پیش از اعلام نهایی، گزارش محصولی شامل قابلیت‌های کامل، Flowهای تأییدشده، بهبود تجربه کاربر، Evidence و وضعیت آمادگی استفاده روزانه تهیه شود.

## 65. Final Acceptance Question
آیا یک کاربر واقعی می‌تواند فردا صبح آروین را بدون آموزش خاص برای کارهای روزانه، تعهدها، پیگیری‌ها و برنامه‌های خود استفاده کند؟ اگر خیر، ادامه؛ اگر بله ولی Evidence ناقص است، Evidence تکمیل؛ اگر بله و Evidence کامل است، Release Candidate.

**FINAL PRINCIPLE:** GITHUB REMEMBERS · FACTORY EXECUTES · AUTOMATION ACCELERATES · EVIDENCE PROVES · PRODUCT WINS · FINISH ARVIN

## Operational Acceptance Clarifications — 2026-10-09

این بخش فقط جزئیات پذیرش اجرایی را روشن می‌کند؛ جایگزین قراردادهای قبلی نیست و معماری یا Feature موازی ایجاد نمی‌کند.

### Quick Task and Task Form
- ثبت سریع باید با حداقل اطلاعات لازم ممکن باشد؛ کاربر برای ساخت یک کار ساده نباید از ابتدا با همه گزینه‌های پیشرفته روبه‌رو شود.
- Create/Edit Task باید فارسی، RTL، گروه‌بندی‌شده و مناسب استفاده روزانه باشد. اطلاعات پرتکرار ابتدا؛ Repeat، Checklist، Follow-up و جزئیات کم‌مصرف به‌صورت Progressive Disclosure.
- سناریوهای وام، اجاره، بیمه، ورزش، مطالعه، مدرسه، خرید، سفر و پیگیری مشتری با همان Task Engine عمومی پوشش داده شوند؛ Entity یا Engine موازی ممنوع.

### Checklist interaction and preservation
- Toggle چک‌لیست فقط وضعیت فعال‌بودن نمایش/اجرا را کنترل می‌کند؛ خاموش‌کردن نباید ردیف‌های ذخیره‌شده را پاک کند. ردیف‌ها باید پس از ذخیره/بازگشایی و Backup/Restore قابل بازیابی باشند.
- در Task Detail، آیتم‌ها داخل همان Task و بدون صفحه مدیریت مستقل قابل تیک‌زدن، برداشتن تیک و افزودن باشند.
- در Repeat، تعریف Checklist از Task اصلی و وضعیت اجرای آن از Occurrence مربوطه خوانده شود؛ وضعیت روز قبل به اجرای بعدی منتقل نشود.

### Home time and combined filters
- انتخاب زمان باید رفتارهای موردنیاز را پوشش دهد: امروز، فردا، این هفته، گذشته، آینده، فاقد زمان، تاریخ شروع/پایان و ساعت شروع/پایان. اگر یک گزینه هنوز پیاده‌سازی یا Validate نشده، صرف حضور در سند یا UI به معنی تکمیل نیست.
- فیلترهای زمان، پروژه، دسته و برچسب AND هستند. آزمون باید هم نتیجه منطبق و هم مواردی را که با یک شرط ناسازگارند ثابت کند.
- گروه‌بندی Home باید گذشته/تاریخ‌گذشته، امروز، فردا، آینده و فاقد زمان را با Header، تعداد و Expand/Collapse نمایش دهد؛ Home نباید به Report یا داشبورد تحلیلی تبدیل شود.

### Report Center
- Report Center مسیر مستقل تحلیل/مدیریت/خروجی است و نباید قرارداد روزانه Home را تغییر دهد.
- فیلترهای ترکیبی باید در نتیجه نهایی View/Share/Print/Export اثر داشته باشند. از Share و Print موجود استفاده شود؛ Report Engine جدید ساخته نشود.
- حضور کنترل فیلتر یا دکمه خروجی به‌تنهایی Evidence نیست؛ خروجی باید با همان مجموعه داده فیلترشده سازگار باشد.

### Backup/Restore evidence boundary
- تست Backup/Restore با سرویس fake یا حافظه موقت فقط تست UI/منطق محدود است و اثبات ذخیره/بازیابی واقعی فایل نیست.
- پذیرش Release نیازمند Round-trip واقعی از طریق Android document/file provider و بررسی حفظ Task، Checklist، Repeat، Follow-up، Project، Category، Tag و Date/Time است.
- تا زمان وجود Evidence واقعی، وضعیت این دروازه BLOCKED می‌ماند؛ این محدودیت نباید با سبز بودن Emulator یا Build پنهان شود.

### Visual and release evidence
- برای Home و هر UI مهم، Screenshot باید از مسیر واقعی برنامه در viewport هدف تولید و با Visual Reference بررسی شود؛ آزمون Widget یا Build جای Visual Review را نمی‌گیرد.
- Screenshot فقط برای سناریویی ادعا شود که واقعاً UI را اجرا کرده است؛ تست صرفاً داده‌ای نباید به‌عنوان مدرک تصویری معرفی شود.
- پیش از RC، Unused Code، Dead Feature، Duplicate Logic، راه‌حل موقت، Debug Element و UI ناقص بررسی شوند؛ پاک‌سازی نباید داده یا رفتار معتبر کاربر را حذف کند.

### User report and final acceptance
- گزارش مالک محصول ۳ تا ۵ خط و غیر فنی باشد: وضعیت، انجام‌شده، اثر برای کاربر، مانع و قدم بعد. گزارش اجرایی GitHub باید جداگانه شامل تغییر، فایل، تست، Evidence، خطا، تصمیم و موارد باقی‌مانده باشد.
- پرسش نهایی ثابت است: آیا کاربر واقعی می‌تواند فردا صبح بدون آموزش خاص کارهای روزانه، تعهدها، پیگیری‌ها و برنامه‌ها را مدیریت کند؟ اگر Evidence ناقص است، RC اعلام نشود؛ اگر تجربه یا داده هنوز ناقص است، کار ادامه یابد.



## Owner-Reported Requirements & Post-Install Feedback Index — 2026-10-09

**Purpose:** This index preserves the owner's reported installed-app defects and product requirements across conversations, accounts, and execution agents. It is a traceability index, not proof that any item is fixed. Always re-check live Issue/PR state and exact-head evidence before changing status.

### A. Reported after installing/using the app

| Owner observation / expected behavior | Permanent record | Current known lane (re-check live state) |
|---|---|---|
| Calendar task actions disappeared: edit, delete, and register/export to phone calendar must remain available where applicable; recurring scheduled days must be represented correctly in the installed APK. | [Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | [PR #2533](https://github.com/mobinpda-lab/Arvin-clean/pull/2533) is open as of this index; exact-head tests, APK, Android Calendar Provider acceptance, Device Smoke, and required real-device acceptance remain mandatory. |
| Settings → Projects: creating/editing a project must persist after save and reopening. | [Umbrella Issue #2151](https://github.com/mobinpda-lab/Arvin-clean/issues/2151) | [PR #2540](https://github.com/mobinpda-lab/Arvin-clean/pull/2540) is merged. This does not close the broader post-install acceptance issue or prove all gates passed; verify current-main evidence and user flow. |
| Home overdue-warning × must dismiss the warning only; it must not clear the task date or make the task disappear. | [Issue #2543](https://github.com/mobinpda-lab/Arvin-clean/issues/2543) | [PR #2544](https://github.com/mobinpda-lab/Arvin-clean/pull/2544) is merged. Re-check current-main tests and installed-product behavior before marking accepted. |
| Importing an event from the phone calendar must be idempotent; a second import must show a clear Persian duplicate message; imported events must not be automatically exported back to the phone calendar. | [Issue #2543](https://github.com/mobinpda-lab/Arvin-clean/issues/2543), [Calendar integration umbrella #516](https://github.com/mobinpda-lab/Arvin-clean/issues/516) | [PR #2544](https://github.com/mobinpda-lab/Arvin-clean/pull/2544) is merged; exact-head/real provider evidence still governs acceptance. |
| Colors across Arvin should be stronger and clearer; Persian typography should be more readable without silently overriding the user's font preferences. | [Issue #2546](https://github.com/mobinpda-lab/Arvin-clean/issues/2546) | [PR #2547](https://github.com/mobinpda-lab/Arvin-clean/pull/2547) is open as of this index. Requires exact-head Analyze/Test/Build/UI smoke and screenshot-based visual review. |

### B. Product requirements the owner explicitly set

1. **Product-first and continuity:** GitHub is the durable source of truth; start every “ادامه آروین” with a no-code Reality Snapshot; use DONE / IN PROGRESS / BLOCKED / FAILED / NOT STARTED / UNKNOWN with evidence; continue from live GitHub rather than chat memory. See this protocol, [live remaining-work ledger #2299](https://github.com/mobinpda-lab/Arvin-clean/issues/2299), [execution loop #2224](https://github.com/mobinpda-lab/Arvin-clean/issues/2224), and [AI continuity package #2310](https://github.com/mobinpda-lab/Arvin-clean/issues/2310).
2. **No duplicate work:** Search open/closed Issues and PRs, branches, commits, code, tests, documentation, decisions, workflows, automation, CI and evidence before creating anything. Prefer UPDATE EXISTING → COMPLETE EXISTING → VALIDATE EXISTING → REPAIR EXISTING → CREATE NEW only with a recorded reason.
3. **Home and filters:** Home is the daily decision center, not a report. Time/Project/Category/Tag are real, visible filters with dedicated Arvin bottom sheets and combined AND behavior; groups cover past/today/tomorrow/future/no-time with count and expand/collapse. See [post-install umbrella #2151](https://github.com/mobinpda-lab/Arvin-clean/issues/2151), [Home contract #2319](https://github.com/mobinpda-lab/Arvin-clean/pull/2319), and [visual QA lane #2320](https://github.com/mobinpda-lab/Arvin-clean/pull/2320).
4. **Report Center:** Keep reporting separate from Home. Combined filters cover time/date range, project, category, tag, status, priority, repeat, follow-up and checklist; reuse existing Share/Print/Export paths and do not create a parallel report engine. See [Report Center #2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385).
5. **One Task engine:** Checklist, repeat, tracking, follow-up, project/category/tag and task scenarios remain part of the canonical Task architecture; do not create separate loan/debt/habit/payment/contract/customer systems or parallel stores/models. See [Checklist contract #2230](https://github.com/mobinpda-lab/Arvin-clean/issues/2230), [Repeat architecture #2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254), and Follow-up remains a canonical Task capability and must reuse existing product contracts and implementation.
6. **Repeat and tracking:** One canonical parent Task; independent occurrence execution/history; immutable past and adjustable future; Checklist definition belongs to Task while execution state belongs to each occurrence. NORMAL remains simple; TRACKING reveals richer progress/history only when requested. Architecture authority remains [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254).
7. **Persian UX and visual consistency:** Persian RTL, modern/calm/professional UI, readable text, meaningful semantic color, consistent cards/spacing/radius/shadows/icons, progressive disclosure, reversible actions and clear feedback. Preserve the approved visual authority and existing settings; related records include [app-wide visual identity #2156](https://github.com/mobinpda-lab/Arvin-clean/issues/2156), [visual system #2275](https://github.com/mobinpda-lab/Arvin-clean/issues/2275), and [typography #1860](https://github.com/mobinpda-lab/Arvin-clean/issues/1860).
8. **User-data guard:** No Task/history/checklist/repeat/follow-up/project/category/tag/date-time data loss. Before model/storage changes, assess old-data readability, migration, rollback and Backup/Restore compatibility. Real file-provider Backup → Restore round-trip is required; fake/in-memory tests are not real-file evidence. See [release evidence gate #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) and [Backup/Restore flow #2430](https://github.com/mobinpda-lab/Arvin-clean/pull/2430).
9. **Validation / Release:** Code presence, tests alone, green CI alone, merged PR alone, or Build success alone do not mean DONE. Require relevant feature/flow tests, exact-head Analyze/Test/Build, Android smoke, actual screenshots and visual review for UI, data compatibility and Backup/Restore round-trip, and Golden Flow evidence. Do not install incomplete builds on the owner's phone; reserve it for final verification/acceptance after RC gates.
10. **Execution and reporting:** Run independent Core / UX / Tests / Build-Release / Documentation lanes in safe parallel. Isolate environment/device blockers while continuing independent work. Keep user-facing status concise and product-focused; keep detailed technical evidence separately in GitHub.

### C. Durable recordkeeping rules

- This index is subordinate to and linked from `ARVIN_AI_CONTEXT.md`; the full governing contract remains this file.
- Every owner-reported defect must link to an existing Issue. Update that Issue and its existing PR instead of opening duplicates.
- After a code change, record Changed / Evidence / Remaining / Next Step in the existing issue/PR or live ledger.
- Re-check the live status before reporting: the statuses in section A are only a dated snapshot.
- A closed/merged PR is not automatically accepted; the exact current-main evidence and the owner's reported behavior determine acceptance.
