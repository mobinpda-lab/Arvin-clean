# آروین — سند تداوم اجرای پروژه

تاریخ مرجع: ۱۴۰۵/۰۶/۳۱

## قانون مالک

SQL/SQLite + Drift یکی از محورهای اصلی اجرای فعلی آروین است، نه صرفاً یک مرحله در سند.

## ترتیب مرجع تکمیل

1. حسابرسی زنده GitHub در ابتدای هر ادامه.
2. تثبیت Drift/SQLite بدون Model یا Storage موازی.
3. رفع Lossless Migration.
4. مهاجرت واقعی داده از SharedPreferences/JSON به SQLite.
5. اعتبارسنجی تعداد، شناسه‌ها، روابط، ترتیب تاریخچه، جلوگیری از duplicate، idempotency و rollback.
6. Round-trip و Backup/Restore.
7. Cutover کنترل‌شده Repository/TaskStore به SQL.
8. Analyze + Test + Debug APK + Release APK روی همان SHA.
9. Android smoke/evidence روی همان SHA.
10. تکمیل و تأیید UI نهایی: Home، Quick Capture، FollowUp، Notebook، Calendar، Next Action، More، Settings، Swipe.
11. فقط پس از عبور همه گیت‌ها: Release-Ready.

## داده‌هایی که باید حفظ شوند

Task، FollowUp و تاریخچه، Project، Category، Tag، Checklist، Note، Archive، Trash و هر داده واقعی کاربر که در مرز مهاجرت وجود دارد.

## چیزهایی که Migration نیستند

Home قدیمی، home-group-mode-selector، فیلترها و کنترل‌های قدیمی Home، projectionهای سازگاری قدیمی، تست‌های صرفاً UI قدیمی و فایل‌های صرفاً UI/Widget.

این موارد نباید به SQL منتقل شوند.

## وضعیت فعلی مرجع

- پایه SQL/Drift وجود دارد.
- TaskStore هنوز به SQL Cutover نشده است.
- Migration کامل داده واقعی هنوز انجام نشده است.
- گیت Lossless Migration باید قبل از Cutover عبور کند.
- SharedPreferences تا اثبات موفقیت Migration نباید حذف یا جایگزین شود.
- PRهای مرتبط و SHAها باید در هر ادامه زنده از GitHub بررسی شوند؛ این سند جای حسابرسی زنده را نمی‌گیرد.

## قانون گزارش

هیچ موردی «کامل» نیست مگر اینکه کد + آزمون + Build + شواهد Android روی همان SHA تأیید شده باشد.

## فرمان ادامه

ادامه آروین = اجرای واقعی مرحله بعد بر اساس همین سند، با شروع از حسابرسی زنده GitHub و ادامه کار در Branch/PR؛ نه صرفاً ارائه دستور یا گزارش تکراری.
