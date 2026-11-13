# Arvin Calendar — Canonical UI/UX Specification
**Decision date:** 2026-11-05 — ۱۴۰۵/۰۸/۱۴  
**Authority:** Product-owner approved conversation decisions, including the final placement corrections made on 2026-11-05.  
**Status:** APPROVED — CANONICAL DESIGN REFERENCE  
**Scope:** Calendar screen presentation and interaction contract only. This document does not authorize runtime implementation, data-model changes, provider changes, schema changes, or release.
## 1. Design authority and scope
This file is the canonical reference for the approved Arvin Calendar screen UI/UX. It supersedes conflicting older Calendar header/layout proposals only within the screen areas explicitly defined here. Existing calendar data, provider, synchronization, event identity, and persistence contracts remain unchanged unless separately approved.
## 2. Header composition and sacred phrase
The header has three balanced RTL zones:
- **Center:** the exact phrase «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ», visually centered and balanced in prominence with the Home screen's Bismillah treatment. It replaces the Calendar app-title/header label.
- **Right:** calendar search icon.
- **Left:** the full Persian current-date pill and the «برو به تاریخ» date-picker icon, kept together as the date/navigation cluster.
The help button is removed. Do not reintroduce a help icon or a redundant Calendar title.
## 3. Header date pill — Today shortcut
The full Persian date is displayed in the top-left header cluster. It is the Today shortcut: tapping the date pill returns the calendar selection to the current day. Its visual size must harmonize with the calendar typography and it belongs at the highest/topmost calendar area on the left, not displaced into the content-filter row.
## 4. Go to Date control
The «برو به تاریخ» icon is adjacent to the full-date pill in the top-left cluster and opens date selection/navigation. Keep it distinct from the Today shortcut: the date pill returns to today; the picker icon lets the user choose a date. The final approved correction keeps the date and picker adjacent in the corrected top-left arrangement; do not swap their roles.
## 5. Selected-date display bar
A separate, prominent selected-date display appears above the calendar navigation/grid area:
- **Center:** selected Jalali date, bold and visually dominant.
- **Right:** corresponding Gregorian date.
- **Left:** corresponding Hijri lunar date.
This is the selected calendar date, not a duplicate of the Today shortcut. The selected Jalali date is also reflected in the calendar's month/date heading.
## 6. View-mode control row
Place exactly four view segments **above the calendar grid**:
«روزانه» | «هفتگی» | «ماهانه» | «سالانه»
The default selected mode is «هفتگی». These are mutually exclusive calendar presentation modes, not content filters.
## 7. Calendar grid structure
The grid is a seven-column Persian-week layout, Saturday through Friday. In RTL visual order, Saturday begins at the right and Friday ends at the left. The grid presents the calendar dates for the active view and selected period.
## 8. Triple-calendar date cells
Each date cell displays three corresponding calendar values:
1. Jalali/Solar Hijri — primary, bold, largest.
2. Gregorian — secondary, smaller.
3. Hijri lunar — secondary, smaller.
The three values must remain visually distinguishable and aligned within the same date cell. Do not let Gregorian or Hijri lunar values compete visually with the Jalali date.
## 9. Date-cell selection and date identity
The selected date is represented consistently between the selected-date display bar and the grid. A selected day must remain identifiable independently of the Today shortcut. Detailed selection colors, animation, and multi-date range-selection behavior are not specified by this approval and must not be invented as locked requirements.
## 10. Content-filter row placement and options
Place the five content filters **strictly below the calendar grid and above the agenda/list**. Their exact order is:
«همه» → «تقویم آروین» → «تقویم گوشی» → «یادآورها» → «انجام‌نشده»
These five chips filter the content shown in the agenda. They are not view modes and must never be moved above the grid or merged into the four-segment view-mode row.
## 11. Agenda/list content
Below the content-filter row, show the agenda for the selected day. It contains the applicable task, event, and reminder cards, subject to the selected content category. The agenda is date-scoped and must not visually overlap or stack cards on top of one another.
## 12. Non-overlapping card and content separation
Task, calendar-event, and reminder entries remain individually readable, with separate card boundaries and no overlap. Filtering must not cause cards to cover one another or obscure the selected date, grid, or filter row. Detailed card field inventory, ordering within a mixed agenda, and empty-state copy are not defined by this approval; retain existing canonical data semantics and do not fabricate new fields.
## 13. Calendar search
The top-right search icon opens the calendar's dynamic search experience. It replaces any prior header search placement and must remain in the top-right header zone. Exact search scope, matching rules, result ranking, and empty-state wording are not specified in this design decision and require a separate product decision if they are to change.
## 14. Hijri adjustment, RTL and implementation boundary
Calendar settings provide the Hijri lunar-date adjustment choices:
- +1 day
- −1 day
- Official Iranian Calendar Match
The adjustment affects the displayed Hijri lunar date alignment only; it must not mutate Jalali/Gregorian source dates, task due dates, reminders, event identity, or provider data. Preserve Persian RTL presentation and the established Vazirmatn application typography. This is a documentation-only registration: no runtime implementation or test changes are authorized by this document.
## Non-negotiable vertical hierarchy
Header → selected-date display → view-mode segments → calendar grid → content-filter chips → selected-day agenda.  
The view-mode row belongs above the grid; the five content filters belong below the grid. These rows are architecturally and visually separate.
## Acceptance and governance
- Treat this file as the single canonical Calendar UI/UX reference for the decisions above.
- Where a detail is explicitly marked unspecified, preserve current behavior pending a separate owner decision; do not infer a new product rule.
- Existing calendar/provider/data/persistence contracts remain in force.
- PR #3052 stays OPEN / DRAFT / UNMERGED; do not modify main, merge, publish or release.
- **BLOCKED — RELEASE: NO-GO.**


---

## تکمیل مصوبات نهایی تقویم — 2026-11-05

این بخش، جزئیات مصوبی را که در نسخه اولیه صریح نبودند، تکمیل می‌کند. سلسله‌مراتب عمودی تقویم تغییرناپذیر است:
**هدر → نمایش سه‌گانه تاریخ انتخاب‌شده → انتخاب حالت نمایش → جدول تقویم → فیلترهای محتوایی → فهرست همان روز.**

### هدر سه‌ناحیه‌ای RTL
- راست: فقط ذره‌بین جستجوی تقویم.
- مرکز واقعی صفحه، مستقل از عرض دکمه‌های طرفین: «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ» با اعراب کامل؛ اندازه و ظرافت آن با بسم‌الله Home هماهنگ باشد.
- چپ: تاریخ کامل امروز شمسی و آیکون «برو به تاریخ» در کنار یکدیگر. لمس تاریخ امروز، انتخاب را به روز جاری بازمی‌گرداند؛ آیکون مجاور، انتخاب‌گر تاریخ را باز می‌کند.
- عنوان «تقویم آروین» و دکمه راهنما در هدر وجود ندارد.
- «برو به تاریخ» انتخاب‌گر سه‌گانه با پیش‌فرض شمسی است و امکان انتخاب از تقویم شمسی، میلادی و قمری را می‌دهد.

### نوار تاریخ انتخاب‌شده
کادر برجسته مستقل از هدر: تاریخ شمسی در مرکز و درشت؛ تاریخ میلادی در راست؛ تاریخ قمری در چپ با رنگ متمایز. این نوار تاریخ انتخاب‌شده را نشان می‌دهد، نه لزوماً امروز را.

### چهار حالت نمایش
چهار حالت انحصاری و رنگی، بالای جدول: روزانه، هفتگی، ماهانه، سالانه. پیش‌فرض هفتگی است.
- روزانه: تمرکز بر روز انتخاب‌شده و محتوای همان روز.
- هفتگی: هفته شنبه تا جمعه؛ شنبه در راست و جمعه در چپ.
- ماهانه: شبکه هفت‌ستونی با چیدمان RTL و شروع هفته از شنبه.
- سالانه: ۱۲ ماه در شبکه سه‌ستونی؛ انتخاب ماه/روز باید به همان تاریخ انتخاب‌شده و agenda متناظر منتهی شود.
- در هر سلول، عدد شمسی برجسته و اعداد میلادی و قمری کوچک‌تر و ثانویه‌اند. روز جاری و روز انتخاب‌شده باید از یکدیگر قابل تشخیص باشند.

### فیلترهای محتوا و Agenda
دقیقاً زیر جدول و بالای فهرست، پنج چیپ ثابت و متمایز: «همه»، «تقویم آروین»، «تقویم گوشی»، «یادآورها»، «انجام‌نشده». این‌ها فیلتر محتوا هستند، نه حالت نمایش.
فهرست پایین، هم‌زمان بر اساس روز انتخاب‌شده و فیلتر محتوای فعال محدود می‌شود و می‌تواند Taskهای آروین، Reminderها، Follow-upهای مرتبط و رویدادهای تقویم گوشی را نمایش دهد. هر مورد کارت مستقل، سبک و گوشه‌گرد با نوار باریک رنگی نوع محتوا دارد؛ کارت‌ها نباید روی هم بیفتند یا یکدیگر را بپوشانند.
جستجوی تقویم از آیکون ذره‌بین هدر آغاز می‌شود و دامنه مصوب آن شامل عنوان Taskها، Reminderها، Follow-upها و رویدادهای تقویم گوشی است.

### تنظیم قمری و معماری منبع تقویم
- گزینه‌های اختلاف قمری: یک روز جلو، یک روز عقب، تطابق با تقویم رسمی ایران. گزینه سوم باید به منبع رسمی متکی باشد؛ اگر منبع رسمی در دسترس/قابل اثبات نیست، تطابق رسمی نباید ادعا شود.
- این تنظیم فقط هم‌ترازی تاریخ قمری نمایشی را تغییر می‌دهد؛ تاریخ شمسی و میلادی، Due Date، Reminder، شناسه رویداد و داده Provider تغییر نمی‌کنند.
- لایه اول: تقویم داخلی آروین برای داده‌های بومی محصول.
- لایه دوم: تقویم لوکال اجباری Arvin با `ACCOUNT_TYPE_LOCAL` برای یکپارچگی محلی/Provider.
- لایه سوم: تقویم‌های جانبی کاربر فقط نمایشی‌اند؛ منبع جانبی نباید به‌صورت ضمنی به تقویم قابل‌نوشتن یا مقصد نوشتن تبدیل شود.
- این سه‌لایه قرارداد معماری/محصولی است؛ جزئیات مجوزها، همگام‌سازی، شناسه‌ها و رفتار Provider همچنان تابع قراردادهای فنی موجودند.

### مرز پذیرش
ثبت این جزئیات به معنی پیاده‌سازی یا پذیرش runtime نیست. نمایش واقعی سه تقویم، رفتار انتخاب‌گر، جستجو، منبع رسمی قمری، Provider و فیزیکال‌دیوایس فقط با شواهد همان SHA قابل VERIFIED شدن است.


---

## ابلاغ Master و وضعیت اجرایی — ARVIN-DIR-1405/08/16-02-MASTER
**ثبت: ۱۴۰۵/۰۸/۱۶ | شاخه مجاز PR #3052**

- PRODUCT FIRST: نقص محصول در کد محصول رفع می‌شود؛ هیچ آزمونی حذف، Skip یا تضعیف نمی‌شود. اصلاح Finder فقط برای قرارداد واقعاً منسوخ و با حفظ پوشش رفتاری مجاز است.
- فونت یگانه رابط: **Vazirmatn**؛ بررسی `pubspec.yaml`، `lib/theme/app_fonts.dart` و `lib/theme/font_registry.dart` فقط همین خانواده را نشان می‌دهد.
- تم روشن فیروزه‌ای: Primary `#078B91`، Header `#066F75`، Soft `#DDF7F5`، Background `#F0FAF9`، Border `#D9ECEA`. رنگ‌های خطا/اولویت و وضعیت برای معنای وضعیت حفظ می‌شوند.
- SVG بسم‌الله با عرض نمایشی `210dp` حفظ شده؛ آزمون عرض ۲۱۰dp اضافه شده است.
- ترتیب فیلترهای Home: زمان ← مرکز ← پروژه ← دسته ← برچسب؛ مرتب‌سازی جدا و پس از پنج فیلتر است؛ Wrap راست‌به‌چپ و بدون پیمایش افقی.
- «پیگیری‌های انجام‌شده» فقط از بخش «نوع گزارش» در پنل فیلترها انتخاب می‌شود؛ دکمهٔ بالای صفحه وجود ندارد و آزمون آن را کنترل می‌کند.
- Calendar: محتوای سلول ماه درون سلول مقیاس می‌شود و هدف لمس حداقل ۴۸dp حفظ می‌شود؛ ارتفاع اضافهٔ نمای هفتگی کاهش یافته است.
- Task Editor و Quick Capture برای ۳۶۰/۳۹۰/۴۱۲dp، کیبورد باز/بسته و متن بزرگ پوشش آزمون دارند؛ کنترل‌های اولویت Quick Add حداقل ۴۸dp هستند.
- ایجاد مرکز/دسته/برچسب در Quick Capture دیگر کنترل متن موقت را پیش از پایان انیمیشن Sheet آزاد نمی‌کند؛ Sheetها قابل پیمایش‌اند.
- کامیت‌های کد/آزمون: `9de8f221`, `7125e828`, `895c7ad`, `21606a9`, `9946f15`, `4a64d50`, `4f65800`.
- Build روی SHA قبلی `21606a9f3050337d57c0ada2ca4c14c2febe907f` به‌علت توکن تعریف‌نشدهٔ `ArvinTheme.primarySoft` در Analyze/Visual و شاردها شکست کامپایل داشت؛ Follow-up Persistence run `42339727992` نیز به همان علت شکست خورد. توکن مرکزی در commit `4a64d50` تعریف شد؛ نتایج SHA قدیمی به SHA جدید منتقل نمی‌شوند.
- آخرین کد/آزمون پیش از این ثبت: `4f65800612bd0cce95448f39eee67d683e0e6504`. اجرای اختصاصی این SHA هنوز در فهرست GitHub ظاهر نشده؛ هیچ PASS برای آن ادعا نمی‌شود.
- فایل مستقل Master در پیوست‌های این گفتگو یا جست‌وجوی Library پیدا نشد؛ این یادداشت بر متن ابلاغ‌شده در گفتگو متکی است، نه بر ادعای مطالعهٔ فایل پیوست‌نشده.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` بدون تغییر؛ Merge و انتشار ممنوع. Device Smoke و پذیرش نصب واقعی هنوز مانع‌اند.
- **BLOCKED — RELEASE: NO-GO** تا Build، تمام شاردها، Provider، Persistence، Device Smoke و پذیرش گوشی واقعی روی یک SHA واحد PASS شوند.


## پیوست اصلاحیه Master — ۱۴۰۵/۰۸/۱۶

- کامیت تکمیلی محصول پس از ثبت قبلی: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`.
- سطح خالی کارت‌های فیلتر و لهجهٔ سربرگ پنل فیلتر نیز به توکن فیروزه‌ای/سطح خنثی مشترک منتقل شد؛ رنگ‌های برند غیر فیروزه‌ای در کنترل‌های فیلتر باقی نماند.
- آخرین کد پیش از این به‌روزرسانی اسناد: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`. نتیجهٔ CI این SHA تا لحظهٔ ثبت این پیوست هنوز قابل تأیید نیست؛ PASS از SHAهای قبلی به آن منتقل نمی‌شود.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ بدون Merge/انتشار؛ **BLOCKED — RELEASE: NO-GO**.
