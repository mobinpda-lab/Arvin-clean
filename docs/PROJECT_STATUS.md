# Arvin — Project Status

## وضعیت زنده — 2026-08-27

GitHub تنها Source of Truth عملیاتی پروژه است. هر SHA، PR، CI، درصد یا وضعیت باید قبل از اقدام دوباره از GitHub تازه بررسی شود.

- Branch مرجع: `main`
- snapshot مبنا: `bec99214534a8c9972f9e3145dde792cecf2f9e3`
- آخرین Merge: PR #245 — audit مرز canonical Privacy / Encryption
- Mergeهای مهم همین موج: #243 deterministic Device lane، #242 Semantic Search v1، #247 parallel APK Build، #245 Privacy audit
- post-#242 main: Build #829 ✅ / Device #69 ✅
- post-#247 main: Build #832 ✅ / Device #72 ✅
- #245 exact head: Parallel #754 ✅ / Build #834 ✅ / Device #74 ✅
- post-#245 main: Build #835 و Device Smoke بعد از Merge فعال شده‌اند و باید قبل از ادعای post-merge green دوباره خوانده شوند.
- Project A-H: **70.0%**
- Extension roadmap: **25.0% overall / 59.4% Wave X1**

## قرارداد اجرای سریع

هدف، تحویل در چند ساعت به‌جای چند روز است، بدون قربانی‌کردن صحت:

1. Audit زنده GitHub قبل از تصمیم.
2. Laneهای مستقل هم‌زمان؛ Block یک Lane نباید بقیه را متوقف کند.
3. Merge فقط با evidence همان Head SHA.
4. بعد از Merge، `main` دوباره Build + Device Smoke می‌شود.
5. Implementation، Tests، Automation و Documentation هم‌زمان جلو می‌روند.
6. Foundation موازی برای Task/FollowUp/Search/Backup/Sync/Widget/Storage ممنوع است مگر audit مستقل آن را توجیه کند.
7. PR کوچک، بازسازی‌پذیر و با conflict surface محدود ترجیح دارد.

## Foundation فعلی

مسیر canonical محصول همچنان:

`Task / Unified Item → Reminder → FollowUps[] → History`

Home، Search، Today، FollowUp، Timeline، Reminder، Calendar، Backup، Settings، Widget و Report باید همین foundation را مصرف کنند.

## تحویل‌های اخیر

### Semantic Search v1 — PR #242
- روی `TaskSearchService` موجود ادغام شد؛ Search engine/UI/index/database دوم ساخته نشد.
- aliasهای محدود فارسی با OR داخل گروه و AND بین termها.
- exact-head: Parallel #751 / Build #826 / Device #66 ✅
- post-merge: Build #829 / Device #69 ✅
- Issue #241 بسته شد.

### Deterministic Device validation — PR #243
- مسیر `device/**` برای exact-ref Device Smoke اضافه شد.
- API/automation دیگر برای smoke دقیق به delivery اتفاقی PR event وابسته نیست.

### Faster Build — PR #247
- Analyze/tests یک بار در `quality` اجرا می‌شوند.
- Release و Debug APK بعد از آن به‌صورت matrix مستقل و موازی ساخته/verify/upload می‌شوند.
- exact-head: Parallel #753 / Build #831 / Device #71 ✅
- post-merge: Build #832 / Device #72 ✅

### Privacy / Encryption boundary — PR #245
- مرز امن اولین implementation روی همان portable backup bytes موجود تعریف شد.
- legacy plaintext v1 باید قابل خواندن بماند.
- encrypted envelope آینده باید versioned و authenticated باشد.
- local TaskStore encryption و multi-device sync عمداً از این slice جدا نگه داشته شدند.
- credential/token نباید وارد portable Settings/backup شود؛ regression اجرایی دارد.
- Issue #248 قدم بعدی implementation را بدون شروع premature code ثبت کرده است.

## Score رسمی

### Project gates A-H
A=70, B=70, C=70, D=70, E=70, F=70, G=70, H=70 → **70.0%**.

رسیدن به 85/100 هنوز به physical-device/E2E و closureهای تعریف‌شده در scorecard وابسته است؛ emulator/CI به‌تنهایی باعث افزایش مصنوعی نمی‌شود.

### Extension roadmap
- Semantic Search: **85**
- Privacy / Encryption: **10** (audit؛ implementation هنوز شروع نشده)
- Overall: **25.0%**
- Wave X1: **59.4%**

## Laneهای بعدی

1. بستن post-merge Build/Device روی main فعلی.
2. Merge کردن همین refresh مستندات پس از Progress Score + Fast Lane دقیق.
3. سپس Issue #248: prototype کوچک encrypted backup envelope روی همان `ArvinBackupService`؛ legacy-v1 read + authenticated-failure tests، بدون local TaskStore encryption یا Sync موازی.
4. انتخاب Gap محصولی بعدی فقط بعد از audit زنده backlog/roadmap.

## Definition of Done

قابلیت فقط وقتی Done است که مسیر canonical، UI/عملیات واقعی حسب نیاز، regression/E2E، CI دقیق، APK/device evidence و Status/Handoff همگرا باشند.

## Trigger ادامه

`ادامه آروین` یعنی:

`Fresh GitHub audit → reconcile docs → parallel independent work → exact-head validation → safe merge → post-merge validation → next smallest real gap → document → short nontechnical owner report`
