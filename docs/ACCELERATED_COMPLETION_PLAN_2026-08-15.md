# برنامه شتاب‌دهی تکمیل آروین — 2026-08-15

## Audit قبل از تغییر
- `main` فعلی بررسی شد.
- PRهای باز و اسناد roadmap/AI handoff بررسی شدند.
- مدل فعلی `Task` بررسی شد؛ `FollowUp[]` و `isSimpleNote` از قبل در مدل وجود دارند.
- Widget implementation با جستجوی repository بررسی شد؛ پیاده‌سازی native widget فعلی پیدا نشد، بنابراین Widget نباید با حدس یا storage دوم ساخته شود.
- SearchService موجود است و دوباره‌سازی نمی‌شود.
- Notebook foundation/application/session policy موجود است و دوباره‌سازی نمی‌شود.

## تصمیم نهایی Item / Note / FollowUp
یک Item واحد داریم:

`Item -> Simple Note -> Enable FollowUp -> FollowUp-enabled Item`

یادداشت و کار دو رکورد موازی نیستند. FollowUpها در همان Item نگهداری می‌شوند.

### Note
- موضوع/عنوان و متن
- تاریخ/ساعت سیستم هنگام ایجاد
- تاریخ/ساعت قابل ویرایش
- auto-save
- پس از خروج read-only
- ویرایش فقط با Edit
- Checklist
- تاریخ Note فقط داخل Arvin؛ عدم ارسال به Google Calendar یا system calendar

### FollowUp
- تاریخ/ساعت سیستم به‌صورت پیش‌فرض
- قابل ویرایش توسط کاربر
- note/result/nextFollowUp
- تاریخچه کامل
- آخرین FollowUp در Home

## Widget Contract
Widget باید سبک و کم‌مصرف باشد و از همان منبع داده اصلی Arvin استفاده کند.

### نمایش
- موارد امروز، آینده و عقب‌افتاده فقط بر اساس داده/فیلترهای واقعی موجود در محصول.
- اگر Category/Today/Overdue در مدل یا UI نهایی وجود نداشته باشد، Widget نباید فیلتر مصنوعی ایجاد کند.
- نمایش خلاصه عنوان + زمان/وضعیت مرتبط.

### تعامل
- دکمه `+` برای ایجاد سریع Item.
- لمس Item برای بازکردن همان Item در Arvin.
- بدون storage یا دیتابیس مستقل.
- refresh محدود و سبک در background؛ بدون polling دائمی.
- RTL و فونت اصلی IRANSans در خروجی قابل مشاهده.

### اصل ضد دوباره‌کاری
قبل از پیاده‌سازی native widget، باید Android app structure و Flutter/native bridge فعلی audit شود و فقط کمترین integration لازم اضافه شود.

## Print Contract
Print یک قابلیت مستقل از PDF/Share است.
- Note ساده قابل چاپ است.
- Item پیگیری‌دار همراه همه FollowUpها قابل چاپ است.
- فهرست موارد قابل چاپ است.
- RTL، فارسی، تاریخ شمسی و IRANSans باید رعایت شوند.
- Note print هیچ Calendar Event ایجاد نمی‌کند.

## Waveهای شتاب‌یافته
### Wave 1 — Item Contract Guardrail
تست regression برای Simple Note/FollowUp و migration legacy.

### Wave 2 — Home/Repository Integration Gate
یکپارچه‌سازی مسیر `Task` جدید و `ArvinTask/TaskRepository` بدون ایجاد storage موازی.

### Wave 3 — Notebook UI
UI، auto-save، read-only/edit، Checklist و Settings.

### Wave 4 — Home UX + Search UI
اتصال SearchService موجود، Sort، Swipe، Long Press و Multi-select.

### Wave 5 — Widget
Native Android widget با منبع داده مشترک و `+`.

### Wave 6 — PDF + Print
خروجی Note و FollowUp و فهرست.

### Wave 7 — IRANSans End-to-End
UI، Widget، PDF و Print.

### Wave 8 — Reminder / Google Calendar
Reminder واقعی از timestamp Note جدا بماند؛ Note به Calendar نرود.

### Wave 9 — Backup / Restore / Dropbox
End-to-End با حفظ همه داده‌های Item/FollowUp/Note/Settings.

### Wave 10 — E2E + APK Release
Build قابل نصب، smoke test و release artifact.

## Definition of Done
قابلیت فقط زمانی Done است که domain + persistence + UI + test + CI + APK واقعی آن را پوشش دهند و مستندات/AI handoff به‌روز باشد.

## قانون دائمی اجرا
قبل از هر تغییر: audit کل پروژه -> PRهای باز -> CI اخیر -> کد واقعی -> مستندات -> تشخیص Gap -> تغییر حداقلی -> تست -> مستندسازی -> Commit -> Workflowهای موازی.

اگر یک مشکل قبلاً رفع شده باشد، هیچ تغییر تکراری روی آن انجام نمی‌شود.
