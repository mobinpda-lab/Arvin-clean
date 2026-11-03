# ماتریس ممیزی معماری و محصول آروین — نقطه کنترل دقیق SHA
**تاریخ:** ۱۴۰۵/۰۸/۱۲ (۲۰۲۶-۱۱-۰۳)
**مخزن:** mobinpda-lab/Arvin-clean
**شاخه:** fix/recovery-calendar-device-smoke-2026-10-31
**SHA ممیزی‌شده:** 469f9a5b0140bb69f6f415e1ad8ad0eee28e2983
**PR:** #3052 — OPEN / DRAFT / UNMERGED
**main:** 45e4202b03a434459e4c021a04efa7e8396359db (بدون تغییر)
**انتشار:** BLOCKED — RELEASE: NO-GO
**روش:** بررسی مستقیم Source و Test روی SHA فوق؛ گزارش‌های مبتنی بر SHAهای قدیمی صرفاً سابقه‌اند. وجود تست در مخزن به‌تنهایی PASS نیست؛ شاهد CI فقط به Runهای همین SHA متصل شده است.
## راهنمای وضعیت
- **VERIFIED:** رفتار/کد و آزمون اختصاصی روی همین SHA قابل اتصال به CI است.
- **IMPLEMENTED / TEST MISSING:** پیاده‌سازی مشاهده شده، اما آزمون اختصاصی/شاهد رفتاری کافی نیست.
- **PARTIAL:** بخشی از قرارداد وجود دارد یا با بخش دیگری تعارض دارد.
- **NOT IMPLEMENTED:** پیاده‌سازی در مسیرهای بررسی‌شده مشاهده نشد.
- **CONFLICT / LEGACY BLOCKER:** مدل/Schema/Runtime فعال با قرارداد مالک محصول تعارض دارد.
## ماتریس ۲۴ حوزه پذیرش ابلاغیه مالک محصول
| # | حوزه پذیرش | وضعیت روی SHA | مسیر و نماد مستقیم | آزمون مرتبط | شاهد CI روی همین SHA |
|---:|---|---|---|---|---|
| 01 | ترتیب پنج فیلتر Home از راست به چپ: زمان، مرکز، پروژه، دسته، برچسب | PARTIAL | lib/main.dart — _homeFilterCards؛ پنج کنترل و RTL | test/home_stat_filters_test.dart هنوز چهار کنترل را assert می‌کند؛ مرکز و ترتیب کامل اثبات نشده | Build 41614740315: شش شارد PASS؛ پوشش دقیق ترتیب نامشخص |
| 02 | گزینه داخلی «همه» و نبود چیپ مستقل «همه» | IMPLEMENTED / TEST MISSING | lib/main.dart — _showTimeFilterSheet، _showCenterFilterSheet، _showProjectFilterSheet، _showCategoryFilterSheet، _showTagFilterSheet | home_stat_filters_test.dart؛ آزمون جامع مستقل برای هر پنج فیلتر یافت نشد | Build 41614740315 PASS؛ رفتار تک‌تک فیلترها مستقل اثبات نشده |
| 03 | عدم Overflow نوار فیلتر در صفحه کوتاه | IMPLEMENTED / TEST MISSING | lib/main.dart — _homeFilterCards با SingleChildScrollView افقی و home-compact-filter-scroll | home_stat_filters_test.dart و device_feedback_home_regression_test.dart صفحه کوتاه را می‌سنجند، اما دسترسی/اسکرول هر پنج فیلتر را مستقل assert نمی‌کنند | Build 41614740315 PASS |
| 04 | منطق AND بین فیلترها و OR داخل انتخاب چندگانه | PARTIAL | lib/main.dart — visible: فیلترها زنجیره‌ای AND؛ _tagFilters.every(tags.contains) همه برچسب‌ها را هم‌زمان لازم می‌کند | home_stat_filters_test.dart آزمون OR برچسب‌های Home ندارد؛ Reports آزمون OR مستقل دارد | Build 41614740315 PASS، اما قرارداد OR در Home اثبات نشده |
| 05 | جست‌وجوی پیشرفته و Past در جست‌وجو | NOT IMPLEMENTED | lib/services/task_search_service.dart — جست‌وجوی متنی Task/Follow-up؛ فیلتر مستقل زمان/مرکز/پروژه/دسته/برچسب در این سرویس وجود ندارد | test/task_search_service_test.dart فقط جست‌وجوی متنی را پوشش می‌دهد | Build 41614740315 PASS؛ جست‌وجوی پیشرفته اثبات نشده |
| 06 | Past در Home با Pending قبل از Completed و P1→P4 در هر گروه | IMPLEMENTED / TEST MISSING | lib/main.dart — visible به TaskListSortService.sortPast می‌رود؛ lib/services/task_list_sort_service.dart وضعیت تکمیل و سپس اولویت را مرتب می‌کند | test/task_list_sort_service_test.dart تست Past دارد؛ تست مستقل Home کامل نیست | Build 41614740315 PASS |
| 07 | Past در Reports با حفظ معیارهای اختصاصی گزارش | IMPLEMENTED / TEST MISSING | lib/services/task_report_filter.dart — پس از اعمال فیلتر گزارش، در ReportTimePreset.past از sortPast استفاده می‌کند | test/task_report_filter_test.dart؛ ترکیب‌های Past نیازمند تکمیل | Build 41614740315 PASS |
| 08 | چهار سطح آیزنهاور، نگاشت داده قدیمی و رنگ‌های مصوب | IMPLEMENTED / TEST MISSING | lib/models/task.dart — TaskPriorityProduct؛ lib/arvin_colors.dart — priorityColor | test/task_priority_compatibility_test.dart نگاشت legacy/P1..P4 را دارد؛ آزمون رنگ/نمایش کامل نیست | Build 41614740315 PASS |
| 09 | پیش‌فرض P2 در Task جدید، فرم کامل و Quick Capture | IMPLEMENTED / TEST MISSING | Task constructor، ArvinTaskEditorDialog و QuickCaptureDialog مقدار پیش‌فرض TaskPriority.medium دارند | test/quick_capture_consecutive_tasks_test.dart؛ test/task_editor_dialog_test.dart | Build 41614740315 PASS |
| 10 | سورت P1→P4 در تمام لیست‌ها، بدون تخریب سورت ثانویه | PARTIAL | lib/services/task_list_sort_service.dart اولویت را قبل از معیار عمومی اعمال می‌کند؛ task_report_filter.dart تاریخ را اصلی و اولویت را ثانویه نگه می‌دارد | task_list_sort_service_test.dart؛ task_report_filter_test.dart؛ تمام مصرف‌کنندگان فهرست ممیزی نشده‌اند | Build 41614740315 PASS |
| 11 | کار تاریخ‌گذشته: فقط متن قرمز، سطح/کادر/آیکون خنثی | IMPLEMENTED / TEST MISSING | CHANGELOG همین شاخه ادعای اصلاح Wave 7.304 دارد؛ مسیر کارت Home در lib/main.dart نیازمند تست رفتاری مستقیم و مرور رنگ است | تست اختصاصی متن/آیکون/سطح در این ممیزی کامل استخراج نشد | Build 41614740315 PASS؛ پذیرش بصری NOT VERIFIED |
| 12 | دکمه انتقال موعد به امروز زیر فیلد موعد در Task Details | VERIFIED | lib/task_detail_page.dart — _summaryCard؛ دکمه task-detail-move-due-date-to-today زیر ردیف موعد است | test/task_detail_due_date_action_test.dart موقعیت، ذخیره موعد و حفظ Reminder/Checklist/Follow-up را assert می‌کند | Build 41614740315 شش شارد PASS |
| 13 | تکمیل از Home: خروج فوری از Active/Past و آرشیو با حفظ تاریخچه | IMPLEMENTED / TEST MISSING | CHANGELOG همین شاخه Wave 7.304 رفتار archive را ثبت کرده؛ مسیرهای Home در lib/main.dart و TaskBulkMutationService نیازمند تطبیق دقیق‌اند | تست‌های رگرسیون Home ذکرشده در CHANGELOG؛ نام تست و اجرای سناریو هنوز به‌صورت مستقل ثبت نشده | Build 41614740315 PASS؛ پذیرش محصولی NOT VERIFIED |
| 14 | Tap کارت تقویم باید Task Details را باز کند، نه Edit | PARTIAL | lib/calendar_page.dart — _ReminderCard.build: برای Task از onEditTask و برای Follow-up از onEdit استفاده می‌کند؛ Long-press منوی اکشن را باز می‌کند | test/calendar_page_test.dart تعامل کارت را پوشش می‌دهد، اما مسیر Details مطلوب را اثبات نمی‌کند | Calendar Provider 41614740147 PASS؛ این Run جایگزین تست Routing نیست |
| 15 | Swipe انتقال به Device Calendar فقط در تقویم؛ Home فقط از Details | IMPLEMENTED / TEST MISSING | lib/calendar_page.dart — _handleHorizontalSwipe؛ lib/task_detail_page.dart اکشن صریح خروجی دارد؛ main.dart مسیر Export عادی/خودکار را محدود کرده | test/calendar_explicit_export_contract_test.dart | Build 41614740315 PASS؛ Calendar Provider 41614740147 PASS |
| 16 | Device Calendar: Idempotent، Isolated، Failure-safe | IMPLEMENTED / TEST MISSING | calendar_outbound_sync_service.dart، calendar_sync_plan_service.dart، external_calendar_link_store.dart و Android Provider bridge | calendar_sync_plan_service_test.dart، system_calendar_export_identity_test.dart، calendar_provider_android_contract_test.dart | Calendar Provider 41614740147 SUCCESS |
| 17 | Import از گوشی به Task مستقل محلی؛ تغییر/حذف خارجی Task واردشده را دستکاری نکند | IMPLEMENTED / TEST MISSING | calendar_inbound_sync_service.dart مسیر reconciliation را no-op نگه می‌دارد؛ Import صریح در main.dart Task محلی ذخیره و لینک واردات را ثبت می‌کند | calendar_explicit_export_contract_test.dart، external_calendar_page_projection_test.dart | Calendar Provider 41614740147 SUCCESS؛ قطع دسترسی/حذف خارجی نیازمند آزمون مستقل |
| 18 | Follow-up Record به تقویم آینده یا Device Calendar صادر نشود | PARTIAL | calendar_page.dart شناسه‌های تاریخی را در projection فیلتر می‌کند؛ Sync در _handleHorizontalSwipe فقط Task Record را می‌پذیرد؛ مسیرهای Legacy نیازمند ممیزی یکپارچه‌اند | follow_up_calendar_projection_test.dart، calendar_explicit_export_contract_test.dart | Calendar Provider 41614740147 SUCCESS؛ عدم صدور همه انواع Follow-up مستقل اثبات نشده |
| 19 | مرکز→پروژه→دسته→کار، نام‌گذاری مرکز و منبع داده مشترک | PARTIAL | ArvinCenter، CenterStore، ProjectPlan.centerId، ProjectStore و Task.category/tags؛ دسته/برچسب در مدل Task هستند و زیرمجموعه ساختاری Project نیستند | center_project_association_test.dart، project_store_test.dart | Build 41614740315 PASS؛ اتصال سلسله‌مراتبی کامل اثبات نشده |
| 20 | حذف امن Center/Project/Category/Tag دارای ارجاع | PARTIAL | TaskTaxonomyLifecycleService حذف Category/Tag ارجاع‌دار را مسدود می‌کند؛ ProjectPlan.canDelete و CenterDeleteBlocked وجود دارند | project_lifecycle_service_test.dart، center_project_association_test.dart؛ پوشش Active/Archive/Follow-up کامل نیست | Build 41614740315 PASS |
| 21 | Project Templates و تولید پروژه‌های مستقل | IMPLEMENTED / TEST MISSING | project_template_service.dart، project_template_store.dart، project_template_management_page.dart | project_template_service_test.dart تولید مستقل و جلوگیری از پروژه تکراری را پوشش می‌دهد | Build 41614740315 PASS |
| 22 | Safe Mid-Cycle Propagation: فقط Task جدید، append-only و idempotent | IMPLEMENTED / TEST MISSING | ProjectTemplateService.propagateTask و TaskStore.appendTemplateTaskToProject؛ transaction و template_task_applications مانع تکرار هستند | project_template_service_test.dart تکمیل Task قبلی و عدم ایجاد Task تکراری را می‌سنجد؛ حفظ Follow-up history/checklist occurrence assertion صریح ندارد | Build 41614740315 PASS |
| 23 | Report Center: فیلترهای ترکیبی و خروجی PDF/متن/ساختاریافته | PARTIAL | report_center_page.dart، TaskReportFilter، TaskReportPdfRenderer؛ فیلتر مرکز/قالب/کار/پروژه/دسته/برچسب/بازه وجود دارد؛ فیلتر Priority نیز از قبل در UI/Filter model حاضر است و باید با تصمیم عدم فیلتر اولویت تعیین تکلیف شود | report_center_page_test.dart، task_report_filter_test.dart، task_report_pdf_renderer_test.dart، task_report_text_renderer_test.dart | Build 41614740315 PASS؛ Print/Share/structured export end-to-end NOT VERIFIED |
| 24 | Vazirmatn، Bottom Navigation پنج‌گانه و Legacy/data model | CONFLICT / LEGACY BLOCKER | Vazirmatn در Theme و PDF renderer است؛ ArvinPrimaryNavigation پنج مقصد دارد اما برچسب خانه «امروز» است. Task هنوز followUpEnabled/followUpDate و FollowUp.nextFollowUp/reminderDate را فعال نگه می‌دارد؛ Schema/TaskStore نیز می‌خوانند/می‌نویسند | primary_bottom_navigation_test.dart، report_typography_canonical_test.dart، task_legacy_follow_up_migration_test.dart؛ آزمون پاک‌سازی کامل Legacy وجود ندارد | Draft Review APK 41614740340 SUCCESS (فقط APK آزمایشی)؛ Build 41614740315 PASS؛ Legacy Gate مسدود |
## فهرست Legacy مشاهده‌شده روی SHA
| محل | ارجاع فعال | اثر فعلی | تصمیم ایمن |
|---|---|---|---|
| lib/models/task.dart | followUpEnabled، followUpDate | constructor، JSON parse/serialize و مدل زنده | حذف Runtime فقط پس از طراحی سازگاری JSON و تست Backup/Restore |
| lib/models/task.dart — کلاس FollowUp | nextFollowUp، reminderDate؛ completedAt فقط getter alias به dateTime است | serialization و parser همچنان مقدارهای آینده/Reminder را حمل می‌کنند | Follow-up Record فقط با زمان اقدام واقعی نگه داشته شود؛ مقادیر آینده به Reminder واقعی منتقل نشوند |
| lib/services/g1_drift_schema.dart | tasks.follow_up_enabled، tasks.follow_up_date، follow_ups.next_follow_up، follow_ups.reminder_date | ستون‌های Schema نسخه ۸ | حذف فیزیکی فعلاً ممنوع؛ backup/rollback، مهاجرت داده معتبر و تست DB قدیمی لازم است |
| lib/services/task_store.dart | درج/خواندن follow_up_enabled و envelope قدیمی | وابستگی Runtime و Persistence فعال | ابتدا مسیر خواندن/نوشتن جدید و adapter سازگار؛ سپس migration مستقل |
| lib/task_editor_dialog.dart | حفظ existing.followUpEnabled/followUpDate در ویرایش غیرمرتبط | Legacy در مسیر Edit زنده می‌ماند | پس از تعیین قرارداد JSON و جلوگیری از حذف ناخواسته |
| تست‌ها/Fixtures | task_detail_due_date_action_test.dart و تست‌های تاریخچه، داده Legacy می‌سازند و حفظ آن را assert می‌کنند | بخشی از قرارداد تست فعلی هنوز Legacy را الزام می‌کند | فقط پس از مهاجرت غیرمخرب و با حفظ داده واقعی بازنویسی شوند؛ حذف/Skip ممنوع |
## طرح مهاجرت غیرمخرب — بدون اجرای حذف در این Commit
1. Inventory کامل ارجاعات در Model/Schema/DAO/Repository/Serialization/UI/Tests/Fixtures/Reports/Backup را تکمیل و دسته‌بندی کنید: (الف) ستون/فیلد صرفاً ذخیره‌شده، (ب) Runtime فعال، (ج) مقدار آینده، (د) سابقه اقدام واقعی.
2. نسخه پشتیبان سازگار و مسیر Rollback را پیش از هر تغییر Schema تعریف کنید؛ روی کپی دیتابیس قدیمی تست ارتقا/بازگشت انجام شود.
3. مقدارهای nextFollowUp و followUpDate آینده هرگز به Follow-up Record تبدیل نشوند. فقط شواهد اقدام واقعی با timestamp معتبر می‌تواند به رکورد تاریخی منتقل شود؛ هیچ مقدار حدسی ساخته نشود.
4. Runtime/UI/serialization جدید را در Commit مستقل بازنشسته کنید، در حالی که Reader سازگاری داده قدیمی را بدون فعال‌کردن رفتار آینده نگه می‌دارد.
5. فقط پس از اثبات عدم نیاز، Migration نسخه‌دار برای حذف ستون‌ها طراحی شود؛ تست قدیمی→جدید، rollback، Backup/Restore و عدم از دست رفتن Reminder/Follow-up الزامی است.
## شواهد CI دقیق روی SHA ممیزی‌شده
| Workflow | Run | نتیجه در آخرین Poll | تفسیر |
|---|---:|---|---|
| Arvin Build | 41614740315 | SUCCESS؛ Analyze و شش شارد Test همگی SUCCESS؛ APK matrix SKIPPED | تست‌های Build سبز؛ APK این Workflow ساخته نشد |
| Calendar Provider Acceptance | 41614740147 | SUCCESS | پذیرش Provider در CI؛ نه اثبات همه رفتارهای تقویم/Details |
| Follow-up File Persistence | 41614740328 | SUCCESS | آزمون Persistence مستقل موفق |
| Draft Review APK | 41614740340 | SUCCESS | APK آزمایشی/Review؛ نه APK انتشار با امضای تولید |
| Device Smoke | 41614740157 | IN PROGRESS | Boot PASS، Navigation PASS، Quick Capture PASS، Task Lifecycle PASS؛ Calendar Segmented View IN PROGRESS، Reminder/Vazirmatn IN PROGRESS، Follow-up Persistence QUEUED |
## کارهای مستقل باقی‌مانده و ترتیب Commit
- **Commit B — Filters:** اصلاح OR برچسب‌ها در Home، افزودن Center به active-filter state، آزمون پنج فیلتر و صفحه کوتاه.
- **Commit C — Calendar Routing:** افزودن callback بازکردن Task Details برای Tap کارت تقویم؛ Edit فقط از داخل Details؛ آزمون Routing برای Task و Follow-up.
- **Commit D — Project Templates:** تقویت آزمون حفظ تمام Taskهای قبلی، completed/archived، checklist، Reminder و Follow-up history در Mid-cycle Propagation.
- **Commit E — Reports:** تعیین تکلیف فیلتر Priority موجود، تکمیل Past/خروجی‌ها و آزمون end-to-end PDF/Print/Share/structured.
- **Commit F — Legacy:** طراحی و اجرای تدریجی Retirement و Migration نسخه‌دار؛ هیچ ستون/داده‌ای در این مرحله حذف نمی‌شود.
- Date-jump action در Task Details: CHANGELOG قدیمی‌تر آن را نیازمند clarification ثبت کرده بود؛ ابلاغیه حاضر اکنون محل و رفتار را صریح تعیین کرده است. این کار باید در Commit مستقل همراه آزمون انجام شود.
## کنترل حاکمیتی
- هیچ تغییری روی main اعمال نشده است.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند.
- این سند ممیزی/برنامه است؛ ثبت آن به‌معنای تکمیل بندها یا PASS شدن همه گیت‌ها نیست.
- انتشار همچنان **BLOCKED — RELEASE: NO-GO** است.
