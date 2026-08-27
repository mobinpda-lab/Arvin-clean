# Arvin — Project Status

## وضعیت زنده — 2026-08-27

GitHub تنها Source of Truth عملیاتی پروژه است. هر SHA، PR، CI، درصد یا وضعیت باید قبل از اقدام دوباره از GitHub تازه بررسی شود.

- Branch مرجع: `main`
- snapshot ممیزی این سند: `cd7b823a0d96e657912e5beb953c4e4f93582679`
- آخرین Merge: PR #268 — انتخاب `یادداشت ساده` / `چک‌لیست` در Notebook
- #268 exact-head: Parallel #788 ✅ / Build #892 ✅ Release+Debug APK / Device #138 ✅
- post-#268 main: Build #894 ✅ Release+Debug APK / Device #140 ✅
- Project A-H: **70.0%**
- Extension roadmap: **25.0% overall / 59.4% Wave X1**

## قرارداد اجرای سریع

هدف تحویل معتبر در چند ساعت به‌جای چند روز است:

1. Audit زنده GitHub قبل از تصمیم.
2. Laneهای مستقل هم‌زمان؛ Block یک Lane نباید بقیه را متوقف کند.
3. Merge فقط با evidence همان exact Head SHA و current base.
4. بعد از Merge، `main` دوباره Build + Device Smoke می‌شود.
5. Implementation، Tests، Automation و Documentation هم‌زمان جلو می‌روند.
6. Foundation موازی برای Task/FollowUp/Search/Backup/Sync/Widget/Storage ممنوع است مگر audit مستقل آن را توجیه کند.
7. PR کوچک، بازسازی‌پذیر و با conflict surface محدود ترجیح دارد.

## Foundation فعلی

مسیر canonical محصول:

`Task / Unified Item → Reminder → FollowUps[] → History`

Notebook نیز فقط از مسیر:

`NotebookPage → CanonicalNotebookRepository → Task.checklist → TaskStore`

استفاده می‌کند.

## تحویل‌های Merge‌شده اخیر

### Notebook create mode — #268

- ساخت یادداشت اکنون `یادداشت ساده` یا `چک‌لیست` را پیشنهاد می‌دهد.
- checklist mode روی همان `Task.checklist` باز می‌شود و input را focus می‌کند.
- cancel هیچ Taskی ایجاد نمی‌کند.
- storage/model/database جدید ساخته نشده است.
- exact-head و post-merge Build/Device کامل سبز هستند.

### Daily Content wave — Issue #260

- #261 — foundation
- #265 — preferences
- #266 — notification sink
- #262 — Calendar card
- #263 — pack codec
- #273 — bounded local cache

Provider/network production هنوز باید source/license gate و validation/cache موجود را رعایت کند.

### Semantic Search / CI foundations

- #242 — Semantic Search v1 روی `TaskSearchService` موجود
- #243 — deterministic `device/**` exact-ref smoke fallback
- #247 — shared quality + Release/Debug APK parallel Build

## Laneهای فعال

### Quick checklist templates — PR #281 / Issue #270

- base: `cd7b823...`
- Draft head در زمان این snapshot: `7dd8699d9f66afbba2edf7d8ff99f06a82f3b4db`
- presetها: `لیست خرید | وسایل سفر | کارهای امروز | چک‌لیست جدید`
- shopping/travel starter items canonical و قابل rename/remove/check/add هستند.
- today/blank خالی شروع می‌شوند و input فوری focus می‌شود.
- هیچ template entity، storage key یا migration جدیدی وجود ندارد.
- Draft Build/Device jobها skip و Parallel #792 Fast Lane را اجرا می‌کند.

### Documentation — PR #277 / Issue #276

Live Handoff/Status روی post-#268 main بازسازی شده‌اند. PR تا settle شدن #281 Draft می‌ماند و سپس یک reconcile نهایی می‌شود.

### Automation hardening — Issue #278

هدف جلوگیری از هدررفت Runner روی heavy PR gateهایی است که با جلو رفتن main stale می‌شوند؛ بدون تضعیف exact-head/current-base rule.

## Score رسمی

### Project gates A-H

A=70, B=70, C=70, D=70, E=70, F=70, G=70, H=70 → **70.0%**.

### Extension roadmap

- Overall: **25.0%**
- Wave X1: **59.4%**

PR باز یا work-in-progress امتیاز رسمی ایجاد نمی‌کند.

## نزدیک‌ترین ترتیب تحویل

1. بستن Fast CI #281.
2. اگر سبز: Ready و full Build + Device روی exact head.
3. قفل مجدد current main/head و Merge فقط اگر evidence هنوز معتبر باشد.
4. post-merge Build + Device روی main جدید.
5. reconcile نهایی #277 و validation/merge مستندات.
6. اجرای مستقل automation hardening #278 و بازکردن Lane بعدی پس از fresh audit.

## Definition of Done

قابلیت فقط وقتی Done است که implementation canonical، تست، CI دقیق، APK/device evidence حسب نیاز، integration امن و current-state docs با واقعیت GitHub همگرا باشند.

## Trigger ادامه

`ادامه آروین` یعنی:

`Fresh GitHub audit → reconcile docs → parallel independent work → exact-head validation → safe merge → post-merge validation → next smallest real gap → document → short nontechnical owner report`
