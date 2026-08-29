# Arvin-clean — Current Execution Audit — 2026-08-15

## هدف
این سند snapshot اجرایی فعلی است تا ادامه پروژه برای انسان یا هوش مصنوعی دیگر از روی وضعیت واقعی `main` و CI انجام شود، نه از روی تعداد PRها.

## نتیجه audit قبل از Wave بعدی
- مرجع: `main` و آخرین commit فعلی `e22172611ea8f222f5b99739fecd23a946c23938`.
- Unified Item + FollowUps[] منبع حقیقت باقی می‌ماند؛ Note و Task نباید به دو storage موازی تبدیل شوند.
- Calendar foundation و `CalendarReminder` موجودند و نباید بازسازی شوند.
- `OfficialCalendarReminderService` و Source Contract موجودند؛ Provider واقعی اوقات شرعی و تعطیلات رسمی هنوز Gap محصولی است.
- Android native AppWidgetProvider/RemoteViews در مخزن فعلی وجود ندارد؛ بنابراین Quick FollowUp Widget نباید جداگانه ساخته شود. ابتدا Widget Foundation مشترک لازم است.
- SearchService موجود است و اتصال UI به مدل نهایی هنوز Wave مستقل است.

## Use Case پیگیری زنجیره‌ای
- ثبت چند FollowUp روی همان Item با کمترین کلیک.
- تاریخ/ساعت خودکار و قابل ویرایش.
- Next FollowUp/Reminder جدا از timestamp پیگیری.
- Quick FollowUp Widget: عنوان کار + آخرین پیگیری + تاریخ و ساعت در یک خط؛ لیست اسکرول‌شونده، Category/امکانات سازگار Widget اصلی، بازکردن Item و Lock Screen در صورت پشتیبانی.

## PR audit
چند PR مستنداتی قدیمی هنوز Open هستند. Open بودن آن‌ها به معنی Gap جدید نیست.
- PR #79 مربوط به قرارداد رسمی Calendar است و `mergeable=false` است؛ محتوای آن با مسیر Calendar فعلی/PRهای بعدی superseded شده و نباید دوباره پیاده‌سازی شود.
- PRهای تاریخی #76، #75، #74 و موارد قدیمی‌تر عمدتاً roadmap/audit هستند. قبل از استفاده از هرکدام باید آن را با `main` مقایسه کرد.
- PR #81 قبلاً merge شده و خطای قدیمی package-name آن نباید دوباره اصلاح شود.

## CI
- `Arvin Build` روی push به `main` و PRها اجرا می‌شود.
- `Arvin Parallel Wave` روی PR به `main` و branchهای `wave/**`, `ci/**`, `fix/**` اجرا می‌شود.
- نتیجه Workflow هرگز از روی وضعیت قبلی حدس زده نشود.

## نمودار پیشرفت
برآورد محافظه‌کارانه بر اساس فاصله تا Definition of Done واقعی:

```text
پیشرفت کلی ≈ 61%

0%        20%        40%        60%        80%       100%
|----------|----------|----------|----------|----------|
██████████████████████████████▌░░░░░░░░░░░░░░░░░░░
                              ▲
                             61%
```

| Lane | برآورد |
|---|---:|
| Unified Item / Architecture | 80% |
| Notebook / Note | 65% |
| FollowUp | 70% |
| Home / Search | 55% |
| Calendar Foundation | 70% |
| Prayer + Iranian Holidays Providers | 35% |
| Widget + Lock Screen | 40% |
| PDF / Print / Share | 50% |
| IRANSans | 40% |
| Backup / Dropbox | 55% |
| Reminder / Google Calendar | 45% |
| E2E / APK Release | 45% |

## گام‌های بعدی با بیشترین ارزش
1. Calendar Providerهای واقعی و قابل اعتبارسنجی.
2. Widget Foundation مشترک و قابل تست Android.
3. Quick FollowUp Widget روی همان foundation.
4. FollowUp UX و Home/Search.
5. E2E و APK واقعی.

## قانون دائمی
`Audit کل پروژه → Gap واقعی → تغییر حداقلی → تست focused → Commit → Build + Parallel → بررسی CI → مستندسازی + AI Handoff`

اگر Gap واقعی وجود نداشت، تغییر محصولی انجام نشود.
