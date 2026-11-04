# Arvin — Clean Project

نرم‌افزار مدیریت کارها و پیگیری‌ها برای اندروید، ساخته‌شده با Flutter.

این Repository کاملاً جدید است و نسخه‌های قبلی مبنای آن نیستند.

## پایه‌های پروژه
- مدیریت کارها و پیگیری‌ها
- عنوان خودکار از سطر اول توضیحات با امکان اصلاح
- تاریخ پیگیری، شامل تاریخ‌های گذشته
- تگ‌ها
- انتخاب چندتایی و عملیات گروهی
- بایگانی و سطل زباله
- تنظیم عملکرد Swipe چپ و راست
- پنل تنظیمات قابل مخفی شدن
- Backup/Restore
- آماده‌سازی برای اتصال Dropbox

## Build
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```


## ممیزی CI آروین — ۱۴۰۵/۰۸/۱۳ (2026-11-04)

- ممیزی دقیق SHA `3f849eefed2afe08c3d3662cf66d9c488388e737`: Analyze و شش شارد تست PASS؛ Follow-up SQLite PASS.
- Device Smoke run [41852048093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852048093) در زمان ممیزی کامل نشده بود؛ فقط Preparation موفق، Boot/Navigation در حال اجرا و پنج سناریوی دیگر در صف. نتیجه نهایی NOT VERIFIED.
- Calendar Provider run [41852047809](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047809) و Review APK run [41852047701](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047701) در حال اجرا بودند. Artifact جدید هنوز موجود نبود؛ لینک APK NOT VERIFIED.
- اصلاح اسکرول قبل از Finder در test-3 ثبت شد. تست‌ها تضعیف نشدند. PR #3052 OPEN / DRAFT / UNMERGED؛ main دست‌نخورده؛ Vazirmatn و فیلدهای Task حفظ؛ Release BLOCKED — RELEASE: NO-GO.
- این گزارش snapshot همان SHA است؛ مستندات در commit بعدی به‌روزرسانی شدند و اجرای CI روی SHA جدید باید جداگانه بررسی شود.
