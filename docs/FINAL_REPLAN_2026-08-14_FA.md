# بازنگری نهایی برنامه تکمیل آروین — ۱۴۰۵/۰۵/۲۳

## 1) اصل مرجع
`Arvin-clean` منبع حقیقت است. قبل از هر تغییر باید main، کد واقعی، PRهای باز، CI اخیر و مستندات بررسی شود. پروژه‌های `arvin-task-tracker` و `daftar-peygiri` فقط منبع تجربه هستند و نباید باعث copy یا ساخت مسیر موازی شوند.

## 2) مدل نهایی محصول
مدل محصولی مورد توافق:

`Item → Note ساده → فعال‌سازی FollowUp → همان Item پیگیری‌دار`

Item پایه شامل عنوان/موضوع، متن، تاریخ/ساعت ایجاد، تاریخ/ساعت قابل ویرایش، Checklist در صورت نیاز، Category/Tag و قابلیت‌های اختیاری مانند Reminder است.

FollowUp یک تاریخچه روی همان Item است و شامل timestamp خودکار سیستم، timestamp قابل ویرایش توسط کاربر، متن/یادداشت، نتیجه و next-follow-up است.

تفکیک الزامی:
- timestamp یادداشت ≠ FollowUp
- FollowUp ≠ next-follow-up
- Reminder ≠ Calendar Event
- timestamp یادداشت به Google Calendar یا تقویم سیستم ارسال نمی‌شود.

## 3) Notebook / یادداشت ساده
- موضوع/عنوان + متن
- تاریخ و ساعت سیستم هنگام ایجاد
- امکان ویرایش تاریخ/ساعت
- Auto-save
- خروج از Editor → Read-only
- مراجعه بعدی → فقط با دکمه Edit قابل ویرایش
- Checklist
- رفتار Read-only/Edit قابل فعال/غیرفعال شدن از Settings
- تاریخ یادداشت فقط داخل آروین نگهداری شود
- Print برای یادداشت ساده الزامی است

Foundation فعلی Notebook در PRهای #57 و #61 و session policy در #62 ثبت شده است؛ این foundation نباید دوباره ساخته شود، فقط باید UI و Integration نهایی شود.

## 4) FollowUp
- ثبت در هر لحظه
- تاریخ/ساعت خودکار از سیستم
- ویرایش تاریخ/ساعت توسط کاربر
- متن/نتیجه
- next-follow-up مستقل
- تاریخچه کامل و chronological
- آخرین پیگیری در Home همراه ساعت/دقیقه
- ویرایش و حذف
- FollowUp Office فارسی/RTL

PRهای #40، #49، #50 و #56 و مسیرهای قبلی مرجع implementation موجود هستند. فقط Gap واقعی Integration و UI نهایی ادامه یابد.

## 5) Home و UX
Home باید لیست Itemها باشد و Note ساده و Item پیگیری‌دار را در یک مدل نمایش دهد.

نیازمندی‌ها:
- لمس عادی = نمایش Read-only
- Edit با دکمه جداگانه
- عنوان، توضیحات، آخرین FollowUp و زمان آن
- Search
- Sort بر اساس تاریخ، آخرین ورودی، عنوان
- تکرار Sort جهت را معکوس کند
- Long Press برای Multi-select
- عملیات گروهی Category/Trash/Archive
- Swipe چپ/راست قابل تنظیم از Settings
- + پایین صفحه
- منوی جداکننده Noteها، FollowUpها، امروز، آینده، عقب‌افتاده، Archive، Trash، Category، Tag، Search، Reports، Backup/Restore و Settings

### گیت مهم
SearchService موجود است و نباید دوباره ساخته شود. قبل از اتصال Search UI باید مرز مدل جدید `Task` و مسیر Legacy `ArvinTask/TaskRepository` حل شود تا دو منبع داده موازی ایجاد نشود.

## 6) Calendar و Reminder
Calendar فعلی سابقه Jalali/RTL و responsive regression fixes دارد. بازنویسی Calendar ممنوع مگر یک regression واقعی یا نیاز محصولی جدید ثابت شود.

Reminder باید از timestamp Note جدا باشد.

Google Calendar فقط برای Event/Reminderهایی که محصول صریحاً اجازه می‌دهد استفاده شود؛ Note به آن ارسال نشود.

## 7) Widget — مشخصات نهایی
Widget بخشی از محصول نهایی است.

### نمایش
- موارد امروز
- موارد عقب‌افتاده
- موارد آینده/نزدیک‌ترین Reminder یا FollowUp
- نمایش فشرده عنوان + تاریخ/ساعت + وضعیت لازم
- در صورت وجود واقعی Category و Tag در مدل نهایی، امکان فیلتر/نمایش آنها
- اگر Today/Overdue/Category در مدل نهایی وجود نداشت، Widget نباید قابلیت مصنوعی یا مسیر داده جدا بسازد.

### تعامل
- دکمه `+` برای افزودن سریع Item
- لمس مورد → بازکردن مستقیم همان Item
- در صورت تنظیمات تعامل غیرفعال → Widget فقط نمایشی

### فنی
- سبک و کم‌مصرف
- بدون Database/Storage مستقل
- منبع حقیقت همان Item/Reminder/FollowUp اصلی
- refresh محدود و کم‌هزینه در پس‌زمینه؛ بدون polling سنگین
- مقاوم در برابر stale data و تغییرات lifecycle اندروید
- RTL و IRANSans

Widget باید بعد از تثبیت Home/Item contract تکمیل شود؛ foundation قابل استفاده قبلی باید حفظ شود.

## 8) PDF و Print
### PDF
- PDF یک Item پیگیری‌دار + تمام FollowUpها
- PDF یک Note ساده
- PDF فهرست Itemها
- Share خروجی
- RTL، فارسی، شمسی، IRANSans

### Print
Print مسیر مستقل از PDF است و باید با Android Print Service کار کند.

- چاپ Note ساده: عنوان، متن، Checklist، تاریخ/ساعت
- چاپ Item پیگیری‌دار: اطلاعات Item + همه FollowUpها
- چاپ فهرست موارد، در صورت وجود انتخاب گروهی/فهرست
- RTL، فارسی، شمسی، IRANSans

## 9) Typography
تصمیم نهایی: IRANSans / IranSansX(Eco) به‌عنوان فونت اصلی، با فایل مجاز ارائه‌شده توسط کاربر.

نباید Vazirmatn را دوباره به‌عنوان فونت اصلی جایگزین کرد.

اعتبارسنجی باید در UI، Widget، PDF و Print انجام شود.

## 10) Backup / Restore / Dropbox
Backup باید قابل انتقال به گوشی دیگر باشد و این داده‌ها را حفظ کند:
- Item/Note
- FollowUp
- Category
- Tag
- Reminder/configuration
- Settings

Dropbox برای انتقال/نگهداری Backup استفاده شود و مسیر provider موجود بررسی شود؛ سیستم دوم ساخته نشود.

## 11) ترتیب اجرای Waveهای تکمیل
### Wave A — Architecture Gate
تطبیق مدل جدید Item با `Task` موجود، Legacy `ArvinTask`، Notebook storage و FollowUp persistence. بدون تغییر غیرضروری.

### Wave B — Notebook UI
Editor، Auto-save، Read-only/Edit، Checklist، Settings integration.

### Wave C — Home Integration
یکپارچه‌سازی Item، Note و FollowUp، آخرین پیگیری، Sort، Swipe، Multi-select و منو.

### Wave D — Search UI
اتصال SearchService موجود به Home و بخش‌های مرتبط.

### Wave E — Widget
تکمیل Widget روی منبع اصلی داده، + سریع، Today/Overdue/Upcoming در صورت وجود، background سبک.

### Wave F — PDF + Print
هر دو Note و Item پیگیری‌دار، سپس فهرست.

### Wave G — Typography
IRANSans End-to-End و PDF/Print/Widget.

### Wave H — Reminder + Google Calendar
با isolation کامل Note.

### Wave I — Backup + Dropbox
End-to-End و Restore واقعی.

### Wave J — Release / APK
E2E، regression، build release، artifact قابل نصب و گزارش نسخه.

## 12) اجرای موازی
سطوح مستقل CI باید با `fail-fast=false` اجرا شوند. Parallel Wave فقط برای کارهای واقعاً مستقل است. وابستگی‌های معماری ابتدا به‌عنوان Gate بررسی می‌شوند.

در هر Wave:
1. Audit کلی پروژه
2. تشخیص اینکه مشکل قبلاً حل شده یا نه
3. تغییر حداقلی
4. focused tests
5. commit مستقل
6. workflowهای موازی
7. بررسی CI
8. مستندسازی تغییر

## 13) موارد ممنوع از دوباره‌سازی
- Calendar foundation و responsive fixes موجود
- FollowUp application/agenda/office foundation
- Notebook domain/storage/application/session foundation
- SearchService
- Backup foundation
- Dropbox provider/foundation
- Typography preference foundation
- CI parallel infrastructure

## 14) Definition of Done نهایی
قابلیت فقط وقتی Done است که در APK واقعی قابل استفاده باشد، persistence واقعی داشته باشد، UI به مدل اصلی متصل باشد، RTL/شمسی/IRANSans را رعایت کند، regression نداشته باشد، CI سبز باشد و مستندات و AI handoff به‌روز شده باشند.

## 15) وضعیت اجرایی
اولویت فعلی: **Architecture Gate برای Item/Task/Notebook/FollowUp**.

تا وقتی این Gate تأیید نشده، Search UI و Home Integration نباید با یک مسیر داده جدید ساخته شوند.

در عین حال Notebook UI و سایر کارهای کاملاً مستقل می‌توانند به‌صورت جداگانه آماده شوند؛ پس از Gate، Widget، PDF/Print، Typography، Calendar integration، Dropbox و Release به ترتیب اجرا می‌شوند.
