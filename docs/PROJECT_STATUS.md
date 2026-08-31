# Arvin — Project Status

## وضعیت زنده — 2026-08-31

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل checkpoint زنده است و قبل از هر تصمیم باید با `main`، PRها، Issueها و exact-head CI دوباره تطبیق داده شود.

- Branch مرجع: `main`
- snapshot فعلی تأییدشده: `a4c2a3eca5838808ed0dee7c389f2d0dce997ba6`
- آخرین Merge تأییدشده: PR #598 — `feat(calendar): discover Android device calendars on current main`
- Merge قبلی مهم: PR #592 — Device Calendar Settings UI
- Backup restore confirmation: PR #582 روی main
- AI Worker patch/provider hardening: PR #579 روی main
- Calendar date-jump: PR #575 روی main
- AI Code Worker GitHub-native fallback: PR #574 روی main
- Production feedback loop: PR #573 روی main

## Release Blockers

در audit این checkpoint هیچ Issue باز با label دقیق `release-blocker` پیدا نشد. این به معنی RC-ready بودن خودکار نیست؛ PRهای فعال هنوز باید نسبت به `main` فعلی reconcile شوند و exact-head/current-main gates خود را کامل کنند.

## Core / Data

- foundation اصلی Task / Reminder / FollowUp / History / Settings / Calendar / Backup باید reuse شود؛ store/model/repository موازی ممنوع است.
- merge #598 Core/Data store جدیدی معرفی نکرد؛ تغییر آن در boundary اندروید و bridge تقویم provider-neutral است.
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

Merge SHA: `a4c2a3eca5838808ed0dee7c389f2d0dce997ba6`

- READ_CALENDAR، permission status/request و Android `CalendarContract` provider enumeration اکنون روی `main` است.
- typed provider metadata برای calendar/accountهای نصب‌شده در bridge موجود اضافه شده است.
- WRITE_CALENDAR و event read/write/delete sync در این slice اضافه نشده است.
- قبل از merge، exact-head Fast/Parallel، Build quality، Debug/Release APK و Home/People Device Smoke روی head #598 سبز بودند.
- این merge foundation لازم برای انتخاب provider در مراحل بعدی است؛ bidirectional sync کامل هنوز Done نیست.

Issueهای مرتبط: #595، #348، #516.

### PR #599 — overlapping provider-discovery draft

PR #599 هنوز باز و Draft است، اما پس از merge شدن #598 scope آن عملاً توسط `main` جلو افتاده است. این lane نباید Heavy یا merge مستقل بگیرد مگر اینکه GitHub live diff نشان دهد gap جدید و غیرتکراری دارد؛ در غیر این صورت باید به‌عنوان duplicate/superseded reconcile شود.

## Automation / Production Orchestrator

Production Orchestrator همچنان authority اصلی promotion/merge است. Worker و Production Loop مجاز به bypass کردن Fast/Build/Device یا merge مستقیم نیستند.

### PR #600 — AI Worker launch + patch reliability — Draft / Fast historical-green

Head: `92c33573ef94b8e6e4e76a5b35df997b84a9cac0`

- Fast run `33376661169` روی exact head خودش کاملاً ✅ success بوده است.
- scope شامل workflow_dispatch-only شدن Worker برای launch عادی، explicit dispatch توسط Orchestrator/Production Loop، concurrency بر پایه issue input و `git apply --recount` بعد از structural validation است.
- malformed/context-invalid patch همچنان fail-closed است.
- PR هنوز Draft و mergeable است، اما base آن قبل از merge #598 بوده است؛ بنابراین Fast قبلی evidence تاریخی همان head است و برای promotion بعدی باید #600 ابتدا با `main` جدید `a4c2a3ec...` reconcile شود.
- Heavy/Device pre-reconcile نباید اجرا یا به‌عنوان evidence current-main مصرف شود.
- PR #593 superseded و بسته شده است؛ #589/#591 historical هستند و نباید مستقل promote شوند.

Issues مالک: #588 و #590.

## CI / Build

- #598 با Fast + Heavy Build/APK + Device سبز merge شد؛ این evidence متعلق به head تأییدشده همان PR است.
- #600 Fast سبز دارد، ولی پس از حرکت `main` به #598 باید قبل از Heavy دوباره current-main reconcile شود.
- skipped/cancelled protective runs evidence failure یا success محصول نیستند؛ فقط runهای exact-head و ancestry معتبر ملاک‌اند.
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
7. duplicate lane نباید Heavy یا merge موازی بگیرد.

## Open operational lanes

- #600 — Worker reliability: Fast head خودش green است؛ بعد از merge #598 نیازمند reconcile با main جدید قبل از Heavy.
- #599 — provider-discovery duplicate Draft؛ پس از merge #598 نیازمند close/supersede یا اثبات gap غیرتکراری.
- #578/#583 — evidence-backed Progress Score dashboard: implementation/validation کامل نشده.
- #516/#348 — bidirectional Android device-calendar integration: provider discovery foundation روی main است؛ event projection/read/write/sync مراحل بعدی هستند.

## Definition of Done

قابلیت فقط وقتی Done است که implementation واقعی، مسیر canonical، تست، exact-head CI، Build/APK/Device لازم، merge امن و مستندات همگرا باشند. Conversation memory یا CI head قدیمی evidence برای head جدید نیست.