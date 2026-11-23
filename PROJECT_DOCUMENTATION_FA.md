# مستند فنی و سوابق پروژه آروین (Arvin)

## 1. هدف این سند

این فایل مرجع اصلی برای ادامه توسعه، رفع خطا و ارتقای نسخه نرم‌افزار آروین است. در شروع هر ارتقای آینده، این سند را همراه با وضعیت فعلی مخزن مطالعه کنید و سپس کد فعلی `main` را با این مستند تطبیق دهید.

مخزن: `mobinpda-lab/Arvin-clean`
شاخه اصلی: `main`
پلتفرم هدف فعلی: Android
فناوری: Flutter / Dart
نام برنامه: Arvin / آروین
نسخه ثبت‌شده در `pubspec.yaml`: `1.0.0+1`

---

## 2. ایده و کارکرد اصلی برنامه

آروین یک نرم‌افزار مدیریت کارها و پیگیری‌ها برای اندروید است. داده اصلی برنامه شامل فهرستی از `ArvinTask`ها است.

هر کار دارای این فیلدهاست:

- `id`: شناسه یکتا
- `title`: عنوان
- `description`: توضیحات
- `followUpDate`: تاریخ پیگیری، اختیاری
- `tags`: فهرست برچسب‌ها
- `archived`: وضعیت بایگانی
- `trashed`: وضعیت سطل زباله
- `completed`: وضعیت انجام‌شدن

رابط کاربری راست‌به‌چپ است و از Material 3 استفاده می‌کند.

---

## 3. ذخیره‌سازی فعلی اطلاعات

در `lib/main.dart` کلاس `TaskRepository` مسئول ذخیره اطلاعات است.

کل فهرست کارها در `SharedPreferences` با کلید زیر ذخیره می‌شود:

`arvin.tasks`

ساختار ذخیره‌سازی فعلی JSON است و هر `ArvinTask` با `toJson()` به Map تبدیل می‌شود. بازیابی با `ArvinTask.fromJson()` انجام می‌شود.

بنابراین هر قابلیت Backup/Restore باید با همین ساختار سازگار باشد، مگر اینکه در یک نسخه آینده عمداً migration طراحی شود.

وابستگی فعلی:

- `shared_preferences: ^2.5.3`

---

## 4. معماری Backup / Restore

هدف مورد توافق پروژه:

1. کاربر بتواند یک پوشه روی خود گوشی انتخاب کند.
2. برنامه در زمان انتخاب‌شده توسط کاربر Backup بگیرد.
3. Backup داخل همان پوشه ذخیره شود.
4. فایل Backup بتواند به گوشی دیگر منتقل شود.
5. روی گوشی دیگر همان فایل قابل Restore باشد.
6. Backup به مسیر خصوصی یا غیرقابل‌انتقال برنامه وابسته نباشد.

برای انتخاب پوشه و کار با فایل از Android Storage Access Framework استفاده شده است.

وابستگی:

`saf: ^2.1.0`

پکیج `file_picker` که در مراحل قبلی باعث خطای Android/GeneratedPluginRegistrant شده بود، از وابستگی نهایی Backup حذف شد.

---

## 5. خطای مهم قبلی file_picker

یکی از خطاهای اصلی پروژه این بود:

`cannot find symbol com.mr.flutter.plugin.filepicker.FilePickerPlugin`

این خطا در `GeneratedPluginRegistrant.java` ظاهر می‌شد و باعث شکست:

`flutter build apk --release`

شد.

هشدار KGP نیز برای بعضی پکیج‌ها وجود داشت، ولی خطای مسدودکننده اصلی `FilePickerPlugin` بود.

راه‌حل معماری Backup این شد که به‌جای وابستگی به `file_picker` از SAF استفاده شود.

---

## 6. وضعیت فعلی backup_service.dart

فایل اصلی سرویس Backup:

`lib/backup_service.dart`

این سرویس اکنون ساختار Backup را به‌صورت نسخه‌دار طراحی می‌کند و برای Restore اعتبارسنجی انجام می‌دهد.

نام فایل Backup باید با تاریخ هجری شمسی ساخته شود.

فرمت مورد توافق:

`Arvin_Backup_1405-05-21_09-13.json`

یعنی:

`Arvin_Backup_<سال شمسی>-<ماه>-<روز>_<ساعت>-<دقیقه>.json`

هدف این فرمت این است که فایل برای کاربر قابل تشخیص، مرتب و قابل انتقال باشد.

نکته مهم: تاریخ داخل نام فایل شمسی است، ولی زمان از `DateTime` دستگاه گرفته می‌شود.

---

## 7. فرمت منطقی Backup

Backup باید نسخه‌دار باشد تا در آینده امکان migration وجود داشته باشد.

ساختار مفهومی:

```json
{
  "formatVersion": 1,
  "app": "arvin",
  "createdAt": "2026-08-12T09:13:00.000",
  "tasks": [
    {
      "id": "...",
      "title": "...",
      "description": "...",
      "followUpDate": "...",
      "tags": [],
      "archived": false,
      "trashed": false,
      "completed": false
    }
  ]
}
```

در Restore نباید فایل نامعتبر مستقیماً روی اطلاعات فعلی نوشته شود. ابتدا ساختار، نسخه و `tasks` بررسی شود و فقط در صورت معتبر بودن Restore انجام شود.

---

## 8. تست و خطای تاریخ شمسی

Commitی با عنوان:

`test: verify Persian-date backup filenames`

برای بررسی نام فایل Backup ساخته شد.

این تست در یکی از اجراهای CI قرمز شد، اما علت واقعی خطا تست نبود؛ Analyzer خطای زیر را گزارش کرد:

`unnecessary_string_escapes`

در:

`lib/backup_service.dart:73:43`

متن خطا:

`Unnecessary escape in string literal. Remove the '\\' escape`

علت این بود که در رشته نام فایل، `_` به‌صورت `\\_` نوشته شده بود، درحالی‌که در Dart نیازی به Escape کردن `_` وجود ندارد.

اصلاح انجام‌شده:

`return 'Arvin_Backup_$year-$month-$day_$hour-$minute.json';`

Commit اصلاح:

`689167ad — fix: remove unnecessary escape from backup filename`

---

## 9. CI / GitHub Actions

Workflow اصلی در:

`.github/workflows/build.yml`

قرار دارد.

نام Workflow:

`Arvin Build`

روی Push به `main` و `master` و Pull Request اجرا می‌شود و همچنین `workflow_dispatch` دارد.

مراحل اصلی Workflow:

1. checkout
2. نصب Flutter stable
3. `flutter create --platforms=android --project-name arvin .`
4. `flutter pub get`
5. `flutter analyze`
6. `flutter test`
7. `flutter build apk --release`
8. بررسی وجود APK
9. Upload artifact با نام `arvin-release-apk`

در نتیجه، هر تغییر مهم باید حداقل از Analyze، Test و Build عبور کند.

---

## 10. خطاهای مهمی که در مسیر پروژه رخ داده‌اند

### خطای A — FilePickerPlugin

در Build Release:

`cannot find symbol ... FilePickerPlugin`

راه‌حل: حذف وابستگی مشکل‌دار `file_picker` از مسیر Backup و استفاده از SAF.

### خطای B — nullable directory picker

خطا:

`A value of type 'Future<String?>' can't be returned from the method 'chooseDirectory' because it has a return type of 'Future<String>'`

راه‌حل: متد انتخاب پوشه باید nullable باشد:

`Future<String?>`

زیرا کاربر ممکن است انتخاب پوشه را لغو کند.

### خطای C — رشته نام فایل Backup

خطا:

`unnecessary_string_escapes`

راه‌حل: حذف Escape غیرضروری قبل از `_`.

### خطاهای قبلی main.dart

در چند مرحله Analyze خطاهایی مانند این‌ها رخ داد:

- `Iterable<Widget>` در جایی که `List<Widget>` لازم بود
- اجرای `.toList()` روی `Padding`
- `Too many positional arguments`
- `Expected to find ')'`

این خطاها مربوط به تغییرات اشتباه در `main.dart` بودند و باید هنگام ارتقا از ویرایش‌های گسترده و فشرده‌سازی کد UI بدون تست جلوگیری شود.

---

## 11. وضعیت UI و TaskRepository فعلی

`main.dart` شامل:

- `ArvinApp`
- `ArvinTask`
- `TaskRepository`
- `HomePage`
- منطق افزودن و ویرایش کار
- فیلترهای فعال، بایگانی و سطل زباله
- جستجو
- وضعیت تکمیل‌شدن
- ذخیره در SharedPreferences

در زمان اضافه کردن Backup نباید ساختار `ArvinTask` بدون migration تغییر کند.

---

## 12. وضعیت فعلی Backup از نظر محصول

بخش‌هایی که طراحی/پیاده‌سازی شده‌اند:

- انتخاب پوشه با SAF
- خواندن/نوشتن فایل Backup
- فرمت JSON نسخه‌دار
- نام فایل با تاریخ شمسی
- اعتبارسنجی اولیه Backup

بخش‌هایی که هنوز باید تکمیل و به UI متصل شوند:

- اتصال Backup واقعی به `TaskRepository`
- گرفتن Snapshot از تمام `tasks`
- Restore واقعی به `SharedPreferences`
- UI انتخاب پوشه Backup
- ذخیره مسیر/URI انتخاب‌شده
- دکمه Backup دستی
- دکمه Restore
- نمایش نتیجه موفق/ناموفق
- تأیید کاربر قبل از جایگزینی اطلاعات
- زمان‌بندی دوره‌ای بر اساس زمان تعیین‌شده توسط کاربر
- مدیریت Backupهای قدیمی
- جلوگیری از overwrite ناخواسته
- تست انتقال Backup به گوشی دیگر

---

## 13. نیاز محصول برای Backup دوره‌ای

کاربر باید بتواند حداقل این تنظیمات را تعیین کند:

- فعال/غیرفعال بودن Backup خودکار
- پوشه Backup
- زمان Backup
- احتمالاً تعداد Backupهای نگهداری‌شده

نمونه رفتار موردنظر:

کاربر پوشه‌ای را انتخاب می‌کند و زمان را مثلاً 23:30 تعیین می‌کند. برنامه در زمان مقرر یک فایل مانند:

`Arvin_Backup_1405-05-21_23-30.json`

ایجاد می‌کند.

Backup باید در گوشی دیگر نیز قابل انتخاب و Restore باشد.

---

## 14. نکته مهم درباره Android

چون برنامه از SAF استفاده می‌کند، مسیر واقعی فایل نباید به یک path ثابت مانند `/storage/emulated/0/...` وابسته شود.

بهتر است URI مجوزدار پوشه ذخیره شود و برنامه از همان URI برای ساخت فایل استفاده کند.

اگر برنامه بعداً نیاز به اجرای Backup در زمان مشخص حتی هنگام بسته بودن برنامه داشته باشد، باید برای Android یک راهکار مناسب زمان‌بندی مانند WorkManager/Alarm/Foreground constraints بررسی شود. این بخش هنوز باید با توجه به نسخه Android هدف طراحی شود.

---

## 15. سیاست توسعه پروژه

برای جلوگیری از تکرار مشکلات قبلی:

1. هر تغییر کوچک و مشخص باشد.
2. بعد از هر مرحله `flutter analyze` اجرا شود.
3. سپس `flutter test` اجرا شود.
4. سپس `flutter build apk --release` اجرا شود.
5. فقط نسخه‌ای که CI واقعاً سبز کرده مبنای مرحله بعد باشد.
6. هنگام خطا، ابتدا متن دقیق خطا و Commit مربوط به آن مشخص شود.
7. از حذف تست فقط به‌دلیل قرمز شدن آن خودداری شود؛ ابتدا علت واقعی شکست مشخص شود.
8. تغییرات UI بزرگ به چند Commit کوچک تقسیم شوند.
9. Backup format با `formatVersion` همیشه قابل مهاجرت نگه داشته شود.

---

## 16. تاریخچه مهم توسعه بر اساس سوابق ثبت‌شده

### مرحله Android / Build

- پروژه Flutter برای Android Build آماده شد.
- در یک مرحله Build Release با خطای `FilePickerPlugin` متوقف شد.
- وابستگی Backup از `file_picker` به SAF منتقل شد.
- Build بعدی در یک مرحله موفق شد و APK با حجم حدود 49.9MB ساخته شد.

### مرحله Backup / Restore

- نیاز محصول Backup دوره‌ای در پوشه انتخابی کاربر مشخص شد.
- شرط انتقال Backup به گوشی دیگر و Restore روی گوشی جدید تعیین شد.
- SAF به‌عنوان روش اصلی انتخاب پوشه و فایل انتخاب شد.
- `backup_service.dart` ایجاد/تکمیل شد.
- فرمت Backup نسخه‌دار شد.
- نام فایل به تاریخ هجری شمسی تغییر کرد.
- تست نام‌گذاری Backup اضافه شد.
- خطای Escape اضافی در نام فایل شناسایی و اصلاح شد.

### Commitهای شناخته‌شده اخیر

- `b9896d6` — `Fix backup directory picker nullable return type`
- `35243232` — `feat: add versioned Persian-date backup format`
- `89b2cb5` — `test: verify Persian-date backup filenames`
- `689167ad` — `fix: remove unnecessary escape from backup filename`
- `251ffc4` — `ci: run build for backup filename fix`

توجه: بعضی از این Commitها در مسیر توسعه قرمز بوده‌اند و نباید صرفاً با عنوان Commit به‌عنوان نسخه سالم تلقی شوند. وضعیت واقعی CI همیشه ملاک است.

---

## 17. قانون مهم برای ارتقای نسخه آینده

وقتی کاربر گفت «نسخه آروین را ارتقا بده» یا نسخه جدید خواست، ابتدا این مراحل انجام شود:

1. همین فایل `PROJECT_DOCUMENTATION_FA.md` مطالعه شود.
2. وضعیت واقعی `main` بررسی شود.
3. آخرین Commit سبز مشخص شود.
4. `pubspec.yaml`، `main.dart` و `backup_service.dart` بررسی شوند.
5. قبل از تغییر ساختار داده، migration strategy مشخص شود.
6. Backup/Restore نباید با تغییر نسخه باعث از بین رفتن اطلاعات کاربر شود.
7. تغییرات جدید باید تا حد امکان backward-compatible باشند.
8. بعد از هر تغییر، CI بررسی شود.

---

## 18. اولویت‌های پیشنهادی توسعه بعدی

اولویت 1 — تکمیل Backup واقعی:

- اتصال `BackupService` به `TaskRepository`
- export تمام tasks
- import و validation
- Restore امن

اولویت 2 — UI:

- صفحه تنظیمات Backup
- انتخاب پوشه
- زمان Backup
- Backup دستی
- Restore دستی

اولویت 3 — Backup دوره‌ای:

- زمان‌بندی Android
- اجرای مطمئن در پس‌زمینه
- جلوگیری از اجرای چند Backup همزمان

اولویت 4 — مدیریت فایل‌ها:

- فهرست Backupها
- حذف Backup قدیمی
- نگهداری تعداد مشخص Backup

اولویت 5 — تست مهاجرت:

- ساخت Backup روی گوشی A
- انتقال فایل
- نصب آروین روی گوشی B
- انتخاب فایل
- Restore
- مقایسه کامل tasks قبل و بعد

---

## 19. معیار موفقیت نهایی Backup

یک قابلیت Backup زمانی کامل محسوب می‌شود که:

- کاربر پوشه را انتخاب کند.
- برنامه بتواند بدون دسترسی filesystem خام به آن پوشه فایل ایجاد کند.
- نام فایل تاریخ شمسی داشته باشد.
- فایل شامل همه اطلاعات کارها باشد.
- فایل نسخه‌دار باشد.
- فایل به گوشی دیگر منتقل شود.
- گوشی دوم بتواند فایل را انتخاب کند.
- اطلاعات قبل از Restore اعتبارسنجی شوند.
- Restore بدون خراب کردن ساختار داده انجام شود.
- بعد از Restore، تعداد و محتوای کارها با نسخه Backup مطابقت داشته باشد.
- Backup دوره‌ای طبق زمان کاربر اجرا شود.

---

## 20. آخرین وضعیت مرجع

در زمان ایجاد این سند، `pubspec.yaml` شامل `shared_preferences` و `saf` است و نسخه برنامه `1.0.0+1` ثبت شده است. fileciteturn343file0

`main.dart` هنوز منبع اصلی مدل `ArvinTask` و ذخیره‌سازی `TaskRepository` است. fileciteturn345file0

`backup_service.dart` منطق نام‌گذاری Backup با تاریخ شمسی را دارد و فرمت نام فایل به شکل `Arvin_Backup_YYYY-MM-DD_HH-MM.json` است. fileciteturn344file0

Workflow اصلی پروژه `Arvin Build` است و Analyze، Test و Release APK را اجرا می‌کند. fileciteturn342file0

---

## 21. دستورالعمل کوتاه برای دستیار توسعه آینده

اگر این فایل در یک گفت‌وگوی آینده به دستیار داده شد، فرض کن:

> «این پروژه همان Arvin-clean است. اطلاعات کاربران در SharedPreferences با کلید `arvin.tasks` نگهداری می‌شود. مدل اصلی `ArvinTask` است. Backup باید با SAF انجام شود، فایل قابل انتقال بین گوشی‌ها باشد، فرمت نسخه‌دار داشته باشد و نام فایل تاریخ هجری شمسی داشته باشد. قبل از هر ارتقا آخرین Commit سبز و CI را بررسی کن. هیچ داده کاربر نباید با ارتقای نسخه از بین برود. تغییرات را مرحله‌ای انجام بده و بعد از هر مرحله Analyze/Test/Build را بررسی کن.»

این متن باید نقطه شروع بررسی در ارتقاهای آینده باشد.
