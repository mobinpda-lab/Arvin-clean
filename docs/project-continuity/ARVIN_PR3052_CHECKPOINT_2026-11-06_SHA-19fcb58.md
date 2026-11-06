# نقطه تداوم اجرایی PR #3052 — ممیزی Exact-SHA
**تاریخ:** ۱۴۰۵/۰۸/۱۵ — ۲۳:۳۰ به وقت ایران  
**Repository:** mobinpda-lab/Arvin-clean  
**Branch مجاز:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052  
**SHA ممیزی‌شده:** `19fcb58e17f51624dd69b1047f7ddfcbeec77c5a`  
**main/base SHA مشاهده‌شده:** `45e4202b03a434459e4c021a04efa7e8396359db`

## کنترل هویت و حاکمیت
- HEAD شاخه و HEAD PR در زمان ممیزی دقیقاً برابر SHA بالا بودند.
- PR OPEN / DRAFT / UNMERGED بود؛ هیچ Merge انجام نشد.
- هیچ تغییری روی main انجام نشد.
- تمام نتایج این سند فقط به SHA مبنا تعلق دارند و با هر commit جدید منقضی می‌شوند.

## شواهد دقیق CI روی SHA مبنا

| مسیر | Run | نتیجه | شواهد |
|---|---:|---|---|
| Build | 42282761205 (#9993) | FAILURE | Analyze و APK jobs موفق؛ هر ۶ test shard شکست |
| Draft Review APK | 42282761255 (#803) | SUCCESS | APK واقعی، امضای v2/v3، فونت Vazirmatn و manifest بررسی شد |
| Calendar Provider | 42282761379 (#2131) | SUCCESS | ۲ آزمون Instrumentation موفق؛ CRUD واقعی Provider |
| Device Smoke | 42282761181 (#7229) | PENDING | هنوز Job و Artifact وجود ندارد؛ پذیرش نشده |

### Build — شکست آزمون‌ها، نه خطای کامپایل
Analyze و Android V2 audit موفق شدند. ساخت Debug، Release و Staging APK نیز در Jobهای مربوطه موفق شد. شش Shard آزمون شکست خوردند:
- test-0: ۲۹۶ موفق، ۸ ناموفق
- test-1: ۱۸۳ موفق، ۱ ناموفق
- test-2: ۲۹۶ موفق، ۸ ناموفق
- test-3: ۱۴۰ موفق، ۲ ناموفق
- test-4: ۲۳۲ موفق، ۳ ناموفق
- test-5: ۱۷۰ موفق، ۱ ناموفق

جمع ثبت‌شده: ۱۳۱۷ موفق و ۲۳ ناموفق. هیچ تستی حذف یا تضعیف نشده است.

### خوشه‌های مستقل شکست
**Calendar**
- `calendar_view_modes_test.dart`: ارتفاع واقعی نمای ماه ۳۴۲dp است، درحالی‌که تست فعلی سقف کمتر از ۲۸۰dp را مطالبه می‌کند؛ در همان سناریو خطاهای Render نیز ثبت شده‌اند.
- `calendar_page_test.dart`: آزمون جابه‌جایی افقی روز/هفته/ماه نیز با خطای Render شکست خورد.
- یک assertion تاریخ در حالت RTL دو نمونه به‌جای یک نمونه پیدا کرد.
- این موارد مستقل از Build/کامپایل‌اند. کاهش اندازه لمس برای سبزکردن تست بدون ارزیابی دسترس‌پذیری مجاز نیست.

**Reports**
- آزمون پنل فیلتر Report Center متن «بازه دقیق» را در سطح مورد انتظار پیدا نکرد.
- آزمون نمایش ردیف‌های فعالِ منتظر پاسخ برای اشخاص شکست خورد.
- آزمون تعداد Chipهای فیلتر فعال، ۵ مورد پیدا کرد درحالی‌که ۶ مورد انتظار بود.
- این شکست‌ها مستقل از Calendar و از خطای کامپایل قدیمی هستند.

**Home و فرم‌ها**
- چند آزمون، کلید `home-compact-filter-scroll` را پیدا نکردند.
- آزمون فرم کامل Task یک RenderFlex overflow به اندازه ۵۳ پیکسل در راست ثبت کرد.
- Quick Add گزینه «ایجاد جدید» را در آزمون مربوط پیدا نکرد.
- آزمون‌های Category/Project و Home theme نیز شکست ثبت کردند.

## APK واقعی — فقط برای بازبینی و نصب آزمایشی
Artifact: `arvin-review-staging-apk-19fcb58e17f51624dd69b1047f7ddfcbeec77c5a`  
Artifact ID: `13536322099`  
Run: `42282761255`  
اندازه ZIP: 39,136,828 بایت  
SHA-256 آرشیو ZIP: `7d9c67667dbacef78c03df1c0d24ea149cdb6f79c9d69e01adfeaa24e78ee41a`

APK داخلی: `Arvin-review-staging-19fcb58e17f51624dd69b1047f7ddfcbeec77c5a.apk`  
اندازه APK: 79,038,285 بایت  
**SHA-256 خود فایل APK:** `44f1908cdb47571229e96b78efc9a52e7953900cdd9433a55a220d2a6dee8fcd`  
Application ID: `com.example.arvin.staging`  
`android_debuggable=false`  
امضای v2: تأیید شد؛ v3: تأیید شد.  
گواهی امضاکننده: `b68c939fbe6454b141532192c46f01aefea46a784cd747eddc494cc1c76d5a7e`  
فونت‌های موجود در APK: Vazirmatn-Regular.ttf، Vazirmatn-Medium.ttf، Vazirmatn-Bold.ttf.  
کلید امضا موقت و مخصوص Review است؛ `publishable=false` و این APK نسخه انتشار نیست.

## Calendar Provider
Artifact ID: `13536891873`  
ZIP SHA-256: `e0131131d86f0acd795abbd0498c88c52caaa2258d75f6351e126ab52fdc478f`  
Exact checkout SHA تأیید شد. CREATE، NO-OP UPDATE بدون duplicate، UPDATE روی همان event و DELETE موفق شدند؛ حذف event، Task canonical را حذف نکرد. دو آزمون Instrumentation موفق شدند. این مدرک، Device Smoke یا نصب روی گوشی واقعی نیست.

## ماتریس پذیرش UX — هنوز انجام/اثبات نشده
هیچ نتیجه‌ای برای ماتریس مستقل عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp با کیبورد باز و بسته در این ممیزی تولید نشده است. موارد زیر همچنان NOT VERIFIED هستند:
- ثبت سریع، فرم کامل، Home و Reports در هر سه عرض؛
- نبود overflow و دسترسی واقعی به دکمه ثبت با کیبورد باز؛
- اندازه هدف‌های لمسی؛
- ترتیب RTL: زمان ← مرکز ← پروژه ← دسته ← برچسب؛
- نصب و پیمایش روی گوشی واقعی.

## تصمیم اجرایی
این checkpoint فقط ثبت شواهد و تفکیک شکست‌هاست؛ در این مرحله تغییر کد یا اصلاح تست انجام نشده است. ابتدا باید منشأ شکست‌های Home، فرم کامل، Reports و Calendar اصلاح شود، بدون حذف/skip/تضعیف تست‌ها؛ سپس ماتریس UX اجرا و همه workflowها برای SHA جدید دوباره ارزیابی شوند.

تا تکمیل همه گیت‌ها و آزمون نصب روی گوشی واقعی:
**BLOCKED — RELEASE: NO-GO**

PR باید OPEN / DRAFT / UNMERGED بماند. main ممنوع از تغییر؛ Merge ممنوع.
