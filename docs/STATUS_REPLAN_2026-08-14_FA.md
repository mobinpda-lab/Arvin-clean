# گزارش فشرده وضعیت و برنامه بازنگری آروین

تاریخ: ۱۴۰۵/۰۵/۲۳

## وضعیت کلی

Arvin-clean از مرحله «زیرساخت پراکنده و تست‌های اولیه» عبور کرده و اکنون چند هسته قابل اتکا دارد، اما هنوز به APK نهایی با همه قابلیت‌های محصول نزدیک نشده است. معیار پیشرفت باید قابلیت قابل استفاده در APK باشد، نه تعداد PRها.

## برآورد پیشرفت

| بخش | وضعیت | برآورد |
|---|---|---:|
| Android/Flutter/CI baseline | پایدار و قابل Validation | 90% |
| Task/Tag/Archive/Trash | پایه موجود | 80% |
| FollowUp domain/application/agenda | چند Wave مستقل موجود؛ Integration کامل نیست | 70% |
| FollowUp Office UI | وجود دارد؛ اتصال کامل به Home هنوز مانده | 65% |
| Calendar Jalali | Waveهای responsive و Jalali موجود؛ بازنویسی مجدد فعلاً ممنوع | 85% |
| Simple Notebook domain/storage | foundation موجود | 75% |
| Notebook session policy | موجود و تست‌شده در Wave مستقل | 70% |
| Notebook UI | هنوز Integration کامل نشده | 35% |
| Global Search service | پیاده‌سازی و تست مستقل انجام شده | 95% |
| Global Search UI/Home integration | منتظر حل مرز legacy/new Task model | 20% |
| PDF/Share | در Roadmap؛ پیاده‌سازی نهایی نشده | 10% |
| IRANSans/Font Settings | تصمیم محصول قطعی؛ اعمال سراسری هنوز باید Audit شود | 20% |
| Reminder/Google Calendar | قرارداد مشخص؛ Integration production-ready باقی مانده | 20% |
| Backup/Restore | پایه موجود و تست‌های مرتبط سبز بوده‌اند | 70% |
| Dropbox | Provider/مسیر پایه وجود دارد؛ production integration باقی مانده | 45% |
| E2E / Release APK | هنوز مرحله نهایی نیست | 20% |

**برآورد کلی قابل استفاده برای برنامه‌ریزی: حدود 55–60%.** این عدد تقریبی است و عمداً محافظه‌کارانه محاسبه شده، چون چند قابلیت foundation دارند ولی هنوز در UI اصلی محصول end-to-end نیستند.

## چیزهایی که فعلاً نباید دوباره‌کاری شوند

- Calendar را بازنویسی نکنیم؛ مشکلات responsive و Jalali قبلاً Wave مستقل داشته‌اند.
- Search Service را دوباره نسازیم؛ Wave #67 زیرساخت Search را پوشش می‌دهد.
- خطای `const_with_non_const` تست Search قبلاً رفع شده و اقدام مجدد ممنوع است.
- خطای assertion مربوط به empty query نیز در Head جدید اصلاح شده است.
- Backup/Dropbox را از صفر نسازیم؛ ابتدا implementation موجود Audit و تکمیل شود.
- Simple Notebook foundation را دوباره نسازیم؛ Waveهای #57/#61/#62 مرجع هستند.
- FollowUp Office را دوباره از صفر نسازیم؛ Waveهای #40/#46/#49/#50/#56 مرجع هستند.

## مسئله معماری فعلی

SearchService جدید روی مدل `Task` کار می‌کند، در حالی که HomePage legacy هنوز در بخشی از مسیر خود از `ArvinTask`/`TaskRepository` استفاده می‌کند. بنابراین قبل از Search UI باید Contract و migration/compatibility این دو مسیر روشن شود.

## برنامه موازی بعدی

### Wave A — Task Model Integration

- مشخص‌کردن source of truth.
- حفظ compatibility داده‌های موجود.
- بدون حذف عجولانه legacy.
- تست migration و regression.

### Wave B — Notebook UI

همزمان با Wave A، تا وقتی به مدل Task وابستگی ندارد:

- فهرست Noteها.
- ایجاد Note.
- timestamp خودکار قابل ویرایش.
- save خودکار.
- read-only پس از خروج.
- Edit صریح در مراجعه بعدی.
- Settings toggle.
- عدم ارسال Note به Google/system Calendar.

### Wave C — Search UI

پس از Contract Wave A:

- جستجوی Home.
- Task + FollowUp.
- نتیجه واضح و RTL.
- بدون تغییر Calendar/Backup/Dropbox.

### Wave D — PDF/Share

- PDF یک Task + همه FollowUpها.
- PDF فهرست Taskها.
- Share.
- فارسی/RTL و تاریخ شمسی.

### Wave E — Typography

- اعمال IranSans به‌عنوان فونت اصلی.
- Audit تمام Theme/TextStyleها.
- سپس Settings font selection در صورت نیاز.

### Wave F — Calendar/Reminder Integration

فقط پس از تثبیت Task/FollowUp:

- Reminder مستقل.
- Google Calendar فقط برای Task/FollowUpهای مجاز.
- Note هرگز Calendar Event نسازد.

### Wave G — Dropbox

- Audit Provider فعلی.
- Backup/Restore production.
- Conflict/error handling.
- حفظ داده‌ها و Settings.

### Wave H — Release

- E2E.
- regression.
- release APK.
- artifact قابل نصب.
- تست روی گوشی واقعی.

## قانون دائمی اجرای پروژه

قبل از هر تغییر:

1. main و HEAD واقعی بررسی شود.
2. PRهای باز بررسی شوند.
3. کد مرتبط واقعی بررسی شود.
4. تست‌های مرتبط و خطاهای اخیر بررسی شوند.
5. مستندات و Handoff خوانده شوند.
6. مشخص شود قابلیت قبلاً وجود دارد یا نه.
7. اگر وجود دارد، فقط تکمیل/اتصال/رفع regression انجام شود.
8. Waveهای مستقل به‌صورت موازی Commit و Workflow شوند.
9. هر تصمیم مهم در مستندات ثبت شود.
10. سبزشدن CI شرط لازم است، نه شرط کافی؛ قابلیت باید در APK قابل استفاده باشد.
