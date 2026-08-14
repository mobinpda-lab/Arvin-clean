# Arvin — Accelerated Project Roadmap 2026-08-14

## هدف
تکمیل سریع اما کنترل‌شده `Arvin-clean` تا رسیدن به APK واقعی، پایدار، فارسی، شمسی و RTL؛ بدون بازسازی foundationهای موجود و بدون ایجاد مسیر داده موازی.

## قانون اجرای همه Waveها
قبل از هر تغییر:
1. بررسی `main` و آخرین commit.
2. بررسی کد واقعی مرتبط.
3. بررسی PRهای باز و CI اخیر.
4. بررسی مستندات و سابقه تصمیم‌ها.
5. در صورت نیاز مقایسه با پروژه‌های مرجع.
6. فقط Gap واقعی تغییر می‌کند.
7. قابلیت حل‌شده دوباره ساخته نمی‌شود.

بعد از تغییر:
- تست focused و regression.
- Commit مستقل و قابل ردیابی.
- اجرای Build و Workflowهای validation مرتبط بلافاصله.
- بررسی نتیجه CI قبل از ادامه Wave وابسته.
- ثبت تصمیم، تغییر، نتیجه تست و وضعیت CI در مستندات.

## برنامه موازی کنترل‌شده
Waveها فقط وقتی موازی اجرا می‌شوند که وابستگی داده‌ای/معماری آنها اجازه دهد. هیچ Wave موازی حق تغییر یک foundation مشترک بدون هماهنگی با Wave اصلی را ندارد.

### Lane A — Architecture / Unified Item
**اولویت: فوری**
- تثبیت `Task` به‌عنوان مدل Item مشترک.
- بررسی دقیق `ArvinTask / TaskRepository` و تعیین adapter/migration حداقلی.
- حفظ migration داده‌های قدیمی.
- حذف تدریجی وابستگی‌های Legacy فقط پس از تست و بدون شکستن UI موجود.

### Lane B — Simple Notebook UI
**پس از تثبیت Contract مدل، با بیشترین سرعت قابل انجام**
- Editor واقعی.
- Auto-save.
- Read-only بعد از خروج.
- Edit صریح.
- Checklist.
- Settings integration.
- timestamp داخلی و جدا از Calendar.

### Lane C — Home / Search preparation
- طراحی اتصال Home به Unified Item پس از تثبیت adapter.
- اتصال Search UI فقط به مسیر نهایی Item/Home و SearchService موجود.
- Sort، Swipe، Multi-select، Archive/Trash بدون repository موازی.

### Lane D — Widget
- استفاده از همان source of truth Item/Reminder/FollowUp.
- Today/Future/Overdue/Category فقط در صورت وجود واقعی مدل.
- Quick Add و open-item.
- RTL و IranSans.
- بررسی واقعی پشتیبانی Lock Screen و graceful fallback برای دستگاه‌های فاقد پشتیبانی.
- بدون Storage جدا.

### Lane E — Output
- PDF Item + FollowUps.
- PDF list.
- Share.
- Print برای Note ساده و Item پیگیری‌دار.
- حفظ RTL، شمسی و فونت مورد توافق.

### Lane F — Integrations
پس از تثبیت مدل و UI:
- Reminder / Google Calendar فقط برای eventهای مجاز.
- Note timestamp هرگز به Calendar منتقل نشود.
- Backup/Restore End-to-End.
- Dropbox provider موجود تکمیل شود، نه بازسازی.

## ترتیب Gateهای اصلی
1. **Gate A:** Unified Item + adapter/migration + regression.
2. **Gate B:** Notebook UI قابل استفاده و persistence واقعی.
3. **Gate C:** Home + Search روی مسیر نهایی Item.
4. **Gate D:** Widget + Lock Screen validation.
5. **Gate E:** PDF + Print + IranSans.
6. **Gate F:** Reminder/Calendar + Backup/Dropbox.
7. **Gate G:** E2E، APK release، artifact و تست واقعی دستگاه.

## معیار سرعت
سرعت به معنی تغییرات بیشتر نیست؛ معیار سرعت این است که هر commit یک Gap مشخص را ببندد، CI آن سریعاً اجرا شود و Wave بعدی بدون انتظار غیرضروری برای حوزه‌های مستقل آغاز شود.

## معیار توقف
اگر CI قرمز شود، توسعه قابلیت جدید در همان مسیر متوقف می‌شود و ابتدا root cause همان شکست اصلاح می‌گردد. اگر تغییری قبلاً در main یا PR حل شده باشد، هیچ commit تکراری ایجاد نمی‌شود.

## وضعیت فعلی
- Unified Item foundation و Category compatibility در main تثبیت شده‌اند.
- Lock Screen Widget به‌عنوان الزام محصولی مستند شده است.
- CI فعلی برای commit مستندسازی Lock Screen در حال اجراست.
- قدم بعدی: **Audit و اجرای Gate A برای adapter/migration بین Task و Legacy**؛ سپس Notebook UI.
