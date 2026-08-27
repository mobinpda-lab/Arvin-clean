# Arvin — Current Management Status

## مرجع

این فایل snapshot مدیریتی فشرده است. قواعد کامل و حاکم پروژه در `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 قرار دارد و GitHub واقعیت عملیاتی را تعیین می‌کند.

## وضعیت فعلی — 2026-08-27

- `main = cd7b823a0d96e657912e5beb953c4e4f93582679`
- PR #268 Notebook create mode Merge شده است.
- #268 exact-head: Parallel #788 ✅ / Build #892 ✅ / Device #138 ✅
- post-merge main: Build #894 ✅ Release+Debug APK / Device #140 ✅
- موج Daily Content تا #273 روی main ادغام شده است.
- امتیاز رسمی بدون افزایش مصنوعی: **Project 70.0% | Extension 25.0% | Wave X1 59.4%**.

## کار عملی فعال

### PR #281 — Quick checklist templates

- Issue #270
- presetها: `لیست خرید`، `وسایل سفر`، `کارهای امروز`، `چک‌لیست جدید`
- starterها همان `Task.checklist` هستند و رفتار ویژه بعد از creation ندارند.
- rename/remove/check/add برای همه checklistهای Notebook فعال شده است.
- Draft head هنگام این snapshot: `7dd8699d9f66afbba2edf7d8ff99f06a82f3b4db`
- Draft Heavy Build/Device skip؛ Parallel #792 Fast CI را اجرا می‌کند.
- بعد از Fast CI سبز: Ready → full exact-head gates → final current-main/head lock → Merge → post-merge validation.

### PR #277 — Live documentation refresh

سه سند current-state روی post-#268 main بازسازی شده‌اند. این Lane عمداً Draft می‌ماند تا #281 settle شود و سپس یک reconcile نهایی دریافت کند.

### Issue #278 — CI stale-gate cancellation

اتوماسیون بعدی برای کاهش هدررفت Runner: فقط heavy pull_request gateهایی که بعد از جلو رفتن main base قدیمی دارند هدفمند لغو شوند. هیچ rebase/merge خودکار یا serialization سراسری مجاز نیست.

## قواعد کاری

- Lane مستقل را موازی اجرا کن.
- قابلیت موجود را دوباره نساز.
- CI روی SHA/base قدیمی evidence Merge نیست.
- هیچ PR باز یا work-in-progress درصد رسمی اضافه نمی‌کند.
- Merge → post-merge Build + Device → سپس Lane وابسته بعدی.
- Architecture، data، Sync، UI، security، recovery و evidence باید حفظ شوند.

## گزارش مدیریتی

`کجا هستیم | چه انجام شد | وضعیت | مدرک | مانع | قدم بعد`

گزارش‌ها کوتاه، قابل کپی و تا حد ممکن غیر فنی باشند.

## ادامه

`ادامه` یعنی GitHub زنده دوباره audit شود و نزدیک‌ترین کار ناتمام واقعی با مدل موازی و کنترل‌شده ادامه پیدا کند؛ نه اینکه وضعیت قدیمی حدس زده شود.
