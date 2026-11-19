# قرارداد داده‌ای الگوهای کار و موتور تکثیر عمیق — G1 Drift v16

**نسخه قرارداد محصول:** 2.0 — ۱۴۰۵/۰۸/۱۸ / 2026-11-09  
**دامنه:** PR #3052 / شاخه مجاز  
**وضعیت:** قرارداد محصولی مصوب؛ شکاف پیاده‌سازی و پذیرش در این سند صریح است.  
**مرجع ذخیره‌سازی:** SQLite/Drift موجود در G1؛ بدون پایگاه داده، مدل، Store یا Repository موازی.

> این نسخه، قراردادهای متعارض قبلی درباره حذف Due Date از الگو و انتخاب دستی مجدد تاریخ Reminder را supersede می‌کند. قرارداد جدید، انتقال offset از تاریخ مبنای الگو به تاریخ مبنای جدید را الزامی می‌کند. این تغییر فعلاً مستندسازی است و به معنی اجرای آن در کد نیست.

## ۱. اصل تفکیک الگو و Task اجرایی

الگو یک تعریف قابل استفاده مجدد است. هر بار استفاده از الگو باید یک Task جدید با شناسه جدید و وضعیت اجرایی مستقل بسازد. منبع الگو نباید mutate شود و هیچ تاریخچه اجرای قبلی نباید به Task جدید منتقل شود.

## ۲. موارد تکثیرشونده

| داده | قرارداد |
|---|---|
| عنوان | عنوان Task از الگو کپی می‌شود؛ شناسه Task جدید است. |
| ساختار طبقه‌بندی | Center، Project و Category هرکدام حداکثر یک انتخاب؛ روابط canonical حفظ شوند. |
| Checklist | متن خام همه موارد حفظ شود؛ همه موارد در Task جدید تیک‌نخورده باشند؛ وضعیت occurrence کپی نشود. |
| Tags | تمام برچسب‌های تعریف‌شده در الگو با رابطه canonical به Task جدید منتقل شوند. |
| Priority | مقدار دقیق P1/P2/P3/P4 حفظ شود. |
| People | افراد پیش‌فرض/مرتبطی که صریحاً در الگو ثبت شده‌اند حفظ شوند؛ این رابطه به‌تنهایی مسئولیت یا assignee ایجاد نمی‌کند. |
| Due Date | فاصله زمانی نسبت به تاریخ مبنای الگو حفظ و نسبت به تاریخ مبنای جدید بازتولید شود. |
| Reminders | تمام تعریف‌های Reminder و فاصله زمانی آن‌ها حفظ؛ شناسه جدید و زمان‌بندی مستقل در Task جدید ساخته شود. |

## ۳. موارد غیرقابل تکثیر

- سوابق Follow-up و تاریخچه تعاملات.
- Change Log، audit trail و رویدادهای اجرایی Task مبدأ.
- وضعیت تکمیل Task، `completedAt` و وضعیت‌های انجام‌شده Checklist.
- شناسه‌های Task، Reminder، Follow-up و alarm مبدأ.
- وضعیت‌های occurrence یا نتیجه اجرای قبلی.
- هیچ Reminder مبدأ نباید پس از Clone در مقصد فعال یا دوباره زمان‌بندی شود.

## ۴. محاسبه هوشمند تاریخ و Reminder

در زمان ساخت از الگو، کاربر تاریخ مبنای جدید را انتخاب می‌کند. تاریخ مبنای الگو (`sourceAnchor`) و فاصله زمانی هر موعد/یادآور باید در تعریف الگو یا snapshot قابل بازیابی باشد.

```
offset = sourceDateTime - sourceAnchor
newDateTime = newBaseDateTime + offset
```

قواعد:
- همه Due Dateها و Reminderها نسبت به همان مبنا جابه‌جا شوند؛ تاریخ مطلق قبلی نباید بدون تبدیل باقی بماند.
- All-Day باید به‌صورت تاریخ‌محور جابه‌جا شود و ساعت ساختگی دریافت نکند.
- Reminder زمان‌دار باید فاصله و ساعت خود را حفظ کند.
- هر Reminder در مقصد شناسه جدید، Task ID مقصد و sequence مستقل داشته باشد.
- مرز نیمه‌شب، ماه/سال، سال کبیسه، اختلاف روز تقویم و timezone باید تست شوند.
- اگر تاریخ مبنای مبدأ یا offset برای داده قدیمی قابل بازیابی نیست، سیستم نباید تاریخ را حدس بزند؛ باید مسیر سازگارانه و قابل توضیح ارائه کند.

## ۵. رابطه با قراردادهای کار و taxonomy

- Center، Project و Category برای هر Task انتخاب تک‌مقداری و اختیاری دارند؛ Tags چندانتخابی‌اند.
- زنجیره هدف انتخاب‌ها: Center → Projectهای همان Center → Categoryهای همان Project.
- Quick Capture اجازه ذخیره Task بدون Center/Project/Category/Tag را می‌دهد.
- عضویت Project باید از مسیر canonical Project membership انجام شود؛ فیلد موازی `projectId` روی Task ساخته نشود.
- Checklist جدید از متن خام الگو ساخته می‌شود و تمام موارد در ابتدا باز/تیک‌نخورده‌اند.

## ۶. وضع پیاده‌سازی مشاهده‌شده در HEAD ممیزی‌شده

- G1 Drift schema در `lib/services/g1_drift_schema.dart` نسخه 16 است و جدول `task_templates` دارد.
- `TaskTemplate` فعلی category، priority، checklist، tags، people، reminders، recurrence و snapshot شناسه/نام Center و Project را نگه می‌دارد.
- `TaskTemplateReminder` فعلی title، all-day، hour، minute، enabled و sequence را نگه می‌دارد؛ offset روز/زمان نسبت به anchor ندارد.
- مدل TaskTemplate فعلی فیلد Due Date یا source anchor ندارد.
- `TaskCloneService.clone` شناسه جدید می‌سازد، وضعیت تکمیل و Follow-up history را پاک می‌کند؛ اما Due Date مطلق را بدون انتقال باقی می‌گذارد و `taskReminders` را خالی می‌کند.
- بنابراین موتور فعلی بخشی از اصول جداسازی تاریخچه را رعایت می‌کند، اما قرارداد جدید Deep Clone و انتقال offset را کامل اجرا نمی‌کند.
- `ProjectPlan.centerId` وجود دارد؛ اما `taxonomy_categories` فعلی فقط نام دسته را نگه می‌دارد و project_id ندارد. وابستگی دسته به پروژه هنوز در schema مشاهده نشده است.

## ۷. برنامه شکاف و مهاجرت آینده

| شکاف | اقدام آینده | کنترل ایمنی |
|---|---|---|
| نبود sourceAnchor و Due Date در TaskTemplate | افزودن فیلدهای مبنا و offsetهای Due Date به مدل/جدول الگو | migration افزایشی، مقدار nullable و حفظ رکوردهای قبلی |
| Reminder بدون offset | ذخیره offset روز/زمان، all-day، ساعت، enabled و sequence | شناسه‌های جدید و عدم بازپخش alarm مبدأ |
| Clone بدون جابه‌جایی موعد | ساخت Deep Clone Engine بر پایه sourceAnchor/newBaseDate | تست دقیق offset و تمام‌روز |
| دسته بدون Project relation | طراحی رابطه دسته↔پروژه و قواعد آبشاری | حفظ دسته‌های قدیمی و migration قابل rollback |
| افراد پیش‌فرض | حفظ canonical Person IDs بدون استنباط نقش مسئول | عدم تبدیل Person مرتبط به assignee |
| داده‌های قدیمی فاقد anchor | سیاست fallback شفاف و بدون حدس | عدم تولید تاریخ/Reminder ساختگی |

هیچ migration یا DDL مخربی مجاز نیست. پیش از هر تغییر schema باید backup/restore، شمارش و ممیزی داده واقعی، مهاجرت آزمایشی و rollback test انجام شود.

## ۸. مسیرهای کد و تست مرتبط

- Schema/model/store: `lib/services/g1_drift_schema.dart`, `lib/models/task_template.dart`, `lib/services/task_template_store.dart`.
- Clone: `lib/services/task_clone_service.dart`.
- Project membership: `lib/services/task_project_assignment_service.dart`, `lib/models/goal_project.dart`.
- Tests: `test/services/task_template_store_test.dart`, `test/services/g1_drift_schema_test.dart`, `test/project_template_service_test.dart`, `test/task_detail_template_conversion_test.dart`.

## ۹. حاکمیت و پذیرش

این سند در این مرحله فقط قرارداد محصول و Gap Analysis را ثبت می‌کند. هیچ فایل کد، تست، اسکیما یا migration در این تغییر مستنداتی اصلاح نمی‌شود. هیچ تستی حذف، Skip، تضعیف یا دور زده نمی‌شود.

PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` دست‌نخورده؛ **BLOCKED — RELEASE: NO-GO**.


## 10. WAVE 4 REV8 relational ownership addendum

The approved SQL-only architecture requires Recurrence, Occurrence and each Occurrence checklist to have independent relational ownership.

Current implementation adds:
- `task_recurrence_rules`: one normalized recurrence rule per owning Task, with frequency, interval, start/end, count, active and tracking-level fields.
- `task_occurrences`: stable occurrence identity, Task FK, scheduled timestamp, status, completion timestamp, result and ordinal.
- `occurrence_checklist_items`: per-occurrence checklist rows with independent order and state.

TaskStore reads/writes these relations; legacy Task envelope maps are migrated and parity-checked before being removed from newly written envelopes. Backup JSON remains a transfer representation only.

**Still open:** Task/Project legacy envelopes, Task Template JSON arrays, Project Template task JSON arrays, and complete template field-by-field normalization. These are not SQL-only COMPLETE. Preserve unknown fields and legacy sources until full parity and backup/restore acceptance.
