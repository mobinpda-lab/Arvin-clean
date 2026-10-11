# Arvin-clean — Progress Snapshot B — 2026-08-15

## مبنای snapshot
این snapshot پس از audit دوباره `main`، `PROJECT_STATUS.md`، `AI_HANDOFF_CURRENT_FA.md` و آخرین Workflowهای GitHub تهیه شده است. هدف آن ثبت وضعیت قابل انتقال برای ادامه کار و جلوگیری از اختلاف در برآورد پیشرفت است.

## وضعیت کلی
**برآورد پیشرفت کلی: حدود 61٪**

این درصد بر اساس فاصله هر Lane تا Definition of Done واقعی است؛ صرف وجود foundation یا CI سبز به معنی تکمیل قابلیت نیست.

```text
0%        20%        40%        60%        80%       100%
|----------|----------|----------|----------|----------|
██████████████████████████████▌░░░░░░░░░░░░░░░░░░░
                              61%
```

| Lane | برآورد |
|---|---:|
| Unified Item / Architecture | 80٪ |
| Notebook / Note | 65٪ |
| FollowUp / زنجیره پیگیری | 70٪ |
| Home / Search | 55٪ |
| Calendar Foundation | 70٪ |
| اوقات شرعی + تعطیلات رسمی ایران | 35٪ |
| Widget + Lock Screen | 40٪ |
| PDF / Print / Share | 50٪ |
| IRANSans | 40٪ |
| Backup / Restore / Dropbox | 55٪ |
| Google Calendar | 45٪ |
| E2E / APK Release | 45٪ |

## وضعیت CI تاییدشده
آخرین Workflow مستند‌شده برای snapshot قبلی، `Arvin Build #323` روی commit `10bc67b236c4436df04c53d624d14ae2b26c1f25` است و نتیجه آن **success** ثبت شده است.

## گلوگاه‌های فعال
1. **Gate A — Unified Item / Legacy boundary:** تکمیل adapter/migration بدون ایجاد مسیر داده موازی.
2. **Gate D — Calendar official providers:** اتصال Provider واقعی اوقات شرعی شیعه و تعطیلات رسمی ایران به `CalendarReminder` موجود.
3. **Gate E — Widget Foundation:** native AppWidget foundation هنوز در `main` تثبیت نشده؛ Quick FollowUp Widget نباید مستقل ساخته شود.

## قرارداد Quick FollowUp Widget
- عنوان کار
- تیتر/متن کوتاه آخرین FollowUp
- تاریخ و ساعت آخرین FollowUp در یک خط
- لیست چندموردی قابل اسکرول عمودی
- Category و امکانات/فیلترهای سازگار Widget اصلی
- لمس ردیف → همان Item
- RTL و فونت اصلی
- بدون Storage/Database جدا
- Lock Screen در صورت پشتیبانی Android/Launcher
- نمایش آخرین FollowUp، نه Reminder بعدی

## مسیر سرعت‌بخشی
Laneهای مستقل Calendar، FollowUp UX، Notebook/Home و آماده‌سازی تست‌ها می‌توانند موازی آماده شوند؛ اما Widget و هر تغییر در مدل Unified Item فقط پس از audit foundation مشترک انجام می‌شود.

## قانون دائمی
`Audit کل پروژه → Gap واقعی → تغییر حداقلی → تست focused → Commit → Build + Parallel → بررسی CI → Documentation + AI Handoff`

اگر قابلیت قبلاً وجود دارد، دوباره ساخته نشود. اگر Workflow هنوز نتیجه نداده، موفق/ناموفق بودن آن حدس زده نشود.
