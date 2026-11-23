# پیام روز آروین — Parallel Delivery Wave — 2026-08-27

Refs: #260

## وضعیت تثبیت‌شده
- Foundation در PR #261 با Build/Parallel/Device Smoke سبز وارد `main` شد.
- مدل Daily Content، source policy و selector بدون dependency جدید در main موجود است.

## Laneهای هم‌زمان
- #262: Calendar UI — کارت «پیام روز» خارج از شمارنده Reminder/Task/FollowUp.
- #263: Pack codec — schema v1 کوچک و fail-closed.
- Preferences lane: master switch، شش دسته مستقل، opt-in اعلان و ساعت اعلان.
- Notification lane: sink مستقل روی `flutter_local_notifications` موجود؛ بدون package جدید.

## قوانین سرعت و ایمنی
- هر lane کوچک، مستقل و قابل rollback است.
- تغییر مستقیم main ممنوع؛ هر تغییر از PR و exact-head CI عبور می‌کند.
- توسعه یک lane منتظر تکمیل lane دیگر نمی‌ماند مگر dependency واقعی داشته باشد.
- کتاب کامل/بانک عظیم حدیث وارد APK نمی‌شود.
- محتوای بدون source/reference/verification هرگز publish نمی‌شود.
- source/provider واقعی تا روشن‌شدن اعتبار و مجوز مستقل از UI و notification پیش می‌رود.

## مسیر بعدی
1. سبزکردن و merge مستقل UI و codec.
2. اتصال Preferences به Settings UI بدون تغییر قرارداد Backup عمومی.
3. اتصال scheduler به preference زمان اعلان با زیرساخت موجود Android/Arvin.
4. اضافه‌کردن content pack کوچک و ممیزی‌شده از منابع رسمی ایرانی/حوزوی.
