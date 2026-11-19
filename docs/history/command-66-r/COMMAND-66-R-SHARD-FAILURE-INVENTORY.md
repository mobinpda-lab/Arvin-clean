# COMMAND 66-R — Six-shard failure inventory

- Repository: `mobinpda-lab/Arvin-clean`
- Source PR: #3570
- Build run: `44499570840`
- Source head SHA: `fd4954d773e039cb56ed31806fd2b4790b82d3b5`
- Analyze: SUCCESS
- Visual: SUCCESS
- APK Debug / Release / Staging: SUCCESS
- Shards: 6/6 FAILED
- Failed test instances: 64
- Unique failed test names: 64
- Exact duplicate test names across these six shards: 0

This is a factual inventory from all six job logs. The classification below is a triage index, not a claim that every failure has a proven product root cause. Missing widget finders, `Bad state: No element`, hit-test errors, and `pumpAndSettle` timeouts are not automatically classified as product defects; inspect the exact widget tree and source path before changing either implementation or test.

## Shard 0 — 12 failures

1. `test/task_detail_checklist_flow_test.dart` — task detail displays checklist and toggles an item
2. `test/home/home_filter_contract_test.dart` — Home keeps completed past tasks visible in a separate non-overdue group
3. `test/canonical_home_boundary_test.dart` — Home owns canonical Task state without legacy ArvinTask projection
4. `test/task_people_page_test.dart` — empty People UI adds and removes a local Person explicitly
5. `test/device_feedback_home_regression_test.dart` — Home keeps backup in the More menu instead of the header
6. `test/primary_bottom_navigation_test.dart` — primary navigation exposes exactly five canonical destinations
7. `test/widgets/task_dialog_test.dart` — creates a task with trimmed text and a unique tag
8. `test/home_today_about_test.dart` — Today menu action shows only active canonical tasks due today
9. `test/quick_capture_dialog_test.dart` — Quick Capture can create a center inline and immediately select it
10. `test/task_editor_category_project_integration_test.dart` — new task saves typed category without an extra apply step
11. `test/follow_up_office_page_test.dart` — follow-up office exposes the shared five filter dimensions
12. `test/services/task_report_filter_test.dart` — combined filters use AND semantics without mutating tasks

## Shard 1 — 4 failures

1. `test/widgets/home_page_test.dart` — completed tasks remain visible in All and Completed filters
2. `test/widgets/home_page_test.dart` — Home uses the five checkbox filters as combined filters and preserves time grouping
3. `test/quick_capture_dialog_test.dart` — canonical capture keeps title-only path and optional choices
4. `test/quick_capture_dialog_test.dart` — Quick Add scheduling uses the canonical circular date/time picker

## Shard 2 — 23 failures

1. `test/settings_page_test.dart` — settings exposes date, swipe, projects and canonical backup controls
2. `test/widgets/home_quick_capture_test.dart` — Home primary add persists canonical task and preserves history
3. `test/quick_capture_dialog_test.dart` — Quick Add opens an independent Persian reminder date/time picker
4. `test/quick_capture_dialog_test.dart` — Quick Add shows the selected scheduling time and uses injected now
5. `test/follow_up_entry_page_test.dart` — waiting FollowUp can add, select, reopen and remove a stable person
6. `test/home_last_follow_up_real_record_test.dart` — Home shows last FollowUp only for a real record and does not create one
7. `test/widget_test.dart` — Home exposes the canonical workflow controls
8. `test/home/home_owner_reference_test.dart` — Home follows the owner header, real summary values and Today navigation
9. `test/home/home_filter_boolean_logic_test.dart` — Home filters combine OR within each dimension and AND across dimensions
10. `test/command63_occurrence_checklist_persistence_test.dart` — COMMAND 63-R schema 17 preserves Occurrence and Checklist envelopes across three installs and file reopen
11. `test/follow_up_office_page_test.dart` — selects one of multiple tasks and persists only to that task
12. `test/task_detail_person_persistence_test.dart` — Task Details Follow-up person selection persists through canonical Person and relation tables
13. `test/task_detail_master_screen_test.dart` — Task Details presents canonical follow-up title, note and waiting-for-response state
14. `test/task_detail_master_screen_test.dart` — Task Details persists checklist reorder and additions immediately without changing Follow-up history
15. `test/home_wave2_editor_wiring_guard_test.dart` — Home add/edit stay wired to the canonical Wave 2 coordinator
16. `test/notebook_page_test.dart` — editor tag picker replaces tags on the same canonical note
17. `test/canonical_home_boundary_test.dart` — normal save, Quick Capture, edit and completion never export automatically
18. `test/home_today_about_test.dart` — Today menu action has a dedicated empty state
19. `test/quick_capture_project_create_test.dart` — Quick Add offers Project create-new and selects the created project
20. `test/report_center_page_test.dart` — Report Center exposes center and searchable task controls
21. `test/home_stat_filters_test.dart` — category checkbox selection applies OR only after confirmation
22. `test/task_detail_checklist_crud_test.dart` — checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps
23. `test/home/home_filter_boolean_logic_test.dart` and `test/task_report_filter_test.dart` are separate test files/contracts; do not conflate their filter semantics.

## Shard 3 — 10 failures

1. `test/quick_capture_dialog_test.dart` — Quick Add reminder presets match the product contract
2. `test/quick_capture_dialog_test.dart` — Quick Add custom recurrence exposes every canonical time unit
3. `test/task_detail_master_screen_test.dart` — Smart visibility keeps an ordinary Task detail compact
4. `test/device_feedback_home_regression_test.dart` — normal-height Home keeps empty groups and floating add action
5. `test/task_editor_dialog_test.dart` — task editor recurrence uses RollBox and preserves interval
6. `test/home/home_filter_contract_test.dart` — Home task card expands in place with real FollowUp history and preserves details route
7. `test/widgets/home_page_test.dart` — RTL Move-to-Today does not dismiss and None is a no-op
8. `test/widgets/home_page_test.dart` — Home five filters stay in one RTL row without horizontal scrolling at phone widths and with keyboard
9. `test/widgets/home_page_test.dart` — Home Past time filter excludes today and prioritizes incomplete tasks
10. `test/follow_up_office_page_test.dart` — legacy Next Follow-up dates never create an automatic due filter

## Shard 4 — 9 failures

1. `test/widgets/home_page_test.dart` — Home separates calendar today from selected focus and persists toggle removal
2. `test/widgets/home_page_test.dart` — Focus Today is reachable from drawer More and global funnel with one result set
3. `test/quick_capture_dialog_test.dart` — timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder
4. `test/widget_test.dart` — HomePage shows the empty-state message after loading
5. `test/follow_up_office_page_test.dart` — asks the user to create a task when the list is empty
6. `test/task_detail_master_screen_test.dart` — Task Details does not present related people as assignees and keeps bottom content clear
7. `test/notebook_page_test.dart` — Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries
8. `test/canonical_calendar_launcher_test.dart` — repeat occurrence actions resolve back to the canonical Task
9. `test/report_center_page_test.dart` — Report Center quick presets apply from a dedicated bottom sheet

## Shard 5 — 6 failures

1. `test/widgets/home_page_test.dart` — overdue active task uses red text while card and icons stay neutral
2. `test/task_detail_master_screen_test.dart` — Smart visibility shows rich sections only when canonical data exists
3. `test/task_detail_master_screen_test.dart` — Task Details presents summary, metadata and due date once in RTL order
4. `test/issue_1891_lane_d_rollbox_test.dart` — issue 1891 tag RollBox supports multi-select with apply/cancel
5. `test/home_today_about_test.dart` — About menu action opens the built-in Arvin about dialog
6. `test/calendar_page_test.dart` — prayer cards use mosque icon and subdued unregistered status

## Confirmed cross-cutting observations

- There are 64 unique failed test names across these six shards; exact test-name duplication is zero.
- UI contract failures span Home, Quick Capture, Task Editor, Task Details, People, Follow-up, Notebook, Reports and Settings. They are not one single root cause.
- Three observed `pumpAndSettle` timeouts occur in Follow-up Office flows; inspect ongoing animations/tickers and test pump strategy separately from data correctness.
- `canonical_home_boundary_test.dart` has a source-boundary helper failure: `RangeError (end)` from `substring` after a searched boundary returns -1. This is a test-helper defect unless a separate product contract is failing.
- `home_wave2_editor_wiring_guard_test.dart` expects 5 editor paths but finds 6. Review the sixth path against the canonical coordinator before changing the guard; do not delete an assertion to force green.
- `task_report_filter_test.dart` uses a Follow-up timestamp at 09:00 while the selected record-time window is 14:00–17:00. Its fixture was corrected on the operational branch by moving the Follow-up record to 15:00; the expected result and assertion remain unchanged. This is not a Home filter failure.
- The separate legacy reminder failures in child branches use deprecated Task-level `reminderDate` and expect it to round-trip through canonical `Task.fromJson`; the appropriate canonical fixture uses `TaskReminder`, while legacy conversion belongs to `Task.fromLegacyJson`.
- PR #3569 changes the visible grouping of completed past tasks by merging them into overdue. This is a product behavior change and must not be accepted without explicit product-contract validation.

## Acceptance rule

This inventory is not a closure report. Each test remains OPEN until its exact source branch is inspected, a product/test/environment root cause is recorded, any correction preserves assertions and user data, and the full six-shard suite passes on one identical final SHA.
