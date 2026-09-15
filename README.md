# Arvin — Clean Project

نرم‌افزار مدیریت کارها، پیگیری‌ها و سازمان‌دهی اطلاعات برای اندروید، ساخته‌شده با Flutter.

این Repository مرجع توسعه فعلی آروین است.

## Product Scope

آروین فقط یک Task List نیست؛ هدف آن یک سیستم مدیریت کار و پیگیری یکپارچه است.

حوزه‌های محصول:

- Task Management
- Follow Up Management
- Projects
- Categories
- Tags
- Reminders
- Notebook / Notes
- Calendar
- Backup/Restore
- Multi-device Sync
- Future Intelligence Layer

## Current Foundation

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

## Product Alignment

برای جلوگیری از اختلاف بین طراحی، مستندات و کد، مرجع‌های زیر استفاده می‌شوند:

- `docs/ARVIN_PRODUCT_SPECIFICATION.md`
- `docs/FEATURE_IMPLEMENTATION_MATRIX.md`

## Build
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```
