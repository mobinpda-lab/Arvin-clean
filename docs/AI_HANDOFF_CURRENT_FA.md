# Arvin-clean — سند انتقال زنده برای هوش مصنوعی

> این فایل مرجع فشرده و به‌روز برای انتقال پروژه بین جلسات و بین هوش‌های مصنوعی است. هر عامل/هوش مصنوعی باید ابتدا این فایل، `docs/PROJECT_STATUS.md` و `docs/PROJECT_ROADMAP_2026-08-14.md` را مطالعه کند و سپس کد واقعی `main` را با آن‌ها تطبیق دهد.

## 1. قانون همکاری — غیرقابل مذاکره

قبل از هر تغییر: آخرین `main` و commit، کد واقعی مرتبط، PRهای باز، Workflow/CI اخیر، مستندات و سابقه تصمیم‌ها بررسی شوند؛ در صورت نیاز پروژه‌های مرجع بررسی شوند؛ Gap واقعی مشخص شود؛ قابلیت موجود دوباره ساخته نشود؛ تغییر حداقلی انجام شود؛ تست focused اجرا شود؛ Commit مستقل ثبت شود؛ Build و Parallel Workflow اجرا و نتیجه بررسی شود؛ و سابقه و تصمیم جدید در مستندات ثبت شود.

هدف APK واقعی، پایدار و قابل استفاده است؛ نه صرفاً CI سبز.

## 2. معماری هدف

Arvin-clean برنامه Android فارسی/RTL برای مدیریت Item، یادداشت، کار و پیگیری است.

```text
Item
 ├─ title
 ├─ text/description
 ├─ CreatedAt / EditedAt
 ├─ Checklist
 ├─ Category
 ├─ Tags
 ├─ Reminder (اختیاری)
 └─ FollowUps[]
      ├─ DateTime
      ├─ Text/Result
      └─ Next FollowUp (در صورت نیاز)
```

Item منبع حقیقت است. Note و Task نباید دو سیستم داده موازی باشند. FollowUp بخشی از همان Item است.

`Note Timestamp != FollowUp != Next FollowUp != Reminder != Calendar Event`

## 3. وضعیت فعلی مهم

- Unified Item/Task و FollowUp foundation موجودند و نباید از صفر ساخته شوند.
- Calendar foundation موجود است و باید حفظ شود.
- SearchService موجود است و نباید دوباره ساخته شود.
- Backup/Dropbox foundation قبلی باید تکمیل شود، نه بازنویسی.
- CI parallel infrastructure موجود است.
- مسیر Legacy مثل `ArvinTask/TaskRepository` باید با Unified Item مرزبندی و در نهایت تثبیت شود؛ سیستم داده موازی ایجاد نشود.
- `PROJECT_DOCUMENTATION_FA.md` مستند فنی سابق پروژه است؛ این فایل handoff زنده و فشرده است.

## 4. Calendar

Calendar باید شمسی، فارسی، RTL، responsive، دارای تاریخ/ساعت صحیح و بدون overflow باشد.

یادآورهای رسمی موردنظر:

1. اوقات شرعی شیعه بر اساس منبع/داده معتبر مرتبط با مؤسسه ژئوفیزیک دانشگاه تهران.
2. تعطیلات رسمی ایران.

هر دو باید به CalendarReminder فعلی متصل شوند و Storage موازی نسازند. Note timestamp نباید خودکار به Google Calendar منتقل شود.

## 5. Use Case کلیدی — پیگیری زنجیره‌ای یک کار

یک کار اصلی می‌تواند پیگیری‌های متعدد داشته باشد. ثبت پیگیری باید با کمترین کلیک انجام شود:

`Item → + ثبت پیگیری → متن → ذخیره`

تاریخ و ساعت خودکار ثبت و در صورت نیاز قابل ویرایش باشد. برای هر مرحله امکان `Next FollowUp / Reminder` وجود داشته باشد. هدف ثبت پیگیری‌های متعدد بدون ساخت Taskهای جداگانه است.

## 6. Quick FollowUp Widget — مشخصات تثبیت‌شده

Widget اختصاصی پیگیری باید با همان foundation Widget اصلی و بدون Storage جداگانه ساخته شود.

هر ردیف فقط:

- عنوان کار
- تیتر/متن کوتاه آخرین پیگیری
- تاریخ آخرین پیگیری
- ساعت آخرین پیگیری

تاریخ و ساعت در یک خط: `۱۸ مرداد ۱۴۰۵ | 11:20`

Widget باید:

- لیست چندموردی و قابل اسکرول عمودی داشته باشد.
- لمس هر ردیف → باز شدن همان Item.
- Category و امکانات/فیلترهای سازگار Widget اصلی را داشته باشد.
- RTL و هماهنگ با فونت اصلی باشد.
- سبک و کم‌مصرف باشد.
- از همان source of truth Item/FollowUp استفاده کند.
- Storage/Database جدا نسازد.
- در صورت پشتیبانی معماری روی Lock Screen نیز ارائه شود.
- آخرین FollowUp را نشان دهد، نه Reminder بعدی.

### Audit فعلی Widget — 2026-08-15

Audit مستقیم در `main` نشان داد مسیر native فعلی Android در `android/app/src/main` فقط `AndroidManifest.xml` دارد و implementation قطعی `AppWidgetProvider/RemoteViews` در آن وجود ندارد. بنابراین Quick FollowUp Widget نباید با یک implementation موازی و مستقل ساخته شود. گام فنی درست، ایجاد یک Widget Foundation مشترک و کنترل‌شده است؛ سپس Widget اصلی و Quick FollowUp Widget هر دو باید روی همان foundation قرار بگیرند.

همچنین `pubspec.yaml` فعلی Flutter است و dependencyهای اعلان/زمان‌بندی دارد، اما dependency یا plugin مشخصی برای Android App Widget در آن ثبت نشده است. این موضوع باید در طراحی foundation بررسی شود و نباید بدون audit یک dependency جدید اضافه شود.

## 7. Widget اصلی

Widget اصلی باید مبنای UX مشترک باشد: Reminderهای آروین، موارد امروز/آینده/عقب‌افتاده و Category فقط در صورت وجود واقعی در مدل، افزودن سریع `+`، بازکردن مستقیم Item، Refresh سبک، RTL، کم‌مصرف، بدون Database جدا و Lock Screen در scope محصول. قابلیت مصنوعی برای داده‌ای که در مدل نهایی وجود ندارد ساخته نشود.

## 8. Home / Note / FollowUp

Note ساده: عنوان/موضوع، متن، Checklist، CreatedAt/EditedAt، Auto-save، Read-only بعد از خروج، Edit برای تغییر و تنظیم رفتار Read-only/Edit از Settings.

Home: لمس عادی → Read-only؛ Edit برای ویرایش؛ `+`؛ Long Press/Multi-select؛ انتقال گروهی Category/Trash؛ Swipe؛ Sort بر اساس تاریخ، آخرین ورودی و عنوان، با معکوس شدن جهت در فعال‌سازی مجدد.

## 9. Search

SearchService موجود است. Gap مهم اتصال Search UI به Home و مدل نهایی Item است. جستجو باید عنوان، توضیحات، Tags، متن FollowUp و نتیجه FollowUp را پوشش دهد. SearchService از صفر ساخته نشود.

## 10. Print / PDF / Font

Print برای Note ساده، Item دارای FollowUp و در صورت امکان لیست انتخاب‌شده. PDF/Share برای Item + تمام FollowUpها و فهرست‌ها. RTL و تاریخ شمسی الزامی.

فونت اصلی: **IRANSans / IranSansX(Eco)**؛ Vazirmatn فونت اصلی توافق‌شده نیست.

## 11. Backup / Restore / Dropbox

Backup باید کامل، قابل انتقال و قابل Restore روی گوشی دیگر باشد و Item/FollowUp/Category/Tags/Settings را پوشش دهد. Foundation قبلی حفظ شود و Storage موازی ساخته نشود.

## 12. Roadmap اجرایی

- **Lane A — Architecture:** Unified Item + persistence + Legacy boundary.
- **Lane B — Calendar:** Provider تعطیلات رسمی + Provider اوقات شرعی → تست → اتصال به CalendarReminder → regression → APK.
- **Lane C — Notebook:** Note editor + autosave + read-only/edit + checklist + settings.
- **Lane D — Home/Search:** Home واقعی + Sort/Swipe/Multi-select + اتصال SearchService.
- **Lane E — Widget:** Widget Foundation مشترک → Widget اصلی → Quick FollowUp Widget → Lock Screen.
- **Lane F — Output:** PDF + Print + IRANSans.
- **Lane G — Reminder/Calendar Integration:** Reminder واقعی و Google Calendar فقط برای Calendar Event/Reminder.
- **Lane H — Backup/Dropbox:** End-to-End Backup/Restore و انتقال.
- **Lane I — E2E/Release:** تست APK واقعی، regression و release.

Laneهای مستقل در صورت عدم تداخل با foundation می‌توانند موازی اجرا شوند.

## 13. Definition of Done

Domain، Application logic، Persistence، UI، RTL، تاریخ شمسی، فونت لازم، Regression، تست، CI سبز، APK واقعی قابل استفاده و مستندات به‌روز باید همگی وجود داشته باشند.

## 14. Git/CI

Workflowهای اصلی:

- `.github/workflows/build.yml`
- `.github/workflows/parallel-wave.yml`

روش اجباری:

`Audit → Commit → Build + Parallel → بررسی نتیجه → Documentation`

اگر Workflow هنوز نتیجه نداده، نتیجه آن حدس زده نشود.

## 15. آخرین تصمیم‌های مهم

- PR #80 مربوط به Calendar official reminder source contracts در مسیر توسعه قرار گرفت؛ foundation آن نباید دوباره ساخته شود.
- `docs/CALENDAR_OFFICIAL_SOURCE_RESEARCH_2026-08-15.md` برای منابع رسمی Calendar ثبت شده است.
- `docs/QUICK_FOLLOWUP_WIDGET_AUDIT_2026-08-15.md` مشخصات و audit اولیه Quick FollowUp Widget را ثبت کرده است.
- Use Case «پیگیری زنجیره‌ای یک کار» سناریوی رسمی محصول است.
- Audit مستقیم native Android در 2026-08-15 نبودن AppWidgetProvider/RemoteViews را تأیید کرد؛ بنابراین Widget Foundation باید قبل از هر Widget محصولی به‌صورت مشترک و کنترل‌شده ایجاد شود.

## 16. دستور ادامه برای هوش مصنوعی بعدی

از صفر شروع نکن. ابتدا همین فایل، `PROJECT_STATUS.md` و `PROJECT_ROADMAP_2026-08-14.md` را بخوان؛ سپس آخرین commit، PRهای باز، CI و کد واقعی مرتبط را بررسی کن. Foundation موجود را حفظ کن، Gap واقعی را مشخص کن، تغییر حداقلی بده، Commit مستقل بزن، Build و Parallel Workflow را اجرا کن، نتیجه CI را بررسی کن و همین سند و مستندات مرتبط را به‌روز کن.

**هرگز صرفاً برای ادامه دادن کد جدید نساز؛ ابتدا ثابت کن Gap واقعی وجود دارد.**

## تاریخ آخرین به‌روزرسانی

2026-08-15

این فایل باید در هر Wave مهم به‌روزرسانی شود تا برای انتقال پروژه به هوش مصنوعی دیگر قابل استفاده بماند.
