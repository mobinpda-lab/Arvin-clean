# Arvin — Project Status

## مرجع فعلی
- Branch توسعه/مرجع: `main`
- Wave جاری: **Unified Item / Note / FollowUp foundation — Category compatibility**
- برنامه اجرایی به‌روز: `docs/PROJECT_ROADMAP_2026-08-14.md`
- مستند نیاز جدید تقویم: `docs/CALENDAR_OFFICIAL_REMINDERS_2026-08-14.md`
- این سند باید همراه هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## قانون audit قبل از تغییر
قبل از هر تغییر محصولی باید main، کد واقعی، PRهای باز، CI اخیر، مستندات و پروژه‌های مرجع بررسی شوند. اگر قابلیت قبلاً حل شده باشد، دوباره‌سازی ممنوع است.

## قانون توسعه سریع و موازی
حوزه‌های مستقل می‌توانند موازی پیش بروند، اما هیچ Wave موازی نباید foundation مشترک را بدون audit و هماهنگی تغییر دهد. هر تغییر باید یک Gap مشخص را ببندد و بلافاصله با تست، Commit و Workflowهای مربوط validation شود. نتیجه CI قبل از ادامه Wave وابسته بررسی می‌شود. تمام تصمیم‌ها، تغییرات و نتایج مهم باید در مستندات ثبت شوند.

### Audit اخیر
- مستندات پروژه، roadmap و Calendar foundation دوباره بررسی شدند.
- Lock Screen برای Widget به‌عنوان الزام محصولی ثبت شده است.
- `CalendarPage` فعلی یک مدل خواندنی `CalendarReminder` دارد و Calendar نباید بدون Gap واقعی بازنویسی شود.
- نیاز جدید محصول: اوقات شرعی شیعه بر مبنای روش/اطلاعات مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران و تعطیلات رسمی ایران باید به‌صورت reminderهای تقویمی نمایش داده شوند.
- جزئیات منبع، مکان، cache، مرزبندی داده و تست در `docs/CALENDAR_OFFICIAL_REMINDERS_2026-08-14.md` ثبت شده است.

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
- **اوقات شرعی شیعه** باید به‌عنوان reminder تقویمی و بر مبنای روش/اطلاعات مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران ارائه شود؛ زمان‌ها باید برای مکان انتخابی کاربر معتبر باشند و در صورت نیاز مکان فعلی یا شهر انتخابی پشتیبانی شود.
- **تعطیلات رسمی ایران** باید به‌عنوان reminder تقویمی از تقویم رسمی کشور و مناسبت‌های مصوب نمایش داده شوند؛ داده باید سال‌به‌سال و در صورت اصلاحیه قابل به‌روزرسانی باشد.
- این دو منبع باید خواندنی و قابل تشخیص از Reminderهای کاربر باشند و نباید Storage مستقل برای Itemها ایجاد کنند.
- نمایش در تقویم آروین به‌تنهایی به معنی ارسال به Google/system Calendar نیست.
- جزئیات اجرایی و منبع در `docs/CALENDAR_OFFICIAL_REMINDERS_2026-08-14.md` ثبت شده است.

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
1. **Unified Item:** تکمیل migration/adapter بدون شکستن Legacy. ← **گام فعال فعلی**
2. **Notebook UI:** Editor، auto-save، read-only/edit، Checklist و Settings.
3. **Home UX:** اتصال Item، FollowUp، Note، Sort، Swipe و Multi-select.
4. **Search UI:** اتصال SearchService موجود به Home جدید.
5. **Widget:** تکمیل Widget روی همان source of truth، شامل بررسی پشتیبانی Lock Screen.
6. **Calendar official sources:** اتصال اوقات شرعی شیعه و تعطیلات رسمی ایران به `CalendarReminder` با منبع معتبر، مکان صحیح و داده سالانه قابل به‌روزرسانی.
7. **PDF + Print:** خروجی برای Note، Item و فهرست.
8. **IranSans:** اعمال کامل در UI و خروجی‌ها.
9. **Reminder + Google Calendar:** integration با isolation برای Note و مرزبندی روشن با منابع رسمی Calendar.
10. **Backup + Restore + Dropbox:** End-to-End.
11. **E2E + Release:** APK نسخه‌دار، Artifact، checksum و Release documentation.

برای جزئیات Gateها، وابستگی‌ها و اجرای موازی، `docs/PROJECT_ROADMAP_2026-08-14.md` مرجع اجرایی این برنامه است.

## Definition of Done
هر قابلیت زمانی Done است که domain/application، persistence، UI واقعی، RTL/شمسی/فونت، regression tests، CI سبز و APK قابل استفاده داشته باشد و مستندات/AI handoff آن به‌روز باشد.
