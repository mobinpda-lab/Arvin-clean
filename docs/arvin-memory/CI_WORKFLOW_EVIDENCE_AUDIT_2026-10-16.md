# ممیزی شواهد جریان‌های کاری CI آروین
**تاریخ ممیزی:** 2026-10-16  
**وضعیت انتشار:** RELEASE: NO-GO  
**دامنه:** فقط ممیزی اسناد و گردش‌کارها؛ هیچ منطق محصولی یا UI تغییر داده نشده است.

## مبنای ممیزی و محدودیت شناسه مرجع
- مخزن: https://github.com/mobinpda-lab/Arvin-clean
- آخرین commit قابل مشاهده در جست‌وجوی commitها هنگام ممیزی: [e04467a38b92121cfb3b635f39c4c5e8fd0569ba](https://github.com/mobinpda-lab/Arvin-clean/commit/e04467a38b92121cfb3b635f39c4c5e8fd0569ba).
- این SHA به‌عنوان **snapshot مرجع ممیزی** ثبت شده است؛ به‌علت در دسترس نبودن تأیید مستقل pointer شاخه `main` در پاسخ ابزار، آن را بدون قید «HEAD قطعی main» معرفی نمی‌کنیم.
- گردش‌کارهای بررسی‌شده در snapshot فایل‌ها: `.github/workflows/build.yml`، `.github/workflows/device-smoke.yml`، `.github/workflows/final-head-release-validation.yml`، `.github/workflows/calendar-provider-acceptance.yml` و `docs/arvin-memory/ARVIN_EVIDENCE_MAP.md`.
- Blob SHAهای workflowها به‌ترتیب: `a7619bcafa667a5c40efb61bf1c35fc623b9d8d2`، `e1f4b57e165fda1672c2316fd003318a979e989d`، `eba74e691df5d3173dc42d85aca8a6478f256033`، `0c30d5f9183bd4edea5a40a6c4705aca2585e6cc`. فایل نقشه شواهد در زمان ممیزی blob SHA برابر `f80f06c5cd66b7ba425623f0c2937949d49d3ea9` داشت.

## ۱. مسیر رسمی تحلیل کد و تست‌ها

### Arvin Build — `.github/workflows/build.yml`
- Job `quality` دارای ماتریس هفت‌مسیره است: `analyze` و `test-0` تا `test-5`.
- فقط lane با نام `analyze` دستور `flutter analyze` را اجرا می‌کند.
- شش lane تست، کل مجموعه `flutter test` را با `--total-shards 6 --shard-index N` تقسیم می‌کنند.
- دو job مستقل `apk (debug)` و `apk (release)` نیز APK می‌سازند؛ موفقیت ساخت APK به‌تنهایی نتیجه تحلیل یا تست نیست.
- بنابراین معیار موفقیت Build باید شامل Analyze + هر شش shard + هر دو ساخت APK باشد؛ هر lane ناموفق، حذف‌شده یا فاقد نتیجه نهایی، شکاف شواهد است.

### Final Head Release Validation — `.github/workflows/final-head-release-validation.yml`
- در اجرای دستی (`workflow_dispatch`)، workflow ابتدا `main` را checkout می‌کند و برابری `HEAD` و `origin/main` را کنترل می‌کند؛ سپس `flutter analyze`، `flutter test` کامل و ساخت Release APK را اجرا می‌کند.
- در اجرای ناشی از `workflow_run`، اعتبارسنجی به نتیجه Release Closure، دارایی‌های ساخته‌شده و تطبیق SHA/هش‌ها وابسته است؛ این مسیر به‌خودی‌خود یک اجرای تازه `flutter analyze` یا مجموعه تست کامل نشان نمی‌دهد.
- در مسیر `workflow_run`، شکست Release Closure با پیام مسدود بودن اعتبارسنجی و خروج غیرصفر fail-closed می‌شود.
- این workflow گیت نهایی مبتنی بر main است، اما لاگ موفقیت فقط وقتی معتبر است که SHA نهایی، نتیجه jobها و artifactها با هم تطبیق داده شوند.

## ۲. امولاتور واقعی در CI

### Device Smoke — `.github/workflows/device-smoke.yml`
- امولاتور اندروید **واقعاً در workflow پیکربندی شده است**؛ این صرفاً تست قرارداد در سطح هاست نیست.
- شواهد مستقیم در YAML: فعال‌سازی KVM، استفاده از `reactivecircus/android-emulator-runner@v2` با API 35 و معماری x86_64 و اجرای `flutter drive` روی `emulator-${EMULATOR_PORT}`.
- شش سناریوی ماتریس: Home، Quick Capture، SQL Persistence، SQL Migration، Backup/Restore و People.
- این workflow اسکرین‌شات برای Home، Quick Capture و People و همچنین تصویر انتخاب‌گر زمان را تلاش می‌کند بارگذاری کند؛ نبودن فایل تصویر به‌صورت هشدار تنظیم شده، نه شکست الزامی. بنابراین موفقیت job الزاماً به معنی وجود همه تصاویر نیست.
- امولاتور CI، **دستگاه فیزیکی نیست** و به‌تنهایی پذیرش روی گوشی واقعی، ارائه‌دهنده تقویم دستگاه یا رفتار انتخاب‌گر فایل واقعی را ثابت نمی‌کند.

### Calendar Provider Acceptance — `.github/workflows/calendar-provider-acceptance.yml`
- این workflow نیز امولاتور API 35 را اجرا می‌کند، APK را نصب می‌کند، مجوزهای تقویم را اعطا می‌کند و تست یکپارچگی `integration_test/android_calendar_provider_acceptance_test.dart` را روی امولاتور اجرا می‌کند.
- نتیجه معتبر مورد انتظار یا `CALENDAR_PROVIDER_ACCEPTANCE=PASS` است، یا محدودیت صریح `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`. نتیجه محدودیت، موفقیت آزمون واقعی CRUD محسوب نمی‌شود.
- محرک PR مبتنی بر فهرست `paths` است؛ در نتیجه اجرای این workflow برای هر تغییر دلخواه تضمین نشده و باید مسیرهای حساس پوشش‌داده‌شده در فهرست محرک‌ها بررسی شوند.

## ۳. ماتریس پوشش و شکاف‌های شواهد

| سطح / قابلیت | پوشش تعریف‌شده در CI | شکاف باقی‌مانده |
|---|---|---|
| تحلیل استاتیک | `flutter analyze` در Build lane و در اجرای دستی Final Head | لاگ موفق باید به SHA نهایی متصل شود؛ کد YAML به‌تنهایی نتیجه اجرا نیست |
| تست‌های واحد و ویجت | همه `test/**` در شش shard از طریق `flutter test` | لازم است نتیجه هر شش shard در همان SHA نهایی ثبت شود |
| Home | سناریوی `android_home_smoke_test.dart` در امولاتور؛ تلاش برای بارگذاری اسکرین‌شات | اسکرین‌شات اختیاری است؛ پذیرش بصری نهایی و گوشی واقعی اثبات نمی‌شود |
| Calendar | تست Provider در workflow جداگانه و مشروط به path؛ بخشی از تست‌های واحد/ویجت در Build | سناریوی Calendar در ماتریس شش‌گانه Device Smoke وجود ندارد؛ اجرای workflow Provider باید جداگانه و روی SHA مربوط اثبات شود |
| Report Center | تست‌های واحد/ویجت احتمالی در مجموعه عمومی `flutter test` | سناریوی اختصاصی Report Center در ماتریس Device Smoke مشاهده نشد؛ تصویر و مسیر کامل تعامل گزارش در این workflowها الزام‌آور نیست |
| پیگیری‌ها / Follow-up | تست‌های موجود در `test/**` در شش shard عمومی؛ Quick Capture و People در Smoke | سناریوی مستقل end-to-end برای چرخه پیگیری در ماتریس Device Smoke مشاهده نشد؛ پوشش دقیق تست‌های نام‌برده باید از نتیجه shardها و فایل‌های تست تأیید شود |
| واژگان «پیگیری» | تست‌های عمومی ممکن است قراردادها را پوشش دهند | گیت واژگان یا lint اختصاصی در workflowهای بررسی‌شده مشاهده نشد؛ انطباق واژگانی سراسری از YAML به‌تنهایی اثبات نمی‌شود |
| SQLite و مایگریشن | دو سناریوی مستقل SQL Persistence و SQL Migration در امولاتور | موفقیت باید برای هر دو lane و SHA نهایی قابل مشاهده باشد؛ آزمون امولاتور جایگزین آزمون فیزیکی نیست |
| Backup/Restore | سناریوی امولاتور مستقل در Device Smoke | ارائه‌دهنده فایل سیستم واقعی، بازیابی/بازگشت در گوشی و پذیرش فیزیکی در این گردش‌کار اثبات نمی‌شود |
| انتشار نهایی | Final Head Validation بررسی SHA، artifact و هش‌ها را انجام می‌دهد | نتیجه workflow، فایل APK و هش باید برای یک SHA دقیق ثبت شود؛ release gate نباید با نتیجه قدیمی باز شود |

## ۴. شواهد اجرایی قابل مشاهده در زمان ممیزی

- اجرای [Arvin Build شماره 38899481933](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38899481933) از طریق API مربوط به jobها بررسی شد: **۹ job از ۹ job گزارش‌شده دارای conclusion=success** بودند؛ شامل Analyze، شش shard تست و دو ساخت APK.
- در همان گزارش jobها، گام `Analyze` موفق و گام `Test` در هر یک از شش lane تست موفق بود؛ گام نامرتبط در lane دیگر به‌صورت skipped گزارش شد که رفتار مورد انتظار ماتریس است.
- **محدودیت مهم:** داده برگشتی jobها در این بررسی، SHA دقیق checkout شده برای اجرای 38899481933 را نشان نداد؛ بنابراین این اجرا شواهد مثبت برای همان Run است، اما در این ممیزی به‌عنوان اثبات قطعی آخرین HEAD پذیرفته نمی‌شود.
- جست‌وجوی اجرای PR-associated برای snapshot `e04467a38b92121cfb3b635f39c4c5e8fd0569ba` هیچ اجرای متناظری برنگرداند. چون این ابزار فقط اجراهای آغازشده از PR را بازمی‌گرداند، این نتیجه **اثبات نبودن همه اجراهای GitHub Actions نیست**؛ وضعیت دقیق Build/Smoke روی HEAD نهایی نامشخص باقی می‌ماند.
- محتوای فعلی Evidence Map شامل چندین ردیف تاریخی با وضعیت‌های pending/queued/skipped و SHAهای قدیمی است؛ خود سند نیز هشدار می‌دهد که این نتایج جایگزین شواهد SHA نهایی نیستند.

## ۵. نتیجه و معیار توقف

**نتیجه ممیزی:** ساختار CI هم تحلیل استاتیک، تست‌های واحد/ویجت shardشده، ساخت APK و امولاتور واقعی را تعریف کرده است. بااین‌حال، پوشش عملی Home/Calendar/Report Center/Follow-up یکسان نیست و صرف وجود workflowها، اثبات موفقیت اجرای نهایی محسوب نمی‌شود.

**شکاف‌های مسدودکننده:**
1. اتصال نتیجه نهایی Analyze + شش shard + دو APK به SHA قطعی HEAD.
2. دریافت نتیجه نهایی شش سناریوی Device Smoke برای همان SHA.
3. دریافت artifactها و نتیجه صریح Calendar Provider Acceptance برای SHA مرتبط؛ محدودیت امولاتور نباید به‌عنوان PASS ثبت شود.
4. نبود سناریوی اختصاصی Report Center و چرخه مستقل Follow-up در ماتریس Device Smoke فعلی.
5. نبود گیت واژگانی اختصاصی برای اثبات یکدستی اصطلاح «پیگیری».
6. نبود شواهد دستگاه فیزیکی و پذیرش بصری قطعی Home/Calendar/Report Center در workflowهای بررسی‌شده.

هیچ فایل منطق محصول یا UI در این ممیزی تغییر نکرده است. تا زمانی که این شکاف‌ها با لاگ‌های نهایی و SHA دقیق بسته نشوند، وضعیت انتشار باید `RELEASE: NO-GO` بماند.

## منابع مستقیم
- [build.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/build.yml)
- [device-smoke.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml)
- [final-head-release-validation.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/final-head-release-validation.yml)
- [calendar-provider-acceptance.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/calendar-provider-acceptance.yml)
- [Arvin Evidence Map](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/arvin-memory/ARVIN_EVIDENCE_MAP.md)
