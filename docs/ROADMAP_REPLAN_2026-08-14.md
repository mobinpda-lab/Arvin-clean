# بازنگری برنامه اجرای پروژه آروین — ۱۴۰۵/۰۵/۲۳

## هدف

این سند برنامه اجرای پروژه را از «افزودن قابلیت‌های مستقل» به «تکمیل محصول یکپارچه و قابل انتشار» بازتنظیم می‌کند. مبنای تصمیم‌گیری، کد واقعی `main`، قراردادهای محصول، تجربه `arvin-task-tracker` و `daftar-peygiri`، متن ایده Time Jot و گزارش‌های CI است.

## اصل حاکم

قبل از هر تغییر:

1. `main` و کد واقعی بررسی شود.
2. PRهای باز و وابستگی‌های آن‌ها بررسی شود.
3. مستندات و قراردادهای قبلی بررسی شود.
4. مشخص شود قابلیت قبلاً پیاده‌سازی یا حل نشده باشد.
5. تغییر با حداقل سطح درگیری انجام شود.
6. تست مرتبط همان Wave و تست‌های regression اجرا شوند.
7. مستندات تغییر همزمان ثبت شود.

Commitهای مستقل و Waveهای مستقل تا حد امکان موازی و همزمان Validation شوند؛ یک Wave نباید برای شروع صرفاً منتظر سبزشدن Wave مستقل دیگری بماند، مگر اینکه وابستگی واقعی کدی داشته باشد.

## وضعیت مبنا

- Android/Flutter/CI: پایه موجود و حساس به regression.
- Calendar جلالی: تثبیت‌شده؛ بازنویسی بدون نیاز واقعی ممنوع.
- FollowUp: Domain/Storage/Application/Agenda/Office پایه‌های متعددی دارند و اکنون اولویت، یکپارچه‌سازی با Task واقعی است.
- Simple Note: Domain/Storage/Application/Session Policy در Waveهای جداگانه در حال تثبیت است؛ UI کامل هنوز هدف بعدی است.
- Backup/Restore: پایه‌های محلی و Providerهای Cloud/Dropbox در Repository وجود دارند؛ production-ready کردن آن جداگانه انجام شود.
- Google Calendar: integration باید فقط برای Task/FollowUp/Reminder باشد و Note نباید Event ایجاد کند.
- Typography: فونت پیش‌فرض محصول **IRANSans / IranSansX(Eco)** است.
- متن ایده Time Jot به‌عنوان Product Requirements مرجع ثبت شده است.

## بازتنظیم Waveها

### Wave 0 — Baseline & Gate

- اجرای full test/analyze/build.
- شناسایی تست‌های flaky و خطاهای واقعی.
- تعیین یک نقطه مبنای سبز قبل از تغییرات پرریسک.
- خروجی: baseline سبز و گزارش کوتاه.

### Wave 1 — FollowUp Integration

هدف: تبدیل FollowUp از مجموعه اجزای جدا به مسیر کامل محصول.

- اتصال Entry به Task واقعی.
- نمایش آخرین FollowUp در Home.
- نمایش تاریخچه کامل.
- تاریخ/ساعت خودکار و قابل ویرایش.
- nextFollowUp مستقل.
- Today/Future/Overdue.
- Reminder contract.

### Wave 2 — Simple Note

- ساخت Note ساده در Home.
- تاریخ/ساعت خودکار و قابل ویرایش.
- Auto-save.
- خروج = Read-only.
- مراجعه بعدی = View-only + دکمه Edit.
- Checklist.
- فعال/غیرفعال‌سازی Notebook در Settings.
- فعال‌کردن FollowUp برای تبدیل همان مورد به Task قابل پیگیری.

مرز مهم:

`Simple Note != Reminder != FollowUp != Calendar Event`

### Wave 3 — Home / Search / Sort UX

- Home به‌عنوان فهرست اصلی.
- تشخیص Note و Task.
- Search سراسری.
- Sort: تاریخ، آخرین ورودی، عنوان.
- Reverse sort.
- Long Press selection.
- Batch operations.
- FAB +.
- Swipe قابل تنظیم.

### Wave 4 — Reports / PDF / Share

- PDF یک Task همراه تمام FollowUpها.
- PDF فهرست Taskها.
- Persian/Jalali rendering.
- Share خروجی‌ها.

### Wave 5 — Typography / Settings

- اعمال سراسری IRANSans.
- بررسی دقیق فایل فونت موجود و مسیر قانونی/فنی bundling.
- Font Settings در صورت نیاز محصول.
- اعمال بدون تغییر رفتار داده‌ای.

### Wave 6 — Reminder / Google Calendar

- Reminder واقعی برای Task/FollowUp.
- Date/Time Picker استاندارد گوشی با نمایش فارسی/شمسی.
- اتصال Google Calendar در صورت فعال بودن.
- جلوگیری قطعی از ارسال Note به Google Calendar و Calendar گوشی.
- تست duplicate-event و restore.

### Wave 7 — Dropbox / Backup / Restore

- تکمیل Dropbox authentication/provider.
- Upload/Download backup.
- Restore روی گوشی دیگر.
- Conflict policy.
- Backup شامل Note، Task، FollowUp، Category، Tag و Settings.
- جلوگیری از ساخت Calendar Event ناخواسته هنگام Restore.

### Wave 8 — Release Hardening

- Full regression.
- E2E مسیرهای اصلی.
- Android release APK.
- نصب و smoke test.
- بررسی migration و restore.
- ثبت release notes.

## Waveهای موازی پیشنهادی

پس از Baseline، این مسیرها تا حد امکان مستقل اجرا شوند:

```text
                    ┌─ FollowUp Integration
                    ├─ Simple Note UI
Baseline Green ─────┼─ Search/Sort UX
                    ├─ PDF/Share foundation
                    ├─ Typography/Settings audit
                    └─ Dropbox/Backup audit

Google Calendar integration بعد از تثبیت قرارداد Reminder وارد مسیر مستقل خود می‌شود.
```

وابستگی واقعی فقط جایی مانع اجرای همزمان است که کد مشترک همان فایل/مدل را تغییر دهد؛ در این حالت ابتدا یک Contract/Model Wave کوچک و تست‌شده ساخته شود، سپس Waveهای وابسته مستقل شوند.

## معیار عبور هر Wave

هر Wave فقط وقتی «کامل» محسوب می‌شود که:

- تست اختصاصی سبز باشد.
- تست regression مرتبط سبز باشد.
- `flutter analyze` سبز باشد.
- تغییرات خارج از Scope نداشته باشد.
- مستندات به‌روز شده باشد.
- UI در صورت وجود، واقعاً در مسیر قابل دسترس برنامه قرار گرفته باشد؛ صرف وجود کلاس یا تست کافی نیست.
- اگر داده ذخیره می‌شود، migration/backward compatibility بررسی شده باشد.

## ممنوعیت‌های ضد دوباره‌کاری

- بازنویسی Calendar تثبیت‌شده بدون regression یا نیاز UX واقعی.
- ساخت مجدد FollowUp storage که قبلاً وجود دارد.
- ساخت Note با مدل جدید بدون بررسی `SimpleNote` موجود.
- واردکردن Note به Google Calendar.
- اضافه‌کردن Dropbox جدید در کنار Provider موجود بدون audit.
- تغییر فونت اصلی به Vazirmatn؛ تصمیم فعلی IRANSans است.
- ادعای تکمیل قابلیت صرفاً به دلیل سبزشدن CI.
- Merge کردن چند Wave مستقل در یک تغییر بزرگ که عیب‌یابی را سخت کند.

## Definition of Done محصول

آروین زمانی برای APK تست نهایی آماده است که کاربر بتواند از Home:

1. Note ساده ایجاد کند.
2. آن را با تاریخ/ساعت خودکار و قابل ویرایش ذخیره کند.
3. Note را فقط‌خواندنی ببیند و با دکمه Edit ویرایش کند.
4. در صورت نیاز FollowUp را فعال کند.
5. FollowUpهای متعدد با تاریخ/ساعت و سوابق کامل ثبت کند.
6. Reminder تنظیم کند.
7. امروز/آینده/عقب‌افتاده را ببیند.
8. Search و Sort انجام دهد.
9. دسته و Tag استفاده کند.
10. PDF بگیرد و Share کند.
11. Backup/Restore انجام دهد.
12. در صورت فعال‌سازی، Google Calendar و Dropbox را استفاده کند؛ بدون آلودگی Calendar به Note.
13. همه این مسیرها را بعد از خروج و اجرای مجدد برنامه بدون از دست رفتن داده ادامه دهد.

## اولویت فعلی

**اولویت فوری: Wave 0 → FollowUp Integration + Simple Note UI به‌صورت موازی.**

بعد از آن Search/Sort/Home UX و سپس PDF/Share، Typography، Calendar integration و Dropbox را به‌صورت مستقل جلو می‌بریم.
