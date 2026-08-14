# ممیزی جامع ایده‌ها و درخواست‌های آروین — 2026-08-14

## هدف
این سند تمام ایده‌ها و تصمیم‌های قابل بازیابی از گفتگوهای پروژه آروین را در یک فهرست مرجع جمع می‌کند و آن‌ها را با وضعیت ثبت‌شده در `Arvin-clean` مقایسه می‌کند. این سند برای جلوگیری از دوباره‌کاری، regression و از دست رفتن تصمیم‌های محصولی است.

## 1. هسته محصول
- Task/کار باید عنوان، توضیح، تاریخ و ساعت ایجاد/ویرایش‌پذیر داشته باشد.
- ثبت پیگیری در هر زمان.
- تاریخ و ساعت پیگیری به‌صورت خودکار از سیستم وارد شود و کاربر بتواند آن را ویرایش کند.
- تاریخ شمسی و RTL.
- تاریخچه کامل پیگیری‌ها، آخرین پیگیری در Home همراه ساعت و دقیقه.
- نتیجه، یادداشت و next follow-up برای پیگیری.
- دسته‌بندی و Tag.
- Reminder برای Task/FollowUp.
- Archive و Trash.
- ویرایش صریح در همه بخش‌ها؛ لمس عادی فقط نمایش Read-only.
- انتخاب چندتایی با Long Press و عملیات گروهی.
- Swipe چپ/راست برای عملیات سریع و قابل تنظیم در Settings.
- Sort بر اساس تاریخ، آخرین ورودی و عنوان؛ دوبار فعال‌کردن همان Sort جهت را معکوس کند.
- Search در همه بخش‌های مرتبط.
- دکمه + پایین صفحات.

### وضعیت
**Foundation عمدتاً موجود است؛ Integration کامل Home و UI هنوز Gap اصلی است.** FollowUp service/agenda/office و مدل جدید Task وجود دارند، ولی Home هنوز مسیر Legacy `ArvinTask/TaskRepository` را دارد. Search service موجود است اما اتصال UI آن باید بعد از حل مرز مدل انجام شود.

## 2. Simple Note / دفترچه یادداشت
تصمیم نهایی گفتگو:
- یادداشت ساده یک موجودیت مستقل از Task است.
- عنوان/موضوع و متن.
- تاریخ و ساعت سیستم هنگام ایجاد به‌صورت خودکار.
- تاریخ و ساعت توسط کاربر قابل ویرایش.
- ذخیره خودکار پس از ورود اطلاعات.
- بعد از خروج، یادداشت Read-only شود.
- در مراجعه بعدی فقط با دکمه «ویرایش» وارد Edit شود.
- قابلیت فعال/غیرفعال شدن رفتار/دفترچه از Settings.
- Checklist داخل یادداشت.
- تاریخ یادداشت فقط برای خود Note نگهداری شود.
- Note نباید به Google Calendar یا تقویم سیستم گوشی ارسال شود.
- Note نباید صرفاً به‌خاطر داشتن timestamp به Calendar Event تبدیل شود.

### وضعیت
Foundation، storage، application service و session policy در PRهای #57/#61/#62 وجود دارند. **UI نهایی Notebook هنوز ناقص است.** Settings integration، Checklist UI و اتصال نهایی به Home/منو باید تکمیل شود.

## 3. Reminder و Calendar
- تقویم باید شمسی، RTL و فارسی باشد.
- تاریخ و ساعت Reminder نمایش داده شود.
- Calendar responsive باشد و overflow قبلی تکرار نشود.
- Reminder از timestamp ساده Note جدا باشد.
- Reminder باید قابل ویرایش باشد.
- کاربر بتواند از امکانات تاریخ/ساعت گوشی استفاده کند.
- Google Calendar فقط برای موجودیت‌هایی که محصول صریحاً Calendar Event می‌داند؛ Note به آن نرود.

### وضعیت
Jalali Calendar و چندین regression fix قبلاً ساخته شده‌اند؛ PR #37 و PRهای #34/#36 و موارد قدیمی‌تر سابقه تثبیت Calendar را ثبت کرده‌اند. **Calendar را نباید دوباره بازنویسی کرد مگر CI یا نیاز محصولی جدید دلیل روشن بدهد.** Google Calendar integration هنوز Gap است.

## 4. PDF و Share
- PDF یک Task به همراه همه FollowUpها.
- Share همان PDF.
- PDF فهرست Taskها.
- Share فهرست.
- فارسی/RTL/شمسی در PDF.

### وضعیت
**Gap جدی**؛ باید پس از تثبیت مدل و UI اصلی اجرا شود.

## 5. Backup / Restore / Dropbox
- Backup کامل قابل انتقال به گوشی دیگر.
- حفظ Task، FollowUp، دسته‌ها، Tagها، Noteها و تنظیمات.
- Restore.
- Dropbox برای نگهداری/انتقال Backup.
- از سیستم Backup/Dropbox موجود استفاده شود؛ سیستم موازی جدید بدون audit ممنوع.

### وضعیت
Backup foundation و اجزای Dropbox در پروژه وجود دارند و CI آن‌ها قبلاً سبز شده است. **تکمیل End-to-End و UI/credential flow هنوز Gap است.**

## 6. Typography
تصمیم نهایی گفتگو:
- فونت اصلی: **IRANSans / IranSansX(Eco)** با فایل فونت ارائه‌شده توسط کاربر.
- Vazirmatn دیگر فونت نهایی توافق‌شده نیست.
- Settings باید امکان مدیریت فونت را داشته باشد؛ اگر فونت‌های دیگر واقعاً مجوز/فایل معتبر داشته باشند می‌توانند بعداً اضافه شوند.

### وضعیت
Typography foundation/CI وجود دارد، اما **اعمال کامل IRANSans در UI و Settings و خروجی PDF هنوز باید End-to-End اعتبارسنجی شود.**

## 7. ظاهر و UX
- مدرن، ساده، فارسی و RTL.
- صفحه اصلی لیست Task/Note.
- Task عادی می‌تواند مانند Note ساده دیده شود.
- با فعال شدن FollowUp، Task به کار پیگیری‌دار تبدیل شود.
- منو بتواند Noteها را از Taskهای دارای FollowUp جدا کند.
- لمس آیتم نباید اطلاعات را تغییر دهد.
- جزئیات با لمس فقط Read-only نمایش داده شود.
- دکمه Edit برای تغییر.
- Swipe و Long Press قابل تنظیم.
- Light/Dark و رنگ‌بندی قابل تنظیم در Settings طبق Roadmap موجود.

### وضعیت
**بخش قابل توجهی foundation دارد، ولی یکپارچه‌سازی UI نهایی هنوز انجام نشده است.**

## 8. فیلترهای کاری
منوی مورد انتظار:
- همه موارد
- یادداشت‌ها
- کارهای دارای پیگیری
- امروز
- آینده
- عقب‌افتاده
- بایگانی
- سطل زباله
- دسته‌ها
- Tagها
- Search
- Reports/PDF
- Backup/Restore
- Settings

### وضعیت
برخی domainها و فیلترها موجودند؛ **منوی نهایی و اتصال کامل UI هنوز Gap است.**

## 9. مرجع‌های خارجی
### arvin-task-tracker
از تجربه آن برای UX تقویم/ساعت و الگوی ورود تاریخ/زمان استفاده شود، نه copy wholesale.

### daftar-peygiri
از تجربه آن برای FollowUp Office، تاریخ/ساعت خودکار قابل ویرایش، تاریخچه پیگیری و UX پیگیری استفاده شود.

### قانون
`Arvin-clean` منبع حقیقت است. پروژه‌های مرجع فقط منبع تجربه‌اند. هیچ قابلیت حل‌شده‌ای نباید دوباره از روی پروژه مرجع ساخته شود.

## 10. الزامات نصب و توسعه
- توسعه روی PC بدون نصب نرم‌افزار اضافی توسط کاربر.
- Build/Test/APK از GitHub Actions.
- کاربر کدنویس نیست؛ خروجی قابل نصب APK هدف نهایی است.
- CI باید سطوح مستقل را موازی اجرا کند.
- `fail-fast=false` برای مسیرهای مستقل حفظ شود.

## 11. قانون دائمی ضد دوباره‌کاری
قبل از هر تغییر:
1. وضعیت `main` بررسی شود.
2. کد واقعی بررسی شود.
3. PRهای باز بررسی شوند.
4. مستندات و AI handoff خوانده شوند.
5. خطاهای CI اخیر بررسی شوند.
6. پروژه‌های مرجع فقط در صورت نیاز مقایسه شوند.
7. اگر قابلیت قبلاً حل شده، **هیچ تغییر مجددی انجام نشود**.
8. تغییر حداقلی و مستقل ساخته شود.
9. تست focused اضافه/اصلاح شود.
10. مستندات همان تغییر به‌روزرسانی شود.
11. Commit و Workflowهای مستقل همزمان اجرا شوند.
12. سبز شدن CI شرط کافی نیست؛ Definition of Done باید در مسیر واقعی APK برقرار شود.

## 12. Gapهای اولویت‌دار
1. تثبیت Contract بین `models.Task` جدید و `ArvinTask/TaskRepository` قدیمی.
2. اتصال Search UI به Home بدون ایجاد مسیر داده موازی.
3. تکمیل Notebook UI + Checklist + Settings.
4. تکمیل Home UX، Sort/Search/Swipe/Multi-select.
5. PDF/Share.
6. IRANSans End-to-End + Settings + PDF.
7. Reminder و Google Calendar با isolation برای Note.
8. Backup/Restore End-to-End + Dropbox.
9. E2E و APK Release.

## 13. مواردی که عمداً نباید دوباره‌سازی شوند
- Calendar responsive fixes قبلی.
- Jalali Calendar foundation.
- FollowUp application/agenda/office foundation.
- Backup foundation.
- Dropbox provider/foundation موجود.
- Search service موجود.
- Notebook storage/application/session foundation.
- CI parallel validation infrastructure.

## 14. Definition of Done نهایی
هر قابلیت زمانی Done است که:
- domain/application logic تست شده باشد؛
- UI واقعی به آن متصل باشد؛
- persistence واقعی کار کند؛
- RTL/شمسی/فونت صحیح باشد؛
- regression روی Calendar/FollowUp/Notebook/Backup کنترل شده باشد؛
- CI سبز باشد؛
- در APK قابل استفاده باشد؛
- مستندات و AI handoff به‌روز شده باشند.

## وضعیت ممیزی
این سند یک baseline برای مقایسه ایده‌های گفتگو با پروژه است. درصد پیشرفت از تعداد PRها محاسبه نمی‌شود؛ معیار، قابلیت End-to-End قابل استفاده در APK است.
