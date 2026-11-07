# Execution wave — unified work-time interaction and overdue semantics
Date: 2026-11-07
Branch: fix/recovery-calendar-device-smoke-2026-10-31
PR: #3052 — OPEN / DRAFT / UNMERGED
Release: BLOCKED — RELEASE: NO-GO

## Implemented on this branch
- Task Details inline editing now exposes one «زمان کار / موعد» action instead of separate date and time buttons. It opens the Persian date picker, then the round clock dialog. The clock's explicit «بدون ساعت» action stores the date-only value at midnight with `allDay=true`; no state is committed when either dialog is cancelled.
- Task Details independent reminder create/edit uses the same date-then-clock sequence and supports the clock dialog's explicit no-time option. All-day reminders store a date-only value and `TaskReminder.isAllDay=true`.
- Reports Person multi-select now matches both tasks linked through `Task.people` and all historical Follow-up records linked through `FollowUp.personIds`; it no longer restricts person matching to active waiting Follow-ups. The existing Follow-up entry flow already reveals Person selection when the waiting toggle is enabled.
- Quick Capture custom reminder selection now uses the same explicit time-selection result and persists `Task.reminderAllDay` for no-time reminders. Its existing unified work-time due picker already used the sequential date + clock flow.
- Added central `TaskDueStatus.isOverdue`: timed tasks become overdue strictly after their datetime; all-day tasks become overdue at the first instant of the next local calendar day; completed or undated tasks are never overdue.
- Home overdue warning and grouping now use the central rule. Report Center overdue coloring and Report Time «گذشته» matching use the same timed/all-day boundary.
- Calendar's tafweez vector label now matches exactly «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ» without the leading waw; the SVG asset path remains `assets/images/branding/tafweez.svg`.
- Added a focused unit test file for timed, all-day, completed and undated overdue boundaries. Updated Task Details picker regression test and Calendar phrase expectation.

## Explicitly not yet implemented or accepted
- Drift clean-slate schema refactor remains pending: current inspected schema still has legacy `follow_up_enabled`, `follow_up_date`, `reminder_date`, and `next_follow_up` columns; dedicated `task_reminders` and canonical `follow_up_records` conversion are not yet completed. No destructive DDL was run.
- Shared `ReusableMultiSelectFilterBottomSheet` and reuse across Home, Quick Add, Task Details and Reports remain pending.
- Person association in the «منتظر پیگیری دیگران» flow and Reports Person filter across both tasks and follow-ups remain pending.
- Bismillah fixed 210dp width and full seven-lane physical Samsung SM-A528B/DS evidence remain to be verified.
- The light turquoise palette tokens were already present in the inspected central theme at the initial checkpoint; this wave did not rewrite them.
- No test command or workflow dispatch was available through the current GitHub connector actions. Source/test changes are not marked PASS until an exact-HEAD CI run reports them.
- Emulator Device Smoke does not satisfy physical Samsung acceptance.

## Source/test files changed in this wave
- `lib/task_detail_page.dart`
- `lib/quick_capture_dialog.dart`
- `lib/main.dart`
- `lib/report_center_page.dart`
- `lib/services/task_due_status.dart` (new)
- `lib/services/task_report_filter.dart`
- `lib/calendar_page.dart`
- `test/task_detail_master_screen_test.dart`
- `test/calendar_page_test.dart`
- `test/services/task_due_status_test.dart` (new)

No tests were deleted or weakened. `main` was not modified. No merge, publication or release occurred.
