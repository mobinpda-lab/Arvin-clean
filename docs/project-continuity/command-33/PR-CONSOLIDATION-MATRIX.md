# COMMAND 33 — PR CONSOLIDATION MATRIX
**Audit date:** 2026-11-18  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Canonical branch:** `recovery-02/main-based-integration`  
**Audited code SHA:** `facef07ecf9db4cd627f7aaad6e123f2c6ad5023`  
**Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`

> **Status: PARTIAL — NOT A CLEANUP AUTHORIZATION.**  
> This matrix records the material PRs directly identified by the current REV10 consolidation history and current live PR inventory. It is not a complete 110-open-PR / historical-PR unique-commit audit. File-path overlap alone is not proof of semantic transfer. No PR closure or branch deletion is authorized from this matrix.

| PR | وضعیت زنده | تغییر منحصربه‌فرد / دامنه | منتقل شد؟ | محل انتقال در #3495 | اقدام نهایی |
|---|---|---|---|---|---|
| #3495 | OPEN / DRAFT | مسیر یکپارچه REV10؛ ۱۵۶ commit، ۱۳۵ فایل | مرجع | کل شاخه `recovery-02/main-based-integration` | تنها مسیر توسعه؛ حفظ |
| #1901 | OPEN | رگرسیون Calendar/Home/Typography/Taxonomy/Notebook/Quick Add؛ ۲۶ فایل | PARTIAL | `test/models/task_checklist_test.dart` برای Checklist؛ Home چهارحالته طبق REV10 منسوخ است | باز بماند؛ منبع رگرسیون؛ بستن پس از اثبات تمام موارد مفید |
| #3463 | OPEN / DRAFT | مهاجرت M2M نسخه ۱۹، Center/Project/Category و SQL tests | PARTIAL — فقط تصمیم/ADR قابل شناسایی | `docs/ADR/ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M.md`; کد migration/store در فهرست فایل‌های PR #3495 اثبات نشد | باز بماند؛ شاخه و تاریخچه محافظت شود |
| #3470 | OPEN / DRAFT | بازطراحی گسترده قرارداد وزن‌های Vazirmatn و UI | NOT PROVEN | مسیرهای مشترک UI به‌تنهایی اثبات انتقال نیستند؛ تست اختصاصی typography در فهرست فایل‌های PR #3495 نیست | باز بماند؛ انتقال گزینشی فقط پس از تطبیق REV10 |
| #3384 | OPEN / DRAFT | بسته گسترده SQL/metadata، migration، فونت‌ها، UI و اسناد | PARTIAL / NOT PROVEN | تعدادی سند معماری و فایل‌های مشترک وجود دارند؛ assets/fonts و زنجیره کامل migration در PR #3495 اثبات نشد | باز بماند؛ بدون انتقال کامل یا تست نهایی بسته نشود |
| #3382 | OPEN / DRAFT | آزمون مستقل Raw SQL evidence و Workflow تشخیصی | NOT PROVEN | `test/diagnostics/command_06_h_raw_sql_evidence_test.dart` و Workflow متناظر در فهرست PR #3495 نیستند | باز بماند؛ مدرک تشخیصی حفظ شود |
| #3380 | OPEN / DRAFT | بازیابی چرخه عمر executor پس از reopen | NOT PROVEN | `test/services/sql_task_migration_writer_test.dart` در فهرست PR #3495 نیست | باز بماند؛ مدرک تشخیصی حفظ شود |
| #3376 | OPEN / DRAFT | ثبت دقیق Task envelope پیش از rollback | NOT PROVEN | فایل تست تشخیصی در فهرست PR #3495 نیست | باز بماند؛ مدرک تشخیصی حفظ شود |
| #3366 | OPEN / DRAFT | حفظ metadata و استقلال due/reminder در Editor و migration tests | PARTIAL / NOT PROVEN | فایل‌های هم‌مسیر `lib/task_editor_dialog.dart` و `test/task_contract_test.dart` در #3495 وجود دارند؛ تطبیق محتوای تغییرات اختصاصی انجام نشده | باز بماند؛ diff و blob comparison لازم است |
| #3364 | OPEN / DRAFT | حفظ Follow-up envelope و SQL metadata | PARTIAL / NOT PROVEN | `lib/models/task.dart` و `lib/services/g1_drift_schema.dart` هم‌مسیر هستند؛ انتقال کامل SQL writer/test اثبات نشده | باز بماند؛ زنجیره migration محافظت شود |
| #3356 | OPEN / DRAFT | تشخیص parity شکست SQL envelope در زنجیره #3052 | NOT PROVEN | `lib/services/sql_task_migration_writer.dart` و آزمون متناظر در #3495 اثبات نشد | باز بماند؛ شاخه وابسته محافظت شود |
| #3346 | OPEN / DRAFT | حفظ فیلدهای canonical در Task Editor | PARTIAL / NOT PROVEN | `lib/task_editor_dialog.dart` و تست‌های Editor هم‌مسیر هستند؛ انتقال دقیق patch اثبات نشده | باز بماند؛ تا تطبیق diff بسته نشود |
| #3052 | OPEN / DRAFT | زنجیره گسترده Calendar/SQL/UI/Workflow بر پایه Main | NOT PROVEN | هم‌پوشانی تعداد زیادی از فایل‌ها با #3495 وجود دارد؛ یکتایی commitها و انتقال تمام تغییرات بررسی نشده | باز بماند؛ هیچ cherry-pick یا حذف شاخه |
| #3341 | CLOSED / UNMERGED | آزمون‌های file-backed ProjectStore و TaskReminder | PARTIAL / HISTORICAL CLAIM | آزمون‌های متناظر در #3495 با نام‌های `test/project_store_file_persistence_test.dart` و `test/task_reminders_file_backed_sqlite_test.dart` وجود دارند؛ برابری کامل محتوایی در این دور اثبات نشد | بسته باقی بماند؛ Branch حذف نشود |
| #3348 | CLOSED / UNMERGED | Calendar interaction، navigation و file-backed persistence | PARTIAL / HISTORICAL CLAIM | `integration_test/calendar_card_interaction_test.dart`، `lib/widgets/arvin_primary_navigation.dart` و آزمون‌های persistence هم‌مسیر هستند؛ تطبیق نهایی کامل لازم است | بسته باقی بماند؛ Branch حذف نشود |
| #3365 | CLOSED / UNMERGED | اصلاح Device Smoke و Calendar navigation | PARTIAL / HISTORICAL CLAIM | فایل‌های Calendar interaction، navigation و `.github/workflows/device-smoke.yml` در #3495 وجود دارند؛ برابری کامل در این دور دوباره اثبات نشد | بسته باقی بماند؛ Branch حذف نشود |
| #3388 | CLOSED / UNMERGED | اسناد Wave 0 governance و continuity | PARTIAL | اسناد حاکم جاری در `docs/project-continuity/` و adapters ریشه وجود دارند؛ تطبیق تمام متن‌ها انجام نشده | بسته باقی بماند؛ تاریخچه حفظ شود |
| #3448 | CLOSED / UNMERGED | منشور REV10، ADR و اسناد continuity | PARTIAL | ADR M2M و اسناد جاری در `docs/project-continuity/` وجود دارند؛ تفاوت‌های هفت سند هم‌پوشان نیازمند تطبیق محتوایی‌اند | بسته باقی بماند؛ تاریخچه حفظ شود |
| #3340 | CLOSED / UNMERGED | منشور REV9 و اسناد قدیمی governance/UI | SUPERSEDED / PARTIAL | تصمیمات جاری REV10 در `PRODUCT_DECISIONS.md` و اسناد archive/reference؛ پیشنهادهای منسوخ باید فقط تاریخی بمانند | بسته باقی بماند؛ اسناد تاریخی حذف نشوند |

## Evidence and cleanup boundary

- Live PR #3495 head was verified as `facef07ecf9db4cd627f7aaad6e123f2c6ad5023`; Main remained `45e4202b03a434459e4c021a04efa7e8396359db`.
- GitHub REST open-PR pagination returned 100 entries on page 1 and 10 on page 2: **110 open PRs** at audit time.
- The prior COMMAND 32 record reports 1,439 branch names; a complete fresh branch SHA / PR association / unique-commit audit was not completed in COMMAND 33.
- Current live state confirms the material open/closed PR statuses shown above. Closed PRs are not assumed to have their branches deleted.
- The changed-file list for #3495 was compared against source PR changed-file lists. Shared paths were treated as leads only, not as proof of patch equivalence.
- No PR was closed and no branch was deleted. No destructive cleanup is authorized until every unique contribution, dependent PR, workflow, issue reference, tag, release reference and preserved history is accounted for.
