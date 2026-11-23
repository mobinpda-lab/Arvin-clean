# Encrypted Backup Byte Path — 2026-08-27

## Scope
این Slice فقط رمزنگاری اختیاری را به byte path موجود `ArvinBackupService` وصل می‌کند.

- فرمت plaintext رسمی همچنان `arvin_backup` نسخه 1 است.
- بدون passphrase رفتار قبلی بدون تغییر می‌ماند.
- با passphrase، همان bytes معتبر v1 داخل `ArvinEncryptedBackupEnvelope` قرار می‌گیرند.
- SAF و Cloud دقیقاً همان final bytes را دریافت می‌کنند.
- در Restore ابتدا envelope باز و authenticate می‌شود، سپس plaintext به `validateBackupDocument` موجود می‌رسد.
- Backup قدیمی plaintext بدون passphrase همچنان قابل Restore است.

## Security boundary
- passphrase در Backup، Settings یا metadata ذخیره نمی‌شود.
- رمز اشتباه یا ciphertext دستکاری‌شده قبل از برگرداندن document معتبر fail می‌شود.
- `TaskStore` و داده محلی رمزنگاری نشده‌اند؛ این Slice فقط Backup portability را پوشش می‌دهد.
- Dropbox/Cloud provider سیاست رمزنگاری ندارد و فقط bytes آماده را جابه‌جا می‌کند.

## Test seam
برای اثبات یکسان‌بودن bytes محلی و Cloud، `ArvinBackupService` یک `BackupLocalWriter` اختیاری برای تست دارد. در اجرای واقعی، اگر inject نشده باشد همان `Saf.writeFileBytes` قبلی استفاده می‌شود. این seam storage/repository جدیدی ایجاد نمی‌کند.

## Validation required
این تغییر فقط بعد از exact-head Parallel Wave، Build شامل Release/Debug APK و Device Smoke قابل Merge است. Slice بعدی #250 رابط کاربری فارسی opt-in، ورود/تأیید passphrase و هشدار بازیابی را اضافه می‌کند؛ secret همچنان نباید persist شود.
