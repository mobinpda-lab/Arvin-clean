# گزارش یکپارچه پروژه آروین — 2026-10-12

> این گزارش یک نمای مدیریتیِ قابل پیگیری از وضعیت پروژه است؛ جایگزین حافظه‌های تخصصی، ADRها، Issueها یا شواهد خام CI نیست. وضعیت زنده GitHub بر هر snapshot تاریخی مقدم است. وضعیت‌ها فقط تا جایی «تأییدشده» هستند که لینک و SHA مشخص شده باشد.

## 1. خلاصه مدیریتی

- **وضعیت محصول:** در حال توسعه و تثبیت؛ **آماده انتشار نیست (Release NO-GO)**.
- **مخزن:** [mobinpda-lab/Arvin-clean](https://github.com/mobinpda-lab/Arvin-clean)، شاخه هدف `main`.
- **مبنای شاخه گزارش:** `a4dae51e93d9b3dcbc55ded366280e59183f16bc`؛ این SHA مبنای PR پاک‌سازی #2619 و آخرین commit گزارش‌شده در جست‌وجوی commitهای مخزن هنگام تهیه گزارش است. قبل از merge باید main دوباره خوانده شود.
- **پاک‌سازی مخزن:** PR [#2619](https://github.com/mobinpda-lab/Arvin-clean/pull/2619) باز و ادغام‌نشده است. سر PR برابر `433c337327a031c5008f4a63c2b2759847309c39`.
- **اعتبارسنجی PR #2619:** Build و هر شش سناریوی Device Smoke روی همان SHA موفق شده‌اند. این نتایج CI شبیه‌سازند، نه پذیرش روی گوشی واقعی.
- **موانع اصلی:** پذیرش فیزیکی Calendar و Backup/Restore، یکپارچه‌سازی امن PRهای هم‌پوشان Task Form/Time Picker/Report UI، تکمیل ممیزی Project/Category/Tag، و تأیید صریح مالک.
- **قاعده انتشار:** Issue [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) باز بماند تا همه شواهد و پذیرش‌های لازم واقعاً ثبت شوند.

## 2. وضعیت GitHub و شواهد قابل اتکا

### 2.1 پاک‌سازی و حافظه پروژه

PR [#2619 — حذف محتوای یتیم و یکپارچه‌سازی Backup](https://github.com/mobinpda-lab/Arvin-clean/pull/2619)

- Head: `433c337327a031c5008f4a63c2b2759847309c39`
- Build: [run 38209828960](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38209828960) — موفق: Analyze، test shardهای 0 تا 5، Debug APK و Release APK.
- Device Smoke: [run 38209828949](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38209828949) — هر شش lane موفق: Home، Quick Capture، People، SQL Persistence، SQL Migration و Backup/Restore.
- PR باز، ادغام‌نشده و از دید GitHub قابل ادغام گزارش شده است. شواهد CI به همین SHA مربوط است؛ هر commit جدید نیازمند بررسی وضعیت دقیق سر جدید است.
- بازبینی حذف‌ها و محتوای منتقل‌شده همچنان لازم است؛ سبز بودن CI به‌تنهایی اثبات نمی‌کند که هر حذف از نظر محصولی صحیح است.

کارهای اصلی در PR:
- حذف سند patch یتیم v48.1 که companion لازم آن در درخت جاری نبود؛ v48.2 و فرمان جاری v8 حفظ شده‌اند.
- حذف snapshotهای قدیمی وضعیت و handoff که SHA و وضعیت‌های منسوخ را تکرار می‌کردند.
- ادغام قرارداد UI تکراری در `docs/ARVIN_UI_CANONICAL.md`.
- حذف Workflow دستیِ نمایشی `arvin-task-dispatcher.yml` که فقط echo اجرا می‌کرد و caller شناخته‌شده‌ای نداشت.
- حذف `lib/services/backup_service.dart` به‌دلیل نبود ارجاع داخلی و وجود پیاده‌سازی canonical مبتنی بر SAF؛ فایل متفاوت `lib/backup_service.dart` حذف نشده است.
- ادغام دو فایل Dropbox provider در یک پیاده‌سازی canonical و حفظ seam تزریق HTTP و تست‌ها.

### 2.2 تغییرات Backup و Calendar که قبلاً ادغام شده‌اند

- [PR #2585 — حفظ داده قابل انتقال و Restore امن](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): ادغام شده در `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. تغییرات شامل پوشش rollback برای کاتالوگ‌های Category/Tag و آزمون‌های تزریق خطا در مسیرهای orchestration است. وجود commit، به‌تنهایی پذیرش کامل بازیابی روی فایل واقعی و گوشی را ثابت نمی‌کند.
- [PR #2569 — حفظ Calendar Event Link هنگام Restore](https://github.com/mobinpda-lab/Arvin-clean/pull/2569): ادغام شده در `598fe6511d8c5ff7f991aca51c4c435d3a05f350`.
- [PR #2570 — به‌روزرسانی رویداد مرتبط پس از ویرایش Task](https://github.com/mobinpda-lab/Arvin-clean/pull/2570): ادغام شده در `34a6cee9ae05ad1cf632960b96e98f2a5448e128`.
- این ادغام‌ها پایه پیاده‌سازی‌اند؛ هنوز باید رفتار واقعی «ویرایش همان رویداد، بدون ساخت رویداد تکراری» و نگهداری لینک پس از Restore روی دستگاه و فایل واقعی پذیرفته شود.

### 2.3 وضعیت PRهای فعال و هم‌پوشان

این PRها نباید مستقل و بدون یکپارچه‌سازی نهایی ادغام شوند:

| PR | هدف | وضعیت مشاهده‌شده | اقدام بعدی |
|---|---|---|---|
| [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591) | Universal Arvin Time Picker | باز، Draft؛ head `eae0394` | مبنای مشترک زمانی را با PRهای وابسته تطبیق بده و CI دقیق head را تأیید کن. |
| [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595) | فرم Task ساده‌اول و نمایش تدریجی | باز، Draft؛ base روی شاخه #2591 | فقط با قرارداد canonical Description و پس از حل تعارض‌ها ادغام شود. |
| [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602) | اصلاح ترتیب Taxonomy و نمایش تدریجی Task Editor | باز، Draft؛ GitHub در آخرین بررسی mergeable=false؛ head `1ddea0c` | سه اصلاح harness ثبت شده‌اند، اما CI دقیق این head هنوز تأیید نشده بود؛ ابتدا CI معتبر بگیر و تعارض را حل کن. |
| [#2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607) | گسترش زبان بصری pastel و کارت‌های فشرده | باز، Draft؛ GitHub در آخرین بررسی mergeable=false؛ base قدیمی‌تر | rebase/تطبیق کنترل‌شده با main، رفع تعارض و اعتبارسنجی Report Center و RTL. |

**تصمیم قطعی داده:** مالک گزینه «فقط Description» را انتخاب کرده است. مدل اصلی Task باید فیلد موجود `description` را نگه دارد؛ فیلد ریشه‌ای جدید `Task.note`، کلید ذخیره‌سازی، قرارداد serialization، migration یا فیلد Backup جدید اضافه نشود. مفاهیم Note در Notebook یا FollowUp که از قبل وجود دارند، حذف نمی‌شوند. منبع تصمیم و زمینه در [PR #2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595) و [PR #2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602) پیگیری شود.

## 3. قراردادهای معماری غیرقابل نقض

1. **Task تنها منبع حقیقت برای کارهای قابل اقدام است.** Quick Add و Full Form باید همان Task را بسازند یا ویرایش کنند.
2. **Checklist و Repeat متعلق به Task هستند.** تکرار نباید Task ریشه‌ای کپی بسازد؛ تاریخچه گذشته تغییرناپذیر و برنامه آینده قابل تنظیم است.
3. **Calendar یک projection از Task است، نه مالک Task.** ابتدا CREATE و سپس UPDATE EXISTING بر اساس Task ID و External Event ID؛ تشخیص بر اساس عنوان/تاریخ ممنوع.
4. **Taxonomy فقط سه مفهوم دارد:** Project، Category و Tag. «گروه» در معنای محصولی مترادف Category/«دسته» است، نه موجودیت چهارم؛ «گروه‌بندی» فقط برای نمایش مجاز است.
5. **Home و Report مالک Storage نیستند.** Report Center باید مصرف‌کننده فقط‌خواندنی داده canonical باشد؛ Calendar، Widget، Home و گزارش منبع داده مستقل نسازند.
6. **Tracking جایگزین CRM یا مدل مستقل نیست.** Repeat Tracking Level از Follow-up متمایز است و در مدل Repeat موجود قرار می‌گیرد.
7. **Backup/Restore باید هویت و روابط داده را حفظ کند:** Task، Project، کاتالوگ‌های Category/Tag حتی در صورت عدم استفاده، تنظیمات، تاریخچه تکرار و Calendar Linkها. rollback باید تمام storeهای تغییرکرده را پوشش دهد.
8. **هیچ تغییر مدل، migration، serialization یا فرمت Backup پرریسک بدون تصمیم مالک، طرح rollback و آزمون سازگاری انجام نشود.**

منابع تصمیم و پیگیری:
- [Issue #2580 — ممیزی سراسری Project/Category/Tag](https://github.com/mobinpda-lab/Arvin-clean/issues/2580)
- [Issue #2582 — ثبت تصمیم PCTADP](https://github.com/mobinpda-lab/Arvin-clean/issues/2582)
- [Issue #2605 — معماری Repeat Tracking Level](https://github.com/mobinpda-lab/Arvin-clean/issues/2605)
- [Issue #2026 — ممیزی و پاک‌سازی کم‌ریسک کل کد](https://github.com/mobinpda-lab/Arvin-clean/issues/2026)

## 4. قابلیت‌ها و وضعیت محصول

### 4.1 Task و فرم‌ها
- مسیر canonical همان Task موجود است؛ ایجاد Storage یا Model موازی ممنوع.
- فرم باید اولویت را به عنوان، توضیحات، تاریخ/زمان و فیلدهای اصلی بدهد؛ جزئیات پیشرفته تدریجی نمایش داده شوند.
- ترتیب taxonomy و تعامل‌های recurrence/time picker در PRهای #2591/#2595/#2602 هم‌پوشانی دارند؛ یک integration head واحد و تست‌شده لازم است.
- مالکیت ریشه‌ای متن Task روی `description` تثبیت شده است.

### 4.2 Repeat و Tracking
- مسیر مفهومی: `Task → Repeat Definition → Occurrence projection → Execution State → History`.
- مدل موجود `RecurrenceTrackingLevel.normal/tracking` در `Task.recurrence` ذخیره می‌شود؛ مقادیر مفقود legacy باید به normal برگردند.
- زبان UI مورد نظر: «نوع پیگیری»، گزینه‌های «عادی» و «مهم و قابل پیگیری».
- پیاده‌سازی کامل در Create/Edit، Task Detail، نشانه محدود Home، Report Center، حفظ history/checklist و Backup round-trip هنوز نیازمند اعتبارسنجی و پذیرش end-to-end است.
- Issue #2605 باز است؛ قابلیت را آماده انتشار تلقی نکن.

### 4.3 Report Center و رابط کاربری
- گزارش باید از داده canonical بخواند و مالک داده یا موتور موازی نشود.
- فیلترها باید با قواعد مشخص عمل کنند: OR درون هر گروه انتخاب و AND بین گروه‌ها؛ Project، Category، Tag، Status و Tracking مستقل باقی بمانند.
- انتخاب بازه تاریخ باید از انتخاب‌گر فارسی/Jalali مشترک استفاده کند.
- PR #2607 شامل بخش‌هایی از UI و Report Center است، اما Draft و از نظر integration/CI/RTL پذیرش کامل ندارد.
- قرارداد هویت بصری باید حفظ شود: «بسم الله الرحمن الرحیم»، عنوان «مدیریت کارها و پیگیری آروین»، چهار فیلتر/نمای زمان/پروژه/دسته/برچسب، رنگ indigo با `#4A4CAB`، RTL فارسی و Bottom Navigation اختصاصی آروین.
- گزارش تجربه کاربر در حافظه پروژه می‌گوید کاربر در 2026-10-09 نبود اقدامات «ثبت در تقویم گوشی» و «ویرایش» را در نمای Calendar گزارش کرده است؛ این گزارش تا وقتی با شواهد فعلی بررسی و پذیرش نشود، نباید خودکار «حل‌شده» علامت بخورد.

## 5. موانع انتشار — Issue #2102

[Issue #2102 — Release Gate](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) باید باز بماند تا همه موارد زیر با شواهد واقعی تکمیل شوند:

- [ ] پذیرش روی گوشی واقعی: ویرایش Task متصل به Calendar همان رویداد قبلی را به‌روزرسانی کند و Duplicate Event ایجاد نشود.
- [ ] Backup/Restore واقعی با Android file provider، شامل بازیابی/rollback و حفظ داده‌های کاربر.
- [ ] حفظ و صحت Calendar Linkهای بازیابی‌شده.
- [ ] Golden Flow کامل روی نسخه نصب‌شده.
- [ ] پذیرش فارسی/RTL، تایپوگرافی و صفحه‌نمایش فشرده.
- [ ] بررسی Release Notes، Installation Guide، User Guide، Known Issues، Architecture Summary و Evidence Report.
- [ ] تأیید صریح مالک محصول.
- [ ] بررسی رفتار guarded release workflow پس از بسته‌شدن واقعی gate؛ هیچ انتشار عمومی یا ادعای Release Ready قبل از آن مجاز نیست.

**تفکیک شواهد:** CI و emulator smoke برای SHA مشخص‌شده موفق‌اند؛ این نتیجه معادل پذیرش فیزیکی، صحت داده روی گوشی، یا تأیید مالک نیست.

## 6. فهرست مسائل باز و ریسک‌ها

| اولویت | مسئله | وضعیت / پیگیری |
|---|---|---|
| P0 | از دست رفتن داده یا restore ناقص | PR #2585 پوشش rollback را تقویت کرده؛ round-trip روی فایل واقعی و دستگاه هنوز باید اثبات شود. |
| P0 | Duplicate Calendar Event یا لینک خراب | PRهای #2569/#2570 ادغام شده‌اند؛ پذیرش فیزیکی همچنان باز است. |
| P0 | انتشار پیش از پذیرش محصول | Issue #2102 باز؛ انتشار NO-GO. |
| P1 | یکپارچه‌سازی Task Form/Time Picker | #2591/#2595/#2602 هم‌پوشان و Draft؛ یک integration head با CI دقیق لازم است. |
| P1 | UI و Report Center | #2607 Draft و غیرقابل ادغام بدون تطبیق؛ RTL و رفتار فیلترها نیازمند پذیرش هستند. |
| P1 | ناسازگاری Taxonomy | Issue #2580 باز؛ ممیزی سراسری باید با مسیر فایل، طبقه‌بندی، تست و شواهد تکمیل شود. |
| P2 | پاک‌سازی مخزن و مستندات | Issue #2026 و PR #2619؛ حذف‌های کم‌ریسک انجام شده‌اند، اما review کامل و merge هنوز لازم است. |
| P2 | تکرار بیش از حد اجرای release orchestration و صف AUTO-FIX | داده تاریخی حافظه از حجم بالا خبر می‌دهد؛ قبل از حذف Workflowها باید trigger graph و وابستگی‌ها ممیزی شود. |

## 7. شواهد CI و معنی آن‌ها

### تأییدشده روی head فعلی PR #2619
- Build run [38209828960](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38209828960): همه jobهای مشاهده‌شده موفق.
- Device Smoke run [38209828949](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38209828949): هر شش سناریو موفق.
- SHA مورد آزمایش: `433c337327a031c5008f4a63c2b2759847309c39`.

### تأییدشده در گذشته، نه جایگزین وضعیت زنده
- Build و Device Smoke روی SHAهای قدیمی‌تر، شواهد تاریخی‌اند و نباید به‌عنوان اعتبارسنجی head جدید یا main فعلی معرفی شوند.
- PR #2602 در آخرین وضعیت ثبت‌شده هنوز برای head `1ddea0c9e6481dbf944f70f4faceb91499908c80` شواهد CI نهایی نداشت.
- نتیجه ترکیبی commit روی SHA بدون status، موفقیت تلقی نمی‌شود.
- تغییر هر فایل بعد از CI، لزوم بررسی مجدد exact-head را ایجاد می‌کند.

## 8. برنامه اجرایی یکپارچه

### گام 1 — تکمیل و بازبینی PR #2619
1. تأیید کن Build و شش smoke lane هنوز برای head دقیق `433c337...` سبز هستند.
2. بازبینی دستی حذف‌ها، انتقال محتوای UI، سرویس Backup و Dropbox provider را تکمیل کن.
3. main و base comparison را تازه بخوان؛ سپس بازبینی رسمی و تصمیم merge را انجام بده. بدون مجوز لازم، ادغام نکن.

### گام 2 — integration واحد برای PRهای محصول
1. از main تازه یک integration branch بساز؛ #2591/#2595/#2602/#2607 را مستقل merge نکن.
2. قرارداد قطعی Description-only را اعمال کن و از ورود root `Task.note` جلوگیری کن.
3. اصلاح‌های harness در #2602 را با اجرای واقعی تست اعتبارسنجی کن؛ assertionها را برای سبز شدن CI تضعیف نکن.
4. حل تعارض‌ها را به ترتیب وابستگی انجام بده؛ به‌ویژه Time Picker مشترک، Task Form، taxonomy order و Report UI.
5. اجرا کن: Analyze، همه شش test shard، Debug/Release APK، Device Smoke مرتبط و بررسی exact-head.
6. تنها پس از نتیجه معتبر و review، درباره آماده‌بودن PR برای ادغام تصمیم بگیر.

### گام 3 — ممیزی و پذیرش داده
1. Issue #2580 را با ماتریس مسیرهای UI، model/store، serialization، Backup/Restore، tests و docs تکمیل کن.
2. رفتار rollback و بازیابی کاتالوگ‌های Category/Tag را با failure injection و round-trip واقعی بررسی کن.
3. روی گوشی واقعی Calendar same-event/update-existing و نگهداری لینک پس از Restore را ثبت کن.
4. Golden Flow، RTL/compact screen و نصب را با شواهد تصویری و نتیجه قابل بازتولید مستند کن.

### گام 4 — تحویل و انتشار
1. فایل‌های Release Notes، Installation Guide، User Guide، Known Issues، Architecture Summary و Evidence Report را کامل کن.
2. همه شواهد را به Issue #2102 پیوند بده.
3. فقط پس از تکمیل gate و تأیید صریح مالک، Release Closure را دوباره اعتبارسنجی کن.
4. پس از هر merge، main و CI پس از merge را دوباره بررسی کن؛ شواهد PR قبلی را به main جدید تعمیم نده.

## 9. فهرست اسناد مرجع

- وضعیت اجرا: `docs/arvin-memory/ARVIN_EXECUTION_STATE.md`
- ثبت تصمیم‌ها: `docs/arvin-memory/ARVIN_DECISION_LOG.md`
- دانش پروژه: `docs/arvin-memory/ARVIN_PROJECT_KNOWLEDGE.md`
- تجربه کاربر: `docs/arvin-memory/ARVIN_USER_EXPERIENCE_LOG.md`
- ثبت مشکلات: `docs/arvin-memory/ARVIN_PROBLEM_REGISTER.md`
- نقشه شواهد: `docs/arvin-memory/ARVIN_EVIDENCE_MAP.md`
- ممیزی پاک‌سازی: `docs/arvin-memory/ARVIN_REPOSITORY_CLEANUP_AUDIT_2026-10-12.md`
- قرارداد UI canonical: `docs/ARVIN_UI_CANONICAL.md`
- مرجع اجرا و gateها: Issue #2102، #2026، #2580، #2582، #2605 و PRهای #2591/#2595/#2602/#2607/#2619.

## 10. محدودیت‌های گزارش

- این گزارش، نمای تجمیعی است؛ جایگزین بازبینی فایل‌های کد یا مشاهده همه شواهد خام نمی‌شود.
- اطلاعات وضعیت branch/PR/CI در GitHub ممکن است تغییر کند. پیش از هر merge، release یا تغییر داده باید وضعیت زنده دوباره بررسی شود.
- هیچ داده‌ای درباره نصب یا استفاده واقعی کاربر، مدل گوشی، نسخه نصب‌شده یا بازخورد تازه در این گزارش اختراع نشده است.
- نبود شواهد، به‌معنی موفقیت نیست. هر gate فاقد مدرک در وضعیت «باز/تأییدنشده» می‌ماند.

## خلاصه تصمیم

**پروژه در حال پیشرفت است؛ PR پاک‌سازی #2619 از نظر Build و شش سناریوی شبیه‌ساز موفق شده اما هنوز ادغام نشده است. Release NO-GO می‌ماند.** اولویت عملی بعدی: بازبینی و تکمیل #2619، ساخت یک integration head واحد و معتبر برای PRهای هم‌پوشان، سپس تکمیل پذیرش فیزیکی Calendar و Backup/Restore و ثبت شواهد در Issue #2102.
