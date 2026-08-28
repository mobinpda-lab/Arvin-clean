# ثبت خطای CI و وضعیت Search — ۱۴۰۵/۰۵/۲۳

## نتیجه بررسی Runهای 31824305634 و 31824465196 و 31825111187

خطای مشاهده‌شده در Runهای قدیمی Search مربوط به `test/task_search_service_test.dart` بود.

### خطای اول

در نسخه قدیمی PR #67، خطای analyzer زیر وجود داشت:

`const_with_non_const` در خط ۱۸.

علت: استفاده از `const` برای سازنده‌ای که `const` نبود.

این مشکل در Commit `763419a6539657476e6e0d4c2a70c9df3bc44dee` اصلاح شده است.

### خطای دوم

در Run `31825111233`، Analyze کاملاً سبز است و ۴۵ تست اجرا شده که ۴۴ تست سبز و فقط تست زیر قرمز بوده است:

`empty query preserves task order`

پیغام:

`Expected: same instance as [...]`

علت: تست به‌اشتباه identity همان List را انتظار می‌کشید، در حالی که Search Service برای query خالی `List.of(tasks)` برمی‌گرداند؛ یعنی ترتیب حفظ می‌شود ولی یک List جدید ساخته می‌شود.

این مورد نیز در Head فعلی PR #67 اصلاح شده و assertion بر اساس `task.id` و ترتیب قرار گرفته است.

## تصمیم ضد دوباره‌کاری

در نتیجه، برای این خطاها نباید Commit دیگری روی Search Service یا همان assertion ساخته شود، مگر اینکه CI جدید پس از Head فعلی خطای تازه‌ای گزارش کند.

کد سرویس Search عمداً pure است و به UI یا persistence وابستگی ندارد. urlPR #67https://github.com/mobinpda-lab/Arvin-clean/pull/67

## وضعیت مثبت هم‌زمان

در همان CI جدیدتر:

- `flutter analyze`: سبز
- Calendar Jalali: سبز
- Calendar selected-day reminders: سبز
- FollowUp repository: سبز
- FollowUp page: سبز
- Backup/Restore: سبز
- Dropbox provider tests: سبز
- Backup scheduler: سبز
- Widget baseline: سبز

بنابراین هیچ‌یک از این بخش‌ها به دلیل Runهای قدیمی Search نباید دوباره بازنویسی شوند.

## مرحله بعد

بعد از سبزشدن کامل PR #67، Wave بعدی باید **Search UI** باشد؛ اتصال سرویس موجود به Home/Search UI، بدون ساخت سرویس Search دوم و بدون دستکاری Calendar، Backup، Dropbox یا Notebook.

## قانون پروژه

قبل از هر تغییر:

1. main و Head مربوطه بررسی شود.
2. PRهای باز بررسی شوند.
3. CIهای اخیر و خطاهای قدیمی بررسی شوند.
4. قابلیت قبلاً رفع‌شده دوباره پیاده‌سازی نشود.
5. تغییرات کوچک و قابل برگشت باشند.
6. تست همان قابلیت اضافه/اصلاح شود.
7. نتیجه و تصمیم در مستندات ثبت شود.
