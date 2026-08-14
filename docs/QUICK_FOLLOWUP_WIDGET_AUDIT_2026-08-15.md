# Quick FollowUp Widget — Audit & Implementation Plan — 2026-08-15

## Audit rule
قبل از هر تغییر، main، کد واقعی مرتبط، PRهای باز، CI اخیر و مستندات بررسی می‌شوند. قابلیت موجود دوباره ساخته نمی‌شود و foundation مشترک بدون دلیل تغییر نمی‌کند.

## Audit result
- `docs/PROJECT_STATUS.md` و `docs/PROJECT_ROADMAP_2026-08-14.md` بررسی شدند.
- مدل محصول همچنان Unified Item با `FollowUps[]` است.
- قرارداد محصولی Quick FollowUp Widget قبلاً ثبت شده است و باید از همان source of truth `Item/FollowUp` استفاده کند.
- در مسیر `android/app/src/main` فعلاً فقط `AndroidManifest.xml` مشاهده شد.
- مسیرهای native معمول `android/app/src/main/kotlin` و `android/app/src/main/java` در مخزن فعلی وجود ندارند.
- جست‌وجوی فعلی برای `AppWidgetProvider`/`RemoteViews` نیز implementation native موجودی را نشان نداد.

## نتیجه معماری
در وضعیت فعلی، ساخت «Widget دوم» بدون ساختن foundation واقعی Widget می‌تواند باعث مسیر موازی و ناسازگار شود. بنابراین ابتدا باید یک Android Widget foundation حداقلی و source-neutral ایجاد شود؛ سپس Widget عمومی و Quick FollowUp Widget هر دو روی همان foundation پیاده شوند.

## Quick FollowUp Widget contract
- عنوان کار
- تیتر/متن کوتاه آخرین پیگیری
- تاریخ و ساعت آخرین پیگیری در یک خط: `تاریخ | ساعت`
- لیست چند Item با اسکرول عمودی در صورت پشتیبانی اندازه Widget
- لمس هر ردیف → بازکردن همان Item
- Category و سایر فیلترها/امکانات مشترک Widget اصلی، فقط در صورت وجود واقعی در مدل
- آخرین FollowUp، نه Reminder بعدی
- بدون Database/Storage جدا
- RTL و فونت اصلی پروژه
- refresh محدود و کم‌مصرف
- Lock Screen در صورت پشتیبانی Android/Launcher و graceful fallback در غیر این صورت

## Implementation lanes
1. Android Widget foundation: provider/receiver, update contract, deep-link contract.
2. Shared Item/FollowUp projection برای Widget بدون Storage جدید.
3. Generic Widget و Quick FollowUp Widget روی foundation مشترک.
4. Scroll/category/filter compatibility tests.
5. Lock Screen compatibility validation.
6. APK/device validation.

## Safety gate
تا قبل از تأیید foundation واقعی، implementation دوم Widget به‌صورت موازی ساخته نمی‌شود. این تصمیم برای جلوگیری از دوباره‌کاری و ایجاد دو مسیر Widget مستقل ثبت شده است.

## Next commit
اولین تغییر کدنویسی باید فقط foundation مشترک Android Widget را اضافه کند و تست‌های contract آن را داشته باشد؛ پس از سبز شدن CI، Quick FollowUp rendering به‌عنوان commit مستقل اضافه می‌شود.
