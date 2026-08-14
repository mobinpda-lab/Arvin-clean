# Arvin — Project Status

## وضعیت مرجع
- Branch: `feat/follow-up-history-v1.3`
- آخرین Commit ثبت‌شده در این Branch: `3e9ddd4` (`fix: enable core library desugaring for release APK`)
- این سند باید با هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## وضعیت واقعی CI — 2026-08-14
آخرین Release Job بررسی‌شده: `94698620530` / Run `31778393323`.
- Checkout: 🟢 روی Commit `6d8be750`.
- Flutter 3.47.0: 🟢.
- `flutter pub get`: 🟢؛ 58 dependency resolve شد.
- Gradle `assembleRelease`: شروع شد 🟢 و حدود 211 ثانیه اجرا شد.
- خطای قبلی Android V1: دیگر رخ نداد 🟢.
- خطای فعلی: `:app:checkReleaseAarMetadata` به‌دلیل نیاز `flutter_local_notifications 22.3.0` به Core Library Desugaring 🔴.
- نکته مهم: فایل فعلی `android/app/build.gradle.kts` در Branch مرجع همین حالا `isCoreLibraryDesugaringEnabled = true` و `desugar_jdk_libs:2.1.5` را دارد؛ اما Run فوق روی Commit قدیمی `6d8be750` اجرا شده و بنابراین این اصلاح را در build ندیده است.
- APK هنوز تولید نشده است.

## معماری فعلی
- Flutter Android application.
- مدل اصلی `Task` حفظ شده و تاریخچه پیگیری با `FollowUp` در کنار آن توسعه داده شده است.
- `TaskStore` برای ذخیره/بازیابی `followUps` اصلاح شده است.
- Calendar و تست‌های مرتبط در حال پایدارسازی هستند.

## Follow-up History
هدف این قابلیت، نمایش آخرین پیگیری و ساعت آن و نگهداری تاریخچه پیگیری‌هاست؛ این بخش باید بدون از بین بردن داده‌های قبلی `followUpDate` توسعه یابد.

## Calendar
- تست‌های Calendar به‌صورت deterministic شده‌اند.
- گزارش‌های قبلی CI دو تست Calendar را با مشکل layout/overflow نشان داده‌اند؛ قبل از Release باید دوباره تأیید شوند.

## Android / Release
- خطای Android V1 از مسیر Release فعلی عبور کرده است.
- Android V2 اکنون به مرحله واقعی Gradle رسیده است.
- Core Library Desugaring در فایل فعلی Android فعال شده و آماده Run جدید است.
- Release pipeline باید روی آخرین Commit Branch اجرا شود تا اصلاح Desugaring واقعاً validate شود.
- تا سبز شدن Release Build، نباید موفقیت APK اعلام شود.

## CI معیار پذیرش
1. `flutter analyze` سبز
2. تمام `flutter test` سبز
3. Android dependency/audit سبز
4. `flutter build apk --release` سبز
5. APK در Artifact موجود باشد
6. نام APK شامل نسخه باشد

## Font System — برنامه بعدی
- فونت اصلی پیش‌فرض: **IranSans**.
- امکان تغییر فونت از Settings.
- انتخاب فونت باید persistent باشد.
- امکان بازگشت به IranSans وجود داشته باشد.
- اعمال فونت روی کل UI، RTL، فارسی و اعداد باید تست شود.
- فایل فونت کاربر باید قبل از ثبت asset نهایی در Repository بررسی شود.

## قانون توسعه
توسعه می‌تواند موازی باشد، اما فقط یک Branch/Commit مرجع برای Release باید مبنای ساخت APK باشد تا Workflowها روی نسخه‌های متفاوت اجرا نشوند.

## گزارش تغییرات اخیر
- `3e9ddd4` — فعال‌سازی Core Library Desugaring برای Release APK.
- `6d8be750` — مستندسازی وضعیت پروژه و معیارهای Release.
- `94698620530` — تأیید شد که Release روی `6d8be750` اجرا شده و هنوز اصلاح `3e9ddd4` را مصرف نکرده است.

هر تغییر مهم باید با Commit SHA و نتیجه CI در همین سند ثبت شود؛ ادعای «انجام شد» فقط زمانی مجاز است که تغییر در GitHub قابل مشاهده باشد.
