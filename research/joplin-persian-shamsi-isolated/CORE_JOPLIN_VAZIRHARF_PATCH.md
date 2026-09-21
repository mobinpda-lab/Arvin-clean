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
