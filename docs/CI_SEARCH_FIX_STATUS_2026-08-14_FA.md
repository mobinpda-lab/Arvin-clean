# گزارش Validation جستجو — ۱۴۰۵/۰۵/۲۳

## وضعیت

Run `31824305634` در مرحله `flutter analyze` روی تست Search شکست خورد. خطا از fixture تست بود و نه از منطق Search.

### خطا

- `const_with_non_const`
- `non_constant_list_element`

علت: استفاده از `const FollowUp` در حالی که سازنده/fixture آن در این مسیر برای const مناسب نبود.

## اقدام اصلاحی

در branch مربوط به Search فقط fixture تست اصلاح شد:

- `const FollowUp(...)` → `FollowUp(...)`
- منطق `TaskSearchService` تغییر نکرد.
- مدل Task تغییر نکرد.
- Calendar / Notebook / Backup / Dropbox / Google Calendar دست‌کاری نشدند.

Commit اصلاحی:

`16e7a7a8ba82971e5ad939898106cb83df0bb321`

## Guardrail

این خطا نباید با بازنویسی Search یا تغییر مدل داده حل شود. قبل از هر اقدام بعدی باید CI جدید بررسی شود و اگر سبز است، این مورد بسته تلقی شود و دوباره‌کاری نشود.

## مسیر بعدی

بعد از سبزشدن Search، Wave بعدی باید فقط در صورت نبودن قابلیت مشابه در کد فعلی، Search UI را به Home/FollowUp متصل کند. Calendar و Notebook تا زمان رسیدن به Integration Gate مستقل باقی می‌مانند.

## قانون دائمی پروژه

قبل از هر تغییر:

1. وضعیت `main` بررسی شود.
2. PRهای باز بررسی شوند.
3. کد و تست واقعی بررسی شوند.
4. مستندات و تصمیم‌های محصولی بررسی شوند.
5. خطاهای CI اخیر با وضعیت فعلی مقایسه شوند.
6. اگر قابلیت/خطا قبلاً حل شده، هیچ Commit جدیدی برای تکرار آن ساخته نشود.
7. Waveهای مستقل تا جای ممکن با Commit و Workflow موازی Validation شوند.
