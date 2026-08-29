# Arvin — Project Status

## وضعیت زنده — 2026-08-29

GitHub تنها Source of Truth عملیاتی پروژه است. هر SHA، PR، CI، درصد یا وضعیت باید پیش از اقدام دوباره از GitHub تازه بررسی شود.

Baseline این بازنگری:

- `main`: `08671b350bdaafd8f1633615615024fd2ed91b8c`
- آخرین Merge تولیدی مشاهده‌شده: PR #514 — تثبیت canonical Vazirmatn برای PDF و بارگذاری deterministic فونت‌های bundled
- Production Orchestrator فعال و حاکم بر مسیر `Draft → Fast → Promote → Build + Device → serial merge`
- اصل اجرایی مادر: **Maximum Parallel؛ سریع، خودکار، مستند، بدون توقف Production و با Merge سریالی و current-main-safe**

این snapshot فقط نقطه ثبت مستندات است؛ GitHub زنده همیشه مقدم است.

## Foundation canonical فعلی

مسیر اصلی محصول همچنان یکپارچه است:

`Task / Unified Item → Due Date / Reminder → FollowUps[] / FollowUp Reminder → Recurrence / History`

Home، Search، Today، Calendar، Work Agenda، Timeline، Reminder، FollowUp، Backup، Settings، Widget، Reports و Project integration باید همین Foundationها را مصرف کنند.

قواعد حفاظت‌شده:

- Foundation دوم برای Task، FollowUp، Reminder، Calendar، Work Agenda، Settings، Backup، Scheduler یا Alarm ساخته نمی‌شود مگر Requirement جدید و مستقل آن را اثبات کند.
- `Project` از Category/Tags مستقل است و عضویت Task از طریق canonical Project membership مدیریت می‌شود؛ `Task.projectId` ساخته نمی‌شود.
- ProjectStore و Project backup bridge از مسیر موجود Backup استفاده می‌کنند.
- Work Agenda همان Projection موجود است و report/PDF آن از مسیر canonical TaskReport استفاده می‌کند.
- Vazirmatn UI FD فونت bundled و canonical گزارش PDF است؛ Font Controller/Store موازی ساخته نمی‌شود.

## تحویل‌های مهم اخیر

### Work Agenda

مسیر موجود شامل Projection، Report Adapter، PDF renderer و صفحه day/range است. یک Task در یک روز برای چند دلیل زمانی duplicate نمی‌شود و reasonهای canonical در همان entry جمع می‌شوند. External Calendar integration باید همین مسیر را extend کند، نه Work Agenda دوم بسازد.

### Projects

Foundationهای ProjectPlan، lifecycle، selector، management page، ProjectStore، Task↔Project assignment، editor context، backup portability و ProjectBackupBridge در مسیر canonical موجودند. هر wiring باقی‌مانده باید روی همین components انجام شود.

### Reports و Typography

`TaskReportProjection` منبع canonical گزارش است. PDF/Print و renderer متنی باید همین داده را مصرف کنند. PR #514 روی main ثابت کرد bundled Vazirmatn assets قابل بارگذاری‌اند و default PDF renderer گزارش فارسی واقعی می‌سازد.

Lane نزدیک Production برای native text sharing در زمان این snapshot PR #518 است. اولین Fast آن به‌دلیل regression ساده label سه تست UI را شکست؛ اصلاح minimal روی همان branch انجام شد و باید روی Head جدید exact-head Fast بگیرد. CI قدیمی evidence Head جدید نیست.

## Bidirectional Device Calendar Integration

Target رسمی جدید در Issue #516 ثبت شده و سند canonical آن:

`docs/BIDIRECTIONAL_DEVICE_CALENDAR_INTEGRATION_2026-08-29.md`

معماری هدف:

`Arvin ↔ Android Device Calendar ↔ Google Calendar / Samsung Calendar / Other Providers`

Foundation موجود باید Reuse شود:

- `SystemCalendarBridge`
- Android MethodChannel موجود
- merged PR #381: `CalendarSyncRevisionService`, `CalendarSyncPlanService`, `ExternalCalendarEventLink`
- Issue #348 به‌عنوان Lane Android Calendar Provider
- Settings و Work Agenda موجود

Google و Samsung Engine جدا ندارند. مسیر اولیه Android Calendar Provider است؛ OAuth/API اختصاصی فقط با Requirement اثبات‌شده آینده بررسی می‌شود.

تمام تنظیمات فقط در:

`آروین → تنظیمات → تقویم و همگام‌سازی`

قرار می‌گیرند. Calendar یا Work Agenda Settings دوم ایجاد نمی‌کنند.

External-owned events در فاز اولیه read-only projection هستند و خودکار به Task تبدیل نمی‌شوند. ورود به Task فقط با اقدام صریح کاربر مجاز است. External events به‌صورت پیش‌فرض وارد Task Report/PDF/Share/Backup نمی‌شوند.

در زمان این snapshot، PR #519 Phase 1 Settings Contract را روی current main پیاده کرده و Fast exact-head آن سبز شده است. این Lane باید پشت مسیر نزدیک‌تر به Production باقی بماند؛ اگر main با PR دیگری جلو برود، #519 باید دوباره روی main جدید اعتبارسنجی/بازسازی شود و CI قدیمی استفاده نشود.

## مسیرهای فعال در این snapshot

1. **PR #518 — Report native text share**: Draft + `arvin-auto`; اصلاح regression label روی Head جدید در حال ورود به Fast است. Build/Device تا Promote باید skipped بمانند.
2. **PR #519 — Calendar Settings Contract**: Draft؛ Fast exact-head روی `41c9bb75...` سبز است؛ `arvin-auto` اضافه شده، اما اولویت Merge بعد از Lane نزدیک‌تر به Production است.
3. **Documentation reconciliation**: همین بازنگری و سند Calendar به‌صورت Lane مستقل و بدون توقف محصول اجرا می‌شود.

## Production safety

قانون اجرایی ثابت:

1. Audit زنده `main`، PRها، Branchها و CI پیش از write/merge.
2. Laneهای مستقل هم‌زمان؛ Block یک Lane بقیه را متوقف نمی‌کند.
3. Draft فقط با Fast exact-head معتبر است.
4. Ready فقط با Build/APK + Device exact-head/current-main-safe قابل Merge است.
5. Mergeها سریالی‌اند و بعد از هر Merge، main و sibling laneها دوباره بررسی می‌شوند.
6. CI قدیمی پس از تغییر main/head معتبر نیست.
7. No Force Push / Force Merge / Force Update.
8. Workflow/Build/Device سالم Cancel یا Restart غیرضروری نمی‌شود.
9. Documentation و tests موازی‌اند و Production را block نمی‌کنند.

## مستندات و جلوگیری از گم‌شدن Requirement

تصمیم‌های این موج که باید در ادامه حفظ شوند:

- Projects ≠ Category/Tags و color متعلق به Project است.
- Work Agenda یک Foundation واحد باقی می‌ماند.
- Reports یک canonical projection دارند و PDF/Text فقط rendererهای متفاوت آن هستند.
- Vazirmatn UI FD canonical report typography است.
- Bidirectional Device Calendar Integration Target رسمی است و Settings آن فقط در Settings اصلی قرار می‌گیرد.
- Google/Samsung از Android Calendar Provider adapter واحد استفاده می‌کنند.
- External Calendar Events به‌صورت پیش‌فرض Task/Report/Backup نیستند.
- Calendar data privacy-sensitive است؛ permissions فقط هنگام نیاز و CI فقط با داده synthetic.
- Maximum Parallel توسعه را موازی می‌کند، نه Merge را.

## Score و درصد

درصدهای تاریخی این فایل معیار تصمیم عملیاتی نیستند. Score رسمی فقط از scorecard canonical و evidence واقعی به‌روز می‌شود. هیچ درصدی صرفاً به‌خاطر تعداد PRها یا وجود Foundation افزایش نمی‌یابد؛ physical-device/E2E و Definition of Done مربوطه باید کسب شود.

## گام‌های بعدی

ترتیب current-main-safe:

1. Fast جدید #518 را ارزیابی و در صورت سبزشدن اجازه مسیر Orchestrator برای Promote/Build/Device/serial merge بده.
2. بعد از هر Merge، #519 و Lane مستندات را روی main جدید revalidate/rebuild کن؛ stale CI استفاده نشود.
3. پس از production شدن Settings Contract، Phase 2 Calendar Settings UI فقط داخل Settings اصلی.
4. سپس Phase 3 از Issue #348: read-only Android Calendar Provider discovery/read/permission adapter.
5. در زمان انتظار CI، audit کل Product Contract Matrix و backlog برای کوچک‌ترین gap واقعی و rebuild laneهای ارزشمند روی current main ادامه یابد.

## Trigger ادامه

`ادامه آروین` یعنی:

`Fresh GitHub audit → reconcile docs → parallel independent work → exact-head validation → safe serial merge → post-merge validation → next smallest real gap → document → short nontechnical owner report`
