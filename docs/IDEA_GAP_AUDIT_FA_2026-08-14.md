# ممیزی جامع ایده‌ها و تصمیم‌های نهایی آروین — 2026-08-14

## هدف
این سند تمام ایده‌ها، درخواست‌ها و تصمیم‌های محصولی قابل بازیابی از گفتگوهای پروژه آروین را با وضعیت واقعی `Arvin-clean` مقایسه می‌کند. این سند مرجع جلوگیری از دوباره‌کاری، regression و از دست رفتن تصمیم‌های نهایی است.

> **مهم:** هر تصمیم جدید در گفتگو که با این سند یا مستندات قبلی تعارض داشته باشد باید ابتدا به‌عنوان «تغییر تصمیم محصول» ثبت و بعد وارد کد شود؛ نباید با تغییر کد به‌صورت ضمنی تصمیم قبلی را عوض کرد.

## 1. مدل نهایی «مورد» / Item
مدل محصولی نهایی گفتگو نسبت به ممیزی قبلی اصلاح شد.

آروین نباید از نظر تجربه کاربر سه مسیر جدا برای «یادداشت»، «کار» و «پیگیری» داشته باشد. مدل مفهومی هدف یک **مورد مشترک (Item)** است که در حالت عادی مانند یک یادداشت ساده رفتار می‌کند و در صورت فعال‌شدن پیگیری، همان مورد به یک کار پیگیری‌دار تبدیل می‌شود.

```text
Item
 ├── موضوع / عنوان
 ├── متن / توضیحات
 ├── تاریخ و ساعت ایجاد
 ├── تاریخ و ساعت قابل ویرایش
 ├── Checklist اختیاری
 ├── Category / Tags
 ├── Reminder اختیاری
 └── FollowUps[]
      ├── تاریخ و ساعت ثبت
      ├── متن / یادداشت پیگیری
      ├── نتیجه
      └── Next FollowUp اختیاری
```

### قواعد نهایی
- مورد جدید در حالت عادی یک یادداشت ساده است.
- فعال‌کردن پیگیری، همان مورد را به کار دارای پیگیری تبدیل می‌کند؛ کپی‌کردن Note به Task ممنوع است.
- Note و Task از نظر UX می‌توانند در منوی اصلی جدا فیلتر شوند، اما نباید دو منبع داده موازی برای یک مورد ایجاد شود.
- تاریخ و ساعت ایجاد/ثبت به‌صورت خودکار از سیستم درج می‌شود و کاربر می‌تواند آن را ویرایش کند.
- لمس عادی اطلاعات را تغییر نمی‌دهد؛ جزئیات Read-only است و Edit باید صریح باشد.
- ذخیره در بازگشت/خروج باید خودکار و قابل اعتماد باشد.

### وضعیت فعلی کد
`lib/models/task.dart` در `main` همین حالا `Task` را همراه `FollowUp[]` مدل می‌کند و migration از `followUpDate` قدیمی دارد. fileciteturn1546file0L2-L6

با این حال Notebook domain/storage فعلی نیز وجود دارد. بنابراین **در این مرحله نباید آن را حذف یا دوباره‌سازی کنیم**؛ ابتدا Contract مشترک Item و مرز persistence باید طراحی و با داده‌های فعلی مقایسه شود. PR #67 نیز SearchService را روی `Task` جدید بنا کرده است. fileciteturn1545file0L4-L9

## 2. FollowUp / پیگیری
- ثبت پیگیری در هر زمان.
- تاریخ و ساعت پیگیری به‌صورت خودکار از سیستم.
- تاریخ و ساعت پیگیری قابل ویرایش توسط کاربر.
- متن/یادداشت پیگیری.
- نتیجه پیگیری.
- Next FollowUp مستقل از تاریخ ثبت پیگیری.
- مشاهده تمام سوابق chronological.
- آخرین پیگیری در Home همراه ساعت و دقیقه.
- ویرایش و حذف پیگیری.
- دفتر/Office پیگیری فارسی و RTL.
- فیلتر آینده و Agenda برای پیگیری‌ها.

### وضعیت
Foundationهای FollowUp، application service، agenda و Persian Office قبلاً ساخته شده‌اند. بنابراین این بخش **بازسازی نمی‌شود**؛ تمرکز بعدی Integration آن با Item/Home است.

## 3. Simple Note / دفترچه یادداشت
دفترچه یادداشت همچنان جزو محصول است، اما طبق تصمیم نهایی، از نظر تجربه کاربر همان **حالت پایه Item** است و نباید به‌عنوان یک Task موازی پیاده‌سازی شود.

### رفتار نهایی
- موضوع/عنوان و متن.
- تاریخ و ساعت سیستم هنگام ایجاد.
- تاریخ و ساعت قابل ویرایش.
- ذخیره خودکار پس از ورود اطلاعات.
- پس از خروج از Editor، یادداشت Read-only شود.
- در مراجعه بعدی فقط با دکمه «ویرایش» دوباره Edit شود.
- این سیاست بتواند از Settings فعال/غیرفعال شود.
- Checklist داخل یادداشت.
- تاریخ یادداشت فقط در خود آروین نگهداری شود.
- timestamp یادداشت به‌خودی‌خود Reminder یا Calendar Event نیست.
- یادداشت به Google Calendar یا تقویم گوشی ارسال نشود.
- یادداشت نباید فقط به‌خاطر داشتن تاریخ/ساعت در Calendar آروین هم به‌عنوان Event نمایش داده شود، مگر تصمیم محصولی صریح آینده.

### وضعیت
PRهای #57/#61/#62 foundation، persistence، application service و session policy را دارند. **UI نهایی Notebook و ادغام آن با مدل Item هنوز Gap است.** این foundationها حفظ می‌شوند و دوباره نوشته نمی‌شوند.

## 4. Reminder / Next FollowUp / Calendar Event
این سه مفهوم باید از هم جدا بمانند:

- **تاریخ/ساعت ثبت Item یا Note:** فقط metadata داخلی.
- **تاریخ/ساعت FollowUp:** زمان ثبت یک پیگیری واقعی.
- **Next FollowUp:** زمان پیگیری بعدی، مستقل از زمان ثبت.
- **Reminder:** یادآوری قابل فعال/ویرایش برای کاربر.
- **Calendar Event:** فقط چیزی که محصول صریحاً تصمیم گرفته با تقویم گوشی/Google Calendar همگام شود.

بنابراین داشتن timestamp روی Note هرگز نباید باعث ارسال آن به Google Calendar شود.

## 5. Calendar
- تقویم شمسی، فارسی و RTL.
- نمایش تاریخ و ساعت Reminder.
- responsive و بدون overflow در viewportهای کوچک.
- استفاده از date/time picker و امکانات سیستم گوشی برای ورود تاریخ و ساعت.
- FollowUpهای منتخب/مناسب می‌توانند طبق integration موجود به Calendar Reminder/Event تبدیل شوند.
- **Simple Note نباید وارد Google Calendar یا Calendar گوشی شود.**
- Calendar foundation و regression fixهای قبلی نباید بدون دلیل دوباره بازنویسی شوند.

### وضعیت
Jalali Calendar و regression fixهای viewport در PRهای #34/#36/#37 تثبیت شده‌اند. PR #20 نیز foundation پل FollowUp history به Calendar را ثبت کرده است. بنابراین **Calendar بازنویسی نمی‌شود**؛ فقط integration لازم با مدل نهایی Item/Reminder بررسی می‌شود.

## 6. دسته‌بندی، Tag و وضعیت کار
- Category.
- Tag.
- Archive.
- Trash.
- Completed در صورت پشتیبانی مدل فعلی.
- انتقال گروهی به Category.
- انتقال گروهی به Trash.
- انتخاب چندتایی با Long Press.
- عملیات سریع با Swipe چپ/راست.
- Swipe قابل تنظیم در Settings.

### وضعیت
بخش زیادی در مدل/زیرساخت فعلی وجود دارد. Gap اصلی، اتصال کامل آن به Home و Item UX نهایی است.

## 7. Home و UX اصلی
- صفحه اصلی لیست موارد است.
- Note ساده و مورد FollowUpدار در یک لیست پایه قابل نمایش‌اند.
- فیلتر منویی برای جداکردن Noteها از موارد FollowUpدار.
- آخرین FollowUp با ساعت و دقیقه نمایش داده شود.
- `+` پایین صفحه برای افزودن مورد.
- لمس فقط نمایش Read-only.
- دکمه Edit برای تغییر.
- Long Press برای Multi-select.
- Swipe برای عملیات سریع.
- Swipe در Settings قابل انتخاب/تنظیم.
- ظاهر مدرن، ساده، RTL و فارسی.
- Light/Dark و تنظیمات ظاهری طبق roadmap موجود.

## 8. Sort و Search
### Sort
- تاریخ.
- آخرین ورودی/آخرین تغییر.
- عنوان.
- فعال‌کردن دوباره همان Sort جهت مرتب‌سازی را معکوس کند.

### Search
- عنوان.
- توضیحات.
- Tags.
- متن FollowUp.
- نتیجه FollowUp.
- case-insensitive و trim.
- Search باید در بخش‌های مرتبط و در نهایت Home در دسترس باشد.

### وضعیت
SearchService مستقل در PR #67 وجود دارد و **نباید دوباره نوشته شود**. اتصال آن به Home باید بعد از تثبیت Contract Item/Task انجام شود. fileciteturn1545file0L4-L9

## 9. PDF و Share
- PDF یک مورد/Task به همراه تمام FollowUpها.
- Share همان PDF.
- PDF فهرست موارد.
- Share فهرست.
- فارسی/RTL/شمسی در PDF.
- timestamp داخلی Note نباید به Calendar Event تبدیل شود.

### وضعیت
End-to-End هنوز Gap است و باید بعد از تثبیت Item/Home و Typography اجرا شود.

## 10. Backup / Restore / Dropbox
- Backup کامل و قابل انتقال به گوشی دیگر.
- Restore.
- حفظ Item/Task، FollowUp، Note، Category، Tag و Settings.
- Dropbox برای نگهداری/انتقال Backup.
- استفاده از foundation/provider موجود و عدم ساخت سیستم Backup موازی.

### وضعیت
Foundationهای Backup/Dropbox وجود دارند و قبلاً در CI مسیر مستقل داشته‌اند. Gap اصلی End-to-End UI، انتقال و Restore واقعی است.

## 11. Typography — تصمیم نهایی
تصمیم نهایی گفتگو:

**فونت اصلی آروین = IRANSans / IranSansX(Eco)** با فایل فونتی که کاربر قبلاً ارائه کرده است.

بنابراین:
- Vazirmatn دیگر فونت نهایی مورد توافق نیست.
- لیست فونت‌های قبلی (Vazirmatn، Mitra، Homa، کودک، IranSans، Faraz) به‌عنوان نیاز تاریخی ثبت شده، اما تصمیم نهایی فعلی IRANSans است.
- Settings باید امکان مدیریت فونت را داشته باشد.
- PDF نیز باید با فونت فارسی مناسب و در صورت امکان همان Typography نهایی تولید شود.

### وضعیت
Typography foundation/CI قبلاً ایجاد شده است؛ اعمال کامل IRANSans در UI، Settings و PDF هنوز End-to-End باید اعتبارسنجی شود.

## 12. فیلترها و منوی اصلی
منوی مورد انتظار:
- همه موارد.
- یادداشت‌ها.
- کارهای دارای پیگیری.
- امروز.
- آینده.
- عقب‌افتاده.
- بایگانی.
- سطل زباله.
- دسته‌ها.
- Tagها.
- Search.
- Reports/PDF.
- Backup/Restore.
- Settings.

## 13. پروژه‌های مرجع
### `arvin-task-tracker`
منبع تجربه UX تقویم و ساعت و الگوی ورود تاریخ/زمان است؛ نه منبع Copy مستقیم.

### `daftar-peygiri`
منبع تجربه FollowUp Office، تاریخ/ساعت خودکار قابل ویرایش، تاریخچه و UX پیگیری است.

### قانون
`Arvin-clean` منبع حقیقت است. پروژه‌های مرجع فقط منبع تجربه‌اند. قابلیت حل‌شده در Arvin نباید از پروژه مرجع دوباره ساخته شود.

## 14. الزامات توسعه و تحویل
- کاربر روی PC نیاز به نصب ابزار توسعه ندارد.
- Build/Test/APK از GitHub Actions.
- خروجی نهایی باید APK قابل نصب و قابل تست باشد.
- Workflowهای مستقل باید موازی اجرا شوند.
- `fail-fast=false` برای مسیرهای مستقل حفظ شود.
- CI سبز به‌تنهایی کافی نیست؛ قابلیت باید در APK واقعی قابل استفاده باشد.

## 15. قانون دائمی ضد دوباره‌کاری
قبل از هر تغییر:
1. `main` و commit فعلی بررسی شود.
2. کد واقعی بررسی شود.
3. تمام PRهای باز مرتبط بررسی شوند.
4. مستندات Roadmap و AI Handoff بررسی شوند.
5. CIهای اخیر بررسی شوند.
6. پروژه‌های مرجع فقط در صورت نیاز مقایسه شوند.
7. اگر قابلیت قبلاً رفع شده، **هیچ تغییر مجددی انجام نشود**.
8. تغییر حداقلی و مستقل ایجاد شود.
9. تست focused اضافه/اصلاح شود.
10. مستندات همان تغییر به‌روز شود.
11. Commit و Workflowهای مستقل همزمان اجرا شوند.
12. بعد از CI، قابلیت در APK و مسیر واقعی کاربر بررسی شود.

## 16. Gapهای اولویت‌دار بعد از تصمیم نهایی Item
1. طراحی/تثبیت Contract مشترک Item بدون شکستن Note foundation یا Task/FollowUp داده‌های موجود.
2. جلوگیری از دو منبع داده برای یک مورد و مشخص‌کردن migration strategy.
3. اتصال SearchService موجود به Home.
4. تکمیل Notebook/Item UI، Checklist و Settings.
5. تکمیل Home UX، Sort، Swipe و Multi-select.
6. PDF/Share.
7. IRANSans End-to-End + Settings + PDF.
8. Reminder و Google Calendar با isolation کامل برای Note.
9. Backup/Restore End-to-End + Dropbox.
10. E2E و APK Release.

## 17. مواردی که عمداً نباید دوباره‌سازی شوند
- Calendar Jalali و responsive fixes موجود.
- FollowUp application/agenda/office foundation.
- Backup foundation.
- Dropbox provider/foundation.
- SearchService موجود.
- Notebook storage/application/session foundation.
- CI parallel validation infrastructure.
- Typography foundation.

## 18. Definition of Done نهایی
هر قابلیت زمانی Done است که:
- domain/application logic تست شده باشد؛
- UI واقعی به آن متصل باشد؛
- persistence واقعی کار کند؛
- RTL/شمسی/IRANSans صحیح باشد؛
- regression روی Calendar/FollowUp/Notebook/Backup کنترل شده باشد؛
- CI سبز باشد؛
- در APK قابل استفاده باشد؛
- مستندات و AI Handoff به‌روز باشند.

## وضعیت ممیزی
این سند baseline تصمیم‌های محصولی است. درصد پیشرفت از تعداد PRها محاسبه نمی‌شود؛ معیار، قابلیت End-to-End قابل استفاده در APK است. تصمیم جدید درباره مدل Item/Note/FollowUp باید در همه Roadmapها و AI Handoffهای بعدی منعکس شود.
