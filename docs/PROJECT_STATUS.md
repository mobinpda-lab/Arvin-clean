# Arvin — Project Status

## مرجع فعلی
- Branch توسعه/مرجع: `main`
- آخرین Commit تثبیت‌شده در main قبل از Wave جاری: `2a8940a9646f549e5a1c317d9d894e59378ea3fa`
- Wave جاری: **Unified Item / Note / FollowUp foundation — Category compatibility**
- این سند باید همراه هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## قانون audit قبل از تغییر
قبل از هر تغییر محصولی باید main، کد واقعی، PRهای باز، CI اخیر، مستندات و پروژه‌های مرجع بررسی شوند. اگر قابلیت قبلاً حل شده باشد، دوباره‌سازی ممنوع است.

### Audit این Wave
- `main` و commitهای اخیر بررسی شدند.
- PRهای باز بررسی شدند؛ PR #77 مربوط به همین Unified Item foundation بود و پس از سبز بودن `Arvin Parallel Wave` و `Arvin Build` ادغام شد.
- `lib/models/task.dart` و `lib/services/task_store.dart` بررسی شدند.
- `lib/main.dart` بررسی شد و مرز Legacy `ArvinTask / TaskRepository` هنوز دست‌نخورده باقی مانده است.
- SearchService، Calendar، Notebook foundation و Backup/Dropbox به‌عنوان foundationهای موجود دوباره ساخته نشدند.
- Gap واقعی این Wave: Contract نهایی Category در مدل `Task` وجود نداشت.

## وضعیت CI
CI به چند مسیر موازی تقسیم شده است تا شکست یک حوزه، وضعیت حوزه‌های دیگر را مبهم نکند:

1. `Arvin Feature Validation` — analyze و مجموعه تست‌ها.
2. `Arvin FollowUp Validation` — مدل، TaskStore و UI تاریخچه FollowUp.
3. `Arvin Calendar Validation` — تست‌های Calendar.
4. `Arvin Backup Validation` — تست Backup/Restore.
5. `Arvin Release Validation` — Android audit، analyze، test، ساخت APK و upload artifact.

آخرین PR #77 پیش از merge با موفقیت `Arvin Parallel Wave` و `Arvin Build` را پشت سر گذاشت.

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

Wave جاری در `lib/models/task.dart` فقط به‌صورت additive این Contract را آماده می‌کند و مسیر Legacy UI را هنوز تغییر نمی‌دهد تا regression ایجاد نشود.

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
- **Print برای یادداشت ساده نیز الزامی است.**
- Print برای Item پیگیری‌دار با همه سوابق FollowUp
- Print و PDF دو مسیر مجزا هستند.

### Font
- فونت اصلی توافق‌شده: **IranSans / IranSansX(Eco)**
- اعمال نهایی در UI، Settings، Widget، PDF و Print باید End-to-End اعتبارسنجی شود.

## فازهای عملیاتی بعدی
1. **Unified Item:** تکمیل migration/adapter بدون شکستن Legacy.
2. **Notebook UI:** Editor، auto-save، read-only/edit، Checklist و Settings.
3. **Home UX:** اتصال Item، FollowUp، Note، Sort، Swipe و Multi-select.
4. **Search UI:** اتصال SearchService موجود به Home جدید.
5. **Widget:** تکمیل Widget روی همان source of truth، شامل بررسی پشتیبانی Lock Screen.
6. **PDF + Print:** خروجی برای Note، Item و فهرست.
7. **IranSans:** اعمال کامل در UI و خروجی‌ها.
8. **Reminder + Google Calendar:** integration با isolation برای Note.
9. **Backup + Restore + Dropbox:** End-to-End.
10. **E2E + Release:** APK نسخه‌دار، Artifact، checksum و Release documentation.

## Definition of Done
هر قابلیت زمانی Done است که domain/application، persistence، UI واقعی، RTL/شمسی/فونت، regression tests، CI سبز و APK قابل استفاده داشته باشد و مستندات/AI handoff آن به‌روز باشد.

## توسعه سریع اما کنترل‌شده
حوزه‌های مستقل به‌صورت موازی پیش می‌روند، اما هر Wave باید مستقل و کم‌خطر باشد. Commit، تست و Workflowهای مربوط به همان Wave باید بلافاصله پس از تغییر اجرا شوند؛ تغییرات قبلاً حل‌شده نباید تکرار شوند.
