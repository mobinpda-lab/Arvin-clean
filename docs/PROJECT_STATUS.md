# Arvin — Project Status

## وضعیت زنده — 2026-08-31

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل checkpoint زنده است و قبل از هر تصمیم باید با `main`، PRها، Issueها و exact-head CI دوباره تطبیق داده شود.

- Branch مرجع: `main`
- snapshot فعلی: `377da2dfe0a5de6b998e2cfa520d13972918b4a9`
- آخرین Merge تأییدشده: PR #582 — `fix(backup): confirm before replacing local data on latest main`
- Merge مهم قبلی: PR #579 — سخت‌سازی خروجی patch و budget/timeout ارائه‌دهنده AI Worker
- Calendar date-jump روی main: PR #575
- AI Code Worker GitHub-native fallback روی main: PR #574
- Production feedback loop روی main: PR #573

## Release / Data Safety

### Backup / Restore — PR #582 ✅ merged

- معماری Backup/Restore، encryption و callbackهای موجود حفظ شده‌اند.
- پس از خواندن موفق backup و قبل از جایگزینی Taskهای فعلی، تأیید صریح کاربر لازم است.
- Cancel نباید mutation ایجاد کند.
- تعداد Taskهای ورودی در هشدار نمایش داده می‌شود.
- failure behavior فایل invalid/encrypted حفظ شده است.

این تغییر از مسیر current-main تازه بازسازی شد و branch قدیمی #580 بدون merge بسته شد.

## Automation / Production Orchestrator

Production Orchestrator همچنان authority اصلی promotion/merge است. Worker و Production Loop مجاز به bypass کردن Fast/Build/Device یا merge مستقیم نیستند.

### PR #593 — AI Worker reliability — Draft / Fast green

Head: `76aa045af3450fbe3b7855c39d204af1a8babf05`

- Orchestrator به launch authority عادی Worker تبدیل می‌شود؛ Worker `workflow_dispatch`-only می‌شود.
- Production Loop dispatch صریح Auto-Fixهای token-created را حفظ می‌کند.
- concurrency فقط با issue input کلید می‌خورد.
- `git apply --recount` فقط بعد از validation ساختاری استفاده می‌شود تا hunk-count عددی اشتباه recover شود؛ context/header خراب همچنان fail-closed می‌ماند.
- Fast/Parallel Wave run #1283 روی همین head موفق است؛ Build/Device در Draft طبق قرارداد skip شده‌اند.
- PRهای #589 و #591 supersede و بسته شده‌اند تا Heavy validation تکراری ساخته نشود.

Issues مالک: #588 و #590.

## Calendar

### PR #592 — Device Calendar Settings UI — Draft / Fast green

Head: `7c75439189221be5d631b7a21866bde82a435e9b`

- entry رسمی `تقویم و همگام‌سازی` در Settings canonical.
- reuse فقط از `CalendarIntegrationSettings` و `AppSettingsService` موجود.
- toggleهای safe برای intentهای sync و نمایش external eventها.
- provider IDs تا زمان Android Calendar Provider discovery read-only می‌مانند.
- حذف linked external event به‌صورت پیش‌فرض OFF است.
- Fast/Parallel Wave run #1282 روی همین head موفق است؛ Build/Device در Draft طبق قرارداد skip شده‌اند.
- PR #586 پس از حرکت main supersede و بسته شد.

Issue مالک: #584. Target بزرگ‌تر Bidirectional Device Calendar Integration در #516 باقی است و provider discovery/read/write هنوز خارج از این slice است.

## Progress / Evidence Dashboard

Issue #578 همچنان باز است: Progress Score باید به dashboard زنده evidence-backed تبدیل شود بدون ساخت score source دوم. Issue #583 slice محدود renderer deterministic را تعریف کرده است. هیچ درصد جدیدی در این checkpoint به‌صورت دستی ادعا نمی‌شود؛ score رسمی باید فقط از scorecard/tool canonical و evidence همان main استخراج شود.

## Core / Data Invariants

- foundation اصلی محصول باید reuse شود؛ Task/FollowUp/Reminder/Calendar/Backup/Settings/Report نباید store/model/repository موازی بسازند.
- تغییر data-safety بدون migration/compatibility evidence مجاز به promotion نیست.
- Calendar integration باید روی foundation موجود و Android Calendar Provider adapter مشترک بنا شود؛ engine مستقل Google/Samsung ساخته نشود.

## CI / Merge Contract

1. هر Lane از current `main` ساخته یا reconcile شود.
2. Draft فقط Fast/Parallel را می‌گیرد؛ Heavy Build/APK/Device باید بعد از Ready روی همان exact head انجام شود.
3. Merge فقط با current-main ancestry، exact-head evidence و mergeability زنده.
4. Mergeها serial هستند؛ انتظار یک Lane نباید Lane مستقل سالم را متوقف کند.
5. PR/branch stale باید rebuild/reconcile شود، نه force merge.
6. Documentation نباید validation سالم Product/Automation را stale کند؛ docs-only تغییرات در Lane جدا نگه داشته می‌شوند.

## Open operational lanes

- #592 — Calendar settings UI: Fast green، هنوز Draft/Heavy pending.
- #593 — Worker launch + patch reliability: Fast green، هنوز Draft/Heavy pending.
- #578/#583 — evidence-backed Progress Score dashboard: هنوز implementation/validation کامل نشده.
- #516/#348 — bidirectional Android device-calendar integration: مراحل provider discovery/read/write و projection هنوز باقی است.

## Definition of Done

قابلیت فقط وقتی Done است که implementation واقعی، مسیر canonical، تست، exact-head CI، Build/APK/Device لازم، merge امن و مستندات همگرا باشند. Conversation memory یا CI head قدیمی evidence برای head جدید نیست.