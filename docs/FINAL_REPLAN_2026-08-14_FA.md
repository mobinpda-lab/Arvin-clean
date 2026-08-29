# بازنگری نهایی برنامه تکمیل آروین — 2026-08-14

## 1. اصل مرجع
این برنامه بر اساس ممیزی گفتگو، مستندات قبلی، وضعیت `main` و PRهای باز تنظیم شده است. قبل از هر تغییر کد باید وضعیت `main`، PRهای باز، CI اخیر، تست‌های مرتبط و مستندات تصمیم‌های محصول بررسی شود. قابلیت حل‌شده دوباره ساخته نمی‌شود.

## 2. مدل نهایی محصول
مدل مفهومی هدف یک **Item مشترک** است:

`Item → Note ساده → فعال‌سازی FollowUp → همان Item به مورد پیگیری‌دار تبدیل می‌شود`

نباید برای یک رکورد دو مسیر داده مستقل Note و Task ایجاد شود.

هر Item می‌تواند شامل عنوان، متن/توضیحات، تاریخ و ساعت خودکارِ قابل ویرایش، Checklist، Category، Tag، Reminder و `FollowUps[]` باشد.

FollowUp شامل زمان ثبت خودکارِ قابل ویرایش، متن، نتیجه و Next FollowUp مستقل است.

## 3. Notebook / یادداشت
رفتار مورد توافق:
- ایجاد با تاریخ/ساعت سیستم.
- تاریخ/ساعت قابل ویرایش.
- ذخیره خودکار.
- بعد از خروج Read-only.
- بازگشت به Edit فقط با دکمه ویرایش.
- این سیاست از Settings قابل فعال/غیرفعال شدن است.
- Checklist.
- تاریخ یادداشت فقط metadata داخلی آروین است.
- یادداشت به Google Calendar، تقویم گوشی یا Arvin Calendar Event ارسال نمی‌شود.

Foundationهای Notebook در PRهای #57/#61/#62 موجودند و باید حفظ شوند؛ هدف بعدی UI و ادغام صحیح با Item است.

## 4. FollowUp / پیگیری
- ثبت تاریخچه کامل و chronological.
- تاریخ/ساعت خودکار و قابل ویرایش.
- آخرین پیگیری در Home با ساعت/دقیقه.
- متن و نتیجه.
- Next FollowUp مستقل.
- ویرایش/حذف.
- FollowUp Office فارسی/RTL.
- Agenda و فیلتر آینده.

Foundationهای موجود بازسازی نمی‌شوند؛ Integration با Item/Home اولویت دارد.

## 5. Reminder و Calendar
تفاوت مفاهیم الزام‌آور است:

`Note timestamp ≠ FollowUp timestamp ≠ Next FollowUp ≠ Reminder ≠ Calendar Event`

Calendar موجود، Jalali/RTL و regression fixهای viewport را دارد و نباید دوباره‌نویسی شود. FollowUp-to-Calendar foundation نیز قبلاً ایجاد شده است.

Google Calendar فقط برای Reminder/Eventهای صریحاً مجاز است؛ timestamp یادداشت هرگز Event نیست.

## 6. Widget — تصمیم نهایی
Widget قبلاً در پروژه و گفتگو مورد توجه بوده و باید به‌عنوان قابلیت محصول حفظ شود؛ اما قبل از پیاده‌سازی مجدد، foundation فعلی Widget و PRهای مربوط به آن audit می‌شوند.

### قابلیت‌های مورد توافق + پیشنهاد تکمیلی
- نمایش فشرده موارد مرتبط با امروز/آینده/عقب‌افتاده.
- امکان فیلتر/دسته در صورتی که Category/Today/Overdue در مدل نهایی واقعاً وجود داشته باشند.
- اگر Category، Today یا Overdue در نسخه نهایی وجود نداشت، Widget نباید برای این فیلترها UI مصنوعی بسازد؛ باید فقط فیلترهای واقعی موجود را ارائه کند.
- دکمه **+** برای افزودن سریع Item.
- لمس مورد، برنامه را مستقیماً روی همان Item باز کند.
- حالت نمایشی/تعامل‌پذیر مطابق تنظیمات سیستم/محصول در صورت وجود.
- طراحی سبک و کم‌مصرف.
- Widget نباید دیتابیس یا storage موازی داشته باشد.
- داده Widget باید از منبع اصلی Item/Reminder/FollowUp خوانده شود.
- به‌روزرسانی پس‌زمینه باید سبک، محدود و event-driven تا حد امکان باشد؛ از اجرای دائمی و سنگین background task اجتناب شود.
- در صورت پشتیبانی Android، refresh در تغییر داده، زمان‌بندی‌های لازم و boot/device events مدیریت شود.
- Widget باید RTL و با فونت/زبان نهایی آروین سازگار باشد.

**قانون:** اگر قابلیت Today/Overdue/Category در مدل محصول نهایی تثبیت نشد، Widget نباید آن را به‌صورت مستقل اختراع کند.

## 7. Print و PDF
### Print
یادداشت ساده نیز **حتماً قابل چاپ است**.

دو سطح Print:
1. چاپ یک Item ساده/یادداشت: عنوان، متن، Checklist و timestamp داخلی.
2. چاپ Item پیگیری‌دار: اطلاعات Item + تمام سوابق FollowUp با تاریخ/ساعت.
3. در صورت فراهم بودن UI انتخاب گروهی، چاپ فهرست موارد انتخاب‌شده.

Print باید RTL، فارسی، شمسی و IRANSans را رعایت کند و از Android Print Service استفاده کند؛ نباید موتور چاپ موازی و بی‌دلیل ساخته شود.

### PDF
- PDF یک Item با تمام FollowUpها.
- PDF فهرست موارد.
- Share برای هر دو.
- فارسی/RTL/شمسی/IRANSans.

Print و PDF دو خروجی متفاوت‌اند: PDF برای فایل/اشتراک‌گذاری، Print برای چاپ مستقیم.

## 8. Typography
تصمیم نهایی: **IRANSans / IranSansX(Eco)** به‌عنوان فونت اصلی با فایل فونتی که کاربر قبلاً ارائه کرده است.

اعمال نهایی باید در UI، Widget، Print و PDF اعتبارسنجی شود.

## 9. Home / UX
- Home لیست مشترک Itemها.
- Note ساده و FollowUp-enabled با فیلتر جداگانه.
- لمس = Read-only.
- Edit صریح.
- `+` پایین صفحه.
- Long Press برای انتخاب چندتایی.
- انتقال گروهی به Category/Trash.
- Swipe چپ/راست قابل تنظیم در Settings.
- Sort بر اساس تاریخ، آخرین ورودی و عنوان؛ فعال‌سازی دوباره همان Sort جهت را معکوس کند.
- Search در بخش‌های مرتبط و در نهایت Home.
- ظاهر مدرن، فارسی و RTL.

## 10. Search
SearchService موجود در PR #67 حفظ می‌شود. هیچ بازنویسی مجددی انجام نمی‌شود.

گام بعدی فقط پس از تثبیت Contract Item/Home:
`SearchService → Home Search UI → Task/Note/FollowUp results`

## 11. Backup / Restore / Dropbox
Backup باید Item، FollowUp، Note data، Category، Tag، Settings و داده‌های لازم Widget را بدون duplicate storage حفظ کند.

Restore باید داده را به همان source of truth برگرداند.

Dropbox فقط provider/transport است، نه دیتابیس دوم.

## 12. برنامه Waveهای بعدی
### Wave A — معماری Item
Audit دقیق `Task`، `ArvinTask`، Notebook و persistence و تعریف compatibility layer بدون حذف داده‌های قدیمی.

### Wave B — Notebook UI
Editor، auto-save، read-only-after-exit، explicit Edit، Checklist و Settings toggle.

### Wave C — Home Integration
اتصال Item/FollowUp به Home، فیلتر Note/FollowUp، آخرین پیگیری، Sort، Swipe و Multi-select.

### Wave D — Search UI
اتصال SearchService موجود به Home و فیلتر نتایج.

### Wave E — Widget
Audit foundation موجود، سپس تکمیل Widget بدون storage موازی، با +، داده‌های Today/Overdue/Category فقط در صورت وجود واقعی، refresh سبک و background محدود.

### Wave F — PDF / Print
ساخت یک pipeline خروجی مشترک تا Print و PDF از مدل و formatter مشترک استفاده کنند، سپس Android Print Service و Share.

### Wave G — Typography
اعمال و تست IRANSans در تمام سطوح UI، Widget، PDF و Print.

### Wave H — Reminder / Google Calendar
تکمیل Reminder و Calendar integration فقط برای موجودیت‌های مجاز؛ Note isolation حفظ شود.

### Wave I — Backup / Dropbox E2E
Backup/Restore واقعی، انتقال‌پذیری، Dropbox sync/transport و regression.

### Wave J — Release
Full test، analyze، Android build، نصب APK، smoke test واقعی روی گوشی و ثبت نسخه نهایی.

## 13. کار موازی
Waveهای مستقل A/B می‌توانند با مستندات و تست‌های جداگانه موازی شوند، اما هیچ Waveای نباید همزمان روی همان source of truth بدون contract کار کند.

برای هر تغییر:
1. audit کلی پروژه؛
2. بررسی PRهای باز؛
3. بررسی CI اخیر؛
4. مقایسه با مستندات؛
5. تغییر حداقلی؛
6. تست focused؛
7. مستندسازی؛
8. Commit مستقل؛
9. Workflowهای مستقل موازی؛
10. فقط سپس ورود به Wave بعدی.

## 14. مواردی که نباید دوباره ساخته شوند
- Calendar foundation و responsive fixes.
- FollowUp application/agenda/office foundation.
- Notebook foundation/storage/application/session policy.
- SearchService.
- Backup foundation.
- Dropbox provider foundation.
- CI parallel infrastructure.
- Typography preference foundation.

## 15. معیار نهایی تکمیل
قابلیت فقط وقتی Done است که در domain، persistence، UI واقعی، RTL/شمسی، فونت، تست، CI و APK قابل استفاده باشد و مستندات/AI handoff نیز به‌روز باشند.

## 16. خروجی مورد انتظار نهایی
یک APK قابل نصب و تست روی Android که در آن Item/Note/FollowUp، Calendar/Reminder، Search، Widget، PDF، Print، Backup/Restore، Dropbox و Settings بدون مسیر داده موازی و بدون regression در کنار هم کار کنند.
