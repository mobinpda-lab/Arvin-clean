# قرارداد «کارهای برگزیدهٔ امروز» و فیلترهای پیگیری
تاریخ: 2026-11-08
مخزن: mobinpda-lab/Arvin-clean
شاخهٔ مجاز: fix/recovery-calendar-device-smoke-2026-10-31
SHA مبنای ممیزی: c4444930d1b8053d2081ad3ccd35b40cd0190888
PR: #3052 — باید OPEN / DRAFT / UNMERGED بماند.
وضعیت انتشار: BLOCKED — RELEASE: NO-GO

## تصمیم‌های مصوب مالک محصول
### دو معنای مستقل امروز
- «امروزِ تقویمی» فقط بر اساس تاریخ محلی دستگاه/تقویم و قواعد canonical موعد کار و تقویم محاسبه می‌شود.
- «کارهای برگزیدهٔ امروز» فهرست تمرکزی مستقلی است؛ موعد امروز به‌تنهایی انتخاب ایجاد نمی‌کند.
- انتخاب و برداشتن انتخاب باید در مدل canonical کار ذخیره شود و پس از بستن/بازکردن برنامه باقی بماند.
- فیلد علاقه‌مندی (isFavorite) جایگزین انتخاب روزانه نیست. پیش از تغییر مدل باید ساختار canonical و مسیر ذخیره‌سازی بررسی شود.
- هیچ شمارش یا فیلتر نباید این دو مفهوم را ادغام کند.

### فیلترهای پیگیری
- در حالت «پیگیری‌دار»، زمان بر اساس timestamp خود رکورد FollowUp اعمال می‌شود، نه Task.dueDate.
- در مدل جاری timestamp canonical رکورد، FollowUpRecord.completedAt است؛ نام قدیمی dateTime فقط سازگاری منبعی دارد.
- فیلترهای پنج‌گانه با ترتیب راست‌به‌چپ زمان، مرکز، پروژه، دسته، برچسب حفظ می‌شوند؛ منطق OR داخل هر بُعد و AND بین ابعاد است.
- Task، FollowUpRecord و Person سه موجودیت مستقل‌اند. خروجی فیلتر نباید Task را به تعداد FollowUpها تکثیر کند؛ گزارش رکوردی می‌تواند هر FollowUp را یک ردیف مستقل نشان دهد و تعداد کارها باید بر اساس شناسهٔ یکتای Task محاسبه شود.
- پیوند شخص فقط از personIds رکورد پیگیری و فهرست canonical اشخاص resolve می‌شود؛ برای شناسهٔ حذف‌شده فقط قرارداد تاریخی «شخص حذف‌شده» مجاز است.
- نام رسمی سلسله‌مراتب: مرکز > پروژه > دسته > کار.
- Bottom Sheet مشترک ReusableMultiSelectFilterBottomSheet و الگوی دسترس‌پذیری/ظاهر موجود باید بازاستفاده شوند.
- مالکیت tafweez.svg فقط با تقویم است و ارتباطی با هدر Home ندارد.

## ممیزی کد در SHA مبنا
| بخش | شواهد در مخزن | نتیجه |
|---|---|---|
| Home — امروز تقویمی | lib/main.dart: گروه‌بندی کارها بر اساس Task.dueDate؛ lib/services/home_list_projection.dart: HomeListScope.today نیز موعد کار را می‌سنجد | منطق موعد تقویمی وجود دارد؛ نام/نمای مستقل «برگزیده‌های امروز» و انتخاب پایدار در UI دیده نشد |
| HomeTodayProjection | lib/services/home_today_projection.dart از legacyHomeFollowUpDate/آخرین پیگیری استفاده می‌کند؛ test/services/home_today_projection_test.dart همین رفتار را آزمون می‌کند | یک projection قدیمی با نام Today وجود دارد که از نظر معنا با امروز تقویمی متفاوت است و نیازمند تعیین مصرف‌کننده/تفکیک روشن است |
| مدل و ذخیره‌سازی | lib/models/task.dart فیلد isFavorite دارد اما فیلد مستقل انتخاب روزانه ندارد؛ lib/services/task_store.dart فیلدهای Task را در Drift و JSON envelope می‌خواند/می‌نویسد؛ lib/services/g1_drift_schema.dart نسخهٔ 15 و جدول tasks را تعریف می‌کند | انتخاب روزانهٔ مستقل در مدل/اسکیما/مسیر persistence در این SHA احراز نشد |
| فیلترهای Home | lib/main.dart و lib/home/home_filter_ui.dart پنج فیلتر را نشان می‌دهند؛ lib/services/home_task_filter_matcher.dart OR برچسب‌ها را اعمال می‌کند؛ فیلترهای ابعاد به‌صورت زنجیره‌ای اعمال می‌شوند | پنج بُعد Home وجود دارد؛ حفظ ترتیب/منطق باید با آزمون مشترک بین‌بخشی تثبیت شود |
| فیلترهای گزارش | lib/report_center_page.dart پنج کنترل فیلتر و ReusableMultiSelectFilterBottomSheet دارد؛ lib/services/task_report_filter.dart hasFollowUp را فقط با وجود/عدم وجود رکورد می‌سنجد و زمان را با _matchesTime(task.dueDate, ...) اعمال می‌کند | فیلتر پیگیری در گزارش از timestamp رکورد استفاده نمی‌کند؛ شکاف قطعی |
| گزارش پیگیری و شخص | lib/services/completed_follow_up_report_projection.dart یک ردیف برای هر رکورد می‌سازد؛ lib/services/person_follow_up_report_projection.dart رکوردها را با personIds به فهرست اشخاص وصل می‌کند؛ Report Center تعداد Task یکتا را از taskId می‌سنجد | تفکیک رکورد/کار/شخص در projectionهای گزارش تا حدی وجود دارد و باید با فیلتر زمان یکپارچه شود |
| دفتر پیگیری | lib/follow_up_office_page.dart تمام رکوردهای قابل‌نمایش را از TaskStore جمع می‌کند و فقط سوییچ «منتظر پاسخ» دارد | فیلتر زمان و پنج بُعد مشترک در این بخش وجود ندارد؛ شکاف بین‌بخشی |
| تقویم | lib/calendar_page.dart انتخاب روز و فیلتر منبع تقویم را دارد؛ این ممیزی هنوز یکپارچگی پنج فیلتر taxonomy/پیگیری را در UI تقویم اثبات نکرده است | نیازمند بررسی و آزمون تکمیلی؛ فعلاً PASS اعلام نمی‌شود |

## آزمون‌ها و شواهد CI در SHA مبنا
- Workflow run: 42479797712، همهٔ checkهای گزارش‌شده با head SHA برابر c4444930d1b8053d2081ad3ccd35b40cd0190888.
- quality(analyze): SUCCESS.
- apk(debug): SUCCESS.
- Follow-up file-backed SQLite persistence: SUCCESS.
- android-calendar-provider: SUCCESS.
- quality(test-0 تا test-5): هر شش شارد FAILURE در snapshot بررسی‌شده.
- visual: FAILURE؛ آزمون Task Details overflow به میزان 37px در task-detail-due-date-card را گزارش کرده است.
- apk(release) و apk(staging) هنگام snapshot هنوز IN_PROGRESS بودند؛ نتیجهٔ نهایی آن‌ها در این ممیزی احراز نشده است.
- از log شارد test-0: 213 passed / 12 failed؛ از log شارد test-1: 184 passed / 5 failed. این اعداد فقط مربوط به همان شاردها هستند و جمع کل suite نیستند.
- آزمون‌های مرتبط موجود: test/services/home_today_projection_test.dart، test/home_list_projection_test.dart، test/services/task_report_filter_test.dart، test/task_report_filter_test.dart، test/services/completed_follow_up_report_projection_test.dart، test/services/person_follow_up_report_projection_test.dart، test/follow_up_office_page_test.dart، test/report_center_page_test.dart، test/home_filter_contract_test.dart، test/home_filter_boolean_logic_test.dart و test/reusable_multi_select_filter_bottom_sheet_test.dart.

## وضعیت اجرا در این ثبت
این commit صرفاً ثبت قرارداد و ممیزی شواهد است؛ هیچ ادعایی دربارهٔ پیاده‌سازی انتخاب پایدار روزانه، فیلتر زمانی رکورد پیگیری، اتصال بین‌بخشی یا قبولی آزمون‌های جدید ندارد. کد و تست‌ها در این ثبت تغییر نکرده‌اند. موارد بالا باید در همان شاخه، با آزمون‌های هدفمند و اعتبارسنجی exact-SHA تکمیل شوند.

## حاکمیت
PR #3052 باید OPEN / DRAFT / UNMERGED بماند. main تغییر نکند. ادغام، انتشار یا ادعای Release-Ready ممنوع است. هیچ آزمونی حذف، skip، bypass یا تضعیف نشود.
