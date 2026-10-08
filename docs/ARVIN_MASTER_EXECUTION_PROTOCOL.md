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
