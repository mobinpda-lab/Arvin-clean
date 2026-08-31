# Arvin-clean — Live AI Handoff

## Primary Rule

مرجع حاکم فرایند `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 است. GitHub تنها Source of Truth عملیاتی است؛ این فایل فقط checkpoint فشرده برای ادامه سریع است.

## Start Here

در هر گفتگوی جدید یا Trigger «ادامه آروین»:

1. `main`، PRهای باز، Issueهای فعال، Head SHAها و workflowهای همان Head را تازه از GitHub بخوان.
2. این Handoff و `docs/PROJECT_STATUS.md` را با GitHub تطبیق بده؛ GitHub مقدم است.
3. قبل از foundation/model/storage جدید، کد canonical موجود را بخوان.
4. کوچک‌ترین Gap واقعی و مستقل را انتخاب کن؛ Laneهای غیرمسدود را موازی ادامه بده.
5. Merge فقط با exact-head evidence؛ mergeها سریالی باشند و سپس `main` دوباره Build + Device validate شود.
6. Documentation هم‌زمان جلو برود، اما هیچ docs commit نباید PR validation سالم را بی‌دلیل stale کند.

## Live Checkpoint — 2026-08-31

Snapshot فعلی `main`:

`eb52e32f0c49e0ee83a57a4bb6a04157ef1114ed`

آخرین Merge تأییدشده: PR #575 — `fix(calendar): add explicit Jalali date jump on current main`.

### Verified recent delivery

- #575 — پرش مستقیم به تاریخ جلالی در Calendar؛ exact-head Fast + Analyze/Test + Debug/Release APK + Home/People Device Smoke سبز.
- #574 — GitHub-native/Copilot fallback برای AI Worker روی main؛ ابزارهای Copilot read-only و Worker non-merge boundary حفظ شده است.
- Production Loop روی main فعلی بعد از #575 موفق بوده است.

## Active Parallel Lanes

### 1. #579 — AI Worker hardening

Head: `25f243617f95728ad323a034266b224ca52637fb`

- Parallel/Fast: موفق.
- ARVIN Orchestrator: موفق روی PR event.
- Production Loop: موفق روی PR event.
- Heavy Build و Device Smoke برای exact head با workflow_dispatch فعال شده‌اند؛ قبل از سبز شدن کامل merge نکن.
- Scope: unified-diff validation، BOM/CRLF/fence normalization، provider timeout و retry budget، کاهش درخواست provider.
- Product model/storage/UI را تغییر نمی‌دهد.

### 2. #580 — Backup restore confirmation

Head فعلی: `1c562afa069c8abfbc8a2b24fdaadf75016a9f57`

- Draft و مستقل از #579.
- safety UX: Restore بعد از خواندن فایل، قبل از replace نیاز به تأیید صریح دارد؛ Cancel صفر mutation.
- Fast قبلی روی دو widget test جدید `pumpAndSettle timeout` داشت، نه product logic failure.
- تست اصلاح شده و چون head عوض شده، exact-head Fast باید دوباره اجرا و مبنا قرار گیرد.

## Release Blockers — current reality

1. تکمیل Heavy exact-head evidence #579؛ اگر سبز شد، merge سریالی و post-merge Build/Device روی main جدید.
2. revalidate #580 روی head جدید؛ سپس Ready → Heavy Build/Device → merge فقط بعد از main sanity.
3. اثبات عملی یک چرخه واقعی AI Worker: Issue → patch معتبر → PR → CI، بدون merge خودکار یا دخالت foundation جدید.
4. PRهای تاریخی/stale از baseهای قدیمی evidence فعلی نیستند و قبل از promotion باید روی current main rebuild/reconcile شوند.

## Product/Foundation Invariants

- Persian RTL Flutter app.
- Canonical foundation: `Task / Unified Item → Reminder → FollowUps[] → History`.
- Home/Search/Today/Timeline/FollowUp/Calendar/Backup/Settings/Widget/PDF باید foundation موجود را reuse کنند.
- Task model/store دوم ممنوع است مگر audit تازه الزام کند.
- Backup SAF/cloud/encryption باید روی canonical byte/document path موجود همگرا بمانند.
- Calendar داخلی موجود و validate شده است؛ external Google/Samsung sync موضوع مستقل است.

## Fast Lane Contract

- Draft PR → Parallel Wave؛ Heavy Build/Device skip.
- Ready PR → Build + Device.
- Build → quality/analyze/tests سپس APK release/debug مستقل.
- Device → Home + People smoke.
- exact-head evidence تنها evidence معتبر برای merge است.
- mergeها سریالی؛ بعد از هر merge، main دوباره validate می‌شود.
- docs lane نباید برای «به‌روز بودن» مصنوعی، main را حرکت دهد و validation laneها را stale کند.

## Documentation Rule

- `PROJECT_STATUS.md` و این فایل checkpoint زنده‌اند.
- اسناد موضوعی قدیمی تاریخچه هستند و حذف/بازنویسی بی‌دلیل ممنوع است.
- اگر در یک بازه ساعتی تغییر معناداری در main/PR/evidence/Blocker رخ نداده باشد، docs commit نویزی ساخته نشود.

## Continuation Trigger

«ادامه آروین» یعنی:

`Fresh GitHub audit → reconcile stale docs → continue independent lanes in parallel → avoid duplicate foundations → validate exact head → safe serial merge → post-merge validate → next real vertical slice → document in parallel → short nontechnical report`

Repository reality always overrides conversation memory.
