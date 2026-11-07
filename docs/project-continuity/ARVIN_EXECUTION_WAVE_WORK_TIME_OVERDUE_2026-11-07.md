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


## Storage wave — canonical relational tables (schema v12)

- Bumped `G1DriftSchema.version` from 11 to 12.
- Added first-class `task_reminders` with stable reminder ID, Task FK, independent datetime, all-day state, sequence, enabled state and transitional legacy-origin marker.
- Added historical-only `follow_up_records` with `completed_at` as the timestamp driver. The canonical table has no `reminder_date` or `next_follow_up` scheduling columns.
- Added canonical `persons` directory and `follow_up_record_people` relation.
- Added idempotent materialization from existing Task reminder envelopes, old `follow_ups` rows and person directory/relations. Reminder IDs, sequence, all-day state, Follow-up IDs/timestamps and person IDs are retained.
- `TaskStore` now reads and writes Task reminders through `task_reminders`; Follow-up history is read/written through `follow_up_records`; the Person directory uses `persons`.
- A transitional compatibility bridge still writes/reads legacy `follow_ups` rows for the remaining UI consumers of old Follow-up scheduling properties. The old `tasks` columns and `people`/ `follow_ups` tables have NOT been dropped yet. They must only be removed after the consumer audit and model/UI migration are complete.
- Added schema-level migration tests for multiple reminders, historical Follow-up records, person relations, and absence of future-scheduling columns from the canonical record table; added TaskStore relational persistence tests.
- This is an implementation step, not the final clean-slate cutover. Exact-head CI is pending; no test PASS is claimed from source edits alone.

## Latest test recovery batch

- Updated stale tests to the approved Calendar phrase, the current waiting-for-others label, the complete Person filter semantics, and timed/all-day overdue boundaries.
- Home now keeps completed past Tasks visible in a separate «گذشته (انجام‌شده)» group instead of misclassifying them as overdue or hiding them.
- Rebuilt CI must confirm all updated tests on the exact current HEAD before acceptance.


## Storage cutover wave — schema v13/v14

- `G1DriftSchema.version` is now 14.
- The canonical Task table has been rebuilt without `follow_up_enabled`, `follow_up_date` and singular `reminder_date` columns. Existing Task IDs, content, completion, due date, recurrence and payload data are copied transactionally; foreign keys are disabled only during the rebuild, checked before commit, then re-enabled.
- The legacy `follow_ups`, `follow_up_people` and `people` tables are copied into `follow_up_records`, `follow_up_record_people` and `persons`, then dropped. Fresh schema creation no longer creates the old tables.
- The canonical TaskReminder table now owns all reminders. Old Task-level singular reminders and reminders formerly attached to Follow-up history are converted to independent TaskReminder records with Task-scoped stable IDs and preserved all-day state. Legacy future `nextFollowUp` scheduling is intentionally not carried forward.
- `FollowUpRecord` is now the canonical model name (with a temporary source-compatible `FollowUp` type alias); its canonical timestamp is `completedAt`. Its JSON contains historical fields only, with no reminder or future schedule fields.
- `Person` is now the canonical model name (with a temporary `PersonReference` alias). TaskStore, SQL migration writer and person directory use the `persons` table.
- Follow-up editor no longer edits reminder/future scheduling on a historical record. Its optional reminder action creates an independent TaskReminder, including when editing an existing record.
- Task timeline and Calendar projections now consume independent TaskReminder entries. Task Details no longer renders a duplicate legacy reminder card.
- Added/updated migration, persistence, timeline and UI regression tests. All source/test changes still require exact-HEAD CI confirmation; no PASS is claimed before those runs complete.

## Remaining cleanup after this cutover
- Compatibility constructor arguments/getters remain temporarily in the Dart model to keep old call sites source-compatible; they no longer represent persisted Task/Follow-up state. Remove those shims after the remaining test fixtures and consumers are fully migrated.
- The reusable five-way multi-select filter component and complete reuse across Home, Quick Add, Task Details and Reports are still pending.
- Physical Samsung SM-A528B/DS seven-path verification remains pending and is a hard release gate.


## Shared five-way filter interaction wave

- Added `ReusableMultiSelectFilterBottomSheet` with multi-select checkboxes, search, a clear-all option inside the sheet, inline creation, and automatic selection of newly created items. Single-select mode reuses the same bottom-sheet design for Task metadata selectors.
- Home now opens the shared component for Center, Project, Category and Tag filters; the Time filter uses the shared sheet shell for its date/time controls. The Home row remains one RTL row of five controls (Time, Center, Project, Category, Tag), with no All chip and no horizontal scroll.
- Quick Add and the full Task editor now use the shared selector for Center, Project, Category and Tag; tag selection remains multi-select. Inline creation receives the typed name, persists through the existing entity callback, and returns the created item selected.
- Task Details inline editing now uses the same component for Center, Project, Category and Tags. Center selection persists through the existing `Task.centerId` field; Project assignment persists through the canonical Project relation. Project choices are scoped to the selected Center, and creating a Project passes the selected `centerId`.
- Reports now has a compact five-way RTL filter row. Center, Project, Category, Tag and Person selections open the shared checkbox sheet; new values are saved through the canonical entity callbacks and selected immediately. Report Person matching continues to include linked Tasks and historical Follow-up records.
- Added a dedicated widget test for multi-select, inline creation/auto-selection and single-select clearing, plus a Task Details metadata selector test and updated Report filter interaction tests.
- Exact-head CI remains the acceptance gate; this wave is not marked PASS until the new workflows complete.

## Remaining UI/data caveats
- Task Details now edits `Task.centerId` directly and persists Project membership independently. Clearing Center also clears an incompatible Project; selecting a Center filters available Projects.
- Quick Add and the full Task editor persist Center on the Task and keep Project assignment as a separate relation.
- The shared filter component and the latest schema cutover still require exact-HEAD CI and physical-device validation.


## Task Details Center / Project selector completion

- Task Details inline metadata now uses the shared bottom sheet for all four selectors: Center, Project, Category and Tags.
- Center selection updates the existing canonical `Task.centerId` field. Project selection updates the separate Project membership relation; choosing a Center filters available Projects, and clearing Center clears a Project that no longer matches.
- Inline-created Projects are persisted with the selected `centerId`; the full Task editor and Quick Add use the same selected-Center context.
- Report and Home center filters already prioritize `Task.centerId`, then use the existing Project center relation as a fallback for older tasks.
- Added a widget regression test for selecting Center then Project and verifying both persisted values. Exact-HEAD CI remains required.


## Canonical storage and consumer-alignment pass — 2026-11-07

- Source audit confirms Drift schema version **14** declares canonical `tasks`, `task_reminders`, `follow_up_records`, and `persons` tables. The schema installer migrates legacy Follow-up/person/reminder rows and rebuilds `tasks` without `follow_up_enabled`, `follow_up_date`, or `reminder_date`; old `follow_ups` and `people` tables are retired after transfer.
- TaskStore reads/writes independent reminder and Follow-up relation rows. The model retains a deprecated compatibility boundary only while remaining source consumers/tests are migrated; the compatibility reminder projection now resolves the primary independent reminder rather than only legacy-marked rows.
- Alarm planning no longer schedules the same primary reminder twice through both the singular compatibility view and the independent reminder collection. Delivery-state reconciliation now derives live reminder keys from independent reminder IDs.
- Work Agenda now projects every enabled independent Task reminder instead of one singular reminder.
- Compile fixes: imported the shared filter component and Center model where newly shared selectors are consumed; corrected generic result construction and tag-create callback adaptation; added reminder identity support to TaskReminder.copyWith.
- No tests were deleted, skipped, or weakened. The previous exact-HEAD CI on `0c89f9f3643d82302d686721558ca9445a03423a` failed because the model cutover removed compatibility members before all consumers/tests were moved. A staged compatibility boundary has been restored; the follow-up exact-HEAD CI is running on `381ff68207a201ed722ae428ec8ffc48418b458b`.
- Remaining schema/entity work: replace JSON-backed `task_people` with an FK-backed relation to `persons`, verify person assignment/report filtering end-to-end, and finish migration of all remaining compatibility call sites before removing deprecated model projections.
- Current exact-HEAD Build, Review APK, Calendar Provider, Follow-up Persistence and Device Smoke results must be read from their run IDs for this SHA; none of the earlier SHA results may be carried forward.


## Unified Person relation normalization — 2026-11-07

- Added canonical `task_persons` with foreign keys to `tasks` and `persons`; `follow_up_record_people.person_id` now references the same `persons` directory.
- Schema installation now migrates the former JSON-backed `task_people` rows into `task_persons` and drops the old relation table. Fresh databases no longer create `task_people`.
- TaskStore reads Task people by joining `task_persons` to `persons`, writes only stable Person IDs, and preserves referenced directory entries when replacing the unreferenced directory catalog.
- SQL migration writer now writes normalized Person links and inserts required Person rows before dependent Follow-up relations. Removed a duplicate TaskReminder insert loop found during the same persistence audit.
- Tests now assert the normalized schema, Person foreign keys, old-relation migration, multiple reminder persistence, and absence of legacy reminder resurrection. These tests remain active; no test was removed or skipped.
- The next exact-HEAD CI is required on the new branch HEAD after this batch. The prior 2026-11-07 runs on older SHAs remain historical only.


## Date-only / All-Day storage contract — 2026-11-07

- The shared round clock contains its own explicit `بدون ساعت` action. Date selection remains first; the clock opens immediately after date confirmation. Cancellation returns without changing the prior committed value.
- Central overdue logic is confirmed: timed Tasks become overdue after the exact due datetime; All-Day Tasks become overdue at the start of the next local calendar day; completed or undated Tasks are never overdue.
- Task and TaskReminder serialization now writes All-Day values as date-only `YYYY-MM-DD` strings. Timed values retain full timestamps. SQLite TaskStore, schema cutover, and SQL migration writer use the same date-only encoding, avoiding synthetic `00:00` in persisted floating values.
- Added regression coverage for Task All-Day due-date serialization and raw SQLite All-Day reminder storage. Existing persistence coverage still checks reminder IDs, order, and independent timestamps.
- Latest code/test HEAD before this note: `c0a6118685ab9d52f962e83c947e2977d98ab7fc`; exact-HEAD CI has started and remains pending/in progress at time of recording.
