# Arvin — Project Status

## مرجع فعلی
- Branch توسعه/مرجع: `feat/follow-up-history-v1.3`
- آخرین CI release fix: `d4776ac7c70380ee65f60893d41e5a7cb3d20b62`
- Flutter CI target: `3.47.0` stable
- این سند باید همراه هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## وضعیت CI
CI اکنون به چند مسیر موازی تقسیم شده است تا شکست یک حوزه، وضعیت حوزه‌های دیگر را مبهم نکند:

1. `Arvin Feature Validation` — analyze و مجموعه تست‌ها.
2. `Arvin FollowUp Validation` — مدل، TaskStore و UI تاریخچه FollowUp.
3. `Arvin Calendar Validation` — تست‌های Calendar.
4. `Arvin Backup Validation` — تست Backup/Restore.
5. `Arvin Release Validation` — Android audit، analyze، test، ساخت APK و upload artifact.

### تغییر اخیر CI
- Run `94710722878` روی commit `80e699db` نشان داد `flutter pub get` کاملاً موفق است و `saf 2.1.0` نیز resolve می‌شود؛ شکست فقط به‌خاطر hard-code اشتباه مسیر `MainActivity` بود.
- مسیر واقعی `MainActivity.kt` در پروژه: `android/app/src/main/kotlin/com/mobinpda/lab/arvin/MainActivity.kt`.
- Commit `d4776ac7c70380ee65f60893d41e5a7cb3d20b62` audit را به کشف پویا و مستقل از package path تغییر داد.

## Android / Release
- Android V2 با `FlutterActivity` استفاده می‌شود.
- Core Library Desugaring در `android/app/build.gradle.kts` فعال است.
- `desugar_jdk_libs:2.1.5` تعریف شده است.
- Release فقط وقتی موفق اعلام می‌شود که `flutter build apk --release` واقعاً سبز شود و APK به Artifact آپلود شده باشد.
- خطای قبلی Android V1 نباید دوباره به‌عنوان هدف اصلاح تکرار شود؛ audit اکنون آن را صریحاً بررسی می‌کند.

## قابلیت‌های فعلی
### Task Management
- ایجاد/ویرایش Task
- توضیحات و Tag
- تاریخ پیگیری
- تکمیل، بایگانی و Trash
- Restore و حذف دائمی
- جست‌وجو و فیلتر
- آمار Taskها

### FollowUp
- مدل مستقل `FollowUp`
- نگهداری تاریخچه در `TaskStore`
- migration از `followUpDate` قدیمی
- تست‌های مدل و Store
- UI تاریخچه در حال تکمیل است.

### Calendar
- صفحه Calendar و تست‌های deterministic موجود است.
- اتصال کامل Calendar به FollowUp/Reminder هنوز در فاز تثبیت است.

### Backup
- انتخاب پوشه Backup
- ایجاد Backup
- Restore
- Backup اضطراری قبل از Restore

## فازهای عملیاتی بعدی
1. **Release/CI:** سبز کردن APK واقعی و Artifact.
2. **FollowUp UI:** آخرین پیگیری، ساعت، نتیجه، پیگیری بعدی و تاریخچه کامل.
3. **Calendar + Reminder:** اتصال کامل به FollowUp و اعلان‌ها.
4. **Font System:** IranSansX پیش‌فرض + امکان تغییر فونت در Settings + persistence.
5. **Release Candidate:** تست کامل، APK نسخه‌دار، checksum، Artifact و مستند Release.

## قانون توسعه موازی
توسعه حوزه‌ها می‌تواند موازی باشد، اما APK Release فقط از Branch مرجع ساخته می‌شود. هر تغییر مهم باید با **کد + تست + CI + مستندات + Commit SHA قابل مشاهده** ثبت شود.
