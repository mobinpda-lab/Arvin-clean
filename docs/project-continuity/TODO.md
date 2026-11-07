# TODO — دفتر کارهای باز آروین

**مخزن:** `mobinpda-lab/Arvin-clean`  
**شاخه مجاز:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Snapshot مبنا:** `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`  
**آخرین بررسی:** 2026-11-07 — ۱۴۰۵/۰۸/۱۶  
**قاعده:** وضعیت هر ردیف فقط با شواهد همان SHA تغییر می‌کند. «در انتظار تأیید» به معنی DONE نیست.

## کارهای باز

| شناسه | وضعیت | اولویت | شرح کوتاه | وابستگی | معیار تکمیل | مرجع شواهد یا اجرای مرتبط |
|---|---|---|---|---|---|---|
| ARV-TODO-001 | IN_PROGRESS | P0 | تکمیل Build و شش شارد تست و jobهای APK در اجرای جاری | اجرای CI روی SHA مبنا | همه jobهای run جاری به نتیجه نهایی برسند؛ Analyze، Visual، شش شارد و jobهای APK موفق باشند و نتایج دقیقاً به همین SHA تعلق داشته باشند | [Build run 42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460) — Analyze و Visual موفق؛ شش شارد و Debug/Staging/Release هنوز IN_PROGRESS |
| ARV-TODO-002 | IN_PROGRESS | P1 | تأیید تست‌های رگرسیون فیلتر پس از اصلاح سرریز ۱۵۸ پیکسلی | ARV-TODO-001 | تست‌های Home، انتخاب دسته/برچسب در جزئیات، ساخت گزینه در فیلتر چندانتخابی و فیلتر گزارش بدون overflow و با رفتار مورد انتظار PASS شوند؛ هیچ assertion حذف یا تضعیف نشود | اصلاح کد در [commit 2baad457](https://github.com/mobinpda-lab/Arvin-clean/commit/2baad457ba0bdd89114566afb4b42e2315904bb2)؛ اجرای جاری [42407484460](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484460) هنوز در جریان است؛ نتیجه تست‌ها در انتظار تأیید |
| ARV-TODO-003 | PENDING | P0 | تکمیل Device Smoke روی SHA مبنا | اجرای workflow و آماده‌شدن jobها | تمام laneهای الزامی Device Smoke روی همین SHA اجرا و موفق شوند؛ نتیجه ناقص یا بدون job پذیرفته نیست | [Device Smoke run 42407484403](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484403) — PENDING؛ هنوز jobای برنگشته است |
| ARV-TODO-004 | PENDING | P0 | نصب و پذیرش واقعی روی Samsung SM-A528B/DS | APK قابل نصب و دسترسی به دستگاه واقعی | نصب APK همان candidate، اجرای برنامه و سناریوهای ضروری یادآور/تقویم/تعامل بررسی و شواهد تصویری یا ثبت اجرای واقعی نگهداری شود | APK بازبینی [Artifact 13588087657](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484426/artifacts/13588087657) موجود است؛ نصب و رفتار گوشی هنوز در انتظار تأیید |
| ARV-TODO-005 | BLOCKED | P0 | عبور از دروازه انتشار و پذیرش نهایی | ARV-TODO-001، ARV-TODO-003، ARV-TODO-004 و ثبت پذیرش مالک محصول | تمام دروازه‌های لازم روی یک SHA واحد PASS شوند و پذیرش مالک محصول ثبت شود؛ سپس مجوز جداگانه انتشار صادر شود | PR #3052 و وضعیت انتشار: [OPEN / DRAFT / UNMERGED](https://github.com/mobinpda-lab/Arvin-clean/pull/3052)؛ **BLOCKED — RELEASE: NO-GO** |

## سوابق تأییدشده — خارج از فهرست فعال

| مورد | نتیجه ثبت‌شده | SHA / مرجع |
|---|---|---|
| ساخت و بارگذاری Staging Review APK | SUCCESS؛ امضای V2/V3، package، debuggable=false و فونت Vazirmatn تأیید؛ فقط review-only و غیرقابل انتشار | SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`، run [42407484426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484426)، artifact [13588087657](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484426/artifacts/13588087657)؛ APK SHA-256: `04482b5595eb7666a9a47076eb7c8fdcec480ca7911ab2a8f718ef442276fd90` |
| G1 lock sync | SUCCESS | SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`، [run 42407484429](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484429) |
| Follow-up file persistence | SUCCESS | SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`، [run 42407484432](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484432) |
| Calendar Provider | SUCCESS | SHA `b1ad86a164f9d8f8363e29313163f1be0ee53d4a`، [run 42407484406](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42407484406) |
| اصلاح سرریز افقی فیلتر | تغییر کد با جایگزینی Row با Wrap ثبت شد؛ این سابقه به‌تنهایی PASS تست‌ها نیست | [commit 2baad457](https://github.com/mobinpda-lab/Arvin-clean/commit/2baad457ba0bdd89114566afb4b42e2315904bb2) |

## قواعد نگهداری

- کارهای تکمیل‌شده از بخش «کارهای باز» خارج می‌شوند؛ سابقه آن‌ها فقط در همین تاریخچه یا گزارش اجرای مرتبط می‌ماند.
- هر نتیجه CI فقط به SHA ثبت‌شده در همان اجرا تعلق دارد؛ نتیجه SHA قدیمی به HEAD جدید منتقل نمی‌شود.
- «در انتظار تأیید» در شرح شواهد می‌آید و هرگز معادل DONE نیست.
- هیچ تستی حذف، Skip، دور زده یا تضعیف نمی‌شود.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` دست‌نخورده؛ Merge و انتشار ممنوع.
- وضعیت انتشار: **BLOCKED — RELEASE: NO-GO**.
