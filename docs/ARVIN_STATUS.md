# Arvin — Current Management Status

## مرجع
قوانین کامل پروژه در `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 است. GitHub زنده مرجع نهایی وضعیت اجرایی است.

## وضعیت ثبت‌شده — 2026-08-26
- `main`: `21fc74cf6db7e6f9b9feffd0ab94a1cbd056c3de`
- PR #189 FollowUp write/reschedule: Merge شده؛ exact-head Build #652 و Parallel #469 سبز بودند.
- Build پس از Merge #189: #654 در زمان ثبت این Snapshot در حال اجرا بود.
- PR #190 Next Action UI: روی `main` جدید بازسازی شده؛ exact head `db64b37f816f8814563f5a20e7445eb56caf4abf`؛ Build #655 و Parallel #471 در حال اجرا بودند.
- Lane مستندسازی: `docs/current-state-audit-2026-08-26`، مستقل از Product Lane.

## نتیجه Audit مستندات
- v49.0 تنها مرجع فعال حاکمیتی است.
- v48.x، Snapshotها، Changelogها و Waveهای تاریخ‌دار سابقه هستند.
- چند Current-State قدیمی با GitHub امروز همگام نبودند و در Lane مستندسازی اصلاح می‌شوند.
- قرارداد قدیمی Notebook با Storage مستقل با Unified Item تعارض داشت؛ مسیر اجرایی فعلی Storage/Repository مستقل Note را ممنوع می‌کند.
- درصدهای دستی تاریخی مثل 61٪ رسمی نیستند.

## معماری محافظت‌شده
- Unified Item/Task + Reminder + FollowUps[] + History.
- `arvin.tasks` مسیر اصلی داده است مگر Migration رسمی آن را تغییر دهد.
- هیچ Model/Repository/Storage/Search/Calendar/Scheduler/Router موازی ساخته نمی‌شود.
- UI فارسی و RTL و طراحی مصوب حفظ می‌شود.

## وضعیت محصول
- Automatic FollowUp تا مسیر Scheduler و reschedule پس از write واقعی جلو رفته؛ ارتقای Score فقط پس از شواهد Post-merge و PR رسمی Scorecard.
- Timeline ورودی واقعی محصول دارد.
- Next Action در PR #190 در حال اعتبارسنجی UI واقعی است.
- Quick Capture مسیر واقعی Home دارد.
- تعطیلات رسمی ۱۴۰۵ در Calendar موجود است؛ Prayer Times معتبر هنوز Gap است.
- Recurrence foundation موجود است؛ UI کامل باقی است.
- Widget/Lock Screen قبل از کار جدید باید با کد فعلی دوباره Audit شود.

## درصد رسمی
دو عدد جدا داریم و با هم ترکیب نمی‌شوند:
- کل آروین: فقط از `docs/project_completion_scorecard.json` روی `main`.
- Extension 19-feature: فقط از `docs/progress_scorecard.json` روی `main`.
هر تغییر درصد باید Evidence-backed و از مسیر PR + Automation باشد.

## روش اجرا
کارهای مستقل موازی، کارهای وابسته ترتیبی، CI دقیق Head، Merge کنترل‌شده، Build پس از Merge و مستندسازی همزمان. هیچ موفقیت یا درصدی بدون Evidence اعلام نمی‌شود.

## قدم بعد
ابتدا #654 و CI تازه #190 بسته شوند؛ سپس #190 در صورت سبز بودن Merge و روی `main` دوباره Build شود. بعد Scorecard و این Snapshot روی Evidence نهایی همان main همگام می‌شوند.
