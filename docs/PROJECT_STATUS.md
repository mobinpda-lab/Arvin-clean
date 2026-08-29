# Arvin — Project Status

## وضعیت زنده — 2026-08-29

GitHub تنها Source of Truth عملیاتی پروژه است. هر SHA، PR، CI، درصد یا وضعیت باید پیش از اقدام دوباره از GitHub تازه بررسی شود.

Baseline این بازنگری:
- `main`: `bf3e7eb57aeb11df5283014ae8ef5401ec100815`
- آخرین Merge مشاهده‌شده: PR #521 — Production Orchestrator هر 5 دقیقه
- PR #519 merged: Phase 1 قرارداد تنظیمات Device Calendar Integration روی Foundation موجود Settings
- اصل اجرایی مادر: **Maximum Parallel؛ سریع، خودکار، مستند، بدون توقف Production؛ Merge سریالی و current-main-safe**
- Production Orchestrator: `Draft → Fast → Promote → Build + Device → serial merge` با cadence پنج‌دقیقه‌ای و triggerهای CI

این فایل snapshot است؛ GitHub زنده همیشه مقدم است.

## Foundation canonical

مسیر اصلی محصول:

`Task / Unified Item → Due Date / Reminder → FollowUps[] / FollowUp Reminder → Recurrence / History`

Home، Search، Today، Calendar، Work Agenda، Timeline، Reminder، FollowUp، Backup، Settings، Widget، Reports و Projects باید همین Foundationها را مصرف کنند.

قواعد حفاظت‌شده:
- Foundation دوم برای Task/FollowUp/Reminder/Calendar/Work Agenda/Settings/Backup/Scheduler/Alarm ساخته نمی‌شود مگر Requirement مستقل اثبات‌شده.
- Project مستقل از Category/Tags است؛ color متعلق به Project است و `Task.projectId` ساخته نمی‌شود.
- Work Agenda یک Projection واحد باقی می‌ماند.
- Reports یک `TaskReportProjection` canonical دارند؛ PDF/Text فقط rendererهای متفاوت همان داده‌اند.
- Vazirmatn UI FD فونت canonical گزارش PDF است؛ Font Controller/Store موازی ساخته نمی‌شود.

## تحویل‌های مهم اخیر

### Projects
ProjectPlan، lifecycle، selector، management page، ProjectStore، Task↔Project assignment، editor context، backup portability و ProjectBackupBridge روی مسیر canonical وجود دارند. Wiringهای بعدی باید همین اجزا را reuse کنند.

### Work Agenda
Projection، Report Adapter، PDF renderer و صفحه day/range موجودند. یک Task در یک روز به‌خاطر چند دلیل زمانی duplicate نمی‌شود. External Calendar integration باید همین Projection را extend کند.

### Reports و Typography
TaskReportProjection منبع canonical گزارش است. Copy Text و renderer متنی موجودند؛ native Share lane در PR #522 روی current main بازسازی شده است. PDF از bundled Vazirmatn UI FD استفاده می‌کند و regression واقعی بارگذاری فونت روی main موجود است.

### Bidirectional Device Calendar Integration
Target رسمی در Issue #516 تثبیت شده است:

`Arvin ↔ Android Calendar Provider ↔ Google / Samsung / Other compatible calendars`

PR #519 Phase 1 قرارداد تنظیمات را merge کرده است. Device calendar ids محلی می‌مانند و وارد portable Settings backup نمی‌شوند. Settings رسمی فقط از مسیر `تنظیمات → تقویم و همگام‌سازی` خواهد بود.

Existing sync foundations مانند CalendarSyncRevisionService / CalendarSyncPlanService و Issue #348 باید reuse شوند؛ Google/Samsung engine جدا ساخته نمی‌شود مگر Requirement بعدی آن را توجیه کند.

## Laneهای فعال این snapshot

1. **PR #522 — native report text share**: rebuild مستقیم از current main، Draft + `arvin-auto`; Fast exact-head در حال اجرا/انتظار است و CI قدیمی #518 استفاده نمی‌شود.
2. **Documentation reconciliation v2**: بازسازی مستقل مستندات روی current main بعد از Mergeهای #519/#521؛ بدون دخالت در product lane.
3. **Calendar next phase**: بعد از تثبیت Settings contract، Settings UI و سپس read-only Android Calendar Provider discovery/read/permission روی existing #348.

## Production safety

1. Fresh audit قبل از write/merge.
2. Laneهای مستقل هم‌زمان؛ Block یک Lane بقیه را متوقف نمی‌کند.
3. Draft فقط با Fast exact-head معتبر است.
4. Ready فقط با Build/APK + Device exact-head/current-main-safe قابل Merge است.
5. Mergeها سریالی؛ بعد از هر Merge main و sibling laneها دوباره بررسی می‌شوند.
6. CI قدیمی پس از تغییر main/head evidence نیست.
7. No Force Push / Force Merge / Force Update.
8. Workflow/Build/Device سالم Cancel یا Restart غیرضروری نمی‌شود.
9. Documentation/typography/tests موازی‌اند و Production را block نمی‌کنند.

## Requirementهای حفظ‌شده

- Projects ≠ Category/Tags.
- Work Agenda یک Foundation واحد است.
- Reports یک canonical projection دارند.
- Vazirmatn UI FD canonical report typography است.
- Bidirectional Device Calendar Integration Target رسمی است.
- Google/Samsung از Android Calendar Provider adapter واحد استفاده می‌کنند.
- External Calendar Events به‌صورت پیش‌فرض Task/Report/Backup نیستند.
- Calendar permissions فقط هنگام نیاز درخواست می‌شوند و CI با داده synthetic است.
- Maximum Parallel توسعه را موازی می‌کند، نه Merge را.

## Score

درصد تاریخی این فایل معیار تصمیم عملیاتی نیست. Score رسمی فقط از scorecard canonical و evidence واقعی به‌روز می‌شود. Foundation یا تعداد PR به‌تنهایی امتیاز DoD ایجاد نمی‌کند؛ physical-device/E2E و closureهای لازم باید کسب شوند.

## Trigger ادامه

`ادامه آروین` یعنی:

`Fresh GitHub audit → reconcile docs → parallel independent work → exact-head validation → safe serial merge → post-merge validation → next smallest real gap → document → short nontechnical owner report`
