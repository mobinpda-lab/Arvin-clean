# Arvin — وضعیت به‌روزشده پروژه

آخرین بازبینی کامل: 2026-08-14

## وضعیت مرجع
- مخزن: `mobinpda-lab/Arvin-clean`
- Branch توسعه: `feat/follow-up-history-v1.3`
- Flutter CI: `3.47.0` stable
- Android: Flutter V2 embedding
- نسخه ثبت‌شده محصول در مستند فعلی: `1.0.0+1`

## قابلیت‌های موجود
### Task Management
- ایجاد و ویرایش Task
- توضیحات و Tag
- تاریخ پیگیری
- تکمیل
- بایگانی
- Trash / Restore / حذف دائمی
- جست‌وجو و فیلتر
- آمار Taskها

### FollowUp
- مدل مستقل `FollowUp`
- migration از `followUpDate` قدیمی
- persistence در `TaskStore`
- تست مدل و Store
- UI تاریخچه FollowUp در حال تکمیل و تثبیت

### Calendar / Reminder
- Calendar page foundation
- نمایش Reminder برای روز انتخاب‌شده
- empty state
- تست deterministic
- مرحله بعد: اتصال کامل Calendar ↔ FollowUp ↔ Reminder و تثبیت responsive layout

### Backup / Restore
- SAF برای انتخاب پوشه
- Backup نسخه‌دار JSON
- نام فایل با تاریخ شمسی
- Restore با validation
- emergency backup قبل از Restore
- تست‌های سرویس، schedule، notification، background، Android scheduler و cloud provider
- مرحله بعد: تکمیل UX و lifecycle واقعی Backup دوره‌ای

### UI / Typography
- Material 3 و RTL
- **IranSansX باید فونت پیش‌فرض محصول باشد.**
- امکان تغییر فونت در Settings باید اضافه شود.
- انتخاب فونت و اندازه باید persistence داشته باشد.

## CI موازی
چهار مسیر جدید مستقل به این branch اضافه شده‌اند:
1. `Arvin Parallel FollowUp`
2. `Arvin Parallel Calendar`
3. `Arvin Parallel Backup`
4. `Arvin Parallel Release`

این چهار مسیر با یک push به‌صورت مستقل و موازی اجرا می‌شوند. شکست یک حوزه نباید جلوی تشخیص حوزه‌های دیگر را بگیرد.

Release معیار سخت‌گیرانه دارد: `flutter build apk --release` باید سبز شود و APK به Artifact آپلود شود.

## فازهای باقی‌مانده
1. **Release / APK:** تأیید Build واقعی و Artifact نسخه‌دار.
2. **FollowUp UI:** تکمیل افزودن/نمایش/ویرایش تاریخچه، نتیجه و پیگیری بعدی.
3. **Calendar + Reminder:** اتصال کامل به FollowUp، اعلان و responsive layout.
4. **Typography:** افزودن IranSansX به assets و FontManager/Settings برای تغییر فونت و persistence.
5. **Product Settings:** یکپارچه‌سازی تنظیمات فونت، Backup و Reminder در Settings.
6. **Release Candidate:** smoke test، versioning، checksum، artifact و مستند Release.

## قانون ثبت تغییرات
هر قابلیت مهم باید با چهار خروجی ثبت شود: **کد + تست + CI + مستندات**. SHA هر Commit مهم باید قابل مشاهده باشد.
