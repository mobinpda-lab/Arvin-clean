# Arvin — Project Status

## وضعیت زنده — 2026-08-31

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل checkpoint زنده است و قبل از هر تصمیم باید با `main`، PRها، Issueها و exact-head CI دوباره تطبیق داده شود.

- Branch مرجع: `main`
- snapshot فعلی تأییدشده: `6dcb368db8565018384c4a6fb7aad9be22ea9e8c`
- آخرین Merge تأییدشده: PR #592 — `feat(calendar): expose device calendar settings on latest main`
- Merge قبلی مهم: PR #582 — ایمن‌سازی Restore با تأیید صریح قبل از جایگزینی داده فعلی
- AI Worker patch/provider hardening روی main: PR #579
- Calendar date-jump روی main: PR #575
- AI Code Worker GitHub-native fallback روی main: PR #574
- Production feedback loop روی main: PR #573

## Release Blockers

در audit این checkpoint هیچ Issue باز با label دقیق `release-blocker` پیدا نشد. این به معنی RC-ready بودن خودکار نیست؛ PRهای فعال هنوز باید exact-head/current-main gates خود را کامل و سپس به‌صورت serial merge کنند.

## Core / Data

- foundation اصلی Task / Reminder / FollowUp / History / Settings / Calendar / Backup باید reuse شود؛ store/model/repository موازی ممنوع است.
- تغییرات فعال Calendar و Automation در این checkpoint Core/Data store جدیدی معرفی نمی‌کنند.
- تغییر data-safety بدون migration/compatibility evidence مجاز به promotion نیست.

## Backup / Restore

### PR #582 ✅ merged

- معماری Backup/Restore، encryption و callbackهای موجود حفظ شده‌اند.
- پس از خواندن موفق backup و قبل از جایگزینی Taskهای فعلی، تأیید صریح کاربر لازم است.
- Cancel نباید mutation ایجاد کند.
- تعداد Taskهای ورودی در هشدار نمایش داده می‌شود.
- failure behavior فایل invalid/encrypted حفظ شده است.

این تغییر روی `main` قرار دارد؛ branch قدیمی #580 بدون merge بسته شده و نباید دوباره promote شود.

## Calendar

### PR #592 — Device Calendar Settings UI ✅ merged

- entry رسمی `تقویم و همگام‌سازی` در Settings canonical اکنون روی `main` است.
- فقط `CalendarIntegrationSettings` و `AppSettingsService` موجود reuse شده‌اند.
- toggleهای safe برای intentهای sync و نمایش external eventها اضافه شده‌اند.
- حذف linked external event به‌صورت پیش‌فرض OFF باقی مانده است.
- provider-specific engine مستقل Google/Samsung ایجاد نشده است.

### PR #598 — Android Calendar Provider discovery — Ready / Heavy green

Head: `2cb663e2a14b68dae70b411289bd22fc5b49f6d9`

- PR باز، mergeable و Ready است.
- Exact-head Fast/Parallel Wave run #1286 موفق است.
- Heavy Build run `33376483721`: quality، Debug APK و Release APK همگی ✅ success.
- Device Smoke run `33376485193`: Home و People هر دو ✅ success.
- scope فقط READ_CALENDAR، permission status/request و provider enumeration است؛ WRITE_CALENDAR و event read/write/delete sync در این slice نیست.
- merge هنوز انجام نشده و باید current-main ancestry و mergeability درست قبل از merge دوباره تأیید شود.

Issueهای مرتبط: #595، #348، #516.

### PR #599 — duplicate provider-discovery draft

PR #599 باز و Draft است و scope آن با #598 هم‌پوشانی دارد. تا وقتی #598 lane فعال و Heavy-proven است، #599 نباید به‌عنوان lane دوم مستقل به Heavy/merge فرستاده شود؛ قبل از هر promotion باید وضعیت duplicate/superseded آن با GitHub live state reconcile شود.

## Automation / Production Orchestrator

Production Orchestrator همچنان authority اصلی promotion/merge است. Worker و Production Loop مجاز به bypass کردن Fast/Build/Device یا merge مستقیم نیستند.

### PR #600 — AI Worker launch + patch reliability — Draft / Fast green

Head: `92c33573ef94b8e6e4e76a5b35df997b84a9cac0`

- Worker برای launch عادی `workflow_dispatch`-only می‌شود و Orchestrator launch authority canonical می‌ماند.
- Production Loop dispatch صریح Auto-Fixهای token-created را حفظ می‌کند.
- concurrency فقط با issue input کلید می‌خورد.
- `git apply --recount` فقط بعد از structural validation استفاده می‌شود؛ context/header خراب همچنان fail-closed است.
- Fast run `33376661169` کاملاً ✅ success است: quality/analyze/test و surfaceهای release/followup/typography/guide/calendar/backup همگی سبز هستند.
- PR هنوز Draft است؛ Heavy/Device عمداً پشت lane محصول فعلی نگه داشته شده تا validation تکراری و رقابت merge ایجاد نشود.
- PR #593 superseded و بسته شده است؛ #589 و #591 نیز historical هستند و نباید مستقل promote شوند.

Issues مالک: #588 و #590.

## CI / Build

- #598 Fast + Heavy Build/APK + Device روی exact head سبز است؛ تنها merge guard نهایی باقی است.
- #600 Fast روی exact head سبز است؛ Heavy هنوز شروع نشده چون PR Draft است.
- cancelled/skipped protective runs نباید به‌عنوان failure واقعی یا evidence موفقیت Heavy تعبیر شوند؛ فقط runهای exact-head مرتبط ملاک‌اند.

## Progress / Evidence Dashboard

Issue #578 همچنان مرجع Progress Score evidence-backed است و #583 slice renderer deterministic را تعریف می‌کند. هیچ درصد جدیدی در این checkpoint به‌صورت دستی ادعا نمی‌شود؛ score رسمی باید فقط از scorecard/tool canonical و evidence همان `main` استخراج شود.

## CI / Merge Contract

1. هر Lane از current `main` ساخته یا reconcile شود.
2. Draft فقط Fast/Parallel را می‌گیرد؛ Heavy Build/APK/Device باید بعد از Ready روی همان exact head انجام شود.
3. Merge فقط با current-main ancestry، exact-head evidence و mergeability زنده.
4. Mergeها serial هستند؛ انتظار یک Lane نباید Lane مستقل سالم را متوقف کند.
5. PR/branch stale باید rebuild/reconcile شود، نه force merge.
6. Documentation نباید validation سالم Product/Automation را stale کند؛ docs-only تغییرات در Lane جدا نگه داشته می‌شوند.
7. duplicate lane نباید Heavy یا merge موازی بگیرد.

## Open operational lanes

- #598 — provider discovery: Fast + Build/APK + Device green؛ merge guard نهایی pending.
- #600 — Worker reliability: Fast green؛ هنوز Draft و Heavy pending.
- #599 — provider-discovery duplicate Draft؛ نیازمند reconcile/supersede قبل از هر promotion.
- #578/#583 — evidence-backed Progress Score dashboard: implementation/validation کامل نشده.
- #516/#348 — bidirectional Android device-calendar integration: event read/write/projection/sync مراحل بعدی هستند.

## Definition of Done

قابلیت فقط وقتی Done است که implementation واقعی، مسیر canonical، تست، exact-head CI، Build/APK/Device لازم، merge امن و مستندات همگرا باشند. Conversation memory یا CI head قدیمی evidence برای head جدید نیست.