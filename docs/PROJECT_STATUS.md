# Arvin — Project Status

## وضعیت زنده — 2026-09-01

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل checkpoint زنده است و قبل از هر تصمیم باید با `main`، PRها، Issueها و exact-head CI دوباره تطبیق داده شود.

- Branch مرجع: `main`
- snapshot فعلی تأییدشده: `2ee2adc22a45ab5fda1dcd548672ddaf77717afc`
- آخرین Merge تأییدشده: PR #605 — `feat(calendar): add bounded read-only device event query`
- Merge قبلی مهم: PR #601 — Worker reliability / launch authority
- Calendar Provider discovery: PR #598 روی main
- Calendar Settings UI: PR #592 روی main
- Backup restore confirmation: PR #582 روی main
- AI Worker timeout/budget hardening: PR #579 روی main

## Release Blockers / RC Freeze

در audit این checkpoint هیچ Issue باز با label دقیق `release-blocker` تأیید نشد. این به معنی RC-ready بودن خودکار نیست؛ promotion همچنان به current-main ancestry، exact-head validation و در صورت نیاز Build/APK/Device معتبر نیاز دارد.

### Issue #612 — RC Feature Freeze + Canonical PR policy 🟡 open

قانون رسمی ثبت‌شده:

```text
Product Decision = FINAL
        ↓
Canonical PR Selected
        ↓
No Alternative PR
        ↓
Only Validation Remains
```

هدف این policy جلوگیری از بازشدن دوباره طراحی قابلیت نهایی‌شده، PRهای موازی و تکرار validation است. پس از FINAL شدن تصمیم محصول، فقط validation، test، build verification و release evidence باید باقی بماند. این rule به‌طور ویژه برای Calendar و سایر قابلیت‌های release-sensitive ثبت شده است.

برای Calendar provider selection، PR #607 در body خود صراحتاً canonical Fast proof برای exact head مشترک `6cdd6cd49ecb038851cce76a2a37e9c499f139fb` معرفی شده و #604 را برای promotion supersede می‌کند. با این حال چون `main` بعداً توسط #605 جلو رفته، promotion نهایی هنوز به reconcile/replay روی current main نیاز دارد؛ طراحی محصول نباید دوباره باز شود.

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
- current-main Build/APK و Device success مستقل برای merge SHA `2ee2adc2...` هنوز در این checkpoint تأیید نشده‌اند؛ Orchestrator/Production Loop success جایگزین آن gateها نیست.

### PR #607 — Canonical provider-selection validation path 🟡 open

Shared exact head با #604: `6cdd6cd49ecb038851cce76a2a37e9c499f139fb`

- #607 برای replay همان provider-selection implementation با latest Flutter API ساخته شده و در PR body به‌عنوان canonical Fast proof معرفی شده است.
- exact-head Fast/Parallel run `33406629330`: `success`.
- exact-head Heavy Build run `33406422054`: `success`؛ quality/test و Debug/Release APK کامل سبز شدند.
- exact-head Device Smoke run `33406422349`: `success`؛ Home و People هر دو سبز شدند.
- این evidence برای SHA `6cdd6cd4...` معتبر است، اما چون `main` با #605 به `2ee2adc2...` جلو رفته، قبل از promotion نهایی باید همان مسیر canonical روی current main reconcile/replay شود.
- Product Decision نباید دوباره باز شود؛ طبق #612 از این نقطه فقط validation/reconcile مجاز است.

### PR #604 — historical provider-selection evidence

#604 همان exact head و implementation را حمل می‌کند. طبق #607 برای promotion superseded است؛ evidence موجود آن historical/exact-SHA باقی می‌ماند ولی نباید lane موازی Heavy/merge ایجاد کند.

Issue مالک selection: #597 باز است. #348/#516 همچنان umbrella اجرای read/write/idempotent sync و external projection را نگه می‌دارند.

### PR #599 — provider-discovery duplicate Draft

PR #599 هنوز باز است، ولی scope آن توسط merge #598 روی `main` پوشش داده شده است. مگر اینکه live diff gap جدید و غیرتکراری ثابت کند، نباید Heavy/Device یا merge budget مصرف کند.

## Multi Device Sync Architecture

### PR #611 — Arvin Multi Device Sync Architecture v15 🟡 open draft

PR #611 یک lane مستنداتی/معماری بعد از RC است و روی `main` merge نشده است.

اصول ثبت‌شده در آن:

- Direct Device-to-Device Sync اولویت اول است.
- Local WiFi / Hotspot / WiFi Direct مسیر اصلی ارتباط هستند و اینترنت نباید prerequisite باشد.
- Offline First و Local Database First حفظ می‌شوند.
- Trusted Device Pairing و secure peer connection پایه multi-device هستند.
- Cloud optional است و نباید محل اجرای Sync Logic باشد.
- Conflict Resolution، Recovery، Audit و YadNegar integration در roadmap معماری لحاظ شده‌اند.

این PR design reference آینده است و طبق policy فعلی نباید RC یا validation فعال Calendar را block یا stale کند.

## Automation / Production Orchestrator

Production Orchestrator همچنان authority اصلی promotion/merge است. Worker و Production Loop مجاز به bypass کردن Fast/Build/Device یا merge مستقیم نیستند.

### PR #601 — AI Worker launch + patch reliability ✅ merged

- normal AI Worker launch `workflow_dispatch`-only است و Orchestrator authority اصلی dispatch است.
- Production Loop explicit dispatch برای Auto-Fixهای ساخته‌شده با `GITHUB_TOKEN` را حفظ می‌کند.
- concurrency بر پایه issue input نگه داشته شده است.
- `git apply --recount` فقط بعد از structural validation استفاده می‌شود؛ malformed/context-invalid patch همچنان fail-closed است.
- PR #600 historical/superseded است و نباید دوباره Heavy یا promotion بگیرد.

Latest verified current-main ARVIN Orchestrator run: `33487725264` در 2026-09-01، event=`issues` برای Issue #612، head=`2ee2adc22a45ab5fda1dcd548672ddaf77717afc` و conclusion=`success`.

این run نشان می‌دهد Orchestrator روی current main بعد از ثبت RC Freeze policy سالم اجرا شده است، ولی به‌تنهایی Build/APK/Device یا RC readiness را ثابت نمی‌کند.

## Resilient Production / Factory Protocol v2

### PR #609 — resilient continuous production checkpoints 🟡 open draft

- scope ثبت‌شده شامل `PROJECT_STATE.md`، `ROADMAP_QUEUE.md` و `DECISIONS.md` است.
- هدف: حفظ canonical state در GitHub، ادامه‌پذیری پس از قطع session/connection و جلوگیری از توقف توسعه.
- PR `open`, `draft`, `mergeable` است و هنوز روی `main` ادغام نشده؛ بنابراین merged production capability محسوب نمی‌شود.
- این lane documentation/continuity باید از validation فعال Product/Automation جدا بماند و باعث stale شدن laneهای release نشود.

### Issue #610 — Universal Autonomous Software Factory Protocol v2 🟡 open

Issue #610 adoption لایه‌های عملیاتی زیر را ثبت می‌کند:

- Bottleneck Manager
- Normal / Fast Delivery / Emergency RC production modes
- Priority Engine مبتنی بر value/urgency/dependency/risk/effort
- Parallel Conflict Controller برای shared files/modules/dependencies
- Learning Loop پس از release
- Evidence-Based Automation Score
- Human Escalation فقط برای ambiguity/security/destructive/irreversible decisions

این Issue operating-policy task است، نه evidence اجرای کامل Level 10. تا زمانی که workflow/test/build/release/recovery evidence واقعی وجود نداشته باشد، `100% End-to-End Automation` ادعا نمی‌شود.

## CI / Build

- provider-selection exact head `6cdd6cd4...` دارای Fast + Heavy Build/APK + Device success کامل است، اما با حرکت main توسط #605 stale-for-promotion شده است؛ فقط #607 باید canonical validation path باشد.
- merged #605 pre-merge Fast success دارد و current-main Orchestrator نیز روی merge head سبز است، ولی current-main Build/APK/Device success مستقل در این checkpoint تأیید نشده است.
- Build/Device skipped روی Draft به‌تنهایی success/failure محصول محسوب نمی‌شود.
- skipped/cancelled protective runs evidence محصول نیستند؛ فقط runهای exact-head و ancestry معتبر ملاک‌اند.
- documentation lane جدا و Draft باقی می‌ماند تا validation فعال Product/Automation را stale نکند.

## Release

- GitHub Releases در این checkpoint خالی است؛ هیچ Release منتشرشده‌ای ثبت نشده است.
- بنابراین RC/Release فقط بعد از evidence مستقل و معتبر Build/APK/Device روی current main قابل ادعا است؛ Orchestrator یا Production Loop سبز به‌تنهایی معادل Release artifact یا RC-ready نیست.

## Product Evolution Roadmap

Issue #608 roadmap تأییدشده پس از تثبیت RC/نسخه پایدار را ثبت می‌کند. ترتیب فعلی آن چهار Wave است:

1. **Core Productivity** — Today Center، Next Action Foundation، Daily/Weekly Dashboard.
2. **Knowledge Layer** — Task ↔ Notebook، Decision History، Unified Search.
3. **Reporting** — Smart Reports و Timeline Activity History.
4. **AI Assistant** — پیشنهاد اولویت، تشخیص عقب‌افتادگی، پیشنهاد Next Action و خلاصه پروژه‌ها پس از جمع شدن داده کافی.

قیدهای #608: reuse معماری فعلی، small slice، test/document/merge استاندارد، بدون Storage/Database جدید، بدون بازنویسی Task Engine و بدون Calendar مستقل. این roadmap بعد از RC است و نباید laneهای Release/validation فعلی را stale یا متوقف کند.

PR #611 اکنون یک architecture lane جداگانه برای Multi Device Sync آینده است و باید همین اصل post-RC / non-blocking را رعایت کند.

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
8. پس از `Product Decision = FINAL` فقط یک Canonical PR مجاز به promotion است و فقط Validation باقی می‌ماند.

## Open operational lanes

- #597 / #607 — Calendar provider selection: Product Decision نهایی؛ #607 canonical validation path است، exact-head Fast + Heavy + Device روی `6cdd6cd4...` سبز، اما پس از #605 نیازمند current-main replay/reconcile است.
- #604 — provider-selection historical evidence؛ superseded برای promotion توسط #607.
- #516/#348 — bidirectional Android device-calendar integration: provider discovery + bounded read-only event query روی main هستند؛ external projection و سپس idempotent write/sync هنوز باقی است.
- #609 — Resilient Production checkpoint docs: open Draft, mergeable, not on main yet.
- #610 — Factory Protocol v2 adoption task: open; policy integration pending evidence-backed implementation.
- #611 — Multi Device Sync Architecture v15: open Draft، post-RC/non-blocking؛ Direct Device-to-Device اولویت اول.
- #612 — RC Feature Freeze / Canonical PR policy: open operating-policy issue؛ طراحی FINAL را از validation جدا می‌کند.
- #599 — provider-discovery duplicate Draft؛ historical/superseded مگر gap واقعی ثابت شود.
- #600 — Worker reliability historical Draft؛ superseded توسط merged #601 و نباید دوباره promote شود.
- #578/#583 — evidence-backed Progress Score dashboard: implementation/validation کامل نشده.
- #608 — Product Evolution Roadmap بعد از RC؛ مرجع برنامه‌ریزی و non-blocking برای Release جاری.

## Definition of Done

قابلیت فقط وقتی Done است که implementation واقعی، مسیر canonical، تست، exact-head CI، Build/APK/Device لازم، merge امن و مستندات همگرا باشند. Conversation memory یا CI head قدیمی evidence برای head جدید نیست.