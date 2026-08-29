# Arvin — Execution Audit 2026-08-15

## هدف
ثبت وضعیت واقعی قبل از Wave بعدی و جلوگیری از دوباره‌کاری. این سند جایگزین foundation یا source-of-truth محصول نیست.

## Audit انجام‌شده
- `main` فعلی: `6db00c815fedaf5f264f50c1310893c29e66d6a1`.
- `docs/PROJECT_STATUS.md` و `docs/PROJECT_ROADMAP_2026-08-14.md` بررسی شدند.
- مدل Calendar همچنان روی `OfficialCalendarReminder` و `CalendarReminder` موجود است؛ foundation جدید ساخته نشد.
- تست موجود `test/calendar_official_reminders_test.dart` mapping، ترکیب sourceها، فیلتر سال، حذف duplicate و sort را پوشش می‌دهد.
- PRهای باز بررسی شدند؛ PR #80 قرارداد Calendar را قبلاً به main رسانده است و بنابراین قرارداد دوباره ساخته نمی‌شود.
- Android Widget foundation هنوز در main به‌صورت native AppWidget/RemoteViews تثبیت نشده است؛ بنابراین Quick FollowUp Widget بدون foundation مشترک شروع نمی‌شود.

## Calendar source validation
برای تعطیلات رسمی ۱۴۰۵، منابع عمومی موجود تاریخ‌ها و مناسبت‌ها را ارائه می‌کنند، اما در این audit هیچ منبع ثانویه‌ای به‌عنوان source-of-truth نهایی محصول تثبیت نمی‌شود.

برای اوقات شرعی، منابع عمومی مورد بررسی تأکید می‌کنند که روش/تأیید مؤسسه ژئوفیزیک دانشگاه تهران مبناست؛ با این حال implementation محصول باید داده یا روش قابل اعتبارسنجی را مستقیماً به قرارداد Provider تزریق کند و نباید زمان‌ها را از یک منبع ثانویه بدون validation وارد کند.

بنابراین Gap واقعی فعلی همچنان این است:
1. Provider تعطیلات رسمی ایران با داده versioned و قابل اعتبارسنجی.
2. Provider اوقات شرعی شیعه با مکان، timezone، سال و منبع مشخص.
3. regression tests برای مرز سال، مکان و duplicate.

## CI guardrail
آخرین شکست بررسی‌شده در Run `31847037825` در مرحله دریافت dependency از `pub.dev` رخ داده بود و قبل از analyze/test/build APK متوقف شده بود؛ بنابراین نباید به‌عنوان regression محصول تفسیر شود. قبل از ادامه Lane وابسته، Run جدید باید دوباره تأیید شود.

## مسیر موازی بعدی
- Calendar Providerها: implementation فقط پس از تثبیت fixture/source معتبر.
- Widget Foundation: audit native Android و انتخاب یک foundation مشترک، بدون storage موازی.
- Quick FollowUp Widget: بعد از foundation، عنوان + آخرین پیگیری + تاریخ/ساعت یک‌خطی، اسکرول، Category/امکانات سازگار و Lock Screen در صورت پشتیبانی.
- FollowUp UX و Home/Search می‌توانند تست و طراحی مستقل آماده کنند، اما به Unified Item/adapter وابسته‌اند.

## قانون ادامه
`Audit → Gap واقعی → تغییر حداقلی → focused/regression test → Commit → Build + Parallel → بررسی CI → مستندسازی/Handoff`.

در این Wave هیچ قابلیت حل‌شده دوباره‌سازی نمی‌شود و درصد پیشرفت فقط با رسیدن یک قابلیت به Definition of Done افزایش می‌یابد.
