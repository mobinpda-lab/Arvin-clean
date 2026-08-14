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

## مدل اجرای سریع و موازی
سرعت با شکستن کار به commitهای کوچک و مستقل افزایش می‌یابد، نه با موازی‌سازی کور. هر Lane فقط مالک فایل‌ها/لایه‌های خودش است و foundation مشترک فقط توسط Lane اصلی تغییر می‌کند.

### Lane 0 — CI / Release مراقبت مستمر
- بررسی نتیجه هر Build/Parallel قبل از ادامه تغییر وابسته.
- حفظ APK release به‌عنوان معیار نهایی، نه صرفاً analyze/test.
- در صورت سبز بودن CI، شروع فوری کار مستقل بعدی بدون انتظار برای تکمیل Laneهای نامرتبط.
- در صورت قرمز شدن، توقف همان Lane و root-cause fix.

### Lane A — Architecture / Unified Item
**اولویت: فوری و گلوگاه اصلی**
- تثبیت `Task` به‌عنوان مدل Item مشترک.
- بررسی دقیق `ArvinTask / TaskRepository` و تعیین adapter/migration حداقلی.
- حفظ migration داده‌های قدیمی.
- حذف تدریجی وابستگی‌های Legacy فقط پس از تست و بدون شکستن UI موجود.
- خروجی Gate A: یک مسیر داده مشخص برای Item/Note/FollowUp.

### Lane B — Simple Notebook UI
**قابل آماده‌سازی موازی، اجرای UI نهایی پس از Contract مدل**
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
- تست‌های UI مستقل می‌توانند همزمان با Lane A آماده شوند، اما merge وابسته به Gate A است.

### Lane D — Calendar / Official Iranian data
**به‌صورت مستقل از Notebook/Home جلو می‌رود؛ Calendar foundation بازنویسی نمی‌شود.**
- تکمیل `CalendarReminder` برای اوقات شرعی شیعه بر اساس منبع/روش مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران.
- تکمیل یادآور تعطیلات رسمی ایران بر اساس تقویم رسمی کشور و مناسبت‌های مصوب.
- تعریف source-of-truth، مکان، timezone، cache و refresh.
- تست تاریخ شمسی، مرز روز، تغییر مکان و سال.
- Note timestamp هرگز وارد این مسیر نشود.
- Google/system Calendar فقط برای eventهای مجاز محصول باقی بماند.
- این Lane بعد از validation قرارداد PR #79 به implementation واقعی می‌رسد.

### Lane E — Widget
- استفاده از همان source of truth Item/Reminder/FollowUp.
- Today/Future/Overdue/Category فقط در صورت وجود واقعی مدل.
- Quick Add و open-item.
- RTL و IranSans.
- بررسی واقعی پشتیبانی Lock Screen و graceful fallback برای دستگاه‌های فاقد پشتیبانی.
- بدون Storage جدا.
- validation روی Android هدف پروژه.

### Lane F — Output / Font
- PDF Item + FollowUps.
- PDF list.
- Share.
- Print برای Note ساده و Item پیگیری‌دار.
- حفظ RTL و شمسی.
- اعمال IranSans / IranSansX(Eco) در UI، Widget، PDF و Print.
- تست خروجی مستقل می‌تواند قبل از اتمام Widget آماده شود، اما یکپارچه‌سازی نهایی پس از تثبیت مدل انجام می‌شود.

### Lane G — Integrations / Data portability
- Reminder / Google Calendar فقط برای eventهای مجاز.
- Backup/Restore End-to-End.
- تکمیل Dropbox provider موجود، نه بازسازی.
- تست انتقال داده بین دستگاه‌ها و حفظ Item/FollowUp/Category/Tag/Settings.

### Lane H — E2E / Device release
- اجرای سناریوهای واقعی APK.
- Calendar شمسی + ساعت + اوقات شرعی + تعطیلات.
- Notebook، FollowUp، Search، Widget و Lock Screen در صورت پشتیبانی.
- Backup/Restore و Dropbox.
- ساخت APK release، artifact، checksum و release documentation.

## ترتیب Gateهای اصلی
1. **Gate A:** Unified Item + adapter/migration + regression.
2. **Gate B:** Notebook UI قابل استفاده و persistence واقعی.
3. **Gate C:** Home + Search روی مسیر نهایی Item.
4. **Gate D:** Calendar + Prayer Times + Iranian Holidays.
5. **Gate E:** Widget + Lock Screen validation.
6. **Gate F:** PDF + Print + IranSans.
7. **Gate G:** Reminder/Google Calendar + Backup/Dropbox.
8. **Gate H:** E2E، APK release، artifact و تست واقعی دستگاه.

## کارهای قابل اجرای موازی فعلی
تا وقتی Gate A در حال تثبیت است، این کارها می‌توانند بدون تغییر foundation مشترک جلو بروند:
- Contract و implementation Calendar رسمی (PR #79) پس از CI.
- طراحی/تست‌های Notebook UI روی foundation موجود.
- آماده‌سازی تست‌های Home/Search با mock/in-memory بدون تغییر repository اصلی.
- آماده‌سازی Widget/Lock Screen compatibility tests بدون ایجاد storage جدید.
- آماده‌سازی PDF/Print tests با fixtureهای Item/FollowUp.

## معیار سرعت
هر commit باید یک Gap مشخص را ببندد، کوچک و قابل بازبینی باشد و بلافاصله validation شود. کار مستقل بعدی نباید فقط به‌خاطر انتظار برای یک Lane نامرتبط متوقف شود.

## معیار توقف
اگر CI قرمز شود، توسعه قابلیت جدید در همان مسیر متوقف می‌شود و ابتدا root cause همان شکست اصلاح می‌گردد. اگر تغییری قبلاً در main یا PR حل شده باشد، هیچ commit تکراری ایجاد نمی‌شود.

## وضعیت فعلی
- Unified Item foundation و Category compatibility در main تثبیت شده‌اند.
- Lock Screen برای Widget به‌عنوان الزام محصولی ثبت شده است.
- PR #79 قرارداد اوقات شرعی و تعطیلات رسمی ایران را ثبت کرده و در انتظار validation/ادامه implementation است.
- **تمرکز اجرایی فعلی:** Gate A به‌عنوان گلوگاه معماری + پیشبرد مستقل Calendar رسمی و آماده‌سازی همزمان Notebook/Home/Search/Widget tests بدون تغییر foundation مشترک.
- پس از سبز شدن validation هر Lane، همان Lane بدون انتظار غیرضروری وارد commit/implementation بعدی می‌شود.
