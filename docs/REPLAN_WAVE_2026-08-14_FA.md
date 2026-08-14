# بازنگری Wave تکمیل آروین — 2026-08-14

## مبنای واقعی
آخرین commit فعلی `main`:
`38377f6ac167be7f8642f18c06f29b05793975c8`

این Wave بر اساس کد واقعی `main` و سابقه commitها تنظیم شده است. README فعلی پایه‌های Task/FollowUp، Tag، Multi-select، Archive/Trash، Swipe، Settings، Backup/Restore و آمادگی Dropbox را ثبت می‌کند.

## تصمیم نهایی مدل محصول
موجودیت کاربرمحور یک **Item** است.

```text
Item
 ├─ title/topic
 ├─ note/description
 ├─ createdAt / editedAt
 ├─ checklist (اختیاری)
 ├─ category / tags
 ├─ reminder (اختیاری)
 └─ followUps[] (اختیاری)
```

Item در حالت عادی یک یادداشت ساده است. با فعال شدن پیگیری، همان Item به مورد پیگیری‌دار تبدیل می‌شود؛ نباید برای Note و Task دو مسیر داده موازی ساخته شود.

## یادداشت
- timestamp سیستم هنگام ایجاد به‌صورت خودکار درج شود.
- timestamp برای کاربر قابل ویرایش باشد.
- Auto-save.
- پس از خروج Read-only.
- برای تغییر، دکمه Edit.
- رفتار Read-only/Edit از Settings قابل فعال/غیرفعال شدن.
- Checklist.
- timestamp یادداشت فقط داخل Arvin نگهداری شود و Event تقویم نشود.
- Note قابل PDF/Print باشد.

## پیگیری
- تاریخ/ساعت سیستم هنگام ثبت خودکار باشد.
- تاریخ/ساعت توسط کاربر قابل ویرایش باشد.
- متن/نتیجه پیگیری.
- تاریخچه کامل.
- Edit/Delete.
- آخرین پیگیری در Home با ساعت و دقیقه.

## Print و PDF
Print و PDF دو خروجی مستقل‌اند:
- Note ساده: عنوان، متن، Checklist، timestamp.
- Item پیگیری‌دار: اطلاعات Item + تمام FollowUpها.
- فهرست موارد برای Print/PDF در صورت پشتیبانی UI انتخاب گروهی.
- RTL، فارسی، تاریخ شمسی و IRANSans.
- PDF برای Share مناسب است؛ Print برای Android Print Service.

## Widget — مشخصات نهایی
Widget از دیتای اصلی Arvin استفاده می‌کند و Storage جدا ندارد.

نمایش:
- موارد امروز
- عقب‌افتاده
- آینده/نزدیک‌ترین موارد در صورت وجود مدل Reminder/FollowUp
- فیلتر Category فقط اگر Category در Item فعال باشد
- فیلتر Today/Overdue فقط اگر وضعیت‌های متناظر در مدل نهایی وجود داشته باشند

UX:
- دکمه `+` برای افزودن سریع Item
- لمس Item برای بازکردن همان مورد
- RTL و IRANSans
- سبک و کم‌مصرف
- refresh محدود و هوشمند در پس‌زمینه، بدون سرویس سنگین دائمی
- در صورت نبود Category/Today/Overdue، Widget نباید قابلیت مصنوعی برای آنها بسازد.

## Waveها
### Wave A — Architecture Safety
تطبیق مدل فعلی Task/FollowUp، Notebook foundation و persistence با Item Contract. هیچ قابلیت حل‌شده‌ای بازنویسی نشود.

### Wave B — Notebook UI
Editor، Auto-save، Read-only/Edit، Checklist و Settings.

### Wave C — Home Integration
یکپارچه‌سازی Item، FollowUp، Sort، Swipe و Multi-select.

### Wave D — Search UI
استفاده از SearchService موجود؛ فقط اتصال به مسیر واقعی Home.

### Wave E — Widget
تکمیل Widget روی همان repository/service موجود، بدون Storage موازی.

### Wave F — PDF + Print
تکمیل هر دو خروجی با Note و FollowUp.

### Wave G — Typography
IRANSans در UI، Widget، PDF و Print + Settings.

### Wave H — Reminder / Google Calendar
تفکیک کامل timestamp Note از Reminder/Calendar Event؛ Note هرگز به Calendar ارسال نشود.

### Wave I — Backup / Restore / Dropbox
تکمیل End-to-End با حفظ داده‌های Item/FollowUp/Notebook/Settings.

### Wave J — E2E / APK
تست سناریوهای اصلی، Release APK و تست نصب واقعی.

## قانون ضد دوباره‌کاری
قبل از هر تغییر:
1. `main` و آخرین commit بررسی شود.
2. PRهای باز بررسی شود.
3. کد واقعی و تست‌های مرتبط بررسی شود.
4. مستندات و تصمیم‌های قبلی بررسی شود.
5. پروژه‌های `arvin-task-tracker` و `daftar-peygiri` فقط برای تجربه مرجع مقایسه شوند.
6. اگر قابلیت قبلاً حل شده، تغییر مجدد ممنوع است.
7. فقط Gap واقعی تغییر کند.
8. تست focused و regression اجرا شود.
9. سابقه و مستندات همان Wave ثبت شود.
10. Commit و Workflowهای مستقل موازی اجرا شوند.

## Definition of Done
قابلیت فقط زمانی Done است که domain + persistence + UI + RTL/Jalali + تست + CI + APK واقعی + مستندات آن کامل باشند.
