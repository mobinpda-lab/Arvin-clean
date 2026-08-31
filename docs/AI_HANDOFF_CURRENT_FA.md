# Arvin-clean — Live AI Handoff

## Primary Rule

GitHub تنها Source of Truth عملیاتی است. این فایل فقط checkpoint فشرده برای ادامه سریع است؛ هر اجرای جدید باید قبل از اقدام، `main`، PRها، Issueها و exact-head CI را تازه بخواند.

## Live Checkpoint — 2026-08-31

Current `main`:

`2ee2adc22a45ab5fda1dcd548672ddaf77717afc`

آخرین Merge تأییدشده: PR #605 — bounded read-only Android calendar event query.

Mergeهای مهم همین موج:
- #579 — AI patch validation + provider timeout/budget hardening
- #582 — Backup restore confirmation safety
- #592 — Calendar integration settings UI
- #598 — Android Calendar Provider discovery
- #601 — Worker single-launch authority + safe patch recount reliability
- #605 — bounded provider-neutral read-only external event query

## Active Parallel Lanes

### 1. Calendar provider selection — Issue #597 / PR #604 / PR #607

Shared validated head:

`6cdd6cd49ecb038851cce76a2a37e9c499f139fb`

- #604 و #607 یک implementation هم‌پوشان provider-selection را حمل می‌کنند؛ #607 برای گرفتن Fast رسمی پس از اصلاح API منسوخ Flutter ساخته شد.
- Fast/Parallel run `33406629330`: ✅ success.
- Heavy Build run `33406422054`: ✅ quality/test + Debug APK + Release APK success.
- Device Smoke run `33406422349`: ✅ Home + People success.
- implementation existing `SystemCalendarBridge` + existing `CalendarIntegrationSettings` / `AppSettingsService` را reuse می‌کند.
- permission/listing فقط با اقدام صریح کاربر آغاز می‌شود؛ page load به‌تنهایی platform permission یا settings write ایجاد نمی‌کند.
- target calendar + visible calendar IDs از canonical settings استفاده می‌کنند.
- Google/Samsung/other calendars همان Android Calendar Provider path را استفاده می‌کنند؛ vendor-specific engine ساخته نشده است.
- WRITE_CALENDAR و direct event mutation هنوز خارج از این slice هستند.
- چون `main` بعد از این validation با merge #605 به `2ee2adc2...` جلو رفته، این SHA اکنون evidence تاریخی معتبر است اما promotion-current نیست. مرحله بعد فقط یک canonical replay/reconcile روی current main است؛ #604 و #607 نباید هر دو جداگانه Heavy/merge شوند.

### 2. Read-only external event provider — PR #605 ✅ merged

Current main merge SHA:

`2ee2adc22a45ab5fda1dcd548672ddaf77717afc`

- existing `arvin/system_calendar` bridge اکنون `listDeviceCalendarEvents` دارد.
- Android `CalendarContract.Instances` concrete recurrence instanceها را در window محدود می‌خواند.
- READ_CALENDAR only؛ هر call حداکثر 20 calendar و 93 روز.
- provider-neutral event model شامل شناسه‌ها، calendar name، title/description، start/end/all-day، timezone و recurrence rule است.
- malformed rows / denied permission / missing plugin fail closed هستند.
- Task import، Work Agenda UI، WRITE_CALENDAR، create/update/delete، background sync و vendor SDK اضافه نشده‌اند.
- pre-merge exact-head `071abc3b...` Fast/Parallel run `33406072049` ✅ success؛ Build/Device آن Draft head skipped بودند.
- current-main operational evidence تازه: Production Loop run `33411270935` روی exact head `2ee2adc2...` با conclusion `success` کامل شده است.
- هنوز current-main Build/APK یا Device success مستقل برای merge SHA `2ee2adc2...` در این checkpoint تأیید نشده؛ Production Loop success جایگزین آن gateها نیست.

### 3. Duplicate/superseded cleanup

- PR #599 scope merged provider-discovery #598 را overlap می‌کند؛ بدون live diff gap جدید Heavy/Device یا merge budget نگیرد.
- PR #600 توسط merged #601 superseded است و historical evidence محسوب می‌شود.
- provider-selection #604/#607 نیز یک implementation مشترک دارند؛ فقط یک current-main replay باید ادامه پیدا کند.

### 4. Live Progress Score — #578 / #583

- reuse existing `tool/progress_score.py` و canonical scorecards.
- no second score source.
- exact-main SHA و PASS/FAIL/BLOCKED evidence required.
- stale evidence هرگز score را بالا نبرد.
- درصد دستی ساخته/ویرایش نشود.

## Calendar Reality

روی current `main` اکنون این foundations وجود دارند:
- Settings UI از #592
- READ_CALENDAR permission/provider discovery از #598
- bounded read-only event query از #605

هنوز باقی است:
- provider selection replay روی current main (#597)
- external event projection به Calendar/Work Agenda موجود
- Arvin→provider idempotent create/update + stable mapping
- delete/conflict/import policies و real-device evidence برای مراحل write/sync

#516/#348 umbrella اجرای بزرگ‌تر را نگه می‌دارند. Work Agenda موجود باید aggregator بماند و engine/report path دوم ساخته نشود.

## Automation Reality

PR #601 روی main باقی است:
- normal AI Worker launch = `workflow_dispatch`-only
- ARVIN Orchestrator = canonical launch authority
- Production Loop explicit dispatch برای GITHUB_TOKEN Auto-Fix حفظ شده است
- concurrency issue-input keyed است
- Git native `--recount` فقط بعد از structural validation استفاده می‌شود و malformed/context-invalid patch fail closed می‌ماند

Current-main evidence: Production Loop run `33411270935` روی head `2ee2adc22a45ab5fda1dcd548672ddaf77717afc` در 2026-08-31 با conclusion `success` کامل شده است. این evidence فقط سلامت همان workflow را ثابت می‌کند و به‌تنهایی Build/APK/Device یا RC readiness را اثبات نمی‌کند.

## Production / Merge Contract

- Production Orchestrator canonical promotion/merge authority است.
- Worker/Production Loop نباید gateها را bypass یا مستقیم merge کنند.
- Draft → exact-head Fast/Parallel.
- Ready → Heavy Build/APK + Device روی همان head و current-main ancestry.
- merge serial؛ development laneهای مستقل parallel.
- اگر `main` حرکت کرد، affected lane reconcile/rebuild شود؛ force merge ممنوع.
- healthy workflow برای سرعت دادن lane دیگر restart/cancel نشود.
- duplicate/superseded lane duplicate Heavy/merge نگیرد.

## Core / Data / Backup Safety

- existing Task / Reminder / FollowUp / History / Settings / Work Agenda / Backup foundations حفظ شوند.
- duplicate TaskStore, Settings store, Calendar engine, scheduler, report path یا Backup repository ساخته نشود.
- #605 فقط provider bridge/read model را گسترش داده و canonical Task/FollowUp data را mutate نمی‌کند.
- Restore mutation همچنان بعد از read/validation موفق و confirmation صریح است؛ بعد از #582 تغییر Backup جدیدی تأیید نشد.
- هیچ Issue باز با label دقیق `release-blocker` در این checkpoint پیدا نشد، اما RC readiness به current-main CI و laneهای باز وابسته است.

## Continuation Priority

1. current main `2ee2adc2...` و post-merge CI را دوباره verify کن؛ Production Loop روی current head سبز است اما Build/APK/Device فقط با evidence مستقل ادعا شوند.
2. provider-selection را فقط در یک canonical PR از current main replay/reconcile کن؛ historical #604/#607 evidence را حفظ کن ولی دوباره duplicate Heavy اجرا نکن.
3. پس از selection، external events را به existing Calendar/Work Agenda projection متصل کن؛ موتور/صفحه/Store دوم نساز.
4. #599/#600 را historical/superseded نگه دار مگر gap واقعی ثابت شود.
5. #578/#583 را فقط با extension ابزار score canonical ادامه بده.
6. Documentation را در همین Draft lane موجود نگه دار و فقط روی تغییر معنادار GitHub update کن؛ docs نباید Product/Automation validation سالم را stale کند.

## Continuation Trigger

`Fresh GitHub audit → parallel independent implementation → exact-head Fast → serial Ready/Heavy → guarded merge → post-merge re-audit → reconcile docs → next smallest real gap`

Repository reality always overrides conversation memory and this checkpoint.