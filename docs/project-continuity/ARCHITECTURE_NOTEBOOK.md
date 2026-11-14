> **الحاقیه معماری مصوب ۱۴ نوامبر ۲۰۲۶ — اولویت بالاتر از بندهای متعارض این سند:** روابط Center↔Project و Project↔Category هر دو Many-to-Many هستند. هر دو سمت هر رابطه می‌توانند صفر تا چند اتصال داشته باشند. Task برای Center، Project و Category به‌صورت مستقل صفر یا یک انتساب مستقیم دارد و Task مستقل مجاز است. قراردادهای تک‌والدی و زنجیره اجباری قدیمی در بخش‌های ۵ و ۸ SUPERSEDED هستند؛ متن تاریخی حذف نمی‌شود. جزئیات در `docs/ADR/ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M.md` ثبت شده است. این تصمیم به معنی پیاده‌سازی یا پذیرش Schema نیست.

**نسخه قرارداد محصول:** 2.1 — 2026-11-14

---
# معماری محصول: دفترچه یادداشت متصل آروین

**نسخه قرارداد محصول:** 2.0 — ۱۴۰۵/۰۸/۱۸ / 2026-11-09  
**مخزن/شاخه مرجع:** `mobinpda-lab/Arvin-clean` / `fix/recovery-calendar-device-smoke-2026-10-31`  
**وضعیت:** قرارداد محصولی مصوب؛ شکاف‌های پیاده‌سازی در جدول بخش ۸ ثبت شده‌اند.  
**مرز این ثبت:** مستندسازی؛ بدون تغییر کد، اسکیما، مهاجرت یا تست.

## ۱. فلسفه نوت‌بوک — مغز دوم متمرکز

دفترچه آروین فضای ثبت فوق‌سریع ایده‌ها، شماره تلفن‌ها، تجربه‌ها، دستورالعمل‌ها، نکات کاری و اطلاعات خام است؛ ثبت باید پیش از سازمان‌دهی انجام شود و کاربر را در لحظه ثبت مجبور به انتخاب مرکز، پروژه، دسته یا برچسب نکند.

- یادداشت می‌تواند مستقل باشد یا به یک کار متصل شود.
- متن و هویت یادداشت در اتصال، قطع اتصال، تبدیل یا حذف کار مرتبط نباید ناخواسته از بین برود.
- ذخیره‌سازی باید از مسیر canonical آروین و SQLite/Drift موجود ادامه یابد؛ ایجاد Store یا پایگاه داده موازی بدون تصمیم معماری ممنوع است.
- هدف ارگونومی تمام کنترل‌های اصلی لمسی حداقل **48dp** است.
- معیارهای میدانی شامل RTL، کیبورد باز، متن بلند و مقیاس متن دسترس‌پذیری و Samsung SM-A528B/DS است.

## ۲. قرارداد ثبت فوق‌سریع (Fast Capture)

1. با ورود به ثبت یادداشت، فوکوس ورودی و نمایش کیبورد باید بی‌درنگ و بدون لمس اضافه انجام شود.
2. ذخیره متن خام نباید به تکمیل فراداده وابسته باشد.
3. در **اولین ذخیره خودکار**، اگر عنوان مستقل هنوز تعیین نشده است، خط اول متن به‌عنوان عنوان اولیه ثبت می‌شود.
4. استخراج عنوان، متن اصلی را تغییر نمی‌دهد یا خط اول را از بدنه حذف نمی‌کند؛ بدنه باید تمام متن اولیه را حفظ کند.
5. پس از ثبت عنوان اولیه، ویرایش‌های بعدی متن نباید عنوان را خودکار بازنویسی کنند. تغییر عنوان بعدی فقط با ویرایش صریح عنوان انجام می‌شود.
6. ورودی خالی یا فقط شامل فاصله باید بدون ساخت عنوان/یادداشت جعلی مدیریت شود؛ معیار دقیق empty-state در UI باید آزمون شود.
7. هیچ‌یک از Center، Project، Category و Tag برای ذخیره یادداشت اجباری نیست.

## ۳. قرارداد اتصال دوطرفه یادداشت و کار

### ۳.۱ دو حالت یادداشت
- **مستقل:** یادداشت بدون اتصال به کار در نوت‌بوک باقی می‌ماند.
- **متصل به کار:** یادداشت دارای پیوند صریح و قابل پیمایش به یک کار است؛ شناسه یادداشت و شناسه کار دو هویت مستقل و پایدارند.

### ۳.۲ قواعد بقای داده و قطع اتصال
- حذف یک کار، یادداشت‌های متصل به آن را حذف نمی‌کند. فقط رابطه اتصال حذف/غیرفعال می‌شود و یادداشت مستقل در نوت‌بوک باقی می‌ماند.
- قطع ارتباط از صفحه جزئیات کار فقط Link را لغو می‌کند؛ محتوای یادداشت، عنوان، شناسه و زمان‌های آن حذف یا بازنویسی نمی‌شوند.
- عملیات unlink نباید به حذف soft/hard یادداشت یا پاک‌کردن متن آن تبدیل شود.
- پیمایش از یادداشت به کار و از کار به یادداشت باید از رابطه canonical استفاده کند؛ نمایش اتصال باید قابل تشخیص باشد.
- هیچ Foreign Key با رفتار cascade نباید باعث حذف یادداشت در اثر حذف کار شود. سیاست detach باید صریح و آزمون‌شده باشد.

### ۳.۳ تبدیل یادداشت به کار جدید
- تبدیل/ساخت کار جدید باید متن کامل و دقیق یادداشت مبدأ را حفظ کند؛ حداقل عنوان و محتوای کامل باید در Task مقصد قابل بازیابی باشند.
- برای جلوگیری از اتلاف داده، ایجاد Task جدید نباید محتوای یادداشت مبدأ را به‌صورت ضمنی پاک یا کوتاه کند.
- شناسه Task جدید مستقل است؛ رابطه منشأ/مقصد در صورت نیاز باید قابل ردیابی باشد.
- این قرارداد با تبدیل فعلی درجا و حفظ همان Task ID یکسان نیست؛ پیاده‌سازی باید پس از طراحی مهاجرت و تست بقای داده انجام شود.

## ۴. قرارداد پنج فیلتر سراسری آروین

ترتیب بصری و معنایی از راست به چپ، بدون جابه‌جایی:

**زمان → مرکز → پروژه → دسته → برچسب**

- فیلتر زمان، عضو اول مجموعه پنج‌گانه است؛ بیرون از این مجموعه شمرده نمی‌شود.
- انتخاب چندگانه در هر بُعد باید با موتور فیلتر مشترک و قواعد یکسان آروین انجام شود.
- OR درون یک بُعد و AND میان ابعاد، مطابق قرارداد مشترک فیلترهای آروین اعمال شود.
- ایجاد گزینه جدید از داخل فیلتر باید آن را پس از ایجاد به‌صورت خودکار انتخاب کند.
- Notebook نباید فیلترهای مستقل و ناسازگار با Home/Reports بسازد.

## ۵. قرارداد روابط داده و ثبت سریع

### ۵.۱ کاردینالیتی انتخاب‌ها

| بُعد | انتخاب مجاز برای هر کار | فیلد/مسیر فعلی مشاهده‌شده |
|---|---|---|
| مرکز | صفر یا یک | `Task.centerId` |
| پروژه | صفر یا یک | عضویت canonical در `ProjectPlan.itemIds`؛ تخصیص از `TaskProjectAssignmentService` |
| دسته | صفر یا یک | `Task.category` |
| برچسب | صفر تا چند | `Task.tags` و رابطه Drift در `task_tags` |

«تک‌انتخابی» به معنی حداکثر یک مقدار برای هر Task است؛ یک مرکز/پروژه/دسته می‌تواند توسط چند Task استفاده شود. پروژه در Task به‌صورت `projectId` موازی ذخیره نمی‌شود؛ منبع رابطه همان Project membership canonical است.

### ۵.۲ رفتار Quick Capture
- انتخاب مرکز، پروژه و دسته اختیاری است؛ برچسب نیز اختیاری است.
- ذخیره Task بدون هیچ‌یک از این انتخاب‌ها مجاز است و Task در Inbox/بدون دسته‌بندی باقی می‌ماند.
- انتخاب پروژه باید به مرکز مالک همان پروژه محدود شود.
- تغییر/پاک‌کردن مرکز، پروژه ناسازگار را پاک می‌کند.
- انتخاب دسته باید فقط دسته‌های متعلق به پروژه انتخاب‌شده را نشان دهد؛ پاک‌کردن پروژه، دسته ناسازگار را نیز پاک می‌کند.
- زنجیره انتخاب و فیلتر وابستگی: **مرکز → پروژه‌های همان مرکز → دسته‌های همان پروژه**.
- این زنجیره، قرارداد هدف محصول است. در کد فعلی، پروژه دارای `centerId` است اما جدول دسته‌ها رابطه `projectId` ندارد؛ بنابراین پیاده‌سازی آبشاری کامل هنوز تأیید نشده است.

## ۶. قرارداد موتور الگو و تکثیر عمیق (Deep Clone Engine)

### ۶.۱ مواردی که باید تکثیر شوند
- عنوان کار.
- ساختار دسته‌بندی: مرکز، پروژه و دسته با حفظ روابط canonical و ایجاد/انتخاب مرجع معتبر.
- متن خام Checklist؛ همه موارد در کار جدید تیک‌نخورده باشند.
- برچسب‌ها.
- اولویت P1 تا P4.
- افراد پیش‌فرض/مرتبطی که صریحاً در الگو تعریف شده‌اند؛ این رابطه به‌تنهایی به معنی «مسئول» نیست.

### ۶.۲ مواردی که نباید تکثیر شوند
- سوابق تاریخی Follow-up.
- لاگ تغییرات و رویدادهای اجرایی.
- وضعیت انجام‌شده، `completedAt` و وضعیت‌های تکمیل آیتم‌های چک‌لیست.
- شناسه‌های Task/Reminder/Follow-up و سوابق اجرای قبلی.
- هیچ تاریخچه یا اعلان قبلی نباید به کار جدید متصل شود.

### ۶.۳ انتقال هوشمند تاریخ و یادآورها
- کاربر تاریخ مبنای جدید را هنگام ساخت از الگو تعیین می‌کند.
- برای هر موعد یا یادآور مبدأ، فاصله زمانی آن نسبت به تاریخ مبنای الگو حفظ می‌شود.
- قاعده محاسبه: `offset = sourceDateTime - sourceAnchor` و `newDateTime = newBaseDateTime + offset`.
- برای تمام‌روز، روز تقویمی جابه‌جا می‌شود و ساعت ساختگی ایجاد نمی‌شود؛ برای زمان‌دار، فاصله و ساعت انتخاب‌شده حفظ می‌شود.
- هر Reminder در مقصد شناسه جدید دارد و از Task جدید زمان‌بندی می‌شود؛ هیچ آلارم مبدأ کپی یا دوباره فعال نمی‌شود.
- تمام محاسبات باید با قرارداد زمان محلی و تقویم canonical آروین انجام شوند و در مرز روز/ماه/سال و سال کبیسه آزمون شوند.

## ۷. تقویم سه‌گانه سراسری

تقویم آروین سه‌گانه است و **شمسی پیش‌فرض** باقی می‌ماند:

1. هجری شمسی (Jalali / Solar Hijri) — پیش‌فرض انتخابگر و نمایش اصلی.
2. هجری قمری (Hijri / Islamic lunar).
3. میلادی (Gregorian).

- تمام انتخابگرهای تاریخ در Quick Capture، Task Editor/Details، Reminder، Follow-up، Calendar و سایر مسیرهای انتخاب تاریخ باید هر سه تقویم را ارائه دهند.
- انتخاب هر تقویم باید به یک تاریخ canonical داخلی تبدیل شود؛ نوع تقویم نمایشی نباید شناسه، timestamp یا فرمت ذخیره‌سازی داخلی را تغییر دهد.
- نمایش تقویم اصلی و سلول‌های تقویم مطابق مشخصات مصوب: شمسی برجسته و میلادی/قمری ثانویه.
- هم‌ترازی قمری باید از مبنای مصوب تقویم رسمی ایران و تنظیمات اختلاف +۱/−۱/تطابق رسمی پیروی کند. ادعای «تطابق رسمی» فقط در صورت اتصال و اثبات منبع رسمی مجاز است؛ در غیر این صورت وضعیت باید صادقانه اعلام شود.
- تبدیل رفت‌وبرگشت، مرز روز، کبیسه، محدوده مجاز انتخاب و تاریخ‌های تمام‌روز باید تست شوند.
- کد فعلی انتخابگر مشترک شمسی و میلادی را دارد؛ گزینه قمری در آن وجود ندارد. پوشش سراسری سه‌گانه هنوز پیاده‌سازی/تأیید نشده است.

## ۸. Gap Analysis — وضع موجود در برابر قرارداد مصوب

| حوزه | شواهد فعلی در HEAD مبنا | شکاف/ریسک | اقدام آینده؛ بدون تغییر در این فاز |
|---|---|---|---|
| مدل Notebook | `Task.notebookKind` و `CanonicalNotebookRepository`؛ ذخیره روی Task canonical | Note مستقل از Task نیست؛ پیوند مستقل Note↔Task وجود ندارد | طراحی رابطه پایدار و مستقل بدون ایجاد Store موازی |
| حذف کار و unlink | رابطه صریح Note↔Task در مدل فعلی مشاهده نشد | رفتار بقای یادداشت متصل در حذف/قطع اتصال قابل اثبات نیست | طراحی detach غیرمخرب و تست حذف Task، unlink و restore |
| Fast Capture | `createNote` مسیر canonical دارد | فوکوس فوری کیبورد و قاعده «عنوان فقط در اولین auto-save» در مسیر فعلی اثبات نشده | پیاده‌سازی و تست فوکوس، عنوان اولیه، حفظ متن و عدم بازنویسی عنوان |
| فیلتر Notebook | فیلترهای Center/Project/Category/Tag در صفحه دیده می‌شوند | فیلتر زمان و ترتیب پنج‌گانه/کامپوننت مشترک هنوز یکپارچه و تأییدشده نیست | اتصال به موتور مشترک با ترتیب Time/Center/Project/Category/Tag |
| روابط taxonomy | مرکز و پروژه مرتبط‌اند؛ تخصیص پروژه از سرویس canonical انجام می‌شود؛ دسته یک رشته و Tag چندمقداری است | جدول `taxonomy_categories` فقط نام دسته دارد و `project_id` ندارد | افزودن رابطه دسته↔پروژه فقط با مهاجرت افزایشی، backup و آزمون سازگاری |
| Quick Capture | Center/Project/Category/Tag کنترل و انتخاب اختیاری دارند | آبشار کامل مرکز→پروژه→دسته هنوز در داده و UI احراز نشده | اعمال فیلتر وابسته و reset فرزند ناسازگار؛ حفظ Inbox بدون فراداده |
| Task Template | جدول `task_templates` در G1 Drift v16؛ مدل دارای category/priority/checklist/tags/people/reminders و snapshot مرکز/پروژه است | anchor تاریخ و offset موعد/Reminder ذخیره نمی‌شود؛ Reminder فقط hour/minute دارد | طراحی ذخیره offset و مبنای الگو با مهاجرت غیرمخرب |
| Clone فعلی | `TaskCloneService` شناسه جدید و تاریخچه Follow-up/تکمیل را پاک می‌کند | dueDate مطلق بدون جابه‌جایی باقی می‌ماند و taskReminders خالی می‌شود؛ Deep Clone زمان‌محور کامل نیست | ساخت موتور clone با تاریخ مبنای جدید، offset و Reminderهای مستقل |
| تقویم | `PersianDatePicker` شمسی و مسیر میلادی دارد؛ Calendar spec سه تاریخ را تعریف کرده است | انتخاب قمری و پوشش همه انتخابگرها در کد فعلی وجود ندارد | یک Calendar Adapter مشترک و تست سه‌گانه در همه مسیرها |
| Drift و مهاجرت | G1DriftSchema نسخه 16؛ task_templates و روابط پروژه/برچسب وجود دارند | جدول Note-Link و رابطه دسته-پروژه در شواهد schema فعلی نیست | فقط پس از طراحی schema، backup/restore و migration test؛ بدون DDL مخرب |

## ۹. معیارهای پذیرش آینده

1. بازشدن ثبت سریع همراه فوکوس/کیبورد و ذخیره بدون فراداده.
2. استخراج عنوان فقط در اولین ذخیره خودکار؛ حفظ کامل بدنه و عدم تغییر عنوان در ویرایش‌های بعدی.
3. حداقل 48dp برای اهداف لمسی و آزمون RTL در 360/390/412dp.
4. یادداشت مستقل/متصل، پیمایش دوطرفه، unlink غیرمخرب و بقای یادداشت پس از حذف کار.
5. تبدیل به Task جدید با حفظ دقیق متن مبدأ و شناسه‌های مستقل.
6. آزمون کاردینالیتی 0..1 برای Center/Project/Category و 0..n برای Tags؛ Quick Capture بدون فراداده.
7. آزمون زنجیره Center→Project→Category و پاک‌سازی فرزند ناسازگار.
8. آزمون Deep Clone برای فیلدهای مشمول/مستثنی، checklist خام تیک‌نخورده، شناسه جدید و انتقال offset موعد/Reminder.
9. آزمون سه تقویم و تبدیل رفت‌وبرگشت در تمام انتخابگرهای تاریخ.
10. اجرای کامل Analyze، Visual، شش شارد، APKها، Provider، Persistence و Device Smoke روی یک SHA؛ پذیرش فیزیکی Samsung SM-A528B/DS مستقل باقی می‌ماند.

## ۱۰. حاکمیت

- این سند قرارداد محصول و Gap Analysis است؛ وجود تصمیم مصوب به معنی پیاده‌سازی یا PASS نیست.
- این به‌روزرسانی فقط مستندات را تغییر می‌دهد؛ هیچ فایل `.dart`، تست، اسکیما یا migration تغییر نمی‌کند.
- هیچ تستی حذف، Skip، تضعیف یا دور زده نمی‌شود.
- شاخه مجاز: `fix/recovery-calendar-device-smoke-2026-10-31`.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` دست‌نخورده.
- **BLOCKED — RELEASE: NO-GO**.

**مراجع کد/قرارداد:** `lib/models/task.dart`, `lib/services/canonical_notebook_repository.dart`, `lib/notebook_page.dart`, `lib/services/task_project_assignment_service.dart`, `lib/models/task_template.dart`, `lib/services/task_clone_service.dart`, `lib/services/task_template_store.dart`, `lib/services/g1_drift_schema.dart`, `lib/widgets/persian_date_picker.dart`, `docs/project-continuity/calendar_ui_ux_spec.md`.


## 11. REV10 relationship graph supersession — 2026-11-14

The approved current model is not a single-parent tree:

- Center↔Project and Project↔Category are Many-to-Many.
- Task→Center, Task→Project and Task→Category are independent optional 0..1 assignments.
- Task↔Tag remains Many-to-Many.
- Standalone Tasks are valid.

The M2M migration candidate is `lib/services/g1_many_to_many_hierarchy_migration.dart` on PR #3463, currently based on #3384 head `310c0e20e3447c488c1e1c102c38bea5040708ca`. It creates `center_projects` and `project_categories`, but is not yet connected to the canonical G1 database lifecycle or all product repositories.

Source audit findings on that base:
- G1DriftSchema remains version 19 and does not invoke the candidate migration.
- TaskStore rewrites Task rows without the new direct relationship columns.
- ProjectStore rewrites Project rows and does not preserve/write the new junction relations; its bulk Project delete conflicts with the candidate's RESTRICT foreign keys once edges exist.
- CenterStore deletion checks only legacy `projects.center_id`.
- Category management remains on `taxonomy_categories`; no canonical Category entity CRUD integration is proven.
- Backup/Restore does not yet serialize and restore both junction relations.

These are integration blockers, not permission to create parallel stores. Extend the existing canonical SQL ownership path only. Keep the legacy columns, `project_items` and `taxonomy_categories` until consumer parity and D01–D05 are accepted.


## COMMAND 07-A.2.79 — Architecture integration audit

The approved graph is not yet the sole operational model. Existing code still contains `projects.center_id`, `project_items`, `taxonomy_categories`, new `categories`, and new junction tables. Decide one canonical owner and compatibility boundary before UI integration. Avoid duplicate Task assignment sources. Migration transaction boundaries must be separated or refactored; nested BEGIN is unsafe.


## COMMAND 07-A.2.79 — Live audit checkpoint (2026-11-14)

- Main: `45e4202b03a434459e4c021a04efa7e8396359db` (unchanged/read-only).
- PR #3463: OPEN / DRAFT; branch `rev10-m2m-v19-test-expansion`; Head `190dfd6dd0d487dbcafd85e13c5309db061b47af`; Base `310c0e20e3447c488c1e1c102c38bea5040708ca`.
- PR #3448: OPEN / DRAFT. Issue #3458: OPEN.
- Exact-head #3463: Build 43577665573 PENDING/no jobs reported; Device Smoke 43577665873 QUEUED; Follow-up Persistence 43577665629 SUCCESS; Orchestrator and PR Wakeup SUCCESS; Draft Review APK SKIPPED. Combined status has no entries; no current-head APK/Smoke acceptance artifact.
- Base SHA `310c0e20...`: Build 43575749904 FAILURE; Analyze, Visual, Debug/Release/Staging APK PASS; six test shards total 1,409 passed / 41 failed. Base artifacts do not validate #3463 Head.
- G1DriftSchema remains v19; the v19→v20 helper is not called by canonical installation. Its own transaction cannot be nested inside the existing install transaction.
- TaskStore rewrite omits the new direct relationship columns; ProjectStore still uses `projects.center_id` and `project_items`; CenterStore deletion checks only `projects.center_id`.
- Category remains split between `taxonomy_categories` and migration-created `categories`. Canonical Category CRUD/relation UI is not verified.
- Physical Backup/Restore parity for both junction tables and migration exceptions is NOT VERIFIED. D01–D05 and seven Device Smoke scenarios are NOT ACCEPTED.
- No app code/tests/workflows were changed in this audit. No merge, release, deployment, Main edit, branch deletion, history rewrite, workflow cancellation or test weakening.
