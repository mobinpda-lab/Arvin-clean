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
