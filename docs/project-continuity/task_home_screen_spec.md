# TaskHomeScreen — Final Product and UI Specification

**Status:** APPROVED — PRODUCT OWNER SPECIFICATION  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052 — must remain OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO  
**Language / direction:** Persian / RTL  
**App font:** Vazirmatn; the Bismillah calligraphy is a separate Arabic-script display treatment.

This is the canonical Home-screen contract. It records the fourteen approved requirements below. It does not replace architecture, persistence, alarm, calendar, or release contracts.

## 1. Header positions
- Right: hamburger menu button, opening the navigation drawer.
- Center: Bismillah calligraphy above the bold «آروین» title and subtitle «مدیریت کارها، یادداشت‌ها و پیگیری‌ها».
- Left: general filter funnel, opening the Today, Timeless, Archive, and Trash views.
- No notification bell in the Home header.
- No standalone search icon in the Home header.

## 2. Bismillah treatment
Display the fully vocalized phrase «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ» above «آروین», using the dedicated `assets/images/branding/bismillah.svg` vector and a restrained, elegant Naskh-style treatment. This is the Home header artwork; `tafweez.svg` and «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ» do not belong to the Home header. Keep it visually delicate and minimal; it must not compete with the product title. This treatment is separate from the app's Vazirmatn UI typography.

## 3. Independent search field
- Keep a dedicated search field immediately below the header.
- Exact placeholder: «جستجو در کارها...».
- The search affordance belongs inside the search field; it must not return to the header.
- Search must not clear or mutate active filters or sorting.

## 4. One unified filter-and-sort row
The row is horizontally scrollable on narrow screens and uses this strict RTL order:
1. زمان
2. مرکز
3. پروژه‌ها
4. دسته‌ها
5. برچسب‌ها
6. مرتب‌سازی icon

The sort icon is at the far-left/end of this row. It is not part of the five filters and is not placed beside the general header filter.

## 5. Filter selection semantics
- Each filter category supports checkbox multi-selection.
- Selections within the same category combine with OR.
- Different filter categories combine with AND.
- Applying or clearing sorting must not reset selected filter chips.
- Applying or clearing a filter must not reset the selected sort order.
- The five concepts remain distinct: Time, Center, Project, Category, Tag.

## 6. General filter menu
The funnel icon in the header is a separate general-view shortcut. It exposes:
- Today
- Timeless / کارهای فاقد زمان
- Archive
- Trash
Do not duplicate these general views inside the five quick-filter categories.

## 7. Default sort key
- Default sort key: Follow-up Date, sourced from the canonical latest Follow-up record date.
- Ascending order is the initial direction; the sort sheet may switch to descending.
- Tasks without a Follow-up date remain after dated tasks in either direction.
- When Follow-up dates tie (including both missing), priority order is the deterministic secondary key, followed by stable Task ID.
- The Past group retains its dedicated overdue ordering: incomplete tasks first, then the existing priority/date policy. This exception preserves the established Past-group behavior and its existing regression test.
- Available explicit sort choices: Follow-up Date, Due Date, Latest Changes, and Title.

## 8. Date triad
Keep these concepts independent:
- **Due Date:** task due date; exclusively determines the time group.
- **Follow-up Date:** default Home sorting key.
- **Reminder Date:** alarm/notification trigger time; excluded from Home grouping and sorting.

A Reminder must never be treated as a Due Date or Follow-up Date.

## 9. Home time groups and order
Render the five groups in this order:
1. گذشته
2. امروز
3. فردا
4. آینده
5. فاقد زمان

Classification uses Due Date only. Completed tasks with past Due Dates remain in the Past group but must not be labelled as overdue active work.

## 10. Dynamic Jalali group headings
- Dated group headings display the full Persian weekday and Jalali date.
- Example: «امروز — پنج‌شنبه ۱۴ آبان ۱۴۰۵».
- Example: «فردا — جمعه ۱۵ آبان ۱۴۰۵».
- Calculate these values dynamically from the Iran-local date; examples are not hard-coded.
- Past and Timeless groups must not receive fabricated dates.
- Group headings are collapsible and include a calendar icon and a count badge.

## 11. Task cards
- Clean, lightweight white card surface, consistent with the approved shared card tokens.
- Circular completion control on the right in RTL.
- Persian task title is the most prominent card content.
- Compact taxonomy metadata is shown when present: Center, Project, Category; Tags remain compact.
- Optional Follow-up badge/preview appears only when a real Follow-up record exists.
- Preserve existing task actions, checklist progress, Reminder presentation, and canonical persistence behavior.

## 12. Sorting behavior inside groups
- Sorting changes display order only; it must not modify Task data.
- Keep the five time groups intact when sorting changes.
- Apply the selected sort within each applicable group.
- Do not use Reminder Date to sort or group tasks.
- Past-group special ordering remains as specified in item 7.

## 13. FAB and bottom navigation
- Purple Add (+) Floating Action Button at the bottom-right in RTL, above the navigation bar.
- Exactly five bottom tabs, from right to left:
  1. خانه (active on Home)
  2. تقویم
  3. دفترچه
  4. گزارش‌ها
  5. بیشتر
- «اقدام بعدی» is not a sixth primary tab; it remains accessible from «بیشتر» where applicable.

## 14. Explicit Home prohibitions and invariants
- No KPI cards, statistical summary cards, or dashboard metrics on Home.
- No standalone «کارهای من» tab or Home header; its management options remain under «بیشتر».
- No notification bell or standalone search icon in the Home header.
- No combining the sort action with the general filter menu or counting it as a sixth filter.
- No parallel Task storage/model, no mutation of data from filter/sort operations, and no conflation of Due Date, Follow-up Date, and Reminder Date.
- Preserve all existing tests and assertions. Do not delete, skip, weaken, bypass, or artificially time out tests.

## Canonical implementation surfaces
- Home page implementation: `lib/main.dart` — `HomePage` / `_HomePageState`.
- Filter and sort service: `lib/services/task_list_sort_service.dart`.
- Taxonomy metadata chips: `lib/widgets/taxonomy_icon_row.dart`.
- Primary navigation: `lib/widgets/arvin_primary_navigation.dart`.
- Existing Home widget coverage: `test/widgets/home_page_test.dart`, `test/task_list_sort_service_test.dart`, and the existing Home filter contract tests.

## Verification status rules
- A code change is IMPLEMENTED only after it is present on the authorized branch.
- A test or analyzer result is VERIFIED only for the exact SHA on which it ran.
- Existing workflow results from earlier SHAs do not transfer to later commits.
- Physical-device visual acceptance of the Naskh treatment and the complete Home layout remains NOT VERIFIED until evidence is captured and reviewed.
- PR #3052 remains OPEN / DRAFT / UNMERGED; `main` must remain untouched; release remains BLOCKED — RELEASE: NO-GO.


---

## تکمیل و تثبیت یکپارچه مصوبات صفحه اصلی — 2026-11-05

این بخش، اصلاحات نهایی مالک محصول را به قرارداد canonical صفحه اصلی اضافه می‌کند و همراه با سند مشخصات کار و تقویم، مرجع واحد زبان طراحی سه صفحه است.

### زبان طراحی مشترک
- الگوی بصری: الهام از Microsoft To Do؛ پس‌زمینه روشن و خلوت، کارت‌های سفید گوشه‌گرد، سطوح نرم، تگ‌ها و نشانگرهای رنگی شاداب اما کنترل‌شده.
- رابط کاملاً فارسی و RTL است؛ فونت رسمی رابط در تمام اجزا Vazirmatn است. خط نسخ هنری بسم‌الله صرفاً یک treatment نمایشی مستقل برای عبارت عربی است و جایگزین فونت رابط نیست.
- طراحی PRODUCT FIRST است: هیچ داشبورد آماری، KPI، کارت آمار یا تکرار عنوان «کارهای من» در Home اضافه نشود.

### هدر و جستجو
- راست: منوی همبرگری؛ مرکز: «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ» با خط نسخ ظریف در بالای «آروین» و زیرعنوان «مدیریت کارها، یادداشت‌ها و پیگیری‌ها»؛ چپ: فیلتر عمومی.
- فیلتر عمومی، نماهای مدیریتی «کارهای امروز»، «فاقد زمان»، «بایگانی» و «سطل زباله» و گزینه‌های مدیریتی تکمیلی را در بر می‌گیرد. این فهرست با پنج فیلتر سریع مستقل است.
- اعلان مستقل و آیکون مستقل جستجو در هدر وجود ندارد. کادر جستجوی اختصاصی، خوانا و دارای affordance جستجو داخل خود کادر، بلافاصله زیر هدر و بالای ردیف فیلترها قرار دارد.

### فیلترها و مرتب‌سازی
- ردیف افقی RTL در عرض کم اسکرول می‌شود؛ ترتیب دقیق از راست: «زمان»، «مرکز»، «پروژه‌ها»، «دسته‌ها»، «برچسب‌ها»، سپس آیکون مستقل مرتب‌سازی در انتهای چپ.
- پنج مورد اول فیلتر هستند؛ مرتب‌سازی فیلتر ششم نیست و ابزار مستقلی است.
- هر فیلتر چندانتخابی با چک‌باکس است. انتخاب‌های داخل یک گروه با OR و گروه‌های متفاوت با AND ترکیب می‌شوند. فیلتر فعال با رنگ معنایی شاداب و قابل تشخیص نمایش داده می‌شود.
- مرتب‌سازی پیش‌فرض بر اساس تاریخ آخرین Follow-up واقعی است؛ مرتب‌سازی فقط ترتیب نمایشی را تغییر می‌دهد و داده Task را mutate نمی‌کند. در نبود تاریخ Follow-up، کارهای فاقد تاریخ پس از موارد تاریخ‌دار قرار می‌گیرند. در تساوی، اولویت و سپس شناسه پایدار Task نقش tie-breaker دارند.
- در گروه «گذشته»، کارهای انجام‌نشده/تاریخ‌گذشته بالاتر از کارهای انجام‌شده قرار می‌گیرند. کار انجام‌شده با Due Date گذشته در گروه گذشته باقی می‌ماند، اما نباید به‌عنوان کار فعالِ overdue برچسب بخورد.
- سه تاریخ مستقل و غیرقابل جایگزینی‌اند: Due Date فقط مبنای گروه‌بندی زمانی؛ Follow-up Date مبنای مرتب‌سازی پیش‌فرض؛ Reminder Date فقط زمان فعال‌سازی یادآور و خارج از گروه‌بندی و مرتب‌سازی Home.

### گروه‌بندی و کارت‌ها
- ترتیب ثابت گروه‌ها: گذشته/تاریخ‌گذشته، امروز، فردا، آینده، فاقد زمان.
- سربرگ گروه‌های تاریخ‌دار، عنوان گروه و تاریخ کامل شمسی/روز هفته را به‌صورت پویا نشان می‌دهد؛ نمونه: «امروز — پنج‌شنبه ۱۴ آبان ۱۴۰۵». نمونه صرفاً نمایشی است و نباید hard-code شود.
- گروه‌ها collapse/expand می‌شوند و شمارنده تعداد کارها دارند. برای گروه‌های گذشته و فاقد زمان تاریخ ساختگی نمایش داده نشود.
- کارت Task سبک، سفید و گوشه‌گرد است؛ عنوان درشت، چک‌باکس انجام در سمت راست RTL، آخرین پیگیری فقط در صورت وجود رکورد واقعی، و نشانگرهای رنگی متناسب با مرکز/پروژه/دسته دارد. متادیتای taxonomy فشرده باقی بماند.
- FAB افزودن کار در پایین صفحه و بالای Bottom Navigation ثابت است؛ ثبت سریع بدون تاریخ، ساعت، یادآور یا اولویت پیش‌فرض اجباری انجام می‌شود.
- Bottom Navigation دقیقاً پنج گزینه از راست به چپ دارد: خانه، تقویم، دفترچه، گزارش‌ها، بیشتر. «اقدام بعدی» تب ششم نیست.

### مرز پذیرش
این سند مصوبه محصولی است، نه ادعای پیاده‌سازی یا پذیرش بصری. هر رفتار اجرایی و هر تست فقط با شواهد همان SHA قابل VERIFIED شدن است.


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
