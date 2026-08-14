# Calendar رسمی ایران — Implementation Gate — 2026-08-14

## Audit قبل از تغییر
- `main` و roadmap فعلی بررسی شد.
- PR #79 بررسی شد؛ آن PR قرارداد و منبع رسمی موردنیاز را ثبت کرده و implementation واقعی را وارد `main` نکرده است.
- PR #80 نیز بررسی شد؛ foundation فعلی Calendar و `CalendarReminder` حفظ شده و storage موازی ایجاد نشده است.
- `CalendarPage` و مدل موجود `CalendarReminder` بررسی شد.

## تغییر این Wave
یک contract کوچک و source-neutral برای اتصال داده رسمی به مدل موجود Calendar اضافه شد:

- `OfficialCalendarReminder`
- `OfficialReminderKind`
- `OfficialCalendarReminderSource`
- `OfficialCalendarReminderService`

این لایه فقط mapping و composition را انجام می‌دهد و مسئول networking، cache یا storage نیست.

## محدودیت عمدی
این Wave هنوز داده واقعی اوقات شرعی یا فهرست تعطیلات را hard-code یا از منبع غیررسمی دریافت نمی‌کند. Providerهای واقعی باید بعد از validation منبع رسمی PR #79 اضافه شوند.

## Validation فعلی
- mapping به `CalendarReminder`
- ترکیب چند source
- جلوگیری از ایجاد مدل/Storage موازی
- Build و Parallel برای head فعلی PR #80 در حال اجرا هستند؛ merge فقط پس از سبز شدن validation انجام می‌شود.

## گام بعدی — دو lane مستقل
پس از سبز شدن contract، providerهای واقعی به‌صورت مستقل برای این دو منبع پیاده می‌شوند:

1. **اوقات شرعی شیعه** با منبع/روش مورد تأیید مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران؛ بدون جایگزین کردن منبع غیررسمی و با وابستگی روشن به مکان/سال.
2. **تعطیلات رسمی ایران** با منبع تقویم رسمی کشور؛ داده سالانه باید قابل ممیزی و به‌روزرسانی باشد.

این دو provider باید در همان `OfficialCalendarReminderService` ترکیب شوند و خروجی را به `CalendarReminder` فعلی بدهند.

## Guardrail
- Note timestamp به این مسیر وارد نمی‌شود.
- Reminder رسمی با Google/system Calendar یکی فرض نمی‌شود.
- Calendar foundation، storage و مدل Item دوباره ساخته نمی‌شوند.
- اگر منبع رسمی برای یک سال/مکان در دسترس نباشد، داده ساختگی تولید نمی‌شود؛ UI باید graceful رفتار کند.
