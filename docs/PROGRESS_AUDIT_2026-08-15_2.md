# Arvin-clean — Progress Audit 2026-08-15 (2)

## هدف
این سند یک snapshot قابل انتقال برای ادامه توسعه است و جایگزین foundation یا مستندات قبلی نیست.

## وضعیت مبنا
- Branch مرجع: `main`
- آخرین Build موفق روی `main`: Build #325 برای commit `e22172611ea8f222f5b99739fecd23a946c23938`.
- PR #82 روی branch `wave/2026-08-15-current-audit` در حال اجرای Build #326 و Parallel Wave #190 است؛ نتیجه این اجرا تا زمان ثبت این snapshot نباید حدس زده شود.
- PR/Workflowهای قدیمی شکست‌خورده مربوط به refهای قدیمی هستند و نباید به‌عنوان وضعیت فعلی `main` تفسیر شوند.

## گلوگاه‌های واقعی
1. Unified Item / Legacy boundary — foundation موجود است؛ تکمیل adapter/migration بدون مسیر داده موازی.
2. Calendar رسمی ایران — CalendarReminder و قرارداد Source/Mapping تثبیت شده؛ Provider واقعی اوقات شرعی شیعه و تعطیلات رسمی ایران باقی است.
3. Widget Foundation — native AppWidgetProvider/RemoteViews یا راهکار native معادل هنوز در `main` تثبیت نشده؛ Widget اصلی و Quick FollowUp باید روی یک foundation مشترک ساخته شوند.
4. FollowUp UX — سناریوی ثبت سریع چند پیگیری برای یک Item باید با کمترین کلیک و بدون storage موازی تکمیل و E2E شود.

## Quick FollowUp Widget — قرارداد نهایی
- عنوان کار
- متن/تیتر کوتاه آخرین FollowUp
- تاریخ و ساعت آخرین FollowUp در یک خط
- لیست عمودی قابل اسکرول
- بازکردن همان Item با لمس
- Category و امکانات سازگار Widget اصلی
- RTL و فونت اصلی
- بدون Database/Storage جدا
- استفاده از source of truth Item/FollowUp
- Lock Screen در صورت پشتیبانی Android و fallback در دستگاه فاقد پشتیبانی
- نمایش آخرین FollowUp، نه Reminder بعدی

## برنامه موازی
- Lane A: Unified Item adapter/migration
- Lane B: Calendar Providerهای رسمی ایران
- Lane C: Notebook UI
- Lane D: Home/Search و ثبت سریع FollowUp
- Lane E: Widget Foundation → Widget اصلی → Quick FollowUp → Lock Screen
- Lane F: PDF/Print/IranSans
- Lane G: Reminder/Google Calendar
- Lane H: Backup/Dropbox
- Lane I: E2E/Release

Laneها فقط در صورت عدم تداخل با foundation مشترک موازی می‌شوند.

## برآورد محافظه‌کارانه پیشرفت
| Lane | درصد |
|---|---:|
| Unified Item / Architecture | 80% |
| Notebook | 65% |
| FollowUp | 70% |
| Home / Search | 55% |
| Calendar Foundation | 70% |
| Official Iran Calendar Providers | 35% |
| Widget / Lock Screen | 40% |
| PDF / Print / Share | 50% |
| IranSans | 40% |
| Backup / Dropbox | 55% |
| Reminder / Google Calendar | 45% |
| E2E / APK Release | 45% |

**پیشرفت کلی فعلی: حدود 61%**

این عدد تا وقتی قابلیت محصولی به Definition of Done نرسیده افزایش داده نمی‌شود.

## قانون اجرا
`Audit کل پروژه → Gap واقعی → تغییر حداقلی → Commit → Build + Parallel → بررسی CI → مستندسازی + AI Handoff`

هیچ تست، مدل، storage یا foundation موجودی صرفاً برای سرعت دوباره ساخته نشود.
