# Calendar رسمی ایران — Implementation Gate — 2026-08-15

## Audit قبل از تغییر
- `main` و roadmap/status فعلی بررسی شد.
- PR #79 و PR #80 بررسی شدند؛ قرارداد رسمی و source-neutral mapping به `CalendarReminder` اکنون در `main` تثبیت شده‌اند.
- `CalendarPage` و مدل موجود `CalendarReminder` حفظ شده‌اند و storage موازی ایجاد نشده است.
- سند `CALENDAR_OFFICIAL_SOURCE_RESEARCH_2026-08-15.md` مرجع فعلی بررسی منبع است.

## وضعیت فعلی
لایه‌های زیر در `main` موجود و تثبیت شده‌اند:
- `OfficialCalendarReminder`
- `OfficialReminderKind`
- `OfficialCalendarReminderSource`
- `OfficialCalendarReminderService`

این لایه فقط mapping و composition را انجام می‌دهد و مسئول networking، cache یا storage نیست.

## محدودیت عمدی
داده واقعی اوقات شرعی یا فهرست تعطیلات هنوز hard-code یا از منبع غیررسمی وارد production نشده است. این تصمیم عمدی است: Provider باید فقط با داده قابل انتساب و قابل اعتبارسنجی نسبت به منبع رسمی ساخته شود.

## گام اجرایی بعدی
دو Provider مستقل، بدون تغییر Calendar foundation:

1. **تعطیلات رسمی ایران**
   - داده سالانه versioned و قابل audit.
   - فقط روزهای واقعاً تعطیل رسمی به `OfficialReminderKind.iranianHoliday` نگاشت شوند.
   - اصلاحیه‌های سالانه قابل جایگزینی باشند.
   - fixture سالانه و تست تبدیل تاریخ شمسی/میلادی اضافه شود.

2. **اوقات شرعی شیعه**
   - منبع/روش مورد تأیید مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران.
   - ورودی صریح مکان/شهر و سال.
   - حفظ timezone محلی مکان.
   - fixture معتبر شهر/سال و تست timezone و مرز روز.
   - در نبود داده معتبر، زمان حدسی تولید نشود.

هر دو Provider باید خروجی را از مسیر `OfficialCalendarReminderService` به همان `CalendarReminder` فعلی تحویل دهند.

## سرعت و موازی‌سازی
Provider تعطیلات و Provider اوقات شرعی از نظر کد می‌توانند در دو commit مستقل آماده شوند، مشروط به اینکه هر دو فقط contract موجود را مصرف کنند و foundation مشترک را تغییر ندهند. هر commit بلافاصله با Build و validation مرتبط اجرا می‌شود.

## Guardrail
- Note timestamp به این مسیر وارد نمی‌شود.
- Reminder رسمی با Google/system Calendar یکی فرض نمی‌شود.
- Calendar foundation، storage و مدل Item دوباره ساخته نمی‌شوند.
- اگر منبع رسمی برای یک سال/مکان در دسترس نباشد، داده ساختگی تولید نمی‌شود؛ UI باید graceful رفتار کند.

## Validation
- تست mapping و composition موجود است.
- پس از هر Provider: focused tests + Calendar validation + Build/Parallel.
- پس از اتصال هر دو Provider: regression کامل Calendar و APK واقعی.
