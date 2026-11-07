

## یکپارچه‌سازی رنگ حالت انتخاب‌شده در تم سراسری — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `50b1e99164fea7c03110e2641c786a78f8c94752`

- رنگ انتخاب‌شدهٔ پنج فیلتر Home و پنج فیلتر مشترک Report Center اکنون از `ArvinColors.primary` و `primarySoft` استفاده می‌کند؛ رنگ accent هر بُعد فقط در حالت غیرفعال/نشانهٔ معنایی باقی می‌ماند.
- چیپ‌های فیلتر فعال نیز فیروزه‌ای هستند. `ColorScheme.secondary` و `secondaryContainer` به توکن برند متصل شدند تا ChoiceChipهای Material از رنگ پروژه به‌عنوان رنگ انتخاب استفاده نکنند.
- FAB، NavigationBar، ProgressIndicator و ChipTheme به توکن‌های برند متصل شدند. رنگ‌های معنایی اولویت/وضعیت و رنگ سرمه‌ای SVGهای مقدس تغییر نکردند.
- آزمون widget برای رنگ حالت فعال HomeFilterPill، HomeFilterCard و HomeFilterChip اضافه شد.
- نتیجهٔ Analyze، مجموعهٔ کامل تست‌ها و ساخت APK باید روی SHA نهایی ثبت شود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.



## حذف وابستگی ناخواستهٔ Task Details به بارگذاری هم‌زمان اشخاص — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `1845c5a071beb7e087d21453a31753db905506d8`

- آزمون‌های CI نشان داد بازکردن فرم ویرایش Follow-up از Task Details به انتظار مستقیم برای `TaskStore.loadPeopleDirectory()` وابسته شده و در مسیرهای isolated/preview تست، فرم باز نمی‌شود.
- دایرکتوری اشخاص اکنون به‌صورت دادهٔ ورودی اختیاری به Task Details تزریق می‌شود؛ مسیر اصلی Home و Report Center آن را از مخزن canonical می‌خوانند. اشخاص پیوندخوردهٔ خود Task نیز در فهرست قرار می‌گیرند و شناسه‌های تاریخی ناموجود با عنوان «شخص حذف‌شده» حفظ می‌شوند.
- افزودن شخص همچنان از `TaskStore.mergePeopleDirectory` استفاده می‌کند؛ خواندن دایرکتوری دیگر در لحظهٔ بازکردن فرم، navigation را متوقف نمی‌کند.
- نیازمند CI exact-SHA جدید است؛ نتایج قبلی به SHAهای خودشان محدود می‌مانند.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.



## اصلاح تعامل افزودن شخص و واکنش‌گرایی سربرگ فرم — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `35098527149ed94808330108938ec1c531892918`

- کنترل نام شخص به یک Dialog دارای چرخهٔ عمر مستقل منتقل شد؛ در نسخهٔ قبلی controller پیش از پایان unmount شدن TextField آزاد می‌شد و CI خطای `TextEditingController was used after being disposed` ثبت کرده بود.
- سربرگ فرم Task در عرض کمتر از 420px دکمهٔ ذخیرهٔ آیکونی با tooltip نشان می‌دهد تا در بزرگ‌نمایی فونت، Row سربرگ از عرض دستگاه خارج نشود؛ در عرض عریض، دکمهٔ متنی حفظ می‌شود.
- آزمون ارتفاع نوار هفته با پیاده‌سازی واقعی (حداقل 68px) همسو شد؛ انتظار قدیمی 56px دیگر با layout فعلی سازگار نبود. آزمون overflow باریک/فونت بزرگ جداگانه حفظ می‌شود و نتیجهٔ آن فقط پس از CI جدید قابل پذیرش است.
- این تغییرات هنوز نیازمند Analyze و تست‌های exact-SHA هستند.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.



## اصلاح شکست‌های CI پس از پیوند شخص و سرریز Calendar — ۱۴۰۵/۰۸/۱۵

**Parent SHA:** `52205ba2ff5964e34d96acc0b3cb3c2db338890d`

- CI روی SHA `5c522e7`، `flutter analyze` را PASS کرد و persistence file-backed و SQLite close/reopen نیز PASS شدند.
- آزمون `task_detail_followup_flow_test.dart` نشان داد مسیر پیش‌نمایش Task Details ممکن است فاقد provider دیتابیس اشخاص باشد؛ بارگذاری دایرکتوری اکنون fail-soft است و در این حالت فقط افراد پیوندخوردهٔ همان Task را برای بازکردن فرم ارائه می‌کند. مسیر اصلی برنامه همچنان دایرکتوری canonical را از TaskStore می‌خواند.
- آزمون Task Details یک رنگ قدیمی indigo را assert می‌کرد؛ assertion به توکن واقعی `ArvinColors.primary` به‌روزرسانی شد، نه اینکه تست حذف یا شل شود.
- آزمون Calendar در عرض باریک و text scale 1.4 یک سرریز 47px را در سلول‌های هفته نشان داد. ارتفاع ثابت 68px به حداقل ارتفاع تبدیل شد و Column با `MainAxisSize.min` اندازهٔ واقعی محتوا را می‌پذیرد. آزمون دست‌نخورده باقی ماند تا رفع منشأ layout را بررسی کند.
- این اصلاحات نیازمند اجرای مجدد exact-SHA هستند. نتیجهٔ FAIL روی parent SHA حفظ می‌شود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.



## پیوند شخص به پیگیری — اجرای UI و ذخیرهٔ شناسهٔ پایدار (۱۴۰۵/۰۸/۱۵)

- **Parent SHA:** `277117469ff586a9529c5ab23c655cc2d6eb2e0e`
- **Scope:** فقط فرم ثبت/ویرایش Follow-up و اتصال آن به فهرست canonical اشخاص.
- هنگام فعال بودن «منتظر پاسخ دیگران»، فهرست اشخاص با شناسهٔ پایدار و گزینهٔ افزودن شخص جدید نمایش داده می‌شود. انتخاب قبلی در ویرایش بازسازی می‌شود و انتخاب/حذف از همان مجموعهٔ `FollowUp.personIds` ذخیره می‌شود.
- ایجاد شخص از مسیر `TaskStore.mergePeopleDirectory` انجام می‌شود؛ دادهٔ شخص در فهرست canonical باقی می‌ماند و Follow-up فقط شناسه‌ها را نگه می‌دارد. افراد حذف‌شده با برچسب تاریخی «شخص حذف‌شده» قابل مشاهده و حذف از پیوند هستند.
- مسیر ثبت از Home و مسیر افزودن/ویرایش در Task Details به همان فرم و مخزن داده وصل شدند. آزمون widget برای افزودن، انتخاب، بازگشایی و حذف پیوند اضافه شد.
- **هنوز نیازمند CI exact-SHA:** Analyze، تست‌های کامل، گزارش person projection و آزمون persistence واقعی با بازگشایی برنامه. این تغییر به‌تنهایی اثبات نصب یا پذیرش دستگاه نیست.
- **موارد باز:** جریان زنجیره‌ای تاریخ/ساعت و «بدون ساعت» برای Follow-up/Reminder، یکپارچه‌سازی جزء مشترک فیلترهای Home و Report، و ممیزی نهایی Home/تبلت.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ هیچ merge یا release انجام نشود؛ **BLOCKED — RELEASE: NO-GO**.



## اصلاح خطای تحلیل و ساخت Quick Capture — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent SHA:** `1c14c801a2b04cc70a4a617e2e7626d6c35d4331`  
**Evidence run:** Build `42262323182` on SHA `b5c8892a7aa5dad5d83abbf717bc19ea5c63140c`; Draft Review APK `42262323487` on the same SHA.

- Analyze در SHA `b5c8892` با سه خطای syntax در `lib/quick_capture_dialog.dart` شکست خورد: دو خطای positional arguments و یک پرانتز بسته‌نشده (log lines around 762, 833, 863). Staging APK نیز در مرحلهٔ compile Flutter با همان دو parenthesis mismatch شکست خورد؛ هیچ APKی upload نشد.
- علت: در تبدیل دو ردیف ثبت سریع به Wrap، یک لایهٔ بسته‌شدن `_surfaceCard` از هر بلوک جا افتاده بود. این مورد پنهان یا skip نشد؛ در این commit دو closure مربوط به هر دو Wrap کامل می‌شود.
- این اصلاح فقط syntax را ترمیم می‌کند؛ پذیرش layout هنوز منوط به Analyze و آزمون‌های exact-head است.
- SHA `b5c8892` همچنان FAIL برای Analyze و Review APK ثبت می‌شود؛ نتیجه به SHA جدید منتقل نمی‌شود.
- برای parent SHA `1c14c80`: Build `42262966593` PENDING، Device Smoke `42262966560` PENDING، Draft Review APK `42262966666` IN_PROGRESS، Calendar Provider `42262966580` IN_PROGRESS، Follow-up Persistence `42262966838` IN_PROGRESS. Artifactی هنوز ثبت نشده بود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ هیچ merge یا release انجام نشده است؛ **BLOCKED — RELEASE: NO-GO**.



## آخرین اصلاح منبع چیدمان و آزمون‌های اندازه‌ناپذیر — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent code SHA:** `9e1c9f3e4e52f5168fb3749195b32926fa28bc0a`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO.

- Home header، search، filter row و active-filter chips اکنون داخل یک viewport عمودی قابل پیمایش با `FlexFit.loose` قرار می‌گیرند؛ در viewport کوتاه یا هنگام بازبودن صفحه‌کلید، محتوای کنترل‌ها به‌جای فشرده‌سازی اجباری و سرریز، در همان ناحیه پیمایش می‌شود. لیست کارها همچنان viewport مستقل Expanded دارد.
- آزمون‌های جدید منبعی برای Calendar و Home عرض منطقی 360.333px (1081 physical px در DPR=3)، فونت بزرگ 1.4، RTL و inset صفحه‌کلید Home اضافه شده‌اند. آزمون‌های Quick Capture و Task Editor نیز با بزرگ‌نمایی فونت اجرا می‌شوند.
- این‌ها آزمون‌های منبعی هستند؛ تا نتیجهٔ exact-SHA Build، هیچ‌کدام PASS محسوب نمی‌شوند و جای نصب روی دستگاه واقعی را نمی‌گیرند.
- گزارش دقیق مالک محصول از دستگاه فعلی (مدل دستگاه، مقیاس، مسیر صفحه، و screenshot مربوط به overflow 0.333px) در PR comments/Issue #823 comments و فایل‌های فعلی مخزن قابل بازیابی نبود. این خلأ به‌عنوان NOT VERIFIED ثبت می‌شود؛ گزارش قدیمی نصب APK از 2026-08-14 مربوط به PR دیگر است و مبنای این پذیرش نیست.
- Home spec چهارده‌بندی در منبع خوانده شد. بخش‌های ساختاری موجود (header، Bismillah SVG، search، پنج فیلتر و sort مستقل، گروه‌بندی Due Date، navigation پنج‌تب) از قبل پیاده بودند؛ تست‌ها و پذیرش بصری کامل هنوز لازم‌اند. شکاف‌های Center در فرم Task، یکپارچه‌سازی جزء فیلتر Home/Report، انتخاب Person در Follow-up و مدل/جریان بدون ساعت همچنان بازند.
- وضعیت runهای دقیق parent SHA `9e1c9f3`: Build `42261916395` PENDING بدون job؛ Device Smoke `42261916305` PENDING بدون job؛ Draft Review APK `42261916169` IN_PROGRESS؛ Calendar Provider `42261916279` IN_PROGRESS؛ Follow-up Persistence `42261916393` IN_PROGRESS. نتایج این runها فقط به همان SHA تعلق دارند.
- آزمون‌های قبلی روی SHA `f614fab` برای file-backed Repository و SQLite close/reopen هر دو SUCCESS بودند؛ نتیجه به SHA جدید منتقل نمی‌شود.

هیچ تستی حذف، skip، bypass یا تضعیف نشده است. main دست‌نخورده، PR OPEN/DRAFT/UNMERGED و انتشار NO-GO باقی می‌ماند.



## ممیزی و اصلاحات UX / Home و فرم‌ها — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Code checkpoint SHA:** `f614fab584cd149db7aa9234dbe825b14198c292`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**main:** untouched  
**Release:** BLOCKED — RELEASE: NO-GO.

### Commits روی شاخه
- `6d7a48de45a4fc07a5f1c6dd70455e3484218ec8` — توکن‌های برند اصلی از بنفش/سرمه‌ای به آبی‌فیروزه‌ای تغییر کردند: primary `#087F8C`، header `#075E66`، soft `#DDF7F5`. رنگ‌های معنایی اولویت و taxonomy در تست توکن‌ها بدون تغییر باقی ماندند؛ رنگ SVG بسم‌الله `#1A2B4C` دست‌نخورده است.
- `1e63de1b39327ca569283a7bf6ea0cea9d328917` — ردیف انتخاب مرکز/پروژه/دسته/برچسب و ردیف موعد/یادآور/تکرار در ثبت سریع از اسکرول افقی به Wrap چندردیفی تغییر کرد؛ تست اندازه‌های 320 و 1024 پیکسل، نبود اسکرول افقی فرم را بررسی می‌کند.
- `c3e2b522ee72b74a4366648d09f19fc847a791f3` — نسخه اولیه Wrap برای taxonomy فرم کامل ثبت شد؛ ساختار این نسخه در کامیت بعدی اصلاح شد و این SHA به‌تنهایی مبنای پذیرش نیست.
- `5164319f5262e458ee85af127c83d3fc5bdd0d08` — ساختار Wrap فرم کامل اصلاح و برای Category / Project / Tag کلیدهای آزمون‌پذیر اضافه شد؛ چیدمان در عرض باریک دو ستونه و در عرض عریض سه‌ستونه است.
- `670e092f2bc4a0b3220f58d449a825637c1ea880` — عبارت نمایش پروژه به APIهای سازگار Dart محدود شد؛ از extension غیرضروری استفاده نمی‌شود.
- `f614fab584cd149db7aa9234dbe825b14198c292` — اولویت ثبت سریع تا انتخاب صریح کاربر `TaskPriority.none` است؛ تاریخ موعد و یادآور نیز بدون انتخاب کاربر null می‌مانند. تست عدم‌تولید پیش‌فرض‌ها افزوده شد.

### مواردی که پیش از این وجود داشتند
- هدر اصلی Home با منوی راست، SVG بسم‌الله، عنوان و زیرعنوان مرکزی و فیلتر عمومی چپ؛ کادر جستجو زیر هدر؛ ردیف پنج فیلتر RTL با مرتب‌سازی مستقل؛ پنج گروه زمانی؛ FAB و پنج مقصد Bottom Navigation از قبل در `lib/main.dart` وجود داشتند.
- مرتب‌سازی پیش‌فرض در Home از قبل `TaskListSort.lastFollowUp` با جهت صعودی بود. طبق قرارداد، موارد فاقد Follow-up پس از موارد تاریخ‌دار می‌آیند و تساوی با اولویت و سپس شناسه Task شکسته می‌شود. گروه‌بندی پنج‌گانه از Due Date استفاده می‌کند.
- فیلترهای Home از قبل منطق OR داخل بُعد و AND بین ابعاد را پیاده کرده بودند؛ آزمون موجود ترکیب Category و Tag را پوشش می‌دهد، اما پوشش کامل پنج بُعد و تمام ترکیب‌ها هنوز اثبات نشده است.
- مدل `PersonReference`، سرویس `TaskPeopleService`، فیلد `Task.people` و `FollowUp.personIds` و فیلتر اشخاص در Report Center از قبل وجود دارند؛ این به‌معنای وجود انتخاب/افزودن شخص در فرم Follow-up نیست.
- `allDay` برای Due Date از قبل وجود دارد؛ این وضعیت جایگزین پشتیبانی عمومی «بدون ساعت» در Follow-up و Reminder نیست.

### تطبیق Home و فرم‌ها — شکاف‌های باز
- **Home:** هدر، جستجو، فیلترها، گروه‌ها و navigation از نظر ساختاری موجودند. گروه «آینده» در کد عنوان تجمیعی دارد و نمایش تاریخ کامل برای آن هنوز نیازمند تطبیق دقیق با بند ۱۰ سند است. آزمون Home موجود viewport 320×640 و 390×844 را پوشش می‌دهد؛ آزمون DPR کسری 0.333px، بزرگ‌نمایی فونت و صفحه‌کلید برای Home هنوز اضافه/اجرا نشده است.
- **فرم کامل Task:** کنترل‌های Category / Project / Tag اکنون Wrap می‌شوند؛ انتخاب‌گر Center در این فرم هنوز وجود ندارد. Project دارای `centerId` است و نباید بدون انتخاب/رابط صریح، Center مستقل جعل شود.
- **اشتراک فیلترها:** ردیف Home از `ActionChip` و Report Center از بخش‌های مستقل `_Section` / `_MultiSelectChips` استفاده می‌کند. ادغام واقعی در یک جزء مشترک و یکسان‌سازی وضعیت/تعامل پنج فیلتر هنوز انجام نشده است؛ فیلتر شخص گزارش مستقل باقی می‌ماند.
- **Follow-up / Person:** فرم `FollowUpEntryPage` وضعیت «منتظر پاسخ» را ذخیره می‌کند، اما انتخاب شخص موجود/افزودن شخص جدید و تغییر/حذف پیوند شخص را در UI ارائه نمی‌کند. گزارش‌ها فقط از `personIds` موجود استفاده می‌کنند؛ آزمون ذخیره، بازگشایی و گزارش یک شخص واقعی هنوز انجام نشده است.
- **تاریخ/ساعت:** در چند فرم، انتخاب تاریخ و ساعت هنوز کنترل‌های جدا دارد. Due Date از `allDay` استفاده می‌کند، اما جریان واحد یک‌دکمه‌ای و گزینهٔ صریح «بدون ساعت» در همهٔ محل‌های اختیاری پیاده نشده است. پشتیبانی ذخیره/نمایش بدون ساعت برای Follow-up و عدم ساخت اعلان زمان‌دار بدون ساعت هنوز باز است؛ Due Date، Follow-up Date و Reminder Date مستقل باقی می‌مانند.
- **چیدمان تقویم:** تغییر قبلی به پیمایش عمودی و guard خطای startup در کد وجود دارد؛ این guard به‌تنهایی رفع منشأ RenderFlex را اثبات نمی‌کند. گزارش دستگاه با سرریز 0.333px در منابع قابل دسترس این ممیزی پیدا نشد؛ اصلاح منشأ و آزمون DPR کسری/فونت بزرگ/RTL هنوز NOT VERIFIED است.
- **SVG و فونت:** توکن رنگ بسم‌الله در Home حفظ شده است. وجود دو asset بسم‌الله و تفویض در مخزن به‌تنهایی اثبات path-only بودن، نبود عنصر text/raster، و render صحیح روی دستگاه نیست؛ این گیت‌ها باید با آزمون asset و screenshot تأیید شوند. Vazirmatn تنها فونت متنی مجاز باقی می‌ماند.

### وضعیت شواهد روی Code SHA بالا
- Build run `42261229876`: PENDING؛ در آخرین بررسی هنوز job آغاز نشده بود. بنابراین `flutter analyze` و مجموعه کامل تست‌ها روی این SHA نتیجه ندارند.
- Device Smoke run `42261230051`: PENDING؛ هنوز job و مدرک دستگاه/اسکرین‌شات ارائه نشده است.
- Follow-up File Persistence run `42261230162`: SUCCESS؛ checkout SHA دقیق تأیید شد؛ تست file-backed Repository و diagnostic بستن/بازگشایی SQLite هر دو SUCCESS شدند. این گیت محدود، جایگزین آزمون شخص/گزارش یا Device Smoke نیست.
- Calendar Provider run `42261229778`: IN_PROGRESS؛ آزمون instrumentation/provider در حال اجرا بود.
- Draft Review APK run `42261229806`: IN_PROGRESS؛ ساخت Staging APK در حال اجرا بود؛ در لحظه بررسی هیچ artifactی بارگذاری نشده بود. APK Debug مستقل ساخته/تحویل نشده است.
- نتیجهٔ orchestration/factory SUCCESS جایگزین Analyze، تست، APK، Device Smoke یا پذیرش مالک محصول نیست.

هیچ تست یا قابلیتی حذف، skip یا تضعیف نشده است. هیچ تغییر روی `main`، Merge، Release یا انتشار انجام نشده است. این ثبت مستندات، نتیجهٔ CI را به PASS ارتقا نمی‌دهد.

## ۱۴۰۵/۰۸/۱۵ (2026-11-06) — ممیزی موازی CI، Device Smoke و APK روی SHA `33cbccca804a6f33b22a84e37ea1fc1f5600cd2b`

- PR #3052 روی شاخه مجاز OPEN / DRAFT / UNMERGED است؛ SHA مبنا و نتایج هر Run جداگانه ثبت شدند.
- روی SHA هدف، Analyze و شش شارد تست و Visual موفق‌اند؛ Build هنوز به‌دلیل APKهای Debug و Staging در حال اجراست و Calendar Provider نیز باز است.
- Draft Review APK با امضای v2/v3، debuggable=false و سه وزن Vazirmatn تأیید شد؛ کلید موقت بازبینی است و APK قابل انتشار نیست.
- آرتیفکت Release تولید شده، اما امضا و کلید تولیدی آن مستقلاً تأیید نشده است؛ پذیرش انتشار صادر نمی‌شود.
- Device Smoke جدید هنوز PENDING است. Device Smoke قدیمی متعلق به SHA `59a321d333bd867049cf7f5b87be82ad9cb8e68e` است و فقط Boot و Navigation آن موفق‌اند؛ Calendar در حال اجرا و چهار lane دیگر در صف‌اند.
- جزئیات Runها، آرتیفکت‌ها، SHA-256 و دروازه‌های باز در `docs/project-continuity/ARVIN_PARALLEL_EVIDENCE_CHECKPOINT_2026-11-06.md` و Ledger محصول ثبت شده‌اند.
- وضعیت انتشار همچنان **BLOCKED — RELEASE: NO-GO** است.

## 2026-11-06 — test(ci): align concurrency contract with serial device-smoke policy

- علت شکست CI: تست قرارداد هم‌زمانی برای Device Smoke مقدارهای `cancel-in-progress: true` و `max-parallel: 2` را انتظار داشت، درحالی‌که سیاست موجود Workflow اجرای سریالی و عدم لغو اجرای جاری (`false` و `1`) است.
- اصلاح محدود به دو مقدار مورد انتظار در همان تست قراردادی است؛ هیچ assertion دیگری حذف، skip یا تضعیف نشده است.
- سیاست `.github/workflows/device-smoke.yml` تغییر نکرده است؛ `cancel-in-progress: false` و `max-parallel: 1` بدون تغییر حفظ شدند.
- کد اجرایی برنامه و قابلیت‌های محصول تغییر نکرده‌اند. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده و انتشار BLOCKED — RELEASE: NO-GO است.

## 2026-11-05 — تثبیت تصمیم تایپوگرافی مالک محصول

- Vazirmatn فونت الزامی تمام اجزای رابط است. فقط دو عبارت «بسم‌الله الرحمن الرحیم» و «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» (یا «افوض امری الی الله») مجاز به رندر با خط نسخ هنری هستند؛ هیچ استثنای دیگری وجود ندارد.

## 2026-11-05 — اجرای کد الگوها و فرم واحد Task Detail (PR #3052)

- قرارداد داده‌ای Task Template در docs/project-continuity/TASK_TEMPLATE_DATA_CONTRACT.md ثبت شد؛ G1 به v11 ارتقا یافت و checklist_enabled با default غیرمخرب اضافه شد. ذخیره‌سازی از همان SQLite/Drift موجود استفاده می‌کند.
- دو تب عملیاتی «الگوهای کار» و «الگوهای پروژه» به تنظیمات متصل شدند. تبدیل Task از فهرست و جزئیات، تبدیل Project از مسیر Projects → Project Details، ذخیره واقعی، بازخورد و نمایش الگوی ذخیره‌شده پیاده‌سازی شد.
- Checklist، People references، priority، recurrence definition و ساعت Reminder در Task Template قرارداد مشخص دارند؛ تاریخ‌های اجرای قبلی، وضعیت تکمیل و Follow-up history منتقل نمی‌شوند. Task جدید شناسه‌های جدید و checklist ناتمام می‌گیرد.
- Task Detail در مسیر فعال به فرم واحد draft/save/cancel نزدیک شد: Checklist اتمیک با reorder، Due Date قابل پاک‌کردن، recurrence end date، Reminderهای قابل ویرایش، وضعیت/اولویت، عنوان/یادداشت Follow-up و حفظ scroll offset. زمان اجرا و مسئول تا وجود منبع canonical «نامشخص» می‌مانند.
- تست‌های سرویس، مهاجرت، تعامل دو تب، تبدیل Task/Project و فرم Task Detail اضافه/گسترش یافتند. نتیجه همه این تست‌ها روی HEAD نهایی تا دریافت exact-SHA run، NOT VERIFIED است.
- Visual: انتظار pumpAndSettle با pump قطعی ۳۵۰ms و assertion idle-frame جایگزین شد؛ علت دقیق frame source هنوز اثبات نشده و Golden مرجع در branch/main وجود ندارد؛ Golden بدون بازبینی تصویری ساخته نشد.
- هیچ تستی حذف، Skip یا تضعیف نشد؛ هیچ Golden به‌روزرسانی نشد. PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.

## 2026-11-05 — Home test-2 correction and visual timeout disposition

- Root-caused the historical Home test-2 mismatch: the UI combines weekday + Jalali date in one heading Text, while the test searched for date-only exact text; the test also expected the old Category label. Updated the test to assert the complete dynamic heading and «دسته‌ها».
- Historical test-0 was a fixture-title collision with the «گذشته» group heading; the fixture was disambiguated and test-0 passed on baseline c35929c.
- Task Details visual job still has an unresolved pumpAndSettle timeout before screenshot/golden capture. Root cause NOT VERIFIED; no timeout bypass or golden update.
- These corrections require fresh exact-HEAD CI. No older SHA result transfers. PR remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.

## 2026-11-05 — Issue #823 Home filter copy and UI/UX evidence audit

- Corrected the active Home Category filter chip in lib/main.dart to the approved label «دسته‌ها»; added an exact widget assertion in test/home/home_filter_contract_test.dart. The row remains five filters plus a separate sort icon; «همه» remains inside filter panels only.
- Added docs/audit/ARVIN_ISSUE_823_UIUX_EXECUTION_AUDIT_2026-11-05.md covering canonical documentation registration, Home active-path behavior, Project/Task Templates, Drift, Calendar, Task Details, and exact-SHA CI evidence.
- Updated Product Decisions and Implementation Log with the unresolved sacred-phrase typography clarification and implementation gaps. Task Template schema/UI conversion and full eleven-section Task Details remain incomplete; no speculative model or migration was added.
- Existing Home OR/AND code is present, but the combined behavior still needs explicit widget acceptance. Future-group date-heading behavior requires product interpretation before implementation.
- No tests/assertions were removed, skipped, weakened or bypassed. PR #3052 stays OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.

## 2026-11-05 — ثبت مستندات مصوب معماری محصول آروین (Home, Task Detail, Calendar)

- سه مرجع canonical محصولی Home، Task Master-Detail و Calendar در `docs/project-continuity/` تثبیت و هم‌راستا شدند.
- Home: هدر/جستجو، فیلتر عمومی، پنج فیلتر سریع و مرتب‌سازی مستقل، OR/AND، تفکیک Due Date / Follow-up Date / Reminder Date، گروه‌بندی پنج‌گانه، کارت‌ها، FAB و ناوبری پنج‌تایی.
- Task Detail: سند مستقل فرم واحد View/Edit با ترتیب ۱۱ بخش، پنج کارت متادیتا، وضعیت/اهمیت، موعد، مسئول، Reminderها، recurrence، checklist، آخرین Follow-up، timeline و نوار عملیات ثابت اضافه شد.
- Calendar: مصوبات تکمیلی هدر، تاریخ سه‌گانه، چهار حالت نمایش، پنج فیلتر agenda، کارت‌های محتوا، offset قمری و معماری سه‌لایه در مرجع موجود ثبت شد.
- PRODUCT_DECISIONS.md و ROADMAP.md تصمیم APPROVED و backlog slices را ارجاع می‌دهند؛ README continuity و continuation Ledger نیز به‌روزرسانی شدند.
- قید ممیزی: زمان اجرا و assignment مسئول تا اثبات نگاشت canonical، NOT VERIFIED؛ هیچ مدل یا مخزن موازی مجاز نیست.
- این commit فقط مستندات است؛ هیچ کد اجرایی، ویجت، تست، Golden Test، schema، Provider یا migration تغییر نکرده است. CI قدیمی به SHA جدید منتقل نمی‌شود.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main untouched؛ Release: BLOCKED — RELEASE: NO-GO.

## 2026-11-05 — TaskHomeScreen workflow and regression contract alignment

- Restored the exact seven-lane Build quality matrix: Analyze + test-0 through test-5. Moved `test/task_detail_visual_test.dart` and its artifact upload to a separate standalone `visual` job with exact-SHA checkout verification; visual coverage is retained.
- Synchronized existing Home regression expectations with the approved fourteen-point Home specification: fully vocalized Bismillah, no Home-header notification bell, general-filter/menu RTL positioning, the canonical Past heading «گذشته», and search hint «جستجو در کارها...».
- Updated the Task Details completion-action color assertion to the owner-approved shared primary token `#3F3D56`.
- Updated the Vazirmatn source contract to assert the actual single-source `ArvinTheme.fontFamily` wiring and canonical bundled-font token declaration.
- Test cases and behavioral coverage remain present. No test file or case was deleted, skipped, bypassed, weakened, or timeout-bypassed. No product runtime code was changed in this alignment pass.
- Build, standalone Visual, Parallel Wave contract, and seven-path Device Smoke must complete on the new exact HEAD before any PASS is recorded. PR #3052 remains OPEN / DRAFT / UNMERGED; `main` unchanged; release BLOCKED — RELEASE: NO-GO.

## 2026-11-04 — Quick Capture tighter visual compression (UI-only)

- Tightened compact option controls to 40dp, icons to 16dp, icon/text gaps to 4dp and internal horizontal padding to 8dp; reduced card and row spacing and compacted title/description field decoration.
- Preserved the exact existing item order, row structure, selector keys and horizontal scrolling, four Persian priority options/helper texts, Vazirmatn font family, colors, touch target minimum, and all form logic/data behavior. **UI-only; no behavior change.**
- Updated compact geometry assertion to 40dp. Physical SM-A528B/DS screenshot and zero-vertical-scroll device verification remain NOT VERIFIED pending device test.

## Quick Capture priority helper row refinement — 2026-11-04
- Four canonical priority chips now show only «اولویت ۱» through «اولویت ۴» in 40dp-high controls; the four existing explanatory labels appear in a separate compact helper-text row immediately below.
- Existing priority enum values, ordering, selected-state animation, color mapping, tap callbacks and Semantics labels (including the explanatory text) remain unchanged.
- This refinement supersedes the in-flight CI started on prior SHA `d83683e47c0d3f6c3ca3fdf10504bc93aebd39d0`; its results are not acceptance evidence for the final SHA.

## 2026-11-04 — Quick Capture compact single-screen layout (UI-only)

- Compressed the existing Quick Capture header, cards, gaps, priority chips and selector controls; aligned «ثبت کار» and «لغو» in one footer row.
- Added opt-in 42dp compact presentation for ArvinRollBox and ArvinTagRollBox; retained their menu choices, selected values, semantics and callbacks.
- Constrained the bottom sheet to 66% of screen height while retaining its inner scroll fallback for short viewports, keyboard and text scaling.
- Kept the existing title and description fields, selector inventory/order, four canonical TaskPriority values, Persian priority labels/helper text, all selection/validation/save behavior and all data field names unchanged. This is **UI-only; no behavior change**.
- Updated focused geometry assertions; no test/assertion was removed, weakened, skipped or bypassed.
- Physical SM-A528B/DS before/after screenshots are NOT VERIFIED; exact-SHA CI is pending after this documentation update.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details reference comparison checkpoint (PR #3052)
- Revalidated exact branch HEAD 940b22f4dc30aef083e5116843ac9457bd1bd37a; PR OPEN / DRAFT / UNMERGED; main unchanged.
- Current TaskDetailPage, _openTaskDetail route and Task model re-read. Model has related people but no dedicated assignee field; people are not an assignee.
- Source confirms repeated due date, priority, category/tags. No runtime cleanup was made because the two named screenshots were unavailable in current conversation and Library search; image-based acceptance remains NOT VERIFIED.
- Exact-head Build run 41819344155 SUCCESS (Analyze + six test shards), focused Task Details tests and RTL/Vazirmatn contracts logged PASS. Follow-up Persistence 41819344361 SUCCESS. Draft Review APK 41819344101 SUCCESS, artifact 13316861010 (review only).
- Calendar Provider 41819344729 and Device Smoke 41819344258 were still running/queued at last poll; Device Smoke was incomplete.
- Detailed audit/backlog: docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md and docs/project-continuity/OPEN_ISSUES.md.
- No tests/assertions weakened/skipped, no main write, merge or release. PR remains OPEN / DRAFT / UNMERGED; Release BLOCKED — RELEASE: NO-GO.

## 2026-11-04 — Quick Capture compact form implementation (PR #3052)

- First exact-head Build exposed a real overflow in the selected priority Dropdown and two legacy custom date/time action-label expectations. The selected state is now text-only (still color-dynamic), and the unified custom date/time action retains the established Persian label; no test or assertion was disabled.

- Reworking the existing `QuickCaptureDialog` rather than introducing a replacement form or persistence path.
- Target UI contract: single-line title; header shortcut to the full Task editor; RTL horizontal Center → Project → Category → Tag row; dynamic colored priority dropdown; one Jalali date + approved circular time control; Reminder and Recurrence; submit-right / cancel-left footer.
- The description field remains in Quick Capture; its visible height is compacted only. Checklist controls are not part of the current Quick Capture field inventory; no existing Quick Capture field is removed.
- Center selection scopes Project choices. A Task's Center relationship is persisted only through its selected canonical Project (`ProjectPlan.centerId`); no `Task.centerId` field or parallel storage is introduced.
- Exact-head widget, Home persistence and Android smoke validation are pending. This entry records implementation scope, not completion.
- PR #3052 remains OPEN / DRAFT / UNMERGED; `main` untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Arvin local calendar lifecycle and read-only external providers

- Startup permission flow now retries idempotent Arvin local-calendar provisioning on every app launch after permission has already been acknowledged.
- Canonical Task create/edit/due-date/complete/archive mutations reconcile their projected reminders into the app-owned local Arvin calendar after the Task database write succeeds.
- Task descriptions are included in provider event revisions; completed, archived, and trashed Tasks are removed from the writable Arvin projection without deleting the canonical Task.
- Outbound provider writes are constrained to the verified app-owned `ACCOUNT_TYPE_LOCAL` Arvin calendar. Google/Samsung calendars remain read-only event sources.
- Legacy links to external calendars are replaced by Arvin-local links without modifying or deleting the external event.
- Removed the Android `ACTION_INSERT` route that could open a generic external calendar as a write destination. The legacy bridge insert now writes through the verified Arvin-local provider path.
- Added unit and Android integration coverage for startup provisioning retry, fixed Arvin destination, external write rejection, archive/description projection, provider CRUD, and Task persistence after provider-event deletion.
- CI, six-lane test evidence, Device Smoke, and a stable Review APK are not yet verified on the final commit. Release remains BLOCKED — RELEASE: NO-GO pending device acceptance.

## 2026-11-03 — Calendar Bridge identity and analyzer correction

- Removed the Task Reminder identity from the native calendar-editor launch payload; opening an existing device event requires only its calendar and event IDs.
- Moved the Reminder identity to the provider ownership-verification payload, where it is required to verify the exact Arvin-owned event.
- Added native-side validation that ownership checks receive an eligible Task/TaskReminder identity before querying Calendar Provider.
- Removed the redundant spread `.toList(growable: false)` and added the required guard braces in the Calendar Bridge.
- The existing Arvin local-calendar provisioning and event CRUD paths were not redesigned by this focused correction.
- Exact-head Analyze, tests, Calendar Provider acceptance and Review APK build are still required. No PASS is inferred from source edits.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Filter regression finder precision

- Scrolled the lazy time-filter list to the «بازهٔ دلخواه» row before asserting its CheckboxListTile.
- Scoped the pre-apply category assertion to the persisted task-card title key, avoiding collisions with the same category label in the filter sheet and task metadata.
- Test-only correction; no runtime behavior changed.

## 2026-11-03 — Filter count assertions

- Scoped count-label assertions to their corresponding top filter chips, because the active-filter summary row intentionally repeats the selected dimension/count.
- No runtime behavior changed.

## 2026-11-03 — Filter CI follow-up

- Converted the range predicate closure to a named local function to satisfy the repository analyzer rule.
- Made widget-test taps target the filter chip/checkbox row directly and scroll into view, avoiding ambiguous or clipped text targets.
- Aligned the bottom-navigation source contract with the approved «خانه» label; no navigation runtime code changed.
- Exact-HEAD Build remains required; this follow-up is test/analyzer hardening only. Release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Filter test alignment and Persian count labels

- Multi-selection counts on the five Home filter chips and active-filter summary chips now use Persian digits, including the Time dimension.
- Updated legacy Home widget tests to toggle CheckboxListTile rows and press the explicit Apply action; ambiguous text finders were replaced with row-scoped finders.
- Added/retained OR-within-dimension and AND-between-dimension assertions for categories and tags, plus Time OR coverage.
- No schema, Task, Reminder, Follow-up, Calendar or navigation behavior changed.
- Exact-SHA Build/Device Smoke/Calendar Provider/File Persistence/Draft APK runs remain the release evidence gate; local Flutter tests not run. Release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Checkbox filter confirmation and unified time ranges

- Added an explicit checkbox row for «بازهٔ دلخواه»; its date/time bounds are draft-only and the single bottom «تأیید / اعمال فیلتر» action commits the selected time options together.
- Time selections, including a custom range, now use OR within the Time dimension. Selecting Past with another time option retains Pending-before-Completed ordering.
- Updated Home filter contract tests from Radio/single-select expectations to Checkbox + explicit confirmation; updated range tests and added a time multi-select OR regression.
- The five RTL Home filter chips retain horizontal SingleChildScrollView. Existing category/tag OR/AND regression tests remain active.
- Local Flutter tests were not run in this session; exact-HEAD CI is required. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Past ordering with multi-select time scopes

- When Past is one of multiple selected time scopes, Home retains a single ordered result group so pending tasks remain ahead of completed tasks; within each status group the canonical priority order remains active.
- This prevents date-bucket regrouping from undoing the Past ordering contract.
- Exact-HEAD CI is pending; no local Flutter SDK. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Home filter Checkbox Multi-Select stabilization

- Fixed stale single-select state references after converting the Home filters to sets.
- Time filter drafts now keep a custom date local to the sheet until confirmation; cancelling date selection no longer creates an invalid selected preset.
- Time-filter removal clears both preset and custom-range state. Existing custom date/time range controls and the «اعمال بازه» action remain available.
- Added widget tests for staged Category selection, OR semantics for Tags, and AND semantics across dimensions.
- Local Flutter tests not run; exact-HEAD CI is required. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Home filter Checkbox Multi-Select standard

- Converted Center, Project and Category filters from single-choice Radio controls to staged Checkbox multi-select. All five Home filter sheets now have an explicit «همه» reset row and «تأیید / اعمال فیلتر» action.
- Time presets are multi-select with OR matching, including Past; custom date selection is a selectable option and custom date/time ranges remain an explicit separate action.
- Center, Project, Category and Tag selections use OR within each dimension; the dimensions are combined by AND. Past keeps pending-before-completed sorting when included.
- Filter chips show the selected value for one choice and the filter name with count for multiple choices. The five-chip strip uses a horizontal SingleChildScrollView.
- Extended short-viewport and time-sheet regression coverage. Local Flutter tests were not run in this environment; exact-HEAD CI is required.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main is untouched; release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit H: archived dependency deletion regression tests

- Added regression coverage proving a completed/archived Task with Follow-up history continues to block Category and Tag deletion.
- Added a SQLite-backed test proving an archived Project still blocks deletion of its owning Center and both records remain intact.
- The existing lifecycle behavior is unchanged; tests cover Active/Archive/Follow-up references without destructive mutations.
- Local Flutter tests not run; exact-HEAD CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit F: refresh exact-HEAD 24-domain matrix and Legacy inventory

- Updated docs/qa/ARVIN_MASTER_SPEC_24_DOMAIN_AUDIT_2026-11-03.md to source SHA 35b5765a7964c063b01a5ef3366836064decc751, including the filter OR fix, Calendar Task Details routing/export-only swipe, safe template preservation test, report P1-P4 output grouping, and five-item navigation.
- Added docs/qa/ARVIN_LEGACY_REFERENCE_INVENTORY_2026-11-03.md with direct model, Schema, Store, migration, repository/service, UI, report, Work Agenda, Next Action and test/fixture references.
- Confirmed Task.followUpEnabled/followUpDate and FollowUp.nextFollowUp/reminderDate remain active compatibility data; Task.reminderDate is still consumed by Editor/Work Agenda/Next Action/Calendar/Report. FollowUp.completedAt remains a getter alias to dateTime; no follow_ups.completed_at column exists.
- No legacy data, columns, or runtime fields were deleted. No migration was executed. Backup/Rollback and migration plan are documented.
- CI checkpoint on source SHA 35b5765a7964c063b01a5ef3366836064decc751: Analyze PASS; Build test shards IN PROGRESS; Follow-up File Persistence SUCCESS; Calendar Provider failed due Gradle Plugin Portal inability to resolve Kotlin 2.2.21 artifacts; Device Smoke queued/in progress; Draft Review APK in progress. These are not release acceptance.
- Documentation-only Commit F. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit G: Canonical five-item navigation labels

- Renamed the visible Home destination from «امروز» to the owner-approved «خانه».
- Corrected the navigation regression test to assert exactly five visible destinations: خانه، تقویم، دفترچه، گزارش‌ها، بیشتر; the separate Next Action route remains outside the bottom bar.
- No routing/storage behavior changed. Local Flutter tests not run; exact-HEAD CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit E2: Exact-SHA analyzer corrections for Reports and Template tests

- Added the canonical Task model import to the Project Template regression test so TaskReminder and FollowUp preservation assertions compile.
- Removed the obsolete Priority-filter argument from the Report Center filter test; priority remains a report grouping/sort dimension, not a filter criterion.
- Added the Task model import to the grouped text-report test and removed an unnecessary interpolation brace flagged by Analyze.
- No product data/schema behavior changed. Local tests not run; exact-HEAD CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit E1: Report text numbering correction

- Corrected the first item index in priority-grouped plain-text reports; the counter is incremented once and rendered without an extra offset.
- This is a focused correctness follow-up to Commit E. The report grouping remains P1→P4 and stable within each group.
- Local tests not run; exact-HEAD Build CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit E: Report Center priority grouping and filter contract

- Removed the existing standalone Priority filter from Report Center and TaskReportFilter; priority is no longer a report-selection criterion.
- Added canonical P1→P4 groups to the shared TaskReport projection. PDF/Print and plain-text copy/share now render the same priority-group order while preserving input order inside each group.
- TaskReportEntry now carries canonical Task priority; PDF continues to load bundled Vazirmatn regular/bold fonts and RTL page direction.
- Added projection and plain-text regression tests for P1/P2/P3/P4 grouping and a Report Center assertion that no Importance filter is exposed.
- Structured machine-readable export and full Print/Share end-to-end validation remain NOT VERIFIED. Local Flutter tests were not run; exact-HEAD CI required.
- No Task/Reminder/Follow-up data or schema changed. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit D: Safe Mid-Cycle Project Template preservation test

- Extended the real SQLite/Drift propagation test with a completed and archived existing Task carrying a Checklist, independent Reminder and historical Follow-up.
- The test now verifies all existing state/history and project membership survive propagation, while only the new template Task is appended and repeated propagation remains idempotent.
- Runtime propagation implementation was not changed; the existing transactional append-only path remains the only write path.
- Local Flutter tests were not run; exact-HEAD Build CI must validate the stronger test. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit C1: Calendar routing analyzer cleanup

- Removed the unused Follow-up helper, added the Follow-up action reminder namespace to canonical parent-Task routing, and fixed the analyzer-required control-flow braces.
- This follow-up is based on exact analyzer evidence from Build run 41618701405 on Commit C: the only analyzer findings were the unused helper and missing braces.
- The Follow-up action card remains non-exportable by swipe; the new prefix is recognized only for opening the owning Task Details.
- Exact-HEAD CI is required after this correction. No data/schema changes; main untouched; PR remains OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit C: Calendar Task Details routing and export-only swipe

- Calendar Task and Follow-up card taps now resolve the owning canonical Task and call the Task Details route; Edit remains available from the explicit Details action only.
- Calendar long-press no longer exposes Task/Follow-up Edit. Calendar horizontal swipe now performs only explicit Device Calendar export for eligible Task records; legacy edit/trash swipe settings decode to no action and are no longer offered in Settings.
- Added direct CalendarPage tap assertions, launcher-to-canonical-Task resolution coverage, and legacy swipe-setting retirement tests.
- Local Flutter tests were not run in this environment. Exact-HEAD CI must validate the new routing and settings behavior.
- No Task/Follow-up data or schema changed. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit B: Home filter semantics and five-filter coverage

- Home active-filter state now includes Center, so clear-filter affordances remain visible when Center is the only active filter.
- Home multi-select Tags now use OR semantics through the pure homeTaskMatchesAnySelectedTag matcher; independent filter dimensions remain AND-combined.
- Updated Home filter regression coverage to include the fifth Center control and the compact viewport.
- Added focused unit tests for OR matching and the empty-selection behavior. No persistence/schema behavior changed.
- Local Flutter tests were not run in this environment; exact-HEAD Build CI is required before treating the change as accepted.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Exact-SHA 24-domain architecture/product audit

- Added docs/qa/ARVIN_MASTER_SPEC_24_DOMAIN_AUDIT_2026-11-03.md, audited directly against PR branch HEAD 469f9a5b0140bb69f6f415e1ad8ad0eee28e2983.
- The matrix records 24 owner-acceptance domains with conservative statuses, direct source/test paths, and exact-SHA CI evidence. Prior audit documents on older SHAs remain historical only.
- Confirmed active legacy references in Task/FollowUp models, Drift schema, TaskStore and Task editor. No legacy column or user data was deleted or rewritten.
- Recorded immediate independent corrections for the next code slice: Home multi-tag OR semantics and the missing Center contribution to Home active-filter state. Calendar card Tap currently routes Task/Follow-up records to Edit callbacks rather than Task Details.
- Exact-SHA evidence: Build 41614740315 Analyze + six test shards SUCCESS (APK matrix SKIPPED); Calendar Provider 41614740147 SUCCESS; File Persistence 41614740328 SUCCESS; Draft Review APK 41614740340 SUCCESS (review-only); Device Smoke 41614740157 remains IN PROGRESS with four lanes PASS, two IN PROGRESS and one QUEUED at checkpoint.
- Documentation-only Commit A. No product runtime, tests, schema, migration, dependency, main, merge, release or APK publication changed. PR #3052 remains OPEN / DRAFT / UNMERGED; release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Wave 7.304 Home overdue styling and completion archive behavior

- Home cards now render overdue, unfinished Task title and due-date text in the error/red text color only; overdue status and due-date icons remain neutral, card surface and border remain unchanged, and unrelated follow-up text/icons remain neutral.
- Completing an active Home Task immediately sets its canonical `completed` and `archived` state before the Home rebuild, so it leaves active scopes including the Past filter and remains in canonical Archive storage. Task identity, due date, reminder, checklist, description and FollowUp history are preserved.
- Added Home widget regression coverage for red overdue text with neutral icons, instant archive with preservation of task data/history, and instant removal while the Past filter is active. Assertions are additive; existing tests were not deleted or weakened.
- Date-jump relocation remains **NOT IMPLEMENTED / NEEDS PRODUCT CLARIFICATION**. On this branch, the current-date action is `calendar-today` in `CalendarPage`, while `calendar-date-jump` opens an arbitrary Jalali date selector; neither is a HomePage control. Moving either into Task Details would change its meaning without an explicit owner decision.
- Source/test commits: `c5d8627211b7cb8b0c601e74cefa44119dd309c4`, `c9c6cbfdda950ca5f2d4d9c0364236d058a5775f`, `378045d5d020d307cb9dfa88b3ede998753ed719`, `9ce6ff8627fb414b4e10ceb3019d169a8487e4af`, `d89f46641a59e93e4cf81cfb69b17192af59fe32`. Exact-HEAD test/CI validation is pending.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main is untouched. Release remains **BLOCKED — RELEASE: NO-GO**.

## 2026-11-02 — Local Calendar historical FollowUp exclusion

- Product behavior: historical FollowUp records are filtered at the local Calendar display boundary. IDs with the historical `followup:` and legacy `task-followup:` namespaces are excluded from both supplied and visible-range projected Calendar items.
- Dated Task events, independent dated Reminder events, and recurrence projections remain in the existing Calendar projection. `task-followup-action:` is not filtered by this change.
- FollowUp records, Task Details history, Follow-up Notebook data, Report Center projections, Task storage, Reminder data, Due Dates, and legacy database columns are not modified or deleted.
- Implementation: `lib/calendar_page.dart`; regression coverage: `test/calendar_page_test.dart`, `test/calendar_runtime_actions_fast_track_test.dart`, and `test/calendar_release_acceptance_test.dart`. Existing projection, Task Details and Report Center tests are retained.
- Implementation/test commit: `8533b17599af46524973bc0a366864d44e08c96e`. Documentation synchronization commits follow; exact final branch HEAD and exact-head CI results must be read back before acceptance.
- Release remains **BLOCKED — RELEASE: NO-GO**. PR #3052 must remain OPEN / DRAFT / UNMERGED. No main mutation, merge, APK publication, or release is authorized.

### Exact-SHA validation checkpoint — 2026-11-02

- Validated source/test SHA: `04cacb3a88a99c12286dd6d8f6a9d0268a0d12eb`.
- Build #9185 / Run `41509339452`: **SUCCESS**. Analyze SUCCESS; all six test shards SUCCESS; 1,122 tests passed in total. Draft PR APK matrix was SKIPPED by the existing Draft guard.
- Explicit regression tests passed: `calendar_page_test.dart` (historical FollowUp hidden from supplied and visible-range projected inputs; dated Task and independent Reminder remain visible); `calendar_runtime_actions_fast_track_test.dart`; `calendar_release_acceptance_test.dart`; `follow_up_calendar_projection_test.dart`.
- Preservation tests passed: `task_detail_followup_flow_test.dart`, `follow_up_office_page_test.dart`, and `completed_follow_up_report_page_test.dart`. FollowUp remains available in Task Details, Follow-up Office/Notebook, and Report Center.
- File Persistence #359 / Run `41509339890`: **SUCCESS**. `follow_up_repository_file_persistence_test.dart` and `alarm_overlay_file_persistence_test.dart` passed, including SQLite close/reopen and Snooze/Complete isolation.
- Device Smoke #6437 / Run `41509340280` on the same SHA at checkpoint: Boot SUCCESS; Navigation SUCCESS; Calendar Segmented View IN_PROGRESS; Quick Capture IN_PROGRESS; Task Lifecycle QUEUED; Reminder/Vazirmatn QUEUED; Follow-up Persistence QUEUED. No aggregate PASS is claimed while five lanes lack terminal success.
- Calendar Provider #1342 / Run `41509339317`: IN_PROGRESS at checkpoint; no PASS claim.
- Draft Review APK #12 / Run `41509339894`: the repository's automated review-only staging workflow assembled and verified its staging APK and uploaded the private CI artifact `arvin-review-staging-apk-04cacb3a88a99c12286dd6d8f6a9d0268a0d12eb`. This is not a Release, public publication, or authorization to distribute an APK. No release action was performed.
- Two earlier exact-SHA test runs exposed obsolete historical-FollowUp card expectations in existing tests; those expectations were replaced with positive/negative assertions for the new owner behavior. On SHA `04cacb3...`, all six shards passed. No tests were deleted, skipped, or weakened.
- Documentation-only synchronization follows this checkpoint; re-read the resulting PR HEAD and require fresh exact-HEAD CI before accepting any later SHA.

## 2026-11-02 — Wave 7.292 product roadmap clarification and exact-SHA gate checkpoint

- Preserved the owner's implementation decision for Branch → Project → Task visibility and historical record retention; Home Task-card expand/collapse with exact description/time and a separate Task Details route; latest valid same-Task Follow-up through the real presentation service; and the task-filter strip with «همه» plus Time, Projects, Branch/Center, Categories and Tags.
- Explicitly left expand/collapse behavior for Branch or Project tree nodes undecided unless the product owner makes a separate decision.
- Clarified that the Home card expansion and HomeFollowUpPresentationService changes exist in source history, but acceptance still requires exact-SHA test/device evidence. The remaining Branch/Project/Task structural model and complete five-filter strip remain PLANNED / NOT ACCEPTED.
- Reaffirmed that this documentation update does not complete product work and does not authorize restoring deprecated Next Follow-up or synthetic followUpEnabled.
- Exact-SHA checkpoint for 758edb259b55ecd69b6509e50b94aeadd378e88e: Build run 41451772834 SUCCESS; independent File Persistence run 41451772534 SUCCESS (storage-only evidence); Calendar Provider run 41451772492 SUCCESS; Device Smoke run 41451772497 still IN_PROGRESS at checkpoint, with five lanes SUCCESS, Calendar CANCELLED and Follow-up Persistence without a final result; Review APK run 41451772502 FAILURE and no artifact. These outcomes do not establish full Device Smoke or approved APK.
- Documentation-only change. No product runtime, test, assertion, schema, migration, dependency, main, merge, release, or workflow dispatch change.

# Arvin Changelog

## 2026-11-02 — Wave 7.270 Home and Fast Lane recovery

- Fast Lane validator now decodes the emulator workflow's Base64 shell payload and validates the real `flutter drive` command without removing or weakening emulator execution.
- Home task cards now expand in place, retain a separate Task Details action, and show description plus exact due date/time.
- Home task cards use `HomeFollowUpPresentationService` to display only the latest persisted `task.lastFollowUp`; legacy dates do not create synthetic history.
- Home Bottom Navigation now animates with scroll direction; the Scaffold Quick Capture FAB remains outside that animation.
- Centered Bismillah typography now uses the official Vazirmatn font family.
- Updated Home and workflow contract tests for compact chips, real FollowUp presentation, and decoded Fast Lane validation. Exact-head CI confirmation is pending; these entries do not imply test or release acceptance.


All entries below describe changes on the authorized PR branch. They are not release notes and do not imply release acceptance.

## 2026-11-01 — Calendar filters, all-day handling, and test stabilization

- Updated Calendar selected-day filtering to distinguish All, Unfinished, timed Reminders, and Phone Calendar sources.
- Kept all-day Task entries visible in All and Unfinished, excluded them from the timed Reminder filter, and ordered all-day entries before timed entries in the selected-day list.
- Added widget coverage for the four source filters, all-day inclusion/exclusion, and selected-day ordering.
- Scoped the canonical launcher test's Today label assertion to the primary navigation so the second Today label elsewhere in the page cannot create a false duplicate match.
- Made the Home grouping contract test use a deterministic expanded test viewport rather than relying on a scrollable finder that was not present in the tested tree.
- These changes require fresh exact-HEAD CI confirmation; no test result is inferred from source edits.

## Recent implementation commits recorded on this branch

- `5b04ba94ac6e84837dda333e484072a9a1b817f8` — Calendar selected-day filter invocation and source-filter behavior.
- `329cad47fb570cfb874ae53eaa4cae8980199537` — Calendar widget coverage for the source filters and all-day ordering.
- `92be06603b2ceac62cf77cf064eed51eb71f9a1b` — Changelog synchronization for the calendar all-day/filter correction.

## Governance

- PR #3052 must remain OPEN / DRAFT / UNMERGED. No merge to `main`, tag, release, or APK publication is authorized.
- Issues #823, #2102, and #2299 remain OPEN until their acceptance/evidence conditions are met.
- Release status: **BLOCKED — RELEASE: NO-GO**.
- Vazirmatn is the only approved application UI font; runtime/device verification must be evidenced on the exact candidate SHA.


## 2026-11-02 — Wave 7.272 test-interaction and Device Smoke evidence repair

- Home shell test now asserts the exact current search hint used by the product (including the current «دسته‌ها» wording); no UI behavior was changed to satisfy the test.
- Accordion contract test now scrolls the legacy-only second card into the lazy list viewport before interacting with it, then verifies its Details control exists while no synthetic FollowUp card is rendered from legacy `followUpDate`.
- File-backed Alarm Overlay test now requires the real Complete control to be present, visible and hit-testable before tapping it; the Complete, persistence, reopen and final state assertions remain intact. Added T14a diagnostic marker.
- Device Smoke contract parser now extracts the embedded Base64 shell from the actual pipeline syntax while retaining the exact seven-lane mapping and real `flutter drive` assertions.
- Device Smoke emulator script now writes screenshot output under the absolute GitHub workspace artifact directory, verifies non-zero file size and PNG signature, and logs path/bytes/signature before artifact upload.
- These are source/test/workflow changes only. Acceptance is pending fresh exact-HEAD Build shards, SQLite file-persistence, Parallel Wave and seven-lane Device Smoke with registered non-empty artifacts.

- Added real Home-surface screenshot capture to the Task Lifecycle and Follow-up Persistence integration lanes after their data assertions; each now emits a named screenshot through the host-side integration driver rather than manufacturing an image in the workflow.


## 2026-11-02 — SSOT owner decision and cross-feature architecture audit

- Registered the owner-mandated central SSOT contract for Category, Tag, Project and Branch/Center under Settings Management Hub; all forms, Home shortcuts, search, filters, Reports and Calendar are consumers of canonical data.
- Added the exact-SHA source/data-flow audit matrix at docs/architecture/ARVIN_SSOT_AND_CROSS_FEATURE_DATA_FLOW_AUDIT_2026-11-02.md and Product Spec section 18.
- Recorded current gaps: Category catalog plus Task.category dual representation; non-atomic Category/Tag rename path; Home/editor snapshots without proven global invalidation; Task-only Home search; Reports and Calendar not connected to the complete central taxonomy/Branch model; Branch model/table/store not found in inspected paths.
- Analyzed real File Persistence and Build Shard 2 logs: both pass initial SQLite reopen/readback through T13, then time out waiting for asynchronous Alarm Overlay load completion at T13.5. Exact internal awaited operation remains NOT VERIFIED; Complete tap/handler/final readback were not reached.
- Documentation-only changes. No runtime code, tests, assertions, schema, migrations, dependencies, main, merge, release or workflow dispatch changed. PR #3052 remains OPEN / DRAFT / UNMERGED; BLOCKED — RELEASE: NO-GO.


## 2026-11-02 — Wave 7.292 final validation outcome

- Device Smoke Run 41451772497 on SHA 758edb259b55ecd69b6509e50b94aeadd378e88e is terminal CANCELLED, not PASS.
- Five of seven scenario lanes completed SUCCESS. Calendar Segmented View and Follow-up Persistence both ended CANCELLED during Flutter Drive; both screenshot uploads then failed because no PNG was produced. Cancellation initiator/root cause is NOT VERIFIED.
- Follow-up Device Smoke has no test result; do not substitute the independent File Persistence run 41451772534 (SUCCESS) for it.
- Review APK Run 41451772502 / Job 125298740317 built the staging APK successfully but failed the verification step. Its apksigner output was not surfaced, so the exact failing predicate is NOT VERIFIED and no APK artifact was uploaded.
- Release remains BLOCKED — RELEASE: NO-GO. No acceptance gate is upgraded by these outcomes.


## 2026-11-03 — Home last Follow-up requires a real record

- Home's visible Task-card date and preview remain sourced only from the chronologically latest canonical FollowUp in Task.followUps; a legacy followUpDate or followUpEnabled value no longer supplies a synthetic Home Follow-up.
- The legacyHomeFollowUpDate compatibility accessor now returns only lastFollowUpDate. followUpDate and followUpEnabled continue to round-trip unchanged; no schema, column, migration or stored historical value is deleted or rewritten.
- HomeTodayProjection inherits the same record-only boundary. Added positive/negative projection and Home widget regression coverage, including a reload assertion proving Home rendering does not create a FollowUp record.
- Existing Task Details, Follow-up Office/Notebook, Report Center, Reminder and Due Date paths were not changed. No destructive migration or database compatibility change was made.
- Validation is pending on the resulting exact branch SHA; previous Build/Device Smoke/Calendar Provider outcomes belong to parent SHA db8818c01d9e944717396e3df93bb0a466e92546 and are not evidence for a later commit.
- Governance remains PR #3052 OPEN / DRAFT / UNMERGED; Release **BLOCKED — RELEASE: NO-GO**.


## 2026-11-03 — Home filter bar: no standalone All chip

- Removed only the standalone Home filter-strip chip keyed `home-filter-card-all`. The contextual Time, Projects, Categories and Tags filter cards remain in their approved order.
- Preserved each filter's own unrestricted choice inside its selector: Time “همه”, Projects “همه پروژه‌ها”, Categories “همه دسته‌ها”, and Tags “همه برچسب‌ها”. Each choice clears only its own dimension; it does not reset the other active filters.
- The natural unfiltered Home state remains the default when no filter dimensions are active. Existing global “پاک کردن فیلترها” remains available in the active-filter summary; it is distinct from a standalone All chip.
- Updated Home filter contract tests to assert the absent standalone key, retained per-filter All choices, natural default task display, and independent category clearing while Time remains active.
- No task schema, database record, persistence path, or task data changed. Validation must be reported against the resulting exact SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED; Release **BLOCKED — RELEASE: NO-GO**.


## 2026-11-03 — Wave 7.304 Task Details explicit due-date action
- Added a separate, clearly labeled **«تنظیم موعد برای امروز»** action immediately below the Task Details Due Date row. Tapping this button changes the Task's due date; it does not navigate or alter CalendarPage's selected day. The Due Date row itself remains display-only.
- Wired the action through the existing `TaskMoveToTodayService` and canonical `TaskStore` path. It uses Arvin's existing Iran-local date reference, preserves the existing due time (or uses the current Iran-local hour/minute for an undated Task), and updates only `dueDate` plus `updatedAt`.
- The detail page reloads the returned canonical Task after saving and refreshes the displayed due date. Other Task fields, reminder schedule, checklist, taxonomy and FollowUp history are preserved by the existing service.
- Added a Task Details widget regression covering button placement, explicit tap, Jalali/local-day display, canonical storage reload, preserved due time and unrelated fields. Added a Home regression that completes a task, reopens the app, and verifies the task remains accessible in Archive with its description, checklist and FollowUp history.
- Re-audited Home/Calendar: no independent Home jump-to-today control exists; CalendarPage's `calendar-today` and `calendar-date-jump` controls are retained unchanged. The Home overdue close indicator dismisses only the overdue warning in the current Home state; it does not clear or persistently modify the due date. For a non-overdue task, the same control clears and saves the due date.
- Previous exact-SHA Build on `4eb65a761870422cdbf1aebdd08abd3d4dec523a` failed: Analyze exited 1 with 12 existing info/warning diagnostics (not a Task Details finding); shard test-0 had 201 passed / 1 failed because `home_filter_contract_test.dart` expected missing text `همه مراکز`; shards test-1 through test-5 passed. Device Smoke was still in progress at the checkpoint. Calendar Provider and Draft Review APK completed successfully; review APK artifact exists and is review-only, not releasable.
- New source/test commits through `42f249d64dbfe1c825e3f6207c8b48018c85fc58`. Exact-head CI for this source update and final documentation SHA is required; no PASS is inferred from parent-SHA runs.
- PR #3052 remains OPEN / DRAFT / UNMERGED; `main` unchanged. Release remains **BLOCKED — RELEASE: NO-GO**.

- Follow-up stabilization for the previously failing Home center-filter contract: the test now explicitly scrolls the center filter chip into the visible viewport before tapping it. The assertion for «همه مراکز» and all subsequent filter assertions remain unchanged; no product or Report Center behavior was modified. Exact-head revalidation is required.

- The Task Details action now also falls back directly to `TaskMoveToTodayService` when opened from another feature route that does not inject the Home callback. The action is therefore available on all Task Details entry paths, not only the Home route. Added a fallback-route persistence regression; exact final-head CI remains required.

- Corrected two analyzer findings introduced by the route-fallback regression: the service result is non-null and the test now checks nullable `updatedAt` explicitly before comparing it. No runtime semantics changed; fresh exact-head validation is required.


## 2026-11-03 — Wave 7.304 exact-head verification checkpoint
- Source/test HEAD at this checkpoint: `2ab0bf7ddaa5c1a206cce415d381945311275f30`. A documentation-only follow-up commit will become the new branch HEAD; its exact-SHA workflows must be checked separately.
- The Task Details action is a separate button immediately below the read-only Due Date row. It calls the existing `TaskMoveToTodayService` (Home callback when supplied, canonical service fallback on other routes), which persists through `TaskStore`, uses `IranClock.now()`, preserves an existing due hour/minute, keeps all-day Tasks at midnight, and changes only `dueDate` and `updatedAt`. CalendarPage selection is not involved.
- Due-date action coverage includes button placement, explicit activation, local Iran-day result, canonical persisted reload, preservation of due time and unrelated Task fields, all-day semantics, and the no-callback Task Details route. Home archive regression unmounts/reopens `ArvinApp`, then opens Archive and verifies the completed Task and its description/checklist/FollowUp history remain available.
- Home overdue title and due-date text remain red only; card surface/border and due/status icons remain neutral. Completing an active unfinished Task sets completed+archived before the Home rebuild and persists the full Task via TaskStore; Past is included in the active Home projection and Archive retains the record.
- Home audit: no independent Home calendar jump-to-today control exists. The Home More-menu item «امروز» is a Home time-scope selection, not CalendarPage date navigation, and is retained. No speculative Home control was removed. CalendarPage's `calendar-today` and `calendar-date-jump` controls remain in place and their source file is unchanged in this wave.
- Overdue indicator behavior: the overdue group header's `warning_amber_rounded` is a static icon with no tap handler. The row's neutral close button (`task-card-clear-due-${task.id}`) dismisses an overdue warning in the current Home state only (in-memory map; dueDate unchanged and not saved); for a non-overdue Task, it clears dueDate and saves through the existing path. No Report Center business logic was changed; its RadioGroup migration only preserves existing selection state while using the non-deprecated Flutter API.
- The prior `CenterDeleteBlocked isn't a type` issue is addressed by exporting `CenterDeleteBlocked` from `center_store.dart`; the association test still asserts deletion is blocked. Analyze on this source/test HEAD completed SUCCESS. Six test shards are still running at checkpoint; do not claim shard PASS before terminal results.
- Exact-SHA workflow checkpoint: Build `41593575999` (Analyze SUCCESS; six test shards in progress); Device Smoke `41593575925` (Boot and Navigation in progress; Quick Capture, Calendar Segmented View, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence queued); Calendar Provider `41593576051` in progress; Draft Review APK `41593576139` in progress; Follow-up File Persistence `41593576023` in progress. No APK artifact is yet verified for this SHA.
- Superseded intermediate attempt `e3faf8a7eaa452c28d1a6428c90f9d9633b04efc`: Analyze SUCCESS, but shard test-0 failed in Home filter contract due to an invalid expectation that the single-select category sheet still showed its close tooltip after selecting a category. The test was corrected to target the category RadioListTile and assert auto-dismiss; latest source/test SHA is `2ab0bf7ddaa5c1a206cce415d381945311275f30`. This intermediate failure is not hidden or counted as a final result.
- Release remains **BLOCKED — RELEASE: NO-GO**. PR #3052 must remain OPEN / DRAFT / UNMERGED; main remains unchanged.


## 2026-11-03 — Priority contract audit on exact PR HEAD ec59d91

- Audited the live branch source without rewriting the existing priority implementation. New Task model default, Task Editor initialization, and Quick Capture initialization all use P2 / TaskPriority.medium; Quick Capture resets to P2 after successful save.
- Legacy JSON decoding preserves high→P1, medium→P2, low→P3, none→P4. Missing/unknown legacy values continue to fail soft to P4; this is intentionally distinct from the P2 default for newly created Tasks. P1/P2/P3/P4 colors remain red/blue/amber/grey.
- Canonical Task ordering uses P1→P4. Past ordering puts incomplete Tasks before completed Tasks, then orders within each completion group by priority and due date.
- Exact-HEAD Build run 41625892691: Analyze SUCCESS; test-0 and test-5 FAILED on three unrelated Calendar interaction assertions; test-1 through test-4 SUCCESS. The priority compatibility test, P1→P4 report grouping test, Past incomplete-first sort test, Quick Capture P2 default test, timed auto-reminder test, and manual-reminder independence test all logged PASS. No 44px chip-overflow signature appeared in the six shard logs; the specific 44px visual regression remains NOT VERIFIED because no dedicated reproducer/result was located.
- No priority production code, test assertion, scenario, or timeout was changed. The current Build is not green: calendar Task Details finder (test-0), calendar card action count, and repeat-occurrence canonical Task action (test-5) failed. Draft APK job was skipped by the Draft guard. Device Smoke run 41625892658 was QUEUED and Calendar Provider run 41625892940 was IN_PROGRESS at this checkpoint; Follow-up File Persistence run 41625892728 completed SUCCESS. These results are exact-head only and must not be transferred to a later SHA.
- Iran timestamp: 1405/08/12 14:49 (Asia/Tehran). PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; Release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-03 — Calendar acceptance root-cause corrections (PR #3052)

- Exact pre-fix SHA audited: `1fe99ebd9cf8eac084727f0507f1398ad4806240`. Build #9339 Analyze passed; test-0 and test-5 failed; test-1..4 passed. Device Smoke #6591: navigation and boot passed, other five lanes cancelled before completion. Calendar Provider #1490 was still in progress at last poll. Follow-up Persistence #513 passed. Draft Review APK #166 created and uploaded review-only staging APK artifact `13226856769` (33,032,076 bytes; SHA-256 artifact archive digest `58adf123e9504d959be38a3615e730c6ad20873796ae1509e6312bcc43b6c7b9`); workflow later concluded CANCELLED after the build/signature/package/Vazirmatn verification and upload steps had succeeded. This artifact belongs only to the old SHA and is not the final candidate.
- Root cause A (Task Details key missing): `OfficialCalendarPage` selected `snapshot.data` as the complete Calendar reminder list. When optional official/provider load returned an empty list, it replaced and discarded canonical Task reminders supplied by the launcher. CalendarPage logs showed `incomingReminderIds=[]` on the failing screen. Fixed by merging provider/official rows with canonical rows by stable ID, keeping canonical rows authoritative.
- Root cause B (expected 2 card opens, actual 1): test log showed the second `task-due` card was rendered at Offset(398,312), outside the test viewport; `tester.tap` emitted a hit-test warning and did not invoke its callback. Fixed the test to ensure the card is visible before tapping and assert the callback count increases for each individual card. No production behavior change for this issue.
- Root cause C (repeat occurrence not resolving to canonical Task): the test tapped a card but supplied only `onEditTask` and expected that callback, while the approved product contract is card tap → Task Details. Updated the regression test to supply and assert `onOpenTask` receives the exact original Task. Added the explicit long-press `ویرایش کار` action using the existing canonical `onEditTask` callback; this keeps Details as the tap behavior and edit as a separate explicit action.
- Added a short 320×520 logical-pixel RTL Report Center test with multiple active category/tag/status chips. It asserts six active chips and no Flutter layout exception. This is a reproduction guard only; until the new test runs and the historical 44px defect is specifically reproduced or its absence is established on the intended environment, the reported 44px issue remains **NOT VERIFIED**. No speculative chip layout changes were made.
- Calendar swipe behavior was not changed: configured Swipe export remains the explicit transfer to the phone calendar; card tap continues to open Details. No priority/Quick Capture implementation was changed.
- Code/test commits: `b640393` (merge canonical and optional Calendar rows), `f8aed94` (explicit Task edit action), `9501f1e` (canonical Details key), `004cc0f` (per-card tap hit-test), `86f2493` (short RTL chip viewport regression test). Full final-SHA validation is pending after documentation synchronization.
- PR remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.


## 2026-11-03 — Owner-approved Triple-Track Calendar architecture and exact-head recovery

- Recorded the product-owner decision: (1) Arvin SQLite is the canonical source for Tasks, P1–P4 priorities, categories and centers; (2) the dedicated Android Local Arvin Calendar Provider is the Arvin-owned system calendar and synchronizes Arvin Task create/update/delete; (3) third-party phone calendars are read-only projections inside Arvin. Their content/time/deletion remains owned by the source app unless the user explicitly imports an event as an independent Arvin Task.
- Interaction contract: tapping an Arvin Task/Follow-up card opens only canonical Task Details. Editing is initiated only by the explicit Edit action inside Task Details. External calendar items open in their source calendar; explicit «ثبت در آروین» remains the import path. Task-to-device-calendar transfer remains an explicit configured swipe action.
- On SHA 681251338c226f6db40bac7d9decde36c1c64d97, Build #9344 / run 41628236149 failed: Analyze PASS; test-0, test-1, test-2, test-3 PASS; test-4 and test-5 FAIL; ordinary APK matrix SKIPPED by the Draft guard. The two failures both found an unintended Task Edit action in the Calendar long-press sheet, contrary to the owner-approved Details-only edit route. The repeat-occurrence-to-canonical-Task assertion passed in test-5.
- On that same SHA, Calendar Provider #1495 / run 41628236109 SUCCESS: real emulator CREATE, NO-OP UPDATE, duplicate prevention, UPDATE on the same event ID and DELETE all PASS. Destination migration remains limited to one writable calendar. Evidence artifact 13226554993, 11,211 bytes, SHA-256 ff8bc22074718450c9ed8cb02c9888d23d7fa219431dfc04bf6cf10cca2c4288.
- Follow-up File Persistence #518 / run 41628236070 SUCCESS. Draft Review APK #171 / run 41628236095 SUCCESS: non-debuggable staging APK, signature/package/debuggable/Vazirmatn checks PASS; artifact 13226239078, 33,031,127 bytes, SHA-256 bbc79528f72843e0ad32f10c506b1ace1722caa37b64b838923f43ae2b8b4e51. Ephemeral test key; review-only, not publishable. APK Matrix remains skipped while Draft.
- Device Smoke #6596 / run 41628236041 was not a complete acceptance: Boot, Navigation, Quick Capture and Task Lifecycle PASS; Reminder/Vazirmatn and Follow-up Persistence CANCELLED; Calendar Segmented View was still running at the last inspection. No seven-lane PASS is claimed.
- Targeted correction: commit a39d9dc9d10a786f69d64f40e8f3c72f6f1c43b0 removed the Task Edit entry from Calendar long-press actions. A transient Analyze failure on that intermediate commit exposed an accidental removal of the public CalendarPage onEditTask API; commit ad11694546ed79391df27a4890b635542693f50b restored the public API while keeping the long-press Edit action absent. No assertion was removed or weakened.
- Added a Home-page short-viewport regression guard in commit f96d6f2833be7a51b73fdbb7b4484dd1a1ddb0a8: 320×520 logical viewport, RTL, five actual Home compact filter controls, horizontal scrolling and no Flutter layout exception. The separate Report Center chip-wrap test passing does not prove Home-page behavior. Historical 44px overflow remains NOT VERIFIED until this exact Home test and visual/device evidence complete.
- Exact-SHA validation for f96d6f2833be7a51b73fdbb7b4484dd1a1ddb0a8 was started: Build #9347 / run 41631273704; Device Smoke #6599 / run 41631273582; Calendar Provider #1498 / run 41631273728; Follow-up File Persistence #521 / run 41631273652; Draft Review APK #174 / run 41631273631. These were pending/in progress at documentation time; no result transfers from earlier SHAs.
- Priority and Quick Capture production logic were not rewritten. PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; no merge/release. BLOCKED — RELEASE: NO-GO.


## 2026-11-03 — Production ownership boundary caveat for Calendar Track 2

- Read-only source audit of `lib/services/calendar_provider_sync_executor.dart` and `lib/services/system_calendar_bridge.dart` found the current outbound executor requires an explicit `targetCalendarId` and performs provider CRUD against that selected system calendar. The native bridge also explicitly opens phone-owned events in the source calendar app rather than editing their contents inside Arvin.
- The Android `CalendarProvisioner` acceptance module provisions `ARVIN CI Acceptance` (test account/calendar) for instrumentation. Its CREATE/NO-OP UPDATE/UPDATE/DELETE PASS proves Provider CRUD in the CI acceptance environment; it does not prove that the production app provisions and owns a dedicated persistent Local Arvin Calendar Provider.
- Accordingly, Track 3's source-app ownership boundary is supported by the read-only/native-editor path and explicit Import action. Track 2's required dedicated production Arvin calendar and automatic Task lifecycle synchronization remain **NOT VERIFIED**. Do not promote Provider acceptance to full Track-2 product acceptance. A separate production provisioning/lifecycle design and exact-device evidence are still required.


## 2026-11-03 — Latest exact-head pipeline checkpoint (documentation baseline deaf50aa9ba380812f611d38e993d9d14b2388dd)

- PR #3052 HEAD at checkpoint: `deaf50aa9ba380812f611d38e993d9d14b2388dd`. PR OPEN / DRAFT / UNMERGED; base `main`; main HEAD remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- Build #9350 / run `41631777717`: workflow IN_PROGRESS at last poll; Analyze and all six test shards were IN_PROGRESS; ordinary APK matrix SKIPPED by the Draft guard. No shard result is claimed.
- Device Smoke #6602 / run `41631777262`: preparation SUCCESS; Boot and Navigation IN_PROGRESS; Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View, Quick Capture and Task Lifecycle QUEUED. Seven-lane result NOT VERIFIED.
- Calendar Provider #1501 / run `41631777653`: IN_PROGRESS; no final artifact/result available at checkpoint.
- Follow-up File Persistence #524 / run `41631777208`: SUCCESS on this exact SHA.
- Draft Review APK #177 / run `41631777254`: IN_PROGRESS; no artifact available at checkpoint. Do not reuse older-SHA APK artifacts as candidate evidence.
- Calendar acceptance tests on earlier SHA 681251338c226f6db40bac7d9decde36c1c64d97: Task Details callback/key test PASS and repeat-occurrence canonical Task test PASS. The per-card action-count assertion was not reached because the same test stopped earlier on the unexpected long-press Edit entry; therefore action-count acceptance remains NOT VERIFIED until the corrected exact-head Build finishes.
- The Home-specific 320×520 RTL test was added, but the f96d6f2 run was cancelled when documentation commits superseded that SHA. It has no terminal result yet. Historical 44px overflow remains NOT VERIFIED.
- Production Track 2 remains NOT VERIFIED: current outbound sync accepts a selected `targetCalendarId`; the `ARVIN CI Acceptance` provisioner is a test fixture, not proof of a dedicated production Arvin-owned Android calendar. Provider CRUD acceptance must not be described as full production Track-2 acceptance.
- The next documentation-synchronized HEAD will require its own exact-SHA Build, seven-lane Device Smoke, Provider, Persistence and Draft Review APK checks. No result above transfers to that new SHA.


## 2026-11-04 — Project continuity deployment and exact-HEAD checkpoint

- Established the durable project continuity index under docs/project-continuity/: README, CURRENT_STATE, PRODUCT_DECISIONS, ROADMAP, OPEN_ISSUES, IMPLEMENTATION_LOG and HANDOFF. These files supplement the root AI context, this changelog and the existing continuation ledger; they do not replace historical records.
- Current app/source baseline inspected before this documentation-only sequence: 33f9489b4c7f3fa6173459b6994cea2a5469f500. PR #3052 OPEN / DRAFT / UNMERGED; main unchanged.
- Build run 41805555476 SUCCESS on 33f9489; Analyze and all six test shards passed. APK matrix SKIPPED by Draft guard.
- Follow-up File Persistence run 41805555397 SUCCESS on 33f9489.
- Calendar Provider run 41805555462 FAILED before test execution because Dart Development Service failed to start while loading android_calendar_provider_acceptance_test.dart; zero tests passed. This is a runner/execution blocker, not a product-behavior failure result.
- Device Smoke run 41805555579 was QUEUED at last poll; Boot and Navigation succeeded, Quick Capture and Calendar Segmented View were in progress, remaining lanes queued. No seven-lane PASS is claimed.
- Review APK run 41805393577 was CANCELLED on older SHA b85ed7b6ac5140e877ce1bd0ece6eef2d4819b43; not current-head evidence.
- SHA transition 93a7c2b → ec4f23e contains exactly one commit, ec4f23e9a3745f1c924f8f75d84e0b943591a1d2. Build 41797850701 succeeded on ec4f23e; Device Smoke 41797850589 was CANCELLED.
- Quick Capture currently displays inline empty-title feedback plus a floating SnackBar, matching the existing two-occurrence test. One-versus-two-message UX remains awaiting explicit owner decision; no test was weakened.
- P2P QR/PIN pairing and LWW/tombstones are design proposals only. Device-local clock winner selection is not approved.
- Release remains **BLOCKED — RELEASE: NO-GO**. See docs/project-continuity/CURRENT_STATE.md and docs/project-continuity/HANDOFF.md for the current operating checkpoint.


## 2026-11-04 — Device Smoke terminal result correction
- Device Smoke run 41805555579 on source SHA 33f9489 concluded CANCELLED. Preparation, Boot, Navigation and Quick Capture succeeded; Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View and Task Lifecycle were cancelled. No seven-lane PASS is claimed.
- The earlier queued/in-progress observation in this checkpoint is superseded by this terminal result. A fresh full run is required on the latest candidate SHA.


## 2026-11-04 — Parallel UI scope reconciliation (owner directive)

- Audited exact branch HEAD `957924cd67066db06abe5fd15df2c802729aa3bb` before making changes.
- Report Center already has no independent top-level completed-Follow-up action; the report is selected inside the unified Filters sheet (`report-filter-type-completed-follow-ups`). Existing widget coverage asserts the obsolete top-level key is absent and exercises the unified path. No duplicate control was introduced.
- Home's five top filters in RTL order are already Time → Center → Project → Category → Tags (`home-filter-card-time/center/project/category/tags`). Default labels are dimension names; no standalone «همه» chip is rendered. Existing filter sheets retain their internal reset/apply behavior; that is not a top-bar chip.
- Quick Capture already uses the compact single-line title, full-form shortcut, RTL Center → Project → Category → Tag row, priority/date-time/reminder/recurrence controls and submit/cancel actions. Empty-title behavior remains inline error + SnackBar; no test or assertion was changed. No description/checklist fields are exposed in this compact form.
- These requested UI behaviors were already present at the audited HEAD, so no redundant runtime edits were made. This is a source reconciliation, not a claim that the physical-device visual review is complete.
- Exact-head Draft Review APK run `41807761597` on the same SHA completed SUCCESS; artifact `13311083215` (`arvin-review-staging-apk-957924cd67066db06abe5fd15df2c802729aa3bb`) is available and not expired. It is a review/staging APK, not a production release APK.
- Exact-head Build run `41807761390`: SUCCESS (Analyze and six test shards); APK matrix SKIPPED by Draft guard. Calendar Provider run `41807761328`: SUCCESS; Follow-up Persistence run `41807761334`: SUCCESS. Device Smoke run `41807761329` has not reached a verified terminal seven-lane conclusion at this checkpoint; partial lane results are not overall acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Local P2P Phase 1 design specification (ARVIN-EXEC-1405/08/14-LOCAL-P2P-SYNC)

- Added `docs/project-continuity/LOCAL_P2P_SYNC_SPECIFICATION.md` as a Phase 1 design-only specification for direct local Wi-Fi / hotspot synchronization between explicitly paired Arvin devices.
- Pairing UX records the requested one-time QR or four-digit PIN paths. The document explicitly treats a four-digit PIN as low entropy and requires short expiry, strict rate limiting, authenticated encrypted key establishment, peer confirmation and security review; QR/PIN alone is not treated as secure authentication.
- Defined privacy boundaries, no Internet/cloud/relay dependency in Phase 1, and a separate deferred Cloud/Dropbox Phase 2.
- Documented canonical entity boundaries, a conceptual versioned operation envelope, durable journal, idempotent receive/apply, acknowledgement/cursor rules, transactional writes, non-destructive SQLite/Drift migration, conflict visibility, revocation, retry/resume and two-device acceptance criteria.
- No application source code, database schema, tests, workflow configuration, font assets or runtime behavior was changed. No test was removed, weakened or skipped. Vazirmatn remains the official font.
- QR/PIN cryptography, discovery/transport implementation, exact schema and conflict algorithm remain design decisions requiring security/technical review. Local P2P implementation and physical acceptance remain NOT VERIFIED. LWW, tombstone policy and device-clock winner selection are not approved by this document.
- Starting branch HEAD: b299c5ccddf9123a661e8a5c52dc3b0548265d35. This is a documentation-only commit; all existing CI/device evidence remains bound to its original SHA and must not be transferred to the new documentation SHA.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details UI reference audit (PR #3052)
- Exact audited source SHA: 0f2977a26d76fbe301b27aef05270b2d7568f4d2. PR #3052 remains OPEN / DRAFT / UNMERGED; main remains unchanged.
- Identified `TaskDetailPage` in `lib/task_detail_page.dart` and `_openTaskDetail` route in `lib/main.dart`.
- Source audit confirms repeated priority and due-date presentation, repeated category/tag metadata, a fixed bottom action bar, canonical due date, independent TaskReminders, Follow-up history, multiline description editing, and related people distinct from any assignee concept.
- No dedicated assignee field was found in the inspected Task model; do not infer assignment from `Task.people`.
- Two user-referenced screenshots were not available to inspect in this audit input. Pixel-level comparison and exact reference conformity remain NOT VERIFIED. No speculative runtime UI changes were made.
- Exact-SHA Build run 41815969951 SUCCESS (Analyze and six test shards); focused Task Details tests logged PASS. APK matrix SKIPPED by Draft guard. Provider run 41815969715 SUCCESS; Follow-up File Persistence run 41815969772 SUCCESS; review-only APK run 41815969817 SUCCESS (artifact 13314402997).
- Device Smoke run 41815969732 was incomplete at last poll: Calendar Segmented View job 126526712495 remained IN_PROGRESS after the other six lanes succeeded. Do not claim seven-lane acceptance.
- Full audit and staged plan: `docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md`. Continuity snapshot refreshed in `docs/project-continuity/CURRENT_STATE.md`.
- No test or assertion was deleted, weakened, skipped or bypassed. No main write, merge or release. Release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details UI alignment
- Reorganized Task Details around a compact title/status/priority summary, separate description card, RTL metadata order, conditional template source and a single due-date card.
- Consolidated status and priority and removed P1–P4 code labels from this page; preserved all existing task actions and lower feature sections.
- Added bottom scroll clearance for the fixed action bar and focused widget tests for RTL ordering, due-date uniqueness, related-person semantics and bottom actions.
- No Task model, storage schema or migration was changed. The model has no execution-time or independent assignee field; related people are not assignees.
- Actual screenshot and pixel-level visual acceptance remain NOT VERIFIED. Exact-SHA CI is pending; PR remains Draft and release NO-GO.


## 2026-11-04 — Exact-SHA CI failure and review APK evidence (a85145de7be4b0d23854e320885f665d50eb35cc)
- Build run 41823721080: FAILURE. Analyze failed at lib/task_detail_page.dart:1158:30 with unnecessary_string_interpolations. APK matrix was SKIPPED by the Draft guard.
- Test shards: test-4 SUCCESS; test-0, test-1, test-2, test-3 and test-5 FAILURE. Do not report the suite as passing.
- Task Details evidence from task_detail_master_screen_test.dart: PASS — clone action invokes canonical handler; title and multiline description save inline; summary/metadata/due date appear once in RTL order; related people are not presented as assignees and bottom content remains clear.
- Task Details failures: independent Reminder toggle could not find key task-detail-reminder-reminder-toggle-1 (line 83); ordinary-task smart visibility could not find task-detail-add-reminder (line 110); rich-section visibility could not find task-detail-independent-reminders (line 163). Related checklist failures: task_detail_checklist_flow_test could not find task-detail-checklist (line 29), and task_detail_checklist_crud_test could not find task-detail-add-checklist (line 72). These are real assertion/finder failures, not skipped tests.
- Related Task Details flow failures: add Follow-up key task-detail-add-followup absent (task_detail_followup_flow_test lines 58 and 193); existing FollowUp edit path raised StateError: No element in ensureVisible at line 252; Today action vertical-order assertion expected >520.5 but observed 478.0 (line 403; same 478.0 vs >520.5 in task_detail_due_date_action_test line 62).
- Calendar Provider run 41823721063: SUCCESS; artifact 13318164013.
- Draft Review APK run 41823721031: SUCCESS; artifact 13317704369, 38,206,200 bytes ZIP. Extracted review APK: 76,806,159 bytes, SHA-256 f3f3efdf74bff2b239f24145c69bbd98fbcf2ac0e2f3bb043e70c6f8d9dcea57. Manifest: applicationId com.example.arvin.staging, android_debuggable=false, v2/v3 signature verified, ephemeral test-only signing key, publishable=false, release_created=false. Review/install testing only; not a production/release APK.
- Device Smoke run 41823721013: still incomplete at last poll. Boot, Navigation, Quick Capture and Task Lifecycle SUCCESS; Reminder/Vazirmatn and Calendar Segmented View IN_PROGRESS; Follow-up Persistence QUEUED. No seven-lane PASS.
- No tests/assertions were modified, removed, weakened, skipped or bypassed during this audit. No timeout workaround was applied. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Quick Capture compact selector compile correction
- Fixed the missing `ArvinTagRollBox.compact` field required by the compact 40dp tag selector; commit `642a4016cbaa1994b4dfe2d278066941ef8a65c2`.
- The pre-fix exact-SHA Staging build failed at `lib/widgets/arvin_roll_box.dart:78` and `:144–149` because the constructor and widget build referenced an undeclared `compact` field. This was corrected without changing task data, field order, save logic, or test assertions.
- Compact spacing and sizing remain UI-only. Vertical scroll remains a safety fallback; physical no-scroll fit and pixel-level comparison to `photo_1793800214435.webp` are NOT VERIFIED.
- Fresh exact-SHA CI is required after documentation synchronization. PR #3052 stays OPEN / DRAFT / UNMERGED; `main` untouched; release BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — CI evidence update for compact Quick Capture (`a657691`)
- Exact-SHA Follow-up Persistence passed (`41843445148`).
- Build Analyze is blocked by one `unnecessary_const` lint at `lib/quick_capture_dialog.dart:587:42` (`41843444962`); six test shards had not completed at inspection.
- Device Smoke (`41843451312`) and Calendar Provider (`41843445191`) were still in progress/queued. Draft Review APK (`41843444971`) was still assembling and had no uploaded artifact at the last check.
- Quick Capture compact-layout tests exist, but their final shard result and scroll-free physical layout are not verified. The dialog retains a vertical scroll fallback.
- No tests were removed/skipped/weakened and no timeout was artificially increased. PR #3052 remains OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.


## ممیزی CI آروین — ۱۴۰۵/۰۸/۱۳ (2026-11-04)

- ممیزی دقیق SHA `3f849eefed2afe08c3d3662cf66d9c488388e737`: Analyze و شش شارد تست PASS؛ Follow-up SQLite PASS.
- Device Smoke run [41852048093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852048093) در زمان ممیزی کامل نشده بود؛ فقط Preparation موفق، Boot/Navigation در حال اجرا و پنج سناریوی دیگر در صف. نتیجه نهایی NOT VERIFIED.
- Calendar Provider run [41852047809](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047809) و Review APK run [41852047701](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047701) در حال اجرا بودند. Artifact جدید هنوز موجود نبود؛ لینک APK NOT VERIFIED.
- اصلاح اسکرول قبل از Finder در test-3 ثبت شد. تست‌ها تضعیف نشدند. PR #3052 OPEN / DRAFT / UNMERGED؛ main دست‌نخورده؛ Vazirmatn و فیلدهای Task حفظ؛ Release BLOCKED — RELEASE: NO-GO.
- این گزارش snapshot همان SHA است؛ مستندات در commit بعدی به‌روزرسانی شدند و اجرای CI روی SHA جدید باید جداگانه بررسی شود.

## R6 — exact-SHA review APK and live smoke checkpoint (2026-11-04; source SHA: 1815ef72864f3e792661eee08cc932b29ff94c88)
- Review Staging APK run [41874160600](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160600) completed SUCCESS on the exact source SHA. Artifact [13345822544](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip), name `arvin-review-staging-apk-1815ef72864f3e792661eee08cc932b29ff94c88`, ZIP size 38,211,551 bytes, SHA-256 `0821c0b1749e5e852d68283eb5c4181bbb15877f9c701954f56e18db685a5ab1`, expires 2026-11-11 17:12:04 UTC. Direct ZIP: https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip
- Extracted APK: `Arvin-review-staging-1815ef72864f3e792661eee08cc932b29ff94c88.apk`, 76,822,515 bytes, SHA-256 `24295b19eea0300623167fbe400320a961feefbc3e6045e1015c43560a306e75`; application ID `com.example.arvin.staging`; `android_debuggable=false`; APK Signature v2/v3 verified. Signer certificate SHA-256 `f3c4ffe277b87daa789596ae3275fc8d9d59fc1d1236b83a7fa1190cb7a3d37b`. Ephemeral review-only test key; `publishable=false`, `release_created=false`. This artifact is for private review/install testing only, not production or release acceptance.
- Build #9553 run [41874160729](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160729): Analyze and all six test shards (0–5) SUCCESS on the exact SHA. Draft-guarded ordinary APK matrix job was SKIPPED as expected; this is not the Review Staging APK job.
- Device Smoke #6800 run [41874160773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160773): matrix preparation SUCCESS. At the latest job-level poll: Boot IN_PROGRESS; Navigation IN_PROGRESS; Quick Capture QUEUED; Follow-up Persistence QUEUED; Task Lifecycle QUEUED; Calendar Segmented View QUEUED; Reminder/Vazirmatn QUEUED. Screenshot/evidence upload steps had not started. Seven-lane acceptance is NOT VERIFIED. The run-level API status was reported as queued while two lane jobs were already in progress; job-level states are recorded above.
- Calendar Provider Acceptance #1698 run [41874160623](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160623): exact-SHA checkout and setup succeeded; real Provider instrumentation/acceptance step remained IN_PROGRESS; evidence publication pending. Final acceptance NOT VERIFIED.
- Repository cleanup audit on the same source SHA: complete recursive tree (790 entries, not truncated); no tracked APK/AAB, generated build/output/cache/temp directories, or safe deletion candidates found. No cleanup deletion or cleanup commit was made.
- PR #3052 remains OPEN / DRAFT / UNMERGED with head `1815ef72864f3e792661eee08cc932b29ff94c88`; branch is unchanged at this checkpoint. `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`. No code changes, merge, release, or publication were made.
- **BLOCKED — RELEASE: NO-GO.** Physical tablet installation/behavior, seven-lane Device Smoke, Calendar Provider terminal result, and product-owner release acceptance remain separate gates. This evidence applies only to source SHA `1815ef72864f3e792661eee08cc932b29ff94c88`; any documentation commit creates a new HEAD and does not inherit these exact-SHA CI results.


## 2026-11-05 — Module-Core-Logic v1.0 audit (source SHA: 4021c84ceb14faf4f6559379cf67dd94955bffe4)
- Registered the evidence crosswalk in `docs/project-continuity/PRODUCT_DECISIONS.md` and updated continuity log, current state, handoff and backlog; detailed exact-SHA evidence is in `docs/ARVIN_CONTINUATION_LEDGER.md`.
- Confirmed Task Due Date / TaskReminder separation, FollowUp.dateTime persistence, Stop/Snooze/Follow-up Alarm paths and scheduler ID 42002 semantics.
- Found a delivery gap: disabled TaskReminders are not filtered in `FollowUpReminderDeliveryService.due`; Reminder creation has no explicit idempotency guard. Legacy scheduling fields remain in model/schema; no real DB backup inspection, so destructive migration remains blocked.
- Exact SHA CI: Analyze PASS; four test shards PASS and two FAIL; visual golden FAIL; Follow-up Persistence PASS; Calendar Provider PASS; Device Smoke 4/7 PASS and 3/7 CANCELLED.
- PR diff test-scenario preservation is NOT VERIFIED: prior tests/assertions were rewritten or removed in several files; no explicit new skip/timeout directive was detected. No code/test changes were made by this audit.
- PR #3052 OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.
## 2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴ — Arvin uniform UI design tokens
- Recorded the owner's new visual-token directive, superseding earlier active palette values while retaining old docs as historical evidence.
- Added central `ArvinTheme` tokens, routed shared palette aliases/global light CardTheme/AppBar and selected shared Home/navigation/selector surfaces through them; Vazirmatn and semantic priority/status/taxonomy behavior retained.
- Added focused token/semantic-color test. Existing tests/assertions were not edited or weakened.
- Whole-app custom card conversion and physical visual acceptance remain NOT VERIFIED; CI on the resulting SHA is required.
- PR #3052 stays OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.

### 2026-11-05 10:03 Asia/Tehran — ۱۴۰۵/۰۸/۱۴ — Target-screen card alignment follow-up
- Applied shared card surface/radius/shadow tokens to Task Details, Task Editor reminder/checklist cards, Quick Capture cards/canvas and Calendar reminder cards.
- No product logic, model, persistence, workflow or existing test assertion changed. Full secondary-route conversion and physical visual acceptance remain NOT VERIFIED.

## 2026-11-05 13:02 Asia/Tehran — ۱۴۰۵/۰۸/۱۴ — TaskHomeScreen final specification and UI alignment (PR #3052)
- Added the canonical fourteen-point Home contract at `docs/project-continuity/task_home_screen_spec.md`.
- On the authorized PR branch, aligned the Home header: hamburger opens the navigation drawer; the general funnel exposes Today, Timeless, Archive and Trash; notification bell and standalone header search icon are removed. The independent search field remains with placeholder «جستجو در کارها...».
- Kept the five quick filters in strict RTL order (Time, Center, Projects, Categories, Tags) and added the independent sort icon at the far-left end of that same horizontally scrollable row.
- Added sort choices and made Follow-up Date the default primary sort key; undated Follow-ups remain last, with priority and stable Task ID as deterministic tie-breakers. Existing Past-group ordering remains unchanged.
- Home groups now render Past → Today → Tomorrow → Future → Timeless; dated headings include the dynamic Persian weekday and Jalali date. The group classification remains Due Date-only; completed past-due tasks remain in Past without being treated as active overdue work.
- Added Center to the task-card taxonomy metadata using the canonical Project → Center relationship. Existing card actions and canonical data pathways are retained.
- Primary navigation was verified to contain exactly five tabs: Home, Calendar, Notebook, Reports, More. «اقدام بعدی» is not a sixth primary tab.
- Existing test files and assertions were not edited, deleted, skipped, weakened or bypassed. Exact-SHA Analyze/widget-test evidence is pending on the final documentation-synchronized HEAD. PR remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

 
## TaskHomeScreen analyzer correction — 2026-11-05
- An intermediate Analyze run on source checkpoint `da311c2f7e4ef9b96fc20a26e31eca996fa63d50` found the plugin import had also been removed even though the app-level notification tap handler still uses `NotificationResponse`, and found an orphan private `_openPendingReminder` helper after removing the Home bell.
- Corrected in `c0766a5e602d04426486816e95cad4038b667fa7`: restored the plugin type import for the retained notification-response path and removed the now-unreferenced pending-notification helper. The Home header remains bell-free.
- No test files or assertions were changed. Analyze and widget tests on the corrected/final SHA remain NOT VERIFIED until a fresh exact-SHA run completes.

 
## TaskHomeScreen final source delta — 2026-11-05
- Added an explicit accessible semantic label to the independent Home sort action: `72e6779f268bb0ca971b651ad0228604b504f4c8`.
- Ensured the Past group heading also uses the calendar icon when Past is selected directly from the Time filter: `460a40b6411c6c63691817e45ef00aab61544bd8`.
- These are source-only follow-ups; no test file or assertion was changed. The latest exact-SHA Build and Device Smoke runs must complete before any PASS is recorded.


## Owner-approved sacred phrase typography and Task Details scroll verification — 2026-11-05
- Recorded the final typography rule: Vazirmatn for all UI; only the Bismillah phrase on Home and «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» on Calendar may use the narrowly scoped Naskh treatment.
- Calendar header now uses `AppFonts.familyForText` for the exact approved phrase; `test/calendar_page_test.dart` verifies the exact whitelist match and confirms ordinary Persian text remains Vazirmatn.
- Home Bismillah uses the shared exact-text whitelist; dedicated Home and typography tests cover the exception boundary.
- Added `test/task_detail_scroll_save_test.dart` for scroll-offset preservation across inline-edit entry and successful save. Existing cancel-path coverage remains.
- Visual timeout diagnosis: the previous `pumpAndSettle` waited indefinitely for scheduler idle; the test now uses deterministic pumping and asserts no scheduled frame before capture. The approved golden file is still absent, so Visual acceptance remains BLOCKED pending a real captured and reviewed baseline.
- Exact-SHA test/CI and physical-device glyph verification are not claimed by this entry.


## Owner typography decision, reusable templates and Task Details evidence — 2026-11-05
- Applied the owner's final typography rule: Vazirmatn for all UI; the exact whitelist permits Naskh-style serif only for «بسم‌الله الرحمن الرحیم» and «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» (or the approved unvowelled UI spelling).
- Added exact-text font selection in `lib/theme/app_fonts.dart`; Home and Calendar use it. Persian UI text remains on Vazirmatn.
- Added Home typography whitelist assertions and retained Calendar phrase typography coverage.
- Expanded Task Details scroll-offset coverage to include entering, cancelling and successfully saving inline edits.
- Consolidated Task Template UI creation coverage to one clean instantiation path; asserts the source Task and its execution history remain unchanged.
- The Visual test now advances a static screen deterministically and asserts no scheduled frame before capture; no timeout was increased and no assertion was skipped. The approved golden is still absent, so visual acceptance is BLOCKED pending a reviewed baseline.
- Exact-SHA CI and physical-device glyph validation are not claimed until their respective evidence is available. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

- Added `test/home/home_filter_boolean_logic_test.dart` for OR within Category/Tag selections and AND across those dimensions (commit `f6e1f38f93279621716a5734f8ea763a2cd19a2e`); exact-SHA result remains unverified.

## 2026-11-05 — اصلاح مانع کامپایل G1 Drift

- خطای نوع `Expando<Future<void>?>` در `G1DriftSchema` با نگهداری Future در `Expando<Object>` و cast کنترل‌شده هنگام خواندن اصلاح شد.
- این تغییر در پاسخ به شکست exact-SHA run `42069322654` انجام شد؛ تست Persistence در آن اجرا به علت خطای کامپایل پیش از اجرای تست با `0 tests passed` متوقف شد.
- نتیجه تست روی SHA جدید هنوز NOT VERIFIED است؛ هیچ PASS از SHA قبلی منتقل نمی‌شود.
- PR #3052 همچنان باید OPEN / DRAFT / UNMERGED بماند؛ انتشار **BLOCKED — RELEASE: NO-GO**.

## 2026-11-05 — رفع موانع کامپایل، فونت عبارات مقدس و تست ساختاری Task Details

- خطاهای const در هدر Home و عنوان Calendar برطرف شد؛ عبارت‌های مقدس فقط از خانواده serif سیستم با زنجیره fallback مرتب Noto Naskh Arabic / Noto Naskh Arabic UI / NotoNaskhArabic استفاده می‌کنند. متن‌های دیگر همچنان Vazirmatn هستند.
- تست sacred phrase اکنون Home و Calendar را با هر دو عبارت، وزن 600 و fallback مشخص بررسی می‌کند و عدم نشت استثنا به متن عادی را assert می‌کند.
- تست Visual از matchesGoldenFile و فایل PNG ناموجود به آزمون Layout/Render Smoke تبدیل شد: ۹ بخش محتوایی واقعی به‌علاوه AppBar و نوار اقدامات ثابت، با بررسی ابعاد، اسکرول و خطاهای Render.
- خطاهای کامپایل Task Details اصلاح شد: TaskTemplateStore از ورودی تزریق‌شده یا نمونه canonical استفاده می‌کند و PopupMenuButton آیتم حذف را با enabled زمان اجرا می‌سازد.
- این تغییر عمداً فونت binary جدیدی به‌عنوان asset ادعا نمی‌کند؛ در این مرحله fallback سیستم‌عامل/وب پیکربندی شده است. رندر فیزیکی Naskh روی دستگاه‌های مختلف همچنان نیازمند بررسی دستگاهی است.
- تمام تست‌ها و گردش‌کارهای جدید باید روی SHA نهایی این مجموعه اجرا شوند؛ نتایج SHAهای قبلی قابل انتقال نیستند.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده و BLOCKED — RELEASE: NO-GO است.


## ۱۴۰۵/۰۸/۱۴ (2026-11-05) — قرارداد نهایی Vazirmatn + دو SVG اختصاصی
- تصمیم مالک محصول: Vazirmatn تنها فونت متنی در کل محصول است؛ هرگونه فونت ثانویه، serif سیستم و fallback ممنوع است.
- بسم‌الله هدر Home و عبارت «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ» سربرگ تقویم باید SVG اختصاصی مبتنی بر vector path واقعی باشند، نه فونت متنی یا raster.
- مشخصات بصری بسم‌الله: مرکز هدر بالای آروین، عرض هدف موبایل ۱۸۰–۲۳۰px، مقیاس‌پذیر در تبلت، سرمه‌ای برند، بدون سایه/پس‌زمینه سنگین و دارای دسترس‌پذیری متنی.
- مرجع تصویری دقیق در سوابق/دارایی‌های قابل بازیابی یافت نشد؛ path نهایی خوشنویسی و تطبیق با مرجع تا دریافت تصویر **NOT VERIFIED** است.
- Layout Smoke ساختاری باقی می‌ماند و باید ۱۱ سطح، ابعاد مثبت و finite، اسکرول و نبود RenderFlex/Bottom overflow را بسنجد؛ تست‌ها یا پوشش آن‌ها حذف نمی‌شوند.
- در ممیزی HEAD قبلی، Build FAILED و APK matrix به‌علت Draft بودن اجرا نشد؛ Device Smoke کامل نیست. هیچ ادعای APK پایدار یا انتشار وجود ندارد.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## به‌روزرسانی اجرای قرارداد نهایی — ۱۴۰۵/۰۸/۱۴ (2026-11-05)
- در کد، AppFonts به یک خانواده متنی واحد Vazirmatn محدود شد؛ serif سیستم، Naskh fallback و هرگونه fontFamilyFallback از Home و Calendar حذف شد.
- تا زمان ثبت SVGهای path-based، دو عبارت به‌طور موقت در Text widget با Vazirmatn رندر می‌شوند؛ این وضعیت فقط گذار ایمن است و پذیرش نهایی vector typography محسوب نمی‌شود.
- تست Home/Calendar برای نبود fallback و یگانگی Vazirmatn به‌روزرسانی شد؛ تست HomeVisualIntegration نیز دیگر انتظار فونت ثانویه ندارد.
- موانع exact-head قبلی در کد اصلاح شدند: const نامعتبر در HomeVisualIntegration، fixture غیر const در Task Template Conversion، Material surface در کارت‌های Task Details، و finite width/height در Layout Smoke.
- HEAD کد پس از اصلاحات: `2a50457cde537ca02544839397c88c998153f5b4`. پس از آن، این ثبت مستندات SHA را تغییر می‌دهد و تست‌های exact-SHA باید روی آخرین HEAD جدید اجرا شوند.
- GitHub workflow API برای HEAD کد فعلی اجرای جدیدی گزارش نکرد؛ بنابراین نتیجه اصلاحات و Layout Smoke روی این HEAD هنوز **NOT VERIFIED** است. هیچ نتیجه قدیمی به این SHA منتقل نمی‌شود.
- مسیر SVGها، dependency رندر SVG و تست روشن/تاریک/چندرزولوشن تا دسترسی به تصویر مرجع و پیاده‌سازی واقعی باقی است.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## AIPOS v1.0 governance checkpoint — 2026-11-05
- Added/updated the seven continuity records under docs/project-continuity: README, CURRENT_STATE, PRODUCT_DECISIONS, ROADMAP, OPEN_ISSUES, IMPLEMENTATION_LOG and HANDOFF.
- Canonical product contract records Vazirmatn-only UI text; dedicated path-only SVG calligraphy for the two sacred phrases; checkbox filters; Center > Project > Category > Task; Overdue-first time filter; and the three-layer Calendar separation.
- flutter_svg 2.3.2 and matching lockfile are present; G1 lock-sync passed on checkpoint SHA 7327c4e0f472e52b12ecd330cb0331132d8aa396.
- Follow-up persistence passed; Build/Analyze, Calendar Provider, seven-lane Device Smoke and Draft Review APK were incomplete at the checkpoint. No full flutter analyze/test or Debug/Release APK result is claimed.
- Both requested SVG files remain absent because the approved reference artwork could not be retrieved. Exact vector calligraphy remains BLOCKED/NOT VERIFIED; do not substitute guessed paths.
- Documentation changes create a new HEAD; rerun all acceptance workflows on the resulting SHA. PR #3052 OPEN/DRAFT/UNMERGED; main untouched; BLOCKED — RELEASE: NO-GO.

## ۱۴۰۵/۰۸/۱۵ (2026-11-06) — رفع شکست‌های Task Template/Details و کنتراست SVG
- صف SnackBarهای قبلی پیش از پیام موفقیت ساخت کار از الگو پاک می‌شود تا پیام عملیات تازه فوراً قابل مشاهده باشد.
- تست Smart visibility با ترتیب واقعی lazy list هماهنگ شد: یادآور، تکرار، چک‌لیست، پیگیری و خط زمانی؛ assertion «در انتظار انجام» همچنان فعال است.
- کارت منشأ الگو از کارت خلاصه خارج شد و تنها یک‌بار پس از خلاصه/توضیحات و پیش از موعد انجام رندر می‌شود.
- SVG بسم‌الله Home و تفویض Calendar در تم روشن سرمه‌ای برند و در تم تاریک رنگ `onSurface` می‌گیرند؛ تست‌های تم روشن/تاریک افزوده شدند.
- هیچ تستی حذف یا skip نشد و هیچ پوشش رفتاری تضعیف نشد. تست‌های متمرکز و شش شارد باید روی SHA نهایی تازه اجرا شوند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## ۱۴۰۵/۰۸/۱۵ (2026-11-06) — اصلاح نهایی کنتراست پویا و تست Task Details
- پس‌زمینه کپسول بسم‌الله Home در تم تاریک از `colorScheme.surfaceContainerLow` می‌آید و با رنگ روشن پویای SVG (`onSurface`) هماهنگ است؛ تم روشن رنگ برند قبلی را حفظ می‌کند.
- تست‌های Home و Calendar برای تم روشن و تاریک به سناریوهای مستقل تقسیم شدند؛ مقایسه تم تاریک با رنگ واقعی Theme انجام می‌شود، نه مقدار رنگ هاردکدشده.
- کلید کارت منشأ الگو به `task_detail_template_source_card` استاندارد شد. تست Task Details ابتدا Description را آشکار می‌کند، وجود کارت الگو را پیش از اسکرول بررسی می‌کند و سپس ترتیب آن تا Due Date را می‌سنجد.
- تست‌های موجود، از جمله نشان «در انتظار انجام»، حفظ شدند؛ هیچ حذف، Skip، کاهش assertion یا تغییر timeout انجام نشد.
- این تغییرات نیازمند اجرای تازه شش شارد و Device Smoke روی SHA جدید هستند. PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## ۱۴۰۵/۰۸/۱۵ (2026-11-06) — رفع هشدارهای Analyzer در تست Home
- دو عملگر غیرضروری `!` از `capsule.decoration` در `test/home/home_visual_integration_test.dart` حذف شدند تا هشدارهای `unnecessary_non_null_assertion` برطرف شوند.
- هیچ تست یا assertion حذف، skip یا تضعیف نشد؛ فقط null assertion غیرضروری حذف شد.
- روی SHA مبنا `0d7d76b0889aac972764594db1eee8b8dfa29b7b`، هر شش شارد تست موفق بودند و Analyze به علت همین دو هشدار شکست خورد. APKهای Debug، Release و Staging ساخته و بررسی شدند؛ نتیجه Device Smoke هنوز کامل نبود.
- Analyze و تمام شش شارد باید مجدداً روی SHA کامیت دوم بررسی شوند؛ نتیجه SHA مبنا جایگزین شواهد SHA جدید نیست.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## ۱۴۰۵/۰۸/۱۵ (2026-11-06) — ممیزی SVG تفویض و شواهد exact-SHA
- در کامیت `e81862cbcd723dd0740411de0526aac5e1771e36` فقط تگ `title` از `assets/images/branding/tafweez.svg` حذف شد؛ مقایسه محتوای والد و فایل جدید پس از حذف همین خط، برابری کامل مسیر گرافیکی را تأیید می‌کند.
- SVG نهایی یک `path`، بدون عنصر پس‌زمینه، با رنگ یکنواخت `#1A2B4C` و viewBox اصلی دارد. این بررسی، تأیید منبع فایل است و جایگزین تست رندر/دستگاه نیست.
- روی SHA فوق: Build run `42212225056` در زمان ممیزی IN_PROGRESS؛ Analyze و Visual و شاردهای ۴ و ۵ موفق؛ شاردهای ۰ تا ۳ و APKها در حال اجرا. Device Smoke run `42212224923` PENDING و بدون Job/Artifact بود. File Persistence run `42212224806` SUCCESS (یک تست فایل‌محور)؛ Calendar Provider و Draft Review APK در حال اجرا بودند.
- نتایج SHA قبلی `2c2594e4663b243932620e250b4586e564996461` به SHA جدید منتقل نمی‌شوند؛ نتیجه سطح Workflow برای Build و Device Smoke آن SHA برابر CANCELLED بود.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## ۱۴۰۵/۰۸/۱۶ — ریشه‌یابی شکست‌های CI و اصلاحات پاسخ‌گو به لاگ (checkpoint)

- مبنای این ثبت: Build run `42335681385` روی SHA دقیق `d2e27baea747ddedf42f744297be09ab86753294`. مجموع شش شارد: ۱۲۳۴ تست موفق و ۲۴ تست ناموفق؛ شاردها به‌ترتیب `test-5: 2`، `test-4: 3`، `test-3: 7`، `test-2: 2`، `test-1: 9` و `test-0: 1` شکست داشتند. Analyze و Visual موفق بودند؛ شکست شش شارد، نتیجه Build را FAIL کرد.
- تفکیک علت‌ها از لاگ: کلید قدیمی Scroll در تست‌های Home، برچسب قدیمی ساخت پروژه، جست‌وجوی متن Tooltip به‌جای Tooltip finder، انتظار یک ردیف ثابت برای اولویت‌ها و نوع دکمه ذخیره قدیمی، ناسازگاری قرارداد آزمون با رابط فعلی بودند. سرریز ۴ پیکسلی سلول ماه Calendar و سرریز ۵۳ پیکسلی فرم Task Editor خطاهای واقعی layout بودند. خطاهای `No element` و `Too many elements` جداگانه ثبت شدند و تا اجرای مجدد exact-head PASS فرض نمی‌شوند.
- اصلاحات ثبت‌شده روی شاخه مجاز: `84aa643` افزایش ارتفاع سلول ماه به ۴۸dp و هم‌ترازسازی آزمون ایجاد پروژه؛ `8ada195`، `fc5debd` و `f965448` اصلاح قراردادهای آزمون Home/Calendar/Task Editor؛ `9b8e4cd` چیدمان عمودی کنترل تاریخ/ساعت در عرض بسیار باریک یا مقیاس متن بزرگ؛ `79fee1b` کلید پایدار ساخت مرکز/دسته؛ `2a777fe` هم‌ترازسازی آزمون‌های ایجاد درون‌فرمی؛ `52ecbef` افزودن راهنمای زمینه‌ای Calendar و اصلاح finder آزمون رنگ.
- این اصلاحات هنوز PASS محسوب نمی‌شوند؛ اجرای Build جدید برای SHA نهایی لازم است. هیچ تست یا قابلیت حذف، Skip یا عمداً تضعیف نشده است.
- شواهد SHA قدیمی `d2e27ba`: Calendar Provider run `42335681413` SUCCESS؛ Draft Review APK run `42335681420` SUCCESS؛ Device Smoke run `42335681478` CANCELLED. Artifactهای Staging/Debug از Build همان SHA موجودند؛ digest گزارش‌شده GitHub مربوط به ZIP آرشیو است و **SHA-256 خود APK نیست**.
- SHA فعلی این ثبت: `52ecbef18d7bbc26d2915270e28297d272342634`. Build `42336933347` و Device Smoke `42336933508` در صف و بدون Job؛ Draft Review APK `42336933225` در حال اجرا؛ Calendar Provider `42336933308` در حال اجرا پس از تأیید SHA؛ Follow-up Persistence `42336934664` در حال اجرا. هیچ‌یک هنوز PASS نیستند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ Merge و انتشار انجام نشده؛ **BLOCKED — RELEASE: NO-GO** تا قبولی همه دروازه‌ها روی یک SHA، Device Smoke کامل و پذیرش روی گوشی واقعی.


## اصلاحیه وضعیت exact-HEAD — ۱۴۰۵/۰۸/۱۶

- پس از ثبت checkpoint قبلی، دو اصلاح تکمیلی آزمون ثبت شد: آزمون تاریخ تقویم تعداد دو نمایش معتبر تاریخ را صریحاً می‌سنجد؛ آزمون رنگ Home تمام لایه‌های AnimatedContainer کارت را بررسی می‌کند، نه یک لایهٔ تصادفی.
- آخرین SHA کد/آزمون پیش از همگام‌سازی اسناد: `0d6ac9f44debc6ca6955f8940826979604f3636b`. این ثبت اسناد، commit بعدی و فقط مستندسازی است؛ هیچ نتیجه CI از SHA قبلی به HEAD مستندات منتقل نمی‌شود.
- برای HEAD نهایی پس از این ثبت، Build شش‌شارد، Draft Review APK، Calendar Provider، Follow-up Persistence و Device Smoke باید دوباره اجرا و جداگانه بررسی شوند.
- اصلاحات کد و آزمون تا این نقطه ثبت شده‌اند؛ **رفع‌شدن شکست‌ها هنوز تأیید CI ندارد**. آزمون گوشی واقعی و پذیرش مالک محصول نیز انجام/اثبات نشده‌اند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ بدون Merge و انتشار؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاحیه تکمیلی Home — ۱۴۰۵/۰۸/۱۶

- commit کد/آزمون بعد از checkpoint قبلی: `467e7f76aced41a123f00a99dd334f32f09ad70c`.
- آزمون Quick Capture اکنون رفتار واقعی محصول را بررسی می‌کند: پس از ثبت، فرم عمداً باز می‌ماند؛ ابتدا ذخیره و حفظ تاریخچه از Store بررسی می‌شود، سپس فرم بسته و نمایش Task در Home تأیید می‌شود.
- Finder پیمایش آزمون کارت Home به Scrollable داخل `home-task-list-viewport` محدود شد تا به Scrollable نامرتبط/غایب در بخش‌های دیگر وابسته نباشد.
- این تغییرات فقط اصلاح آزمون بر اساس قرارداد فعلی‌اند؛ بررسی ذخیره واقعی، حفظ تاریخچه و نمایش Home همچنان باید با اجرای تازه Build روی HEAD نهایی تأیید شوند.
- آخرین نتایج قبلی Build متعلق به SHA `d2e27ba` هستند و برای این commit یا HEAD بعدی اعتبار ندارند. وضعیت انتشار همچنان **BLOCKED — RELEASE: NO-GO** است.


## اصلاحیهٔ هدف لمس Quick Add — ۱۴۰۵/۰۸/۱۶

- آخرین commit کد/آزمون: `c0b3715f16b4fd46e67a2c157559f1de71e2d812`.
- چهار گزینهٔ اولویت Quick Add از ارتفاع ۴۰dp به ۴۸dp رسیدند تا حداقل هدف لمس ۴۸dp رعایت شود.
- ماتریس آزمون Quick Add اکنون عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp را با مقیاس متن بزرگ بررسی می‌کند و برای هر چهار گزینه، عرض و ارتفاع حداقل ۴۸dp را assert می‌کند.
- این تغییر به‌همراه اصلاحات قبلی Calendar و Task Editor هنوز در انتظار اجرای مجدد روی HEAD نهایی است؛ تا دریافت نتیجه، PASS محسوب نمی‌شود.
- وضعیت انتشار: **BLOCKED — RELEASE: NO-GO**؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched.


---

## ابلاغ Master و وضعیت اجرایی — ARVIN-DIR-1405/08/16-02-MASTER
**ثبت: ۱۴۰۵/۰۸/۱۶ | شاخه مجاز PR #3052**

- PRODUCT FIRST: نقص محصول در کد محصول رفع می‌شود؛ هیچ آزمونی حذف، Skip یا تضعیف نمی‌شود. اصلاح Finder فقط برای قرارداد واقعاً منسوخ و با حفظ پوشش رفتاری مجاز است.
- فونت یگانه رابط: **Vazirmatn**؛ بررسی `pubspec.yaml`، `lib/theme/app_fonts.dart` و `lib/theme/font_registry.dart` فقط همین خانواده را نشان می‌دهد.
- تم روشن فیروزه‌ای: Primary `#078B91`، Header `#066F75`، Soft `#DDF7F5`، Background `#F0FAF9`، Border `#D9ECEA`. رنگ‌های خطا/اولویت و وضعیت برای معنای وضعیت حفظ می‌شوند.
- SVG بسم‌الله با عرض نمایشی `210dp` حفظ شده؛ آزمون عرض ۲۱۰dp اضافه شده است.
- ترتیب فیلترهای Home: زمان ← مرکز ← پروژه ← دسته ← برچسب؛ مرتب‌سازی جدا و پس از پنج فیلتر است؛ Wrap راست‌به‌چپ و بدون پیمایش افقی.
- «پیگیری‌های انجام‌شده» فقط از بخش «نوع گزارش» در پنل فیلترها انتخاب می‌شود؛ دکمهٔ بالای صفحه وجود ندارد و آزمون آن را کنترل می‌کند.
- Calendar: محتوای سلول ماه درون سلول مقیاس می‌شود و هدف لمس حداقل ۴۸dp حفظ می‌شود؛ ارتفاع اضافهٔ نمای هفتگی کاهش یافته است.
- Task Editor و Quick Capture برای ۳۶۰/۳۹۰/۴۱۲dp، کیبورد باز/بسته و متن بزرگ پوشش آزمون دارند؛ کنترل‌های اولویت Quick Add حداقل ۴۸dp هستند.
- ایجاد مرکز/دسته/برچسب در Quick Capture دیگر کنترل متن موقت را پیش از پایان انیمیشن Sheet آزاد نمی‌کند؛ Sheetها قابل پیمایش‌اند.
- کامیت‌های کد/آزمون: `9de8f221`, `7125e828`, `895c7ad`, `21606a9`, `9946f15`, `4a64d50`, `4f65800`.
- Build روی SHA قبلی `21606a9f3050337d57c0ada2ca4c14c2febe907f` به‌علت توکن تعریف‌نشدهٔ `ArvinTheme.primarySoft` در Analyze/Visual و شاردها شکست کامپایل داشت؛ Follow-up Persistence run `42339727992` نیز به همان علت شکست خورد. توکن مرکزی در commit `4a64d50` تعریف شد؛ نتایج SHA قدیمی به SHA جدید منتقل نمی‌شوند.
- آخرین کد/آزمون پیش از این ثبت: `4f65800612bd0cce95448f39eee67d683e0e6504`. اجرای اختصاصی این SHA هنوز در فهرست GitHub ظاهر نشده؛ هیچ PASS برای آن ادعا نمی‌شود.
- فایل مستقل Master در پیوست‌های این گفتگو یا جست‌وجوی Library پیدا نشد؛ این یادداشت بر متن ابلاغ‌شده در گفتگو متکی است، نه بر ادعای مطالعهٔ فایل پیوست‌نشده.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` بدون تغییر؛ Merge و انتشار ممنوع. Device Smoke و پذیرش نصب واقعی هنوز مانع‌اند.
- **BLOCKED — RELEASE: NO-GO** تا Build، تمام شاردها، Provider، Persistence، Device Smoke و پذیرش گوشی واقعی روی یک SHA واحد PASS شوند.


## پیوست اصلاحیه Master — ۱۴۰۵/۰۸/۱۶

- کامیت تکمیلی محصول پس از ثبت قبلی: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`.
- سطح خالی کارت‌های فیلتر و لهجهٔ سربرگ پنل فیلتر نیز به توکن فیروزه‌ای/سطح خنثی مشترک منتقل شد؛ رنگ‌های برند غیر فیروزه‌ای در کنترل‌های فیلتر باقی نماند.
- آخرین کد پیش از این به‌روزرسانی اسناد: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`. نتیجهٔ CI این SHA تا لحظهٔ ثبت این پیوست هنوز قابل تأیید نیست؛ PASS از SHAهای قبلی به آن منتقل نمی‌شود.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ بدون Merge/انتشار؛ **BLOCKED — RELEASE: NO-GO**.

## ۱۴۰۵/۰۸/۱۶ — تصمیم محصول زمان کار / موعد (ARVIN-DIR-1405/08/16-02-MASTER)
- تصمیم مالک محصول ثبت شد: Task.dueDate تنها Deadline است؛ تاریخ و ساعت ورودی یک کنترل واحد هستند و فیلد موعد تکراری در Quick Capture و Task Details ممنوع است.
- جریان انتخاب: تقویم شمسی، سپس بلافاصله ساعت ۲۴ساعته؛ کنترل دایره‌ای ساعت امکان ثبت تمام‌روز/بدون ساعت را فراهم می‌کند. عبور از ساعت Deadline یا پایان روز محلی در حالت تمام‌روز، مبنای Overdue است.
- Reminder مستقل از Deadline باقی می‌ماند؛ مدل فعلی dueDate و allDay حفظ می‌شود و فیلد ذخیره‌سازی موازی اضافه نمی‌شود.
- این ثبت فقط تصمیم محصول است؛ ویجت مشترک، اتصال فرم‌ها، تست‌های همگام و پذیرش موبایل در این checkpoint هنوز پیاده‌سازی/تأیید نشده‌اند.
- ممیزی exact-HEAD 2553f27f040287b0cf225a4c054777db94821679: Build 42340630768 FAILED؛ Calendar Provider 42340630862 SUCCESS؛ Device Smoke 42340630785 PENDING؛ Draft Review APK 42340630793 SUCCESS.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.

## اصلاحیه HEAD پس از ثبت تصمیم زمان کار / موعد — ۱۴۰۵/۰۸/۱۶
- commit مستندسازی: 70b32df0bb903b3647a206fd63dc15e94f0df78e؛ تغییرات فقط در PRODUCT_DECISIONS.md، CURRENT_STATE.md و CHANGELOG.md است.
- HEAD فعلی شاخه و PR #3052 اکنون 70b32df0bb903b3647a206fd63dc15e94f0df78e است؛ PR همچنان OPEN / DRAFT / UNMERGED و base=main است.
- این commit صرفاً مستندسازی تصمیم محصول است؛ کد ویجت مشترک و اتصال فرم‌ها در این commit تغییر نکرده‌اند.
- برای SHA جدید هنوز Workflow run ثبت نشده است؛ بنابراین تمام نتایج Build/Provider/Smoke/APK قبلی فقط به SHA 2553f27f040287b0cf225a4c054777db94821679 تعلق دارند و به HEAD جدید منتقل نمی‌شوند.
- Device Smoke قدیمی #7233 همچنان مانع صف است و لغو دستی آن توسط مالک لازم است.
- **BLOCKED — RELEASE: NO-GO** بدون تغییر باقی می‌ماند.

## ۱۴۰۵/۰۸/۱۶ — ممیزی exact-HEAD و APK (ARVIN-DIR-1405/08/16-02-MASTER)
- HEAD ممیزی‌شده: 11919b87b309897a7b2f59fdd34a327730188e6e؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر.
- Build run 42343978253 FAILED (سه شارد: 220/2، 182/2 و 302/2 موفق/ناموفق)؛ Calendar Provider 42343978239 SUCCESS؛ Device Smoke 42343978229 PENDING؛ Draft Review APK 42343978230 SUCCESS.
- شش شکست روی HEAD ثبت شد: ذخیره Quick Capture/history، ارتفاع ماهانه Calendar، توکن‌های رنگ معنایی، رنگ منتخب هفته، جایگاه فیلتر/مرتب‌سازی Home، و رنگ SVG سرصفحه تقویم. اصلاح کد/تست هنوز انجام نشده است.
- 895c7ad بررسی شد: فقط تست‌های واکنش‌گرایی، حداقل لمس و Wrap تقویت شدند؛ تستی حذف/Skip یا تضعیف نشده است.
- پالت فیروزه‌ای و Vazirmatn در سورس حاضرند؛ فیلترهای پنج‌گانه و اتصال Person به FollowUp منتظر پاسخ و فیلتر گزارش در سورس موجودند.
- شکاف زمان: دیالوگ ساعت گرد هنوز «بدون ساعت» داخلی ندارد؛ Quick Capture و Task Editor کنترل بیرونی دارند؛ یادآورهای مستقل تاریخ/ساعت جدا دارند؛ Overdue ساعت‌دار در همان روز در Home محاسبه نمی‌شود.
- APK staging exact-HEAD استخراج شد؛ SHA-256 بایت‌های APK: cdd8cc9e7b478e8fe485cfac6465f265b3c1b3ae501f78abc40edbbfa80814d6؛ کلید امضای موقت review-only، غیرقابل انتشار و بدون نصب روی گوشی واقعی.
- Device Smoke قدیمی #7233 / run 42335301964 همچنان صف را قفل می‌کند؛ لغو دستی توسط مبین لازم است.
- **BLOCKED — RELEASE: NO-GO**؛ بدون ادغام، انتشار یا تغییر main.

## ۱۴۰۵/۰۸/۱۶ — اصلاح کنترل زمان و ثبت All-Day
- دیالوگ ساعت گرد اکنون نتیجهٔ مجزای زمان‌دار، «بدون ساعت» و لغو را پشتیبانی می‌کند؛ برای سازگاری، کنترل‌های صرفاً زمان‌محور همچنان API قبلی را استفاده می‌کنند.
- Task Details و Quick Capture برای موعد سفارشی از تقویم شمسی به دیالوگ ساعت گرد می‌روند؛ All-Day از داخل دیالوگ انتخاب می‌شود و با پرچم واقعی ذخیره می‌شود.
- یادآورهای مستقل TaskReminder نیز از جریان مشترک استفاده می‌کنند؛ گزینهٔ چک‌باکسی بیرون دیالوگ حذف شد تا ورودی تکراری باقی نماند.
- اصلاح محاسبه Overdue در ae9a6db و آزمون مرزی زمان‌دار/تمام‌روز ثبت شده است.
- آزمون‌های All-Day افزوده شدند؛ هیچ تستی حذف، Skip یا تضعیف نشد.
- شکاف باقیمانده: legacy Task.reminderDate و FollowUp.reminderDate هنوز پرچم مستقل All-Day ندارند؛ قرارداد مهاجرت و اعلان آن‌ها باید جداگانه تکمیل شود.
- HEAD: 26e635265593a10afc43759c6457220ccb8f084a; در زمان ثبت Run exact-HEAD هنوز مشاهده نشده است. Runهای والد ae9a6db برای HEAD جدید معتبر نیستند.
- Run قدیمی Device Smoke #7233 / 42335301964 اکنون CANCELLED است؛ گلوگاه اجرای قدیمی برداشته شده، اما Smoke تازه لازم است.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.

## ۱۴۰۵/۰۸/۱۶ — یکپارچه‌سازی یادآور پیگیری تمام‌روز
- میانبر یادآور در فرم ثبت پیگیری به یک جریان پیوستهٔ تقویم شمسی و ساعت گرد تبدیل شد؛ انتخاب «بدون ساعت» داخل دیالوگ انجام می‌شود.
- ذخیره از مسیر TaskReminder.isAllDay است؛ اعلان All-Day طبق قرارداد planner در ساعت ۰۹:۰۰ محلی برنامه‌ریزی می‌شود.
- TaskStore.addTaskReminder پارامتر اختیاری isAllDay دریافت می‌کند و سازگاری فراخوانی‌های قدیمی حفظ شده است.
- تست رفتار کنترل واحد و ذخیرهٔ All-Day افزوده شد؛ هیچ آزمونی حذف یا Skip نشد.
- HEAD کد: d969728523d402a72647f608e635dd1c42ed54ab؛ CI این SHA هنوز تأیید نشده است.
- Device Smoke قدیمی #7233 / 42335301964 CANCELLED؛ اجرای قدیمی‌تر شماره 7268 / 42346612483 فعال و در حال مصرف صف بود؛ نتیجهٔ آن برای HEAD جدید معتبر نیست.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.

## ۱۴۰۵/۰۸/۱۶ — اصلاحات پذیرش UI و جدول شکست‌ها
- Home Quick Capture test fixture به 390×844 و ensureVisible اصلاح شد؛ assertionهای ذخیره و حفظ تاریخچه دست‌نخورده‌اند.
- Calendar month test حداقل 48dp و محدودهٔ واقعی 288–320dp را می‌سنجد؛ حد قبلی <280dp با شش ردیف 48dp ناسازگار بود.
- تست توکن‌های تعاملی به پالت یکپارچه فیروزه‌ای به‌روزرسانی شد؛ رنگ منتخب روز Calendar به #DDF7F5 و SVG برند روشن به #1A2B4C بازگشت.
- مرتب‌سازی Home به سمت چپ پنج فیلتر منتقل شد تا پس از آن‌ها در ترتیب RTL قرار گیرد.
- خطای موقت compile در SHA 068d848 (انتساب ArvinTimeSelection به DateTime?) در 26e635 اصلاح شد؛ wrapper legacy زمان‌محور حفظ شده است.
- ۶ شکست Run 42343978253 روی SHA 11919... با اصلاحات کد/fixture/قرارداد آزمون پاسخ داده شدند؛ هنوز PASS بودن آن‌ها فقط پس از Build تازه روی SHA جدید قابل اعلام است.
- بررسی 895c7ad: تغییر تست‌ها پوشش Wrap/حداقل لمس را تقویت کرد؛ تستی حذف یا Skip نشد.
- SHA کد این اصلاحات: 7a1890fa8c1933fb230cdfa92dcd762209eae95c؛ Runهای Build 42347751661 و Device Smoke 42347751648 در PENDING، Provider 42347751668، Draft APK 42347751728 و Persistence 42347751664 در حال اجرا.
- Run قدیمی Device Smoke #7233 لغو شده؛ #7268 / 42346612483 روی SHA db91... هنوز صف را اشغال می‌کند؛ در صورت تداوم، لغو دستی آن توسط مبین لازم است.
- شکاف‌های باقیمانده: All-Day در legacy Task.reminderDate و FollowUp.reminderDate و یکسان‌سازی کامل ظاهر سلکتورهای Task Details با Home هنوز تکمیل/تأیید نشده است.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.
