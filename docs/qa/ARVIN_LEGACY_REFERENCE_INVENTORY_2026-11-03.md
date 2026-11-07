# فهرست ارجاعات Legacy آروین و طرح مهاجرت غیرمخرب
**تاریخ:** ۱۴۰۵/۰۸/۱۲ — ۲۰۲۶-۱۱-۰۳
**Source SHA:** 35b5765a7964c063b01a5ef3366836064decc751
**Branch:** fix/recovery-calendar-device-smoke-2026-10-31
**Release:** BLOCKED — RELEASE: NO-GO
## 1. قرارداد داده هدف
- Task مستقل است؛ موعد در Task.dueDate باقی می‌ماند.
- Reminder آینده باید در Task.taskReminders باشد؛ Task.reminderDate فقط پل سازگاری قدیمی است و نباید منبع Runtime بلندمدت باقی بماند.
- Follow-up فقط رکورد اقدام واقعی گذشته است؛ تاریخ واقعی فعلی FollowUp.dateTime است.
- FollowUp.nextFollowUp و FollowUp.reminderDate زمان‌بندی آینده‌اند و نباید به سابقه اقدام تبدیل شوند.
- Task.followUpEnabled و Task.followUpDate فیلدهای Legacy زمان‌بندی‌اند، نه تاریخچه.
## 2. مدل و Serialization
| مسیر | ارجاع | وضعیت و رفتار |
|---|---|---|
| lib/models/task.dart — class FollowUp | reminderDate، nextFollowUp | در constructor، toJson/fromJson فعال‌اند؛ getter completedAt فقط alias به dateTime است |
| lib/models/task.dart — class Task | followUpEnabled، followUpDate، reminderDate | در constructor و JSON فعال؛ legacyTaskReminderMigrationVersion برای مهاجرت Reminder قدیمی وجود دارد |
| lib/models/task.dart — TaskReminder | isLegacyTaskReminder | شناسه/پرچم سازگاری برای مهاجرت یک‌باره Task.reminderDate به TaskReminder |
## 3. Schema و DAO/Store
| مسیر | ارجاع | وضعیت |
|---|---|---|
| lib/services/g1_drift_schema.dart | tasks.follow_up_enabled، tasks.follow_up_date، tasks.reminder_date | در CREATE TABLE فعال‌اند |
| lib/services/g1_drift_schema.dart | follow_ups.reminder_date، follow_ups.next_follow_up | ستون‌های جدول Follow-up هنوز وجود دارند |
| lib/services/task_store.dart | INSERT/UPDATE/SELECT task columns و legacy_payload_json | فیلدهای Task در persistence خوانده/نوشته می‌شوند |
| lib/services/task_store.dart | follow_ups.reminder_date و follow_ups.next_follow_up | در درج/خواندن Follow-up رکوردها فعال‌اند |
## 4. Migration، Repository و Service
| مسیر | ارجاع/نقش | وضعیت |
|---|---|---|
| lib/services/sql_task_migration_writer.dart | follow_up_enabled، follow_up_date، reminder_date، next_follow_up | Migration writer این ستون‌ها را می‌نویسد |
| lib/services/task_migration_writer.dart | followUpEnabled، followUpDate و reminderDate | خروجی سازگاری Home JSON را حفظ می‌کند |
| lib/services/task_migration_reader.dart و task_migration_adapter.dart | Task.fromJson و حفظ فیلدهای ناشناخته | مرز خواندن/تبدیل Legacy؛ حذف/پاک‌سازی داده انجام نمی‌دهد |
| lib/follow_up_repository.dart | کپی reminderDate و nextFollowUp | فیلدها در Update مسیر Follow-up حفظ می‌شوند |
| lib/services/waiting_for_response_service.dart | کپی nextFollowUp | زمان‌بندی قدیمی را در تغییر وضعیت حفظ می‌کند |
| lib/services/calendar_reschedule_apply_service.dart | کپی nextFollowUp | در تغییر برنامه Follow-up حفظ می‌شود |
| lib/services/person_follow_up_report_projection.dart | نمایش nextFollowUp و reminderDate | فیلدهای قدیمی در Projection گزارش افراد هنوز قابل دسترسی‌اند |
| lib/services/home_today_projection.dart | legacyHomeFollowUpDate | از Task.followUpDate برای محاسبه قدیمی استفاده می‌کند؛ اتصال آن به UI جاری نیازمند بررسی نهایی است |
| lib/services/home_follow_up_presentation_service.dart | legacy Task.followUpDate | صریحاً آن را نادیده می‌گیرد |
| lib/services/follow_up_calendar_projection.dart | task.reminderDate و legacy followUpDate | Task reminder قدیمی را برای سازگاری می‌خواند؛ Follow-up schedule را به Calendar صادر نمی‌کند |
| lib/services/work_agenda_projection.dart | task.reminderDate | Reminder قدیمی Task را در Work Agenda projection مصرف می‌کند |
| lib/services/task_next_action_service.dart | task.reminderDate | Reminder قدیمی را در Next Action candidate لحاظ می‌کند |
| lib/services/follow_up_reminder_projection.dart | isLegacyTaskReminder | هویت Reminder قدیمی را از شناسه‌سازی جدید جدا می‌کند |
| lib/services/automatic_follow_up_service.dart | Legacy compatibility facade | زمان‌بندی خودکار Follow-up رسماً بازنشسته است؛ Facade برای drain کردن callerهای قدیمی نگه داشته شده |
| lib/services/task_report_projection.dart | task.reminderDate | مقدار Reminder قدیمی را در گزارش Task نمایش می‌دهد |
| lib/task_editor_dialog.dart | reminderDate، followUpEnabled، followUpDate | Reminder قدیمی را در Edit می‌خواند/می‌نویسد و Legacy follow-up fields را حفظ می‌کند |
| lib/follow_up_entry_page.dart | reminderDate، nextFollowUp | کنترل‌های قدیمی پنهان‌اند؛ هنگام ویرایش Follow-up مقدار قبلی حفظ می‌شود؛ Reminder جدید از TaskReminder مستقل ساخته می‌شود |
## 5. Tests و Fixtures دارای ارجاع
| مسیر آزمون | پوشش/وابستگی |
|---|---|
| test/task_legacy_follow_up_migration_test.dart | حفظ followUpDate بدون ساخت سابقه جعلی؛ JSON round-trip |
| test/task_store_followup_test.dart و test/task_store_test.dart | حفظ followUpDate و FollowUp.reminderDate/nextFollowUp در SQLite |
| test/follow_up_repository_test.dart | عدم ساخت Follow-up history از تاریخ Legacy؛ حفظ فیلدهای قدیمی |
| test/task_contract_test.dart | round-trip فیلدهای قدیمی و Task.reminderDate |
| test/task_detail_followup_flow_test.dart | حفظ followUpEnabled/followUpDate/nextFollowUp در مسیر Details |
| test/task_editor_dialog_test.dart و test/task_editor_due_date_preservation_test.dart | حفظ Legacy fields هنگام Edit |
| test/follow_up_canonical_lifecycle_test.dart | سازگاری legacy flag/date |
| test/follow_up_reminder_projection_test.dart | جلوگیری از زمان‌بندی Legacy؛ مهاجرت کنترل‌شده Task.reminderDate |
| test/services/person_follow_up_report_projection_test.dart | نمایش nextFollowUp/reminderDate در گزارش افراد |
| test/services/g1_drift_schema_test.dart و test/services/g1_drift_completed_at_migration_test.dart | Schema قدیمی، completed_at و ستون follow_up_enabled |
| test/services/sql_project_migration_writer_test.dart و test/services/task_migration_writer_test.dart | نوشتن مقادیر Legacy در Migration |
| test/services/task_migration_reader_test.dart و test/services/task_migration_adapter_test.dart | خواندن/تبدیل Legacy JSON بدون جعل تاریخچه |
| test/follow_up_entry_page_test.dart | کنترل‌های قدیمی پنهان و حفظ مقادیر قبلی |
| test/services/follow_up_write_coordinator_test.dart | حفظ nextFollowUp در مسیر نوشتن |
| test/follow_up_calendar_projection_test.dart | جلوگیری از صدور nextFollowUp و Follow-up.reminderDate به Calendar |
| test/work_agenda_page_test.dart و test/work_agenda_pdf_renderer_test.dart | جداسازی Task Due، Task Reminder و Legacy Follow-up |
| test/task_next_action_service_test.dart | عدم ساخت Next Action از nextFollowUp/followUpDate؛ آزمون Task.reminderDate |
| test/follow_up_reminder_model_test.dart | مهاجرت یک‌باره Task.reminderDate به TaskReminder و عدم تکرار |
| test/follow_up_office_page_test.dart | Next Follow-up قدیمی نباید فیلتر موعد خودکار بسازد |
| test/automatic_follow_up_service_test.dart، test/automatic_follow_up_background_runner_test.dart، test/services/automatic_follow_up_alarm_planner_test.dart | Legacy Next Follow-up هرگز اعلان/Alarm خودکار تولید نکند |
| test/waiting_for_response_service_test.dart | حفظ nextFollowUp هنگام تغییر وضعیت |
| test/services/work_agenda_projection_test.dart و work_agenda_report_adapter_test.dart | عدم ساخت Agenda از Follow-up legacy؛ مصرف Task.reminderDate |
| test/widgets/home_quick_capture_test.dart | fixture قدیمی شامل nextFollowUp |
## 6. تفکیک «ستون باقی‌مانده» از «قابلیت Runtime»
- Task.followUpEnabled/followUpDate صرفاً ستون نیستند: در مدل و JSON و TaskStore و Task Editor فعال‌اند؛ HomeToday legacy projection نیز آن‌ها را می‌شناسد.
- FollowUp.nextFollowUp/reminderDate در UI کنترل ویرایش ندارند، اما Model/JSON/Schema/TaskStore/Repository/Projection آن‌ها را حمل می‌کنند؛ پس هنوز Legacy Runtime compatibility هستند.
- Task.reminderDate پل مهاجرت Reminder قدیمی است، اما هنوز در Task Editor، Work Agenda، Next Action، Calendar و Report مصرف می‌شود؛ بازنشستگی آن نیازمند migration به TaskReminder و کنترل idempotency است.
- FollowUp.completedAt مستقل نیست؛ getter به dateTime اشاره می‌کند و ستون persisted فعلی follow_ups.date_time است. follow_ups.completed_at در Schema فعلی وجود ندارد.
- Automatic Follow-up scheduling facade بازنشسته است؛ آزمون‌های مربوطه عمداً عدم ساخت Alarm از Next Follow-up را تثبیت می‌کنند.
## 7. طرح مهاجرت غیرمخرب — هنوز اجرا نشده
1. Backup: نسخهٔ کامل دیتابیس SQLite/Drift و export JSON قدیمی، checksum و شناسهٔ نسخه قبل از migration تهیه شود؛ روی نسخه کپی‌شده اجرا شود.
2. Reader-first: Reader قدیمی فقط برای خواندن/حفظ envelope باقی بماند؛ هیچ رفتار زمان‌بندی از فیلدهای Next Follow-up فعال نشود.
3. Reminder migration: Task.reminderDate فقط با marker فعلی و stable ID به TaskReminder مهاجرت کند؛ وجود Reminder هم‌ارز بررسی شود؛ اجرای دوباره نباید Reminder تکراری بسازد؛ حذف قبلی Reminder نباید آن را دوباره زنده کند.
4. Follow-up history: فقط رکوردی که شواهد اقدام واقعی و timestamp معتبر دارد در Follow-up history باقی بماند. followUpDate/nextFollowUp/reminderDate آینده هرگز به اقدام واقعی تبدیل نشود.
5. Runtime retirement: ابتدا مصرف UI/Runtime فیلدهای followUpEnabled/followUpDate و FollowUp.nextFollowUp/reminderDate از مسیرهای active جدا شود؛ سازگاری خواندن داده قدیمی در adapter نگه داشته شود.
6. Schema migration: فقط پس از اثبات بی‌نیازی Runtime و تست Backup/Restore، ستون‌ها در migration نسخه‌دار حذف شوند؛ rollback و upgrade از Schema نسخه ۸ الزامی است.
7. Acceptance: آزمون دیتابیس قدیمی→جدید، rollback، تکرار migration، عدم حذف TaskReminder، حفظ Follow-up history و عدم ساخت Alarm/Calendar event جعلی الزامی است.
**هیچ‌یک از این مراحل حذف داده/ستون در Commit مستندسازی اجرا نشده است.**
## 8. تصمیم
Legacy blocker واقعی و فعال است؛ حذف مستقیم یا بازنویسی حدسی داده ممنوع. مرحله بعدی باید یک Commit مستقل retirement/runtime و سپس migration نسخه‌دار باشد. PR #3052 باز و Draft می‌ماند؛ main بدون تغییر؛ Release NO-GO.
