# Arvin — Project Status

## مرجع فعلی
- Branch توسعه/مرجع: `main`
- Wave جاری: **Calendar رسمی ایران — Provider واقعی** + آماده‌سازی موازی Widget/FollowUp UX
- برنامه اجرایی به‌روز: `docs/PROJECT_ROADMAP_2026-08-14.md`
- آخرین Calendar implementation merge: PR #80 → commit `1f9c14386c50611d08254c4b70caa73c9108df16`
- این سند باید همراه هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## قانون audit قبل از تغییر
قبل از هر تغییر محصولی باید main، کد واقعی، PRهای باز، CI اخیر، مستندات و پروژه‌های مرجع بررسی شوند. اگر قابلیت قبلاً حل شده باشد، دوباره‌سازی ممنوع است.

## قانون توسعه سریع و موازی
حوزه‌های مستقل می‌توانند موازی پیش بروند، اما هیچ Wave موازی نباید foundation مشترک را بدون audit و هماهنگی تغییر دهد. هر تغییر باید یک Gap مشخص را ببندد و بلافاصله با تست، Commit و Workflowهای مربوط validation شود. نتیجه CI قبل از ادامه Wave وابسته بررسی می‌شود. تمام تصمیم‌ها، تغییرات و نتایج مهم باید در مستندات ثبت شوند.

## Use Case رسمی جدید — پیگیری زنجیره‌ای یک کار
یک Item می‌تواند یک کار/موضوع اصلی باشد و کاربر باید بتواند پیگیری‌های متعدد آن را پشت‌سرهم در همان Item ثبت کند، بدون ساخت Task یا Storage موازی.
- اقدام اصلی: `+ ثبت پیگیری` با کمترین تعداد کلیک.
- تاریخ و ساعت پیگیری به‌صورت خودکار ثبت و در صورت نیاز قابل ویرایش باشد.
- تمام FollowUpها در همان `FollowUps[]` و همان Item حفظ شوند.
- برای هر مرحله در صورت نیاز امکان تعیین Next FollowUp / Reminder وجود داشته باشد.
- Reminder بعدی از سابقه FollowUp جداست و نباید با timestamp پیگیری اشتباه شود.
- این Use Case باید در Home/FollowUp UI و تست‌های E2E به‌عنوان سناریوی اصلی سرعت ثبت پیگیری پوشش داده شود.

## Widget جدید — «پیگیری سریع»
علاوه بر Widgetهای عمومی پروژه، یک نمای اختصاصی برای پیگیری سریع تعریف شد:
- فقط **عنوان کار**.
- **تیتر/متن کوتاه آخرین پیگیری**.
- **تاریخ آخرین پیگیری**.
- **ساعت آخرین پیگیری**.
- تاریخ و ساعت باید در **یک خط** نمایش داده شوند.
- لمس Widget باید همان Item را باز کند.
- Widget باید از همان source of truth `Item/FollowUp` استفاده کند و Storage یا Database جدا نداشته باشد.
- RTL، فونت اصلی پروژه، سبک و کم‌مصرف بودن و refresh محدود مانند قرارداد Widget اصلی الزامی است.
- این Widget نیز در صورت پشتیبانی Android/Launcher باید روی Lock Screen قابل نمایش باشد و در دستگاه‌های فاقد پشتیبانی graceful fallback داشته باشد.
- لیست چندموردی باید **قابل اسکرول عمودی** باشد.
- Category و امکانات/فیلترهای سازگار Widget اصلی باید برای این Widget نیز قابل استفاده باشند.
- آخرین FollowUp نمایش داده می‌شود، نه Reminder بعدی؛ Reminder قابلیت جداگانه است.

## Audit فنی Widget — 2026-08-15
در بررسی مستقیم `main`، مسیر `android/app/src/main` فعلاً فقط `AndroidManifest.xml` دارد و implementation قطعی `AppWidgetProvider/RemoteViews` در مخزن پیدا نشد. همچنین `pubspec.yaml` فعلی dependency مشخصی برای Android App Widget ندارد. نتیجه: ساخت Quick FollowUp Widget به‌صورت مستقل و موازی در این نقطه ممنوع است؛ ابتدا باید یک **Widget Foundation مشترک و کنترل‌شده** ایجاد/تأیید شود، سپس Widget اصلی و Quick FollowUp Widget روی همان foundation پیاده شوند.

## برنامه اجرای سریع به‌روز
برای افزایش سرعت، کار به Laneهای مستقل تقسیم شده است: Architecture/Unified Item، Notebook UI، Home/Search، Calendar رسمی ایران، Widget/Lock Screen، Output/Font، Integrations/Data portability و E2E/Release. Laneهای مستقل می‌توانند همزمان آماده‌سازی و تست شوند؛ اما هیچ Lane اجازه ندارد برای سرعت foundation مشترک را موازی و ناسازگار تغییر دهد.

### گلوگاه‌های فعلی
- **Gate A — Unified Item adapter/migration:** گلوگاه معماری همچنان باید بدون شکستن Legacy تکمیل شود.
- **Gate D — Calendar رسمی ایران:** PR #80 با موفقیت merge شد و Source Contract/Mapping روی `CalendarReminder` تثبیت شده است؛ گام بعدی اتصال Providerهای واقعی و رسمی است.
- **Gate E — Widget Foundation:** implementation native AppWidget هنوز در `main` تثبیت نشده؛ قبل از Widget اصلی و Quick FollowUp Widget باید foundation مشترک ایجاد و با CI/Android audit تأیید شود.
- **FollowUp UX / Quick Widget:** Use Case جدید باید روی مدل موجود پیاده شود و نباید مدل یا Storage جدید ایجاد کند.

## Audit اخیر
- `main` و این مستندات دوباره بررسی شدند.
- مدل محصول همچنان Unified Item با `FollowUps[]` است؛ مسیر جداگانه Note/Task ایجاد نمی‌شود.
- Widget فعلی باید همان source of truth را مصرف کند؛ Widget پیگیری سریع نیز همین قرارداد را دارد.
- Lock Screen برای Widget به‌عنوان الزام محصولی ثبت شده و باید با همان source of truth ویجت اصلی اجرا شود.
- Android native tree بررسی شد؛ فعلاً `android/app/src/main/AndroidManifest.xml` تنها فایل native application source در این مسیر است و AppWidgetProvider/RemoteViews وجود ندارد.

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

### FollowUp
- مدل مستقل `FollowUp`
- نگهداری تاریخچه در Task
- migration از `followUpDate` قدیمی
- تاریخ/ساعت خودکار با امکان ویرایش
- UI تاریخچه در فاز تکمیل است.

### Calendar / Reminder
- Calendar foundation و regression fixes قبلی حفظ می‌شوند.
- Reminder از timestamp ساده Note جداست.
- اوقات شرعی شیعه و تعطیلات رسمی ایران باید به‌عنوان یادآورهای Calendar در همین مسیر قرار گیرند.

### Widget
Widget باید از همان منبع اصلی Item/Reminder/FollowUp استفاده کند و Storage جدا نداشته باشد.
- نمایش Today / Overdue / Future در صورت وجود این مفاهیم در مدل نهایی
- دکمه `+` برای افزودن سریع
- لمس برای بازکردن Item
- RTL و IranSans
- Lock Screen در صورت پشتیبانی
- **Quick FollowUp Widget:** عنوان کار + آخرین پیگیری + تاریخ و ساعت در یک خط؛ لیست اسکرول‌شونده، Category/امکانات سازگار Widget اصلی، بدون Reminder بعدی و بدون Storage جدا.
- **Foundation Gate:** ابتدا AppWidgetProvider/RemoteViews یا راهکار native معادل باید به‌صورت مشترک و قابل تست ایجاد شود؛ سپس Widgetهای محصولی ساخته شوند.

## فازهای عملیاتی به‌روز
1. **Unified Item:** تکمیل migration/adapter بدون شکستن Legacy. ← **گلوگاه فعال معماری**
2. **Notebook UI:** Editor، auto-save، read-only/edit، Checklist و Settings؛ تست‌ها می‌توانند موازی آماده شوند.
3. **Home UX:** اتصال Item، FollowUp، Note، Sort، Swipe و Multi-select؛ شامل UX ثبت سریع پیگیری زنجیره‌ای.
4. **Search UI:** اتصال SearchService موجود به Home جدید.
5. **Calendar رسمی ایران:** Provider واقعی اوقات شرعی شیعه + تعطیلات رسمی ایران.
6. **Widget:** **Widget Foundation مشترک** → تکمیل Widget اصلی و **Quick FollowUp Widget** روی همان source of truth، شامل بررسی Lock Screen.
7. **PDF + Print**
8. **IranSans**
9. **Reminder + Google Calendar**
10. **Backup + Restore + Dropbox**
11. **E2E + Release**

## Definition of Done
هر قابلیت زمانی Done است که domain/application، persistence، UI واقعی، RTL/شمسی/فونت، regression tests، CI سبز و APK قابل استفاده داشته باشد و مستندات/AI handoff آن به‌روز باشد.

## آخرین تغییر مستنداتی
- `docs/AI_HANDOFF_CURRENT_FA.md` با audit مستقیم Android Widget و وضعیت dependencyها به‌روزرسانی شد.
- commit این به‌روزرسانی: `a6b788de00cf8b2cd59d619eaf54bacad28ef196`
