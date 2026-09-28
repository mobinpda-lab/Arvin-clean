# Arvin — Live Remaining Work & Cross-Conversation Continuity Ledger
**Audit date:** 2026-09-28  
**Time basis:** Iran time  
**Repository:** `mobinpda-lab/Arvin-clean`

> این فایل مرجع پایدار فرمان «ادامه آروین» است. واقعیت GitHub بر حافظه گفتگو و گزارش‌های تاریخی مقدم است.

## 1. خط مبنا
- Current `main`: `cccda42e43f414d347d60b645c7be93ac3f58f54`
- Strategy: **PRODUCT FIRST + FACTORY MINIMAL**
- تغییر مستقیم روی `main`: ممنوع.
- تغییر محصول: Issue → Branch → Commit → PR.
- Storage / Model / Repository / Settings / Scheduler / Calendar engine موازی ایجاد نشود.
- داده واقعی کاربر حفظ شود.
- تصمیم‌های پرریسک معماری/Storage/Migration قبل از تغییر برگشت‌ناپذیر نیازمند بازبینی مستقل DeepSeek هستند.
- وجود کد به‌تنهایی «انجام شد» نیست؛ شواهد exact-head و پذیرش محصول لازم است.

## 2. وضعیت تأییدشده فعلی
- PR #1939 با HEAD `8bd91d9b8ea4557f5cf6279019981c25a3eaffc7` در 2026-09-28 با merge SHA `cccda42e43f414d347d60b645c7be93ac3f58f54` **MERGED** شد.
- Device Smoke #2832 روی همان HEAD پس از اجرای مجدد **SUCCESS** شد؛ هر ۶ سناریوی Home، Quick Capture، SQL Persistence، SQL Migration، Backup/Restore و People سبز شدند.
- Analyze، Full Test، Debug APK و Release APK برای HEAD #1939 نیز موفق بودند.
- PR #1902 custom recurrence قبلاً merge شده؛ پیاده‌سازی interval روز/هفته در main موجود است. پذیرش دستگاه واقعی آن هنوز **نامشخص** است.
- PR #1901 هنوز **OPEN** و بر اساس main قدیمی است؛ HEAD آن `964a55c46c92627c4e218bb816abda6b571e26da` و نباید مستقیم merge شود.
- PR #1936 اکنون stale است و به #1935 اشاره می‌کند؛ پس از این ledger باید supersede/close شود و منبع حقیقت همین فایل و main جدید است.
- Issue #1941 برای بهینه‌سازی CI بدون کاهش پوشش ثبت شد.

## 3. گلوگاه اصلی بعدی: #1901
#1901 یک بسته بزرگ 26 فایل/85 commit است و با main فعلی هم‌پایه نیست. راه درست:
1. مقایسه دقیق diff #1901 با main فعلی.
2. استخراج فقط تغییرات محصولی هنوز لازم.
3. هر تغییر مستقل در Issue/Branch/PR کنترل‌شده روی main فعلی.
4. هیچ rebase/merge کورکورانه و هیچ rewrite بزرگ انجام نشود.
5. برای هر lane: Analyze → Full Test → Debug/Release Build → Device Smoke exact HEAD.
6. پذیرش گوشی واقعی فقط برای مواردی که قرارداد آن را لازم می‌داند.

## 4. Remaining Product Work — P0/P1
### 4.1 Quick Add / Date-Time / Reminder
- مسیر Quick Add Date/Time فعلی پس از #1939 از نظر CI exact-head سبز است.
- Reminder Date/Time و تمام مسیرهای مرتبط هنوز باید در دستگاه واقعی/پذیرش محصول بررسی شوند.
- Date + Time هرجا هر دو وجود دارند یک ردیف باشند.
- Persian digits/RTL حفظ شود.
- Project / Category / Tag از Roll Box رنگی/آیکونی canonical با «ایجاد جدید» به‌عنوان آخرین گزینه استفاده کنند.
- مقدار تازه‌ساخته‌شده باید فوراً در selector قابل مشاهده باشد.

### 4.2 Roll Box / فرم‌ها — Issue #1934
- موعد / تکرار / یادآور و سپس تمام Date/Time selectorها به الگوی Roll Box یکپارچه نزدیک شوند.
- از `ArvinRollBox` موجود استفاده/گسترش داده شود؛ Widget/Storage/Model موازی ایجاد نشود.
- فازها: Quick Add → Task Editor/forms → Calendar/Defer/Reminder/time filters → audit کامل.
- این lane بعد از تثبیت P0 فعلی اجرا شود.

### 4.3 Home
- چهار گروه: زمان / پروژه‌ها / دسته‌ها / برچسب‌ها.
- Project view: Project + Category؛ Category view: Category؛ Tag view: Project + Category + Tag.
- فیلترها بدون reopen به‌روز شوند.
- کارت‌ها multiline و خوانا باشند؛ clipping در فونت بزرگ رخ ندهد.
- قرارداد رنگی/دسترسی‌پذیری حفظ شود.
- پذیرش تصویری نهایی روی دستگاه واقعی طبق قرارداد.

### 4.4 Calendar / Defer / Calendar Sync
- «ویرایش کارهای آروین».
- «ثبت کارهای آروین در تقویم پیش‌فرض گوشی».
- Settings → تقویم و همگام‌سازی با همان foundation موجود.
- Defer به Roll Box: یک ساعت / یک روز / یک هفته / یک ماه / تاریخ‌وساعت سفارشی.
- Done toggle: انجام شد ↔ فعال با همان Task canonical.
- بدون Calendar engine/store موازی.
- Provider/device evidence طبق قرارداد لازم است.

### 4.5 Overdue / Recurring Cleanup — #1930
- overdue با red semantic + calendar icon + معنی واضح «گذشته».
- × فقط موعد را حذف کند، Task حذف نشود.
- recurring cleanup کنترل‌شده و از مسیر canonical Task.
- exact-head Analyze/Test/Debug+Release/Device Smoke لازم است.

### 4.6 Task Editor / Taxonomy
- Project/Category/Tag در یک ردیف Roll Box رنگی/آیکونی.
- Tag چندانتخابی با checkmark.
- Create و Select مستقل.
- آیتم جدید فوراً در selector.
- Date+Time یک ردیف؛ Repeat+Priority یک ردیف.
- Completed ↔ Undone و Done/All مطابق قرارداد.
- مدیریت مرکزی Project/Category/Tag در Settings.
- Task و Notebook همان taxonomy canonical را مصرف کنند.

### 4.7 Notebook
- دفترچه مستقل؛ Checklist تب/صفحه مستقل نباشد.
- شماره خودکار / تیک / چک‌لیست inline و مستقل.
- Undo/Redo/autosave/reopen حفظ شود.
- Project/Category/Tag همان taxonomy Tasks.
- selectorها Roll Box درجا؛ Tag selection فعال.
- حذف Checklist/Shopping/Travel فقط بعد از dependency audit و بدون حذف داده.

### 4.8 Typography / Appearance
- font picker واقعی + preview.
- font size واقعی و app-wide.
- VazirHarf v34.003 پیش‌فرض.
- font اضافی فقط با source/license قابل اثبات.
- canonical AppSettingsService؛ settings store موازی ممنوع.
- رنگ‌ها semantic و دسترسی‌پذیر؛ رنگ تنها نشانه وضعیت نباشد.

## 5. CI — وضعیت و بهینه‌سازی
- `.github/workflows/build.yml` اکنون Analyze، شش test shard، Debug APK و Release APK را در jobهای مستقل اجرا می‌کند.
- `.github/workflows/device-smoke.yml` شش سناریوی مستقل را با matrix و `max-parallel: 6` اجرا می‌کند.
- بنابراین اصل Analyze ‖ Test ‖ Build ‖ Android Smoke **هم‌اکنون فعال است** و نباید با ادغام jobها کندتر شود.
- Issue #1941 فقط بهینه‌سازی‌های اندازه‌گیری‌شده را دنبال می‌کند: balance واقعی shardها، کاهش setup تکراری فقط در صورت کاهش wall-clock، و حفظ کامل پوشش.
- هیچ کاهش تست، حذف Smoke، یا استفاده از CI قدیمی برای SHA جدید مجاز نیست.

## 6. Acceptance / Release gates
برای هر تغییر محصولی:
1. Analyze
2. Full Test
3. Debug Build
4. Release Build
5. Device Smoke روی exact HEAD
6. نصب همان APK exact HEAD روی گوشی واقعی، هرجا قرارداد آن را لازم کرده
7. owner acceptance checklist
8. ثبت evidence با SHA دقیق

**Release-Ready هنوز ثابت نشده است.**

## 7. کنترل مسیرهای قدیمی
- #1901: باز و نیازمند re-audit؛ merge مستقیم ممنوع.
- #1892 / #1890 / #1887 / #1885 / #1847 / #1844 و سایر PRهای قدیمی: قبل از هر استفاده، با main فعلی مقایسه شوند.
- #1936: stale؛ باید supersede/close شود.
- #1941: CI optimization lane، مستقل از محصول و بدون ایجاد ریسک برای P0.

## 8. قانون ادامه در گفتگو/اکانت جدید
با دریافت «ادامه آروین»:
1. همین فایل را بخوان.
2. main فعلی و PRهای باز را دوباره بخوان.
3. exact-head CI را مجدداً بررسی کن.
4. بالاترین lane ناتمام را انتخاب کن.
5. کارهای مستقل را موازی و کارهای مشترک را ترتیبی اجرا کن.
6. هر تغییر محصولی را با Issue + Branch + PR انجام بده.
7. evidence نبود = «نامشخص».
8. Storage/Model/Repository/Settings/Calendar engine موازی نساز.
9. هدف نهایی: محصول قابل استفاده و Release-Ready؛ کارخانه فقط وسیله است.

## 9. جمع‌بندی زنده
- #1939 P0: **MERGED + exact-head CI سبز**.
- Device Smoke #2832: **SUCCESS** روی HEAD #1939.
- #1901: **OPEN / نیازمند استخراج تغییرات لازم روی main فعلی**.
- #1934: **آماده شروع پس از تعیین تکلیف laneهای بالاتر**.
- #1930: **ثبت‌شده و نیازمند اجرای کنترل‌شده**.
- CI parallelization: **از قبل فعال است؛ Issue #1941 برای بهینه‌سازی مبتنی بر اندازه‌گیری ثبت شده**.
- Release-Ready کل آروین: **نامشخص / هنوز اثبات نشده**.
