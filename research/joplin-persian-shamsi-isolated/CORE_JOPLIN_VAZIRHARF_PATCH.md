# Joplin Android — مسیر هسته‌ای VazirHarf

## تصمیم اجرایی

کنترل فونت فعلی افزونه **نسخه نهایی نیست** و نباید معیار پذیرش محسوب شود.

ممیزی سورس رسمی Joplin نشان داد:

1. `packages/app-mobile/components/NoteEditor/NoteEditor.tsx` مقدار `style.editor.fontFamily` را از `Setting` می‌خواند و با `editorFont()` به `fontFamily` واقعی ویرایشگر تبدیل می‌کند.
2. `packages/app-mobile/components/global-style.ts` نگاشت واقعی شناسه فونت را در `editorFont()` دارد.
3. `packages/lib/models/settings/builtInMetadata.ts` فهرست فونت موبایل را در خود تعریف می‌کند. در Android فعلی گزینه‌ها فقط `Default` و `Monospace` هستند.
4. API رسمی افزونه امکان ساخت setting/command و افزودن CodeMirror extension را می‌دهد، اما API عمومی برای افزودن یک گزینه به همان built-in setting `style.editor.fontFamily` ارائه نمی‌کند.

بنابراین راه‌حل فعلی افزونه که یک setting جداگانه می‌سازد، حتی اگر فونت را در CodeMirror اعمال کند، **معادل افزودن VazirHarf به فهرست واقعی فونت Joplin نیست**.

## تغییر هسته مورد نیاز

در یک شاخه مستقل از سورس Joplin Mobile باید:

### 1. شناسه فونت
در `packages/lib/models/Setting.ts` یک مقدار جدید برای VazirHarf اضافه شود؛ مثلاً بعد از `FONT_MONOSPACE`:

`FONT_VAZIRHARF`

### 2. فهرست واقعی Android
در `packages/lib/models/settings/builtInMetadata.ts` در بخش `style.editor.fontFamily` و شاخه Android، گزینه VazirHarf مستقیماً به همان فهرست اضافه شود:

- Default
- Monospace
- VazirHarf

### 3. نگاشت واقعی ویرایشگر
در `packages/app-mobile/components/global-style.ts` در `editorFont()`، شناسه جدید به نام خانواده واقعی فونت نگاشت شود:

`FONT_VAZIRHARF -> VazirHarf`

این همان تابعی است که `NoteEditor.tsx` برای ساخت `fontFamily` ویرایشگر استفاده می‌کند.

### 4. بسته Android
فایل فونت در بسته Android قرار گیرد. مسیر نهایی باید با روش بارگذاری فونت در Joplin/React Native سازگار باشد و نام خانواده `VazirHarf` در Android واقعاً resolve شود.

**نکته:** فایل متغیر `Vazirharf[wght].ttf` باید قبل از پذیرش نهایی روی Android بررسی شود؛ اگر مسیر React Native/Joplin با فونت متغیر سازگار نبود، از فایل ایستای مناسب همان خانواده استفاده شود، نه اینکه فقط CSS به بسته افزوده شود.

### 5. آزمون هسته
پس از build:

- Android → Settings → Editor → Editor font
- مشاهده `VazirHarf` در همان فهرست داخلی Joplin
- انتخاب VazirHarf
- باز کردن یادداشت
- ورود به حالت ویرایش
- تایپ متن فارسی
- تأیید بصری خانواده فونت در متن تایپ‌شده

## معیار وضعیت

تا زمانی که این آزمون روی APK ساخته‌شده از همین تغییرات انجام نشده است:

**وضعیت = حل نشده / در حال اجرا**

هیچ setting جداگانه افزونه‌ای، دکمه toolbar یا CSS-only به‌عنوان اثبات پذیرش این قابلیت پذیرفته نمی‌شود.

## مرز مخزن Arvin

این فایل فقط مشخصات/ردپای تحقیق است. سورس AGPL Joplin نباید در runtime آروین کپی یا وارد شود. برای اجرای واقعی تغییر هسته، باید یک fork/branch مستقل از Joplin ساخته شود و APK آن ساخته و روی Android آزمایش شود.


## ممیزی مجدد بر مبنای Joplin v3.7.18 — ۲۱ شهریور ۱۴۰۵

نسخه رسمی فعلی که بررسی شد **v3.7.18** است؛ بنابراین طراحی تغییر باید بر این پایه انجام شود، نه نسخه قدیمی 3.7.8. انتشار رسمی v3.7.18 در 11 سپتامبر 2026 ثبت شده است.

### یافته دقیق فونت

در v3.7.18، بخش `style.editor.fontFamily` در Android همچنان فقط این دو گزینه را دارد:

- `Default`
- `Monospace`

و در `packages/lib/models/Setting.ts` شناسه‌های فعلی فونت شامل `FONT_DEFAULT=0`، `FONT_MENLO=1`، `FONT_COURIER_NEW=2`، `FONT_AVENIR=3` و `FONT_MONOSPACE=4` هستند.

همچنین `packages/app-mobile/components/global-style.ts` در تابع `editorFont()` همین نگاشت را به خانواده واقعی فونت تبدیل می‌کند. بنابراین افزودن VazirHarf باید در **هر دو نقطه** انجام شود تا گزینه تنظیمات و اجرای واقعی ویرایشگر یکسان باشند.

### مسیر تقویم جلالی

در هسته Joplin، تنظیم `dateFormat` از مسیر `packages/lib/time.ts` / `packages/utils/time.ts` به `formatMsToLocal()` می‌رسد. این مسیر نقطه مناسبی برای افزودن **نمایش جلالی** است، مشروط بر اینکه مقدار زمان ذخیره‌شده، timestamp، شناسه یادداشت و داده‌های sync دست‌نخورده بمانند.

قاعده قطعی:

**Gregorian timestamp داخل داده = بدون تغییر**

**نمایش تاریخ در رابط کاربری = قابل تبدیل به جلالی**

در نتیجه تغییر تقویم نباید serializer، مدل Note، ساختار sync یا زمان ذخیره‌شده را تغییر دهد.

### وضعیت اجرایی فعلی

- ممیزی نسخه جدید رسمی: انجام شد.
- محل دقیق افزودن VazirHarf: مشخص شد.
- محل مناسب تغییر نمایش تاریخ: مشخص شد.
- تغییر واقعی سورس Joplin: هنوز انجام نشده.
- APK سفارشی: هنوز ساخته نشده.
- آزمون واقعی Android: هنوز انجام نشده.
- آزمون sync: هنوز انجام نشده.

**وضعیت نهایی: در حال اجرا — هنوز حل‌شده محسوب نمی‌شود.**
