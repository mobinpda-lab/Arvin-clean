# Wave جستجوی سراسری — ۱۴۰۵/۰۵/۲۳

## دلیل اجرا

بازنگری Product Requirements آروین مشخص کرد که جستجو باید در همه بخش‌های مرتبط با داده‌های کاری قابل استفاده باشد. قبل از این Wave، در PRهای باز Wave مستقلی برای زیرساخت Search وجود نداشت.

## Scope

این Wave فقط زیرساخت pure search را اضافه می‌کند:

- عنوان Task
- توضیحات Task
- Tagها
- متن FollowUp
- نتیجه FollowUp
- جستجوی case-insensitive
- حذف فاصله‌های ابتدا/انتهای query

## خارج از Scope

- UI نهایی Search
- تغییر Calendar
- تغییر Google Calendar
- تغییر Dropbox/Backup
- تغییر Notebook
- تغییر مدل Task

## Guardrail

این سرویس به persistence یا UI وابسته نیست تا در Waveهای بعدی بتوان آن را به Home، FollowUp Office و Search UI متصل کرد بدون بازنویسی منطق جستجو.

## Validation

برای رفتارهای اصلی تست focused اضافه شده است. Workflowهای Build و Parallel Wave باید مستقل از سایر Waveها این Commit را اعتبارسنجی کنند.

## وضعیت بعدی

Wave بعدی می‌تواند Search UI را به Home متصل کند و سپس جستجوی Notebook را با یک adapter جدا اضافه کند؛ بدون تغییر قرارداد جستجوی Task/FollowUp.
