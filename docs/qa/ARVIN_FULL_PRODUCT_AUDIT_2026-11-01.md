# ARVIN — Full Product Audit, Canonical Baseline & Evidence Ledger
**Audit date:** 2026-11-01  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Governing acceptance:** Issue [#823](https://github.com/mobinpda-lab/Arvin-clean/issues/823)  
**Historical tracking only:** Issue [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139)  
**Release decision:** `BLOCKED — RELEASE: NO-GO`  
**Authorized implementation lane:** PR [#3052](https://github.com/mobinpda-lab/Arvin-clean/pull/3052), branch `fix/recovery-calendar-device-smoke-2026-10-31`

## 1. Audit method and governing rules

This ledger separates source-code observations, automated test evidence, emulator/runtime evidence, and physical-device acceptance. A source file, widget key, test name, workflow definition, or historical commit is not by itself proof that a user-visible requirement works.

Allowed status values (exactly one per audit row):

- **IMPLEMENTED + VERIFIED** — behavior is supported by target-SHA source and a named test or workflow run with successful relevant evidence.
- **IMPLEMENTED BUT NOT VERIFIED** — an implementation path is present, but current target-SHA/runtime evidence is missing.
- **PARTIALLY IMPLEMENTED** — only part of the requirement is implemented, or the observed implementation conflicts with another part.
- **NOT IMPLEMENTED** — the required behavior is absent or directly contradicted by inspected code.
- **BLOCKED** — safe implementation/acceptance depends on missing data, an unresolved product decision, unavailable physical-device evidence, or another explicit prerequisite.

The word **NOT VERIFIED** is used in evidence fields whenever proof is absent. No PASS is inferred from file existence or old runs.

No database was modified during this audit. The live user database was not inspected for emptiness; therefore no destructive migration or table rebuild is authorized by this report.

## 2. Live repository checkpoint before audit edits

At the start of the live inspection:

| Item | Observed value |
|---|---|
| Repository default branch | `main` |
| PR #3052 | OPEN, Draft, unmerged |
| PR branch | `fix/recovery-calendar-device-smoke-2026-10-31` |
| Initial PR head SHA | `3b5721d67e461976748220bcaeb78376c25affe0` |
| PR base SHA | `45e4202b03a434459e4c021a04efa7e8396359db` |
| Issue #823 | OPEN |
| Issue #2102 | OPEN |
| Issue #1139 | OPEN; historical tracking only |
| NIRA | Not modified |

The initial SHA exactly matched the SHA in the user-supplied historical report. Subsequent commits in this authorized PR branch correct the Staging output path, add a path-contract test, and record this audit. The live PR head must be re-read after those commits; evidence from `3b5721d...` must not be attributed to later SHAs.

## 3. Complete canonical product baseline (preserved)

The following requirements are the acceptance contract for this audit. They are not weakened by current implementation gaps.

### A. Product concepts and data integrity

- Arvin is a Persian-first personal product for task capture and organization, reminders, recurrence, genuine past actions, internal calendar, reports, search, backup and restore.
- Keep Task, Due Date, Reminder and Follow-up Record as four distinct concepts. Every user-created item is a Task; do not create a separate “follow-up task” type.
- A Task may have a Due Date, multiple Reminders, recurrence, Checklist and genuine Follow-up Records.
- A Due Date is independent of a Reminder. All-day items have no real time; 00:00 must not be treated as a real alarm/sync time.
- A Follow-up Record represents only a real completed past action and has a real completedAt timestamp. Future plans belong exclusively to Reminders.
- Permanently remove any live product behavior for “Next Follow-up” / “Scheduled Follow-up” from UI, models, schema and queries. Do not restore it through backup/restore.
- Remove followUpEnabled from the active schema and model; no runtime path may read or write it. Preserve user data if any exists and use a safe migration.
- The Follow-up table must contain no future-scheduling fields. A Follow-up text edit must never alter completedAt.
- If converting a Follow-up into a new Task is supported or retained, it must be explicit, preserve a stable relationship, be idempotent, and not mutate the parent Task’s history or the original Follow-up.
- Completing a Task suppresses future notifications but preserves history.

### B. Capture forms, Reminders and Checklist

- Quick capture is simple, has no Checklist and has no legacy flags.
- Full Task form may manage multiple independent Reminders. Editing/deleting one Reminder changes only that Reminder.
- Relative minute/hour reminders are permitted only when a real time exists; an all-day 00:00 is not a relative-time reference.
- Checklist is managed only in Task Details, never in the initial-create form. Add/Edit/Delete must work and preserve valid data.
- The Follow-up entry form has an optional “افزودن یادآور” / “تنظیم یادآور برای این کار” shortcut. When enabled, collect date/time and create a normal Reminder linked to the same Task. Never store future data in the Follow-up record.
- New Follow-up defaults to “now”; the user may change the actual completion date/time using the official Universal Arvin Time Picker.

### C. Follow-up views and reports

- The follow-up ledger is record-driven: include a Task only when it has at least one real follow_up_records row. Determine its latest Follow-up by MAX(completedAt) for that Task.
- Add “گزارش پیگیری‌های انجام‌شده” inside the existing Report Center; open on today.
- Filter only by completedAt, never by Task due date, Task creation/edit time or Reminder time.
- Use a Jalali day and the half-open interval [start of day, start of next day) in the app timezone. Do not use 23:59:59 or a fixed +24-hour assumption.
- Provide a Jalali date picker, previous-day, next-day and Today controls.
- Show a summary such as “۷ پیگیری برای ۴ کار” computed only from matching genuine Follow-up records.
- Provide “به‌ترتیب ساعت” (default, ascending by actual completedAt) and “بر اساس کار” (grouped by Task).
- Each row shows actual completion time, Task title, Follow-up text/result, related person if available, and navigation to the correct Task Details.
- Task history selection uses stable taskId, not title alone; show all history with ascending and descending sorting.
- Keep Follow-ups visible for open, completed and archived Tasks. Task status changes must not erase genuine historical records.
- Never include future Reminders, same-day Due Dates, or Tasks without real Follow-up records in this report. Reading the report must not schedule or trigger notifications.
- Empty state: “برای این روز پیگیری‌ای ثبت نشده است.”
- Error state: “گزارش دریافت نشد. دوباره تلاش کنید.”
- Rapid filter changes must not display stale results.
- Test multiple Follow-ups for one Task on a day, aggregation across Tasks, midnight/day-boundary behavior, excluded Reminders/Due Dates, and navigation to the correct Task.

### D. Home and reminder presentation

- Home has exactly six fixed sections: عقب‌افتاده، امروز، یادآورهای امروز، پیگیری‌های واقعی، بدون تاریخ، انجام‌شده.
- “انجام‌شده” is at the bottom and collapsed.
- Home summary shows only the nearest future Reminder for each Task. Other Reminders remain available in Task Details/internal calendar.
- Treat all-day items as effective 00:00 for ordering, but show them above timed tasks in the UI.
- Do not mix Task, Reminder and Follow-up dates in filters.
- In Calendar, replace the text labels “تقویم آروین” and “وارد‌شده از تقویم گوشی” with small meaningful icons.
- Remove the specified word “یادآوری” from the Calendar presentation where requested; this does not remove the Reminder feature.
- Use a mosque/minaret or suitable Islamic icon for prayer/religious times; remove the specified downward arrow.
- De-emphasize labels such as “برنامه‌ریزی نشده” and “ثبت نشده” using smaller text where practical.
- Use the correct bell icon consistently for all Reminders and a distinct meaningful Arvin-app icon for Arvin-owned items.

### E. Calendar behavior

- Maintain two independent paths:
  1. Local Arvin Calendar: automatic display of eligible Tasks/Reminders and internal source of truth.
  2. Device Calendar: optional, explicit user action for add/update/delete.
- Show at most five future recurrence occurrences in calendar preview.
- Device Calendar sync must be isolated, idempotent and failure-safe. Repeated action must not create duplicates; failure must not damage internal Task/Reminder data.
- Never turn an all-day event into a timed 00:00 event.
- Changes in either calendar path must not unexpectedly mutate the other path’s Task/Reminder state.

### F. Dynamic Task and Calendar Swipe

- In Settings → Tasks/Card Gestures, independently configure left and right Task-list swipes using dropdowns.
- Task swipe options include “ثبت پیگیری”, Archive, Done and Trash/Delete, as applicable. The final product decision is user-configurable freedom, not a hard-coded fixed gesture.
- Selecting “ثبت پیگیری” opens the Follow-up form only; it must not auto-create a record.
- In Settings → Calendar, provide independent left/right gesture settings for calendar cards.
- Calendar swipe options: Edit, Delete/Remove, Transfer/Sync to Device Calendar.
- Calendar swipe configuration and execution must remain isolated from Task-list swipe logic.

### G. Delete lifecycle

- Define soft delete as moving an item to Trash with recovery available.
- Define hard delete as permanent deletion under a clear lifecycle policy, for example when deleting an item already in Trash.
- Do not silently erase independent Follow-up or Reminder history. Document a clear policy; if a decision remains genuinely ambiguous, record it as an open product decision rather than inventing behavior.

### H. Recurrence, search, backup and output

- Separate recurrence pattern from occurrence; preserve occurrence snapshots and avoid history pollution, duplicate occurrences and duplicate Reminders.
- Only advertise filters that real backend/query logic supports. Keep Task, Reminder and Follow-up dates distinct.
- Backup/Restore preserves relationships and history and must not reactivate the prohibited future Follow-up concept.
- PDF output embeds Vazirmatn and renders Persian letter joining correctly.

### I. Typography and RTL

- Vazirmatn is the only official/default font and is bundled inside the APK. System Default is prohibited.
- Apply the font across the app and text outputs, including overlays/third-party surfaces where controllable.
- Use a single theme source and a global render guard to prevent font leakage.
- Typography weights: page title 700; card/Task title 600; controls/chips/buttons 500; body and small calendar text 400.
- CI packaging audit must fail if Vazirmatn is missing.
- Validate PDF font embedding and Persian shaping.
- Maintain strict Persian RTL and Persian digits where required.

### J. Release gates and proof

- Gate 1 Data Model: no active Next Follow-up/followUpEnabled; follow-up view is based on real records.
- Gate 2 Task Swipe: left/right configurable dropdowns include “ثبت پیگیری”; selection opens form only.
- Gate 3 Calendar Swipe: independent settings and Edit/Delete/Transfer-to-device options.
- Gate 4 Device Calendar Sync: idempotent, isolated, failure-safe; all-day is not converted to timed 00:00.
- Gate 5 Typography + PDF: bundled Vazirmatn, consistent UI, embedded font and correct Persian PDF.
- Verify all required tests, including date boundaries, multiple same-day records, cross-Task aggregation, exclusion of future Reminders and Due Dates, correct Task navigation, Checklist CRUD, RTL/font behavior, recurrence, delete lifecycle, and seven Device Smoke lanes.
- Do not report any gate PASS without target SHA + actual run + evidence.
## 4. Evidence-led audit matrix

**Evidence checkpoint for the rows below:** source inspection on PR branch at initial SHA `3b5721d67e461976748220bcaeb78376c25affe0`; Build run `41274996134`; Device Smoke run `41274996175`; Calendar Provider Acceptance run `41274996200`; Fast Lane contract run `41274996107`; Follow-up File Persistence run `41274996125`. The later Task Swipe implementation is a deliberate product-code change on this same PR branch and supersedes initial rows F2/F3; Section 6 records it. Other source findings remain initial-checkpoint observations until validated against the latest PR head.

| ID / requirement group | Status | Source path / user behavior | Relevant test / evidence |
|---|---|---|---|
| A1 Task, Due Date, Reminder and Follow-up are distinct | PARTIALLY IMPLEMENTED | `lib/models/task.dart` defines Task, TaskReminder and FollowUp; Task has dueDate/taskReminders/followUps. FollowUp still owns reminderDate and nextFollowUp. | `test/task_store_test.dart`; Build `41274996134` quality shards PASS, but model contract conflicts with A2/A3. |
| A2 remove Next Follow-up and followUpEnabled from active model/schema/runtime | NOT IMPLEMENTED | `lib/models/task.dart` still declares, serializes and parses followUpEnabled/followUpDate; FollowUp still declares nextFollowUp. | `test/task_store_test.dart` and `test/task_detail_checklist_crud_test.dart` deliberately preserve legacy fields; this is contrary to the new purge requirement. |
| A3 remove future-scheduling columns from Follow-up table | NOT IMPLEMENTED | `lib/services/g1_drift_schema.dart` creates `follow_ups.reminder_date` and `follow_ups.next_follow_up`; `tasks.follow_up_enabled` remains. | `test/services/g1_drift_schema_test.dart` and migration writer currently encode legacy schema; safe migration not present in inspected code. |
| A4 real completedAt on each Follow-up record | PARTIALLY IMPLEMENTED | `FollowUp.dateTime` maps to SQL `follow_ups.date_time`; `Task.completedAt` is a separate Task completion timestamp. No FollowUp.completedAt field was found. | `test/task_store_test.dart` tests Task completedAt preservation, not the required per-record completedAt contract. |
| A5 Follow-up edit cannot mutate its real completion timestamp | PARTIALLY IMPLEMENTED | `lib/task_detail_page.dart` protects Follow-up collection during Task description/checklist edits; record timestamp is currently named dateTime. | `test/task_detail_followup_flow_test.dart` test “inline description edit updates updatedAt and preserves completion and Follow-up history” passed in Build shard test-1 on initial SHA; per-record completedAt semantics remain absent. |
| A6 explicit Follow-up-to-Task conversion is stable/idempotent | NOT VERIFIED | No verified conversion contract was established in inspected paths. | No matching named acceptance test/evidence located. |
| A7 Task completion suppresses future notifications and preserves history | IMPLEMENTED BUT NOT VERIFIED | `lib/models/task.dart` has setCompleted; `lib/services/task_store.dart` persists Task and Follow-up history. | `test/task_store_test.dart` has completion/history tests; full notification suppression path not independently proven by this run. |
| B1 Quick Capture has no Checklist or legacy flags | NOT VERIFIED | `lib/main.dart`, Quick Capture dialog implementation not fully audited in this pass. | Device Smoke `smoke-quick-capture` PASS on run `41274996175`; no evidence in that lane for every prohibited field/Checklist rule. |
| B2 Full Task form supports multiple independent Reminders | IMPLEMENTED BUT NOT VERIFIED | `lib/models/task.dart` has `taskReminders`; Reminder data is separate from dueDate. | `test/task_store_test.dart`; no current exact-head per-reminder edit/delete proof reviewed. |
| B3 relative reminder requires real time; all-day 00:00 is not a time reference | PARTIALLY IMPLEMENTED | `lib/calendar_page.dart` has all-day-aware presentation; full scheduling/alarm path not verified. | No complete date/time edge-case evidence reviewed. |
| B4 Checklist only in Task Details; Add/Edit/Delete preserves data | IMPLEMENTED + VERIFIED | `lib/task_detail_page.dart`; Task Details owns checklist operations. | `test/task_detail_checklist_crud_test.dart`, test “checklist add, inline edit and delete preserve legacy follow-up timestamps”, passed in Build run `41274996134`, shard test-2, initial SHA. The test preserves legacy fields, so it does not validate the new purge rule. |
| B5 Follow-up form offers optional normal Reminder shortcut | IMPLEMENTED BUT NOT VERIFIED | `lib/follow_up_entry_page.dart` now offers an optional “افزودن یادآور” switch and Jalali date + Universal Arvin Time Picker controls; `TaskStore.addTaskReminder` writes a normal TaskReminder linked by Task ID. New Follow-up JSON omits null legacy scheduling keys. | `test/follow_up_entry_page_test.dart` now covers enabled/disabled shortcut and independent Reminder persistence; exact-head Build validation pending. |
| B6 New Follow-up defaults to now and uses Universal Arvin Time Picker | IMPLEMENTED BUT NOT VERIFIED | `lib/follow_up_entry_page.dart` exposes date/time controls; exact universal picker integration and default behavior not fully proven. | No current target-SHA dedicated picker acceptance result reviewed. |
| C1 record-driven report filters genuine Follow-up records by completedAt | IMPLEMENTED BUT NOT VERIFIED | `lib/services/completed_follow_up_report_projection.dart` projects only `Task.followUps`, uses `FollowUp.completedAt` (compatibility alias of persisted `dateTime`), and never reads Task completion/due/reminder dates. SQL `follow_ups.date_time` remains the persisted canonical history timestamp. | `test/services/completed_follow_up_report_projection_test.dart` covers half-open day boundaries, multiple same-day records, aggregation by Task ID, and exclusion of tasks without history; exact-head CI pending. |
| C2 Follow-up report in Report Center opens on today | IMPLEMENTED BUT NOT VERIFIED | `lib/report_center_page.dart` opens `CompletedFollowUpReportDialog` on the app-local current day. | `test/completed_follow_up_report_page_test.dart`; exact-head CI pending. |
| C3 Jalali date picker and half-open local day interval | IMPLEMENTED BUT NOT VERIFIED | `lib/services/completed_task_report_projection.dart` uses local start-of-day and next local day (not fixed 24h). | No test evidence for daylight/timezone boundaries or Follow-up completedAt filtering. |
| C4 previous/next/Today, summary, two sorting/grouping modes | IMPLEMENTED BUT NOT VERIFIED | `CompletedFollowUpReportDialog` includes previous/next/Today, Jalali date picker, Persian-digit summary, chronological ascending mode and Task-ID grouping mode. | `test/completed_follow_up_report_page_test.dart`; exact-head CI pending. |
| C5 row fields, stable taskId navigation and history sorting | IMPLEMENTED BUT NOT VERIFIED | Follow-up report rows show actual completion time, Task title, note/result, related people where available and navigate to `TaskDetailPage` using the owning Task object/ID. Chronological sort is ascending by completedAt; grouped mode groups by Task ID. | `test/completed_follow_up_report_page_test.dart` and `test/services/completed_follow_up_report_projection_test.dart`; exact-head CI pending. |
| C6 history retained for open/completed/archived Tasks; exclude reminders/due dates; no notifications | NOT VERIFIED | `lib/services/person_follow_up_report_projection.dart` excludes archived/completed tasks in waiting-only mode and exposes legacy reminder/nextFollowUp projections. | No acceptance evidence for the complete report inclusion/exclusion contract. |
| C7 exact empty/error states and stale-query protection | IMPLEMENTED BUT NOT VERIFIED | Report uses the exact requested empty/error strings. Projection is synchronous over the current in-memory Task snapshot, so rapid day/mode changes cannot complete out of order. | `test/completed_follow_up_report_page_test.dart`; exact-head CI pending. |
| D1 Home has exactly six fixed sections and completed collapsed at bottom | NOT VERIFIED | `lib/main.dart` is the Home composition source; full six-section order/collapse behavior not established in this pass. | `integration_test/android_home_smoke_test.dart` covers boot/navigation, not the full six-section contract. |
| D2 Home shows only nearest future Reminder per Task | NOT VERIFIED | Reminder projection exists in app source; exact Home summary selection was not established. | No named test/evidence reviewed. |
| D3 all-day ordering and distinct date filters | PARTIALLY IMPLEMENTED | Calendar item has isAllDay; `lib/calendar_page.dart` contains all-day-aware time/presentation branches. Home/filter behavior not fully verified. | No complete ordering/filter boundary test reviewed. |
| D4 Calendar labels/icons/prayer/reminder visual rules | IMPLEMENTED BUT NOT VERIFIED | `lib/calendar_page.dart` has distinct visual-kind classification including prayer, Arvin Reminder and Follow-up. Exact icon/text polish not visually accepted. | Calendar emulator run was cancelled; no screenshot artifact for Calendar lane. |
| E1 independent Local Arvin Calendar and explicit Device Calendar | IMPLEMENTED BUT NOT VERIFIED | `lib/calendar_page.dart`, `lib/main.dart`, Calendar integration services. | Calendar Provider Acceptance run `41274996200` SUCCESS on initial SHA; physical-device acceptance absent. |
| E2 at most five recurrence preview occurrences | NOT VERIFIED | Recurrence/calendar preview implementation not fully inspected in this pass. | No named test/run evidence reviewed. |
| E3 device sync idempotent, isolated, failure-safe | IMPLEMENTED BUT NOT VERIFIED | Calendar Provider workflow performs real Provider acceptance; Calendar card actions include sync. | Run `41274996200` SUCCESS and artifact `13070688563`; artifact contents not yet independently reviewed. |
| E4 all-day never becomes timed 00:00 | PARTIALLY IMPLEMENTED | `lib/calendar_page.dart` distinguishes isAllDay and avoids showing a time chip for all-day items; provider sync contract remains to be reviewed. | No complete exact-head all-day Provider evidence reviewed. |
| E5 changes in one calendar path do not mutate the other | NOT VERIFIED | Separate Calendar integration path exists; no full failure-isolation proof reviewed. | No current target-SHA fault-injection test evidence. |
| F1 Task left/right settings are independent dropdowns | IMPLEMENTED BUT NOT VERIFIED | `lib/settings_page.dart` exposes separate `swipe-right-action` and `swipe-left-action` controls. | `test/settings_page_test.dart` and `test/services/app_settings_service_test.dart` passed on SHA `69d5ff315b0bdcb4e2e6f9db54132baabafcf504`; latest documentation-synchronized HEAD still requires fresh CI. |
| F2 Task options include configurable “ثبت پیگیری” | IMPLEMENTED BUT NOT VERIFIED | `lib/settings_page.dart` now includes `TaskSwipeAction.convertToFollowUp` in both independent dropdowns and labels it “ثبت پیگیری”. | `test/settings_page_test.dart` and `test/g6_swipe_rtl_acceptance_test.dart` passed on SHA `69d5ff315b0bdcb4e2e6f9db54132baabafcf504`; latest documentation-synchronized HEAD still requires fresh CI. |
| F3 selecting “ثبت پیگیری” opens form only | IMPLEMENTED BUT NOT VERIFIED | `lib/main.dart` now opens `FollowUpEntryPage`; it writes through `_addFollowUpFromDetail` only after a non-null saved result and returns false so the Task stays in the list. | `test/g6_swipe_rtl_acceptance_test.dart` now checks both directions, no write before Save, and persistence after Save; current-head CI is pending. |
| F4 Calendar left/right settings independent of Task swipes | IMPLEMENTED BUT NOT VERIFIED | `lib/settings_page.dart` uses separate `CalendarSwipeSettingsService`; `lib/calendar_page.dart` receives separate calendar actions. | No current exact-head independent-execution test reviewed. |
| F5 Calendar options Edit/Delete/Transfer-to-device | PARTIALLY IMPLEMENTED | CalendarSwipeAction enum has edit/trash/sync/none; `lib/calendar_page.dart` dispatches actions. Sync callback is restricted to canonical Task records. | No complete swipe action matrix test/evidence reviewed. |
| G1 soft delete moves to recoverable Trash | IMPLEMENTED BUT NOT VERIFIED | Task model has trashed; Settings offers Trash; app has Trash state. | No current exact-head restore test evidence reviewed. |
| G2 hard delete policy and independent history preservation | BLOCKED | No clear product lifecycle decision for hard deletion of Task vs independent Reminder/Follow-up history was established. | No destructive behavior changed; decision required before implementing cascade/purge. |
| H1 recurrence pattern/occurrence snapshots and idempotency | PARTIALLY IMPLEMENTED | `lib/models/task.dart` includes recurrence, checklistOccurrences and occurrenceHistory. | No complete duplicate-occurrence/history test evidence reviewed. |
| H2 only real backend filters; distinct Task/Reminder/Follow-up dates | PARTIALLY IMPLEMENTED | `lib/report_center_page.dart` includes hasFollowUp filter; current projection includes legacy Next Follow-up properties. | Query contract tests not reviewed. |
| H3 Backup/Restore preserves relationships/history and cannot revive Next Follow-up | PARTIALLY IMPLEMENTED | Backup/Restore smoke lane uses SQL lifecycle; legacy fields remain serialized in Task/FollowUp model. | `smoke-task-lifecycle` PASS in run `41274996175`; prohibited legacy-field purge/restore behavior is not satisfied. |
| H4 PDF embeds Vazirmatn and shapes Persian | NOT VERIFIED | `pubspec.yaml` registers Vazirmatn for Flutter; PDF package exists. PDF font embedding/shaping path not inspected or tested. | No PDF-specific font embedding/shaping test or artifact reviewed. |
| I1 Vazirmatn only, bundled in APK; System Default prohibited | PARTIALLY IMPLEMENTED | `pubspec.yaml` registers Regular/Medium/Bold; `lib/main.dart` applies Vazirmatn theme. | Build run `41274996134`: Debug/Release Font Packaging Audit PASS; Staging APK was not found so Staging font packaging NOT VERIFIED. |
| I2 all overlays/third-party surfaces, single theme source/render guard | NOT VERIFIED | Main theme source exists; global render guard/overlay coverage not proven. | No screenshot/font-leakage acceptance evidence reviewed. |
| I3 approved typography weights | NOT VERIFIED | Some explicit weights appear in Calendar and theme; complete role-to-weight audit not completed. | No typography contract test/visual acceptance reviewed. |
| I4 PDF font embedding/shaping and strict RTL/Persian digits | NOT VERIFIED | No PDF output artifact or RTL/Persian-digit comprehensive evidence reviewed. | No PDF shaping test or seven-lane screenshot review. |
| J1 Data Model release gate | NOT IMPLEMENTED | Active schema/model/store continue to read/write prohibited legacy fields. | Source inspection on initial SHA directly fails the gate. |
| J2 Task Swipe release gate | IMPLEMENTED BUT NOT VERIFIED | Both Task swipe dropdowns expose “ثبت پیگیری”; preference persistence and form-only action are implemented on this branch. | `test/settings_page_test.dart`, `test/services/app_settings_service_test.dart`, `test/g6_swipe_rtl_acceptance_test.dart`; exact-head CI pending. |
| J3 Calendar Swipe release gate | PARTIALLY IMPLEMENTED | Separate settings/actions exist; full independent action acceptance not proven. | No complete exact-head swipe matrix. |
| J4 Device Calendar Sync release gate | IMPLEMENTED BUT NOT VERIFIED | Calendar Provider Acceptance succeeded on initial SHA. | Run `41274996200`; physical-device sync proof and reviewed artifact details remain NOT VERIFIED. |
| J5 Typography + PDF release gate | PARTIALLY IMPLEMENTED | Staging run `41276902887` verified Vazirmatn Regular/Medium/Bold bundled and System Default/VazirHarf source references purged; APK_DEBUGGABLE=false. PDF embedding/shaping and production signing remain unproven. | Staging artifact `13072275072`, verification artifact `13071394992`; v2/v3 PASS with ephemeral test key only. |
| J6 required tests and seven Device Smoke lanes | PARTIALLY IMPLEMENTED | Build six shards passed; named Checklist CRUD and description-history tests were found in shard logs. | Run `41274996134` exact initial SHA. Device Smoke run `41274996175` did not complete: boot/navigation/quick-capture/task-lifecycle passed; calendar/reminder/follow-up lanes were cancelled. |
| J7 same-target-SHA proof for release | BLOCKED | Initial SHA has mixed evidence; subsequent workflow/doc commits change the target SHA and trigger fresh runs. | No single SHA has all required gates passed. |

## 5. Actual CI and runtime evidence

### Build — run 41274996134

Target branch: `fix/recovery-calendar-device-smoke-2026-10-31`; target SHA: `3b5721d67e461976748220bcaeb78376c25affe0`.

- Analyze: PASS (job `124755300440`).
- Test shards test-0 through test-5: PASS (jobs `124755300326`, `124755300332`, `124755300394`, `124755300382`, `124755300335`, `124755300413`).
- Checklist CRUD test “checklist add, inline edit and delete preserve legacy follow-up timestamps”: found in shard test-2 log and passed.
- Task description/history test “inline description edit updates updatedAt and preserves completion and Follow-up history”: found in shard test-1 log and passed.
- TaskStore test “TaskStore updates description without rewriting completedAt or historical Follow-ups”: found in shard test-5 log and passed.
- Debug APK: PASS; artifact `13071391543`.
- Release APK build/artifact: PASS at build level; artifact `13071391639`. This is not production-signature proof.
- Staging Gradle task: BUILD SUCCESSFUL; however the workflow looked at the wrong file path `android/app/build/outputs/apk/staging/app-staging.apk`. Log explicitly printed `APK_FILE=NOT_FOUND`; apksigner exit was NOT_RUN; v1/v2/v3, debuggable and manifest were NOT_VERIFIED/FAIL. Staging candidate artifact was not uploaded because that path did not exist. Verification artifact `13070643263` contains audit files only.

### Device Smoke — run 41274996175

Target SHA: `3b5721d67e461976748220bcaeb78376c25affe0`.

- PASS: `smoke-boot`, `smoke-navigation`, `smoke-quick-capture`, `smoke-task-lifecycle`.
- CANCELLED: `smoke-calendar-segmented-view`, `smoke-reminder-vazirmatn`, `smoke-follow-up-persistence`.
- Available artifacts: boot `13070783148`, quick capture `13070992114`, navigation `13071272143`, Persian time picker `13071067054`.
- Calendar log emitted: `CALENDAR_ROUTE_DIAG: navigation=1 calendarTitle=1 helpButton=1 segmentedControl=1`; therefore the weekly control was present in the observed emulator route at that point. Two seeded reminders were projected and the due-date item was also present. The emulator job was then cancelled; no Calendar screenshot was produced (`No files were found`). This is a cancellation, not proof that the assertion passed or failed. No root cause for the remaining long-running interaction is claimed.

### Calendar Provider Acceptance — run 41274996200

Target SHA: `3b5721d67e461976748220bcaeb78376c25affe0`; job `124755267335` SUCCESS; artifact `13070688563` downloaded and inspected. `result.txt` reports `RESULT=PASS_REAL_PROVIDER_CREATE_UPDATE_DELETE`; JUnit reports `provisionsExactlyOneWritableCalendarIdempotently` PASS; `crud-markers.txt` confirms CREATE, NO-OP UPDATE (same event ID, providerEventCount=1), no-duplicate check, UPDATE (same event ID), and DELETE. `sha-verification.txt` confirms checked-out SHA exactly matches target SHA. `test-output.txt` reports one instrumentation test passed. Limitation: `CALENDAR_PROVIDER_DESTINATION_MIGRATION=LIMITATION writableCalendars=1`; this run does not prove failure injection cannot damage internal Task/Reminder state, and does not replace physical-device acceptance.

### Fast Lane and file persistence

- Fast Lane contract run `41274996107`, job `124755266616`: SUCCESS.
- Follow-up file-backed SQLite persistence run `41274996125`, job `124755266847`: SUCCESS on the initial SHA. This run used a workflow cache/font label referencing VazirHarf; that is factory/test dependency metadata, not proof of the product font. Product font authority remains Vazirmatn.

## 6. Staging correction committed to the authorized branch

The inspected `android/build.gradle.kts` redirects the root Gradle build directory using `.dir("../../build")`. The module output is therefore under the repository-level `build/app/...`, not `android/app/build/...`.

- Updated `.github/workflows/build.yml` to use `build/app/outputs/apk/staging/app-staging.apk` for verification, font audit, manifest and upload paths (six path references).
- Added `test/build_staging_artifact_path_contract_test.dart` to assert that the workflow follows the configured repository-level Gradle build directory and rejects the incorrect path.
- Updated `docs/CHANGELOG-2026-10-30.md`.
- The path correction is a source-level diagnosis and patch, not a verification PASS. It must be confirmed by a new exact-head Build run that preserves the raw `apksigner verify --verbose` output, separate v2/v3 results, APK_DEBUGGABLE=false, APK size/SHA-256, Release Manifest and Staging artifacts.

### Task Swipe implementation added after the initial source audit

- Settings now exposes `ثبت پیگیری` for either Task-list swipe direction.
- The preference service no longer rewrites that selection to `none`.
- The swipe opens `FollowUpEntryPage`; no record is written merely by opening it. The saved result is persisted against the same Task only after explicit Save, and the Task card remains in the list.
- Regression coverage was updated in `test/g6_swipe_rtl_acceptance_test.dart` and `test/services/app_settings_service_test.dart`.
- This is source implementation, not an acceptance PASS. The new exact-head workflow must pass before these rows can be upgraded to IMPLEMENTED + VERIFIED.

### Follow-up Reminder shortcut and Completed Follow-ups Report implementation added after initial source audit

- Follow-up entry now has optional “افزودن یادآور”. It collects Jalali date and Universal Arvin Time Picker time, then writes a normal independent TaskReminder to the same persisted Task through TaskStore.addTaskReminder; the shortcut is only shown when a stable Task ID is available.
- New Follow-up records omit null reminderDate and nextFollowUp JSON keys. Existing legacy values are still preserved during edit and remain a schema/migration blocker; no data was discarded.
- FollowUp.completedAt is currently an explicit model getter alias of persisted FollowUp.dateTime. No new SQL timestamp column was introduced; a physical-column migration remains an open compatibility decision.
- Report Center now opens a daily record-driven report with Jalali day selection, previous/next/Today, Persian-digit count summary, ascending chronological mode, Task-ID grouping, note/result/person display, Task Details navigation, and exact empty/error states. The local-day interval is constructed as [start of day, start of next calendar day), not by adding 24 hours.
- New regression tests: test/follow_up_entry_page_test.dart, test/services/completed_follow_up_report_projection_test.dart, and test/completed_follow_up_report_page_test.dart.
- All these source changes remain IMPLEMENTED BUT NOT VERIFIED until a fresh exact-head Build run passes. The current legacy schema still contains tasks.follow_up_enabled, tasks.follow_up_date, follow_ups.reminder_date, and follow_ups.next_follow_up; no destructive migration was attempted because actual user database contents are unknown.

## 7. Database migration and data-safety blocker

The inspected schema is version 7. It currently defines:

- `tasks.follow_up_enabled`
- `tasks.follow_up_date`
- `follow_ups.reminder_date`
- `follow_ups.next_follow_up`

The Task model and TaskStore read/write these fields; `sql_task_migration_writer.dart` writes them as well. Legacy compatibility is currently active, not merely inert historical data.

**Unknown:** whether the real user database contains any rows or non-null legacy values. No live database file was read and no row counts were obtained. Therefore it is not established that the database is empty.

**Required safe next step:** before any destructive DDL, inspect the actual database and backup state; count rows and non-null legacy values; map each value to its canonical Reminder/history destination; create a verified backup; design an idempotent, data-preserving migration; test pre-migration and post-migration row counts, IDs, relationships, and restore behavior. A table rebuild/drop is blocked until that evidence exists. No migration has been attempted.

## 10. Latest execution checkpoint — SHA f079ebc and subsequent unvalidated source changes

### PR state and latest branch head
- PR #3052 remains OPEN / DRAFT on the authorized branch.
- Latest observed branch HEAD: 757fc281ae20751282fa79803c64f0c4c0fe6d6a.
- The latest source changes (Task Reminder shortcut, completed Follow-up report, regression tests and docs) were committed after SHA f079ebc. No Build or Device Smoke run associated with HEAD 757fc was visible at the latest live query; do not attribute f079ebc workflow results to this newer HEAD.

### Build run 41276902887 — target SHA f079ebc40c12fc87cc5cde1da82a4a27e7e1afb0
- Overall: FAILURE.
- Analyze: PASS (job 124760996328).
- Quality test shards: test-0 PASS (124760996392), test-1 PASS (124760996342), test-2 FAIL (124760996335), test-3 PASS (124760996431), test-4 PASS (124760996287), test-5 PASS (124760996344).
- Failed shard: 258 tests passed, 1 failed. Exact failure: test/settings_page_test.dart expected “ثبت پیگیری” not to exist; the new product requirement intentionally makes it available. Test expectation was corrected in commit 9b7d93f2fd5a584fd816648df6ece0bb475a042f; this correction has not yet been validated by a fresh Build run.
- APK Release job 124760996250: build/upload PASS; artifact 13072225265. APK bytes 69,959,353; SHA-256 7e53d84546957a01f5beaa0aef0c9af9f205fd02cac9341a6e5b4c6f75e0daaa.
- APK Staging job 124760996307: PASS; artifact 13072275072. The corrected repository-level Gradle output path resolved the missing-file error.
- Staging APK bytes 70,369,380; SHA-256 740466d8f3485484098f32d3ae419c184f0e8b03781805625cdf8bd2ffd1c56f. The APK was downloaded and its checksum independently recomputed from the artifact ZIP; it matches the manifest.
- Raw verification artifact 13071394992 was downloaded and inspected. apksigner exit code 0; v2 PASS; v3 PASS; v1 FAIL; APK_DEBUGGABLE=false PASS; Release Manifest validation PASS. The signer is an ephemeral test-only key and the manifest explicitly sets publishable=false. This is not production-signature evidence and the Staging APK is NOT RELEASABLE.
- Staging font audit: Vazirmatn Regular, Medium and Bold bundled; legacy VazirHarf/System Default source references purged. PDF shaping/embedding remains NOT VERIFIED.
### Device Smoke run 41276902849 — target SHA f079ebc40c12fc87cc5cde1da82a4a27e7e1afb0
| Lane | Job ID | Conclusion |
|---|---:|---|
| smoke-boot | 124760825227 | SUCCESS |
| smoke-navigation | 124760825131 | SUCCESS |
| smoke-quick-capture | 124760825349 | SUCCESS |
| smoke-calendar-segmented-view | 124760825238 | CANCELLED |
| smoke-task-lifecycle | 124760825259 | CANCELLED |
| smoke-reminder-vazirmatn | 124760825171 | CANCELLED |
| smoke-follow-up-persistence | 124760825197 | CANCELLED |

- The cancelled Calendar job log records CALENDAR_ROUTE_DIAG: navigation=1 calendarTitle=1 helpButton=1 segmentedControl=1, followed by a long-running VMServiceFlutterDriver request_data and workflow cancellation. No screenshot artifact was produced for the Calendar lane. The assertion was not removed or weakened.
- Device Smoke result is 3/7 PASS, 4/7 CANCELLED; it is not a successful matrix.

### Other workflows on SHA f079ebc
- Calendar Provider run 41276902959, job 124760802136: SUCCESS; artifact 13071579113. Exact SHA checkout verified in the job. The earlier reviewed Provider artifact proves CREATE, NO-OP UPDATE, duplicate prevention, UPDATE on same event ID and DELETE, with one writable destination-calendar limitation. It does not prove full failure-injection isolation.
- Follow-up file-backed SQLite run 41276903118, job 124760802705: SUCCESS; this was on SHA f079ebc before the later feature changes.

### Latest source changes after f079ebc
- Task Swipe Settings test expectation corrected.
- Follow-up form shortcut now writes a normal TaskReminder through TaskStore.addTaskReminder when a stable Task ID is available.
- FollowUp.completedAt getter aliases persisted dateTime; no physical SQL completed_at column for Follow-up was introduced.
- New daily Follow-up report and projection added; tests cover day boundaries, aggregation, exclusions, grouping and navigation.
- These source changes are IMPLEMENTED BUT NOT VERIFIED until exact latest-head Build and Device Smoke evidence is available.

## 11. Exact-head verification evidence — SHA 69d5ff315b0bdcb4e2e6f9db54132baabafcf504

### Build run 41278430414 (Build #8978)
- Exact checked-out target: 69d5ff315b0bdcb4e2e6f9db54132baabafcf504.
- Analyze job 124765324320 FAILED: unused import services/completed_task_report_projection.dart and unnecessary braces in the summary interpolation. Both were corrected in commit dd90f96.
- Test shards: test-0 PASS (195), test-1 FAIL (162 passed, 2 failed), test-2 PASS (260), test-3 PASS (125), test-4 PASS (206), test-5 PASS (153). Aggregate: 1,101 passed, 2 failed.
- The two test-1 failures were: completed_follow_up_report_page_test expected the no-history Task title not to exist anywhere, but it was present behind the modal on the underlying Report Center page; follow_up_office_page_test used find.byType(SwitchListTile) and became ambiguous after the new Add Reminder switch. The implementation was corrected with a stable key for the waiting-response switch and a scoped report assertion in commits 5a1a997, 4a026c3 and 7f686ed.
- Task Swipe evidence on this SHA: Settings UI option test PASS; left and right preference persistence tests PASS; RTL widget test “configured left and right swipes open Follow-up form and write only after save” PASS. These tests prove both directions and no automatic write before Save.
- Follow-up shortcut evidence on this SHA: tests “saving without the optional Reminder shortcut creates no Reminder” and “optional Reminder shortcut creates a normal Reminder for the same Task” PASS.
- Report projection tests for half-open day boundaries, multiple same-day records, stable Task ID aggregation and excluding tasks without Follow-up records PASS. Report UI empty-state test PASS; the main UI test had the underlying-page title false-positive described above and was corrected afterwards.

### Staging verification — exact SHA 69d5ff3
- Staging job 124765324360: SUCCESS. Artifact APK 13072471359; audit candidate 13072681043; verification bundle 13072286659.
- APK path: build/app/outputs/apk/staging/app-staging.apk.
- Size: 70,385,766 bytes. SHA-256: f2dfdb26141441151d33a19e085cb372d82dd652e9c9f7c7dc4250f5caa66180. APK bytes were extracted from the artifact ZIP and the checksum independently recomputed; it matches the manifest.
- apksigner exit code 0; v2 PASS; v3 PASS; v1 FAIL. APK_DEBUGGABLE=false PASS. Release Manifest validation PASS. Font packaging audit PASS.
- Signer class: EPHEMERAL_TEST_ONLY_NOT_PRODUCTION; publishable=false. The staging APK is not a production-signed release and must not be distributed.
- Release APK job 124765324219: build/upload SUCCESS, artifact 13071769369; this job skipped staging signature verification and does not prove production signing. Production-signature v2/v3 remains NOT VERIFIED.

### Device Smoke run 41278430425 — exact SHA 69d5ff3
| Lane | Job ID | Result |
|---|---:|---|
| smoke-boot | 124765483616 | PASS |
| smoke-navigation | 124765483599 | PASS |
| smoke-quick-capture | 124765483641 | CANCELLED |
| smoke-calendar-segmented-view | 124765483588 | CANCELLED |
| smoke-task-lifecycle | 124765483611 | CANCELLED |
| smoke-reminder-vazirmatn | 124765483655 | CANCELLED |
| smoke-follow-up-persistence | 124765483633 | CANCELLED |

- Boot screenshot artifact 13072176843 (home.png) and Navigation screenshot artifact 13072457400 (people.png) were downloaded and inspected.
- Quick Capture and Calendar lanes were still in progress when the next commit triggered concurrency cancellation; the remaining lanes were queued and cancelled. This is an incomplete 2/7 matrix, not a PASS.

### Calendar Provider and SQLite persistence — exact SHA 69d5ff3
- Calendar Provider run 41278430411, job 124765240759: SUCCESS; artifact 13071774374 reviewed. JUnit 1/1 passed; exact target SHA verified. Evidence confirms CREATE, NO-OP UPDATE with same event ID/no duplicate, UPDATE on same event ID and DELETE. Destination migration limitation: only one writable calendar. Failure-injection isolation from internal Task/Reminder data remains unproven.
- Follow-up file-backed SQLite run 41278430406, job 124765283133: SUCCESS; test “completion true -> false -> true survives closing and reopening the same SQLite file” passed on exact SHA 69d5ff3.

### Post-run corrective commits and new validation requirement
- Commit 7f686ed fixes the two test-1 assertions and Analyze findings. It also retains the new product implementation and stable waiting-response switch key.
- Audit/changelog synchronization and the F1/F2 matrix correction were committed afterwards; latest documentation-synchronized branch HEAD before this matrix correction is 59945086e4f67c36b3f71520294420528fa021a0. The next Build and all seven Device Smoke lanes must complete on the final post-documentation SHA. Evidence from SHA 69d5ff3 must not be attributed to later HEADs.

## 8. Open product decisions / blockers

1. **Historical data conversion:** decide how existing Task-level followUpDate and Follow-up-level reminderDate/nextFollowUp values are migrated. Future schedules must become normal Task Reminders, not Follow-up fields. Do not discard values or treat them as active schedules during transition.
2. **Follow-up timestamp authority:** approve a canonical per-record completedAt representation and migration from existing date_time values. Task.completedAt must remain a distinct Task completion timestamp.
3. **Hard delete lifecycle:** specify what happens to independent Follow-up history, Reminder rows, recurrence snapshots, and Calendar links when a Task is permanently deleted. Until approved, do not invent cascade behavior.
4. **Follow-up-to-Task conversion:** confirm whether this feature exists in the intended product. If retained, define stable relationship and idempotency; otherwise remove/disable it without affecting history.
5. **Calendar runtime cancellation:** the latest inspected emulator log shows the weekly control mounted, but the Calendar lane was cancelled before screenshot/assertion completion. Preserve logs and obtain a fresh bounded run before claiming a runtime fix.
6. **Physical-device acceptance:** CI emulator and Calendar Provider workflow do not establish real phone Calendar same-event update, permissions, recovery, or user-data restore acceptance.
7. **PDF acceptance:** identify the actual PDF renderer/font embedding path and provide a produced PDF with validated embedded Vazirmatn and Persian shaping evidence.

## 9. Required follow-up validation sequence

1. Re-read PR #3052 live head and confirm it remains OPEN/DRAFT; do not use stale SHA evidence.
2. Run the new Staging path-contract test and full Analyze/six test shards on the new exact SHA.
3. Complete Build Staging; retain raw apksigner log and artifact even if verification fails; report v1, v2, v3, APK_DEBUGGABLE=false, SHA-256, byte size and manifest independently.
4. Re-run Device Smoke on the exact new SHA and collect all seven lanes, job logs, screenshots and artifacts. Investigate the Calendar route wait/cancellation using the real emulator trace; do not remove or weaken assertions.
5. Verify Checklist CRUD, Follow-up text edit/history preservation, Reminder independence, backup/restore, recurrence, delete lifecycle, RTL/font and date-boundary tests on that same SHA.
6. Review Calendar Provider artifact contents and complete physical-device acceptance.
7. Complete safe legacy data migration only after database inspection and an approved conversion map.
8. Update this matrix with exact paths, test names, run/job IDs, SHA and artifact references. No gate passes on partial evidence.
9. Keep Issues #823 and #2102 OPEN, PR #3052 OPEN/DRAFT, and release NO-GO until all required gates pass on one candidate SHA and the product owner explicitly accepts it.

## 10. Final audit decision

**Current decision: BLOCKED — RELEASE: NO-GO.**

Confirmed remaining gaps include active legacy followUpEnabled/nextFollowUp schema/model fields and the absence of a data-preserving physical-column migration. Task Swipe, Follow-up Reminder shortcut and daily Follow-up report implementations have been added. On SHA 69d5ff3, all six test shards ran: five passed (939 tests) and test-1 failed (162 passed, 2 failed); Analyze failed on one unused import and one unnecessary interpolation brace. The Staging APK passed v2/v3, APK_DEBUGGABLE=false and Release Manifest checks using an ephemeral test-only key, and is explicitly not publishable. Device Smoke run 41278430425 was superseded before completion: boot/navigation passed, five lanes were cancelled; Calendar and Quick Capture were still running when the next commit cancelled the matrix. Calendar Provider and SQLite persistence passed on SHA 69d5ff3. Code/test corrections were committed in 7f686ed; a new exact-head Build and Device Smoke are required.

No merge, release, publish, main-branch edit, issue closure, NIRA change, or destructive database migration was performed.


## 11. High-priority directive intake — Alarm Snooze / Follow-up Capture / Widget Acceptance

**Intake date:** 2026-11-01  
**Requested scope:** Alarm overlay with active Task title and Reminder time; red `توقف آلارم` action that terminates active audio; snooze increment/decrement and minute-stepper controls; `ثبت سابقه` writing a historical FollowUp against the same parent Task; Vazirmatn across every overlay text; widget tests for stop/snooze/logging; SQLite persistence proof; exact-head evidence update.

### Source facts established during intake
- `pubspec.yaml` defines the Vazirmatn family with Regular 400, Medium 500 and Bold 700.
- `FollowUp.completedAt` in `lib/models/task.dart` is currently a getter alias of `dateTime`. The inspected model does not establish a distinct persisted `completed_at` SQL column.
- FollowUp JSON currently persists `dateTime`; the existing contract treats that as the canonical historical timestamp. Do not introduce a competing timestamp or perform a destructive migration without an approved data-preserving migration plan.
- Existing independent future schedules belong to TaskReminder. Alarm snooze must update only the active Reminder record and must not create or modify FollowUp history.
- The current PR changed-file inventory does not yet show a dedicated alarm/snooze overlay implementation or dedicated alarm widget tests.

### Governance and implementation status
- Governing Issue #823 currently freezes scope to release blockers and explicitly defers new features. The new alarm/widget scope is therefore **SCOPE CONFLICT — OWNER/GOVERNANCE RECONCILIATION REQUIRED** before it can be treated as accepted scope.
- PR #3052 received a high-priority intake comment (GitHub comment ID `6554182142`) recording the requested behavior and the timestamp/governance constraints.
- **Implementation:** NOT VERIFIED / not yet evidenced by a source diff.
- **Widget tests:** NOT RUN / no evidence.
- **SQLite snooze-only mutation and FollowUp insertion:** NOT VERIFIED.
- **Vazirmatn overlay rendering:** NOT VERIFIED (font family declaration alone does not prove overlay inheritance).
- **Exact-head CI / device acceptance:** NOT RUN for this intake.
- **Release:** remains **BLOCKED — RELEASE: NO-GO**.

### Safe acceptance contract for the eventual implementation
1. Stop action terminates the currently playing alarm audio and is idempotent; it does not delete or rewrite the Reminder.
2. Snooze controls validate the minute step and update only the matching Reminder's next scheduled fire time. Other reminders, Task dueDate, FollowUp rows and Task history remain unchanged.
3. `ثبت سابقه` inserts exactly one new FollowUp with the same parent Task ID and the canonical historical timestamp (`dateTime`, exposed as `completedAt` by the current model). It must not alter any future Reminder or legacy scheduling values.
4. All overlay text inherits/enforces Vazirmatn, including dialogs, buttons, labels, controls and accessibility-visible text.
5. Widget tests cover stop-audio behavior, +/- and minute-stepper boundaries, duplicate-submit prevention, FollowUp insertion/linkage, and schedule immutability.
6. File-backed SQLite tests reopen the database and prove snooze persistence in Reminder only and exactly-one FollowUp insertion with unchanged future schedules.
7. Update this section with exact commit SHA, test names/results, workflow run/job IDs and artifact references only after those checks actually pass.

**Audit decision:** intake recorded; implementation and acceptance remain pending. Keep PR #3052 OPEN/DRAFT, Issues #823 and #2102 OPEN, and do not claim PASS or release readiness.


## 12. Binding product-owner directive — Alarm controls, Task completion, Snooze & Follow-up separation

**Pre-edit live PR HEAD:** `eb017f57ccd98f8bc43025aedd837fad2f79a2f6`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31` / PR #3052  
**Issue:** #823 OPEN  
**Release:** BLOCKED — RELEASE: NO-GO

### Scope conflict and reconciliation
Issue #823 previously stated “No new features” and froze work to release blockers. The product owner has now explicitly issued a mandatory, narrow scope override for this specific alarm interaction on PR #3052. The exception is limited to the four actions below and their acceptance tests; it does not authorize unrelated feature work, main changes, merging, APK publication, or release. The reconciliation was appended to Issue #823 before source edits. Issue remains OPEN.

### Binding action semantics
1. **توقف آلارم:** stop active audio only; preserve Task and Reminder; no Task completion and no Follow-up insert; preserve existing dismissal/notification lifecycle.
2. **Snooze:** selected duration is visible; confirm updates only the same Reminder's next alert through the existing lifecycle. No Task completion, due-date mutation, Follow-up insert, or unrelated/recurring Reminder mutation.
3. **انجام شد:** call the existing canonical Task-completion path. Persist and display completion after reload/database reopen; suppress notifications according to current policy; preserve Task/history/valid Reminders; no automatic Follow-up. Must be idempotent and retain existing reopen behavior.
4. **ثبت سابقه پیگیری (optional):** distinct explicit action; insert a real historical FollowUp linked to parent Task using the established historical timestamp; no future schedule data or Reminder mutation; note edits cannot change the timestamp.

### Initial source observations at the recorded HEAD
- `TaskReminder` in `lib/models/task.dart` exposes id/title/date/isAllDay/sequence and recurrence-independent identity; no dedicated snooze field was observed in this model excerpt. A safe approach must reuse the existing Reminder date/lifecycle only if full scheduler inspection proves this preserves recurrence and notification identity.- `FollowUp.completedAt` is currently an alias of `dateTime`. The model excerpt still exposes legacy `reminderDate` and `nextFollowUp` members; the canonical baseline prohibits future scheduling on FollowUp. No schema changes are authorized merely to implement this screen.
- `lib/main.dart` applies Vazirmatn through app theme text themes; screen/dialog coverage still requires widget-level proof.
- `lib/services/task_store.dart` exposes `addFollowUp(taskId, followUp)` and `addTaskReminder(taskId, date)`; neither is proof of the canonical Task-completion path or safe snooze semantics.
- Alarm service, Task completion, recurrence, notification suppression and database reopen behavior remain under inspection. No source change has been made as part of this directive intake.

### Acceptance evidence status
- Stop audio / no side effects: **NOT VERIFIED**.
- Snooze display + same-Reminder persistence + recurrence isolation: **NOT VERIFIED**.
- Canonical Task completion + persisted UI state + notification suppression + idempotency: **NOT VERIFIED**.
- Explicit Follow-up separation + immutable historical timestamp: **NOT VERIFIED**.
- Full Vazirmatn overlay/dialog/accessibility rendering: **NOT VERIFIED**.
- Required widget / service / file-backed SQLite / device tests: **NOT RUN**.
- No PASS can be assigned until exact target SHA, actual run ID, and inspectable artifact are recorded.

**Governance:** keep PR #3052 OPEN/DRAFT, Issue #823 OPEN, and release BLOCKED — RELEASE: NO-GO. No main edit, merge, APK publication, destructive migration or Task/history deletion.


### Source inspection — concrete blockers at HEAD `b4ee274496331d79258e1cb701faff0f8ab0f001`
- The current reminder delivery path is a background runner calling `FollowUpReminderNotificationService.showDue()`, which calls `FlutterLocalNotificationsPlugin.show()`. It does not contain an in-app alarm audio player/controller, a notification-dismiss/cancel API, a notification-response callback, or a route that opens an alarm interaction screen. Therefore a red stop control cannot yet be wired to an existing active-audio lifecycle, and the requested overlay has no existing entry point. Do not invent a second alarm/audio engine as a silent workaround.
- The existing Android scheduler uses the fixed AlarmManager ID `42002`; preserve it. The displayed notification ID is derived from the candidate stable key. Any stop/snooze implementation must preserve these identities and dismissal/delivery-state semantics.
- `TaskReminder` has `id/title/date/isAllDay/sequence/isLegacyTaskReminder`; reminders are serialized in the Task JSON envelope stored in `tasks.legacy_payload_json`. There is no dedicated physical `task_reminders` SQL table in the inspected schema. The existing `TaskStore.mutate` transaction can preserve the same Reminder ID and update only its date logically, then reschedule; this must be proven with file-backed reopen tests and recurrence/other-reminder assertions before acceptance.
- Task recurrence is stored separately on Task. The current projection skips completed/archived/trashed Tasks and the background delivery service checks due Reminder timestamps. The canonical completion callback in `lib/main.dart` toggles via `Task.setCompleted`, persists through `TaskStore.save`, reschedules notifications and syncs the calendar. Reuse this path (including existing reopen toggle) rather than adding a second completion implementation.
- The physical `follow_ups` table still has legacy `reminder_date` and `next_follow_up` columns; new history inserts must leave them NULL. `FollowUp.completedAt` maps to the existing `dateTime/date_time` value. No schema migration is required for the optional history insert; editing the note while preserving dateTime still needs focused verification.
- App theme defines Vazirmatn globally, but no alarm overlay exists to inspect or test for inherited theme, dialog text, numerals, or accessibility labels.

**Execution decision:** no source code was changed because the repository has no existing alarm overlay/audio-stop lifecycle or notification-tap route to extend, and the requested visual reference image is not attached to this conversation. This is a concrete integration blocker, not a PASS. Safest next step is to add the alarm interaction through the existing notification lifecycle with an explicit, reviewed notification tap/action entry point and a single active-notification cancellation path; keep Task completion delegated to the existing canonical callback and snooze delegated to TaskStore mutation of the same Reminder ID. No physical schema migration is currently justified. Implementation and all runtime tests remain NOT VERIFIED.

## 13. Binding visual alarm widget directive — layout, typography and acceptance coordinates

**Intake date:** 2026-11-01  
**Recorded PR HEAD / CI target reviewed:** `eb017f57ccd98f8bc43025aedd837fad2f79a2f6`  
**PR:** #3052, authorized branch `fix/recovery-calendar-device-smoke-2026-10-31`  
**Governing Issue:** #823 OPEN  
**Release:** BLOCKED — RELEASE: NO-GO

### Visual element map (top-to-bottom order; screenshot pixel bounds not yet measurable)
1. **Top red action:** title `توقف آلارم`; subtitle `بستن صدای آلارم جاری`. Semantics: stop active alarm only; do not complete Task, mutate Reminder data or insert FollowUp.
2. **Task / Reminder block:** Task title; current Reminder time (reference example `۰۹:۵۴`); subtitle `زمان فعلی یادآور`. Time must be rendered with bundled Vazirmatn numerals.
3. **Audio control row:** `صدای آلارم` and `قابل تنظیم`, audio icon and slider. The slider is not accepted as functional until a real supported audio stream/controller exists and slider changes that stream. A decorative/fake slider is prohibited.
4. **Snooze block:** heading `مدت تعویق یادآور`; minus button; central pill `تعویق / ۱۰ دقیقه`; plus button. Confirming snooze may reschedule only the same Reminder ID and must preserve recurrence, dueDate, other Reminders, Task history and FollowUp records.
5. **Dark-blue primary action:** label is **`انجام شد`** and invokes the canonical parent-Task completion path. Product-owner clarification on Issue #823 governs: `ثبت سابقه` is not a synonym for Task completion. If the UI offers `ثبت سابقه پیگیری`, it is a separate optional explicit action that inserts one genuine historical FollowUp only after user confirmation.

### Typography and coordinate evidence
- Bundled `Vazirmatn` is mandatory for every visible string, numeral, slider label, button, dialog and accessibility label. System Default and unbundled fallback are prohibited.
- The supplied text identifies component order and exact strings but does not contain numeric pixel coordinates or dimensions.
- The named reference `photo_1793516357359.webp` was not present as a readable attachment in the current execution context. Exact screenshot matching, pixel positions, dimensions, margins and visual comparison are therefore **NOT VERIFIED**. Do not invent coordinates from the filename or textual description.

### Source / runtime findings and blockers
- Prior source inspection at the recorded intake HEAD found the notification/background delivery path but no in-app alarm audio controller/volume stream, stop action, notification-response/cold-start route or alarm overlay entry point.
- Consequently, the red stop action, real volume slider and overlay cannot yet be claimed implemented. Do not add a parallel audio engine or a nonfunctional visual control as a substitute.
- Existing Reminder persistence is in the Task JSON envelope; snooze must update the same Reminder through the established TaskStore/scheduler path and prove file-backed SQLite reopen plus unrelated/recurring Reminder isolation.
- Task completion must reuse the canonical existing completion callback. FollowUp remains independent historical data with the established timestamp; no future schedule fields or Reminder mutations.
- No source code was changed for this visual intake. No alarm widget test, audio-stop test, snooze test, Task completion test or screenshot acceptance was run for this directive.

### Exact-head CI context (not alarm-widget acceptance)
- Build run `41279261929` (#8984) on SHA `eb017f57ccd98f8bc43025aedd837fad2f79a2f6`: workflow conclusion SUCCESS. This is general Build evidence only; it does not prove the new alarm widget, audio slider, stop action, snooze or completion behavior.
- Calendar Provider run `41279261840` (#1153): SUCCESS on the same recorded SHA; unrelated to alarm widget acceptance.
- Device Smoke run `41279261863` (#6254): CANCELLED; it is not a device acceptance PASS.
- Follow-up File Persistence run `41279261786` (#176): SUCCESS, but it tests FollowUp completion persistence, not Task completion or alarm snooze. It is not evidence for this directive.
- No alarm-specific test run or inspectable screenshot artifact is available. All alarm-widget acceptance rows remain **NOT VERIFIED / NOT RUN**.

### Governance
The visual layout and semantics were recorded in Issue #823 and PR #3052 comments. Keep PR #3052 OPEN/DRAFT and Issue #823 OPEN. No main edit, merge, APK publication, destructive migration or release is authorized. Release remains **BLOCKED — RELEASE: NO-GO**.


## Product-owner correction — Follow-up shortcut semantics (2026-11-01)

This section supersedes the prior interpretation in §13 that assigned the dark-blue primary action to canonical Task completion. The latest product-owner directive explicitly clarifies that the button label **`ثبت سابقه`** is the existing Arvin shortcut to open the standard `FollowUpEntryPage` / task Follow-up form (`افزودن پیگیری کار`) for the current Task.

### Binding action contract
- **`ثبت سابقه`:** open the existing standard Follow-up form for the same Task ID. Opening/cancelling the form must not write a FollowUp, change Reminder schedules, or change Task completion.
- **Follow-up Save:** only the form's explicit Save action may persist the historical FollowUp through the existing repository/store path. Do not create a second or parallel Follow-up form or persistence implementation.
- **`توقف آلارم`:** dismiss/stop only the active alarm lifecycle; no Task completion, FollowUp insert or Reminder reschedule.
- **Snooze:** reschedule only the selected Reminder, preserving its ID, recurrence, other Reminder entries, dueDate, Task state and FollowUp history.
- **Task completion:** remains a separate canonical Task action and is not represented by the `ثبت سابقه` button. The alarm widget directive does not request auto-completion.
- **Audio volume:** a slider is accepted only if connected to a real supported alarm audio stream; a decorative slider or invented parallel audio engine is prohibited.

### Source evidence and limits
- The authorized branch contains `lib/follow_up_entry_page.dart` with the standard `FollowUpEntryPage` form, including explicit save control `follow-up-entry-save`; this is the existing form to reuse.
- Source inspection confirms the form implementation exists. The exact current alarm-widget caller/route wiring and exact Task ID handoff still require inspection before claiming the shortcut is integrated in the new widget.
- No source code or runtime tests were changed/run for this correction. SQLite isolation for opening/cancelling/saving Follow-up from the alarm widget remains NOT VERIFIED.
- The named screenshot `photo_1793516357359.webp` remains unavailable in the execution context; numeric pixel coordinates and screenshot matching remain NOT VERIFIED.
- Bundled Vazirmatn remains mandatory for all widget/form labels, numerals, dialogs and accessibility labels.

### Governance
This latest product-owner clarification supersedes the earlier §13 button-label interpretation. It is not a request to add a new Follow-up concept: reuse the existing Arvin form and explicit-save behavior. PR #3052 remains the only authorized implementation lane; Issue #823 stays OPEN; release remains **BLOCKED — RELEASE: NO-GO**.


## Alarm overlay execution checkpoint — 2026-11-01 (PR #3052)

### Live governance and target
- Live PR #3052: OPEN, DRAFT, not merged; head branch `fix/recovery-calendar-device-smoke-2026-10-31`; exact head SHA `47609116cf02e0f2c712a70a4448a93a1b0e0169`.
- Governing Issue #823: OPEN.
- Release decision remains **BLOCKED — RELEASE: NO-GO**.
- No changes were made to `main`; no merge or APK publication was attempted.

### Source inspection — integration blocker confirmed
Inspected the exact-head source for:
- `lib/automatic_follow_up_notification_service.dart`
- `lib/automatic_follow_up_background_runner.dart`
- `lib/follow_up_reminder_notification_service.dart`
- `lib/models/task.dart`
- `lib/services/task_store.dart`
- `lib/follow_up_entry_page.dart`
- `lib/theme/app_fonts.dart` and `lib/theme/font_registry.dart`

Findings:
1. The notification services currently expose delivery methods (`showDue`) and post high-priority notifications with Task ID payloads. The inspected service code does not expose an active alarm audio controller, stop/dismiss action API, notification-response callback, or overlay launch route. A true in-app alarm overlay and immediate ringtone-stop action therefore have no verified integration entry point in this exact-head source. Do not simulate these controls or claim they work.
2. `TaskReminder` is a canonical model serialized in the Task payload; its `copyWith` preserves reminder ID, sequence and legacy identity. `TaskStore.mutate` is the existing persistence boundary. However, a safe snooze implementation still needs the active Reminder identity, established rescheduling lifecycle, recurrence semantics and file-backed SQLite close/reopen tests. No snooze write was made.
3. The standard `FollowUpEntryPage` exists and accepts `taskId`; its explicit save action is `follow-up-entry-save`. The inspected page persists through its existing callback/store integration, but the alarm notification currently carries only a Task ID and no verified overlay caller/route exists. Correct task context handoff from an active ringing reminder is therefore NOT VERIFIED. Do not create a parallel form or persistence model.
4. `AppFonts.vazirmatnFamily` and the font registry identify bundled `Vazirmatn` as the app font. This confirms the canonical family declaration only; it does not prove every future overlay label, digit, slider, dialog and accessibility label is rendered with it.
5. The currently inspected notification service does not provide a volume stream/controller. A slider cannot be truthfully implemented as functional until the platform's supported alarm audio stream and its ownership/lifecycle are identified.

### Acceptance status
- Overlay hierarchy and exact visual match to `photo_1793516357359.webp`: NOT VERIFIED (reference image bytes were not available for inspection in this execution context).
- Stop active ringtone without Task/Reminder/FollowUp mutation: BLOCKED / NOT IMPLEMENTED.
- Active Task title and Reminder time binding: NOT VERIFIED.
- Functional alarm volume slider: BLOCKED / NO VERIFIED AUDIO CONTROLLER.
- Snooze same Reminder with stable ID, recurrence and unrelated-data isolation: NOT VERIFIED / NOT RUN.
- `ثبت سابقه` launching existing FollowUpEntryPage for the active Task, with explicit-save-only insertion: PARTIAL SOURCE AVAILABILITY; alarm caller and Task ID handoff NOT VERIFIED.
- File-backed SQLite close/reopen isolation tests for stop, snooze and FollowUp shortcut: NOT RUN.
- Alarm overlay widget/device screenshot tests: NOT RUN.
- No alarm-specific PASS is claimed.

### Exact-head CI context (not alarm acceptance)
At SHA `47609116cf02e0f2c712a70a4448a93a1b0e0169`:
- Build #8991 / run `41283480262`: IN PROGRESS at checkpoint.
- Device Smoke #6258 / run `41283480258`: QUEUED.
- Follow-up File Persistence #180 / run `41283480264`: SUCCESS; this is not evidence for alarm stop, snooze, or alarm-launched FollowUp.
- Calendar Provider #1157 / run `41283480278`: IN PROGRESS; unrelated to alarm acceptance.
- Production Loop #21729 / run `41283480271`: SUCCESS; unrelated to alarm acceptance.

### Decision and next safe action
Execution is **BLOCKED at integration discovery**, not accepted. Do not add a fake audio engine, decorative slider, synthetic notification lifecycle, parallel FollowUp form, or speculative migration. The next implementation step requires a verified platform alarm/audio lifecycle and notification-response/overlay entry point, then a Task ID + active Reminder ID handoff contract. Only after that should the stop/snooze/shortcut behavior and file-backed SQLite/widget/device tests be implemented on this authorized branch. Keep PR #3052 OPEN/DRAFT, Issue #823 OPEN, and release **BLOCKED — RELEASE: NO-GO**.


---

## Unified product + Alarm Widget audit — 2026-11-01 (live exact-head checkpoint)

> This checkpoint supersedes earlier CI status snapshots and any earlier interpretation of the alarm shortcut as Task completion. It records the latest live evidence at the exact SHA below. It does not claim release acceptance.

### A. Governance and immutable target

- Repository: `mobinpda-lab/Arvin-clean`
- Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- PR #3052: **OPEN / DRAFT / unmerged**
- Issue #823: **OPEN**
- Issue #2102: **OPEN**
- Issue #1139: historical context only; not used as an execution authority.
- Reported SHA comparison: supplied `2ce4d2fa7a73d89dbde92ea704e9e1e318528e7f` equals live branch HEAD and PR head.
- Exact target SHA for all CI rows below: `2ce4d2fa7a73d89dbde92ea704e9e1e318528e7f`.
- Release decision: **BLOCKED — RELEASE: NO-GO**.
- No source implementation was added in this checkpoint. Only this audit ledger and the PR evidence comment are updated. No main edit, merge, APK publication, destructive migration, or issue closure.

### B. Path A — whole-product acceptance matrix

All listed run IDs were re-fetched from GitHub. Each run's `head_sha` is exactly `2ce4d2fa7a73d89dbde92ea704e9e1e318528e7f`.

| Gate | Result at checkpoint | Run / Job evidence | Artifact / limitation |
|---|---|---|---|
| Build Analyze | **PASS — scoped static analysis** | Run `41283768533`; job `124781001944`; exact-checkout step SUCCESS; Analyze SUCCESS; log: `No issues found! (ran in 17.8s)` | No APK artifact from this job. |
| Build test shards | **PASS — 6/6 shards** | Run `41283768533`; jobs: test-0 `124781001943` (195 tests), test-1 `124781002056` (164), test-2 `124781001970` (260), test-3 `124781001868` (125), test-4 `124781001931` (206), test-5 `124781002077` (153). Each exact-checkout step and Test step SUCCESS; aggregate **1,103 tests passed**. | Job logs are the evidence. This is general Flutter test coverage, not proof of Alarm Widget behavior. |
| Overall Build / APK variants | **PENDING** | Run `41283768533`; staging job `124781001760`, debug job `124781001884`, release job `124781002229` were all IN_PROGRESS at last refresh. | No artifacts returned. APK byte size, checksum, debuggable state, signer identity and final manifest not yet inspectable. |
| Staging signature / manifest / font packaging audit | **PENDING** | Run `41283768533`; staging job `124781001760`. Workflow includes apksigner v1/v2/v3, debuggable check, SHA-256/size manifest and Vazirmatn packaging/source audit steps, but job had not reached final result. | Staging workflow generates an ephemeral test-only key. Even a successful staging signature is not production-publishable signing evidence. No manifest artifact currently available. |
| Device Smoke matrix | **PENDING — 0/7 lanes accepted** | Run `41283768541`; matrix preparation job `124780948562` SUCCESS. Lanes: boot `124780961747` IN_PROGRESS; navigation `124780961625` IN_PROGRESS; quick-capture `124780961597` QUEUED; task-lifecycle `124780961620` QUEUED; reminder-vazirmatn `124780961623` QUEUED; calendar-segmented-view `124780961664` QUEUED; follow-up-persistence `124780961992` QUEUED. | No artifacts returned at refresh. Matrix setup success is not lane acceptance. Reminder/Vazirmatn lane reuses `integration_test/calendar_card_interaction_test.dart`; it is not an Alarm Overlay test. |
| Follow-up file-backed SQLite persistence | **PASS — narrow repository scenario only** | Run `41283768600`; job `124780807362`; exact-checkout and test steps SUCCESS; log: one test passed. | `test/follow_up_repository_file_persistence_test.dart`. It verifies Task completion true→false→true across closing/reopening the same SQLite file while preserving two historical FollowUps, two TaskReminders, dueDate and related Task data. It does **not** test FollowUp creation from Alarm Overlay, snooze writes, notification stop, or audio. No artifact returned. |
| Calendar Provider | **PENDING** | Run `41283768538`; job `124780807054` IN_PROGRESS. | Job log/artifact not yet available at refresh. Calendar Provider acceptance remains pending. |
| Production Loop | **PASS — automation-only, not a release gate** | Run `41283768606`; job `124780807413` SUCCESS; feedback-loop job `124780808172` SKIPPED. | No artifact. This does not establish Build, Device Smoke, Calendar Provider, APK signing or release readiness. |

#### Additional whole-product gates

- Database/schema migration: **NOT VERIFIED as a complete release gate**. The passing general test shard includes migration-related unit coverage, but no evidence here establishes backup/recovery against real user data, upgrade-path compatibility across supported schema versions, or destructive-migration safety.
- Calendar behavior: **PENDING** under Calendar Provider and Device Smoke; do not infer acceptance from unit tests alone.
- PDF generation and Persian shaping: **NOT VERIFIED** for end-to-end/device output at this checkpoint.
- Archive/restore states, last-FollowUp office projection and deletion lifecycle: **NOT VERIFIED** as complete product acceptance gates.
- Staging and release APK: **PENDING**; no inspectable APK, checksum, size, signer certificate, debuggable result or manifest artifact was returned.
- Production signing: **NOT RUN / NOT VERIFIED**. The production-signing workflow is a separate protected-default-branch workflow and does not accept arbitrary PR-head signing as production evidence.

### C. Path B — Alarm Widget & Follow-up Shortcut matrix

Source inspected at exact SHA `2ce4d2fa7a73d89dbde92ea704e9e1e318528e7f`:

- `lib/automatic_follow_up_notification_service.dart`
- `lib/automatic_follow_up_background_runner.dart`
- `lib/follow_up_reminder_notification_service.dart`
- `lib/follow_up_reminder_background_runner.dart`
- `lib/android_follow_up_reminder_scheduler.dart`
- `lib/services/follow_up_reminder_projection.dart`
- `lib/services/follow_up_reminder_delivery_service.dart`
- `lib/follow_up_entry_page.dart`
- `lib/models/task.dart`
- `lib/services/task_store.dart`
- `lib/theme/app_fonts.dart`
- `lib/theme/font_registry.dart`
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`

| Control / invariant | Result | SHA / Run / Job | Evidence and limitation |
|---|---|---|---|
| Real alarm delivery lifecycle | **PARTIAL SOURCE EVIDENCE; overlay lifecycle NOT VERIFIED** | SHA above; no Alarm-specific Run/Job | Existing Android scheduler `followUpReminderAlarmId = 42002` schedules a background callback. The callback runs the reminder delivery runner. The notification service calls local-notifications `show()` on a high-importance channel. This is not evidence of a full-screen ringing overlay or an audio-player lifecycle. |
| Stop active ringtone only | **BLOCKED** | SHA above; no Alarm-specific Run/Job | No active audio controller, explicit stop/cancel action, notification response callback, or overlay route was found in the inspected delivery path. Do not present a red decorative button as functional. |
| Task + exact Reminder identity | **NOT VERIFIED / current handoff insufficient** | SHA above; no Alarm-specific Run/Job | The reminder projection has `taskId` and `taskReminderId`; the notification payload currently contains only `candidate.taskId`. The notification response path does not currently demonstrate preservation/recovery of the active Reminder ID for snooze or action routing. |
| Notification/Alarm ID interpretation | **VERIFIED SOURCE FACT** | SHA above | `42002` is the Android AlarmManager scheduler ID for the shared FollowUp/Task Reminder scheduling callback. It is not the active notification ID, ringtone ID, or an audio-controller handle. Individual notification IDs are separately derived from candidate stable identity. |
| Task title and reminder time in overlay | **NOT VERIFIED** | SHA above; no Alarm-specific Run/Job | No alarm overlay entry point was found. Candidate projection contains title/time data, but no rendered overlay binds and displays it. |
| Real volume control | **BLOCKED** | SHA above; no Alarm-specific Run/Job | No real alarm audio stream/controller or volume callback was found. No slider may be claimed functional. |
| Snooze same Reminder, preserving identity/recurrence | **NOT VERIFIED / NOT IMPLEMENTED** | SHA above; no Alarm-specific Run/Job | TaskReminder has stable ID/title/date/isAllDay/sequence and is serialized with Task data. No verified active-reminder response handler, snooze mutation, reschedule integration or file-backed snooze/reopen test exists in the inspected path. |
| `ثبت سابقه` opens existing form | **PARTIAL SOURCE AVAILABILITY; caller NOT VERIFIED** | SHA above; no Alarm-specific Run/Job | `FollowUpEntryPage(taskId: ...)` exists with explicit `follow-up-entry-save` and `onSaved` callback. No Alarm Overlay caller or exact active Task ID handoff is present in the inspected notification flow. |
| FollowUp form isolation | **NOT VERIFIED; integration constraint identified** | SHA above; no Alarm-specific Run/Job | Existing form has an optional `افزودن یادآور` switch; when enabled, its save path calls `TaskStore.addTaskReminder` and reschedules. An Alarm shortcut must reuse the same form but must ensure its shortcut mode cannot unintentionally change future Reminders. This isolation is not implemented or tested. |
| Explicit-save-only FollowUp insertion | **NOT VERIFIED from Alarm entry** | SHA above; no Alarm-specific Run/Job | The form constructs a FollowUp and returns it through `onSaved` / Navigator only after explicit save. No alarm caller/callback wiring or cancel/no-save database isolation test is present. |
| Task completion remains independent | **SOURCE CONTRACT PRESENT; Alarm isolation NOT VERIFIED** | SHA above; general persistence Run `41283768600`, job `124780807362` | Canonical `Task.setCompleted` exists separately. The persistence test covers completion toggling while preserving existing FollowUps and TaskReminders; it does not prove the Alarm Stop or Follow-up shortcut cannot invoke completion. |
| Vazirmatn assets and global theme | **PASS — source declaration only** | SHA above; Build Run `41283768533`; font packaging job `124781001760` still IN_PROGRESS | `pubspec.yaml` bundles Vazirmatn Regular/Medium/Bold; `AppFonts` and registry use only `Vazirmatn`; MaterialApp applies the family. This does not prove Overlay/Dialog/slider/accessibility rendering because no overlay exists. |
| Alarm UI/device/screenshot tests | **NOT RUN** | No Alarm-specific Run/Job | No overlay widget test, stop test, snooze test, alarm-launched FollowUp test, audio test or screenshot artifact exists in this checkpoint. |

#### Font-workflow discrepancy

The Follow-up File Persistence workflow (Run `41283768600`, job `124780807362`) restores a pinned legacy `VazirHarf` checkout under `assets/fonts/vazirharf`. The current product source and `pubspec.yaml` declare bundled `Vazirmatn`. The passing persistence test is not a font-rendering test and must not be used as Vazirmatn acceptance evidence. The Build staging job's dedicated font packaging/source audit is still pending.

#### Reference image availability

Neither `photo_1793512287397.webp` nor `photo_1793516357359.webp` was present among current conversation attachments or saved reference-image entries in this execution context. Their pixel layout, dimensions, spacing and screenshot comparison remain **NOT VERIFIED**. Do not invent coordinates or visual PASS claims.

### D. Execution decision and next safe actions

1. Keep the overall release decision **BLOCKED — RELEASE: NO-GO**.
2. Allow the current exact-SHA Build, Device Smoke and Calendar Provider runs to finish; then re-fetch run, job, log and artifact results before changing any PENDING row.
3. Do not treat the narrow Follow-up persistence test, Production Loop, or general test shards as Alarm acceptance.
4. Before Alarm implementation, define and verify the actual notification-response/overlay entry point and the active Task ID + Reminder ID contract. Confirm whether OS notification sound is the only sound source; do not invent a ringtone controller.
5. Reuse `FollowUpEntryPage`; add only the minimal shortcut-specific isolation needed so the alarm-origin form cannot mutate Reminder scheduling, while preserving explicit Save-only historical insertion.
6. Implement stop, snooze, volume, and overlay UI only against verified lifecycle APIs; then add file-backed SQLite close/reopen tests, widget tests, and device evidence for each independent behavior.
7. Inspect both reference images after they are made available to this execution context.
8. Keep PR #3052 OPEN/DRAFT; keep Issues #823 and #2102 OPEN. No main edits, merge, production signing, or release promotion.

**Path A status:** PARTIAL — general Analyze and six test shards PASS; overall Build, Device Smoke and Calendar Provider remain PENDING; staging/manifest/signature and several end-to-end product gates remain NOT VERIFIED.

**Path B status:** BLOCKED / NOT VERIFIED — canonical notification scheduling and FollowUp form components exist, but there is no verified active audio/overlay/action lifecycle or exact Reminder-ID response handoff; no Alarm-specific runtime acceptance exists.

**Overall release:** **BLOCKED — RELEASE: NO-GO**.


## 12. Alarm Overlay implementation dispatch — 2026-11-01

### Exact base checkpoint
- Authorized PR #3052 remained OPEN/DRAFT and unmerged.
- Base source SHA: `27297237721127b76f43945883b48a13d6f850a8`.
- Issue #823 and #2102 remained OPEN.
- Release remains `BLOCKED — RELEASE: NO-GO`.

### CI evidence on the base SHA
- Build #8993 / run `41284272776`: SUCCESS on exact SHA. Analyze job `124782340058` logged `No issues found!`; all six test shards passed: test-0 `124782339948` (195), test-1 `124782339981` (164), test-2 `124782340065` (260), test-3 `124782340115` (125), test-4 `124782340025` (206), test-5 `124782340060` (153), total 1,103 tests.
- Follow-up File Persistence run `41284272770`, job `124782280003`: SUCCESS; one file-backed SQLite test passed. This does not cover Alarm Stop/Snooze/Overlay Follow-up.
- Calendar Provider run `41284272831`, job `124782280111`: SUCCESS. Log proves CREATE, NO-OP UPDATE, no duplicate, UPDATE same event ID and DELETE. Limitation: only one writable destination calendar was available in the emulator.
- Device Smoke run `41284272771`: NOT FINAL at audit update. boot, navigation, task-lifecycle and quick-capture passed; reminder-vazirmatn and calendar-segmented-view were still running; follow-up-persistence remained queued. Do not claim 7/7.

### Alarm Overlay source changes in this dispatch
- Added a full-screen RTL Alarm Overlay using bundled `Vazirmatn`, loading Task title and the exact Reminder from canonical TaskStore using Task ID + Reminder ID.
- Notification payload now carries Task ID, Reminder ID, scheduled timestamp and the stable notification ID. Foreground notification tap and cold-start launch are routed to the overlay.
- Stop cancels only the active local notification ID. It does not mutate Task completion, Reminder data or Follow-up history. No independent audio player/volume stream exists; the displayed volume slider is informational and disabled. Notification cancellation is the verified stop boundary; separate audio playback control remains NOT IMPLEMENTED.
- Follow-up shortcut opens the existing `FollowUpEntryPage(taskId: ...)`; its optional future-Reminder control is disabled for this route. The page itself does not write a Follow-up; only a returned explicit Save result is appended to the canonical Task.
- Snooze mutates only the exact TaskReminder date in TaskStore, preserving its ID/title/sequence, then requests the existing scheduler to reschedule. The stepper uses a provisional 5-minute increment (bounded 5–120 minutes). All-day reminders do not expose timed Snooze.
- Added widget tests for Stop isolation, stable-identity Snooze, Follow-up shortcut no-write-on-open/cancel, and all-day Snooze guard.
- Visual parity with `photo_1793516357359.webp`: NOT VERIFIED; the reference image was not available in the current file/attachment context. This implementation is functional-first and does not claim pixel matching.

### Validation status
- The implementation in this dispatch is not yet validated on a new exact implementation SHA. Build, Device Smoke, widget tests and runtime notification-tap behavior must pass on the resulting commit before any Alarm Overlay acceptance status is upgraded.


### Implementation CI correction checkpoint
- Initial implementation commit: `4dd0fab5a1db77c9577263a714eee3e4662c70fe`; the first compile-failure run was triggered on follow-up SHA `a25ba1e02caee36ab63aaed1e2dd56efefd0a547`.
- Build run `41286726861` on that SHA reported Analyze FAIL in job `124789416497`. The exact diagnostics were: the Flutter Local Notifications v22 API requires `cancel(id: ...)`, not a positional argument; and `ThemeData.copyWith` does not accept `fontFamily`. Both compile-time issues were corrected in the follow-up patch.
- The correction also renders all-day Reminder timing as `تمام‌روز` rather than presenting midnight as a real time, and adds explicit Follow-up Save isolation coverage.
- The next commit is the corrected implementation candidate. Its exact-head CI is the required validation; no implementation PASS is claimed from the failed first attempt.


### Follow-up compile correction
- The API/analyzer findings from Build run `41286726861` are corrected in this follow-up: notification cancellation uses the named `id:` parameter; theme font assignment is applied through the text theme; constructor parameters use initializing formals.
- All-day Reminder display now explicitly shows `تمام‌روز`, not midnight as a scheduled time. A corresponding widget assertion is included.
- This correction is not yet validated; exact-head CI for the next commit is pending.


### Current exact-head CI checkpoint — SHA `56f9bc5ca627915ce33f745ddae99604d138c145`
- Build #8993 implementation validation / run `41286915733`: Analyze PASS, job `124790119701`, log `No issues found!`.
- Passing test shards: test-1 job `124790119741` (165 tests), test-2 job `124790119643`, test-3 job `124790119685` (125 tests), test-4 job `124790119698`. Failed shards: test-0 job `124790119746` and test-5 job `124790119574`.
- Failure details: test-0's source-contract assertion still expected the old plain-text `payload: candidate.taskId` after the payload became structured JSON; test-5's all-day assertion used a broad text finder matching both the time label and the explanatory copy. These are test-contract/assertion failures, not current Analyzer errors.
- The assertions have been updated to validate the structured Task/Reminder/Notification ID payload and to inspect the keyed reminder-time Text only.
- Follow-up Persistence run `41286915781`: SUCCESS on exact SHA `56f9bc5...`.
- Calendar Provider run `41286915757`: IN_PROGRESS at checkpoint.
- Device Smoke run `41286915804`: boot and navigation in progress; five other lanes queued. No 7/7 result.
- APK Debug/Release/Staging jobs in Build run `41286915733` were still in progress at checkpoint.
- These results do not upgrade Alarm Overlay acceptance. The next corrected commit requires fresh exact-head validation.


## 13. Exact-SHA verification — `53dfae1bbb92ad72de6c51514d5f38f77de3133c`

### Repository and governance snapshot
- Live branch HEAD and PR #3052 head matched `53dfae1bbb92ad72de6c51514d5f38f77de3133c`.
- PR #3052: OPEN / DRAFT / UNMERGED. Issues #823 and #2102: OPEN.
- Release remains `BLOCKED — RELEASE: NO-GO`.

### Build run `41287315440` — SUCCESS
All jobs completed successfully on the exact target SHA.
- Analyze: Job `124791202817`, PASS; log: `No issues found!`.
- Six test shards PASS:
  - test-0: Job `124791202698`, 196 tests.
  - test-1: Job `124791202768`, 165 tests.
  - test-2: Job `124791202567`, 261 tests.
  - test-3: Job `124791202853`, 125 tests.
  - test-4: Job `124791202836`, 207 tests.
  - test-5: Job `124791202833`, 154 tests.
  - Total: 1,108 tests PASS.
- APK assembly jobs PASS:
  - Debug: Job `124791202784`; artifact `13075657764`, 92,529,875 bytes (artifact ZIP size).
  - Release: Job `124791202839`; artifact `13076265451`, 32,444,630 bytes (artifact ZIP size).
  - Staging: Job `124791202773`; artifact `13076350444`, 32,846,782 bytes (artifact ZIP size).
  - Staging audit candidate: artifact `13075559730`.
  - Staging verification logs: artifact `13075863736`.
  - Artifact digests are recorded by GitHub Actions; they are ZIP digests, not the APK file's SHA-256.
- Font packaging audit logged `FONT_GATE=PASS_VAZIRMATN_BUNDLED_SYSTEM_DEFAULT_PURGED`, confirming Regular/Medium/Bold Vazirmatn assets are present in both Debug and Release APK contents.
- APK assembly is proven; production signing/v2-v3 verification and final release manifest are NOT proven by these job logs. Staging used an ephemeral signing key.

### Device Smoke run `41287315493` — INCOMPLETE
The run object remains `queued` while selected child jobs are executing.
- PASS: boot (Job `124791174504`), navigation (`124791174543`), quick-capture (`124791174527`).
- IN_PROGRESS: task-lifecycle (`124791174524`), calendar-segmented-view (`124791174477`).
- QUEUED: reminder-vazirmatn (`124791174513`), follow-up-persistence (`124791174487`).
- Current result: 3/7 completed PASS; 2 running; 2 queued; no failed lane reported yet. This is NOT 7/7 and cannot satisfy the release gate.
- Completed lane artifacts: boot `13075588012`, navigation `13075892991`, quick-capture `13076131548`; Persian time picker artifact `13076111691`. No artifact yet for the active/queued lanes.

### Calendar Provider run `41287315446` — SUCCESS
- Job `124791139542`: exact target SHA verification PASS.
- Real Provider CREATE, NO-OP UPDATE, no-duplicate assertion, UPDATE same event ID, and DELETE all PASS.
- Font gate also logged `FONT_GATE=PASS_VAZIRMATN_BUNDLED_SYSTEM_DEFAULT_PURGED`.
- Artifact `13076205955`, 11,216 bytes; ZIP digest `6c16459fabce95f75db5ffb4fd542b2e7030681545bd0029933965e28a960626`.
- Limitation: `writableCalendars=1`; destination-calendar migration across multiple writable calendars remains unverified.

### Follow-up Persistence run `41287315495` — SUCCESS
- Job `124791139721`; one file-backed SQLite test passed on the exact target SHA.
- No artifact was uploaded for this run.
- This is narrow persistence evidence, not full Alarm lifecycle/device acceptance.

### Visual reference and UI alignment checkpoint
- User identifies `photo_1793516357359.webp` and `photo_1793512287397.webp` as present in the active workspace. In this execution, Files returned no current-conversation file entries and no Library image entries matching either filename; the image binaries/pointers were therefore not available to inspect. Pixel-level comparison remains NOT VERIFIED; do not claim the references were inspected.
- Source review of `AlarmOverlayPage` found the Follow-up shortcut was positioned before Snooze/volume rather than at the bottom, and the volume row lacked a speaker icon. A corrective UI patch moves Follow-up to the bottom, adds a speaker icon beside the informational disabled slider, and sets the red Stop button to a prominent 64px height.
- Added a widget assertion for the visual hierarchy and control presence. This corrective patch is not part of SHA `53dfae1...`; its next exact-head CI must be used for acceptance.

### Current gate decision
- Build: PASS (6/6 shards; 1,108 tests) on SHA `53dfae1...`.
- Device Smoke: INCOMPLETE (3/7 PASS; 2 running; 2 queued).
- Calendar Provider: PASS with one-writable-calendar limitation.
- Follow-up Persistence: PASS (one test).
- Release: **BLOCKED — RELEASE: NO-GO**. The required 7/7 Device Smoke and 6/6 Build shards must both be GREEN on the final HEAD; production signing and release manifest also remain separate gates.


## 14. Exact-HEAD convergence checkpoint — SHA `612f9024621bae75c5bd63cec0164ee8421efe1f`

### Repository / governance
- Target branch: `fix/recovery-calendar-device-smoke-2026-10-31`; PR #3052.
- Exact-head CI runs: Build `41288270995`, Device Smoke `41288271013`, Calendar Provider `41288271011`, Follow-up File Persistence `41288271008`.
- PR #3052 remains OPEN; Issues #823 and #2102 were fetched OPEN in this checkpoint. Do not merge or promote release. Draft state is not exposed by the issue-fetch response and must be rechecked from the PR detail UI/API before claiming a fresh Draft verification.
- Overall release remains **BLOCKED — RELEASE: NO-GO**.

### Build run `41288270995` — FAILURE (exact target SHA)
- Analyze job `124793953540`: PASS; log: `No issues found! (ran in 18.7s)`.
- Test shards:
  - test-0 job `124793953578`: PASS, 196 tests.
  - test-1 job `124793953623`: PASS, 165 tests.
  - test-2 job `124793953591`: FAIL, 260 passed / 1 failed.
  - test-3 job `124793953588`: FAIL, 125 passed / 1 failed.
  - test-4 job `124793953636`: FAIL, 206 passed / 1 failed.
  - test-5 job `124793953592`: PASS, 154 tests.
  - Aggregate: 1,106 passed / 3 failed; 3/6 shards failed. This is not a Build PASS.
- AlarmOverlay widget evidence:
  - The Stop-isolation test passed in test-0: `stop dismisses only the notification and leaves Task data intact`.
  - Follow-up shortcut tests failed in test-2 and test-3 because finder key `alarm-overlay-follow-up` was not found when tapping.
  - Visual hierarchy test failed in test-4 for the same missing finder key while locating the bottom shortcut. Therefore the requested hierarchy is **NOT VERIFIED as guarded by a passing test** on this SHA; the new test currently fails and requires correction/diagnosis.
- APK assembly jobs:
  - Staging job `124793953379`: SUCCESS; artifact `13075957858` (`arvin-staging-apk`, ZIP 32,848,936 bytes); audit candidate `13075669114`; verification logs `13075209870`.
  - Debug job `124793953516`: SUCCESS; artifact `13076645569` (`arvin-debug-apk`, ZIP 92,519,755 bytes).
  - Release job `124793953571`: SUCCESS; artifact `13076536107` (`arvin-release-apk`, ZIP 32,448,245 bytes).
  - These are artifact ZIP sizes, not the APK file byte sizes. GitHub artifact ZIP digests: Debug `5f791f43b984c29f52dd9ba01e6a854c30d365b1c0f0b1d024ecebf3b258302e`; Release `aa273644592ee0f01e99da696ecb47a82451a8898c2f54baa3b4dd2765e34f79`; Staging `4749c480170627b551e9b4d1bb27999e8a733f06097318295300359f8dbc12c6`.
  - Staging verification log reports APK SHA-256 `e7543aea7449580e4be2e6f78c79c76f5618bcc6fc6d6c574c11df5394a33d78`, APK size 70,500,445 bytes, v2 PASS, v3 PASS, APK_DEBUGGABLE=false, release-manifest validation PASS. It also reports signer certificate SHA256 `NOT_AVAILABLE` and used an ephemeral staging key. Production signing is not configured; the Release APK is explicitly unsigned and must not be distributed. These staging checks are not production-signing evidence.
  - Font packaging/source audit passed: Regular, Medium and Bold Vazirmatn assets bundled; `FONT_SOURCE_PURGE=PASS`; `FONT_GATE=PASS_VAZIRMATN_BUNDLED_SYSTEM_DEFAULT_PURGED`. This proves assets/source gate, not complete rendered Persian-digit and accessibility-label fidelity on a live overlay. The test shard also emitted font glyph fallback warnings in a separate test context; investigate before asserting complete rendering acceptance.
- Build gate: **FAIL** due to three failing test shards, despite Analyze and all three APK assembly jobs succeeding.

### Device Smoke run `41288271013` — INCOMPLETE at this checkpoint
All child jobs are attached to the exact target SHA.
- PASS: boot, job `124793987213`, artifact `13075339603`.
- PASS: navigation, job `124793987231`, artifact `13076192419`.
- PASS: task-lifecycle, job `124793987243`; no lane artifact was uploaded.
- PASS: quick-capture, job `124793987211`, artifact `13076417219`.
- IN_PROGRESS: reminder-vazirmatn, job `124793987182`.
- IN_PROGRESS: calendar-segmented-view, job `124793987200`.
- QUEUED: follow-up-persistence, job `124793987273`.
- Current lane tally: 4/7 PASS, 2 IN_PROGRESS, 1 QUEUED; no final 7/7 result. Additional Persian time picker artifact: `13076093504`.
- Do not report the Device Smoke workflow as complete until the three remaining lanes reach conclusive states and their evidence is inspected.

### Calendar Provider run `41288271011` — SUCCESS
- Job `124793953299`: exact target SHA verification, APK manifest/integrity, installed APK integrity and real Provider acceptance passed.
- CREATE PASS; NO-OP UPDATE PASS; duplicate prevention PASS; UPDATE on same event ID PASS; DELETE PASS.
- Artifact `13075823874`, 11,217-byte ZIP; digest `b8b275b8ecadd56ef02c1833a25391de071cb1ddb1633ccc1f249e1d2a996278`.
- Limitation: `writableCalendars=1`; multi-destination calendar migration remains unverified.

### Follow-up File Persistence run `41288271008` — SUCCESS
- Job `124793953290`; exact checkout SHA and one file-backed SQLite test passed.
- No artifact uploaded. This narrow persistence test is not full Alarm lifecycle acceptance.
- Workflow restores a pinned VazirHarf asset for test asset bundling; this is not evidence of Vazirmatn overlay rendering.

### Decision / next actions
1. Keep Release **BLOCKED — RELEASE: NO-GO**. Build is FAIL and Device Smoke is incomplete.
2. Diagnose the missing `alarm-overlay-follow-up` widget key and fix the widget tests or implementation only on the authorized PR branch; do not weaken assertions to manufacture PASS.
3. Investigate the font fallback warnings and prove actual overlay Persian digit/text rendering plus accessibility labels; asset packaging alone is insufficient.
4. Poll Device Smoke until all seven lanes are terminal, then record each job and artifact ID.
5. Re-run Build and all required exact-head workflows after any source/test correction. No result from SHA `612f902...` transfers to a newer HEAD.
6. Preserve PR #3052 OPEN/DRAFT/UNMERGED and Issues #823/#2102 OPEN. No main edits, merge, production signing or release publication.


## 14. Conclusive alarm overlay audit — implementation SHA `612f9024621bae75c5bd63cec0164ee8421efe1f`

Audit timestamp: 2026-11-01. All CI results below were triggered against and checked out the exact implementation SHA `612f9024621bae75c5bd63cec0164ee8421efe1f`. This is not the current PR branch tip: after these runs, the authorized branch advanced by a documentation-only commit to `3c417feb1e024e1c994e874324318129867ef484`. The run API's PR association reports the latter as the PR head reference, while each workflow's own `head_sha` / checkout verification identifies `612f902...` as the tested commit. Do not conflate these values.

### AlarmOverlayPage source audit

Inspected `lib/alarm_overlay_page.dart` and `test/alarm_overlay_page_test.dart` at SHA `612f902...`.

| Requirement | Source result | Acceptance status / limitation |
|---|---|---|
| Stop Alarm, 64px, high-contrast red | `SizedBox(height: 64)`, `FilledButton`, `colorScheme.error/onError`; calls notification controller `cancel(notificationId)` then closes overlay | IMPLEMENTED. Widget test suite did not pass, so not accepted. Stop cancels the active notification ID only; no separate ringtone/audio controller was found or tested. |
| Task title + reminder time bound to IDs | Overlay loads Task by `taskId`, then exact `TaskReminder` by `taskReminderId`; renders Task title and reminder date/time (all-day shown as `تمام‌روز`) | SOURCE VERIFIED; widget suite incomplete/failed. |
| Volume slider + speaker | Speaker icon and disabled informational slider (`onChanged: null)); copy says volume is controlled by device settings | IMPLEMENTED AS INFORMATION ONLY. Not a functional volume control. |
| Snooze 5–120 minutes | +/- controls in 5-minute steps, clamped at 5 and 120; updates only matched Reminder, preserves its ID/title/sequence, reschedules, cancels notification; all-day reminder has no timed Snooze | SOURCE VERIFIED; no full device/runtime snooze acceptance. |
| Bottom Follow-up shortcut | Shortcut is the last control; opens `FollowUpEntryPage(taskId: task.id, allowAddingReminder: false)`; only returned explicit Save is persisted through `addFollowUp` | SOURCE VERIFIED; three widget tests fail to find the shortcut in their rendered test state. Do not mark behavior PASS. |
| Vazirmatn | Overlay wraps its content in a theme whose textTheme applies `AppFonts.vazirmatnFamily`; APK font audit found bundled Vazirmatn Regular/Medium/Bold and purged system default | SOURCE + package audit PASS; pixel-level rendering/accessibility acceptance is not established by this run. |

### Build run `41288270995` — FAILURE

- Run number: `8998`; exact `head_sha=612f902...`; overall conclusion FAILURE.
- Analyze: job `124793953540` SUCCESS.
- Six test shards:
  - test-0: job `124793953578`, PASS, 196 tests.
  - test-1: job `124793953623`, PASS, 165 tests.
  - test-2: job `124793953591`, FAIL, 260 passed / 1 failed.
  - test-3: job `124793953588`, FAIL, 125 passed / 1 failed.
  - test-4: job `124793953636`, FAIL, 206 passed / 1 failed.
  - test-5: job `124793953592`, PASS, 154 tests.
  - Aggregate: 1,106 passed and 3 failed (1,109 executed). All three failures are in `test/alarm_overlay_page_test.dart`; each reports that finder key `alarm-overlay-follow-up` found zero widgets at the time of interaction/assertion. This blocks Build acceptance; do not dismiss as unrelated.
- APK assembly jobs:
  - Staging job `124793953379`, SUCCESS; artifact `13075957858` (`arvin-staging-apk`, 32,848,936 bytes ZIP).
  - Debug job `124793953516`, SUCCESS; artifact `13076645569` (`arvin-debug-apk`, 92,519,755 bytes ZIP).
  - Release job `124793953571`, SUCCESS; artifact `13076536107` (`arvin-release-apk`, 32,448,245 bytes ZIP).
  - Staging audit candidate artifact `13075669114` (32,848,936 bytes ZIP); staging verification artifact `13075209870` (1,901 bytes ZIP).
  - Font packaging step passed for the staged APK: Vazirmatn Regular/Medium/Bold present; system-default purge passed. Staging signing is ephemeral/test-only. APK assembly success is not production-signing or release authorization.
- Artifact sizes above are ZIP archive sizes, not extracted APK byte sizes or APK SHA-256 values.

### Device Smoke run `41288271013` — INCOMPLETE / NOT ACCEPTED

- Preparation job `124793969226`: SUCCESS.
- boot: job `124793987213`, PASS; screenshot artifact `13075339603`.
- navigation: job `124793987231`, PASS; screenshot artifact `13076192419`.
- task-lifecycle: job `124793987243`, PASS; no lane artifact.
- quick-capture: job `124793987211`, PASS; artifact `13076417219`.
- reminder-vazirmatn: job `124793987182`, CANCELLED before the legacy-compatibility check/emulator smoke; no valid lane PASS.
- calendar-segmented-view: job `124793987200`, CANCELLED during emulator smoke; no valid lane PASS.
- follow-up-persistence: job `124793987273`, CANCELLED; no valid lane PASS.
- Tally: 4/7 PASS, 3/7 CANCELLED. The extra Persian time-picker artifact is `13076093504`; it does not replace any cancelled lane. No 7/7 acceptance.

### Calendar Provider run `41288271011` — SUCCESS

- Job `124793953299`: exact target SHA verification and real Android Provider acceptance succeeded.
- One instrumentation test passed: `provisionsExactlyOneWritableCalendarIdempotently`.
- CREATE, NO-OP UPDATE, duplicate prevention, UPDATE on the same event ID, and DELETE all PASS.
- Artifact `13075823874`, 11,217-byte ZIP; ZIP digest `b8b275b8ecadd56ef02c1833a25391de071cb1ddb1633ccc1f249e1d2a996278`.
- Limitation: `writableCalendars=1`; multi-destination calendar migration remains unverified.

### Follow-up File Persistence run `41288271008` — SUCCESS

- Job `124793953290`: exact checkout SHA verification passed; the dedicated file-backed SQLite test passed (1 test).
- No artifact uploaded. This is narrow persistence evidence, not Alarm Stop/Snooze/Follow-up overlay acceptance.
- Workflow restores a pinned VazirHarf asset for test asset bundling; this is not evidence of overlay Vazirmatn rendering.

### Corrected decision

- Build: FAIL (Analyze and APK assembly jobs pass, but 3/6 test shards fail).
- Device Smoke: INCOMPLETE (4/7 PASS, 3 CANCELLED).
- Calendar Provider: PASS with one-writable-calendar limitation.
- Follow-up file persistence: PASS (one test only).
- Alarm Overlay: source implementation present; full widget acceptance NOT VERIFIED due three failing tests; no 7-lane device acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED; branch `fix/recovery-calendar-device-smoke-2026-10-31`. Current branch tip after this tested SHA is `3c417feb1e024e1c994e874324318129867ef484`.
- Issues #823 and #2102 remain OPEN.
- No main edit, merge, production signing, release publication, or destructive data migration was performed.
- Release remains **BLOCKED — RELEASE: NO-GO**. Any correction must be made only on the authorized PR branch and followed by fresh exact-HEAD Build, all seven Device Smoke lanes, Calendar Provider and Follow-up persistence validation.


## 15. Alarm Overlay current-head diagnosis and corrective implementation

Audit update: 2026-11-01. Baseline at start of this dispatch was PR HEAD `55aab0d54c13076d9e35815406db5854b31e72ef`, OPEN/DRAFT/UNMERGED. The comparison `612f902...` → `55aab0d...` contains exactly two commits and only one changed path: this audit document. No application or test source changed in those two commits; therefore the three Alarm Overlay failures reported on `612f902...` remained reproducible candidates at `55aab0d...`.

### Reproduced root cause

The Build run on baseline `55aab0d...` was `41289498512` (run number 9000). Analyze passed; test-2, test-3 and test-4 failed. Their job logs identify the same failure in `test/alarm_overlay_page_test.dart`: finder key `alarm-overlay-follow-up` found zero widgets. The failing cases were:
- `Follow-up shortcut reuses the canonical form without Reminder option` — job `124797854176`.
- `explicit Follow-up Save persists history without adding a future Reminder` — job `124797854164`.
- `overlay hierarchy has a prominent Stop, volume speaker, and bottom Follow-up shortcut` — job `124797854251`.

Root cause confirmed from source and widget tree: `_buildOverlay` used `ListView(children: [...])`. Flutter's lazy sliver child delegate had not built the last/bottom Follow-up control when the tests searched for it. This was not a missing route or a missing ValueKey; it was a lazily unbuilt off-screen child.

### Code correction committed

Commit `f1caadbd58117c619c25a5d198c022945613f935` changes only `lib/alarm_overlay_page.dart`: the lazy `ListView` was replaced by `SingleChildScrollView` containing a `Column` with stretch cross-axis alignment. This eagerly builds the complete overlay widget hierarchy while preserving vertical scrolling and the bottom placement of the Follow-up control. No assertion was removed, loosened, skipped, or bypassed; `test/alarm_overlay_page_test.dart` is byte-for-byte unchanged at this commit. The correction is intended to make the existing interactions and visual-order test exercise the actual rendered control. CI acceptance remains pending until fresh exact-SHA runs finish.

### Current source contract review

- Stop action is 64px high, uses the theme error color and cancels only `widget.notificationId`. The Stop method does not write Task, completion, or Reminder data.
- Task is loaded by exact `taskId`; the Reminder is selected by exact `taskReminderId` (legacy fallback only when no reminder ID is supplied). A non-unique or missing match produces an error state.
- Snooze increments by 5 minutes and clamps at 5–120; it updates the matched Reminder by ID using `copyWith(date: nextTime)`, retaining ID/title/isAllDay/sequence, persists it, reschedules, and cancels the active notification. All-day reminders omit timed Snooze controls.
- Follow-up opens the canonical `FollowUpEntryPage(taskId: task.id, allowAddingReminder: false)`. The overlay writes history only after a non-null Follow-up is returned from the form's explicit Save; the form's future Reminder switch is suppressed by the flag.
- Volume row remains informational: disabled Slider and speaker icon; no independent audio-player or volume controller is verified. Notification dismissal must not be described as stopping an independently controlled audio stream.
- App font declarations identify `Vazirmatn` with Regular, Medium and Bold assets. Overlay applies `AppFonts.vazirmatnFamily` to its TextTheme and uses Persian numeral conversion for the Snooze value. Dialog/route glyph rendering and accessibility labels still require runtime verification; do not claim full glyph coverage based only on the declarations.
- The two requested visual references `photo_1793512287397.webp` and `photo_1793516357359.webp` were not found among the available saved reference images in this session. No pixel comparison was performed or claimed.

### Preliminary CI triggered by the correction commit

All runs below report exact `head_sha=f1caadbd58117c619c25a5d198c022945613f935`. At the time of this audit update they were still active; none is a final acceptance claim:
- Build run `41289880517`, run #9001: pending; jobs not yet published to the run-jobs endpoint.
- Device Smoke run `41289880384`, run #6268: preparation PASS job `124798736724`; boot job `124798751501` and navigation job `124798751460` in progress; quick-capture `124798751492`, reminder-vazirmatn `124798751453`, calendar-segmented-view `124798751445`, task-lifecycle `124798751559`, and follow-up-persistence `124798751443` queued.
- Calendar Provider run `41289880498`: job `124798724445` in progress.
- Follow-up File Persistence run `41289880355`: job `124798724355` in progress.
- No artifacts had been reported yet for these active runs.

### Gate status

The code correction is committed, but the acceptance result is **NOT VERIFIED** pending fresh CI. The above preliminary runs target `f1caadbd...`; if this audit document is committed afterward, those runs do not transfer to the new branch HEAD. The final audit must identify the resulting documentation-synchronized SHA and record fresh exact-HEAD Build, seven-lane Device Smoke, Calendar Provider, and Follow-up persistence outcomes. Production signing and Release Manifest verification remain separate mandatory gates. PR #3052 must remain OPEN/DRAFT/UNMERGED; Issues #823 and #2102 remain OPEN; no main changes, merge, release, or destructive migration.

## 16. Exact-HEAD CI convergence checkpoint — 2026-11-01

**Evidence anchor:** `be4a1ce9f32ec307bd136e93a8889994336cdacf`. Every run and job recorded in this section checked out this exact SHA. This section is a checkpoint, not a release approval.

### Build / Analyze — run 41289944873 (run #9002)

Run conclusion: **FAILURE**. Exact-head Analyze job `124798938508` succeeded and its log states `No issues found!`. Test shard outcomes:

| Shard | Job ID | Result | Test count |
|---|---:|---|---:|
| test-0 | 124798938506 | PASS | 196 passed |
| test-1 | 124798938457 | PASS | 165 passed |
| test-2 | 124798938478 | FAIL | 260 passed, 1 failed |
| test-3 | 124798938499 | FAIL | 125 passed, 1 failed |
| test-4 | 124798938378 | PASS | 207 passed |
| test-5 | 124798938509 | PASS | 154 passed |

The two failures are in `test/alarm_overlay_page_test.dart`: both can locate `alarm-overlay-follow-up`, but the tap hit-test lands on the test view rather than the button. This means the earlier lazy-child construction issue was not the only interaction issue: eager construction made the control discoverable, but the test does not bring the bottom control into the visible viewport before tapping. The hierarchy test must likewise be checked for actual visibility/interaction. Do not weaken or skip the tests; correct the UI/test interaction contract and rerun all gates on a new exact SHA. Aggregate shard count: 1,107 passed, 2 failed.

APK artifact records:
- Staging APK: artifact `13076469355`, ZIP size 32,848,689 bytes, uploaded ZIP SHA-256 `4445c6328d127c397e82b12ac2596a314e863d270cecf821f3436e8c4b4d52c7`. APK SHA-256 `ecb9cc8d665d12acd5ed6f0028930bef40f29a8da1307ffedb306c54b479ef47`, APK size 70,500,441 bytes.
- Debug APK: artifact `13076499233`, ZIP size 92,519,877 bytes, uploaded ZIP SHA-256 `5a5330010d304eebdfcac07d3354e7da0d232d1713feab0d82c1eea0ddd80fe5`. A separate inner APK SHA-256 was not present in the retrieved job log.
- Release APK: artifact `13077101388`, ZIP size 32,448,529 bytes, uploaded ZIP SHA-256 `819768ebf1f1bb4a7f992a6392ec390322b7c0c409a4ad863342b1895362ef75`. A separate inner APK SHA-256 and production-signature proof were not present in the retrieved job log.
- Additional staging audit candidate: artifact `13077275903`, ZIP size 32,848,689 bytes, ZIP SHA-256 `4445c6328d127c397e82b12ac2596a314e863d270cecf821f3436e8c4b4d52c7`.
- Staging verification: artifact `13077385636`, ZIP size 1,900 bytes, ZIP SHA-256 `8ae4e91fec219a3bcdb606e73c42d0b3f94ff72aa3db31fd5ab348e53e8979c0`.

The build logs report the Vazirmatn Regular/Medium/Bold assets bundled and the legacy/system-default font source purge passing (`FONT_GATE=PASS_VAZIRMATN_BUNDLED_SYSTEM_DEFAULT_PURGED`). This is a packaging/source gate only; it does not prove absence of runtime missing-glyph warnings in Persian numerals or accessibility labels.

### Device Smoke — run 41289944872 (run #6269)

At this checkpoint the run remained queued / unfinished; **4 of 7 lanes have completed PASS**, and no final 7/7 conclusion is available:
- boot — job `124799032033`: PASS; artifact `13076763418`.
- navigation — job `124799032000`: PASS; artifact `13076747233`.
- task-lifecycle — job `124799032044`: PASS; no artifact reported.
- quick-capture — job `124799031982`: PASS; artifact `13077042064`.
- reminder-vazirmatn — job `124799032075`: IN_PROGRESS; no final runtime font/glyph conclusion.
- calendar-segmented-view — job `124799032139`: IN_PROGRESS.
- follow-up-persistence — job `124799032052`: QUEUED.
- Persian time-picker evidence artifact: `13077540378` (27,079 bytes); this is supplementary evidence, not a replacement smoke lane.

No cancelled or skipped lane was reported at this checkpoint, but the three remaining lanes are not complete. Do not report 7/7 PASS.

### Calendar Provider — run 41289944891

Exact-head run **SUCCESS**; job `124798916055` PASS. Instrumentation reported one test passed and explicit real-provider markers:
- CREATE PASS, calendarId=1, eventId=1, providerVisible=true.
- NO-OP UPDATE PASS, same eventId, one provider event, no duplicate.
- UPDATE PASS, same eventId, updated title.
- DELETE PASS, same eventId, providerVisible=false.
- Limitation recorded by the run: only one writable calendar available; destination migration was not exercised.
- Artifact `13076956853`, 11,216 bytes; uploaded ZIP SHA-256 `effbd7aa8c2aa310a7a3f96187ba38aea8a095570683356bd8d9fdc931855d4b`.

### Follow-up File Persistence — run 41289944870

Exact-head run **SUCCESS**; job `124798915939` PASS. The file-backed SQLite test reported: `completion true -> false -> true survives closing and reopening the same SQLite file`. One test passed; no artifact was published.

### Governance and disposition

At the time of this checkpoint, PR #3052 was OPEN / DRAFT / UNMERGED with head `be4a1ce9f32ec307bd136e93a8889994336cdacf`; Issues #823 and #2102 were OPEN. No main-branch edit or merge was performed.

**Release remains BLOCKED — RELEASE: NO-GO.** Build run failed on two Alarm Overlay interaction tests; Device Smoke is not yet 7/7; production signing verification and Release Manifest proof remain outstanding. The evidence above is anchored to `be4a1ce...` only. This documentation update itself will advance the PR branch HEAD; it does not transfer or relabel any run as evidence for the new documentation commit. The next implementation step is to resolve the off-screen Follow-up tap/visibility behavior without relaxing tests, then rerun all required workflows against the resulting exact source SHA. After final device lanes finish, record their outcomes separately with their exact run/job/artifact identifiers.



## 17. Product-owner compact Reminder card — implementation checkpoint

**Implementation SHA:** `782168a96222fe1a5db0e8faefd8215c688ac97b` (source/test implementation); follow-up smoke/docs synchronization is committed separately and requires its own exact-SHA CI.

### Scope and visual contract
- Replaced the expanded Alarm Overlay layout with a compact white rounded card, purple bell, Task title, data-derived subtitle from the canonical ProjectStore membership (ProjectPlan.title); falls back to Task category, then actual Reminder title when no Project is assigned, and prominent Persian Reminder time.
- Added four distinct actions in the requested visual order: `تکمیل`, `تعویق`, `پیگیری`, `توقف زنگ`. The Wrap layout adapts to narrow widths and text scaling; all action buttons have explicit Persian Semantics labels.
- The reference WEBP named `image_gen_3ed82aa8-eb27-4627-b4c2-8b37992d3f9d_0.webp` was not found among conversation files or saved reference images. Pixel-level matching remains **NOT VERIFIED**; implementation follows the written structural description only.
- The unsupported, disabled volume Slider was removed. No independent Audio player/stream was found in the current notification lifecycle. `توقف زنگ` therefore cancels only the current notification ID and closes the overlay; it does not claim to stop independent audio. Hardware notification volume remains controlled by Android.

### Action isolation in source
- **تکمیل:** calls `Task.setCompleted(true, at: ...)` through `TaskStore.mutate`, then best-effort invokes the existing Reminder scheduler and the same Calendar outbound projection/sync used by Home save, preserving trashed Task IDs, before cancelling the current notification. Scheduler/Calendar sync failures do not roll back persisted completion. It does not add FollowUp or alter Reminder dates.
- **تعویق:** opens a bounded 5–120 minute duration picker and feeds the selected value to the existing in-place Reminder update + scheduler path. The Reminder ID, title and sequence are preserved; no Task dueDate, completion or FollowUp mutation is performed. Calendar outbound sync is intentionally not called from Snooze.
- **پیگیری:** reuses `FollowUpEntryPage(taskId: ...)`; the form is configured with `allowAddingReminder: false`. Only the form's explicit Save result is persisted through `TaskStore.addFollowUp`; Back/cancel writes nothing.
- **توقف زنگ:** cancels only the notification ID passed by the notification payload and closes the Overlay. No Task completion, FollowUp insertion, Reminder reschedule or data deletion occurs. Independent audio stop is **NOT VERIFIED / unsupported by the current lifecycle**.

### Regression coverage added
- Widget test for completion isolation (Task completed, no new FollowUp, Reminder unchanged, scheduler invoked, active notification cancelled).
- Widget test for the four action controls and absence of the decorative volume Slider, including large text scaling.
- Existing widget coverage retained for Snooze identity/date isolation, FollowUp form cancel, explicit FollowUp Save and all-day Reminder handling.
- Added `test/alarm_overlay_file_persistence_test.dart` to exercise Snooze and Task completion across closing and reopening the same file-backed SQLite database, preserving the sibling Reminder, dueDate and historical FollowUp identity. Added a widget test proving the subtitle is resolved from canonical `ProjectStore` membership rather than assuming `Task.category` is a Project.

### Remaining acceptance gaps
- The dedicated Android smoke must be aligned to the compact-card contract and then pass on the final SHA, with the actual `alarm-overlay-top` screenshot inspected.
- Foreground/background/cold-start notification tap, true Notification action delivery, physical-device layout and large-font screenshot review remain separate runtime gates.
- Recurring Task behavior under Snooze, full notification permission/reboot/timezone cases, independent audio playback/stop and Accessibility Screen Reader runtime remain **NOT VERIFIED**.
- Production signing/manifest, Calendar physical-device edit, Backup/Restore, remaining Issue #823/#2102 gates and product-owner final acceptance remain open.

**Governance:** PR #3052 OPEN/DRAFT/UNMERGED; Issues #823 and #2102 OPEN; no main change, merge or APK publication. **Release: BLOCKED — RELEASE: NO-GO.**


### Action-isolation correction after initial implementation
A source review found that the first attempt to mirror Home's Calendar sync placed the sync call in the Snooze method rather than Task completion. This was corrected before the current validation SHA: Snooze now only mutates the exact Reminder, invokes the established scheduler and cancels its notification; Calendar outbound sync is executed only by the Task completion action. Earlier intermediate-SHA runs are not evidence for the corrected final head.


## 18. Owner-approved Home screen implementation — 2026-11-01

**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Latest source implementation commit at this checkpoint:** `c9c1933f57fbdfac4f4cb4facbaae757b7d5677d`  
**PR:** #3052 — keep OPEN / DRAFT / UNMERGED.  
**Release:** `BLOCKED — RELEASE: NO-GO`.

This section supersedes the earlier Home source observations in §2/§3/§4 only where the current Home implementation is explicitly described below. Earlier audit SHA/run evidence remains historical and is not re-attributed to this implementation.

### Source changes

- `lib/main.dart`: Home header now uses the main title `آروین` and exact subtitle `مدیریت کارها، یادداشت‌ها و پیگیری‌ها`; the existing Bismillah brand identity remains present in a restrained small treatment because the canonical brand lock still requires it.
- Header search button focuses the existing canonical search field. The search projection and filter behavior are retained.
- Header notification button reads the actual pending notification requests from `FlutterLocalNotificationsPlugin`; the red dot is rendered only when the returned pending-request count is nonzero. The dialog lists actual scheduled requests, and selecting one resolves its payload Task ID against canonical TaskStore data before opening that Task. Plugin/query failures do not block Home or create a false red dot.
- Four Home cards now display real values: distinct tag catalog/Task tags, distinct category catalog/Task categories, non-archived Project count, and the existing selected time-filter label. The time card still invokes the existing time-filter sheet; no replacement or invented time-count definition was introduced.
- `_homeGroups` retains the existing real Task grouping, collapse state and Persian-digit item counts, with order aligned to Today, Tomorrow, Future, Past, then Undated. Today/Tomorrow group headers include dynamically derived Jalali dates. Individual Task due dates continue to use the existing Jalali formatter.
- The canonical empty state now reads `هنوز کاری برای نمایش نیست` and exposes `home-empty-add`, wired to the existing Quick Capture flow. It is shown only for an actually empty active Task set, not when an active filter merely has no matches.
- Compact Home add action is aligned to the physical right edge; normal-height FAB uses the RTL-aware start location so it also appears on the physical right, above the five-item bottom navigation.
- `lib/home/home_filter_ui.dart`: Home filter cards accept explicit active-state metadata so real counts do not incorrectly appear as active filters.
- `lib/widgets/arvin_primary_navigation.dart`: the existing Home destination label is now `امروز`; the other four routes remain unchanged.

### Data and sample-content safety

No sample Task title, sample date, sample count or sample project/tag/category was added to application runtime code or seeded into storage. Numeric card values are derived at runtime from canonical catalogs, Task assignments and non-archived Project records. Test fixtures contain synthetic values only inside test source files.

### Regression coverage updated/added

- Updated Home widget tests for the new title/subtitle, plural taxonomy labels, Today navigation label, More route, and Past section label.
- Added tests for data-derived tag/category/Project counts, the existing time-filter value, search-button focus, and the empty-state Quick Capture entry.
- Existing grouping, filtering, Task completion, Quick Capture, data-error and RTL navigation paths were retained rather than replaced.
- Test files changed in this slice include `test/widgets/home_page_test.dart`, `test/widget_test.dart`, `test/device_feedback_home_regression_test.dart`, `test/home/home_filter_contract_test.dart`, `test/home_stat_filters_test.dart`, `test/home_more_my_tasks_test.dart`, `test/home_settings_integration_test.dart`, `test/home_today_about_test.dart`, `test/g6_swipe_rtl_acceptance_test.dart`, and `integration_test/android_quick_capture_smoke_test.dart`.

### Acceptance status

- Source implementation: **IMPLEMENTED** on the authorized branch.
- Local Flutter execution: **NOT VERIFIED** in this connector-only execution; no local Flutter SDK/repository checkout was available.
- Exact-head Build/Analyze/test shards: **IN PROGRESS / NOT VERIFIED** until GitHub runs for the final post-documentation HEAD complete.
- Exact-head Device Smoke screenshots and seven lanes: **NOT VERIFIED** until the new SHA's run and artifacts are inspected.
- Pixel-level reference comparison: **NOT VERIFIED** because the named WEBP reference was not available in the execution environment; the implementation follows the written owner specification only.
- Large-font/compact-device runtime, TalkBack, actual notification tap lifecycle and physical-device acceptance: **NOT VERIFIED**.

### Independent open work retained

- Reminder-specific Foreign Key failure and file-backed SQLite timeout remain separate open defects; this Home work did not alter their test logic or mark them complete.
- Calendar Provider physical-device and two-writable-calendar acceptance, Quick Capture/Checklist architecture reconciliation, Legacy Schema safety, Backup/Restore, PDF, real-device acceptance and production signing/Manifest remain open under Issues #823/#2102/#2299.
- No Issue was closed, no main change was made, and no APK was published.


### Implementation follow-up — source commit `c9c1933f57fbdfac4f4cb4facbaae757b7d5677d`

The Today/Tomorrow Jalali group date is resolved once per group item builder and rendered only when present; this keeps the nullable date path explicit and avoids changing any grouping or date calculation. This is a presentation-only correction. Exact-head Build and Device Smoke remain required on this commit.


## 19. Parallel Home / Calendar source filters / Alarm test remediation — 2026-11-01

**Implementation source checkpoint before this documentation update:** `f1c557bac901f0bd2d64a5fe95ddb13e5d9f3fa0`  
**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **Issues #823 / #2102 / #2299:** OPEN.  
**Release:** `BLOCKED — RELEASE: NO-GO`.

### Calendar implementation
- `lib/calendar_page.dart` now retains the existing Jalali month/year navigation, Today jump, Saturday-to-Friday calendar layout, selected-day highlight, daily counts/dots, and existing day/week/month/year view control.
- Added a separate source SegmentedButton below the calendar: `همه`, `تقویم گوشی`, `یادآورها`, `پیگیری‌ها`. This is intentionally distinct from the existing calendar granularity control (`روزانه / هفتگی / ماهانه / سالانه`).
- Filtering is based on canonical source identity prefixes: `external-calendar:` for user-approved Device Calendar provider events; `task-reminder-item:`, `task-reminder:`, `task-due:`, and `task-recurrence:` for Task reminders/due-date projections; `followup:`, `task-followup:`, and `task-followup-action:` for historical Follow-up projections. No fixture or sample event is added to runtime storage.
- The calendar grid's dots and counts remain based on the full merged date projection; selecting a source filter changes only the selected-day list. Empty-filter feedback is distinct from a genuinely empty selected day.
- Device Calendar event retrieval remains owned by `OfficialCalendarPage`: it requires integration enabled, user-visible calendar IDs, and Android read permission; the new tab does not fabricate phone events or bypass permission.
- Added `test/calendar_page_test.dart` coverage for all four filters using the existing projection identity contract. This test is **NOT VERIFIED** until it runs on the new exact HEAD.

### Reminder Foreign Key root cause and correction
- The exact failure in Run `41319018030`, Attempt 1, Job `124885351836` was in `test/alarm_overlay_page_test.dart`, test `compact card resolves the actual Project membership title`.
- Root cause: the test seeded the Task through the default `TaskStore()` test executor, but injected a different `NativeDatabase.memory()` into `ProjectStore`. The schema correctly enforces `project_items.task_id REFERENCES tasks(id)`; the injected Project database had no parent Task row.
- Corrected the test to seed the same canonical Task ID into `TaskStore(executor: projectDatabase)` before inserting Project membership. This is test-fixture repair only; no production FK or schema relaxation was introduced.
- The corrected test is **NOT VERIFIED** until it passes on the post-fix exact SHA.

### File-backed Alarm test / timeout distinction
- Run `41319018092`, Attempt 1, Job `124885072413` passed one test, but its log proves it ran only `test/follow_up_repository_file_persistence_test.dart`. It does **not** prove `test/alarm_overlay_file_persistence_test.dart`.
- The dedicated Alarm Overlay file-backed close/reopen test therefore remains **NOT VERIFIED**. The reported prior 10-minute timeout has not yet been attributed to a specific lock, connection or await from a reproduced trace; no timeout ceiling was increased and no unsupported root cause is claimed.
- Existing Alarm widget tests separately cover Task completion, Reminder snooze, Follow-up cancel/save and Stop notification isolation. Their combined acceptance still requires the dedicated file-backed test and exact-HEAD CI.

### Exact-SHA evidence from the pre-remediation parent
All following evidence belongs only to SHA `c452033d96667b817a286bb072a2d99c45b01cd6`; it is not carried forward to the implementation source checkpoint above.
- Build Run `41319018030`, Attempt 1: Analyze Job `124885351710` PASS; test-3 Job `124885351663` PASS; test-5 Job `124885351687` PASS; test-0 Job `124885351836` FAIL (2 tests); test-1 Job `124885351626` FAIL (2 tests); test-4 Job `124885351637` FAIL (1 test); test-2 Job `124885351726` was IN PROGRESS at the inspected checkpoint. Shard failures include the Home label/group assertion drift, the Project FK fixture, and duplicate `امروز` text assertion. APK jobs were automatically run by the then-current Draft workflow; this was unintended relative to the owner no-APK instruction.
- Device Smoke Run `41319018109`, Attempt 1: navigation Job `124885416484` PASS; Quick Capture Job `124885416556` PASS; boot Job `124885416555` FAIL because the test expected the retired subtitle `مدیریت کارها و پیگیری آروین`; Calendar, Task Lifecycle, Reminder and Follow-up jobs were cancelled/queued during branch advancement. Not a seven-lane pass.
- Calendar Provider Run `41319018076`, Attempt 1, Job `124885070305`: PASS for emulator CREATE, NO-OP UPDATE/no duplicate, UPDATE same event ID, and DELETE. Artifact `13088483537`, `arvin-calendar-provider-acceptance-c452033d96667b817a286bb072a2d99c45b01cd6`. One writable emulator calendar only; no physical-device or multi-calendar acceptance.
- Follow-up file persistence Run `41319018092`, Attempt 1, Job `124885072413`: PASS for the repository-level file-backed completion toggle test only, not Alarm Overlay persistence.

### Draft no-APK policy correction
- Updated `.github/workflows/build.yml` so the `apk` matrix job is skipped for pull requests while they remain Draft. Analyze and all six test shards remain eligible to run. This avoids producing Debug/Release/Staging APK artifacts from a Draft PR; it does not change main or grant release authority.
- The next exact-HEAD Build must confirm the three APK jobs are skipped and Analyze/test shards run. No APK should be built, published or distributed under this Draft workflow.

### Source/test commits in this remediation sequence
- `22ceef42489dd461a2b1806e47596cb2244b7663` — correct Project FK parent setup in Alarm widget test.
- `85c06dc8fbf79f6969ca046ee072687b6bdf00f5` — add Calendar source filter UI.
- `2b5f75bcd6a9e61dc6a7defaa3db332167c0a088` — add source-filter regression test.
- `f7ceb0e147ce080d63744f8c8f63f7c7873c9f9b`, `2cf5904a66f6b20e8f949b04069330e309d3e1ac`, `7e6ff55aeee1c8345a069798846afb69d6e54d13`, `bc7f495001b5e746815d0c18f57fdd503bb7d291`, `9ab3ffa7760f18c650ce174bf41b76662d9afc0f` — align stale Home/Calendar acceptance expectations with the approved current labels and layout.
- `f1c557bac901f0bd2d64a5fe95ddb13e5d9f3fa0` — Draft workflow APK skip policy.

### Remaining open gates / ledger
- Re-run all six Build test shards and Analyze on the final documentation SHA; specifically confirm Calendar source-filter tests and corrected Project membership test.
- Run `test/alarm_overlay_file_persistence_test.dart` explicitly and collect full test logs; if it hangs, capture the last completed test step and database/connection state before making a narrow correction.
- Re-run all seven Device Smoke lanes on one exact SHA; inspect Home, Calendar and Alarm Overlay screenshots and verify no clipping at supported viewport/font scales.
- Existing Calendar Provider pass is emulator-only; physical device, two writable calendars, permission/reboot and linked-event duplicate/recovery acceptance remain open.
- Reminder notification delivery across foreground/background/cold start, system notification action affordances, TalkBack/accessibility and audio stop remain separate NOT VERIFIED gates.
- Legacy schema, Backup/Restore, PDF, Checklist/Quick Capture reconciliation, production signing, v2/v3 production certificate and Release Manifest remain open. No Issue is closed.

**Governance remains unchanged:** no main edit, no merge, no release; PR #3052 OPEN/DRAFT/UNMERGED; Issues #823/#2102/#2299 OPEN; **BLOCKED — RELEASE: NO-GO**.


---

## 20. Comprehensive reconciliation checkpoint — 2026-11-01 16:34 UTC

**This section supersedes earlier “current” status snapshots in this document.** Earlier run results remain historical and are not carried forward to a later SHA.

### Current authority / exact branch state
- Repository: `mobinpda-lab/Arvin-clean`
- Authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- Current code HEAD at this checkpoint: `a371baa428cade623940ad218a8724b5b1489be4`
- PR #3052: OPEN / DRAFT / UNMERGED; base `main`; head equals the checkpoint SHA.
- Issues #823, #2102 and #2299: OPEN.
- No main edit, merge, tag, release, or APK publication is authorized.
- Release: **BLOCKED — RELEASE: NO-GO**.
- Official font: **Vazirmatn only**; system-default fallback is prohibited.

### Exact-SHA workflow reconciliation
All rows below refer to SHA `a371baa428cade623940ad218a8724b5b1489be4`, Attempt 1:

| Workflow | Run ID | Current observed state | Jobs / evidence |
|---|---:|---|---|
| Build | 41326470775 | IN PROGRESS | Analyze `124907678663` SUCCESS; test-0 `124907678687` SUCCESS; test-1 `124907678650` SUCCESS; test-3 `124907678580` SUCCESS; test-4 `124907678712` SUCCESS; test-5 `124907678400` SUCCESS; test-2 `124907678774` IN PROGRESS; APK matrix `124907679302` SKIPPED |
| Device Smoke | 41326470822 | QUEUED / IN PROGRESS | Prepare `124907647949` SUCCESS; Boot `124907668632` SUCCESS; Navigation `124907668656` IN PROGRESS; Calendar Segmented View `124907668661` IN PROGRESS; Reminder `124907668605`, Task Lifecycle `124907668650`, Follow-up Persistence `124907668672`, Quick Capture `124907668698` QUEUED |
| Calendar Provider Acceptance | 41326470720 | IN PROGRESS | Job `124907350144` IN PROGRESS |
| Follow-up File Persistence | 41326470829 | COMPLETED / SUCCESS | Job `124907362840` SUCCESS |

**Important:** Build test-2 logs were not retrievable at this checkpoint (GitHub log endpoint returned BlobNotFound). The job remained IN PROGRESS, so no conclusion is inferred. Device Smoke is not 7/7 accepted. Calendar Provider has no final outcome yet. The standalone Follow-up file-backed SQLite workflow is PASS only for its own named persistence scope; it does not replace the Alarm Overlay file-backed test inside Build test-2.

### Verified correction commits on the authorized branch
- `5f17184923a1da6883e3f3d76eee4cf7eb166aea`: navigation contract now expects the real Home label `امروز` instead of retired `خانه`.
- `c402eefbd04c52dd0b564adf1d462a98143a8fa5`: Boot smoke expectation aligned to actual Home subtitle `مدیریت کارها، یادداشت‌ها و پیگیری‌ها`. The new Boot job above has SUCCESS on exact SHA.
- `a371baa428cade623940ad218a8724b5b1489be4`: Alarm Overlay file-persistence test injects the same file-backed SQLite executor into TaskStore and ProjectStore at both construction points. This corrects test database isolation; Alarm Overlay timeout resolution is still NOT VERIFIED until test-2 completes successfully.

### Product contract source inspection
At `a371baa428cade623940ad218a8724b5b1489be4`, `lib/calendar_page.dart` declares the requested source filter set:
- `همه` → all projected entries.
- `تقویم گوشی` → IDs prefixed `external-calendar:`.
- `یادآورها` → timed Task reminder/due/recurrence projections; all-day entries excluded.
- `انجام‌نشده` → entries where `completed == false`.

The selected-day list sorts all-day entries before timed entries and sorts timed entries chronologically. Existing widget coverage is present in `test/calendar_page_test.dart`. These are source/test observations, not physical-device acceptance. Monthly Activity Dot semantics, end-of-day Overdue retention, and live filter interaction still require explicit test/runtime evidence.

### Durable open-work ledger (do not drop)
1. **Build:** wait for Run 41326470775. Confirm test-2, all six shards, Analyze, and Draft APK guard on this exact SHA. If test-2 fails, inspect its full test output and repair only the proven cause; never weaken assertions or extend timeouts to mask a hang.
2. **Device Smoke:** wait for all seven lanes in Run 41326470822; capture exact job IDs, conclusions, artifacts, SHA-256 and screenshots. Review Boot, Calendar Segmented View, Reminder/Vazirmatn and Alarm Overlay visuals. No 7/7 claim until all seven pass on one exact SHA.
3. **Calendar Provider:** complete Run 41326470720; record emulator/device scope, artifact and checksum. Physical-device and two-writable-calendar validation remain separate.
4. **Alarm Overlay:** prove test `alarm_overlay_file_persistence_test.dart` itself passes, including close/reopen of the same file-backed DB. Separate the four actions: Task completion via canonical TaskStore; Stop only active notification lifecycle; Snooze only same Reminder; Follow-up only explicit save in standard form. Independent audio stop, recurrence, cold-start/background delivery, permissions/reboot/timezone and accessibility remain NOT VERIFIED.
5. **Calendar filters/all-day:** run the four-filter widget tests on final SHA; add/verify Activity Dot coverage for monthly cells, all-day-first selected-day ordering, exclusion from timed Reminder filter, and retention in Overdue after day end. Verify device interaction and screenshots.
6. **Reminder/Vazirmatn:** verify Persian digits, missing glyphs, font fallback, semantics/accessibility and all required screens at supported text scales. Reminder lane alone is not whole-app font acceptance.
7. **Home:** inspect exact-SHA Boot/Navigation/Quick Capture screenshots and compare with owner reference. Named WEBP `image_gen_3ed82aa8-eb27-4627-b4c2-8b37992d3f9d_0.webp` was unavailable in the prior execution environment; pixel-level comparison remains NOT VERIFIED until asset is available.
8. **Calendar/device sync:** same-event edit, no-duplicate idempotence, broken-link recovery, permissions, reboot, physical device and two writable calendars remain open.
9. **Data integrity:** legacy schema compatibility/migration, Reminder foreign-key and deletion/reopen behavior, Backup/Restore relationship integrity, recurrence snapshots, Checklist/Quick Capture canonical path and delete lifecycle require separate acceptance evidence.
10. **Output/signing:** PDF Vazirmatn embedding and Persian shaping; production signing certificate; APK v2/v3 verification; final Release Manifest containing exact SHA, byte size, SHA-256 and 7-lane smoke status are NOT VERIFIED. Draft guard remains SKIPPED; do not build/publish APK from Draft.
11. **Governance:** keep #823, #2102, #2299 OPEN; keep PR #3052 OPEN/DRAFT/UNMERGED; do not edit main, merge, tag, publish or release. Require explicit owner approval after all gates.

### Evidence protocol
Every PASS must identify: **exact SHA + Run ID + Attempt + Job ID + artifact/log/test evidence**. Source inspection is labelled implementation/source evidence, not a runtime PASS. Any missing, stale, cancelled, in-progress, queued or unavailable evidence is **NOT VERIFIED**. Keep historical results explicitly tied to their original SHA.
