# آروین — قرارداد SSOT و ممیزی سراسری جریان داده
**تاریخ ممیزی:** 2026-11-02  
**مبنای کد:** 3b29ead7d0cf8eaf8bc74ba079d7c4d0f4c24cd3  
**شاخه:** fix/recovery-calendar-device-smoke-2026-10-31  
**PR:** #3052 — OPEN / DRAFT / UNMERGED  
**وضعیت انتشار:** BLOCKED — RELEASE: NO-GO  
**نوع کار:** ممیزی خواندنی و ثبت مستندات؛ بدون تغییر کد، تست، Schema یا Migration.
---
## 1. تصمیم مالک محصول: SSOT مرکزی
تمام دسته‌ها، برچسب‌ها، پروژه‌ها و شعب/مراکز باید از یک هسته مرکزی مدیریت داده در بخش تنظیمات تغذیه شوند. تنظیمات، نقطه واحد مدیریت و فرمان‌دهی است؛ صفحات دیگر فقط مصرف‌کننده و نمایش‌دهنده داده معتبرند و نباید کاتالوگ یا مخزن موازی ایجاد کنند.
هر ایجاد، ویرایش، تغییر نام، غیرفعال‌سازی یا حذف مجاز باید از مسیر نوشتن canonical واحد انجام شود و پس از موفقیت پایدار، تغییر در تمام مصرف‌کنندگان مرتبط منعکس گردد:
- فرم ثبت سریع و فرم کامل ثبت/ویرایش؛
- پنج دسترسی سریع Home و مسیرهای مدیریت؛
- جست‌وجوی Home و نتایج چندنوعی؛
- فیلترهای Home و Reports؛
- تقویم داخلی و projectionهای مرتبط؛
- Branch Directory، Project list و جزئیات/تاریخچه.
هیچ فرم، کارت، فیلتر، صفحه یا projection مجاز نیست فهرست مستقل و ماندگار از Category، Tag، Project یا Branch نگه دارد. Snapshot محلی فقط برای نمایش/ویرایش موقت مجاز است و پس از mutation باید از منبع canonical تازه‌سازی یا از طریق سازوکار invalidation به‌روزرسانی شود.
این تصمیم الزام محصولی است؛ ثبت آن به معنی پیاده‌سازی یا پذیرش SSOT در HEAD ممیزی‌شده نیست.
## 2. مرزهای معماری هدف
1. Settings Management Hub تنها سطح مدیریت موجودیت‌های Category، Tag، Project و Branch/Center است. جزئیات تب‌ها و UX در این ممیزی تحمیل نمی‌شود.
2. مخزن/Repositoryهای canonical باید مالک خواندن و نوشتن پایدار باشند؛ صفحه‌های UI مالک داده نیستند.
3. mutationهای چندبخشی مانند تغییر نام Category/Tag و به‌روزرسانی ارجاع‌های Task باید یک عملیات سازگار و اتمیک باشند؛ شکست هر بخش نباید کاتالوگ و ارجاع‌ها را از هم جدا کند.
4. مصرف‌کنندگان باید به هویت/رابطه پایدار موجودیت متکی باشند؛ تطبیق متن نام Branch جایگزین رابطه Branch→Project نیست.
5. تغییرات موفق باید با refresh/invalidation قابل مشاهده به تمام سطوح باز و مسیرهای بازگشت از Settings منتشر شوند. هیچ وعده «فوری» بدون شواهد رفتار انتشار داده PASS محسوب نمی‌شود.
6. Branch دارای تاریخچه حذف مخرب نمی‌شود؛ Projectهای قدیمی بدون Branch همچنان معتبر می‌مانند. این قواعد با قرارداد محصولی بخش 17 Roadmap هم‌راستا هستند.
7. طراحی شناسه‌ها، نگاشت داده‌های فعلی Category و سیاست مهاجرت قبل از هر تغییر Schema باید جداگانه تصویب شود؛ این سند Migration یا مدل جدید را تجویز نمی‌کند.
## 3. ماتریس ممیزی جریان داده در HEAD مبنا
| حوزه/مصرف‌کننده | منبع و مسیر فعلی مشاهده‌شده | اتصال و تازه‌سازی مشاهده‌شده | حکم ممیزی |
|---|---|---|---|
| Settings | SettingsPage دو ورودی مستقل برای ProjectsLauncher و TaskTaxonomyManagementPage دارد. | مدیریت Project و Category/Tag جداست؛ Branch Directory مشاهده نشد. | SSOT Hub کامل: NOT IMPLEMENTED |
| Category catalog | TaskStore.loadCategories/createCategory/... روی taxonomy_categories در SQLite؛ مقدار استفاده‌شده نیز در Task.category ذخیره می‌شود. | Home کاتالوگ را در _categoryCatalog cache می‌کند؛ فرم‌ها knownCategories snapshot می‌گیرند. | دو نمایش/لایه هویتی؛ قرارداد یگانه نیازمند اصلاح طراحی |
| Tag catalog | جدول tags و رابطه task_tags در SQLite؛ TaskStore.loadTags و روابط Task را می‌خواند/می‌نویسد. | Home _tagCatalog را cache می‌کند؛ فرم‌ها knownTags snapshot می‌گیرند. | persistence مرکزی موجود است؛ انتشار سراسری زنده اثبات نشد |
| Category/Tag management | TaskTaxonomyManagementPage داده Task و دو کاتالوگ را جدا بارگذاری می‌کند؛ TaskTaxonomyMutationService ارجاع‌های Task را تغییر می‌دهد. | ذخیره Task و تغییر کاتالوگ در دو فراخوانی جدا انجام می‌شوند. | خطر ناسازگاری بین ارجاع و کاتالوگ؛ مورد P1 |
| Quick Capture | ورودی projects/knownCategories/knownTags به‌صورت لیست می‌رسد؛ callback ایجاد Category/Tag ویرایش محلی همان فرم را به‌روز می‌کند. | انتشار به Home/Calendar/Reports یا فرم‌های باز دیگر در این مسیر مشاهده نشد. | Snapshot محلی؛ نیازمند invalidation سراسری |
| Full Task Editor | ArvinTaskEditorDialog لیست‌های projects/knownCategories/knownTags را از caller می‌گیرد. | HomeTaskEditorContextService هنگام بازشدن دوباره از Store می‌خواند؛ فهرست درون فرم snapshot است. | بازخوانی هنگام ورود وجود دارد؛ live update هنگام بازبودن اثبات نشد |
| Home | HomePage._load، Taskها، Projectها، Category catalog و Tag catalog را جداگانه بارگذاری و در State نگه می‌دارد. | _createCategory/_createTag فقط Store را صدا می‌زنند؛ Home به‌طور خودکار catalog cache را در همان مسیر به‌روزرسانی نمی‌کند. بازگشت از Settings نیز در مسیر مشاهده‌شده _load را فراخوانی نمی‌کند. | stale snapshot محتمل و از مسیر کد پشتیبانی‌شده؛ مورد P1 |
| Home filters | Category از Task.category و کاتالوگ Home؛ Tag از Task.tags و کاتالوگ Home؛ Project از لیست Projectهای State. | فیلترها از snapshotهای صفحه استفاده می‌کنند. | وابسته به refresh Home؛ به‌روزرسانی فوری سراسری اثبات نشد |
| Home search | HomeSearchProjection به TaskSearchService متصل است؛ search fields شامل عنوان، توضیح، Category، Tag، checklist و متن Follow-up است. | فقط Task نتیجه می‌دهد. Project و Branch در این مسیر حضور ندارند. | Search چندموجودیتی: NOT IMPLEMENTED |
| Projects | ProjectStore روی همان دیتابیس arvin SQLite/Drift؛ جدول projects و project_items با Task ID canonical. | ProjectsLauncher پس از بازگشت به route خودش didPopNext و reload دارد؛ Home state والد مسیر reload متناظر ندارد. | persistence canonical موجود؛ propagation به Home نیازمند تکمیل |
| Branch/Center | در lib/models فهرست‌شده Branch model وجود ندارد؛ در G1DriftSchema جدول Branch/Center مشاهده نشد؛ BranchStore/Directory در lib/services و lib فهرست‌شده مشاهده نشد. | هیچ رابطه ساختاری Branch→Project یا Branch search قابل ردیابی نیست. | NOT IMPLEMENTED |
| Reports | ReportCenterPage یک snapshot از Taskها و Projectها می‌گیرد؛ Category/Tag گزینه‌ها از مقادیر استفاده‌شده در Taskها مشتق می‌شوند. | کاتالوگ‌های مستقل، Branch، Template و Period به عنوان ورودی این صفحه مشاهده نشدند. | گزارش Branch/Template/Period و فهرست کامل کاتالوگ: NOT IMPLEMENTED |
| Calendar | CanonicalCalendarLauncher یک snapshot از Taskها می‌گیرد؛ FollowUpCalendarProjection از Task/Reminder/Follow-up رویدادهای تقویم را می‌سازد. | CalendarReminder فیلد Category/Tag/Project/Branch ندارد؛ تقویم در این مسیر به کاتالوگ‌های تنظیمات وصل نیست. | جریان زمان‌بندی Task موجود؛ اتصال taxonomy/Project/Branch به Calendar: NOT VERIFIED / NOT IMPLEMENTED در مسیر مشاهده‌شده |
## 4. یافته‌های قطعی و ریسک‌ها
### F-01 — تغییر نام Category/Tag اتمیک نیست (P1)
در TaskTaxonomyManagementPage، ابتدا ارجاع‌های Task در حافظه تغییر می‌کنند و TaskStore.save اجرا می‌شود؛ سپس renameCategoryCatalog یا renameTagCatalog جداگانه اجرا می‌شود. این دو مرحله یک transaction مشترک ندارند.
نکته مهم‌تر: _persistMutation در خطای ذخیره، خطا را نمایش می‌دهد، reload می‌کند و بدون rethrow برمی‌گردد؛ caller پس از بازگشت همچنان تغییر نام کاتالوگ را اجرا می‌کند. بنابراین مسیر کد اجازه می‌دهد در صورت شکست ذخیره Task، تغییر کاتالوگ جلو برود و دو لایه از هم جدا شوند. این یک نقص قابل ردیابی در کنترل جریان است، نه صرفاً احتمال نظری.
### F-02 — Home و فرم‌ها snapshot محورند (P1)
Home فهرست‌های catalog و Project را در State نگه می‌دارد. callback ایجاد Category/Tag فقط Store را می‌نویسد و فرم محلی خود را به‌روز می‌کند. مسیر بازگشت از Settings به Home در کد مشاهده‌شده reload سراسری را فراخوانی نمی‌کند. HomeTaskEditorContextService هنگام بازشدن فرم مجدداً Store را می‌خواند، اما این جایگزین انتشار به صفحه‌های باز نیست.
### F-03 — Category دو نمایش پایدار دارد
Category در taxonomy_categories به‌عنوان کاتالوگ و در ستون tasks.category به‌صورت متن ذخیره می‌شود؛ رابطه FK بین این دو در Schema مشاهده نشد. این مدل می‌تواند با rename/delete دو مرحله‌ای از هم واگرا شود. تصمیم درباره شناسه پایدار و سازگاری داده‌های قدیمی، پیش از طراحی Migration لازم است.
### F-04 — Tag و Project در SQLite رابطه‌مندند، اما UI یکپارچه نیست
Tagها در tags و task_tags و Projectها در projects و project_items ذخیره می‌شوند. ProjectStore و TaskStore از پایگاه SQLite/Drift مشترک استفاده می‌کنند؛ با این حال Settings دو صفحه مدیریت مجزا دارد و مصرف‌کنندگان snapshotهای خود را دارند.
ProjectStore.save کل مجموعه Project و membership را داخل transaction پاک‌سازی و دوباره درج می‌کند. این عملیات در این ممیزی به‌عنوان رفتار موجود ثبت می‌شود؛ به‌تنهایی اثبات خرابی نیست، اما اثر آن بر هم‌زمانی، کارایی و حفظ ارجاع‌ها باید در طراحی آینده آزموده شود.
### F-05 — Branch و جستجوی چندموجودیتی وجود ندارند
Branch در مدل‌ها و Schema مشاهده‌شده وجود ندارد. Home search به TaskSearchService محدود است. بنابراین کارت Branch، جستجوی Project/Branch و فیلتر ساختاری Branch هنوز از کد موجود قابل اثبات نیستند.
### F-06 — Reports و Calendar از کاتالوگ مرکزی تغذیه نمی‌شوند
ReportCenterPage Category/Tag را از مقادیر Taskهای ورودی می‌سازد؛ کاتالوگ‌های خالی/استفاده‌نشده را نشان نمی‌دهد. Calendar از projection یادآورها و پیگیری‌ها استفاده می‌کند و در قرارداد CalendarReminder فیلدهای Category/Tag/Project/Branch دیده نشد. اتصال تغییرات کاتالوگ به این دو سطح تأیید نشده است.
### F-07 — کدهای هم‌پوشان/معلق نیازمند تعیین تکلیف
TaskTaxonomyLifecycleService و TaskTaxonomyMutationService عملیات هم‌پوشان Category/Tag دارند. TaskTaxonomyManagementPage از MutationService استفاده می‌کند. مالکیت مصرف سایر سرویس و حذف‌پذیری هر کد باید با جستجوی کامل شاخه و تست‌های مصرف‌کننده تعیین شود؛ در این ممیزی هیچ فایلی حذف یا تغییر نکرد.
TagStore با کلید قدیمی arvin.tags در کد موجود است؛ نبود call site در تمام شاخه با ابزار جستجوی فعلی به‌طور قطعی ثابت نشده است. بنابراین وضعیت آن CANDIDATE FOR ORPHAN AUDIT است، نه «کد مرده» قطعی.
## 5. تحلیل لاگ واقعی Timeout مرحله T13.5
### اجراهای بررسی‌شده
- File Persistence Run 41430574993، Job 125228304102.
- Build Run 41430577235، Shard شماره 2، Job 125228377887.
- تست: test/alarm_overlay_file_persistence_test.dart.
- کد مسیر: lib/alarm_overlay_page.dart، تابع _loadActiveReminder.
### توالی ثبت‌شده
در هر دو لاگ، پس از بازگشایی همان فایل SQLite، T13 با موفقیت ثبت شده است:
- File Persistence: T13 در 10:41:30.474 و T13.5 در 10:41:30.488.
- Build: T13 در 10:52:07.068411 و T13.5 در 10:52:07.068459.
پس از T13، تست به بررسی‌های Readback اولیه ادامه داده و سپس Widget دوم AlarmOverlay را mount کرده است. در تست، Readback اولیه شامل completed=false، حفظ dueDate، حفظ Follow-up history، وجود دو Reminder، تاریخ Snooze برابر 2026-11-01 13:10 و حفظ date/sequence یادآور sibling است. رسیدن به T13.5 نشان می‌دهد این assertions پیش از انتظار بعدی مانع ادامه تست نشده‌اند.
در T13.5 تست منتظر loadCompleted.future می‌ماند. لاگ هر دو اجرا پس از 10 دقیقه TimeoutException ثبت می‌کند. در Build نیز نتیجه نهایی 266 tests passed, 1 failed است.
### تحلیل مسیر واقعی کد
AlarmOverlayPage._loadActiveReminder ابتدا await _store.load() و سپس await _projects.load() را اجرا می‌کند. callback مربوط به onLoadComplete فقط پس از پایان هر دو عملیات، در مسیر موفق یا catch، فراخوانی می‌شود. در تست، T13.5 پیش از await کردن Completer ثبت می‌شود.
هیچ marker داخلی بین شروع/پایان TaskStore.load و ProjectStore.load در این مسیر وجود ندارد. بنابراین لاگ ثابت می‌کند که callback بارگذاری Overlay تا پایان مهلت به تست نرسیده است؛ اما مشخص نمی‌کند کدام یک از دو await بازنگشته است یا callback به دلیل lifecycle دیگری اجرا نشده است.
### نتیجهٔ ریشه‌یابی
- **علت مستقیم اثبات‌شده:** تکمیل lifecycle بارگذاری asynchronous در AlarmOverlay تا نقطه فراخوانی onLoadComplete مشاهده نشده و تست روی loadCompleted.future معطل مانده است.
- **آخرین مرز موفق اثبات‌شده:** بازگشایی فایل SQLite و Task readback اولیه تا T13، شامل Snooze و عدم تغییر Reminder مستقل.
- **مسیر Complete:** T13.6، T14، pointer tap واقعی، handler و readback نهایی Complete در این اجراها اصلاً مشاهده نشده‌اند.
- **علت داخلی دقیق (TaskStore.load در برابر ProjectStore.load یا lifecycle): NOT VERIFIED.** لاگ فعلی برای انتخاب یکی از این علت‌ها داده کافی ندارد. نسبت‌دادن قطعی مشکل به SQLite، قفل TaskStorageLock، ProjectStore یا Flutter test zone بدون marker اختصاصی، حدس و ممنوع است.
### حداقل شواهد لازم برای ممیزی بعدی
بدون تغییر تست یا حذف assertion، در یک اجرای مجاز آینده باید markerهای مستقل قبل/بعد از TaskStore.load، ProjectStore.load، setState، callback موفق/خطا و lifecycle/dispose ثبت شوند. سپس همان SHA باید مسیر T13.6 تا T14، tap واقعی، handler و بستن/بازگشایی همان فایل و readback نهایی را کامل کند. این پیشنهاد، مجوز تغییر کد یا اجرای workflow نیست.
## 6. وضعیت حاکمیتی و محدودیت دسترسی
- PR #3052 در استعلام فعلی OPEN / DRAFT / UNMERGED و HEAD برابر SHA مبنا است.
- Label برابر BLOCKED — RELEASE: NO-GO موجود است.
- Branch API مقدار protected=false را برای شاخه اجرایی گزارش کرده است.
- Ruleset فعال main-protection فقط refs/heads/main را هدف می‌گیرد؛ ruleset مشاهده‌شده به شاخه اجرایی PR اعمال نمی‌شود.
- endpoint جزئیات Branch Protection با خطای 403 در دسترس اتصال ممیزی نبود؛ بنابراین تنظیمات محافظت اختصاصی شاخه از آن endpoint خوانده نشد. با این حال فیلد protected=false و دامنه ruleset فعال نشان می‌دهند حفاظت سطح شاخه اجرایی در شواهد قابل مشاهده فعال نیست.
- این ممیزی هیچ تنظیم حفاظتی را تغییر نداده است. Label و Draft gate جایگزین branch protection فنی نیستند.
- هیچ کد، تست، assertion، Schema، Migration، dependency، APK، Release یا main تغییر نکرده است.
## 7. حکم ممیزی
**SSOT در HEAD مبنا: NOT IMPLEMENTED / PARTIAL FOUNDATIONS.**  
**معماری cross-feature: دارای شکاف‌های اتصال، snapshot و atomicity؛ پذیرش سراسری: NOT VERIFIED.**  
**T13.5: توقف async overlay-load اثبات شده؛ علت داخلی دقیق NOT VERIFIED.**  
**Release: BLOCKED — RELEASE: NO-GO.**
این سند گزارش وضعیت فعلی است، نه مجوز پیاده‌سازی. هر تغییر اجرایی، Schema/Migration یا اصلاح تست نیازمند دستور جداگانه مالک محصول است.
