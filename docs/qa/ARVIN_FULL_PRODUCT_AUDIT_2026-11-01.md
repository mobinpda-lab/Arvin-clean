# ARVIN — Full Product Audit, Canonical Baseline & Evidence Ledger
**Audit date:** 2026-11-01  
**Repository:** \`mobinpda-lab/Arvin-clean\`  
**Governing acceptance:** Issue [#823](https://github.com/mobinpda-lab/Arvin-clean/issues/823)  
**Historical tracking only:** Issue [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139)  
**Release decision:** \`BLOCKED — RELEASE: NO-GO\`  
**Authorized implementation lane:** PR [#3052](https://github.com/mobinpda-lab/Arvin-clean/pull/3052), branch \`fix/recovery-calendar-device-smoke-2026-10-31\`

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
| Repository default branch | \`main\` |
| PR #3052 | OPEN, Draft, unmerged |
| PR branch | \`fix/recovery-calendar-device-smoke-2026-10-31\` |
| Initial PR head SHA | \`3b5721d67e461976748220bcaeb78376c25affe0\` |
| PR base SHA | \`45e4202b03a434459e4c021a04efa7e8396359db\` |
| Issue #823 | OPEN |
| Issue #2102 | OPEN |
| Issue #1139 | OPEN; historical tracking only |
| NIRA | Not modified |

The initial SHA exactly matched the SHA in the user-supplied historical report. Subsequent commits in this authorized PR branch correct the Staging output path, add a path-contract test, and record this audit. The live PR head must be re-read after those commits; evidence from \`3b5721d...\` must not be attributed to later SHAs.

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

**Evidence checkpoint for the rows below:** source inspection on PR branch at initial SHA \`3b5721d67e461976748220bcaeb78376c25affe0\`; Build run \`41274996134\`; Device Smoke run \`41274996175\`; Calendar Provider Acceptance run \`41274996200\`; Fast Lane contract run \`41274996107\`; Follow-up File Persistence run \`41274996125\`. Later PR commits change the workflow/docs only; product source findings below remain observations of the inspected source until rechecked on the new HEAD.

| ID / requirement group | Status | Source path / user behavior | Relevant test / evidence |
|---|---|---|---|
| A1 Task, Due Date, Reminder and Follow-up are distinct | PARTIALLY IMPLEMENTED | \`lib/models/task.dart\` defines Task, TaskReminder and FollowUp; Task has dueDate/taskReminders/followUps. FollowUp still owns reminderDate and nextFollowUp. | \`test/task_store_test.dart\`; Build \`41274996134\` quality shards PASS, but model contract conflicts with A2/A3. |
| A2 remove Next Follow-up and followUpEnabled from active model/schema/runtime | NOT IMPLEMENTED | \`lib/models/task.dart\` still declares, serializes and parses followUpEnabled/followUpDate; FollowUp still declares nextFollowUp. | \`test/task_store_test.dart\` and \`test/task_detail_checklist_crud_test.dart\` deliberately preserve legacy fields; this is contrary to the new purge requirement. |
| A3 remove future-scheduling columns from Follow-up table | NOT IMPLEMENTED | \`lib/services/g1_drift_schema.dart\` creates \`follow_ups.reminder_date\` and \`follow_ups.next_follow_up\`; \`tasks.follow_up_enabled\` remains. | \`test/services/g1_drift_schema_test.dart\` and migration writer currently encode legacy schema; safe migration not present in inspected code. |
| A4 real completedAt on each Follow-up record | PARTIALLY IMPLEMENTED | \`FollowUp.dateTime\` maps to SQL \`follow_ups.date_time\`; \`Task.completedAt\` is a separate Task completion timestamp. No FollowUp.completedAt field was found. | \`test/task_store_test.dart\` tests Task completedAt preservation, not the required per-record completedAt contract. |
| A5 Follow-up edit cannot mutate its real completion timestamp | PARTIALLY IMPLEMENTED | \`lib/task_detail_page.dart\` protects Follow-up collection during Task description/checklist edits; record timestamp is currently named dateTime. | \`test/task_detail_followup_flow_test.dart\` test “inline description edit updates updatedAt and preserves completion and Follow-up history” passed in Build shard test-1 on initial SHA; per-record completedAt semantics remain absent. |
| A6 explicit Follow-up-to-Task conversion is stable/idempotent | NOT VERIFIED | No verified conversion contract was established in inspected paths. | No matching named acceptance test/evidence located. |
| A7 Task completion suppresses future notifications and preserves history | IMPLEMENTED BUT NOT VERIFIED | \`lib/models/task.dart\` has setCompleted; \`lib/services/task_store.dart\` persists Task and Follow-up history. | \`test/task_store_test.dart\` has completion/history tests; full notification suppression path not independently proven by this run. |
| B1 Quick Capture has no Checklist or legacy flags | NOT VERIFIED | \`lib/main.dart\`, Quick Capture dialog implementation not fully audited in this pass. | Device Smoke \`smoke-quick-capture\` PASS on run \`41274996175\`; no evidence in that lane for every prohibited field/Checklist rule. |
| B2 Full Task form supports multiple independent Reminders | IMPLEMENTED BUT NOT VERIFIED | \`lib/models/task.dart\` has \`taskReminders\`; Reminder data is separate from dueDate. | \`test/task_store_test.dart\`; no current exact-head per-reminder edit/delete proof reviewed. |
| B3 relative reminder requires real time; all-day 00:00 is not a time reference | PARTIALLY IMPLEMENTED | \`lib/calendar_page.dart\` has all-day-aware presentation; full scheduling/alarm path not verified. | No complete date/time edge-case evidence reviewed. |
| B4 Checklist only in Task Details; Add/Edit/Delete preserves data | IMPLEMENTED + VERIFIED | \`lib/task_detail_page.dart\`; Task Details owns checklist operations. | \`test/task_detail_checklist_crud_test.dart\`, test “checklist add, inline edit and delete preserve legacy follow-up timestamps”, passed in Build run \`41274996134\`, shard test-2, initial SHA. The test preserves legacy fields, so it does not validate the new purge rule. |
| B5 Follow-up form offers optional normal Reminder shortcut | NOT IMPLEMENTED | \`lib/follow_up_entry_page.dart\` saves FollowUp and still copies legacy reminderDate/nextFollowUp; no new Reminder shortcut observed. | No test for creating a normal Task Reminder from this form located. |
| B6 New Follow-up defaults to now and uses Universal Arvin Time Picker | IMPLEMENTED BUT NOT VERIFIED | \`lib/follow_up_entry_page.dart\` exposes date/time controls; exact universal picker integration and default behavior not fully proven. | No current target-SHA dedicated picker acceptance result reviewed. |
| C1 record-driven ledger uses real follow_up_records and MAX(completedAt) | NOT IMPLEMENTED | \`lib/services/completed_task_report_projection.dart\` filters completed Tasks by Task.completedAt, not Follow-up rows; \`lib/report_center_page.dart\` presents completed Tasks. | No record-driven aggregation query/projection test found. |
| C2 Follow-up report in Report Center opens on today | PARTIALLY IMPLEMENTED | \`lib/report_center_page.dart\` has “گزارش پیگیری‌های انجام‌شده” entry, but it opens a completed-Task report. | \`test/report_center_page_test.dart\` covers report center behavior; it does not establish the required record-driven report. |
| C3 Jalali date picker and half-open local day interval | IMPLEMENTED BUT NOT VERIFIED | \`lib/services/completed_task_report_projection.dart\` uses local start-of-day and next local day (not fixed 24h). | No test evidence for daylight/timezone boundaries or Follow-up completedAt filtering. |
| C4 previous/next/Today, summary, two sorting/grouping modes | NOT IMPLEMENTED | \`lib/report_center_page.dart\` dialog has a date picker and task list only; no previous/next/Today controls, aggregation summary, or two display modes were observed. | No matching report interaction tests. |
| C5 row fields, stable taskId navigation and history sorting | PARTIALLY IMPLEMENTED | Existing report rows navigate using Task IDs; the inspected completed-task dialog uses ValueKey(task.id). Required Follow-up record row fields/sorting not present in that dialog. | \`test/report_center_page_test.dart\`; full required history report NOT VERIFIED. |
| C6 history retained for open/completed/archived Tasks; exclude reminders/due dates; no notifications | NOT VERIFIED | \`lib/services/person_follow_up_report_projection.dart\` excludes archived/completed tasks in waiting-only mode and exposes legacy reminder/nextFollowUp projections. | No acceptance evidence for the complete report inclusion/exclusion contract. |
| C7 exact empty/error states and stale-query protection | NOT IMPLEMENTED | Existing completed-task dialog uses “در این روز تکمیل ثبت‌شده‌ای وجود ندارد.”, not the required empty state; no required error state/rapid-filter contract observed. | No corresponding tests found. |
| D1 Home has exactly six fixed sections and completed collapsed at bottom | NOT VERIFIED | \`lib/main.dart\` is the Home composition source; full six-section order/collapse behavior not established in this pass. | \`integration_test/android_home_smoke_test.dart\` covers boot/navigation, not the full six-section contract. |
| D2 Home shows only nearest future Reminder per Task | NOT VERIFIED | Reminder projection exists in app source; exact Home summary selection was not established. | No named test/evidence reviewed. |
| D3 all-day ordering and distinct date filters | PARTIALLY IMPLEMENTED | Calendar item has isAllDay; \`lib/calendar_page.dart\` contains all-day-aware time/presentation branches. Home/filter behavior not fully verified. | No complete ordering/filter boundary test reviewed. |
| D4 Calendar labels/icons/prayer/reminder visual rules | IMPLEMENTED BUT NOT VERIFIED | \`lib/calendar_page.dart\` has distinct visual-kind classification including prayer, Arvin Reminder and Follow-up. Exact icon/text polish not visually accepted. | Calendar emulator run was cancelled; no screenshot artifact for Calendar lane. |
| E1 independent Local Arvin Calendar and explicit Device Calendar | IMPLEMENTED BUT NOT VERIFIED | \`lib/calendar_page.dart\`, \`lib/main.dart\`, Calendar integration services. | Calendar Provider Acceptance run \`41274996200\` SUCCESS on initial SHA; physical-device acceptance absent. |
| E2 at most five recurrence preview occurrences | NOT VERIFIED | Recurrence/calendar preview implementation not fully inspected in this pass. | No named test/run evidence reviewed. |
| E3 device sync idempotent, isolated, failure-safe | IMPLEMENTED BUT NOT VERIFIED | Calendar Provider workflow performs real Provider acceptance; Calendar card actions include sync. | Run \`41274996200\` SUCCESS and artifact \`13070688563\`; artifact contents not yet independently reviewed. |
| E4 all-day never becomes timed 00:00 | PARTIALLY IMPLEMENTED | \`lib/calendar_page.dart\` distinguishes isAllDay and avoids showing a time chip for all-day items; provider sync contract remains to be reviewed. | No complete exact-head all-day Provider evidence reviewed. |
| E5 changes in one calendar path do not mutate the other | NOT VERIFIED | Separate Calendar integration path exists; no full failure-isolation proof reviewed. | No current target-SHA fault-injection test evidence. |
| F1 Task left/right settings are independent dropdowns | IMPLEMENTED BUT NOT VERIFIED | \`lib/settings_page.dart\` has \`swipe-right-action\` and \`swipe-left-action\`. | No exact-head settings interaction test reviewed. |
| F2 Task options include configurable “ثبت پیگیری” | NOT IMPLEMENTED | \`lib/settings_page.dart\` explicitly filters \`TaskSwipeAction.convertToFollowUp\` out of \`_swipeItems()\`, despite defining its label. | No dropdown test proving option selection; source directly contradicts requirement. |
| F3 selecting “ثبت پیگیری” opens form only | NOT VERIFIED | Runtime action path not fully proven; option is not selectable through current Settings dropdown. | No test evidence. |
| F4 Calendar left/right settings independent of Task swipes | IMPLEMENTED BUT NOT VERIFIED | \`lib/settings_page.dart\` uses separate \`CalendarSwipeSettingsService\`; \`lib/calendar_page.dart\` receives separate calendar actions. | No current exact-head independent-execution test reviewed. |
| F5 Calendar options Edit/Delete/Transfer-to-device | PARTIALLY IMPLEMENTED | CalendarSwipeAction enum has edit/trash/sync/none; \`lib/calendar_page.dart\` dispatches actions. Sync callback is restricted to canonical Task records. | No complete swipe action matrix test/evidence reviewed. |
| G1 soft delete moves to recoverable Trash | IMPLEMENTED BUT NOT VERIFIED | Task model has trashed; Settings offers Trash; app has Trash state. | No current exact-head restore test evidence reviewed. |
| G2 hard delete policy and independent history preservation | BLOCKED | No clear product lifecycle decision for hard deletion of Task vs independent Reminder/Follow-up history was established. | No destructive behavior changed; decision required before implementing cascade/purge. |
| H1 recurrence pattern/occurrence snapshots and idempotency | PARTIALLY IMPLEMENTED | \`lib/models/task.dart\` includes recurrence, checklistOccurrences and occurrenceHistory. | No complete duplicate-occurrence/history test evidence reviewed. |
| H2 only real backend filters; distinct Task/Reminder/Follow-up dates | PARTIALLY IMPLEMENTED | \`lib/report_center_page.dart\` includes hasFollowUp filter; current projection includes legacy Next Follow-up properties. | Query contract tests not reviewed. |
| H3 Backup/Restore preserves relationships/history and cannot revive Next Follow-up | PARTIALLY IMPLEMENTED | Backup/Restore smoke lane uses SQL lifecycle; legacy fields remain serialized in Task/FollowUp model. | \`smoke-task-lifecycle\` PASS in run \`41274996175\`; prohibited legacy-field purge/restore behavior is not satisfied. |
| H4 PDF embeds Vazirmatn and shapes Persian | NOT VERIFIED | \`pubspec.yaml\` registers Vazirmatn for Flutter; PDF package exists. PDF font embedding/shaping path not inspected or tested. | No PDF-specific font embedding/shaping test or artifact reviewed. |
| I1 Vazirmatn only, bundled in APK; System Default prohibited | PARTIALLY IMPLEMENTED | \`pubspec.yaml\` registers Regular/Medium/Bold; \`lib/main.dart\` applies Vazirmatn theme. | Build run \`41274996134\`: Debug/Release Font Packaging Audit PASS; Staging APK was not found so Staging font packaging NOT VERIFIED. |
| I2 all overlays/third-party surfaces, single theme source/render guard | NOT VERIFIED | Main theme source exists; global render guard/overlay coverage not proven. | No screenshot/font-leakage acceptance evidence reviewed. |
| I3 approved typography weights | NOT VERIFIED | Some explicit weights appear in Calendar and theme; complete role-to-weight audit not completed. | No typography contract test/visual acceptance reviewed. |
| I4 PDF font embedding/shaping and strict RTL/Persian digits | NOT VERIFIED | No PDF output artifact or RTL/Persian-digit comprehensive evidence reviewed. | No PDF shaping test or seven-lane screenshot review. |
| J1 Data Model release gate | NOT IMPLEMENTED | Active schema/model/store continue to read/write prohibited legacy fields. | Source inspection on initial SHA directly fails the gate. |
| J2 Task Swipe release gate | NOT IMPLEMENTED | Settings dropdown excludes convertToFollowUp. | Source inspection directly fails the gate. |
| J3 Calendar Swipe release gate | PARTIALLY IMPLEMENTED | Separate settings/actions exist; full independent action acceptance not proven. | No complete exact-head swipe matrix. |
| J4 Device Calendar Sync release gate | IMPLEMENTED BUT NOT VERIFIED | Calendar Provider Acceptance succeeded on initial SHA. | Run \`41274996200\`; physical-device sync proof and reviewed artifact details remain NOT VERIFIED. |
| J5 Typography + PDF release gate | PARTIALLY IMPLEMENTED | Vazirmatn registered; Debug/Release packaging audit passed; PDF shaping unproven and Staging path failed. | Build run \`41274996134\`; Staging APK absent at incorrect path. |
| J6 required tests and seven Device Smoke lanes | PARTIALLY IMPLEMENTED | Build six shards passed; named Checklist CRUD and description-history tests were found in shard logs. | Run \`41274996134\` exact initial SHA. Device Smoke run \`41274996175\` did not complete: boot/navigation/quick-capture/task-lifecycle passed; calendar/reminder/follow-up lanes were cancelled. |
| J7 same-target-SHA proof for release | BLOCKED | Initial SHA has mixed evidence; subsequent workflow/doc commits change the target SHA and trigger fresh runs. | No single SHA has all required gates passed. |

## 5. Actual CI and runtime evidence

### Build — run 41274996134

Target branch: \`fix/recovery-calendar-device-smoke-2026-10-31\`; target SHA: \`3b5721d67e461976748220bcaeb78376c25affe0\`.

- Analyze: PASS (job \`124755300440\`).
- Test shards test-0 through test-5: PASS (jobs \`124755300326\`, \`124755300332\`, \`124755300394\`, \`124755300382\`, \`124755300335\`, \`124755300413\`).
- Checklist CRUD test “checklist add, inline edit and delete preserve legacy follow-up timestamps”: found in shard test-2 log and passed.
- Task description/history test “inline description edit updates updatedAt and preserves completion and Follow-up history”: found in shard test-1 log and passed.
- TaskStore test “TaskStore updates description without rewriting completedAt or historical Follow-ups”: found in shard test-5 log and passed.
- Debug APK: PASS; artifact \`13071391543\`.
- Release APK build/artifact: PASS at build level; artifact \`13071391639\`. This is not production-signature proof.
- Staging Gradle task: BUILD SUCCESSFUL; however the workflow looked at the wrong file path \`android/app/build/outputs/apk/staging/app-staging.apk\`. Log explicitly printed \`APK_FILE=NOT_FOUND\`; apksigner exit was NOT_RUN; v1/v2/v3, debuggable and manifest were NOT_VERIFIED/FAIL. Staging candidate artifact was not uploaded because that path did not exist. Verification artifact \`13070643263\` contains audit files only.

### Device Smoke — run 41274996175

Target SHA: \`3b5721d67e461976748220bcaeb78376c25affe0\`.

- PASS: \`smoke-boot\`, \`smoke-navigation\`, \`smoke-quick-capture\`, \`smoke-task-lifecycle\`.
- CANCELLED: \`smoke-calendar-segmented-view\`, \`smoke-reminder-vazirmatn\`, \`smoke-follow-up-persistence\`.
- Available artifacts: boot \`13070783148\`, quick capture \`13070992114\`, navigation \`13071272143\`, Persian time picker \`13071067054\`.
- Calendar log emitted: \`CALENDAR_ROUTE_DIAG: navigation=1 calendarTitle=1 helpButton=1 segmentedControl=1\`; therefore the weekly control was present in the observed emulator route at that point. Two seeded reminders were projected and the due-date item was also present. The emulator job was then cancelled; no Calendar screenshot was produced (\`No files were found\`). This is a cancellation, not proof that the assertion passed or failed. No root cause for the remaining long-running interaction is claimed.

### Calendar Provider Acceptance — run 41274996200

Target SHA: \`3b5721d67e461976748220bcaeb78376c25affe0\`; job \`124755267335\` SUCCESS; artifact \`13070688563\`. This proves that the workflow job completed successfully on that SHA. The artifact has not yet been unpacked/reviewed in this audit, and it does not replace installed-device acceptance.

### Fast Lane and file persistence

- Fast Lane contract run \`41274996107\`, job \`124755266616\`: SUCCESS.
- Follow-up file-backed SQLite persistence run \`41274996125\`, job \`124755266847\`: SUCCESS on the initial SHA. This run used a workflow cache/font label referencing VazirHarf; that is factory/test dependency metadata, not proof of the product font. Product font authority remains Vazirmatn.

## 6. Staging correction committed to the authorized branch

The inspected \`android/build.gradle.kts\` redirects the root Gradle build directory using \`.dir("../../build")\`. The module output is therefore under the repository-level \`build/app/...\`, not \`android/app/build/...\`.

- Updated \`.github/workflows/build.yml\` to use \`build/app/outputs/apk/staging/app-staging.apk\` for verification, font audit, manifest and upload paths (six path references).
- Added \`test/build_staging_artifact_path_contract_test.dart\` to assert that the workflow follows the configured repository-level Gradle build directory and rejects the incorrect path.
- Updated \`docs/CHANGELOG-2026-10-30.md\`.
- The path correction is a source-level diagnosis and patch, not a verification PASS. It must be confirmed by a new exact-head Build run that preserves the raw \`apksigner verify --verbose\` output, separate v2/v3 results, APK_DEBUGGABLE=false, APK size/SHA-256, Release Manifest and Staging artifacts.

## 7. Database migration and data-safety blocker

The inspected schema is version 7. It currently defines:

- \`tasks.follow_up_enabled\`
- \`tasks.follow_up_date\`
- \`follow_ups.reminder_date\`
- \`follow_ups.next_follow_up\`

The Task model and TaskStore read/write these fields; \`sql_task_migration_writer.dart\` writes them as well. Legacy compatibility is currently active, not merely inert historical data.

**Unknown:** whether the real user database contains any rows or non-null legacy values. No live database file was read and no row counts were obtained. Therefore it is not established that the database is empty.

**Required safe next step:** before any destructive DDL, inspect the actual database and backup state; count rows and non-null legacy values; map each value to its canonical Reminder/history destination; create a verified backup; design an idempotent, data-preserving migration; test pre-migration and post-migration row counts, IDs, relationships, and restore behavior. A table rebuild/drop is blocked until that evidence exists. No migration has been attempted.

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

Confirmed implementation gaps include active legacy future-Follow-up fields, the Follow-up report using Task completion timestamps instead of real Follow-up records, and the Task Swipe Settings dropdown omitting “ثبت پیگیری”. Calendar swipe settings and Reminder/Calendar foundations exist but are not fully accepted. Checklist CRUD and Task completion/history tests passed on the initial SHA. Four of seven Device Smoke lanes passed; three were cancelled. Calendar Provider Acceptance passed at workflow level but its artifact and physical-device behavior remain unreviewed. Staging build succeeded but verification failed because the APK path was wrong; signature v2/v3 and manifest remain NOT VERIFIED.

No merge, release, publish, main-branch edit, issue closure, NIRA change, or destructive database migration was performed.
