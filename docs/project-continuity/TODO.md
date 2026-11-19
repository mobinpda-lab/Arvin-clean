# TODO — دفتر کارهای باز آروین

**مخزن:** `mobinpda-lab/Arvin-clean`  
**شاخه مجاز:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**HEAD مبنای این به‌روزرسانی:** `23372c3dfcac8ff5206c406a575c012dee90c894`  
**تاریخ:** 2026-11-07  
**قاعده:** هر نتیجه فقط به SHA همان اجرا تعلق دارد. «در انتظار تأیید» به معنی DONE نیست.

## کارهای باز

| شناسه | وضعیت | اولویت | شرح کوتاه | وابستگی | معیار تکمیل | مرجع شواهد یا اجرای مرتبط |
|---|---|---|---|---|---|---|
| TSK-01 | PENDING | بالا | دریافت و راستی‌آزمایی Staging APK روی Samsung SM-A528B/DS؛ نصب، اجرای بدون کرش و بررسی اعمال رنگ پیش‌فرض `#3A86EF` | ساخت Staging در run `42406934575` تکمیل شده و Artifact آماده دریافت است؛ باقی‌مانده، دریافت و آزمون روی دستگاه واقعی است | نصب موفق APK همین candidate، اجرای بدون کرش، بررسی صفحات اصلی و اعمال رنگ `#3A86EF` با ثبت شواهد واقعی دستگاه | [Run 42406934575](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575) · [Artifact 13588285590](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575/artifacts/13588285590). این APK روی SHA `2baad457ba0bdd89114566afb4b42e2315904bb2` ساخته شده؛ نصب/رفتار روی گوشی هنوز در انتظار تأیید است |
| TSK-02 | IN_PROGRESS | بالا | ارزیابی نتایج تست‌های شارد ۱، به‌ویژه تست‌های فیلتر و تقویم، و پیگیری شکست‌های واقعی بدون تغییر انتظار تست | گزارش CI روی SHA مشخص و اجرای جاری روی HEAD | شارد ۱ روی یک SHA واحد بدون شکست پاس شود؛ هیچ تستی حذف، Skip یا تضعیف نشود | اجرای قبلی [42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460) روی SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`: job شارد ۱ با **174 passed / 13 failed** پایان یافت؛ اجرای کلی پس از تغییر HEAD به‌صورت CANCELLED ثبت شد. اجرای جدید [42408265669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42408265669) روی HEAD `ad58025592690515020de2c4e3bf0fd0ac65db1b` در حال اجراست؛ نتیجه شارد ۱ هنوز در انتظار تأیید است |
| TSK-03 | PENDING | متوسط | آزمون میدانی `ReusableMultiSelectFilterBottomSheet` در عرض‌های 360، 390 و 412dp | آماده‌بودن candidate قابل نصب و دسترسی به شبیه‌ساز/دستگاه با اندازه‌های هدف | در هر سه عرض، نبود سرریز افقی/عمودی، دسترسی کامل به دکمه‌ها و رفتار صحیح انتخاب چندگانه چک‌باکسی ثبت شود | اصلاح قبلی سرریز 158px در [commit 2baad457](https://github.com/mobinpda-lab/Arvin-clean/commit/2baad457ba0bdd89114566afb4b42e2315904bb2)؛ تست رگرسیون روی SHA قبلی به‌تنهایی اثبات آزمون میدانی سه عرض نیست. شواهد سه عرض هنوز در انتظار تأیید است |
| TSK-04 | PENDING | متوسط | بازبینی اعمال رنگ سازمانی پیش‌فرض `#3A86EF` و پالت ۹ رنگ در SharedPreferences | بررسی منبع پیاده‌سازی، اجرای تست‌ها و اعتبارسنجی بصری/ماندگاری روی دستگاه | تأیید گزینه پیش‌فرض ۸، ذخیره و بازیابی انتخاب در کلید `arvin.settings.primaryColor`، رد مقدار نامعتبر، و اعمال رنگ انتخابی در صفحات/حالت‌های روشن و تاریک | [گزارش پیاده‌سازی پالت](ARVIN_DYNAMIC_THEME_PALETTE_2026-11-07.md) می‌گوید AppThemeManager، ۹ گزینه و کلید SharedPreferences اضافه شده‌اند؛ همان گزارش تصریح می‌کند پذیرش کامل بصری و دستگاهی هنوز اثبات نشده است |

## دروازه انتشار

| شناسه | وضعیت | اولویت | شرح کوتاه | وابستگی | معیار تکمیل | مرجع شواهد یا اجرای مرتبط |
|---|---|---|---|---|---|---|
| ARV-REL-01 | BLOCKED | P0 | حفظ وضعیت عدم انتشار تا تکمیل پذیرش | TSK-01 تا TSK-04 و تمام دروازه‌های CI/Device Smoke روی یک SHA واحد | پذیرش تمام دروازه‌ها و مجوز مستقل مالک محصول؛ سپس تصمیم جداگانه انتشار | PR #3052 باید [OPEN / DRAFT / UNMERGED](https://github.com/mobinpda-lab/Arvin-clean/pull/3052) بماند؛ **BLOCKED — RELEASE: NO-GO** |

## سوابق قطعی و نتایج CI

| مورد | نتیجه | SHA / مرجع |
|---|---|---|
| Staging Review APK run `42406934575` | SUCCESS؛ Artifact بارگذاری شد. APK: `Arvin-review-staging-2baad457ba0bdd89114566afb4b42e2315904bb2.apk`؛ حجم **79,185,752 bytes**؛ SHA-256 **`dd990f90a1441423c3214e915d528f5f78e6d65ce0045b45b75791ddd1873416`**؛ package `com.example.arvin.staging`؛ non-debuggable؛ امضای V2/V3 و Vazirmatn PASS؛ کلید موقت review-only و `publishable=false` | SHA `2baad457ba0bdd89114566afb4b42e2315904bb2`؛ [Run](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575) · [Artifact 13588285590](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934575/artifacts/13588285590). SHA-256 ZIP آرتیفکت: `29369cb751c75055198b69252cd49461d47bf8e50a7e4da3d289393ce6cb89aa` |
| Build run `42406934619` | CANCELLED؛ این اجرا روی SHA `2baad457...` بود و پس از تغییر HEAD، نتیجه نهایی Build/شاردها را تأیید نمی‌کند | [Run 42406934619](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42406934619) |
| Build run `42407484460` | CANCELLED پس از تغییر HEAD؛ در job شارد ۱ روی SHA `b1ad86a...` تعداد **174 تست موفق و 13 تست ناموفق** ثبت شد؛ این نتیجه به HEAD فعلی منتقل نمی‌شود | [Run 42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460) |
| اجرای جاری Build | IN_PROGRESS؛ Analyze و Visual موفق؛ شش شارد و APKها در زمان ثبت در حال اجرا هستند | SHA `ad58025592690515020de2c4e3bf0fd0ac65db1b`؛ [Run 42408265669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42408265669) |
| Device Smoke جاری | PENDING؛ هنوز jobی برای اجرا گزارش نشده است | SHA `ad58025592690515020de2c4e3bf0fd0ac65db1b`؛ [Run 42408265703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42408265703) |

## قواعد نگهداری

- موارد تکمیل‌شده از فهرست فعال خارج می‌شوند و فقط در سوابق قطعی باقی می‌مانند.
- هر نتیجه CI فقط به SHA ثبت‌شده در همان اجرا تعلق دارد.
- وضعیت «در انتظار تأیید» هرگز DONE نیست.
- هیچ تستی حذف، Skip، دور زده یا تضعیف نمی‌شود.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` دست‌نخورده؛ Merge و انتشار ممنوع.
- وضعیت انتشار: **BLOCKED — RELEASE: NO-GO**.


---

## TSK-02 — فهرست شکست‌های تاریخی شارد ۱

- [Build run 42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460)، job `quality (test-1)` / ID `128509578970`، checkout SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`: **174 passed / 13 failed**؛ اجرای کلی بعداً CANCELLED شد.
- نام دقیق هر ۱۳ تست، مسیر و خط، خروجی خطا و دسته‌بندی Assertion/Widget lifecycle/SQL binding در بخش «TSK-02 — تحلیل تفصیلی ۱۳ شکست شارد ۱» در `CURRENT_STATE.md` ثبت شده است.
- خطاهای مشاهده‌شده: ۹ اختلاف Assertion/داده، ۲ خطای استفاده از TextEditingController پس از dispose، ۱ خطای پارامترهای SQL، و ۱ خطای lifecycle چارچوب Flutter همراه Finder ناموفق. Timeout و Mock failure در این لاگ مشاهده نشد.
- این شکست‌ها فقط به SHA همان اجرا مربوط‌اند؛ تا زمان اجرای مجدد روی یک SHA واحد، TSK-02 باز و IN_PROGRESS می‌ماند. هیچ تستی حذف/Skip/تضعیف یا بازنویسی نشود.
- سند `ARCHITECTURE_NOTEBOOK.md` از قبل در شاخه وجود داشت و بررسی شد؛ سند تکراری ایجاد نشد. Gap Analysis فقط فهرست نیازهای فاز بعد است.
- مشخصات Staging APK قبلی حفظ شود: حجم `79,185,752` bytes؛ APK SHA-256 `dd990f90a1441423c3214e915d528f5f78e6d65ce0045b45b75791ddd1873416`؛ run `42406934575`، artifact `13588285590`. این APK متعلق به SHA `2baad457...` است و مدرک نصب روی Samsung نیست.
