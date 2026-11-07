# قرارداد داده‌ای الگوهای کار و پروژه — G1 v11

**تاریخ:** ۱۴۰۵/۰۸/۱۴ — 2026-11-05  
**دامنه:** Issue #823 / PR #3052  
**وضعیت:** قرارداد اجرایی پیاده‌سازی‌شده؛ آزمون exact-SHA و پذیرش CI هنوز تأیید نشده است.  
**مرجع ذخیره‌سازی:** SQLite/Drift موجود در G1؛ بدون database، model store یا repository موازی.

## ۱. اصل تفکیک

الگو یک **تعریف قابل استفاده مجدد** است، نه کپی Task اجرایی. تبدیل از Task یا Project، منبع را فقط می‌خواند و رکورد اصلی را تغییر نمی‌دهد. ساخت Task/Project از الگو شناسه‌های جدید می‌سازد و هیچ تاریخچه اجرایی را بازپخش نمی‌کند.

## ۲. قرارداد Task Template

| داده مبدأ | رفتار در الگو | رفتار هنگام ساخت Task جدید |
|---|---|---|
| نام الگو و عنوان Task | نام الگو جدا از عنوان Task ذخیره می‌شود؛ هر دو الزامی‌اند | عنوان Task از تعریف الگو می‌آید |
| توضیح، دسته، اولویت، برچسب‌ها | حفظ می‌شوند | به Task جدید منتقل می‌شوند |
| Checklist | متن هر مورد حفظ؛ نشانگر انجام [x]/[ ] حذف می‌شود؛ checklistEnabled حتی برای فهرست خالی حفظ می‌شود | همه موارد با وضعیت انجام‌نشده ساخته می‌شوند؛ تنظیم فعال/غیرفعال حفظ می‌شود |
| People | فهرست PersonReference موجود عیناً به‌عنوان افراد مرتبط حفظ می‌شود؛ این داده به معنی «مسئول» نیست | همان مراجع افراد منتقل می‌شوند؛ هیچ نقش مسئول جدیدی استنباط نمی‌شود |
| Reminderهای مستقل | عنوان، تمام‌روز، ساعت/دقیقه، فعال/غیرفعال و sequence حفظ می‌شود؛ شناسه و تاریخ تقویمی Reminder منتقل نمی‌شود | شناسه جدید برای هر Reminder ساخته می‌شود؛ کاربر تاریخ جدید را با تقویم شمسی انتخاب می‌کند و ساعت تعریف‌شده اعمال می‌شود |
| Task.reminderDate قدیمی | اگر معادل مهاجرت‌یافته در taskReminders موجود نباشد، فقط ساعت/دقیقه با عنوان «یادآور اصلی» ثبت می‌شود؛ تاریخ اجرا منتقل نمی‌شود | همانند Reminder مستقل، با تاریخ جدید کاربر ساخته می‌شود |
| Recurrence | frequency، interval، count، active و trackingLevel حفظ می‌شوند | قاعده تکرار حفظ می‌شود؛ تاریخ مبدأ و پایان اجرای قبلی بازپخش نمی‌شود |
| مرکز/پروژه | فقط snapshot نام و شناسه canonical ذخیره می‌شود؛ شناسه فقط در صورت یکتایی رابطه مبدأ ثبت می‌شود | صرفاً اطلاعات منشأ هستند؛ Task جدید خودکار به مرکز/پروژه قبلی متصل نمی‌شود |
| Due Date و تاریخ‌ها | dueDate، تاریخ تقویمی Reminder، createdAt، updatedAt، completedAt، followUpDate و timestampهای اجرا حذف می‌شوند | Due Date خالی می‌ماند تا کاربر در Task جدید تعیین کند؛ تاریخ‌های ایجاد/ویرایش جدیدند |
| تاریخچه و وضعیت اجرا | followUps، وضعیت تکمیل، آرشیو/سطل زباله، occurrenceHistory و checklistOccurrences منتقل نمی‌شوند | Task جدید باز، مستقل و بدون تاریخچه ساخته می‌شود |

**قید مهم:** Task.people فقط افراد مرتبط است؛ تا زمانی که مدل/رابطه canonical برای assignment مسئول وجود ندارد، UI نباید شخصی را به‌عنوان مسئول معرفی کند. کارت مسئول فعلاً صادقانه وضعیت نامشخص را نشان می‌دهد.

## ۳. قرارداد Project Template

- از ProjectTemplateStore، ProjectTemplateService و جدول‌های موجود project_templates و project_template_tasks استفاده می‌شود.
- تبدیل Project از صفحه جزئیات، Project و Taskهای اصلی را فقط می‌خواند؛ عنوان، رنگ، centerId و تعریف پایه Taskها در الگوی جدید ذخیره می‌شود.
- تعریف پایه Project Template مطابق مدل موجود شامل عنوان، توضیح، دسته، برچسب و Checklist است؛ مدل Task اجرایی یا Task Template موازی ایجاد نمی‌شود.
- تولید پروژه از الگوی پروژه از مسیر سرویس موجود انجام می‌شود؛ Taskهای تولیدشده شناسه جدید می‌گیرند.

## ۴. Schema و مهاجرت

- نسخه G1 از ۱۰ به ۱۱ ارتقا یافته است.
- جدول مستقل task_templates در همان G1 ایجاد می‌شود.
- ستون checklist_enabled INTEGER NOT NULL DEFAULT 0 برای ارتقای غیرمخرب الگوهای قبلی اضافه می‌شود.
- center_id_snapshot و project_id_snapshot نیز به‌صورت nullable و سازگارانه حفظ می‌شوند.
- نصب schema برای هر QueryExecutor به‌صورت idempotent و serialized اجرا می‌شود تا mount هم‌زمان دو تب الگو باعث nested BEGIN نشود.
- داده‌های Task و Project Template موجود حذف یا بازنویسی نمی‌شوند؛ مقدار پیش‌فرض Checklist برای الگوهای قدیمی false است.

## ۵. مسیرهای عملیاتی

1. **Task Template از فهرست:** تنظیمات ← الگوها ← الگوهای کار ← انتخاب Task موجود ← نام‌گذاری و تأیید ← ذخیره در task_templates ← نمایش در فهرست الگوها.
2. **Task Template از جزئیات:** مشخصات کار ← «تبدیل به الگو» ← نام‌گذاری/تأیید ← ذخیره واقعی در همان Store.
3. **ساخت Task از الگو:** الگوهای کار ← «ساخت کار» ← تأیید و انتخاب تاریخ Reminder در صورت نیاز ← ساخت Task با شناسه جدید و تاریخچه خالی.
4. **Project Template از فهرست:** پروژه‌ها ← انتخاب Project ← صفحه مشخصات پروژه ← «تبدیل پروژه به الگو» ← تأیید ← ذخیره از طریق ProjectTemplateService و ProjectTemplateStore.
5. **مشاهده/استفاده Project Template:** تنظیمات ← الگوها ← الگوهای پروژه ← مشاهده الگو و Taskهای پایه؛ تولید پروژه از مسیر عملیاتی موجود.

## ۶. شواهد کد و تست مورد انتظار

- Schema/model/store: lib/services/g1_drift_schema.dart, lib/models/task_template.dart, lib/services/task_template_store.dart.
- تبدیل و استفاده Task: lib/task_template_management_page.dart, lib/task_detail_page.dart.
- تبدیل Project: lib/project_detail_page.dart, lib/projects_page.dart, lib/services/project_template_service.dart.
- دو تب: lib/settings_page.dart, lib/task_template_management_page.dart.
- تست داده/مهاجرت: test/services/task_template_store_test.dart, test/services/g1_drift_schema_test.dart.
- تست تعامل: test/task_template_management_page_test.dart, test/project_detail_page_test.dart, test/settings_template_tabs_test.dart, test/task_detail_master_screen_test.dart.

تا زمان اجرای تست‌ها و CI روی SHA نهایی، همه قابلیت‌های جدید **پیاده‌سازی‌شده اما تأییدنشده** محسوب می‌شوند. PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main تغییر نمی‌کند؛ انتشار **BLOCKED — RELEASE: NO-GO** است.


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
