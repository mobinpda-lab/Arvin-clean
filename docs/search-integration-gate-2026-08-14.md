# دروازه ادغام Search — بازنگری قبل از تغییر محصول

تاریخ: ۱۴۰۵/۰۵/۲۳

## نتیجه بررسی

Wave زیرساخت Search در PR #67 اکنون از نظر CI سبز شده است و دیگر نباید همان خطاهای تستی قبلی دوباره اصلاح شوند.

## نکته معماری مهم

`TaskSearchService` روی مدل جدید `lib/models/task.dart` کار می‌کند و علاوه بر عنوان، توضیحات و Tag، متن و نتیجه FollowUp را نیز جستجو می‌کند.

اما `lib/main.dart` هنوز از مدل legacy به نام `ArvinTask` و `TaskRepository` مستقل استفاده می‌کند. این HomePage در حال حاضر جستجوی محلی خود را فقط روی title/description/tags انجام می‌دهد.

بنابراین اتصال مستقیم SearchService به HomePage بدون یکپارچه‌سازی مدل‌ها، خطر ایجاد دو منبع حقیقت، از دست رفتن FollowUpها یا تغییر ناخواسته persistence را دارد.

## تصمیم

فعلاً SearchService دوباره‌نویسی یا کپی نمی‌شود.

Wave بعدی باید یک **Integration Gate** باشد:

1. مقایسه `ArvinTask` با `models.Task`.
2. بررسی `TaskStore` و repositoryهای FollowUp.
3. مشخص‌کردن منبع حقیقت نهایی برای Task/FollowUp.
4. تعریف migration/compatibility برای داده‌های `arvin.tasks`.
5. فقط پس از تأیید این Contract، اتصال HomePage به SearchService.
6. سپس Search UI و جستجوی واقعی FollowUp در Home.

## چیزهایی که نباید دوباره ساخته شوند

- SearchService مستقل
- FollowUpRepository
- Calendar
- Backup/Dropbox
- Simple Notebook

این اجزا قبلاً پایه یا Wave مستقل دارند و قبل از تغییر باید همان کدهای موجود بررسی شوند.

## وضعیت CI مشاهده‌شده

در Run قدیمی #283، Analyze سبز بود و فقط تست `empty query preserves task order` شکست خورد. این مورد در Head بعدی PR #67 اصلاح شده و Runهای مربوط به Head فعلی سبز هستند.

همچنین در همان Run قدیمی، تست‌های Calendar، FollowUp، Backup و Dropbox سبز بودند؛ بنابراین هیچ تغییر مجددی در این بخش‌ها انجام نمی‌شود.

## قانون ادامه

هر Commit محصولی بعدی باید قبل از تغییر:

- main و PRهای باز را بررسی کند؛
- کد واقعی را با Product Requirements و AI Handoff مقایسه کند؛
- قابلیت حل‌شده را دوباره پیاده‌سازی نکند؛
- تست focused داشته باشد؛
- مستندات تصمیم و نتیجه CI را به‌روزرسانی کند؛
- و Workflowهای مستقل را موازی اجرا کند.
