# Arvin — Project Status

## وضعیت زنده — 2026-08-31

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل checkpoint زنده است و قبل از هر تصمیم باید با `main`، PRها، Issueها و exact-head CI دوباره تطبیق داده شود.

- Branch مرجع: `main`
- snapshot فعلی تأییدشده: `2ee2adc22a45ab5fda1dcd548672ddaf77717afc`
- آخرین Merge تأییدشده: PR #605 — `feat(calendar): add bounded read-only device event query`
- Merge قبلی مهم: PR #601 — Worker reliability / launch authority
- Calendar Provider discovery: PR #598 روی main
- Calendar Settings UI: PR #592 روی main
- Backup restore confirmation: PR #582 روی main
- AI Worker timeout/budget hardening: PR #579 روی main

## Release Blockers

در audit این checkpoint هیچ Issue باز با label دقیق `release-blocker` پیدا نشد. این به معنی RC-ready بودن خودکار نیست؛ laneهای باز باید همچنان current-main ancestry، exact-head Fast و در صورت promotion، Build/APK/Device معتبر داشته باشند.

## Core / Data

- foundation اصلی Task / Reminder / FollowUp / History / Settings / Calendar / Backup باید reuse شود؛ store/model/repository موازی ممنوع است.
- merge #605 هیچ Task/FollowUp store یا product database جدیدی نساخت؛ فقط bridge موجود `arvin/system_calendar` و مدل provider-neutral خواندن رویداد خارجی را توسعه داد.
- read خارجی محدود و فقط‌خواندنی است: READ_CALENDAR موجود، حداکثر 20 تقویم و بازه حداکثر 93 روز؛ provider failure/permission denial نباید canonical Arvin data را mutate کند.
- merge #601 نیز product model/store را تغییر نداد و scope آن automation/test/docs بود.
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
- provider discovery foundation برای Google/Samsung/سایر تقویم‌های Android provider-neutral است؛ vendor SDK جدا ساخته نشده است.

### PR #605 — bounded read-only external event query ✅ merged

Merge SHA / current `main`: `2ee2adc22a45ab5fda1dcd548672ddaf77717afc`

- bridge موجود با `listDeviceCalendarEvents` توسعه یافته است.
- Android `CalendarContract.Instances` استفاده می‌شود تا recurrenceها در بازه درخواستی به‌صورت concrete instance خوانده شوند.
- scope فقط READ_CALENDAR است؛ WRITE_CALENDAR، create/update/delete، Task import، background sync و Work Agenda UI اضافه نشده‌اند.
- query در هر call به حداکثر 20 calendar و 93 روز محدود است و malformed/denied/unavailable path fail-closed برمی‌گردد.
- pre-merge exact-head `071abc3b...` Fast/Parallel run `33406072049` با conclusion `success` کامل شده بود؛ Build/Device روی آن Draft head `skipped` بودند.
- در زمان این checkpoint برای merge SHA جدید `2ee2adc2...` workflow run مستقیم مشاهده نشد؛ بنابراین current-main post-merge Build/Device سبز ادعا نمی‌شود.

### PR #604 / #607 — provider selection replay — exact-head validation کامل، ولی main جلو رفته

Shared exact head: `6cdd6cd49ecb038851cce76a2a37e9c499f139fb`

- #604 و #607 هر دو همان سه-file provider-selection implementation را حمل می‌کنند؛ #607 برای Fast رسمی روی API جدید Flutter ساخته شد.
- exact-head Fast/Parallel run `33406629330`: `success`.
- exact-head Heavy Build run `33406422054`: `success`؛ quality/test و Debug/Release APK کامل سبز شدند.
- exact-head Device Smoke run `33406422349`: `success`؛ Home و People هر دو سبز شدند.
- این evidence برای SHA `6cdd6cd4...` معتبر است، اما `main` بعداً با merge #605 به `2ee2adc2...` جلو رفته است؛ بنابراین #604/#607 بدون reconcile/replay روی current main مجوز promotion ندارند.
- #604 و #607 هم‌پوشان هستند و نباید هر دو Heavy/merge budget جداگانه مصرف کنند؛ یک canonical replay کافی است.

Issue مالک selection: #597 باز است. #348/#516 همچنان umbrella اجرای read/write/idempotent sync و external projection را نگه می‌دارند.

### PR #599 — provider-discovery duplicate Draft

PR #599 هنوز باز است، ولی scope آن توسط merge #598 روی `main` پوشش داده شده است. مگر اینکه live diff gap جدید و غیرتکراری ثابت کند، نباید Heavy/Device یا merge budget مصرف کند.

## Automation / Production Orchestrator

Production Orchestrator همچنان authority اصلی promotion/merge است. Worker و Production Loop مجاز به bypass کردن Fast/Build/Device یا merge مستقیم نیستند.

### PR #601 — AI Worker launch + patch reliability ✅ merged

- normal AI Worker launch `workflow_dispatch`-only است و Orchestrator authority اصلی dispatch است.
- Production Loop explicit dispatch برای Auto-Fixهای ساخته‌شده با `GITHUB_TOKEN` را حفظ می‌کند.
- concurrency بر پایه issue input نگه داشته شده است.
- `git apply --recount` فقط بعد از structural validation استفاده می‌شود؛ malformed/context-invalid patch همچنان fail-closed است.
- PR #600 historical/superseded است و نباید دوباره Heavy یا promotion بگیرد.

آخرین Production Loop تأییدشده‌ای که در این audit مشاهده شد run `33407326883` با conclusion `success` بود، اما head آن `a9078ee5...` است؛ برای current main `2ee2adc2...` در زمان checkpoint run مستقیم تازه‌ای مشاهده نشد و success روی current head ادعا نمی‌شود.

## CI / Build

- provider-selection exact head `6cdd6cd4...` دارای Fast + Heavy Build/APK + Device success کامل است، اما با حرکت main توسط #605 stale-for-promotion شده است.
- merged #605 pre-merge Fast success دارد، ولی Build/Device آن Draft head skipped بودند و در زمان checkpoint post-merge run مستقیم روی `2ee2adc2...` مشاهده نشد؛ پس current-main CI باید جداگانه verify شود.
- Build/Device skipped روی Draft به‌تنهایی success/failure محصول محسوب نمی‌شود.
- skipped/cancelled protective runs evidence محصول نیستند؛ فقط runهای exact-head و ancestry معتبر ملاک‌اند.
- documentation lane جدا و Draft باقی می‌ماند تا validation فعال Product/Automation را stale نکند.

## Progress / Evidence Dashboard

Issue #578 همچنان مرجع Progress Score evidence-backed است و #583 renderer deterministic را تعریف می‌کند. هیچ درصد جدیدی در این checkpoint به‌صورت دستی ادعا نمی‌شود؛ score رسمی فقط باید از scorecard/tool canonical و evidence همان `main` استخراج شود.

## CI / Merge Contract

1. هر Lane از current `main` ساخته یا reconcile شود.
2. Draft فقط Fast/Parallel را می‌گیرد؛ Heavy Build/APK/Device باید بعد از Ready روی همان exact head انجام شود.
3. Merge فقط با current-main ancestry، exact-head evidence و mergeability زنده.
4. Mergeها serial هستند؛ انتظار یک Lane نباید Lane مستقل سالم را متوقف کند.
5. PR/branch stale باید rebuild/reconcile شود، نه force merge.
6. Documentation نباید validation سالم Product/Automation را stale کند؛ docs-only تغییرات در Lane جدا نگه داشته می‌شوند.
7. duplicate/superseded lane نباید Heavy یا merge موازی بگیرد.

## Open operational lanes

- #597 / #604 / #607 — Calendar provider selection: exact-head Fast + Heavy + Device سبز روی `6cdd6cd4...`، ولی پس از merge #605 نیازمند current-main replay/reconcile است؛ فقط یک canonical PR ادامه یابد.
- #516/#348 — bidirectional Android device-calendar integration: provider discovery + bounded read-only event query روی main هستند؛ external projection به Calendar/Work Agenda و سپس idempotent write/sync هنوز باقی است.
- #599 — provider-discovery duplicate Draft؛ باید historical/superseded بماند مگر gap واقعی ثابت شود.
- #600 — Worker reliability historical Draft؛ superseded توسط merged #601 و نباید دوباره promote شود.
- #578/#583 — evidence-backed Progress Score dashboard: implementation/validation کامل نشده.

## Definition of Done

قابلیت فقط وقتی Done است که implementation واقعی، مسیر canonical، تست، exact-head CI، Build/APK/Device لازم، merge امن و مستندات همگرا باشند. Conversation memory یا CI head قدیمی evidence برای head جدید نیست.