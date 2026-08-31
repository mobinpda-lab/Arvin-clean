# Arvin — Project Status

## وضعیت زنده — 2026-08-31

GitHub تنها Source of Truth عملیاتی پروژه است. این فایل فقط checkpoint فشرده است و هر SHA، PR، CI، درصد یا وضعیت باید قبل از اقدام دوباره از GitHub تازه بررسی شود.

- Branch مرجع: `main`
- snapshot فعلی: `eb52e32f0c49e0ee83a57a4bb6a04157ef1114ed`
- آخرین Merge تأییدشده در `main`: PR #575 — افزودن پرش مستقیم به تاریخ جلالی در Calendar
- PR #575 قبل از Merge روی exact head `5707d346...` با Fast، Analyze/Test، Debug APK، Release APK، Home Device Smoke و People Device Smoke سبز شد.
- ARVIN Production Loop روی `main` فعلی بعد از Merge #575 موفق بوده است.
- مستندسازی نباید با commit مستقیم روی `main`، PRهای validation فعال را stale کند؛ این refresh روی lane مستندات جدا انجام می‌شود.

## قرارداد اجرای سریع

هدف، تحویل در چند ساعت به‌جای چند روز است، بدون قربانی‌کردن صحت:

1. Audit زنده GitHub قبل از تصمیم.
2. Laneهای مستقل هم‌زمان؛ Block یک Lane نباید بقیه را متوقف کند.
3. Merge فقط با evidence همان Head SHA.
4. بعد از Merge، `main` دوباره Build + Device Smoke می‌شود.
5. Implementation، Tests، Automation و Documentation هم‌زمان جلو می‌روند.
6. Foundation موازی برای Task/FollowUp/Search/Backup/Sync/Widget/Storage ممنوع است مگر audit مستقل آن را توجیه کند.
7. PR کوچک، بازسازی‌پذیر و با conflict surface محدود ترجیح دارد.
8. Documentation lane حق ندارد Production یا PRهای active validation را بی‌دلیل stale کند.

## Foundation فعلی

مسیر canonical محصول همچنان:

`Task / Unified Item → Reminder → FollowUps[] → History`

Home، Search، Today، FollowUp، Timeline، Reminder، Calendar، Backup، Settings، Widget و Report باید همین foundation را مصرف کنند.

Core/Data موجود شامل canonical Task persistence و Project portability در Backup است؛ بازطراحی storage یا افزودن Task model/store دوم برای RC مجاز نیست مگر audit تازه الزام کند.

## تحویل‌های اخیر تأییدشده در main

### Calendar — PR #575
- کنترل قابل‌مشاهده برای رفتن مستقیم به تاریخ جلالی اضافه شد.
- تغییر ماه/سال، روز نامعتبر را clamp می‌کند و state روز انتخاب‌شده هماهنگ می‌ماند.
- exact-head validation شامل Fast، Analyze/Test، هر دو APK و Home/People Device Smoke بوده است.

### AI Worker fallback — PR #574
- fallback بومی GitHub/Copilot برای Worker روی main ادغام شده است.
- boundary ابزار Copilot read-only باقی مانده و Worker حق merge مستقیم ندارد.

### Backup / Restore
- مسیر canonical Backup/Restore، encryption و Progress UI موجود است.
- تغییر جدید #580 فقط safety UX را هدف گرفته: قبل از جایگزینی داده محلی تأیید صریح لازم باشد و Cancel صفر mutation داشته باشد.

## PRهای فعال با اولویت واقعی

### #579 — AI Worker hardening
Head: `25f243617f95728ad323a034266b224ca52637fb`

- Fast/Parallel روی exact head موفق شده است.
- ARVIN Orchestrator و Production Loop روی PR event موفق بوده‌اند.
- Heavy Build و Device برای همان head به‌صورت workflow_dispatch فعال شده‌اند؛ تا تکمیل evidence نباید merge شود.
- Scope محدود به validation کامل unified diff، timeout/retry budget و کاهش latency provider است؛ هیچ product model/storage/UI را تغییر نمی‌دهد.

### #580 — Backup restore confirmation
Head فعلی: `1c562afa069c8abfbc8a2b24fdaadf75016a9f57`

- Draft و مستقل از #579 است.
- اولین Fast، فقط در surface Backup روی دو widget test جدید به `pumpAndSettle timeout` خورد؛ product logic failure گزارش نشد.
- تست به‌صورت محدود اصلاح شده و چون head عوض شده، evidence قبلی تاریخی است؛ exact-head Fast جدید لازم است.
- Merge فقط بعد از revalidation و سپس Heavy Build/Device انجام شود.

## Release Blockerهای واقعی فعلی

1. تکمیل exact-head Heavy evidence برای #579 و در صورت سبز بودن، merge سریالی و post-merge validation روی `main`.
2. revalidation کامل #580 روی head جدید؛ سپس Heavy evidence و merge فقط روی main تازه.
3. AI Worker هنوز باید در یک اجرای واقعی end-to-end ثابت کند Issue → patch معتبر → PR → CI را بدون دخالت دستی و بدون merge خودسرانه کامل می‌کند.
4. PRهای قدیمی با baseهای تاریخی (#539، #536، #526، #525 و laneهای قدیمی‌تر) نباید به‌عنوان evidence فعلی یا blocker خودکار حساب شوند؛ هرکدام قبل از promotion نیازمند rebuild/reconcile روی main جاری هستند.

## CI / Production Orchestrator

- Fast Lane: Draft PR → Parallel Wave؛ Heavy Build/Device در Draft عمداً skip می‌شود.
- Ready PR → Heavy Build + Device روی exact head.
- Build: quality/analyze/tests سپس APK debug/release مستقل.
- Device: Home و People smoke روی Android emulator.
- ARVIN Orchestrator و Production Loop باید فقط evidence همان PR/head را معتبر بدانند.
- `main` فعلی `eb52e32f...` بعد از Calendar merge دارای Production Loop موفق است.

## Calendar

- Calendar داخلی و پرش مستقیم به تاریخ جلالی روی main موجود و validate شده‌اند.
- External device/calendar sync یک موضوع جدا از Calendar UI داخلی است و نباید با «تقویم موجود نیست» اشتباه شود.
- هر Google/Samsung two-way sync فقط با audit تازه و reuse foundation موجود ادامه یابد.

## Documentation / Governance

- `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 مرجع اجرای Production است.
- این `PROJECT_STATUS.md` و `AI_HANDOFF_CURRENT_FA.md` فقط checkpoint زنده هستند و تاریخچه اسناد موضوعی قبلی حذف یا بازنویسی نمی‌شود.
- اگر در بازه بعدی تغییر معناداری در GitHub رخ ندهد، commit مستنداتی جدید ایجاد نشود.

## Definition of Done

قابلیت فقط وقتی Done است که مسیر canonical، UI/عملیات واقعی حسب نیاز، regression/E2E، CI دقیق، APK/device evidence و Status/Handoff همگرا باشند.

## Trigger ادامه

`ادامه آروین` یعنی:

`Fresh GitHub audit → reconcile docs → parallel independent work → exact-head validation → safe serial merge → post-merge validation → next smallest real gap → document in parallel → short nontechnical owner report`
