# Bidirectional Device Calendar Integration

## وضعیت و جایگاه سند

- پروژه: Arvin / آروین
- نوع: تصمیم رسمی محصول + معماری + دستور اجرایی
- مالک Target: Issue #516
- اجرای مرجع: Maximum Parallel؛ سریع، خودکار، مستند، غیرمسدودکننده و بدون توقف Production
- Source of Truth عملیاتی: GitHub زنده؛ هر SHA/PR/CI قبل از اقدام باید دوباره بررسی شود.

> این سند Foundation جدیدی ایجاد نمی‌کند. هدف آن تثبیت تصمیم محصول و جلوگیری از دوباره‌کاری است. در صورت اختلاف با وضعیت عملیاتی، GitHub زنده و جدیدترین تصمیم صریح مالک مقدم است.

## تصمیم رسمی محصول

آروین باید بتواند Calendarهای موجود Android، از جمله Google Calendar، Samsung Calendar و سایر Providerهای سازگار را از مسیر استاندارد Android Calendar Provider بخواند و Eventهای مجاز آنها را در Calendar و Work Agenda خودش نمایش دهد. همچنین باید بتواند داده‌های زمان‌دار انتخاب‌شده آروین را به Calendar انتخابی دستگاه منتقل و به‌صورت پایدار و Idempotent همگام کند.

معماری هدف:

`Arvin ↔ Android Device Calendar ↔ Google Calendar / Samsung Calendar / Other Android Calendar Providers`

همه تنظیمات این قابلیت فقط از مسیر زیر در دسترس خواهند بود:

`آروین → تنظیمات → تقویم و همگام‌سازی`

## Reconcile با وضعیت واقعی پروژه

در baseline ثبت این سند، Foundationهای زیر روی `main` وجود دارند و باید Reuse شوند:

- canonical `Task / Due Date / Reminder / FollowUp / FollowUp Reminder / Recurrence`
- Calendar و Work Agenda موجود
- `AppSettingsService` و `SettingsPage`
- `SystemCalendarBridge` و MethodChannel موجود Android
- `CalendarSyncRevisionService` و `CalendarSyncPlanService`
- provider-neutral `ExternalCalendarEventLink`
- Backup / Report / Notification / Alarm foundations
- Production Orchestrator و exact-head CI gates

PR #381 قبلاً بخش مهم Phase 0 را تحویل داده است: fingerprint پایدار و برنامه deterministic برای create/update/no-op/delete. `SystemCalendarBridge` فعلی فقط export تعاملی FollowUp از طریق `ACTION_INSERT` را انجام می‌دهد و جای Android Calendar Provider sync واقعی را نمی‌گیرد. Issue #348 Lane موجود Provider integration است و باید ادامه داده شود، نه اینکه Engine دوم ساخته شود.

## اصل معماری و حفاظت Foundationها

آروین Source of Truth داده‌های داخلی خود باقی می‌ماند. Calendar Integration یک Adapter روی Foundationهای موجود است.

بدون Requirement اثبات‌شده ساخت موارد زیر ممنوع است:

- Task Model یا Task Repository دوم
- Calendar Architecture موازی
- Reminder/Scheduler/Alarm Engine دوم
- Persistence موازی
- Work Agenda دوم
- Settings Store یا Settings Architecture دوم
- Integration Engine جدا برای Google یا Samsung

اصل اجرا: `Reuse Before Add` و `Extend Before Replace`.

## جهت Arvin → Device Calendar

موارد قابل انتخاب برای Sync:

- Task دارای Due Date
- Task Reminder
- FollowUp
- FollowUp Reminder
- Recurrence occurrence، وقتی پشتیبانی نهایی آن تثبیت شد

اطلاعات قابل Projection شامل title، description، start/end، all-day، reminder در صورت پشتیبانی و شناسه Mapping داخلی است.

کاربر تعیین می‌کند Sync فعال باشد یا نه، Calendar مقصد کدام باشد و کدام نوع eventها Sync شوند.

## جهت Device Calendar → Arvin

Calendarهای مجاز دستگاه باید قابل کشف و خواندن باشند. Event خارجی در فاز نمایش **Task آروین نیست** و به‌صورت خودکار به Task تبدیل نمی‌شود.

Projection provider-neutral خارجی حداقل در صورت موجود بودن داده این فیلدها را حمل می‌کند:

- `externalEventId`
- `calendarId`, `calendarName`
- `accountName` فقط در صورت دسترسی مجاز
- `provider/source`
- `title`, `description`
- `start`, `end`, `allDay`
- recurrence metadata
- version / lastModified

در UI منبع رویداد باید ساده و روشن قابل تشخیص باشد: آروین، Google، Samsung یا تقویم دستگاه.

## Work Agenda و Calendar داخلی

Work Agenda موجود Foundation اصلی باقی می‌ماند:

`Work Agenda = canonical Arvin work events + External Calendar Events`

External Eventها باید به Projection موجود افزوده شوند؛ Work Agenda دوم ساخته نمی‌شود. مالکیت Source هر ردیف باید حفظ شود.

Calendar داخلی آروین حذف نمی‌شود و می‌تواند Aggregator چند Source باشد، بدون مخلوط‌کردن مالکیت داده.

## مالکیت داده

سه وضعیت رسمی داریم:

1. **Arvin-owned** — Source of Truth آروین است. ویرایش آروین همان Event متصل را update می‌کند.
2. **External-owned** — Source of Truth Calendar Provider است. فاز اول read-only projection است.
3. **Imported-to-Arvin** — فقط با اقدام صریح «تبدیل به کار آروین» یک Task canonical ساخته می‌شود.

ویرایش یا حذف External-owned بدون اقدام روشن کاربر ممنوع است.

## Idempotency و Mapping

Sync/Refresh مجدد نباید Duplicate بسازد. Mapping پایدار باید مفهوم زیر را پوشش دهد:

`ArvinEntityId ↔ ExternalCalendarEventId`

Metadata لازم می‌تواند شامل `taskId/entityId`, `eventKind`, `calendarId`, `externalEventId`, `lastSyncedFingerprint`, `lastSyncedAt` باشد.

قبل از insert، Mapping بررسی می‌شود. اگر Event قبلاً وجود دارد، update همان Event انجام می‌شود.

## Conflict و حذف

اگر تنها یک سمت از آخرین Sync تغییر کرده باشد، همان تغییر قابل اعمال است. اگر هر دو سمت تغییر کرده باشند، Conflict ثبت می‌شود و کاربر می‌تواند نسخه آروین، نسخه Calendar یا تصمیم‌گیری بعدی را انتخاب کند.

Conflict نباید موجب crash، data loss، duplicate یا حذف ناخواسته شود.

حذف Task در آروین به‌صورت پیش‌فرض Event خارجی متصل را حذف نمی‌کند. گزینه «حذف Event متصل همراه Task» در Settings وجود خواهد داشت و Default آن خاموش است.

## Google و Samsung

Foundation اولیه و canonical برای هر دو: **Android Calendar Provider**.

- Google OAuth / Google Calendar API مستقیم در Phase اول وارد معماری نمی‌شود.
- Samsung API اختصاصی نیز بدون Requirement اثبات‌شده اضافه نمی‌شود.
- Calendarهای Google/Samsung که سیستم Android expose می‌کند از همان Adapter واحد استفاده می‌شوند.

این تصمیم complexity، token management و vendor lock-in را کاهش می‌دهد و از معماری موازی جلوگیری می‌کند.

## Settings contract

تنها مسیر رسمی:

`Settings اصلی → تقویم و همگام‌سازی`

کنترل‌های هدف:

- اتصال کلی به تقویم دستگاه
- نمایش رویدادهای تقویم گوشی
- انتخاب Calendarهای قابل نمایش
- ارسال کارهای آروین به تقویم
- Calendar مقصد
- انتخاب event kindهای قابل Sync: due/reminder/follow-up/follow-up-reminder/recurrence
- auto sync
- delete linked event with Task، پیش‌فرض خاموش
- Sync now
- وضعیت Permission
- آخرین وضعیت Sync

Calendar و Work Agenda فقط می‌توانند Shortcut به همین Settings داشته باشند و Settings موازی نمی‌سازند.

Read permission فقط هنگام نیاز به مشاهده و Write permission فقط هنگام فعال‌کردن write/update درخواست می‌شود. Deny نباید عملکرد عادی آروین را مختل کند.

## Reports، Backup، Offline و Privacy

External Calendar Eventها به‌صورت پیش‌فرض وارد Task Report، PDF، Export، Share Task یا Backup Task نمی‌شوند. برای ورود آنها به Reports Requirement جداگانه لازم است.

آروین Backup کامل Calendar خارجی نمی‌سازد. فقط Mapping ضروری و versioned، در صورت تصویب persistence contract، می‌تواند نگهداری شود.

عدم اینترنت نباید Task، Work Agenda یا Mapping داخلی را خراب کند و نباید Duplicate ایجاد کند. Cloud sync حساب Google/Samsung مسئولیت Provider/سیستم است.

Calendar داده شخصی است:

- بدون Permission خوانده نشود.
- بدون درخواست کاربر نوشته نشود.
- داده خارجی به سرویس ثالث ارسال نشود.
- متن Event واقعی در CI/debug log ثبت نشود.
- تست‌ها synthetic باشند.

## مراحل اجرایی

- **Phase 0 — Architecture / Contract:** بخش مهم از طریق #381 موجود؛ فقط gap واقعی تکمیل شود.
- **Phase 1 — Calendar Settings Contract:** reuse Settings موجود.
- **Phase 2 — Calendar Settings UI:** فقط در Settings اصلی.
- **Phase 3 — Read-only Android Calendar Provider Adapter:** discovery/read/permissions؛ ادامه #348.
- **Phase 4 — External Event Projection:** اتصال به Calendar/Work Agenda موجود.
- **Phase 5 — Arvin → Provider:** create/update + Mapping پایدار.
- **Phase 6 — Delete policy.**
- **Phase 7 — Conflict detection/resolution.**
- **Phase 8 — Explicit Import to canonical Task.**
- **Phase 9 — Real-device E2E:** Google-backed و Samsung-backed Calendar در صورت دسترسی به evidence واقعی.

## Maximum Parallel / Production rules

- هر Lane از current `main` مناسب ساخته می‌شود.
- PR/Branch/Path/Workflow فعال قبل از write بررسی می‌شود.
- Feature در PR بزرگ ساخته نمی‌شود؛ Laneهای کوچک و مستقل.
- CI قدیمی evidence برای Head جدید نیست.
- Fast + Build + Device exact-head و current-main-safe لازم است.
- Mergeها سریالی‌اند.
- هیچ PR، Workflow، Build، Device Smoke یا Production Orchestrator سالم برای این Feature Cancel/Restart/Force-update نمی‌شود.
- اگر main جلو رفت، Lane باقی‌مانده clean rebuild/revalidation می‌شود.
- اگر conflict وجود داشت فقط همان بخش منتظر نقطه امن می‌ماند؛ سایر Laneها ادامه می‌دهند.
- Lane نزدیک‌تر به Production اولویت Merge دارد.

## Definition of Done

Target فقط زمانی کامل است که discovery Calendarها، permission-safe read/write، Settings اصلی، external projection، Google/Samsung real-device evidence، idempotent create/update/no-duplicate، delete policy، conflict handling، offline safety، stable mapping و regressionهای Task/FollowUp/Reminder/Work Agenda/Settings به‌همراه Fast/Build/APK/Device evidence معتبر همگرا باشند.

## پیوندهای اجرایی

- Umbrella: Issue #516
- Android Calendar Provider lane: Issue #348
- Existing idempotent contract: merged PR #381
- Historical product track: Issue #5
- Maximum Parallel execution board: Issue #403
