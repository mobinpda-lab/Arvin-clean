# ماتریس ممیزی ۲۴ حوزه معماری و محصول آروین — Exact HEAD
**تاریخ:** ۱۴۰۵/۰۸/۱۲ — ۲۰۲۶-۱۱-۰۳
**Repository:** mobinpda-lab/Arvin-clean
**Branch:** fix/recovery-calendar-device-smoke-2026-10-31
**Source HEAD:** 35b5765a7964c063b01a5ef3366836064decc751
**PR #3052:** OPEN / DRAFT / UNMERGED
**main:** 45e4202b03a434459e4c021a04efa7e8396359db — unchanged
**Release:** BLOCKED — RELEASE: NO-GO
**قاعده ممیزی:** فقط Source/Test همین SHA مبناست؛ PASSهای SHAهای قدیمی برای HEAD فعلی معتبر نیستند. وضعیت VERIFIED فقط پس از شواهد آزمون اختصاصی و CI دقیق همین SHA قابل صدور است.
## تعریف وضعیت‌ها
- VERIFIED — کد و آزمون اختصاصی روی همین SHA با شاهد CI موفق.
- IMPLEMENTED / TEST MISSING — پیاده‌سازی دیده شده ولی آزمون اختصاصی/شاهد نهایی کافی نیست.
- PARTIAL — بخشی از قرارداد وجود دارد یا بخشی از مسیرها پوشش ندارند.
- NOT IMPLEMENTED — در مسیرهای بررسی‌شده پیاده‌سازی وجود ندارد.
- CONFLICT / LEGACY BLOCKER — قرارداد فعال/Schema/Runtime قدیمی با مشخصات محصول تعارض دارد.
## ماتریس ۲۴ حوزه
| # | حوزه | وضعیت | کد مستقیم | آزمون/شاهد لازم یا موجود |
|---:|---|---|---|---|
| 01 | پنج فیلتر Home به ترتیب RTL: زمان، مرکز، پروژه، دسته، برچسب | IMPLEMENTED / TEST MISSING | lib/main.dart — _homeFilterCards؛ Row با TextDirection.rtl و پنج کنترل | test/home_stat_filters_test.dart اکنون هر پنج عنوان را می‌سنجد؛ ترتیب مکانی راست‌به‌چپ هنوز assert نشده |
| 02 | «همه» داخل هر فیلتر و نبود چیپ مستقل «همه» | IMPLEMENTED / TEST MISSING | lib/main.dart — پنج Filter Sheet مستقل | آزمون جامع انتخاب/آزادسازی مستقل هر پنج فیلتر هنوز کامل نیست |
| 03 | نوار فیلتر در Short Viewport بدون Overflow و قابل پیمایش | IMPLEMENTED / TEST MISSING | lib/main.dart — SingleChildScrollView افقی با home-compact-filter-scroll | home_stat_filters_test.dart و device_feedback_home_regression_test.dart؛ دسترسی عملی به آخرین چیپ در عرض‌های متعدد هنوز اثبات نشده |
| 04 | AND بین ابعاد فیلتر و OR بین Tagهای انتخاب‌شده | IMPLEMENTED / TEST MISSING | lib/main.dart — فیلترهای مستقل زنجیره‌ای؛ lib/services/home_task_filter_matcher.dart — homeTaskMatchesAnySelectedTag | test/home_task_filter_matcher_test.dart برای OR؛ آزمون یکپارچه ترکیب Center+Project+Category+Tag هنوز لازم است |
| 05 | Advanced Search و Past در Search | NOT IMPLEMENTED | lib/services/task_search_service.dart — جست‌وجوی متنی؛ فیلترهای زمان/مرکز/پروژه/دسته/برچسب در مسیر بررسی‌شده وجود ندارد | task_search_service_test.dart فقط جست‌وجوی متنی را پوشش می‌دهد |
| 06 | Past در Home: Pending قبل از Completed و P1→P4 داخل هر گروه | IMPLEMENTED / TEST MISSING | lib/main.dart — visible؛ TaskListSortService.sortPast | test/task_list_sort_service_test.dart؛ آزمون widget مستقل Home برای وضعیت بعد از تیک تکمیل نیازمند تکمیل |
| 07 | Past در Reports با حفظ معیار اصلی گزارش و Priority ثانویه | IMPLEMENTED / TEST MISSING | lib/services/task_report_filter.dart — ReportTimePreset.past و sortPast؛ ترتیب گزارش‌های دیگر تاریخ‌محور و Priority ثانویه | test/services/task_report_filter_test.dart — آزمون Past و sort تاریخ/اولویت |
| 08 | نگاشت P1..P4 و رنگ‌های قرمز/آبی/کهربایی/خاکستری | IMPLEMENTED / TEST MISSING | lib/models/task.dart — TaskPriorityProduct؛ lib/arvin_colors.dart — priorityColor | test/task_priority_compatibility_test.dart؛ آزمون رنگ و همه سطوح در UI/تصویر هنوز کامل نیست |
| 09 | پیش‌فرض P2 در Task، فرم کامل و Quick Capture | IMPLEMENTED / TEST MISSING | Task constructor؛ lib/task_editor_dialog.dart؛ lib/quick_capture_dialog.dart | task_editor_dialog_test.dart و quick_capture_consecutive_tasks_test.dart |
| 10 | سورت P1→P4 در تمام فهرست‌ها، با حفظ معیارهای اصلی | PARTIAL | TaskListSortService؛ TaskReportFilter تاریخ را اصلی و Priority را ثانویه نگه می‌دارد | مصرف‌کنندگان تمام لیست‌ها هنوز با یک آزمون قراردادی سراسری پوشش داده نشده‌اند |
| 11 | Overdue فقط متن قرمز؛ آیکون، کادر و پس‌زمینه خنثی | IMPLEMENTED / TEST MISSING | lib/main.dart — کارت Home؛ سابقه اصلاح در CHANGELOG همین شاخه | تست رفتاری/بصری مستقل برای هر سه جزء خنثی هنوز به‌طور کامل ثبت نشده |
| 12 | دکمه انتقال موعد به امروز زیر فیلد موعد در Task Details | VERIFIED | lib/task_detail_page.dart — _summaryCard و task-detail-move-due-date-to-today | test/task_detail_due_date_action_test.dart؛ آزمون موقعیت، ذخیره موعد و حفظ داده‌های مستقل؛ Build شش شارد روی SHA قبلی PASS بوده، اما CI فعلی هنوز در حال اجراست |
| 13 | تکمیل از Home: خروج فوری از Active/Past و انتقال به Archive با حفظ تاریخچه | IMPLEMENTED / TEST MISSING | lib/main.dart و TaskBulkMutationService؛ رفتار ثبت‌شده در CHANGELOG | آزمون widget مستقل برای خروج فوری از Past و حفظ کامل history روی HEAD فعلی لازم است |
| 14 | Tap کارت Calendar فقط Task Details را باز کند؛ Edit فقط از Details | IMPLEMENTED / TEST MISSING | lib/calendar_page.dart — _ReminderCard.onTap؛ lib/widgets/canonical_calendar_launcher.dart — _openTaskDetailsFromCalendar؛ main.dart — _openTaskDetail | calendar_page_test.dart و canonical_calendar_launcher_test.dart افزوده شده‌اند؛ CI همین SHA هنوز نهایی نشده |
| 15 | Swipe کارت Calendar فقط Export صریح؛ Edit/Delete از Swipe حذف | IMPLEMENTED / TEST MISSING | lib/calendar_page.dart — _handleHorizontalSwipe فقط sync؛ CalendarSwipeSettingsService مقادیر قدیمی edit/trash را none می‌کند؛ Settings فقط sync/none | calendar_page_test.dart و calendar_swipe_settings_service_test.dart |
| 16 | Device Calendar export: Idempotent، isolated و failure-safe | IMPLEMENTED / TEST MISSING | calendar_outbound_sync_service.dart، calendar_sync_plan_service.dart، external_calendar_link_store.dart و Provider bridge | calendar_sync_plan_service_test.dart و system_calendar_export_identity_test.dart؛ Calendar Provider Run فعلی با خطای دریافت dependency Kotlin متوقف شده و هنوز PASS نیست |
| 17 | Import گوشی به Task مستقل محلی؛ تغییر/حذف خارجی Task واردشده را تغییر ندهد | IMPLEMENTED / TEST MISSING | calendar_inbound_sync_service.dart؛ مسیر Import صریح در main.dart و ExternalCalendarLinkStore | calendar_explicit_export_contract_test.dart و external_calendar_page_projection_test.dart؛ قطع مجوز/حذف خارجی نیازمند آزمون مستقل |
| 18 | Follow-up Record به تقویم آینده یا Device Calendar صادر نشود | PARTIAL | follow_up_calendar_projection.dart؛ CalendarPage فقط Task Record را برای Sync می‌پذیرد؛ Follow-up action به Task Details resolve می‌شود اما قابل Export نیست | follow_up_calendar_projection_test.dart و calendar_explicit_export_contract_test.dart؛ همه انواع رکورد/Reminder نیازمند آزمون ماتریسی هستند |
| 19 | مرکز→پروژه→دسته→کار و یک منبع داده مشترک | PARTIAL | ArvinCenter/CenterStore؛ ProjectPlan.centerId/ProjectStore؛ Task.category/tags؛ Storeها از پایگاه SQLite آروین استفاده می‌کنند | center_project_association_test.dart و project_store_test.dart؛ Category/Tag در مدل فعلی زیرمجموعه ساختاری Project نیستند |
| 20 | حذف امن Center/Project/Category/Tag دارای وابستگی | PARTIAL | CenterStore.delete؛ ProjectPlan.canDelete؛ TaskTaxonomyLifecycleService | center_project_association_test.dart و project_lifecycle_service_test.dart؛ پوشش جامع Active/Archive/Follow-up برای هر نوع وابستگی کامل نیست |
| 21 | تولید Project مستقل از Project Template | IMPLEMENTED / TEST MISSING | ProjectTemplateService.generateProjects؛ ProjectTemplateStore و TaskStore | project_template_service_test.dart تولید مستقل و جلوگیری از پروژه تکراری را می‌سنجد |
| 22 | Mid-Cycle Propagation فقط append-only، idempotent و بدون بازنویسی پیشرفت | IMPLEMENTED / TEST MISSING | ProjectTemplateService.propagateTask؛ TaskStore.appendTemplateTaskToProject؛ template_task_applications و transaction | project_template_service_test.dart اکنون تکمیل/آرشیو، Checklist، Reminder، Follow-up history، عضویت پروژه و اجرای تکراری را assert می‌کند؛ CI همین SHA لازم است |
| 23 | Report Center: فیلترهای ترکیبی، بدون Priority Filter، خروجی گروه‌بندی‌شده P1→P4 | IMPLEMENTED / TEST MISSING | report_center_page.dart؛ TaskReportFilter؛ TaskReport.priorityGroups؛ PDF و Text renderer | Priority Filter مستقل حذف شده؛ task_report_projection_test.dart و task_report_text_renderer_test.dart گروه‌بندی را می‌سنجند؛ PDF/Print/Share end-to-end و structured export هنوز کامل نیست |
| 24 | Vazirmatn، Bottom Navigation پنج‌گانه و Data Model مستقل از Legacy | CONFLICT / LEGACY BLOCKER | Vazirmatn در Theme و PDF؛ ArvinPrimaryNavigation اکنون خانه/تقویم/دفترچه/گزارش‌ها/بیشتر؛ اما Task/FollowUp مدل، Schema و Store هنوز فیلدهای Legacy را فعال نگه می‌دارند | primary_bottom_navigation_test.dart و report_typography_canonical_test.dart؛ آزمون حذف Runtime/Schema Legacy وجود ندارد |
## Legacy inventory و تصمیم مهاجرت
فهرست کامل مسیرها و تفکیک «Runtime فعال»، «سازگاری مهاجرت» و «فقط تست/Fixture» در سند همراه ثبت شده است:
docs/qa/ARVIN_LEGACY_REFERENCE_INVENTORY_2026-11-03.md
حذف مستقیم ستون/داده ممنوع است. Task.followUpDate و FollowUp.nextFollowUp زمان‌بندی‌اند، نه اثبات اقدام واقعی. فقط FollowUp.dateTime زمان رکورد تاریخی فعلی است؛ completedAt در FollowUp صرفاً getter alias به dateTime است و ستون جداگانه follow_ups.completed_at وجود ندارد.
## CI دقیق روی SHA مبنا قبل از Commit مستندسازی
| Lane | Run | وضعیت ثبت‌شده |
|---|---:|---|
| Build | 41620441195 | Analyze PASS؛ شش شارد هنوز در حال اجرا؛ APK matrix SKIPPED |
| Calendar Provider | 41620441200 | FAIL به علت عدم دریافت Kotlin 2.2.21 artifacts از Gradle Plugin Portal؛ این نتیجه PASS نیست و شاهد کد-محور نیست |
| Follow-up File Persistence | 41620441131 | SUCCESS |
| Device Smoke | 41620441101 | Prepare PASS؛ Boot و Navigation در حال اجرا؛ پنج Lane دیگر QUEUED |
| Draft Review APK | 41620441214 | IN PROGRESS؛ خروجی نهایی هنوز ثبت نشده |
این Runها روی Source SHA 35b5765a7964c063b01a5ef3366836064decc751 هستند. Commit مستندسازی بعدی فقط سند/CHANGELOG را تغییر می‌دهد؛ CI همان Source باید روی SHA جدید نیز دوباره بررسی شود.
## کنترل حاکمیتی
- PR #3052: OPEN / DRAFT / UNMERGED.
- main: بدون تغییر؛ SHA ثابت 45e4202b03a434459e4c021a04efa7e8396359db.
- Local Flutter tests: NOT RUN در محیط این اجرا.
- Draft Review APK، APK انتشار نیست.
- Release: **BLOCKED — RELEASE: NO-GO**.
