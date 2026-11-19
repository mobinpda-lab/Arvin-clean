# COMMAND 63-R — 80 failed test-instance inventory
Baseline code SHA: `4b2a2ef418959420d6100d667431f35b55aba494`
Build run: `44476625119`
Scope: six test shards; 80 reported failed test instances. These are failed test instances, not necessarily 80 unique test names.
This inventory records the exact failed test names from the six shard logs. The category is an initial triage label, not a confirmed root cause. A test is not closed until its product/test/environment cause is proven, the appropriate correction is committed, and an exact-new-SHA rerun passes.

| Shard | Job ID | Test file | Test | Initial category | Current disposition |
|---|---:|---|---|---|---|
| quality (test-3) | 135401518167 | `test/widgets/home_page_test.dart` | RTL Move-to-Today does not dismiss and None is a no-op | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/widgets/home_page_test.dart` | Home five filters stay in one RTL row without horizontal scrolling at phone widths and with keyboard | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/widgets/home_page_test.dart` | Home Past time filter excludes today and prioritizes incomplete tasks | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/quick_capture_dialog_test.dart` | Quick Add reminder presets match the product contract | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/quick_capture_dialog_test.dart` | Quick Add custom recurrence exposes every canonical time unit | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/services/task_migration_writer_test.dart` | Home projection persists explicitly supplied canonical Follow-up history | Migration / Reminder / Data Persistence | CORRECTED: canonical Follow-up serialization asserts completedAt; exact-head retest pending |
| quality (test-3) | 135401518167 | `test/device_feedback_home_regression_test.dart` | normal-height Home keeps empty groups and floating add action | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/task_editor_dialog_test.dart` | task editor recurrence uses RollBox and preserves interval | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/home/home_filter_contract_test.dart` | Home task card expands in place with real FollowUp history and preserves details route | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/follow_up_office_page_test.dart` | legacy Next Follow-up dates never create an automatic due filter | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/task_detail_master_screen_test.dart` | Smart visibility keeps an ordinary Task detail compact | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-3) | 135401518167 | `test/home_stat_filters_test.dart` | tag choices are OR within Tags and AND with Category | Home / Center / Reports / Navigation | PARTIALLY CORRECTED: icon-only filter label tests use Semantics; remaining filter logic failures need retest |
| quality (test-4) | 135401518247 | `test/widgets/home_page_test.dart` | overdue active task uses red text while card and icons stay neutral | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/g6_swipe_rtl_acceptance_test.dart` | configured left and right swipes open Follow-up form and write only after save | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/work_agenda_pdf_renderer_test.dart` | existing PDF renderer builds grouped Work Agenda bytes | Calendar / PDF / Integration | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/task_editor_dialog_test.dart` | Task editor saves a real all-day deadline from inside the clock dialog | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/unified_item_migration_test.dart` | Unified Task JSON preserves reminder and recurrence fields | Migration / Reminder / Data Persistence | CORRECTED: legacy fixture now uses Task.fromLegacyJson; exact-head retest pending |
| quality (test-4) | 135401518247 | `test/task_detail_master_screen_test.dart` | Smart visibility shows rich sections only when canonical data exists | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/task_detail_master_screen_test.dart` | Task Details presents summary, metadata and due date once in RTL order | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/issue_1891_lane_d_rollbox_test.dart` | issue 1891 tag roll box supports multi-select with apply/cancel | Other / cross-cutting | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/home_today_about_test.dart` | About menu action opens the built-in Arvin about dialog | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/calendar_page_test.dart` | prayer cards use mosque icon and subdued unregistered status | Calendar / PDF / Integration | ROOT_CAUSE_PENDING |
| quality (test-4) | 135401518247 | `test/home_stat_filters_test.dart` | time checkbox selections use OR without a numeric badge | Home / Center / Reports / Navigation | PARTIALLY CORRECTED: icon-only filter label tests use Semantics; remaining filter logic failures need retest |
| quality (test-1) | 135401518252 | `test/widgets/home_page_test.dart` | completed tasks remain visible in All and Completed filters | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-1) | 135401518252 | `test/widgets/home_page_test.dart` | Home uses the five checkbox filters as combined filters and preserves time grouping | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-1) | 135401518252 | `test/quick_capture_dialog_test.dart` | canonical capture keeps title-only path and optional choices | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-1) | 135401518252 | `test/quick_capture_dialog_test.dart` | Quick Add scheduling uses the canonical circular date/time picker | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-1) | 135401518252 | `test/task_timeline_page_test.dart` | renders canonical task history in chronological order | Other / cross-cutting | ROOT_CAUSE_PENDING |
| quality (test-1) | 135401518252 | `test/calendar_explicit_export_contract_test.dart` | normal Task save, capture, edit and completion contain no outbound sync | Calendar / PDF / Integration | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_detail_person_persistence_test.dart` | Task Details Follow-up person selection persists through canonical Person and relation tables | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/home_last_follow_up_real_record_test.dart` | Home shows last FollowUp only for a real record and does not create one | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_detail_master_screen_test.dart` | Task Details presents canonical follow-up title, note and waiting-for-response state | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_detail_master_screen_test.dart` | Task Details persists checklist reorder and additions immediately without changing Follow-up history | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/follow_up_entry_page_test.dart` | waiting FollowUp can add, select, reopen and remove a stable person | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/notebook_page_test.dart` | editor tag picker replaces tags on the same canonical note | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/widget_test.dart` | Home exposes the canonical workflow controls | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/home/home_owner_reference_test.dart` | Home follows the owner header, real summary values and Today navigation | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/canonical_home_boundary_test.dart` | normal save, Quick Capture, edit and completion never export automatically | Calendar / PDF / Integration | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/home/home_filter_boolean_logic_test.dart` | Home filters combine OR within each dimension and AND across dimensions | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/home_wave2_editor_wiring_guard_test.dart` | Home add/edit stay wired to the canonical Wave 2 coordinator | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/report_center_page_test.dart` | Report Center exposes center and searchable task controls | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/quick_capture_project_create_test.dart` | Quick Add offers Project create-new and selects the created project | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_detail_checklist_crud_test.dart` | checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/settings_page_test.dart` | settings exposes date, swipe, projects and canonical backup controls | Settings / Backup | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_editor_due_date_preservation_test.dart` | editing preserves canonical due date independently | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/widgets/home_quick_capture_test.dart` | Home primary add persists canonical task and preserves history | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/home_stat_filters_test.dart` | category checkbox selection applies OR only after confirmation | Home / Center / Reports / Navigation | PARTIALLY CORRECTED: icon-only filter label tests use Semantics; remaining filter logic failures need retest |
| quality (test-2) | 135401518298 | `test/task_contract_test.dart` | due date stays independent from reminder and follow-up timestamps | Migration / Reminder / Data Persistence | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/home_today_about_test.dart` | Today menu action has a dedicated empty state | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_store_reminder_persistence_test.dart` | legacy reminder-table migration removes its flag without losing reminder rows | Migration / Reminder / Data Persistence | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/quick_capture_dialog_test.dart` | Quick Add opens an independent Persian reminder date/time picker | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/quick_capture_dialog_test.dart` | Quick Add shows the selected scheduling time and uses injected now | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/task_editor_dialog_test.dart` | Back-style close prompts and can save Task edits without data loss | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/follow_up_office_page_test.dart` | selects one of multiple tasks and persists only to that task | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-2) | 135401518298 | `test/release_critical_path_test.dart` | critical capture to independent reminder path survives canonical persistence | Migration / Reminder / Data Persistence | CORRECTED: reminderDate compatibility getter now expected to project enabled TaskReminder; exact-head retest pending |
| quality (test-5) | 135401518331 | `test/widgets/home_page_test.dart` | Home separates calendar today from selected focus and persists toggle removal | Calendar / PDF / Integration | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/widgets/home_page_test.dart` | Focus Today is reachable from drawer More and global funnel with one result set | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/quick_capture_dialog_test.dart` | timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/services/sql_task_migration_writer_test.dart` | preserves complete Follow-up history across closing and reopening SQLite | Migration / Reminder / Data Persistence | CORRECTED: file-reopen fixture records migration-complete marker; exact-head retest pending |
| quality (test-5) | 135401518331 | `test/widget_test.dart` | HomePage shows the empty-state message after loading | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/task_editor_dialog_test.dart` | Task editor cancelling the circular clock does not commit a partial date | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/follow_up_office_page_test.dart` | asks the user to create a task when the list is empty | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/task_detail_master_screen_test.dart` | Task Details does not present related people as assignees and keeps bottom content clear | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/notebook_page_test.dart` | Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/canonical_calendar_launcher_test.dart` | repeat occurrence actions resolve back to the canonical Task | Calendar / PDF / Integration | ROOT_CAUSE_PENDING |
| quality (test-5) | 135401518331 | `test/report_center_page_test.dart` | Report Center quick presets apply from a dedicated bottom sheet | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/task_detail_checklist_flow_test.dart` | task detail displays checklist and toggles an item | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/widgets/task_dialog_test.dart` | creates a task with trimmed text and a unique tag | Other / cross-cutting | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/widgets/home_page_test.dart` | renders the current canonical HomePage shell | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/quick_capture_dialog_test.dart` | Quick Capture can create a center inline and immediately select it | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/task_detail_due_date_action_test.dart` | Task Details explicit today action aligns with Due Date and persists only the date change | Task Details / Follow-up / People / Checklist | CORRECTED: fixture now seeds canonical TaskReminder and asserts inert legacy metadata; exact-head retest pending |
| quality (test-0) | 135401518408 | `test/services/task_report_filter_test.dart` | combined filters use AND semantics without mutating tasks | Other / cross-cutting | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/device_feedback_home_regression_test.dart` | Home keeps backup in the More menu instead of the header | Settings / Backup | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/primary_bottom_navigation_test.dart` | primary navigation exposes exactly five canonical destinations | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/home/home_filter_contract_test.dart` | Home keeps completed past tasks visible in a separate non-overdue group | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/follow_up_office_page_test.dart` | follow-up office exposes the shared five filter dimensions | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/canonical_home_boundary_test.dart` | Home owns canonical Task state without legacy ArvinTask projection | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/task_people_page_test.dart` | empty People UI adds and removes a local Person explicitly | Task Details / Follow-up / People / Checklist | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/task_editor_category_project_integration_test.dart` | new task saves typed category without an extra apply step | Quick Capture / Task Editor / Date-Time / Reminder | ROOT_CAUSE_PENDING |
| quality (test-0) | 135401518408 | `test/home_today_about_test.dart` | Today menu action shows only active canonical tasks due today | Home / Center / Reports / Navigation | ROOT_CAUSE_PENDING |

## Count check
- quality (test-3) (job 135401518167): 12
- quality (test-4) (job 135401518247): 11
- quality (test-1) (job 135401518252): 6
- quality (test-2) (job 135401518298): 26
- quality (test-5) (job 135401518331): 11
- quality (test-0) (job 135401518408): 14
- Total inventory rows: 80
- Expected shard failure instances: 80
- Match: YES

## Root-cause workflow
For every row still marked ROOT_CAUSE_PENDING:
1. Capture the full failing assertion/exception and source line from the shard log.
2. Compare the assertion with the authoritative product decision and current implementation.
3. Classify as product defect, stale test contract, fixture/migration-boundary defect, or CI/environment failure.
4. Fix the product or fixture without deleting/weakening assertions.
5. Add a focused regression test when missing.
6. Rerun on one exact SHA and update this inventory with the commit and run IDs.
7. Do not treat a shard as green while any test is failed, cancelled, skipped or unexecuted.


## Follow-on exact-head failure set — PR #3052 SHA 34c461107b8cb758715d08d1b7aef5e34a2d1c30
Build run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44485072875. This is a new execution set after the earlier 80-instance baseline; do not add its count to the historical 80 as if they were the same run.

| Shard | Job ID | Passed | Failed |
|---|---:|---:|---:|
| test-2 | 135429297669 | 301 | 26 |
| test-5 | 135429297829 | 186 | 10 |
| test-0 | 135429297933 | 234 | 12 |
| test-3 | 135429297944 | 150 | 11 |
| test-1 | 135429297955 | 195 | 6 |
| test-4 | 135429299022 | 242 | 9 |
| **Total** | — | **1,308** | **74** |

The 74 entries below are the exact failed test instances parsed from the six job logs. They are not necessarily unique test names. Initial list only; each remains unaccepted until its assertion/exception, source line, product contract and correction are reviewed.

| Shard | Job ID | Failed test instance |
|---|---:|---|
| test-2 | 135429297669 | test/settings_page_test.dart: settings exposes date, swipe, projects and canonical backup controls |
| test-2 | 135429297669 | test/widgets/home_quick_capture_test.dart: Home primary add persists canonical task and preserves history |
| test-2 | 135429297669 | test/quick_capture_dialog_test.dart: Quick Add opens an independent Persian reminder date/time picker |
| test-2 | 135429297669 | test/quick_capture_dialog_test.dart: Quick Add shows the selected scheduling time and uses injected now |
| test-2 | 135429297669 | test/follow_up_entry_page_test.dart: waiting FollowUp can add, select, reopen and remove a stable person |
| test-2 | 135429297669 | test/home_last_follow_up_real_record_test.dart: Home shows last FollowUp only for a real record and does not create one |
| test-2 | 135429297669 | test/task_contract_test.dart: due date stays independent from reminder and follow-up timestamps |
| test-2 | 135429297669 | test/fonts/vazirmatn_license_asset_test.dart: Vazirmatn license and upstream authors are bundled as app assets |
| test-2 | 135429297669 | test/widget_test.dart: Home exposes the canonical workflow controls |
| test-2 | 135429297669 | test/task_store_reminder_persistence_test.dart: legacy reminder-table migration removes its flag without losing reminder rows |
| test-2 | 135429297669 | test/task_editor_dialog_test.dart: Back-style close prompts and can save Task edits without data loss |
| test-2 | 135429297669 | test/home/home_owner_reference_test.dart: Home follows the owner header, real summary values and Today navigation |
| test-2 | 135429297669 | test/home/home_filter_boolean_logic_test.dart: Home filters combine OR within each dimension and AND across dimensions |
| test-2 | 135429297669 | test/task_editor_due_date_preservation_test.dart: editing preserves canonical due date independently |
| test-2 | 135429297669 | test/follow_up_office_page_test.dart: selects one of multiple tasks and persists only to that task |
| test-2 | 135429297669 | test/task_detail_person_persistence_test.dart: Task Details Follow-up person selection persists through canonical Person and relation tables |
| test-2 | 135429297669 | test/task_detail_master_screen_test.dart: Task Details presents canonical follow-up title, note and waiting-for-response state |
| test-2 | 135429297669 | test/task_detail_master_screen_test.dart: Task Details persists checklist reorder and additions immediately without changing Follow-up history |
| test-2 | 135429297669 | test/home_wave2_editor_wiring_guard_test.dart: Home add/edit stay wired to the canonical Wave 2 coordinator |
| test-2 | 135429297669 | test/notebook_page_test.dart: editor tag picker replaces tags on the same canonical note |
| test-2 | 135429297669 | test/task_detail_checklist_crud_test.dart: checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps |
| test-2 | 135429297669 | test/canonical_home_boundary_test.dart: normal save, Quick Capture, edit and completion never export automatically |
| test-2 | 135429297669 | test/home_today_about_test.dart: Today menu action has a dedicated empty state |
| test-2 | 135429297669 | test/quick_capture_project_create_test.dart: Quick Add offers Project create-new and selects the created project |
| test-2 | 135429297669 | test/report_center_page_test.dart: Report Center exposes center and searchable task controls |
| test-2 | 135429297669 | test/home_stat_filters_test.dart: category checkbox selection applies OR only after confirmation |
| test-5 | 135429297829 | test/widget_test.dart: HomePage shows the empty-state message after loading |
| test-5 | 135429297829 | test/quick_capture_dialog_test.dart: timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder |
| test-5 | 135429297829 | test/task_detail_master_screen_test.dart: Task Details does not present related people as assignees and keeps bottom content clear |
| test-5 | 135429297829 | test/report_center_page_test.dart: Report Center quick presets apply from a dedicated bottom sheet |
| test-5 | 135429297829 | test/canonical_calendar_launcher_test.dart: repeat occurrence actions resolve back to the canonical Task |
| test-5 | 135429297829 | test/notebook_page_test.dart: Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries |
| test-5 | 135429297829 | test/task_editor_dialog_test.dart: Task editor cancelling the circular clock does not commit a partial date |
| test-5 | 135429297829 | test/widgets/home_page_test.dart: Home separates calendar today from selected focus and persists toggle removal |
| test-5 | 135429297829 | test/widgets/home_page_test.dart: Focus Today is reachable from drawer More and global funnel with one result set |
| test-5 | 135429297829 | test/follow_up_office_page_test.dart: asks the user to create a task when the list is empty |
| test-0 | 135429297933 | test/task_detail_checklist_flow_test.dart: task detail displays checklist and toggles an item |
| test-0 | 135429297933 | test/widgets/task_dialog_test.dart: creates a task with trimmed text and a unique tag |
| test-0 | 135429297933 | test/quick_capture_dialog_test.dart: Quick Capture can create a center inline and immediately select it |
| test-0 | 135429297933 | test/services/task_report_filter_test.dart: combined filters use AND semantics without mutating tasks |
| test-0 | 135429297933 | test/device_feedback_home_regression_test.dart: Home keeps backup in the More menu instead of the header |
| test-0 | 135429297933 | test/primary_bottom_navigation_test.dart: primary navigation exposes exactly five canonical destinations |
| test-0 | 135429297933 | test/home/home_filter_contract_test.dart: Home keeps completed past tasks visible in a separate non-overdue group |
| test-0 | 135429297933 | test/follow_up_office_page_test.dart: follow-up office exposes the shared five filter dimensions |
| test-0 | 135429297933 | test/canonical_home_boundary_test.dart: Home owns canonical Task state without legacy ArvinTask projection |
| test-0 | 135429297933 | test/task_people_page_test.dart: empty People UI adds and removes a local Person explicitly |
| test-0 | 135429297933 | test/task_editor_category_project_integration_test.dart: new task saves typed category without an extra apply step |
| test-0 | 135429297933 | test/home_today_about_test.dart: Today menu action shows only active canonical tasks due today |
| test-3 | 135429297944 | test/widgets/home_page_test.dart: RTL Move-to-Today does not dismiss and None is a no-op |
| test-3 | 135429297944 | test/widgets/home_page_test.dart: Home five filters stay in one RTL row without horizontal scrolling at phone widths and with keyboard |
| test-3 | 135429297944 | test/widgets/home_page_test.dart: Home Past time filter excludes today and prioritizes incomplete tasks |
| test-3 | 135429297944 | test/quick_capture_dialog_test.dart: Quick Add reminder presets match the product contract |
| test-3 | 135429297944 | test/quick_capture_dialog_test.dart: Quick Add custom recurrence exposes every canonical time unit |
| test-3 | 135429297944 | test/device_feedback_home_regression_test.dart: normal-height Home keeps empty groups and floating add action |
| test-3 | 135429297944 | test/task_editor_dialog_test.dart: task editor recurrence uses RollBox and preserves interval |
| test-3 | 135429297944 | test/home/home_filter_contract_test.dart: Home task card expands in place with real FollowUp history and preserves details route |
| test-3 | 135429297944 | test/follow_up_office_page_test.dart: legacy Next Follow-up dates never create an automatic due filter |
| test-3 | 135429297944 | test/task_detail_master_screen_test.dart: Smart visibility keeps an ordinary Task detail compact |
| test-3 | 135429297944 | test/home_stat_filters_test.dart: time checkbox selections use OR without a numeric badge |
| test-1 | 135429297955 | test/widgets/home_page_test.dart: completed tasks remain visible in All and Completed filters |
| test-1 | 135429297955 | test/widgets/home_page_test.dart: Home uses the five checkbox filters as combined filters and preserves time grouping |
| test-1 | 135429297955 | test/quick_capture_dialog_test.dart: canonical capture keeps title-only path and optional choices |
| test-1 | 135429297955 | test/quick_capture_dialog_test.dart: Quick Add scheduling uses the canonical circular date/time picker |
| test-1 | 135429297955 | test/task_timeline_page_test.dart: renders canonical task history in chronological order |
| test-1 | 135429297955 | test/calendar_explicit_export_contract_test.dart: normal Task save, capture, edit and completion contain no outbound sync |
| test-4 | 135429299022 | test/calendar_page_test.dart: prayer cards use mosque icon and subdued unregistered status |
| test-4 | 135429299022 | test/task_detail_master_screen_test.dart: Smart visibility shows rich sections only when canonical data exists |
| test-4 | 135429299022 | test/task_detail_master_screen_test.dart: Task Details presents summary, metadata and due date once in RTL order |
| test-4 | 135429299022 | test/issue_1891_lane_d_rollbox_test.dart: issue 1891 tag roll box supports multi-select with apply/cancel |
| test-4 | 135429299022 | test/g6_swipe_rtl_acceptance_test.dart: configured left and right swipes open Follow-up form and write only after save |
| test-4 | 135429299022 | test/task_editor_dialog_test.dart: Task editor saves a real all-day deadline from inside the clock dialog |
| test-4 | 135429299022 | test/work_agenda_pdf_renderer_test.dart: existing PDF renderer builds grouped Work Agenda bytes |
| test-4 | 135429299022 | test/widgets/home_page_test.dart: overdue active task uses red text while card and icons stay neutral |
| test-4 | 135429299022 | test/home_today_about_test.dart: About menu action opens the built-in Arvin about dialog |

### Other exact-head outcomes on 34c4611
- Analyze: PASS; Visual: PASS.
- Debug APK: PASS; Release APK: PASS; Staging APK: PASS.
- Follow-up File Persistence: PASS (run 44485073034).
- Calendar Provider Acceptance: PASS (run 44485073037).
- Draft Review APK: PASS (run 44485073188).
- Device Smoke: PENDING (run 44485072815); no device acceptance is claimed.
- RootBundle test vazirmatn_license_asset_test.dart failed because nested LICENSE.txt was not present in the Flutter asset bundle despite the source file existing. The failure was fixed by explicitly registering both LICENSE.txt and AUTHORS.txt in pubspec.yaml, commit a2825e003bb9e6b5c2413b0dc74b085273b6148b. Retest is pending on that exact SHA.

### Root-cause triage reminders
- Do not infer that the six original corrections resolved all related behaviors; the 74 failures above require their own classification.
- Preserve all assertions. Where a test contradicts the newer product contract, update the contract test to assert the approved behavior rather than deleting the assertion.

## Exact-head follow-on set — PR #3052 SHA a2825e003bb9e6b5c2413b0dc74b085273b6148b
Build run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44490319550 (terminal conclusion: FAILURE).

| Shard | Job ID | Passed | Failed |
|---|---:|---:|---:|
| test-0 | 135443980960 | 234 | 12 |
| test-1 | 135443981268 | 195 | 6 |
| test-2 | 135443981083 | 302 | 25 |
| test-3 | 135443981089 | 151 | 10 |
| test-4 | 135443981321 | 242 | 9 |
| test-5 | 135443981366 | 186 | 10 |
| **Total** | — | **1,310** | **72** |

The following 72 failed test instances were extracted from the exact-head job logs. They are a distinct run and must not be added to the earlier 80 or 74 totals as if they were the same candidate.

| Shard | Job ID | Failed test instance |
|---|---:|---|
| test-0 | 135443980960 | test/task_detail_checklist_flow_test.dart: task detail displays checklist and toggles an item |
| test-0 | 135443980960 | test/widgets/task_dialog_test.dart: creates a task with trimmed text and a unique tag |
| test-0 | 135443980960 | test/quick_capture_dialog_test.dart: Quick Capture can create a center inline and immediately select it |
| test-0 | 135443980960 | test/services/task_report_filter_test.dart: combined filters use AND semantics without mutating tasks |
| test-0 | 135443980960 | test/device_feedback_home_regression_test.dart: Home keeps backup in the More menu instead of the header |
| test-0 | 135443980960 | test/primary_bottom_navigation_test.dart: primary navigation exposes exactly five canonical destinations |
| test-0 | 135443980960 | test/home/home_filter_contract_test.dart: Home keeps completed past tasks visible in a separate non-overdue group |
| test-0 | 135443980960 | test/follow_up_office_page_test.dart: follow-up office exposes the shared five filter dimensions |
| test-0 | 135443980960 | test/canonical_home_boundary_test.dart: Home owns canonical Task state without legacy ArvinTask projection |
| test-0 | 135443980960 | test/task_people_page_test.dart: empty People UI adds and removes a local Person explicitly |
| test-0 | 135443980960 | test/task_editor_category_project_integration_test.dart: new task saves typed category without an extra apply step |
| test-0 | 135443980960 | test/home_today_about_test.dart: Today menu action shows only active canonical tasks due today |
| test-1 | 135443981268 | test/task_timeline_page_test.dart: renders canonical task history in chronological order |
| test-1 | 135443981268 | test/calendar_explicit_export_contract_test.dart: normal Task save, capture, edit and completion contain no outbound sync |
| test-1 | 135443981268 | test/widgets/home_page_test.dart: completed tasks remain visible in All and Completed filters |
| test-1 | 135443981268 | test/widgets/home_page_test.dart: Home uses the five checkbox filters as combined filters and preserves time grouping |
| test-1 | 135443981268 | test/quick_capture_dialog_test.dart: canonical capture keeps title-only path and optional choices |
| test-1 | 135443981268 | test/quick_capture_dialog_test.dart: Quick Add scheduling uses the canonical circular date/time picker |
| test-2 | 135443981083 | test/settings_page_test.dart: settings exposes date, swipe, projects and canonical backup controls |
| test-2 | 135443981083 | test/widgets/home_quick_capture_test.dart: Home primary add persists canonical task and preserves history |
| test-2 | 135443981083 | test/quick_capture_dialog_test.dart: Quick Add opens an independent Persian reminder date/time picker |
| test-2 | 135443981083 | test/quick_capture_dialog_test.dart: Quick Add shows the selected scheduling time and uses injected now |
| test-2 | 135443981083 | test/follow_up_entry_page_test.dart: waiting FollowUp can add, select, reopen and remove a stable person |
| test-2 | 135443981083 | test/home_last_follow_up_real_record_test.dart: Home shows last FollowUp only for a real record and does not create one |
| test-2 | 135443981083 | test/task_contract_test.dart: due date stays independent from reminder and follow-up timestamps |
| test-2 | 135443981083 | test/task_store_reminder_persistence_test.dart: legacy reminder-table migration removes its flag without losing reminder rows |
| test-2 | 135443981083 | test/widget_test.dart: Home exposes the canonical workflow controls |
| test-2 | 135443981083 | test/task_editor_dialog_test.dart: Back-style close prompts and can save Task edits without data loss |
| test-2 | 135443981083 | test/home/home_owner_reference_test.dart: Home follows the owner header, real summary values and Today navigation |
| test-2 | 135443981083 | test/home/home_filter_boolean_logic_test.dart: Home filters combine OR within each dimension and AND across dimensions |
| test-2 | 135443981083 | test/task_editor_due_date_preservation_test.dart: editing preserves canonical due date independently |
| test-2 | 135443981083 | test/follow_up_office_page_test.dart: selects one of multiple tasks and persists only to that task |
| test-2 | 135443981083 | test/task_detail_person_persistence_test.dart: Task Details Follow-up person selection persists through canonical Person and relation tables |
| test-2 | 135443981083 | test/task_detail_master_screen_test.dart: Task Details presents canonical follow-up title, note and waiting-for-response state |
| test-2 | 135443981083 | test/task_detail_master_screen_test.dart: Task Details persists checklist reorder and additions immediately without changing Follow-up history |
| test-2 | 135443981083 | test/home_wave2_editor_wiring_guard_test.dart: Home add/edit stay wired to the canonical Wave 2 coordinator |
| test-2 | 135443981083 | test/notebook_page_test.dart: editor tag picker replaces tags on the same canonical note |
| test-2 | 135443981083 | test/canonical_home_boundary_test.dart: normal save, Quick Capture, edit and completion never export automatically |
| test-2 | 135443981083 | test/task_detail_checklist_crud_test.dart: checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps |
| test-2 | 135443981083 | test/home_today_about_test.dart: Today menu action has a dedicated empty state |
| test-2 | 135443981083 | test/quick_capture_project_create_test.dart: Quick Add offers Project create-new and selects the created project |
| test-2 | 135443981083 | test/report_center_page_test.dart: Report Center exposes center and searchable task controls |
| test-2 | 135443981083 | test/home_stat_filters_test.dart: category checkbox selection applies OR only after confirmation |
| test-3 | 135443981089 | test/widgets/home_page_test.dart: RTL Move-to-Today does not dismiss and None is a no-op |
| test-3 | 135443981089 | test/widgets/home_page_test.dart: Home five filters stay in one RTL row without horizontal scrolling at phone widths and with keyboard |
| test-3 | 135443981089 | test/widgets/home_page_test.dart: Home Past time filter excludes today and prioritizes incomplete tasks |
| test-3 | 135443981089 | test/quick_capture_dialog_test.dart: Quick Add reminder presets match the product contract |
| test-3 | 135443981089 | test/quick_capture_dialog_test.dart: Quick Add custom recurrence exposes every canonical time unit |
| test-3 | 135443981089 | test/device_feedback_home_regression_test.dart: normal-height Home keeps empty groups and floating add action |
| test-3 | 135443981089 | test/task_editor_dialog_test.dart: task editor recurrence uses RollBox and preserves interval |
| test-3 | 135443981089 | test/home/home_filter_contract_test.dart: Home task card expands in place with real FollowUp history and preserves details route |
| test-3 | 135443981089 | test/follow_up_office_page_test.dart: legacy Next Follow-up dates never create an automatic due filter |
| test-3 | 135443981089 | test/task_detail_master_screen_test.dart: Smart visibility keeps an ordinary Task detail compact |
| test-4 | 135443981321 | test/calendar_page_test.dart: prayer cards use mosque icon and subdued unregistered status |
| test-4 | 135443981321 | test/task_detail_master_screen_test.dart: Smart visibility shows rich sections only when canonical data exists |
| test-4 | 135443981321 | test/task_detail_master_screen_test.dart: Task Details presents summary, metadata and due date once in RTL order |
| test-4 | 135443981321 | test/issue_1891_lane_d_rollbox_test.dart: issue 1891 tag roll box supports multi-select with apply/cancel |
| test-4 | 135443981321 | test/g6_swipe_rtl_acceptance_test.dart: configured left and right swipes open Follow-up form and write only after save |
| test-4 | 135443981321 | test/task_editor_dialog_test.dart: Task editor saves a real all-day deadline from inside the clock dialog |
| test-4 | 135443981321 | test/work_agenda_pdf_renderer_test.dart: existing PDF renderer builds grouped Work Agenda bytes |
| test-4 | 135443981321 | test/widgets/home_page_test.dart: overdue active task uses red text while card and icons stay neutral |
| test-4 | 135443981321 | test/home_today_about_test.dart: About menu action opens the built-in Arvin about dialog |
| test-5 | 135443981366 | test/canonical_calendar_launcher_test.dart: repeat occurrence actions resolve back to the canonical Task |
| test-5 | 135443981366 | test/task_detail_master_screen_test.dart: Task Details does not present related people as assignees and keeps bottom content clear |
| test-5 | 135443981366 | test/notebook_page_test.dart: Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries |
| test-5 | 135443981366 | test/widget_test.dart: HomePage shows the empty-state message after loading |
| test-5 | 135443981366 | test/report_center_page_test.dart: Report Center quick presets apply from a dedicated bottom sheet |
| test-5 | 135443981366 | test/widgets/home_page_test.dart: Home separates calendar today from selected focus and persists toggle removal |
| test-5 | 135443981366 | test/widgets/home_page_test.dart: Focus Today is reachable from drawer More and global funnel with one result set |
| test-5 | 135443981366 | test/quick_capture_dialog_test.dart: timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder |
| test-5 | 135443981366 | test/task_editor_dialog_test.dart: Task editor cancelling the circular clock does not commit a partial date |
| test-5 | 135443981366 | test/follow_up_office_page_test.dart: asks the user to create a task when the list is empty |

### Exact-head non-shard outcomes
- Analyze: PASS; Visual: PASS.
- Debug APK: PASS; Release APK: PASS.
- Staging APK: FAIL on the first attempt because Gradle could not resolve Kotlin 2.2.21 artifacts (stdlib, Gradle plugin and BOM) from Plugin Portal; this is classified as external dependency resolution, not source compilation failure.
- Staging job 135443981025 was retried alone after diagnosis. Retry job 135449076966 was IN PROGRESS at the last poll; do not count it as PASS yet.
- Follow-up File Persistence run 44490319367: PASS.
- Calendar Provider run 44490319483: PASS.
- Draft Review APK run 44490319361: PASS.
- G1 Lock Sync run 44490319577: PASS.
- Device Smoke run 44490319359: PENDING with no jobs returned; no device lane is accepted.
- Published workflow artifacts: arvin-debug-apk (93,488,372 bytes; artifact ID 14513066414) and arvin-release-apk (38,041,994 bytes; artifact ID 14513291302). No staging APK artifact was produced because the staging build failed.

### Confirmed correction and open root causes
- The Vazirmatn RootBundle license/authors regression passed on this SHA after explicit asset declarations in pubspec.yaml. This confirms the asset-bundle fix at test level; APK visual font rendering remains unverified.
- test/task_contract_test.dart: the fixture passed deprecated Task.reminderDate to a constructor that intentionally ignores that legacy input. The corrected canonical TaskReminder fixture is isolated in draft PR #3570; no merge yet.
- test/home/home_filter_contract_test.dart: Home did not render the completed past item under the current six-group implementation. The five-group product correction is isolated in draft PR #3569; no merge yet.
- test/task_store_reminder_persistence_test.dart still reports that is_legacy_task_reminder remains in the existing SQL table. The safe table migration is NOT implemented; review unknown columns/indexes/FKs and preservation requirements before changing schema.
- test/home/home_filter_boolean_logic_test.dart has a hit-test warning when selecting an off-screen checkbox option in the filter sheet; determine whether the sheet needs scrolling/layout correction or the test needs a correct scroll interaction. Do not suppress the warning.
- Quick Capture tests cannot find the expected visible «یادآور» / «تکرار» controls. This remains a product/UI contract mismatch until the complete capture form and responsive layout are reviewed.
