# Arvin-clean — Snapshot پیشرفت پروژه — 2026-08-15

## مبنای snapshot
این snapshot پس از بازبینی `docs/PROJECT_STATUS.md`، `docs/AI_HANDOFF_CURRENT_FA.md`، مدل واقعی `Task/FollowUp`، Calendar source contract و CI history روی `main` ثبت شده است. درصدها بر اساس فاصله تا Definition of Done واقعی برآورد شده‌اند و «کد نوشته‌شده» به‌تنهایی معیار نیست.

## نمودار کلی

```text
100% ┤
 90% ┤
 80% ┤
 70% ┤
 60% ┤ ██████████████████████████████░░░░░░░░░░░░░░░░  ≈61%
 50% ┤
 40% ┤
 30% ┤
 20% ┤
 10% ┤
  0% ┼────────────────────────────────────────────────
```

## برآورد Laneها

| Lane | پیشرفت | وضعیت |
|---|---:|---|
| Unified Item / Architecture | 80% | گلوگاه فعال؛ مرزبندی Legacy و migration باید تکمیل شود |
| Notebook / Note UI | 65% | foundation موجود؛ UI و رفتار کامل باید تثبیت شود |
| FollowUp / زنجیره پیگیری | 70% | مدل و foundation موجود؛ UX ثبت سریع و E2E باقی است |
| Home / Search | 55% | SearchService موجود؛ اتصال به Home و UX کامل باقی است |
| Calendar Foundation | 70% | foundation و قرارداد CalendarReminder تثبیت شده |
| اوقات شرعی + تعطیلات رسمی ایران | 35% | Provider واقعی هنوز Lane فعال است؛ داده حدسی وارد production نمی‌شود |
| Widget + Lock Screen | 40% | قرارداد محصول مشخص؛ Widget Foundation native هنوز Gate است |
| PDF / Print / Share | 50% | نیازمند تکمیل E2E و فونت/RTL/شمسی |
| IRANSans / IranSansX | 40% | یکپارچه‌سازی UI/Widget/Output باقی است |
| Google Calendar / Reminder | 45% | باید فقط برای Reminder/Event واقعی تکمیل شود |
| Backup / Restore / Dropbox | 55% | foundation موجود؛ End-to-End باقی است |
| E2E / APK Release | 45% | release validation و سناریوهای واقعی باید کامل شوند |

## پیشرفت کلی

**حدود 61٪** — برآورد محافظه‌کارانه بر اساس Definition of Done.

این snapshot عمداً درصد را افزایش نمی‌دهد؛ audit و سبز بودن CI به‌تنهایی قابلیت محصولی را Done نمی‌کند. افزایش درصد فقط با بستن Gap واقعی و عبور از Definition of Done انجام می‌شود.

## آخرین audit اجرایی

- Unified Item و `FollowUps[]` همچنان منبع حقیقت هستند؛ مدل یا Storage موازی ساخته نمی‌شود.
- Calendar foundation و `OfficialCalendarReminderService` موجودند؛ Provider واقعی هنوز Gap است.
- منبع مورد توافق اوقات شرعی، مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران است. بررسی وب عمومی فعلی فقط برای cross-check انجام شد و هیچ داده شخص ثالثی به‌عنوان source of truth وارد کد نشد.
- برای تعطیلات رسمی ۱۴۰۵، منابع عمومی چند فهرست نزدیک به هم ارائه می‌کنند اما به دلیل اختلاف جزئی در برخی شمارش‌ها/تاریخ‌های منتشرشده، hard-code کردن داده بدون اعتبارسنجی نسخه رسمی ممنوع باقی می‌ماند.
- Widget audit قبلی همچنان معتبر است: ابتدا Widget Foundation مشترک Android، سپس Widget اصلی و Quick FollowUp Widget.
- Quick FollowUp Widget: عنوان کار + آخرین پیگیری + تاریخ/ساعت در یک خط + لیست اسکرول‌شونده + Category/امکانات سازگار Widget اصلی + Lock Screen در صورت پشتیبانی + بدون Storage موازی.

## گلوگاه‌های فعلی

1. Unified Item adapter/migration بدون شکستن Legacy.
2. Provider واقعی اوقات شرعی شیعه و تعطیلات رسمی ایران.
3. Widget Foundation مشترک Android؛ سپس Widget اصلی و Quick FollowUp Widget.
4. UX ثبت سریع FollowUp و E2E.

## Quick FollowUp Widget — قرارداد تثبیت‌شده

- عنوان کار
- تیتر/متن کوتاه آخرین پیگیری
- تاریخ و ساعت آخرین پیگیری در یک خط
- لیست چندموردی قابل اسکرول
- Category و امکانات سازگار Widget اصلی
- لمس هر ردیف → همان Item
- بدون Storage/Database موازی
- RTL و فونت اصلی
- Lock Screen در صورت پشتیبانی
- نمایش آخرین FollowUp، نه Reminder بعدی

## قانون ادامه

`Audit کل پروژه → Gap واقعی → تغییر حداقلی → تست → Commit → Build + Parallel Workflow → بررسی CI → به‌روزرسانی Status و AI Handoff`

اگر foundation موجود است، تکمیل می‌شود و از ساخت دوباره آن جلوگیری می‌شود. اگر Gap واقعی وجود ندارد، Commit ساختگی ایجاد نمی‌شود.

## تاریخ به‌روزرسانی

2026-08-15
