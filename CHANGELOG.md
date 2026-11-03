## 2026-11-03 — Wave 7.304 Home overdue styling and completion archive behavior

- Home cards now render overdue, unfinished Task title and due-date text in the error/red text color only; overdue status and due-date icons remain neutral, card surface and border remain unchanged, and unrelated follow-up text/icons remain neutral.
- Completing an active Home Task immediately sets its canonical `completed` and `archived` state before the Home rebuild, so it leaves active scopes including the Past filter and remains in canonical Archive storage. Task identity, due date, reminder, checklist, description and FollowUp history are preserved.
- Added Home widget regression coverage for red overdue text with neutral icons, instant archive with preservation of task data/history, and instant removal while the Past filter is active. Assertions are additive; existing tests were not deleted or weakened.
- Date-jump relocation remains **NOT IMPLEMENTED / NEEDS PRODUCT CLARIFICATION**. On this branch, the current-date action is `calendar-today` in `CalendarPage`, while `calendar-date-jump` opens an arbitrary Jalali date selector; neither is a HomePage control. Moving either into Task Details would change its meaning without an explicit owner decision.
- Source/test commits: `c5d8627211b7cb8b0c601e74cefa44119dd309c4`, `c9c6cbfdda950ca5f2d4d9c0364236d058a5775f`, `378045d5d020d307cb9dfa88b3ede998753ed719`, `9ce6ff8627fb414b4e10ceb3019d169a8487e4af`, `d89f46641a59e93e4cf81cfb69b17192af59fe32`. Exact-HEAD test/CI validation is pending.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main is untouched. Release remains **BLOCKED — RELEASE: NO-GO**.

## 2026-11-02 — Local Calendar historical FollowUp exclusion

- Product behavior: historical FollowUp records are filtered at the local Calendar display boundary. IDs with the historical `followup:` and legacy `task-followup:` namespaces are excluded from both supplied and visible-range projected Calendar items.
- Dated Task events, independent dated Reminder events, and recurrence projections remain in the existing Calendar projection. `task-followup-action:` is not filtered by this change.
- FollowUp records, Task Details history, Follow-up Notebook data, Report Center projections, Task storage, Reminder data, Due Dates, and legacy database columns are not modified or deleted.
- Implementation: `lib/calendar_page.dart`; regression coverage: `test/calendar_page_test.dart`, `test/calendar_runtime_actions_fast_track_test.dart`, and `test/calendar_release_acceptance_test.dart`. Existing projection, Task Details and Report Center tests are retained.
- Implementation/test commit: `8533b17599af46524973bc0a366864d44e08c96e`. Documentation synchronization commits follow; exact final branch HEAD and exact-head CI results must be read back before acceptance.
- Release remains **BLOCKED — RELEASE: NO-GO**. PR #3052 must remain OPEN / DRAFT / UNMERGED. No main mutation, merge, APK publication, or release is authorized.

### Exact-SHA validation checkpoint — 2026-11-02

- Validated source/test SHA: `04cacb3a88a99c12286dd6d8f6a9d0268a0d12eb`.
- Build #9185 / Run `41509339452`: **SUCCESS**. Analyze SUCCESS; all six test shards SUCCESS; 1,122 tests passed in total. Draft PR APK matrix was SKIPPED by the existing Draft guard.
- Explicit regression tests passed: `calendar_page_test.dart` (historical FollowUp hidden from supplied and visible-range projected inputs; dated Task and independent Reminder remain visible); `calendar_runtime_actions_fast_track_test.dart`; `calendar_release_acceptance_test.dart`; `follow_up_calendar_projection_test.dart`.
- Preservation tests passed: `task_detail_followup_flow_test.dart`, `follow_up_office_page_test.dart`, and `completed_follow_up_report_page_test.dart`. FollowUp remains available in Task Details, Follow-up Office/Notebook, and Report Center.
- File Persistence #359 / Run `41509339890`: **SUCCESS**. `follow_up_repository_file_persistence_test.dart` and `alarm_overlay_file_persistence_test.dart` passed, including SQLite close/reopen and Snooze/Complete isolation.
- Device Smoke #6437 / Run `41509340280` on the same SHA at checkpoint: Boot SUCCESS; Navigation SUCCESS; Calendar Segmented View IN_PROGRESS; Quick Capture IN_PROGRESS; Task Lifecycle QUEUED; Reminder/Vazirmatn QUEUED; Follow-up Persistence QUEUED. No aggregate PASS is claimed while five lanes lack terminal success.
- Calendar Provider #1342 / Run `41509339317`: IN_PROGRESS at checkpoint; no PASS claim.
- Draft Review APK #12 / Run `41509339894`: the repository's automated review-only staging workflow assembled and verified its staging APK and uploaded the private CI artifact `arvin-review-staging-apk-04cacb3a88a99c12286dd6d8f6a9d0268a0d12eb`. This is not a Release, public publication, or authorization to distribute an APK. No release action was performed.
- Two earlier exact-SHA test runs exposed obsolete historical-FollowUp card expectations in existing tests; those expectations were replaced with positive/negative assertions for the new owner behavior. On SHA `04cacb3...`, all six shards passed. No tests were deleted, skipped, or weakened.
- Documentation-only synchronization follows this checkpoint; re-read the resulting PR HEAD and require fresh exact-HEAD CI before accepting any later SHA.

## 2026-11-02 — Wave 7.292 product roadmap clarification and exact-SHA gate checkpoint

- Preserved the owner's implementation decision for Branch → Project → Task visibility and historical record retention; Home Task-card expand/collapse with exact description/time and a separate Task Details route; latest valid same-Task Follow-up through the real presentation service; and the task-filter strip with «همه» plus Time, Projects, Branch/Center, Categories and Tags.
- Explicitly left expand/collapse behavior for Branch or Project tree nodes undecided unless the product owner makes a separate decision.
- Clarified that the Home card expansion and HomeFollowUpPresentationService changes exist in source history, but acceptance still requires exact-SHA test/device evidence. The remaining Branch/Project/Task structural model and complete five-filter strip remain PLANNED / NOT ACCEPTED.
- Reaffirmed that this documentation update does not complete product work and does not authorize restoring deprecated Next Follow-up or synthetic followUpEnabled.
- Exact-SHA checkpoint for 758edb259b55ecd69b6509e50b94aeadd378e88e: Build run 41451772834 SUCCESS; independent File Persistence run 41451772534 SUCCESS (storage-only evidence); Calendar Provider run 41451772492 SUCCESS; Device Smoke run 41451772497 still IN_PROGRESS at checkpoint, with five lanes SUCCESS, Calendar CANCELLED and Follow-up Persistence without a final result; Review APK run 41451772502 FAILURE and no artifact. These outcomes do not establish full Device Smoke or approved APK.
- Documentation-only change. No product runtime, test, assertion, schema, migration, dependency, main, merge, release, or workflow dispatch change.

# Arvin Changelog

## 2026-11-02 — Wave 7.270 Home and Fast Lane recovery

- Fast Lane validator now decodes the emulator workflow's Base64 shell payload and validates the real `flutter drive` command without removing or weakening emulator execution.
- Home task cards now expand in place, retain a separate Task Details action, and show description plus exact due date/time.
- Home task cards use `HomeFollowUpPresentationService` to display only the latest persisted `task.lastFollowUp`; legacy dates do not create synthetic history.
- Home Bottom Navigation now animates with scroll direction; the Scaffold Quick Capture FAB remains outside that animation.
- Centered Bismillah typography now uses the official Vazirmatn font family.
- Updated Home and workflow contract tests for compact chips, real FollowUp presentation, and decoded Fast Lane validation. Exact-head CI confirmation is pending; these entries do not imply test or release acceptance.


All entries below describe changes on the authorized PR branch. They are not release notes and do not imply release acceptance.

## 2026-11-01 — Calendar filters, all-day handling, and test stabilization

- Updated Calendar selected-day filtering to distinguish All, Unfinished, timed Reminders, and Phone Calendar sources.
- Kept all-day Task entries visible in All and Unfinished, excluded them from the timed Reminder filter, and ordered all-day entries before timed entries in the selected-day list.
- Added widget coverage for the four source filters, all-day inclusion/exclusion, and selected-day ordering.
- Scoped the canonical launcher test's Today label assertion to the primary navigation so the second Today label elsewhere in the page cannot create a false duplicate match.
- Made the Home grouping contract test use a deterministic expanded test viewport rather than relying on a scrollable finder that was not present in the tested tree.
- These changes require fresh exact-HEAD CI confirmation; no test result is inferred from source edits.

## Recent implementation commits recorded on this branch

- `5b04ba94ac6e84837dda333e484072a9a1b817f8` — Calendar selected-day filter invocation and source-filter behavior.
- `329cad47fb570cfb874ae53eaa4cae8980199537` — Calendar widget coverage for the source filters and all-day ordering.
- `92be06603b2ceac62cf77cf064eed51eb71f9a1b` — Changelog synchronization for the calendar all-day/filter correction.

## Governance

- PR #3052 must remain OPEN / DRAFT / UNMERGED. No merge to `main`, tag, release, or APK publication is authorized.
- Issues #823, #2102, and #2299 remain OPEN until their acceptance/evidence conditions are met.
- Release status: **BLOCKED — RELEASE: NO-GO**.
- Vazirmatn is the only approved application UI font; runtime/device verification must be evidenced on the exact candidate SHA.


## 2026-11-02 — Wave 7.272 test-interaction and Device Smoke evidence repair

- Home shell test now asserts the exact current search hint used by the product (including the current «دسته‌ها» wording); no UI behavior was changed to satisfy the test.
- Accordion contract test now scrolls the legacy-only second card into the lazy list viewport before interacting with it, then verifies its Details control exists while no synthetic FollowUp card is rendered from legacy `followUpDate`.
- File-backed Alarm Overlay test now requires the real Complete control to be present, visible and hit-testable before tapping it; the Complete, persistence, reopen and final state assertions remain intact. Added T14a diagnostic marker.
- Device Smoke contract parser now extracts the embedded Base64 shell from the actual pipeline syntax while retaining the exact seven-lane mapping and real `flutter drive` assertions.
- Device Smoke emulator script now writes screenshot output under the absolute GitHub workspace artifact directory, verifies non-zero file size and PNG signature, and logs path/bytes/signature before artifact upload.
- These are source/test/workflow changes only. Acceptance is pending fresh exact-HEAD Build shards, SQLite file-persistence, Parallel Wave and seven-lane Device Smoke with registered non-empty artifacts.

- Added real Home-surface screenshot capture to the Task Lifecycle and Follow-up Persistence integration lanes after their data assertions; each now emits a named screenshot through the host-side integration driver rather than manufacturing an image in the workflow.


## 2026-11-02 — SSOT owner decision and cross-feature architecture audit

- Registered the owner-mandated central SSOT contract for Category, Tag, Project and Branch/Center under Settings Management Hub; all forms, Home shortcuts, search, filters, Reports and Calendar are consumers of canonical data.
- Added the exact-SHA source/data-flow audit matrix at docs/architecture/ARVIN_SSOT_AND_CROSS_FEATURE_DATA_FLOW_AUDIT_2026-11-02.md and Product Spec section 18.
- Recorded current gaps: Category catalog plus Task.category dual representation; non-atomic Category/Tag rename path; Home/editor snapshots without proven global invalidation; Task-only Home search; Reports and Calendar not connected to the complete central taxonomy/Branch model; Branch model/table/store not found in inspected paths.
- Analyzed real File Persistence and Build Shard 2 logs: both pass initial SQLite reopen/readback through T13, then time out waiting for asynchronous Alarm Overlay load completion at T13.5. Exact internal awaited operation remains NOT VERIFIED; Complete tap/handler/final readback were not reached.
- Documentation-only changes. No runtime code, tests, assertions, schema, migrations, dependencies, main, merge, release or workflow dispatch changed. PR #3052 remains OPEN / DRAFT / UNMERGED; BLOCKED — RELEASE: NO-GO.


## 2026-11-02 — Wave 7.292 final validation outcome

- Device Smoke Run 41451772497 on SHA 758edb259b55ecd69b6509e50b94aeadd378e88e is terminal CANCELLED, not PASS.
- Five of seven scenario lanes completed SUCCESS. Calendar Segmented View and Follow-up Persistence both ended CANCELLED during Flutter Drive; both screenshot uploads then failed because no PNG was produced. Cancellation initiator/root cause is NOT VERIFIED.
- Follow-up Device Smoke has no test result; do not substitute the independent File Persistence run 41451772534 (SUCCESS) for it.
- Review APK Run 41451772502 / Job 125298740317 built the staging APK successfully but failed the verification step. Its apksigner output was not surfaced, so the exact failing predicate is NOT VERIFIED and no APK artifact was uploaded.
- Release remains BLOCKED — RELEASE: NO-GO. No acceptance gate is upgraded by these outcomes.


## 2026-11-03 — Home last Follow-up requires a real record

- Home's visible Task-card date and preview remain sourced only from the chronologically latest canonical FollowUp in Task.followUps; a legacy followUpDate or followUpEnabled value no longer supplies a synthetic Home Follow-up.
- The legacyHomeFollowUpDate compatibility accessor now returns only lastFollowUpDate. followUpDate and followUpEnabled continue to round-trip unchanged; no schema, column, migration or stored historical value is deleted or rewritten.
- HomeTodayProjection inherits the same record-only boundary. Added positive/negative projection and Home widget regression coverage, including a reload assertion proving Home rendering does not create a FollowUp record.
- Existing Task Details, Follow-up Office/Notebook, Report Center, Reminder and Due Date paths were not changed. No destructive migration or database compatibility change was made.
- Validation is pending on the resulting exact branch SHA; previous Build/Device Smoke/Calendar Provider outcomes belong to parent SHA db8818c01d9e944717396e3df93bb0a466e92546 and are not evidence for a later commit.
- Governance remains PR #3052 OPEN / DRAFT / UNMERGED; Release **BLOCKED — RELEASE: NO-GO**.


## 2026-11-03 — Home filter bar: no standalone All chip

- Removed only the standalone Home filter-strip chip keyed `home-filter-card-all`. The contextual Time, Projects, Categories and Tags filter cards remain in their approved order.
- Preserved each filter's own unrestricted choice inside its selector: Time “همه”, Projects “همه پروژه‌ها”, Categories “همه دسته‌ها”, and Tags “همه برچسب‌ها”. Each choice clears only its own dimension; it does not reset the other active filters.
- The natural unfiltered Home state remains the default when no filter dimensions are active. Existing global “پاک کردن فیلترها” remains available in the active-filter summary; it is distinct from a standalone All chip.
- Updated Home filter contract tests to assert the absent standalone key, retained per-filter All choices, natural default task display, and independent category clearing while Time remains active.
- No task schema, database record, persistence path, or task data changed. Validation must be reported against the resulting exact SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED; Release **BLOCKED — RELEASE: NO-GO**.


## 2026-11-03 — Wave 7.304 Task Details explicit due-date action
- Added a separate, clearly labeled **«تنظیم موعد برای امروز»** action immediately below the Task Details Due Date row. Tapping this button changes the Task's due date; it does not navigate or alter CalendarPage's selected day. The Due Date row itself remains display-only.
- Wired the action through the existing `TaskMoveToTodayService` and canonical `TaskStore` path. It uses Arvin's existing Iran-local date reference, preserves the existing due time (or uses the current Iran-local hour/minute for an undated Task), and updates only `dueDate` plus `updatedAt`.
- The detail page reloads the returned canonical Task after saving and refreshes the displayed due date. Other Task fields, reminder schedule, checklist, taxonomy and FollowUp history are preserved by the existing service.
- Added a Task Details widget regression covering button placement, explicit tap, Jalali/local-day display, canonical storage reload, preserved due time and unrelated fields. Added a Home regression that completes a task, reopens the app, and verifies the task remains accessible in Archive with its description, checklist and FollowUp history.
- Re-audited Home/Calendar: no independent Home jump-to-today control exists; CalendarPage's `calendar-today` and `calendar-date-jump` controls are retained unchanged. The Home overdue close indicator dismisses only the overdue warning in the current Home state; it does not clear or persistently modify the due date. For a non-overdue task, the same control clears and saves the due date.
- Previous exact-SHA Build on `4eb65a761870422cdbf1aebdd08abd3d4dec523a` failed: Analyze exited 1 with 12 existing info/warning diagnostics (not a Task Details finding); shard test-0 had 201 passed / 1 failed because `home_filter_contract_test.dart` expected missing text `همه مراکز`; shards test-1 through test-5 passed. Device Smoke was still in progress at the checkpoint. Calendar Provider and Draft Review APK completed successfully; review APK artifact exists and is review-only, not releasable.
- New source/test commits through `42f249d64dbfe1c825e3f6207c8b48018c85fc58`. Exact-head CI for this source update and final documentation SHA is required; no PASS is inferred from parent-SHA runs.
- PR #3052 remains OPEN / DRAFT / UNMERGED; `main` unchanged. Release remains **BLOCKED — RELEASE: NO-GO**.

- Follow-up stabilization for the previously failing Home center-filter contract: the test now explicitly scrolls the center filter chip into the visible viewport before tapping it. The assertion for «همه مراکز» and all subsequent filter assertions remain unchanged; no product or Report Center behavior was modified. Exact-head revalidation is required.

- The Task Details action now also falls back directly to `TaskMoveToTodayService` when opened from another feature route that does not inject the Home callback. The action is therefore available on all Task Details entry paths, not only the Home route. Added a fallback-route persistence regression; exact final-head CI remains required.

- Corrected two analyzer findings introduced by the route-fallback regression: the service result is non-null and the test now checks nullable `updatedAt` explicitly before comparing it. No runtime semantics changed; fresh exact-head validation is required.


## 2026-11-03 — Wave 7.304 exact-head verification checkpoint
- Source/test HEAD at this checkpoint: `2ab0bf7ddaa5c1a206cce415d381945311275f30`. A documentation-only follow-up commit will become the new branch HEAD; its exact-SHA workflows must be checked separately.
- The Task Details action is a separate button immediately below the read-only Due Date row. It calls the existing `TaskMoveToTodayService` (Home callback when supplied, canonical service fallback on other routes), which persists through `TaskStore`, uses `IranClock.now()`, preserves an existing due hour/minute, keeps all-day Tasks at midnight, and changes only `dueDate` and `updatedAt`. CalendarPage selection is not involved.
- Due-date action coverage includes button placement, explicit activation, local Iran-day result, canonical persisted reload, preservation of due time and unrelated Task fields, all-day semantics, and the no-callback Task Details route. Home archive regression unmounts/reopens `ArvinApp`, then opens Archive and verifies the completed Task and its description/checklist/FollowUp history remain available.
- Home overdue title and due-date text remain red only; card surface/border and due/status icons remain neutral. Completing an active unfinished Task sets completed+archived before the Home rebuild and persists the full Task via TaskStore; Past is included in the active Home projection and Archive retains the record.
- Home audit: no independent Home calendar jump-to-today control exists. The Home More-menu item «امروز» is a Home time-scope selection, not CalendarPage date navigation, and is retained. No speculative Home control was removed. CalendarPage's `calendar-today` and `calendar-date-jump` controls remain in place and their source file is unchanged in this wave.
- Overdue indicator behavior: the overdue group header's `warning_amber_rounded` is a static icon with no tap handler. The row's neutral close button (`task-card-clear-due-${task.id}`) dismisses an overdue warning in the current Home state only (in-memory map; dueDate unchanged and not saved); for a non-overdue Task, it clears dueDate and saves through the existing path. No Report Center business logic was changed; its RadioGroup migration only preserves existing selection state while using the non-deprecated Flutter API.
- The prior `CenterDeleteBlocked isn't a type` issue is addressed by exporting `CenterDeleteBlocked` from `center_store.dart`; the association test still asserts deletion is blocked. Analyze on this source/test HEAD completed SUCCESS. Six test shards are still running at checkpoint; do not claim shard PASS before terminal results.
- Exact-SHA workflow checkpoint: Build `41593575999` (Analyze SUCCESS; six test shards in progress); Device Smoke `41593575925` (Boot and Navigation in progress; Quick Capture, Calendar Segmented View, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence queued); Calendar Provider `41593576051` in progress; Draft Review APK `41593576139` in progress; Follow-up File Persistence `41593576023` in progress. No APK artifact is yet verified for this SHA.
- Superseded intermediate attempt `e3faf8a7eaa452c28d1a6428c90f9d9633b04efc`: Analyze SUCCESS, but shard test-0 failed in Home filter contract due to an invalid expectation that the single-select category sheet still showed its close tooltip after selecting a category. The test was corrected to target the category RadioListTile and assert auto-dismiss; latest source/test SHA is `2ab0bf7ddaa5c1a206cce415d381945311275f30`. This intermediate failure is not hidden or counted as a final result.
- Release remains **BLOCKED — RELEASE: NO-GO**. PR #3052 must remain OPEN / DRAFT / UNMERGED; main remains unchanged.
