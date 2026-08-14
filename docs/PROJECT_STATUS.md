# Arvin — Project Status

## وضعیت مرجع
- Branch: `feat/follow-up-history-v1.3`
- آخرین Commit قابل مشاهده در GitHub: `858a1e0` (`fix: persist FollowUp history in TaskStore`)
- این سند باید با هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## معماری فعلی
- Flutter Android application.
- مدل اصلی `Task` حفظ شده و تاریخچه پیگیری با `FollowUp` در کنار آن توسعه داده شده است.
- `TaskStore` برای ذخیره/بازیابی `followUps` اصلاح شده است.
- Calendar و تست‌های مرتبط در حال پایدارسازی هستند.

## Follow-up History
هدف این قابلیت، نمایش آخرین پیگیری و ساعت آن و نگهداری تاریخچه پیگیری‌هاست؛ این بخش باید بدون از بین بردن داده‌های قبلی `followUpDate` توسعه یابد.

## Calendar
- تست‌های Calendar به‌صورت deterministic شده‌اند.
- آخرین گزارش CI نشان داده بود دو تست Calendar هنوز می‌توانند به layout/overflow حساس باشند؛ قبل از Release باید دوباره تأیید شوند.

## Android / Release
- در CI قبلاً خطای `Build failed due to use of deleted Android v1 embedding` مشاهده شده است.
- Repository در برخی Commitهای قبلی Android skeleton ناقص داشته است.
- Release pipeline باید با Android V2 واقعی و قابل build تثبیت شود و سپس APK تولید شود.
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

## گزارش‌گیری
هر تغییر مهم باید با Commit SHA و نتیجه CI در همین سند ثبت شود؛ ادعای «انجام شد» فقط زمانی مجاز است که تغییر در GitHub قابل مشاهده باشد.
