# سند مرجع جامع محصول آروین — نسخه 1.4 (همساز با قرارداد قطعی)

## Changelog from v1.4

- Governing Issue به **#823** تغییر کرد؛ Issue #1139 صرفاً برای ردیابی تاریخی است.
- **System Default** به‌عنوان فونت جایگزین حذف و ممنوع شد؛ تنها فونت رسمی **Vazirmatn** است.
- Home به شش بخش ثابت و دارای ترتیب قطعی تغییر کرد.
- Swipe فهرست Taskها از طریق تنظیمات قابل پیکربندی شد و گزینه «ثبت پیگیری» اضافه شد؛ انتخاب آن فقط فرم را باز می‌کند.
- تنظیمات مستقل Swipe تقویم با گزینه‌های ویرایش، حذف و انتقال به تقویم گوشی اضافه شد.
- Delete به دو مسیر چرخه عمر تفکیک شد: انتقال نرم به Trash و حذف دائمی متناسب با وضعیت آیتم.
- Device Calendar به‌صورت اختیاری، **Idempotent، Isolated و Failure-safe** تعریف شد.
- **Next Follow-up** و **followUpEnabled** باید از همه لایه‌های فعال محصول و مستندات به‌طور کامل پاکسازی شوند.
- Follow-up Record فقط اقدام واقعی گذشته است و باید دارای **completedAt واقعی** باشد؛ ایجاد رکورد پیگیری بدون اقدام واقعی ممنوع است.
- وضعیت انتشار همچنان **BLOCKED — RELEASE: NO-GO** است.

**نوع سند:** قرارداد مفهومی، رفتاری، طراحی و معیارهای پذیرش  
**مخزن مرجع:** `mobinpda-lab/Arvin-clean`  
**اصل حاکم (Supersedes):** **قرارداد قطعی یکپارچه آروین** (Model × Gestures × Calendar × Font)  
**Issue مرجع پذیرش (قدیمی):** #1139 (صرفاً برای ردیابی؛ در تصمیم‌گیری حاکم نیست)  
**Issue حاکم (Canonical / Governing):** **#823**  
**وضعیت انتشار:** `BLOCKED — RELEASE: NO-GO`

---

## 0) قوانین غیرقابل‌مذاکره (Non-Negotiables)

1. **فونت رسمی:** فقط `Vazirmatn` (باندل داخل APK). گزینه System Default ممنوع است.
2. **مفاهیم ممنوع:** `Next Follow-up` و `followUpEnabled` باید از همه‌چیز پاکسازی کامل شوند: schema، models، DTOs، UI، queries، APIs، tests و docs.
3. **چهار مفهوم اصلی و مستقل:** `Task`، `Due Date`، `Reminder` و `Follow-up Record`؛ ادغام مفهومی ممنوع است.
4. **Follow-up Record فقط اقدام واقعی گذشته است** و باید دارای مقدار واقعی `completedAt` باشد.
5. **حذف (Delete) قطعی است** و در چرخه عمر داده، «سطل زباله / حذف نرم» و «حذف کامل» متناسب با مورد تعریف می‌شود.
6. **تقویم دو مسیر مستقل دارد:** Local Arvin Calendar (خودکار) و Device Calendar (اختیاری، ایزوله و Idempotent).
7. انتشار تا عبور از تمام گیت‌های پذیرش مسدود است.

---

## بخش ۱ — تعریف، مأموریت و اصول حاکم

### 1.1 آروین چیست؟

آروین ابزار شخصی فارسی‌محور برای ثبت، سازمان‌دهی، یادآوری، تکرار، پیگیری اقدام‌های واقعی، تقویم داخلی، گزارش و بازیابی داده است؛ با رفتاری قابل پیش‌بینی، یکپارچه و قابل اتکا.

### 1.2 توانایی‌های اصلی با تفکیک مفاهیم

- ثبت سریع و ثبت کامل Task.
- Reminderهای مستقل و چندتایی برای آینده.
- Follow-up Record برای اقدام‌های واقعی گذشته.
- تکرار (Recurrence) با تفکیک «الگو» و «نوبت».
- مدیریت چک‌لیست فقط در جزئیات Task.
- تقویم داخلی آروین به‌علاوه امکان انتقال یا ثبت انتخابی در تقویم گوشی.
- گزارش‌گیری و جست‌وجوی ترکیبی.
- Backup/Restore با حفظ روابط و تاریخچه.
- UI فارسی RTL با Vazirmatn فقط و PDF فارسی معتبر با فونت Embed‌شده.

### 1.3 اصول غیرقابل‌انحراف

- یکپارچگی مدل و جلوگیری از انحراف مفهومی.
- حفظ تاریخچه و داده معتبر.
- تفکیک مفاهیم Task، Due Date، Reminder و Follow-up Record.
- قابلیت اثبات: هر PASS باید به SHA، Run و Evidence مشخص متصل باشد.
- حفاظت از مخزن: بدون مجوز، شاخه main تغییر نکند.
- شفافیت وضعیت‌ها: PASS، FAIL، IN PROGRESS، BLOCKED و NOT VERIFIED.

---

## بخش ۲ — هویت بصری و فونت رسمی

### 2.1 تصمیم فونت حاکم

- تنها فونت رسمی و پیش‌فرض: **Vazirmatn**.
- System Default ممنوع است و نباید به‌عنوان گزینه یا fallback محصول ارائه شود.

### 2.2 دامنه اعمال فونت

تمام بخش‌های برنامه و تمام خروجی‌های متنی، از جمله PDF.

### 2.3 وزن‌های تایپوگرافی

- عنوان صفحه: 700.
- عنوان کارت/Task: 600.
- کنترل‌ها، چیپ‌ها و دکمه‌ها: 500.
- متن عادی و متن‌های ریز تقویم: 400.

### 2.4 قواعد فنی فونت (Design Agility Protocol)

- فونت باید داخل APK بسته‌بندی شود.
- Theme باید تک‌مرجع باشد.
- Global Render Guard باید از نشت فونت در overlayها و اجزای third-party جلوگیری کند.
- Automated Packaging Audit در CI باید در صورت نبود فونت fail شود.
- PDF باید از نظر Embed بودن فونت و اتصال صحیح حروف فارسی اعتبارسنجی شود.

---

## بخش ۳ — مدل مفهومی کار، پیگیری و یادآور (Canonical)

### 3.1 Task

هر مورد ثبت‌شده یک Task است و می‌تواند Due Date، Reminder، Recurrence، Checklist و Follow-up Record داشته باشد.

### 3.2 Due Date

- از Reminder مستقل است.
- مورد تمام‌روز ساعت واقعی ندارد. مقدار `00:00` صرفاً فنی/نمایشی است و نباید مبنای آلارم یا Sync ساعت‌دار شود.

### 3.3 Follow-up Record

- فقط نمایانگر اقدام واقعی انجام‌شده در گذشته است.
- باید دارای `completedAt` واقعی باشد؛ مقدار آن باید به زمان واقعی تکمیل اقدام مربوط باشد، نه زمان فرضی یا مقدار پیش‌فرض.
- هیچ Next Follow-up وجود ندارد؛ برنامه‌ریزی آینده فقط با Reminder انجام می‌شود.

#### وضعیت «منتظر اقدام شخص»

اگر چنین وضعیت یا چیپی وجود دارد، نباید معادل Next Follow-up شود و به‌تنهایی نباید رویداد تقویم یا آلارم تولید کند.

### 3.4 تبدیل Follow-up Record به کار جدید

اگر قابلیت تبدیل Follow-up Record به Task جدید در محصول وجود دارد یا باقی می‌ماند، باید:

- صریح باشد؛
- رابطه پایدار با رکورد مبدأ را حفظ کند؛
- Idempotent باشد؛
- تاریخچه Task مادر و خود Follow-up Record را دستکاری نکند.

این قابلیت صرفاً می‌تواند یک Task جدید مرتبط با رکورد بسازد؛ نباید مفهوم «کار پیگیری‌دارِ آینده» یا Next Follow-up را بازتولید کند.

### 3.5 Reminder

- Reminderها چندتایی و مستقل‌اند.
- حذف یا ویرایش یک Reminder فقط همان Reminder را تغییر می‌دهد.
- برای Task تمام‌روز، Reminderهای نسبی دقیقه‌ای یا ساعتی مجاز نیستند، مگر آنکه زمان واقعی تعریف شده باشد.

### 3.6 استقلال آلارم و همگام‌سازی تقویم

- ثبت در تقویم گوشی باید ایزوله و Idempotent باشد.
- خطای تقویم گوشی نباید به Task یا Reminder داخلی آسیب بزند.
- سیاست Reminder باید با معماری دو مسیر تقویم در بخش ۶ همساز باشد.

### 3.7 تکمیل Task

- تکمیل Task اعلان‌های آینده را suppress می‌کند.
- تاریخچه و رکوردهای قبلی باقی می‌مانند؛ تکمیل Task نباید تاریخچه را بازنویسی کند.

---

## بخش ۴ — فرم‌ها و جزئیات کار

### 4.1 ورود سریع

- ساده و بدون چک‌لیست.
- نباید فلگ‌های legacy مربوط به Next Follow-up یا `followUpEnabled` داشته باشد.

### 4.2 فرم کامل

- مدیریت چند Reminder مستقل مجاز است.
- Reminderهای نسبی فقط برای موعد ساعت‌دار مجازند.
- برای Task تمام‌روز، ساعت `00:00` مرجع محاسبه Reminder نسبی نیست.

### 4.3 جزئیات Task

محل اصلی برای:

- مدیریت Checklist؛
- مشاهده، افزودن، ویرایش و حذف Reminderها؛
- ثبت Follow-up Record واقعی و مشاهده تاریخچه آن.

فرم ثبت پیگیری نباید صرف باز شدن یا انتخاب یک گزینه Swipe، رکورد واقعی ایجاد کند.

---

## بخش ۵ — چک‌لیست و تکرار

قواعد مفهومی موجود برای Checklist و Recurrence پابرجا هستند، با تأکید بر:

- Snapshot نوبت‌ها؛
- عدم آلودگی یا بازنویسی تاریخچه؛
- جلوگیری از نوبت یا Reminder تکراری؛
- پیش‌نمایش حداکثر پنج نوبت آینده در تقویم.

هر نوبت تکرار باید هویت و وضعیت قابل تشخیص خود را داشته باشد و تغییر الگو نباید به‌طور ناخواسته تاریخچه نوبت‌های قبلی را تغییر دهد.

---

## بخش ۶ — تقویم آروین

### 6.1 نقش تقویم

تقویم نمایی از رویدادهای معتبر آروین و، در صورت پشتیبانی، رویدادهای خارجی است.

### 6.2 دو مسیر تقویمی (Canonical)

#### A) تقویم محلی آروین (Local)

- آیتم‌های واجد شرایط به‌طور خودکار در تقویم داخلی نمایش داده می‌شوند.
- برای Recurrence، حداکثر پنج نوبت آینده پیش‌نمایش داده می‌شود.
- این مسیر نباید به وجود یا دسترسی تقویم گوشی وابسته باشد.

#### B) تقویم گوشی (Device)

- ثبت، حذف و به‌روزرسانی اختیاری است.
- مسیر باید **Isolated + Idempotent + Failure-safe** باشد.
- خطای Provider یا نبود مجوز نباید داده داخلی آروین را خراب یا حذف کند.
- برای مورد تمام‌روز، نباید رویداد ساعت‌دار با زمان `00:00` ساخته شود.
- وضعیت Sync باید قابل بررسی باشد و شکست عملیات نباید به‌عنوان موفقیت گزارش شود.

### 6.3 Swipe در تقویم (Calendar Gestures) — قطعی

در مسیر تنظیمات «تقویم ← حرکت کارت‌ها در تقویم»:

- برای Swipe چپ و راست، Dropdown مستقل وجود دارد.
- گزینه‌های مجاز:
  - ویرایش؛
  - حذف؛
  - انتقال به تقویم گوشی.

تنظیمات Swipe تقویم مستقل از تنظیمات Swipe فهرست Taskها است.

---

## بخش ۷ — صفحه اصلی (Home) و ناوبری

### 7.1 ساختار قطعی Home (شش بخش ثابت)

ترتیب بخش‌ها دقیقاً چنین است:

1. عقب‌افتاده
2. امروز
3. یادآورهای امروز
4. پیگیری‌های واقعی
5. بدون تاریخ
6. انجام‌شده (در پایین صفحه و به‌صورت جمع‌شده)

این ساختار شش‌بخشی جایگزین هر تعریف قدیمی‌تری از Home، از جمله محدودیت «فقط دیروز/امروز/فردا»، است.

### 7.2 قانون خلاصه Reminder در Home

برای هر Task فقط نزدیک‌ترین Reminder آینده در خلاصه Home نمایش داده می‌شود. این قاعده نباید Reminderهای مستقل را در مدل داده ادغام کند یا مانع مشاهده و مدیریت Reminderهای دیگر در جزئیات Task شود.

---

## بخش ۸ — ژست‌ها (Swipe) و چرخه عمر حذف

### 8.1 Swipe در فهرست Taskها — قطعی و قابل تنظیم

در مسیر تنظیمات «کارها و حرکت کارت‌ها»:

- کشیدن به راست: انتخاب عمل از Dropdown.
- کشیدن به چپ: انتخاب عمل از Dropdown.

گزینه‌های مجاز باید شامل موارد زیر باشند:

- **ثبت پیگیری:** باز کردن فرم Add Follow-up Record؛ بدون ایجاد رکورد خودکار.
- بایگانی.
- انجام‌شدن.
- انتقال به سطل زباله / حذف.

«ثبت پیگیری» فقط زمانی به ایجاد رکورد منجر می‌شود که کاربر فرم را تکمیل و اقدام واقعی را ثبت کند؛ خود Swipe یا باز شدن فرم نباید رکورد بسازد.

### 8.2 قرارداد حذف (Delete) — قطعی

اکشن Delete به چرخه عمر حذف واقعی اشاره دارد؛ مسیر دقیق به وضعیت آیتم بستگی دارد:

- **حذف نرم (Soft Delete):** انتقال به Trash برای امکان بازیابی.
- **حذف کامل (Hard Delete):** حذف دائمی متناسب با مورد، از جمله وقتی آیتم از قبل در Trash است یا سیاست چرخه عمر آن را تعیین می‌کند.

حذف نباید تاریخچه‌های مستقل، مانند Follow-up Recordها یا تاریخچه Reminderها، را بدون سیاست روشن و صریح از بین ببرد. اگر سیاست حذف تاریخچه در موردی مبهم است، باید به‌عنوان «تصمیم باز» ثبت شود؛ رفتار مخرب نباید از روی حدس انتخاب شود.

---

## بخش ۹ — گزارش‌ها و جست‌وجوی ترکیبی

- فیلتر فقط وقتی «فعال» معرفی می‌شود که Backend و Query واقعی از آن پشتیبانی کنند.
- تاریخ Task، Reminder و Follow-up Record باید در فیلترها از یکدیگر تفکیک شوند.
- داده‌های legacy مربوط به Next Follow-up یا `followUpEnabled` نباید قابلیت فعال یا منبع زمان‌بندی تلقی شوند.
- گزارش‌ها باید بر داده واقعی و قابل ردیابی متکی باشند؛ داده فرضی یا مقادیر مشتق‌شده نامعتبر نباید به‌عنوان تاریخچه واقعی نمایش داده شوند.

---

## بخش ۱۰ — Backup/Restore و Release

- Backup/Restore باید روابط معتبر، شناسه‌ها و تاریخچه را تا حد قرارداد داده حفظ کند.
- Next Follow-up و `followUpEnabled` نباید در Restore به قابلیت زنده تبدیل شوند؛ داده legacy در صورت وجود باید طبق سیاست سازگاری و مهاجرت مصوب مدیریت شود، نه اینکه رفتار منسوخ دوباره فعال شود.
- Release gate و امضا دو کنترل مستقل‌اند.
- وضعیت انتشار تا عبور از تمام گیت‌های لازم همچنان **BLOCKED — RELEASE: NO-GO** است.

---

## بخش ۱۱ — شواهد، GitHub و وضعیت‌ها

- هر ادعای PASS باید به SHA کامل، Run مشخص و Evidence قابل بررسی متصل باشد.
- وضعیت‌های مجاز گزارش‌دهی عبارت‌اند از PASS، FAIL، IN PROGRESS، BLOCKED و NOT VERIFIED.
- وجود فایل، موفقیت Build یا نصب APK به‌تنهایی اثبات پذیرش رفتاری نیست.
- هیچ نتیجه‌ای نباید بدون اجرای واقعی، شاهد قابل ممیزی یا خروجی معتبر به‌عنوان PASS گزارش شود.
- شاخه `main`، انتشار و APK نهایی بدون مجوز صریح و عبور از گیت‌های مربوط نباید تغییر کنند.

---

## بخش ۱۲ — معیارهای پذیرش نهایی

این گیت‌ها معیارهای پذیرش قرارداد محصول‌اند و قبولی مستنداتی به‌تنهایی به‌معنای عبور از آزمون اجرایی نیست.

### Gate 1: Data Model

- Next Follow-up و `followUpEnabled` از schema، models، DTOs، UI، queries، APIs، tests و docs پاکسازی کامل شده باشند.
- Follow-up view فقط از وجود رکورد واقعی در `follow_up_records` تغذیه شود.
- Follow-up Record نمایانگر اقدام واقعی گذشته باشد و مقدار واقعی `completedAt` داشته باشد.
- ثبت زمان یا رکورد ساختگی هنگام باز شدن فرم، Swipe یا تغییر وضعیت نامرتبط ممنوع است.

### Gate 2: Task Swipe

- Dropdownهای چپ و راست در Task List قابل تنظیم باشند و گزینه «ثبت پیگیری» را داشته باشند.
- انتخاب «ثبت پیگیری» فقط فرم را باز کند.
- رکورد تنها پس از ثبت صریح اقدام واقعی ایجاد شود.

### Gate 3: Calendar Swipe

- تنظیمات مستقل Swipe تقویم وجود داشته باشند.
- گزینه‌ها شامل ویرایش، حذف و انتقال به تقویم گوشی باشند.

### Gate 4: Device Calendar Sync

- همگام‌سازی Idempotent، Isolated و Failure-safe باشد.
- عملیات CREATE، NO-OP UPDATE، UPDATE و DELETE در Provider واقعی مستقلاً بررسی شوند.
- All-day نباید به رویداد ساعت‌دار `00:00` تبدیل شود.
- نبود تقویم قابل‌نوشتن یا مجوز لازم باید آزمون را BLOCKED کند، نه PASS.

### Gate 5: Typography + PDF

- Vazirmatn داخل APK بسته‌بندی شده باشد و یکپارچگی فونت در UI تأیید شود.
- نبود فونت در Automated Packaging Audit موجب شکست CI شود.
- PDF دارای فونت Embed‌شده و حروف فارسی متصل و صحیح باشد.

### تصمیم انتشار

تا PASS شدن تمام گیت‌های لازم با شواهد مستقل: **BLOCKED — RELEASE: NO-GO**.

---

## بخش ۱۳ — فهرست تصمیم‌های قطعی محصول

- **فونت:** فقط Vazirmatn؛ System Default ممنوع.
- **پیگیری:** Follow-up Record فقط اقدام واقعی گذشته است و باید `completedAt` واقعی داشته باشد.
- **Next Follow-up و followUpEnabled:** قابلیت فعال محصول نیستند و باید از همه لایه‌های مشمول قرارداد پاکسازی شوند.
- **Swipe Task List:** قابل تنظیم، با گزینه «ثبت پیگیری» که فقط فرم را باز می‌کند.
- **Swipe Calendar:** قابل تنظیم و مستقل؛ گزینه‌های ویرایش، حذف و انتقال به تقویم گوشی.
- **حذف:** Soft Delete به Trash به‌علاوه Hard Delete متناسب با چرخه عمر.
- **Home:** شش بخش ثابت با ترتیب مشخص.
- **تقویم:** دو مسیر مستقل؛ Device Calendar اختیاری، ایزوله، Idempotent و Failure-safe.
- **Release:** مسدود تا عبور مستقل از همه گیت‌های پذیرش.

---

## بخش ۱۴ — مرجعیت و روش استفاده

در تعارض میان اسناد، این نسخه همساز با قرارداد قطعی مبناست. هر تغییر در قرارداد محصول فقط با تصمیم صریح مالک محصول مجاز است.

این سند قرارداد و معیار پذیرش را تعریف می‌کند؛ ثبت آن به‌تنهایی اثبات نمی‌کند که کد، Schema، آزمون‌ها یا زیرساخت اجرایی با تمام الزامات همسو شده‌اند. هر الزام اجرایی باید جداگانه پیاده‌سازی و با شواهد واقعی تأیید شود.

---

## وضعیت نهایی

**BLOCKED — RELEASE: NO-GO**

انتشار تا زمان عبور مستقل از تمام گیت‌های لازم محصول، CI، پذیرش داده، تقویم دستگاه و دستگاه واقعی مسدود باقی می‌ماند.


## Wave 7-61 Track A/B — Typography and Task completion lifecycle

- The only application font is the bundled `Vazirmatn` family. Settings expose text size only; no font-family picker or active font-family preference is supported. Light and dark application themes use the same family. PDF report and Work Agenda output use the bundled Vazirmatn Regular/Bold assets through the shared renderer.
- Legacy backup `fontFamily` values are ignored during portable-settings merge/decode. New portable settings do not export a font-family selection; restoring a legacy value cannot change the enforced font.
- Task completion time is the nullable Task-level `completedAt` ISO-8601 value. The first transition to completed records the timestamp; repeated completion preserves it; explicit reopen clears it; the next completion records a new timestamp.
- Title, description/Task Note, priority, category and other editor metadata updates change `updatedAt` but do not own or mutate completion state or `completedAt`. Completion is performed only through the explicit completion lifecycle action.
- Existing SQL schema version remains **7**: `tasks.completed_at` is already part of the canonical v7 schema and the idempotent installer adds the nullable column to older task tables when absent. No schema-version increment or destructive migration is needed for this change. Existing `follow_up_enabled` and `follow_up_date` columns remain intact; no follow-up rows are synthesized, dropped or rewritten by completion/metadata operations.
- Single, bulk and swipe completion preserve the existing `followUps` history. TaskStore persists `completedAt` in both the canonical SQL column and the task JSON envelope and continues to write follow-up relations transactionally.
- The completed swipe action is a one-way completion action; reopening remains an explicit Task detail lifecycle action.

Release remains **BLOCKED — RELEASE: NO-GO** pending all independent product and device acceptance gates.
