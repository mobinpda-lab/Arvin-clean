Wave 2 product fast-track branch is active from current main.

Current slice:
- canonical editor context coordinator added
- product guard tests added
- no second Task persistence model introduced

Next required implementation step: wire the coordinator into the existing Home add/edit path, then run exact-head Analyze/Test/Build/Device Smoke.


## وضعیت محصول و دروازه‌های تحویل — ۱۴۰۵/۰۸/۱۶

- شاخه مجاز PR #3052 در SHA `52ecbef18d7bbc26d2915270e28297d272342634` اصلاحات responsive Calendar و Task Editor، کلیدهای پایدار ایجاد مرکز/دسته در Quick Add، راهنمای زمینه‌ای Calendar و هم‌ترازی قراردادهای آزمون را دریافت کرده است.
- شکست‌های واقعی ثبت‌شده روی SHA قبلی `d2e27baea747ddedf42f744297be09ab86753294`: سرریز ۴dp سلول ماه Calendar و سرریز ۵۳dp فرم Task Editor؛ اصلاح کد برای هر دو ثبت شده، اما تأیید مجدد لازم است.
- Build قدیمی run `42335681385`: شش شارد با مجموع ۱۲۳۴ موفق / ۲۴ ناموفق؛ Analyze و Visual موفق. نتیجه این SHA برای HEAD جدید معتبر نیست.
- در HEAD فعلی: Build `42336933347` و Device Smoke `42336933508` هنوز PENDING و بدون Job؛ Draft Review APK `42336933225` و Calendar Provider `42336933308` و Follow-up Persistence `42336934664` در حال اجرا هستند.
- گیت نصب واقعی روی گوشی، آزمون Device Smoke کامل و پذیرش مالک محصول هنوز اثبات نشده‌اند. نصب/انتشار مجاز نیست.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاحیه دفتر وضعیت محصول — ۱۴۰۵/۰۸/۱۶

- آخرین commit کد/آزمون در این چرخه: `0d6ac9f44debc6ca6955f8940826979604f3636b`.
- همگام‌سازی اسناد پیوستگی در commit `d1bb22e36d63bd0ac00980f0a9df4eee0214d2b4` ثبت شد؛ این commit صرفاً مستندات است. همگام‌سازی همین دفتر وضعیت نیز commit بعدی خواهد بود و به‌خودی‌خود نتیجهٔ CI را تغییر نمی‌دهد.
- Build شکست‌خوردهٔ `42335681385` متعلق به SHA قدیمی `d2e27baea747ddedf42f744297be09ab86753294` است. اصلاحات پس از آن باید روی HEAD نهایی دوباره اجرا شوند.
- Release فقط پس از Build/Analyze/تمام شش شارد PASS، Device Smoke کامل، Provider و Persistence PASS روی همان SHA و پذیرش نصب روی گوشی واقعی قابل بازنگری است.
- وضعیت فعلی: **BLOCKED — RELEASE: NO-GO**؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched.


## آخرین اصلاحیه وضعیت محصول — ۱۴۰۵/۰۸/۱۶

- آخرین تغییر کد/آزمون در این چرخه: `467e7f76aced41a123f00a99dd334f32f09ad70c`. ثبت پیوستگی پس از آن در `16c1fc90e1f5e23cbefdb9966680ee4719aa7549` انجام شد.
- آزمون Quick Capture اکنون بازماندن عمدی فرم بعد از ثبت را رعایت می‌کند و پس از بستن فرم، نمایش Task در Home را بررسی می‌کند. پیمایش تست کارت Home نیز به viewport اصلی محدود شده است.
- این دفتر وضعیت در commit بعدی همگام می‌شود. هیچ PASS از اجرای قبلی به SHA جدید منتقل نمی‌شود؛ Build و Device Smoke کامل و پذیرش گوشی واقعی همچنان الزامی‌اند.
- **BLOCKED — RELEASE: NO-GO**؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ Merge و انتشار ممنوع.


## اصلاحیهٔ نهایی هدف لمس Quick Add — ۱۴۰۵/۰۸/۱۶

- commit کد/آزمون: `c0b3715f16b4fd46e67a2c157559f1de71e2d812`.
- کنترل‌های چهارگانهٔ اولویت Quick Add اکنون ۴۸dp ارتفاع دارند؛ آزمون responsive در ۳۶۰/۳۹۰/۴۱۲dp و مقیاس متن بزرگ، حداقل عرض و ارتفاع ۴۸dp را برای هر گزینه بررسی می‌کند.
- این دفتر وضعیت در commit بعدی همگام می‌شود. CI و Device Smoke باید روی HEAD نهایی آن commit دوباره ارزیابی شوند؛ آزمون واقعی گوشی و پذیرش هنوز مانع انتشارند.
- **BLOCKED — RELEASE: NO-GO**؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched.
