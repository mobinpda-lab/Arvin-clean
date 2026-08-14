# Arvin — Project Status

## مرجع فعلی
- Branch توسعه/مرجع: `main`
- Wave جاری: **Calendar رسمی ایران — Source Contract و اتصال به CalendarReminder**
- برنامه اجرایی به‌روز: `docs/PROJECT_ROADMAP_2026-08-14.md`
- آخرین Calendar implementation merge: PR #80 → commit `1f9c14386c50611d08254c4b70caa73c9108df16`
- این سند باید همراه هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## قانون audit قبل از تغییر
قبل از هر تغییر محصولی باید main، کد واقعی، PRهای باز، CI اخیر، مستندات و پروژه‌های مرجع بررسی شوند. اگر قابلیت قبلاً حل شده باشد، دوباره‌سازی ممنوع است.

## قانون توسعه سریع و موازی
حوزه‌های مستقل می‌توانند موازی پیش بروند، اما هیچ Wave موازی نباید foundation مشترک را بدون audit و هماهنگی تغییر دهد. هر تغییر باید یک Gap مشخص را ببندد و بلافاصله با تست، Commit و Workflowهای مربوط validation شود. نتیجه CI قبل از ادامه Wave وابسته بررسی می‌شود. تمام تصمیم‌ها، تغییرات و نتایج مهم باید در مستندات ثبت شوند.

## برنامه اجرای سریع به‌روز
برای افزایش سرعت، کار به Laneهای مستقل تقسیم شده است: Architecture/Unified Item، Notebook UI، Home/Search، Calendar رسمی ایران، Widget/Lock Screen، Output/Font، Integrations/Data portability و E2E/Release. Laneهای مستقل می‌توانند همزمان آماده‌سازی و تست شوند؛ اما هیچ Lane اجازه ندارد برای سرعت foundation مشترک را موازی و ناسازگار تغییر دهد.

### گلوگاه‌های فعلی
- **Gate A — Unified Item adapter/migration:** گلوگاه معماری همچنان باید بدون شکستن Legacy تکمیل شود.
- **Gate D — Calendar رسمی ایران:** PR #80 با موفقیت merge شد و Source Contract/Mapping روی `CalendarReminder` تثبیت شده است؛ گام بعدی اتصال Providerهای واقعی و رسمی است.

### کارهای موازی مجاز در کنار Gate A و Calendar
- آماده‌سازی Notebook UI و تست‌های آن روی foundation موجود.
- آماده‌سازی Home/Search tests بدون اتصال موازی به Legacy repository.
- آماده‌سازی Widget/Lock Screen compatibility tests بدون Storage جدید.
- آماده‌سازی PDF/Print fixtures و تست‌های خروجی.

## Audit اخیر
- `main`، commitهای اخیر، مستندات roadmap/status، PRهای باز و CI مرتبط بررسی شدند.
- PR #80 بررسی شد و پس از سبز شدن هر دو Workflow اصلی آن merge شد: **Arvin Parallel Wave #185** و **Arvin Build #308** هر دو `success` هستند.
- PR #80 فقط Source Contract و mapping را تثبیت کرد؛ Provider واقعی هنوز Gap بعدی است و نباید با داده حدسی یا منبع غیررسمی پر شود.
- Calendar foundation موجود حفظ می‌شود و بازنویسی آن ممنوع است مگر Gap یا regression واقعی.
- Lock Screen برای Widget به‌عنوان الزام محصولی ثبت شده و باید با همان source of truth ویجت اصلی اجرا شود.

## وضعیت CI
CI به چند مسیر موازی تقسیم شده است تا شکست یک حوزه، وضعیت حوزه‌های دیگر را مبهم نکند:

1. `Arvin Feature Validation` — analyze و مجموعه تست‌ها.
2. `Arvin FollowUp Validation` — مدل، TaskStore و UI تاریخچه FollowUp.
3. `Arvin Calendar Validation` — تست‌های Calendar.
4. `Arvin Backup Validation` — تست Backup/Restore.
5. `Arvin Release Validation` — Android audit، analyze، test، ساخت APK و upload artifact.

## Android / Release
- Android V2 با `FlutterActivity` استفاده می‌شود.
- Core Library Desugaring فعال است.
- Release فقط وقتی موفق اعلام می‌شود که `flutter build apk --release` واقعاً سبز شود و APK به Artifact آپلود شده باشد.

## مدل محصول در حال تثبیت
### Unified Item
موجودیت پایه باید یک Item مشترک باشد:
- عنوان/موضوع
- توضیحات
- تاریخ/ساعت ایجاد و ویرایش‌پذیر
- Checklist
- Category / Tags
- Reminder اختیاری
- FollowUps[] اختیاری

در حالت بدون FollowUp، Item می‌تواند یک **یادداشت ساده** باشد. با فعال شدن FollowUp، همان Item به مورد پیگیری‌دار تبدیل می‌شود؛ نباید Note و Task به دو مسیر داده موازی تبدیل شوند.

### Category
- `Task.category` به‌صورت `String?` و backward-compatible اضافه شده است.
- داده‌های قدیمی که Category ندارند همچنان معتبر هستند و مقدار `null` می‌گیرند.
- Category هنوز UI یا persistence جداگانه ندارد؛ در Waveهای بعدی فقط در صورت نیاز واقعی محصول فعال می‌شود.

### FollowUp
- مدل مستقل `FollowUp`
- نگهداری تاریخچه در Task
- migration از `followUpDate` قدیمی
- تاریخ/ساعت خودکار با امکان ویرایش
- UI تاریخچه در فاز تکمیل است.

### Simple Notebook
- foundation، storage، application service و read-only session policy موجود است.
- UI نهایی، Checklist و Settings integration هنوز باقی است.
- timestamp یادداشت فقط داخل آروین است و نباید به Google/system Calendar منتقل شود.

### Calendar / Reminder
- Calendar foundation و regression fixes قبلی حفظ می‌شوند.
- Calendar rewrite ممنوع مگر نیاز جدید یا شکست واقعی.
- Reminder از timestamp ساده Note جداست.
- Google Calendar فقط برای eventهای مجاز محصول استفاده می‌شود.
- **اوقات شرعی شیعه و تعطیلات رسمی ایران باید به‌عنوان یادآورهای Calendar در همین مسیر قرار گیرند؛ منبع و روش محاسبه/داده باید مطابق قرارداد ثبت‌شده در PR #79 باشد و بدون حدس یا منبع غیررسمی جایگزین نشود.**
- PR #80 لایه source-neutral و mapping به `CalendarReminder` را اضافه و merge کرده است؛ Provider واقعی، اعتبارسنجی منبع و داده سال/مکان/Timezone هنوز باقی است.

### Backup / Dropbox
- Backup/Restore foundation موجود است.
- Dropbox providerها موجودند.
- تکمیل End-to-End و UI هنوز باقی است.

### Search
- SearchService روی Task/FollowUp موجود است.
- Search UI نباید قبل از تعیین مسیر نهایی Item/Home به‌صورت موازی به Legacy repository وصل شود.

### Widget
Widget باید از همان منبع اصلی Item/Reminder/FollowUp استفاده کند و Storage جدا نداشته باشد.
- نمایش Today / Overdue / Future در صورت وجود این مفاهیم در مدل نهایی
- Category/Tag filter فقط در صورت وجود واقعی آن قابلیت
- دکمه `+` برای افزودن سریع
- لمس برای بازکردن Item
- سبک و کم‌مصرف با background محدود
- RTL و IranSans
- **همین Widget باید در صورت پشتیبانی سیستم‌عامل/لانچر، روی صفحه قفل (Lock Screen) نیز قابل نمایش و استفاده باشد؛ صفحه قفل نباید منبع داده یا Storage جداگانه داشته باشد و باید از همان source of truth ویجت اصلی استفاده کند.**
- رفتار و محدودیت‌های Lock Screen باید در فاز Widget به‌صورت واقعی روی Android هدف پروژه اعتبارسنجی شود و در صورت محدودیت نسخه/لانچر، graceful fallback داشته باشد؛ قابلیت مصنوعی یا مسیر داده موازی ایجاد نشود.

### PDF / Print
- PDF برای Item و تاریخچه FollowUp و فهرست
- Share برای PDF
- Print برای یادداشت ساده نیز الزامی است.
- Print برای Item پیگیری‌دار با همه سوابق FollowUp
- Print و PDF دو مسیر مجزا هستند.

### Font
- فونت اصلی توافق‌شده: **IranSans / IranSansX(Eco)**
- اعمال نهایی در UI، Settings، Widget، PDF و Print باید End-to-End اعتبارسنجی شود.

## فازهای عملیاتی به‌روز
1. **Unified Item:** تکمیل migration/adapter بدون شکستن Legacy. ← **گلوگاه فعال معماری**
2. **Notebook UI:** Editor، auto-save، read-only/edit، Checklist و Settings؛ تست‌ها می‌توانند موازی آماده شوند.
3. **Home UX:** اتصال Item، FollowUp، Note، Sort، Swipe و Multi-select؛ بدون repository موازی.
4. **Search UI:** اتصال SearchService موجود به Home جدید.
5. **Calendar رسمی ایران:** Source Contract و mapping انجام شد؛ **Provider واقعی اوقات شرعی شیعه + تعطیلات رسمی ایران** و validation منبع، مکان، timezone، سال و تاریخ شمسی گام بعدی است.
6. **Widget:** تکمیل Widget روی همان source of truth، شامل بررسی پشتیبانی Lock Screen.
7. **PDF + Print:** خروجی برای Note، Item و فهرست.
8. **IranSans:** اعمال کامل در UI و خروجی‌ها.
9. **Reminder + Google Calendar:** integration با isolation برای Note.
10. **Backup + Restore + Dropbox:** End-to-End.
11. **E2E + Release:** APK نسخه‌دار، Artifact، checksum و Release documentation.

برای جزئیات Gateها، وابستگی‌ها و اجرای موازی، `docs/PROJECT_ROADMAP_2026-08-14.md` مرجع اجرایی این برنامه است.

## Definition of Done
هر قابلیت زمانی Done است که domain/application، persistence، UI واقعی، RTL/شمسی/فونت، regression tests، CI سبز و APK قابل استفاده داشته باشد و مستندات/AI handoff آن به‌روز باشد.
