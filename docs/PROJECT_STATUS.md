# Arvin — Project Status

## مرجع فعلی
- Branch مرجع: `main`
- آخرین Commit مرجع قبل از Wave مدل: `38377f6ac167be7f8642f18c06f29b05793975c8`
- Flutter CI target: `3.47.0` stable
- این سند باید همراه هر تغییر مهم کد، تست، CI و نسخه به‌روزرسانی شود.

## تصمیم مهم جدید — مدل محصول
مدل قبلی که Note و Task را به‌عنوان دو مسیر مستقل برای یک مورد در نظر می‌گرفت **superseded** شد.

مدل هدف:
`Item → Note state → optional FollowUps[] → optional Reminder`

مورد جدید ابتدا مثل یادداشت ساده است. با فعال‌کردن پیگیری، همان Item به مورد پیگیری‌دار تبدیل می‌شود؛ داده‌ها و شناسه پایه کپی نمی‌شوند.

این تصمیم باید قبل از هر تغییر در Home، Search، FollowUp، Notebook و Storage بررسی شود.

## وضعیت قابلیت‌ها
### Item / Task / FollowUp
- مدل فعلی و مسیر Legacy هنوز باید audit و سپس به Contract جدید نزدیک شوند.
- FollowUp history، تاریخ/ساعت خودکار و قابل ویرایش، نتیجه و next follow-up باید حفظ شوند.
- Search Service موجود است؛ اتصال UI به Home تا بعد از حل model contract نباید باعث ایجاد مسیر داده موازی شود.

### Simple Notebook
- Foundation و session policy قبلی وجود دارند.
- مدل محصول اکنون با Item مشترک هم‌راستا می‌شود.
- Note timestamp فقط metadata داخلی است و Calendar Event نیست.
- Auto-save و read-only-after-exit و explicit edit حفظ می‌شوند.
- Checklist و Settings باید در UI نهایی تکمیل شوند.

### Calendar / Reminder
- Jalali/Persian RTL Calendar و regression fixes قبلی حفظ می‌شوند.
- Calendar دوباره‌سازی نمی‌شود مگر regression یا نیاز صریح.
- Reminder از timestamp Note جداست.
- Google Calendar فقط برای scheduled items واجد شرایط است؛ Note نباید event بسازد.
- UX تقویم/ساعت می‌تواند از `arvin-task-tracker` الگوبرداری شود، بدون کپی معماری.

### Typography
- تصمیم نهایی: IRANSans / IranSansX(Eco) به‌عنوان فونت اصلی.
- اعمال End-to-End در UI/Settings/PDF هنوز باید اعتبارسنجی شود.

### Backup / Dropbox
- Backup/Restore foundation موجود است.
- Note و FollowUp باید در Backup/Restore مدل مشترک جدید را حفظ کنند.
- Dropbox از زیرساخت موجود استفاده می‌کند و سیستم موازی ساخته نمی‌شود.

### PDF / Share
- هنوز Gap اصلی است: PDF مورد + تاریخچه FollowUp و PDF فهرست + Share + RTL/شمسی.

## برنامه بعدی
1. Model Contract audit: `Item / ArvinTask / models.Task / Note storage / FollowUp storage`.
2. Migration بدون از دست رفتن داده.
3. Home و Search UI روی یک مسیر داده.
4. Notebook UI + Checklist + Settings.
5. Reminder/Calendar با isolation برای Note.
6. PDF/Share و IRANSans End-to-End.
7. Backup/Restore + Dropbox End-to-End.
8. E2E و APK Release.

## قانون توسعه دائمی
قبل از هر تغییر: `main`، کد واقعی، PRهای باز، CI اخیر، مستندات و پروژه‌های مرجع بررسی شوند. اگر مشکل قبلاً رفع شده، هیچ اصلاح تکراری انجام نشود. تغییر حداقلی، تست focused، مستندات، Commit SHA و Workflowهای مستقل/موازی باید ثبت شوند.
