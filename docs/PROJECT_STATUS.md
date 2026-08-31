# Arvin — Project Status

## وضعیت زنده — 2026-08-31

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل checkpoint زنده است و قبل از هر تصمیم باید با `main`، PRها، Issueها و exact-head CI دوباره تطبیق داده شود.

- Branch مرجع: `main`
- snapshot فعلی تأییدشده: `a9078ee58263b7d8fa8cf862305467992e178575`
- آخرین Merge تأییدشده: PR #601 — `ci(agent): harden Worker reliability on latest main`
- Merge قبلی مهم: PR #598 — Android Calendar Provider discovery
- Calendar Settings UI: PR #592 روی main
- Backup restore confirmation: PR #582 روی main
- AI Worker timeout/budget hardening: PR #579 روی main
- Calendar date-jump: PR #575 روی main
- AI Code Worker GitHub-native fallback: PR #574 روی main
- Production feedback loop: PR #573 روی main

## Release Blockers

در audit این checkpoint هیچ Issue باز با label دقیق `release-blocker` پیدا نشد. این به معنی RC-ready بودن خودکار نیست؛ laneهای باز باید همچنان current-main ancestry، exact-head Fast و در صورت promotion، Build/APK/Device معتبر داشته باشند.

## Core / Data

- foundation اصلی Task / Reminder / FollowUp / History / Settings / Calendar / Backup باید reuse شود؛ store/model/repository موازی ممنوع است.
- merge #601 هیچ product model/store/calendar data path جدیدی معرفی نکرد؛ scope آن workflow/test/docs مربوط به AI Worker بود.
- merge #598 نیز Core/Data store جدیدی نساخت و فقط boundary اندروید و bridge provider-neutral تقویم را توسعه داد.
- تغییر data-safety بدون migration/compatibility evidence مجاز به promotion نیست.

## Backup / Restore

### PR #582 ✅ merged

- معماری Backup/Restore، encryption و callbackهای موجود حفظ شده‌اند.
- پس از خواندن موفق backup و قبل از جایگزینی Taskهای فعلی، تأیید صریح کاربر لازم است.
- Cancel نباید mutation ایجاد کند.
- failure behavior فایل invalid/encrypted حفظ شده است.

هیچ تغییر جدید تأییدشده‌ای در Backup بعد از #582 در این checkpoint دیده نشد.

## Calendar

### PR #592 — Device Calendar Settings UI ✅ merged

- entry رسمی `تقویم و همگام‌سازی` در Settings canonical روی `main` است.
- `CalendarIntegrationSettings` و `AppSettingsService` موجود reuse شده‌اند.
- حذف linked external event به‌صورت پیش‌فرض OFF باقی مانده است.

### PR #598 — Android Calendar Provider discovery ✅ merged

- READ_CALENDAR، permission status/request و Android `CalendarContract` provider enumeration روی `main` است.
- typed provider metadata برای calendar/accountهای نصب‌شده در bridge موجود اضافه شده است.
- WRITE_CALENDAR و event read/write/delete sync در این slice اضافه نشده است.
- provider discovery foundation برای Google/Samsung/سایر تقویم‌های Android provider-neutral است؛ vendor SDK جدا ساخته نشده است.

### PR #602 — Settings provider selection — Draft / exact-head Fast ✅

Head: `1b28ab5fa2e6efa4da56c584fac7fa1445a67f1e`

- PR باز، Draft و mergeable است.
- Fast/Parallel run `33396542638` روی همین exact head با conclusion `success` کامل شده است؛ quality/analyze/test و calendar/typography/backup/followup/guide/release surfaces سبز هستند.
- این slice فهرست واقعی providerها را فقط بعد از اقدام صریح کاربر می‌گیرد، Google/Samsung/other calendars را از همان `SystemCalendarBridge` نشان می‌دهد و target/visible IDs را در `CalendarIntegrationSettings` موجود ذخیره می‌کند.
- permission/page load بدون selection نباید settings write ایجاد کند.
- هیچ WRITE_CALENDAR، event read/write/delete، recurrence sync یا background sync اضافه نشده است.
- base ثبت‌شده PR هنوز `a4c2a3ec...` است و بعد از merge #601، `main` به `a9078ee5...` جلو رفته؛ بنابراین Heavy/Device و promotion باید فقط پس از replay/reconcile روی current main انجام شود. Fast فعلی evidence معتبر exact-head تاریخی است، نه مجوز promotion روی main جدید.
- branch `feat/calendar-provider-selection-settings-v2` از current `main` ساخته شده و در این checkpoint هنوز دقیقاً روی `a9078ee5...` است؛ یعنی replay کد #602 روی آن هنوز commit نشده و نباید به‌عنوان implementation آماده تلقی شود.

Issue مالک: #597 باز است. Issue #595 پس از merge provider discovery بسته شده است. #348/#516 همچنان scope بزرگ‌تر integration/sync را نگه می‌دارند.

### PR #599 — provider-discovery duplicate Draft

PR #599 هنوز باز و Draft است، ولی scope آن توسط merge #598 روی `main` پوشش داده شده است. مگر اینکه live diff gap جدید و غیرتکراری ثابت کند، نباید Heavy/Device یا merge budget مصرف کند.

## Automation / Production Orchestrator

Production Orchestrator همچنان authority اصلی promotion/merge است. Worker و Production Loop مجاز به bypass کردن Fast/Build/Device یا merge مستقیم نیستند.

### PR #601 — AI Worker launch + patch reliability ✅ merged

Merge SHA / current `main`: `a9078ee58263b7d8fa8cf862305467992e178575`

- AI Worker برای launch عادی `workflow_dispatch`-only شده و Orchestrator authority اصلی dispatch است.
- Production Loop explicit dispatch برای Auto-Fixهای ساخته‌شده با `GITHUB_TOKEN` را حفظ می‌کند.
- concurrency بر پایه issue input نگه داشته شده است.
- `git apply --recount` فقط بعد از structural validation استفاده می‌شود؛ missing headers / context-invalid patch همچنان fail-closed است.
- exact-head Fast/Parallel روی head `f2090840...` سبز بود.
- Heavy Build run `33395334403`: quality + Debug APK + Release APK همگی success.
- Device run `33395336405`: Home smoke + People smoke هر دو success.
- PR #601 در 2026-08-31 merge شد؛ Issueهای #588 و #590 نیز completed/closed شده‌اند.
- PR #600 اکنون historical/superseded است و نباید دوباره Heavy یا promotion بگیرد.

آخرین Production Loop تأییدشده روی current main که در این checkpoint دیده شد: run `33396874925`، conclusion `success` روی `a9078ee5...`.

## CI / Build

- current main #601 با exact-head Fast و Heavy Build/APK + Device سبز وارد main شد.
- #602 exact-head Fast سبز دارد، ولی چون main بعد از base آن حرکت کرده است، Heavy قبل از current-main replay معتبر نیست.
- Build/Device skipped روی Draft به‌تنهایی success/failure محصول محسوب نمی‌شود؛ gate اصلی برای Draft همان Fast/Parallel است.
- skipped/cancelled protective runs evidence محصول نیستند؛ فقط runهای exact-head و ancestry معتبر ملاک‌اند.
- documentation lane جدا و Draft باقی می‌ماند تا validation فعال Product/Automation را stale نکند.

## Progress / Evidence Dashboard

Issue #578 همچنان مرجع Progress Score evidence-backed است و #583 slice renderer deterministic را تعریف می‌کند. هیچ درصد جدیدی در این checkpoint به‌صورت دستی ادعا نمی‌شود؛ score رسمی فقط باید از scorecard/tool canonical و evidence همان `main` استخراج شود.

## CI / Merge Contract

1. هر Lane از current `main` ساخته یا reconcile شود.
2. Draft فقط Fast/Parallel را می‌گیرد؛ Heavy Build/APK/Device باید بعد از Ready روی همان exact head انجام شود.
3. Merge فقط با current-main ancestry، exact-head evidence و mergeability زنده.
4. Mergeها serial هستند؛ انتظار یک Lane نباید Lane مستقل سالم را متوقف کند.
5. PR/branch stale باید rebuild/reconcile شود، نه force merge.
6. Documentation نباید validation سالم Product/Automation را stale کند؛ docs-only تغییرات در Lane جدا نگه داشته می‌شوند.
7. duplicate/superseded lane نباید Heavy یا merge موازی بگیرد.

## Open operational lanes

- #602 / #597 — Calendar provider selection: exact-head Fast سبز؛ نیازمند replay/reconcile روی `a9078ee5...` قبل از Heavy/Device/promotion.
- `feat/calendar-provider-selection-settings-v2` — current-main replay branch وجود دارد ولی در این checkpoint هنوز هیچ تغییر نسبت به main ندارد.
- #599 — provider-discovery duplicate Draft؛ باید supersede/close شود مگر gap جدید اثبات شود.
- #600 — Worker reliability historical Draft؛ superseded توسط merged #601 و نباید دوباره promote شود.
- #578/#583 — evidence-backed Progress Score dashboard: implementation/validation کامل نشده.
- #516/#348 — bidirectional Android device-calendar integration: provider discovery foundation روی main است؛ event projection/read/write/sync مراحل بعدی هستند.

## Definition of Done

قابلیت فقط وقتی Done است که implementation واقعی، مسیر canonical، تست، exact-head CI، Build/APK/Device لازم، merge امن و مستندات همگرا باشند. Conversation memory یا CI head قدیمی evidence برای head جدید نیست.