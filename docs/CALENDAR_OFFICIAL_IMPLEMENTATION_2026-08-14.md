# Calendar رسمی ایران — Implementation Gate — 2026-08-14

## Audit قبل از تغییر
- `main` و roadmap فعلی بررسی شد.
- PR #79 بررسی شد؛ آن PR قرارداد و منبع رسمی موردنیاز را ثبت کرده و هنوز implementation واقعی را وارد `main` نکرده است.
- `CalendarPage` و مدل موجود `CalendarReminder` بررسی شد.
- Calendar foundation بازنویسی نشد و storage جدیدی ایجاد نشد.

## تغییر این Wave
یک contract کوچک و source-neutral برای اتصال داده رسمی به مدل موجود Calendar اضافه شد:

- `OfficialCalendarReminder`
- `OfficialReminderKind`
- `OfficialCalendarReminderSource`
- `OfficialCalendarReminderService`

این لایه فقط mapping و composition را انجام می‌دهد و مسئول networking، cache یا storage نیست.

## محدودیت عمدی
این Wave هنوز داده واقعی اوقات شرعی یا فهرست تعطیلات را hard-code یا از منبع غیررسمی دریافت نمی‌کند. Providerهای واقعی باید بعد از validation منبع رسمی PR #79 اضافه شوند.

## تست
- mapping به `CalendarReminder`
- ترکیب چند source
- جلوگیری از ایجاد مدل/Storage موازی

## معیار ادامه
پس از سبز شدن CI این branch، providerهای واقعی به‌صورت مستقل برای:
1. اوقات شرعی شیعه با منبع/روش مورد تأیید مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران
2. تعطیلات رسمی ایران با منبع تقویم رسمی کشور

اضافه می‌شوند و سپس به Calendar UI متصل خواهند شد.
