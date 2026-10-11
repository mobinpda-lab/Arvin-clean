# Arvin-clean — Progress Log — 2026-08-15

## هدف این سند
این فایل لاگ فشرده و قابل انتقال از آخرین وضعیت عملیاتی پروژه است تا در جلسات بعدی یا توسط هوش مصنوعی دیگر، سابقه نزدیک و تصمیم‌های اجرایی بدون حدس ادامه داده شود.

## Audit مبنا
- `main` و `docs/PROJECT_STATUS.md` و `docs/AI_HANDOFF_CURRENT_FA.md` و `docs/QUICK_FOLLOWUP_WIDGET_AUDIT_2026-08-15.md` بررسی شدند.
- مدل فعلی Unified Item در `lib/models/task.dart` تأیید شد؛ `Task` دارای `FollowUps[]`، `Category`، `Tags` و `Reminder` است و `lastFollowUp` نیز از همان داده اصلی محاسبه می‌شود.
- Quick FollowUp Widget باید همان source of truth را مصرف کند و Storage موازی نداشته باشد.
- Audit قبلی Android نشان داده بود که native AppWidgetProvider/RemoteViews فعلی در مخزن وجود ندارد؛ بنابراین ساخت Widget محصولی مستقل ممنوع است و ابتدا foundation مشترک لازم است.

## CI فعلی
آخرین Build مربوط به merge PR #81 با SHA `abe1be6d9d655742a5e471f3622c53e5bbb69530` در زمان این ثبت هنوز `in_progress` بود. نتیجه آن نباید حدس زده شود.

## تصمیم اجرایی فعلی
1. تا روشن شدن نتیجه Build جاری، تغییر وابسته به foundation مشترک انجام نشود.
2. پس از CI، Android Widget Foundation فقط در صورت وجود Gap واقعی و با حداقل تغییر ایجاد شود.
3. سپس Quick FollowUp Widget به‌صورت commit مستقل روی foundation مشترک پیاده شود.
4. Calendar Providerهای رسمی ایران و UX ثبت سریع FollowUp به‌عنوان Laneهای مستقل می‌توانند موازی آماده‌سازی/تست شوند، مشروط به اینکه foundation مشترک را تغییر ندهند.

## قرارداد Quick FollowUp Widget
- عنوان کار
- تیتر/متن کوتاه آخرین FollowUp
- تاریخ و ساعت در یک خط: `تاریخ | ساعت`
- لیست چندموردی با اسکرول عمودی
- لمس هر ردیف → همان Item
- Category و امکانات سازگار Widget اصلی
- RTL و فونت اصلی
- بدون Storage/Database جدا
- Lock Screen در صورت پشتیبانی، با fallback مناسب
- نمایش آخرین FollowUp، نه Reminder بعدی

## سناریوی رسمی محصول
`Item → + ثبت پیگیری → متن → ذخیره`

پیگیری‌های متعدد باید در همان Item ثبت شوند و در صورت نیاز برای مرحله بعد `Next FollowUp / Reminder` تعیین شود.

## قانون دائمی اجرا
`Audit کل پروژه → Gap واقعی → تغییر حداقلی → تست focused → Commit مستقل → Build + Parallel Workflow → بررسی نتیجه → مستندسازی`

اگر قابلیت قبلاً وجود داشته باشد، دوباره ساخته نمی‌شود.
