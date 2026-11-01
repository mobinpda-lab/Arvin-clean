# ARVIN Changelog — 2026-10-30

## Issue #823 — canonical product contract registration

This entry records the governing product decisions for Reminder-only scheduling, Follow-up history, gestures, Calendar actions, and typography. Registration of the contract is not, by itself, evidence that every legacy consumer has been removed or that release acceptance has passed.

### Canonical model and scheduling

- Retire **Next Follow-up** and the **`followUpEnabled`** column from active schema, models, DTOs, persistence, UI, queries, APIs, tests, and documentation. Retained historical compatibility data must not be read as active scheduling state.
- Use **Reminder-only** scheduling for all future actions. A Follow-up Record represents only a real action completed in the past and must carry its actual `completedAt` timestamp. Opening the Add Follow-up form must not create a record until the user saves it.
- Do not reintroduce future scheduling through Follow-up fields, aliases, or projections.

### Canonical gestures

- **Task-list swipe:** `ثبت پیگیری` opens the Add Follow-up form; it does not immediately create a Follow-up Record. Task-list swipe choices must not contain `انتقال به تقویم گوشی`.
- **Calendar swipe/gesture actions:** Edit, Trash/Delete, and Device Calendar Sync belong exclusively to Calendar items and remain isolated from Task-list swipe choices.

### Typography

- **Vazirmatn** is the exclusive application UI font. It must be registered and bundled inside every distributable APK.
- **System Default** and legacy font-family fallbacks/options are prohibited.
- CI Font Gate must inspect the built APK for Regular, Medium, and Bold Vazirmatn assets and fail if legacy font or System Default source references remain.
- PDF output must use Vazirmatn assets and retain the separate PDF embedding and Persian shaping acceptance checks.

### Acceptance status

- This changelog entry registers the canonical contract; it does not certify a repository-wide Next Follow-up / `followUpEnabled` purge.
- Exact-head Analyze, all six test shards, Debug/Release APK Font Gate, Calendar Provider CRUD, and remaining Issue #823 acceptance gates must pass with retained artifacts before release consideration.
- **Release:** `BLOCKED — RELEASE: NO-GO`.


## 2026-11-01 — Issue #823 full product audit and Staging path correction

- Added a complete canonical product baseline and evidence-led audit ledger in `docs/qa/ARVIN_FULL_PRODUCT_AUDIT_2026-11-01.md`; the ledger distinguishes implementation evidence from runtime/target-SHA acceptance.
- Corrected Staging APK verification, font audit, manifest and upload paths to follow the repository-level Gradle build directory configured by `android/build.gradle.kts` (`$GITHUB_WORKSPACE/build/app/outputs/apk/staging/app-staging.apk`).
- Added `test/build_staging_artifact_path_contract_test.dart` to prevent regression to the incorrect `android/app/build` location.
- No user database was modified; no destructive schema migration was attempted because live database emptiness and data-preservation requirements have not been established.
- Exact-head CI after these commits is pending. Staging v2/v3 signature, `APK_DEBUGGABLE=false`, and Release Manifest remain NOT VERIFIED until the new workflow provides raw evidence.
- Release remains **BLOCKED — RELEASE: NO-GO**.

- Implemented configurable Task-list “ثبت پیگیری” for either swipe direction: Settings exposes and persists the action; selecting it opens FollowUpEntryPage and writes a record only after explicit Save. Added left/right and no-auto-write regression tests. Exact-head CI validation is pending.

- Added an optional “افزودن یادآور” shortcut to Follow-up entry for persisted Tasks. It selects Jalali date and Universal Arvin Time Picker time, then stores a normal independent Task Reminder linked to the same Task; new Follow-up JSON omits empty legacy future-scheduling keys.
- Replaced the completed-Task timestamp dialog with a genuine Follow-up record report: local Jalali day interval, previous/next/Today, Persian-digit aggregation, chronological and Task-ID grouped modes, actual time/note/result/person, Task Details navigation, and exact empty/error states.
- Added Follow-up completedAt compatibility getter mapped to the canonical persisted dateTime field; a physical SQL-column migration remains pending.
- Added regression coverage for Reminder shortcut on/off, report day boundaries, multiple records, cross-Task aggregation, exclusions and navigation. Exact-head CI validation is pending.
- Fixed the Settings UI test expectation for the newly available “ثبت پیگیری” Task swipe action.

- Corrected analyzer findings in the completed Follow-ups report and stabilized the Follow-up Office waiting-response switch test with a dedicated key; scoped the report exclusion assertion to the report row rather than the underlying page. Fresh exact-head CI is required for these corrections.


## 2026-11-01 — Binding alarm / Task completion / Snooze / Follow-up separation directive

- Product-owner clarification: **“انجام شد” completes the parent Task through the existing canonical completion path**. It is not equivalent to stopping audio, snoozing a Reminder, or inserting a Follow-up.
- Defined four independent user actions: stop current alarm audio; snooze only the same Reminder; complete Task via canonical behavior; optionally insert historical Follow-up only after explicit action.
- Recorded a narrow product-owner scope override to the earlier Issue #823 “No new features” freeze. The exception is limited to this interaction on PR #3052; unrelated features remain frozen. Issue #823 remains OPEN.
- Data-safety contract: preserve Task, history, recurrence, unrelated Reminders and existing notification lifecycle; no destructive migration; no automatic Follow-up on stop/snooze/complete; idempotent completion; preserve existing reopen behavior.
- Acceptance requires exact target SHA + actual run ID + inspectable evidence/artifact for every PASS. Initial source inspection is not runtime proof.
- Intake baseline HEAD: `eb017f57ccd98f8bc43025aedd837fad2f79a2f6`. Implementation and tests remain NOT VERIFIED pending inspection and execution.
- PR #3052 remains OPEN/DRAFT. Release remains **BLOCKED — RELEASE: NO-GO**. No main edit, merge or APK publication.


### Alarm interaction implementation status — source audit
- Source inspection found the existing reminder path currently posts a high-priority local notification from a background runner; it has no in-app alarm audio controller, stop/cancel action, notification-response route, or alarm overlay. The requested stop control and overlay therefore cannot be wired into an existing UI/audio lifecycle yet.
- `TaskReminder` records are serialized in the Task JSON envelope in `tasks.legacy_payload_json`; the inspected SQLite schema has no dedicated `task_reminders` table. A safe snooze candidate is an in-place date update preserving Reminder ID via `TaskStore.mutate`, followed by the existing scheduler reschedule, subject to file-backed reopen and isolation tests. No migration is currently justified.
- Existing canonical Task completion is `Task.setCompleted` + TaskStore persistence + reminder reschedule + calendar sync in the app's existing completion callback. Do not implement parallel completion logic.
- FollowUp historical timestamp uses `dateTime/date_time`; legacy scheduling columns remain in the SQL schema and must be NULL for new historical records.
- No source implementation or runtime acceptance is claimed. The audit records the blocker and safe integration direction. Release remains **BLOCKED — RELEASE: NO-GO**.

## 2026-11-01 — Binding alarm widget visual-coordinate directive

- Recorded the requested top-to-bottom widget element map and exact Persian labels: red `توقف آلارم`, Task/current Reminder block, audio-volume slider, snooze stepper and dark-blue primary action.
- Reconciled action naming with the existing binding product decision: dark-blue primary action is `انجام شد` and must invoke canonical Task completion; optional `ثبت سابقه پیگیری` is a distinct explicit historical FollowUp action, never completion.
- Bundled Vazirmatn is mandatory for every label, numeral, dialog and accessibility string; System Default is prohibited.
- The referenced `photo_1793516357359.webp` was not available as an attachment in the execution context, and the text supplied no numeric pixel bounds. Exact screenshot/pixel-coordinate acceptance remains NOT VERIFIED.
- Prior source audit found no in-app alarm audio/volume controller, notification stop/action route or overlay entry point. No fake slider, parallel audio engine or unsupported source implementation was added.
- No source implementation or alarm-specific test PASS is claimed. Build run `41279261929` is general build evidence only; Device Smoke run `41279261863` was CANCELLED. Calendar Provider and FollowUp SQLite runs do not validate alarm behavior.
- PR #3052 remains OPEN/DRAFT; Issue #823 remains OPEN; release remains **BLOCKED — RELEASE: NO-GO**.


## 2026-11-01 — Product-owner correction: alarm widget Follow-up shortcut

- Supersedes the earlier §13 interpretation that the dark-blue alarm-widget action should be labelled `انجام شد` and invoke Task completion.
- The latest directive defines the dark-blue `ثبت سابقه` action as the existing shortcut to open Arvin's standard Follow-up form (`FollowUpEntryPage`) for the current Task.
- Opening or cancelling the form must not persist a FollowUp, alter Reminder schedules or complete the Task. Only explicit Save in the existing form may write historical FollowUp data.
- Task completion remains a separate canonical action and must not be triggered by this shortcut. Stop, Snooze, Follow-up form and Task completion remain isolated.
- Source inspection confirms `lib/follow_up_entry_page.dart` contains the standard form and explicit save control `follow-up-entry-save`; exact alarm-widget caller wiring and Task-ID handoff remain NOT VERIFIED.
- No source implementation or alarm-widget acceptance tests are claimed. Screenshot pixel matching remains NOT VERIFIED because the named WEBP was not available to inspect.
- Vazirmatn remains mandatory throughout. PR #3052 OPEN/DRAFT, Issue #823 OPEN, Release **BLOCKED — RELEASE: NO-GO**.


## 2026-11-01 — Product-owner compact Reminder card (latest directive)

- Supersedes prior alarm-widget visual layouts and the previous single-action label interpretation for this card. The approved written contract now has four independent actions: `تکمیل`, `تعویق`, `پیگیری`, and `توقف زنگ`.
- Replaced the expanded Overlay presentation with a compact white rounded card, purple bell, dynamic Task title, canonical ProjectStore/ProjectPlan subtitle (with safe category/Reminder fallback), prominent Persian Reminder time, and responsive four-action Wrap layout.
- `تکمیل` calls the canonical `Task.setCompleted(true)` model method through TaskStore mutation, then best-effort Reminder reschedule and the existing Calendar outbound projection/sync path; it does not insert FollowUp or alter Reminder dates.
- `تعویق` uses a selected 5–120 minute duration and the existing same-Reminder in-place update/scheduler path; stable Reminder ID and sequence are retained.
- `پیگیری` opens the existing `FollowUpEntryPage` for the same Task with future Reminder creation disabled; only explicit Save writes a historical FollowUp.
- `توقف زنگ` cancels only the active notification ID and closes the Overlay. No independent audio player/controller exists in the inspected implementation; the action does not claim independent audio stop.
- Removed the disabled/decorative volume Slider instead of presenting a nonfunctional control. Android notification volume remains a system setting.
- Added widget isolation tests and a file-backed SQLite close/reopen test for Snooze and completion, preserving sibling Reminder, dueDate and FollowUp history.
- The referenced WEBP was unavailable in the execution environment; pixel-level comparison remains NOT VERIFIED. Runtime emulator/device screenshot acceptance remains pending.
- These source/test changes are not accepted until exact-final-SHA Build, Device Smoke, Alarm screenshot review and remaining release gates pass. PR #3052 remains OPEN/DRAFT; Issues #823/#2102 remain OPEN; **Release: BLOCKED — RELEASE: NO-GO**.
