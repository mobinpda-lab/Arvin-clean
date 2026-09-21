# ARVIN Final Convergence Execution Ledger — 2026-09-21

## هدف
این سند مرجع عملیاتی جلوگیری از دوباره‌کاری در تکمیل Arvin است. قرارداد محصول در `docs/ARVIN_FINAL_UI_AND_BEHAVIOR_CONTRACT.md` و نمایه آن در `docs/ARVIN_UI_CANONICAL.md` است.

## اصل ماندگاری مسیر
این مسیر به گفت‌وگوی ChatGPT، صفحه گفتگو، نشست، دستگاه، یا حساب/چت دیگری وابسته نیست. **مرجع مسیر فقط GitHub است.**
- ترتیب کار، گیت‌های پذیرش، SHAهای مرجع و آخرین checkpoint باید در همین مخزن ثبت شوند.
- اگر گفت‌وگو یا حساب تغییر کرد، اجرای بعدی باید از آخرین checkpoint معتبر همین سند و exact-head شاخه/PR ادامه پیدا کند.
- هیچ دستور جدیدی در یک گفت‌وگوی دیگر به‌تنهایی نمی‌تواند ترتیب این مسیر را عوض کند؛ تغییر مسیر فقط با ثبت تغییر در GitHub و وجود دلیل/شاهد مشخص مجاز است.
- اگر اطلاعات گفتگو با GitHub ناسازگار بود، وضعیت ثبت‌شده در GitHub مرجع است.
- گزارش‌های بعدی نباید ممیزی کامل را از صفر تکرار کنند؛ فقط checkpoint آخر و اختلاف exact-head بررسی می‌شود.

## وضعیت مبنا
- مخزن: `mobinpda-lab/Arvin-clean`
- شاخه مبنا: `main`
- SHA مبنا: `25c2ecf7e935ac7a75cfa0d386e1e5eb1d342d47`
- PR باز مهم: #1259 — اصلاح authoritative persistence برای TaskStore
- PR باز مهم: #1222 — اجرای قرارداد نهایی UI و رفتار
- PR فعلی: #1270 — کنترل واحد اجرای نهایی
- هر PR باز فقط پس از تطبیق exact-head مبنای واقعی تلقی می‌شود؛ کد ادعایی یک PR تا ادغام/تأیید همان SHA بخشی از main نیست.

## قاعده جلوگیری از دوباره‌کاری
1. قبل از هر تغییر فقط اختلاف exact-head با آخرین شاخه/PR بررسی می‌شود.
2. کارهای هم‌پوشان PRهای باز دوباره از صفر پیاده‌سازی نمی‌شوند.
3. یک موج اجرایی = یک شاخه فعال + یک PR فعال.
4. هر قابلیت در ماتریس واحد با وضعیت مستندشده / پیاده‌سازی‌شده / دارای آزمون / تأییدشده روی Android / کامل ثبت می‌شود.
5. موفقیت قدیمی CI یا Build برای SHA جدید قابل استفاده نیست.
6. پس از هر تغییر، SHA جدید و نتیجه همان SHA ثبت می‌شود.
7. تغییر مسیر فقط با اختلاف واقعی، خطا یا شکست پذیرش دارای شاهد GitHub انجام می‌شود.
8. Storage، مدل و مسیر دوم برای رفع UI ساخته نمی‌شود.
9. قبل از شروع موج بعدی، نتیجه موج قبلی در همان PR/commit ثبت و exact-head دوباره بررسی می‌شود.
10. گزارش‌ها از آخرین checkpoint ثبت‌شده ادامه پیدا می‌کنند، نه از ممیزی کامل تکراری.

## ترتیب اجرای قفل‌شده
1. تعیین نسخه پایه Integration از #1259 و استخراج فقط delta واقعی #1222
2. Home و چهار حالت
3. کارت کار و آخرین پیگیری
4. Quick Capture و Bottom Sheet
5. Keyboard و Back
6. Swipe
7. FollowUp detail
8. Notebook
9. More و Settings
10. آزمون و Android verification
11. Build نهایی و PR

**هیچ مرحله‌ای بدون عبور از گیت مرحله قبل به مرحله بعد نمی‌رود.**

## گیت کامل
«کامل» فقط با کد + آزمون + Build debug/release + شواهد Android روی همان SHA مجاز است.

## پروتکل تغییر مسیر
هر پیشنهاد برای تغییر ترتیب یا شروع مسیر جدید باید:
1. اختلاف با checkpoint فعلی را مشخص کند؛
2. دلیل فنی یا شکست پذیرش را ثبت کند؛
3. در GitHub به‌روزرسانی شود؛
4. SHA جدید و گیت بعدی را ثبت کند.
بدون این چهار مورد، مسیر فعلی معتبر باقی می‌ماند.


## برنامه اجرایی مرحله‌به‌مرحله

### G0 — Freeze و Baseline
**ورودی:** #1259 = `675e6ceeb300c48202b00ccfe68d64ecc5351831`، #1222 = `8e99d4d1785738d78a900b4e2db37ff6cca00009`
- exact-head هر دو PR را تأیید کن.
- از #1259 یک شاخه Integration واحد بساز.
- #1222 را merge مستقیم نکن.
- diff #1222...#1259 را به سه گروه KEEP / TAKE / REIMPLEMENT تقسیم کن.
**خروجی:** یک baseline SHA و فهرست delta.
**گیت:** baseline تغییرپذیر نیست مگر با ثبت دلیل.

### G1 — Storage / Model Safety
- TaskStore و migration را روی baseline بررسی کن.
- مطمئن شو Project/Category/Tag/FollowUp/Notebook/Archive/Trash داده موازی نمی‌سازند.
- تست‌های TaskStore و migration را اجرا کن.
**گیت:** هیچ regression ذخیره‌سازی؛ تست‌های مرتبط سبز.

### G2 — Home
- چهار گروه زمان/پروژه/دسته/برچسب.
- داده واقعی و مسیرهای بدون مقدار.
- کارت Task با آخرین متن FollowUp یا description.
- حذف عناصر قدیمی Home.
**گیت:** تست Home سبز + رفتار چهار حالت روی Android.

### G3 — Quick Capture
- Bottom Sheet واقعی + RTL + focus/keyboard.
- TaskStore مرکزی.
- ثبت سه Task متوالی بدون duplicate/empty.
- حفظ draft در خطا و ادامه همان Draft در Full Form.
**گیت:** تست Quick Capture سبز + Android سه‌ثبت متوالی.

### G4 — Keyboard / Back
- Back در selector/submenu.
- Back روی draft خالی.
- Back روی draft غیرخالی با سه انتخاب.
- برگشت از Full Form بدون duplicate.
**گیت:** Android keyboard/back سبز.

### G5 — Task Card / FollowUp
- جزئیات Task.
- latest FollowUp text.
- تاریخچه newest-first.
- Add/Edit/Complete بدون حذف history.
**گیت:** تست FollowUp سبز + Home refresh.

### G6 — Swipe
- mapping چپ/راست طبق Settings.
- complete / date / project/category / trash / undo.
- permanent delete فقط explicit.
**گیت:** Android RTL swipe واقعی + تست مرتبط.

### G7 — Notebook
- Note و Checklist از repository canonical.
- search/filter/category.
- progress واقعی.
- trash/recover و move بدون تغییر ID.
**گیت:** تست Notebook + Android smoke.

### G8 — Calendar
- daily/weekly/monthly/yearly فقط در صورت سلامت.
- navigation/today/direct date.
- long-press create Task.
- تفکیک Task/FollowUp/Reminder/Event.
**گیت:** تست Calendar + Android smoke؛ قابلیت سالم موجود بازنویسی نشود.

### G9 — More / Settings
- My Tasks و فیلترها.
- projects/categories/tags/followup.
- archive/trash/backup/help/about.
- settings فقط برای قابلیت‌های واقعی.
**گیت:** تست Settings/More و نبود گزینه نمایشی غیرعملیاتی.

### G10 — Full Verification
روی **همان SHA**:
`flutter pub get --enforce-lockfile`
→ `flutter analyze`
→ `flutter test`
→ `flutter build apk --debug`
→ `flutter build apk --release`
**گیت:** همه سبز.

### G11 — Android Evidence
روی همان SHA:
- Home ×4
- Quick Capture ×3 sequential
- keyboard/back
- FollowUp
- Swipe
- Notebook/Checklist
- Calendar
- More/Settings
- RTL/FAB/5-tab nav/ellipsis
**گیت:** شواهد ذخیره‌شده و قابل انتساب به همان SHA.

### G12 — Finalize
- آخرین SHA را ثبت کن.
- GitHub Actions همان SHA را ثبت کن.
- PR نهایی واحد ایجاد/به‌روزرسانی کن.
- ماتریس وضعیت را پر کن.
- فقط قابلیت‌هایی که G10 و G11 را گذرانده‌اند «کامل» هستند.

## قانون اجرای هر گیت
برای هر G:
1. فقط delta لازم همان مرحله را تغییر بده.
2. commit کن.
3. exact-head جدید را ثبت کن.
4. targeted test را اجرا کن.
5. اگر سبز بود مرحله بعد.
6. اگر قرمز بود **مرحله بعد ممنوع**؛ فقط regression همان گیت اصلاح شود.
7. بعد از اصلاح، از همان گیت دوباره ادامه بده؛ ممیزی کل پروژه ممنوع.

## Checkpoint format
هر checkpoint باید این چهار مورد را ثبت کند:
- Current SHA
- Gate
- Result
- Next exact action

