# Arvin-clean — Live AI Handoff

## مرجع حاکم

مرجع واحد اجرای پروژه `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 است. GitHub تنها Source of Truth عملیاتی است و این فایل فقط checkpoint فشرده برای ادامه سریع است.

## شروع هر ادامه

1. `main`، PRهای باز، Issueهای فعال، Head SHAها و workflowهای همان Head را تازه از GitHub بخوان.
2. این Handoff، `docs/PROJECT_STATUS.md` و scorecardها را با GitHub تطبیق بده؛ GitHub مقدم است.
3. قبل از ساخت foundation/model/storage جدید، implementation canonical موجود را بررسی کن.
4. Laneهای مستقل را موازی ادامه بده؛ یک blocker نباید کارهای مستقل را متوقف کند.
5. Merge فقط با exact-head evidence؛ بعد از Merge، main دوباره Build + Device validate شود.

## Live Checkpoint — 2026-08-27

Snapshot ممیزی این سند:

`cd7b823a0d96e657912e5beb953c4e4f93582679`

این main نتیجه Merge PR #268 است.

### تحویل‌های Merge‌شده تازه

- #261/#265/#266/#262/#263/#273 — موج Daily Content تا cache محدود و validate‌شده
- #268 — انتخاب `یادداشت ساده` / `چک‌لیست` در Notebook روی همان canonical Task

### evidence تازه

- #268 exact head: Parallel #788 ✅ / Build #892 ✅ Release+Debug APK / Device #138 ✅
- post-#268 main: Build #894 ✅ Release+Debug APK / Device #140 ✅

## امتیاز رسمی

تا زمانی که scorecard Merge‌شده خلاف آن را ثابت نکرده است:

- Project A-H: **70.0%**
- Extension: **25.0% overall**
- Wave X1: **59.4%**

کار Merge‌نشده هیچ امتیاز رسمی اضافه نمی‌کند.

## Laneهای موازی فعال

### 1. Quick checklist templates — PR #281 / Issue #270

- base: post-#268 main `cd7b823...`
- Draft exact head در زمان این checkpoint: `7dd8699d9f66afbba2edf7d8ff99f06a82f3b4db`
- presetها: `لیست خرید`، `وسایل سفر`، `کارهای امروز`، `چک‌لیست جدید`
- starterها بلافاصله ordinary `Task.checklist` می‌شوند.
- rename/remove/check/add برای همه checklistهای Notebook فعال شده است؛ رفتار template-only وجود ندارد.
- هیچ model/database/key/migration/backup format جدیدی ساخته نشده است.
- Draft Build/Device skip می‌شوند؛ Parallel #792 Fast Lane را validate می‌کند.
- بعد از Fast CI سبز: Ready → Build + Device دقیق → final main/head lock → Merge → post-merge main validation.

### 2. Live documentation — PR #277 / Issue #276

این سه سند current-state روی main فعلی بازسازی شده‌اند. PR عمداً Draft می‌ماند تا Lane محصول #281 settle شود؛ سپس یک reconcile نهایی و validation انجام می‌شود.

### 3. CI automation hardening — Issue #278

هدف: وقتی main در میانه heavy PR gate جلو می‌رود، runهای سنگین pull_request که base آن‌ها stale شده است هدفمند لغو شوند؛ بدون serialization سراسری، rebase خودکار یا تضعیف exact-head gate.

### 4. Daily Content continuation — Issue #260

Laneهای continuation مستقل باقی می‌مانند و Merge آن‌ها باید فقط پس از fresh base audit و exact-head validation انجام شود. CI تاریخی evidence Merge نیست.

## Product/Foundation Invariants

- Flutter فارسی و RTL-first.
- foundation canonical: `Task / Unified Item → Reminder → FollowUps[] → History`.
- Notebook فقط از `CanonicalNotebookRepository → Task.checklist → TaskStore` استفاده می‌کند.
- Home/Search/Today/Timeline/FollowUp/Calendar/Backup/Settings/Widget/PDF باید foundationهای مشترک موجود را مصرف کنند.
- Foundation یا storage موازی بدون audit مستقل ممنوع است.

## Fast Lane Contract

- Draft PR → Parallel Wave؛ heavy Build/Device jobها skip.
- Ready PR → Build + Device.
- Build → quality مشترک سپس Release/Debug APK موازی.
- exact-head SHA و current main بلافاصله قبل از Merge دوباره بررسی می‌شوند.
- CI روی SHA یا base قدیمی evidence Merge نیست.
- بعد از Merge، Build + Device روی main جدید الزامی است.

## Trigger ادامه

`ادامه آروین` یعنی:

`Fresh GitHub audit → reconcile current docs → parallel independent execution → exact-head validation → safe merge → post-merge validation → next real vertical slice → document → short nontechnical owner report`

Repository reality همیشه از conversation memory مقدم است.
