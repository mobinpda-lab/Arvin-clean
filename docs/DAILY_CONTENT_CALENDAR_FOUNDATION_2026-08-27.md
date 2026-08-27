# پیام روز آروین — Daily Content Foundation — 2026-08-27

Refs: #260

## هدف محصول
افزودن یک «پیام روز» سبک و قابل ممیزی به هر روز تقویم آروین، بدون تبدیل آن به Task/FollowUp و بدون آلوده‌کردن شمارنده کارهای روز.

## دسته‌های مصوب
1. قرآن کریم
2. نهج‌البلاغه
3. حدیث معتبر شیعه با مأخذ دقیق
4. صحیفه سجادیه
5. سخن بزرگان ایران
6. سخن بزرگان جهان با منبع قابل راستی‌آزمایی

## قرارداد معماری
- `DailyContentItem` یک محتوای کوچک و source-attributed است.
- `DailyContentPack` نسخه‌دار و cache-friendly است و برای حمل تعداد کمی آیتم طراحی شده، نه کتاب کامل.
- `DailyContentSource` مرز provider آینده است؛ networking/cache/storage در foundation تقویم ساخته نمی‌شود.
- `DailyContentSelector` برای یک تاریخ و یک pack ثابت خروجی deterministic می‌دهد.
- انتخاب به runtime random وابسته نیست و با permutation پایدار، تا تمام‌شدن pool واجدشرایط آیتم را تکرار نمی‌کند.
- آیتم بدون `source`، `reference` یا `verifiedBy` fail-closed می‌شود و هرگز برای نمایش روزانه انتخاب نمی‌شود.

## Source Policy
اولویت production با منابع رسمی/حوزوی ایرانی و شیعی قم/نجف است. مسیر پیشنهادی بررسی محتوا:
- قرآن: متن/ترجمه دارای مجوز و قابل انتساب از مرجع رسمی ایرانی.
- حدیث شیعه: پژوهشگاه قرآن و حدیث/دارالحدیث و تطبیق با بانک‌های معتبر حوزوی مانند نور؛ صرف حضور در یک مجموعه حدیثی به معنی صحیح‌السند بودن نیست.
- نهج‌البلاغه و صحیفه: متن و ترجمه دارای مأخذ دقیق؛ فقط فراز مستقل و قابل فهم برای پیام روز.
- بزرگان ایران: اثر اصلی یا مؤسسه رسمی نشر آثار شخصیت.
- بزرگان جهان: فقط نقل‌قولی که مأخذ اصلی/قابل راستی‌آزمایی داشته باشد.

تا زمانی که مجوز/روش دریافت production روشن نباشد، scraping مستقیم یک سایت dependency محصول محسوب نمی‌شود.

## Lightweight Contract
- کتاب‌های کامل یا بانک‌های صدها هزار حدیث داخل APK قرار نمی‌گیرند.
- provider production باید pack کوچک versioned/cacheable بدهد (مثلاً 30 تا 60 روز یا pool کوچک کافی برای دوره آفلاین).
- emergency pack کوچک می‌تواند بعداً اضافه شود، اما فقط با محتوای تأییدشده.
- dependency سنگین جدید برای این foundation اضافه نشده است.

## Calendar Integration Guardrail
Daily Content نباید به `CalendarReminder` معمولی تبدیل شود، چون شمارنده فعلی تقویم تعداد reminderهای روز را روی خانه تاریخ نمایش می‌دهد. UI باید کارت «پیام روز» را جداگانه برای selected day نمایش دهد و شمارنده task/follow-up/reminder را تغییر ندهد.

## Delivery Lanes
### Lane A — Foundation (این PR)
- model/pack/source contract
- deterministic selector
- focused tests
- source + size policy

### Lane B — Calendar UI
- کارت جداگانه «پیام روز» در selected-day surface
- بدون تغییر count
- صفحه/BottomSheet جزئیات با متن، اصل متن اختیاری، مأخذ و مرجع تأیید

### Lane C — Settings + Notification
- master switch
- switch برای هر شش دسته
- اعلان اختیاری با زمان کاربر
- خاموش‌کردن اعلان نباید پیام روز داخل تقویم را حذف کند

### Lane D — Verified Content Pack
- schema v1 JSON
- cache کوچک
- source adapter معتبر
- fallback به آخرین pack معتبر
- در نبود داده معتبر، UI graceful و بدون جعل محتوا

## Merge Gate
- focused tests green
- repository Build/Parallel green روی exact head
- بدون regression در Calendar foundation
- بدون merge مستقیم به main؛ فقط PR reviewable

## CI Ready Checkpoint
- PR #261 ابتدا Draft باز شد و Parallel Wave روی head اولیه سبز شد.
- PR سپس فقط برای اجرای gate کامل به Ready منتقل شد؛ merge خودکار یا مستقیم فعال نشده است.
- این commit مستندی عمداً رفتار production را تغییر نمی‌دهد و رویداد synchronize ایجاد می‌کند تا Build/Parallel روی exact head جدید قابل ارزیابی باشد.
