## 2026-11-04 — Quick Capture compact single-screen layout (UI-only)

- Compressed the existing Quick Capture header, cards, gaps, priority chips and selector controls; aligned «ثبت کار» and «لغو» in one footer row.
- Added opt-in 42dp compact presentation for ArvinRollBox and ArvinTagRollBox; retained their menu choices, selected values, semantics and callbacks.
- Constrained the bottom sheet to 66% of screen height while retaining its inner scroll fallback for short viewports, keyboard and text scaling.
- Kept the existing title and description fields, selector inventory/order, four canonical TaskPriority values, Persian priority labels/helper text, all selection/validation/save behavior and all data field names unchanged. This is **UI-only; no behavior change**.
- Updated focused geometry assertions; no test/assertion was removed, weakened, skipped or bypassed.
- Physical SM-A528B/DS before/after screenshots are NOT VERIFIED; exact-SHA CI is pending after this documentation update.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details reference comparison checkpoint (PR #3052)
- Revalidated exact branch HEAD 940b22f4dc30aef083e5116843ac9457bd1bd37a; PR OPEN / DRAFT / UNMERGED; main unchanged.
- Current TaskDetailPage, _openTaskDetail route and Task model re-read. Model has related people but no dedicated assignee field; people are not an assignee.
- Source confirms repeated due date, priority, category/tags. No runtime cleanup was made because the two named screenshots were unavailable in current conversation and Library search; image-based acceptance remains NOT VERIFIED.
- Exact-head Build run 41819344155 SUCCESS (Analyze + six test shards), focused Task Details tests and RTL/Vazirmatn contracts logged PASS. Follow-up Persistence 41819344361 SUCCESS. Draft Review APK 41819344101 SUCCESS, artifact 13316861010 (review only).
- Calendar Provider 41819344729 and Device Smoke 41819344258 were still running/queued at last poll; Device Smoke was incomplete.
- Detailed audit/backlog: docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md and docs/project-continuity/OPEN_ISSUES.md.
- No tests/assertions weakened/skipped, no main write, merge or release. PR remains OPEN / DRAFT / UNMERGED; Release BLOCKED — RELEASE: NO-GO.

## 2026-11-04 — Quick Capture compact form implementation (PR #3052)

- First exact-head Build exposed a real overflow in the selected priority Dropdown and two legacy custom date/time action-label expectations. The selected state is now text-only (still color-dynamic), and the unified custom date/time action retains the established Persian label; no test or assertion was disabled.

- Reworking the existing `QuickCaptureDialog` rather than introducing a replacement form or persistence path.
- Target UI contract: single-line title; header shortcut to the full Task editor; RTL horizontal Center → Project → Category → Tag row; dynamic colored priority dropdown; one Jalali date + approved circular time control; Reminder and Recurrence; submit-right / cancel-left footer.
- The description field remains in Quick Capture; its visible height is compacted only. Checklist controls are not part of the current Quick Capture field inventory; no existing Quick Capture field is removed.
- Center selection scopes Project choices. A Task's Center relationship is persisted only through its selected canonical Project (`ProjectPlan.centerId`); no `Task.centerId` field or parallel storage is introduced.
- Exact-head widget, Home persistence and Android smoke validation are pending. This entry records implementation scope, not completion.
- PR #3052 remains OPEN / DRAFT / UNMERGED; `main` untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Arvin local calendar lifecycle and read-only external providers

- Startup permission flow now retries idempotent Arvin local-calendar provisioning on every app launch after permission has already been acknowledged.
- Canonical Task create/edit/due-date/complete/archive mutations reconcile their projected reminders into the app-owned local Arvin calendar after the Task database write succeeds.
- Task descriptions are included in provider event revisions; completed, archived, and trashed Tasks are removed from the writable Arvin projection without deleting the canonical Task.
- Outbound provider writes are constrained to the verified app-owned `ACCOUNT_TYPE_LOCAL` Arvin calendar. Google/Samsung calendars remain read-only event sources.
- Legacy links to external calendars are replaced by Arvin-local links without modifying or deleting the external event.
- Removed the Android `ACTION_INSERT` route that could open a generic external calendar as a write destination. The legacy bridge insert now writes through the verified Arvin-local provider path.
- Added unit and Android integration coverage for startup provisioning retry, fixed Arvin destination, external write rejection, archive/description projection, provider CRUD, and Task persistence after provider-event deletion.
- CI, six-lane test evidence, Device Smoke, and a stable Review APK are not yet verified on the final commit. Release remains BLOCKED — RELEASE: NO-GO pending device acceptance.

## 2026-11-03 — Calendar Bridge identity and analyzer correction

- Removed the Task Reminder identity from the native calendar-editor launch payload; opening an existing device event requires only its calendar and event IDs.
- Moved the Reminder identity to the provider ownership-verification payload, where it is required to verify the exact Arvin-owned event.
- Added native-side validation that ownership checks receive an eligible Task/TaskReminder identity before querying Calendar Provider.
- Removed the redundant spread `.toList(growable: false)` and added the required guard braces in the Calendar Bridge.
- The existing Arvin local-calendar provisioning and event CRUD paths were not redesigned by this focused correction.
- Exact-head Analyze, tests, Calendar Provider acceptance and Review APK build are still required. No PASS is inferred from source edits.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Filter regression finder precision

- Scrolled the lazy time-filter list to the «بازهٔ دلخواه» row before asserting its CheckboxListTile.
- Scoped the pre-apply category assertion to the persisted task-card title key, avoiding collisions with the same category label in the filter sheet and task metadata.
- Test-only correction; no runtime behavior changed.

## 2026-11-03 — Filter count assertions

- Scoped count-label assertions to their corresponding top filter chips, because the active-filter summary row intentionally repeats the selected dimension/count.
- No runtime behavior changed.

## 2026-11-03 — Filter CI follow-up

- Converted the range predicate closure to a named local function to satisfy the repository analyzer rule.
- Made widget-test taps target the filter chip/checkbox row directly and scroll into view, avoiding ambiguous or clipped text targets.
- Aligned the bottom-navigation source contract with the approved «خانه» label; no navigation runtime code changed.
- Exact-HEAD Build remains required; this follow-up is test/analyzer hardening only. Release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Filter test alignment and Persian count labels

- Multi-selection counts on the five Home filter chips and active-filter summary chips now use Persian digits, including the Time dimension.
- Updated legacy Home widget tests to toggle CheckboxListTile rows and press the explicit Apply action; ambiguous text finders were replaced with row-scoped finders.
- Added/retained OR-within-dimension and AND-between-dimension assertions for categories and tags, plus Time OR coverage.
- No schema, Task, Reminder, Follow-up, Calendar or navigation behavior changed.
- Exact-SHA Build/Device Smoke/Calendar Provider/File Persistence/Draft APK runs remain the release evidence gate; local Flutter tests not run. Release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Checkbox filter confirmation and unified time ranges

- Added an explicit checkbox row for «بازهٔ دلخواه»; its date/time bounds are draft-only and the single bottom «تأیید / اعمال فیلتر» action commits the selected time options together.
- Time selections, including a custom range, now use OR within the Time dimension. Selecting Past with another time option retains Pending-before-Completed ordering.
- Updated Home filter contract tests from Radio/single-select expectations to Checkbox + explicit confirmation; updated range tests and added a time multi-select OR regression.
- The five RTL Home filter chips retain horizontal SingleChildScrollView. Existing category/tag OR/AND regression tests remain active.
- Local Flutter tests were not run in this session; exact-HEAD CI is required. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Past ordering with multi-select time scopes

- When Past is one of multiple selected time scopes, Home retains a single ordered result group so pending tasks remain ahead of completed tasks; within each status group the canonical priority order remains active.
- This prevents date-bucket regrouping from undoing the Past ordering contract.
- Exact-HEAD CI is pending; no local Flutter SDK. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Home filter Checkbox Multi-Select stabilization

- Fixed stale single-select state references after converting the Home filters to sets.
- Time filter drafts now keep a custom date local to the sheet until confirmation; cancelling date selection no longer creates an invalid selected preset.
- Time-filter removal clears both preset and custom-range state. Existing custom date/time range controls and the «اعمال بازه» action remain available.
- Added widget tests for staged Category selection, OR semantics for Tags, and AND semantics across dimensions.
- Local Flutter tests not run; exact-HEAD CI is required. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Home filter Checkbox Multi-Select standard

- Converted Center, Project and Category filters from single-choice Radio controls to staged Checkbox multi-select. All five Home filter sheets now have an explicit «همه» reset row and «تأیید / اعمال فیلتر» action.
- Time presets are multi-select with OR matching, including Past; custom date selection is a selectable option and custom date/time ranges remain an explicit separate action.
- Center, Project, Category and Tag selections use OR within each dimension; the dimensions are combined by AND. Past keeps pending-before-completed sorting when included.
- Filter chips show the selected value for one choice and the filter name with count for multiple choices. The five-chip strip uses a horizontal SingleChildScrollView.
- Extended short-viewport and time-sheet regression coverage. Local Flutter tests were not run in this environment; exact-HEAD CI is required.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main is untouched; release remains BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit H: archived dependency deletion regression tests

- Added regression coverage proving a completed/archived Task with Follow-up history continues to block Category and Tag deletion.
- Added a SQLite-backed test proving an archived Project still blocks deletion of its owning Center and both records remain intact.
- The existing lifecycle behavior is unchanged; tests cover Active/Archive/Follow-up references without destructive mutations.
- Local Flutter tests not run; exact-HEAD CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit F: refresh exact-HEAD 24-domain matrix and Legacy inventory

- Updated docs/qa/ARVIN_MASTER_SPEC_24_DOMAIN_AUDIT_2026-11-03.md to source SHA 35b5765a7964c063b01a5ef3366836064decc751, including the filter OR fix, Calendar Task Details routing/export-only swipe, safe template preservation test, report P1-P4 output grouping, and five-item navigation.
- Added docs/qa/ARVIN_LEGACY_REFERENCE_INVENTORY_2026-11-03.md with direct model, Schema, Store, migration, repository/service, UI, report, Work Agenda, Next Action and test/fixture references.
- Confirmed Task.followUpEnabled/followUpDate and FollowUp.nextFollowUp/reminderDate remain active compatibility data; Task.reminderDate is still consumed by Editor/Work Agenda/Next Action/Calendar/Report. FollowUp.completedAt remains a getter alias to dateTime; no follow_ups.completed_at column exists.
- No legacy data, columns, or runtime fields were deleted. No migration was executed. Backup/Rollback and migration plan are documented.
- CI checkpoint on source SHA 35b5765a7964c063b01a5ef3366836064decc751: Analyze PASS; Build test shards IN PROGRESS; Follow-up File Persistence SUCCESS; Calendar Provider failed due Gradle Plugin Portal inability to resolve Kotlin 2.2.21 artifacts; Device Smoke queued/in progress; Draft Review APK in progress. These are not release acceptance.
- Documentation-only Commit F. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit G: Canonical five-item navigation labels

- Renamed the visible Home destination from «امروز» to the owner-approved «خانه».
- Corrected the navigation regression test to assert exactly five visible destinations: خانه، تقویم، دفترچه، گزارش‌ها، بیشتر; the separate Next Action route remains outside the bottom bar.
- No routing/storage behavior changed. Local Flutter tests not run; exact-HEAD CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit E2: Exact-SHA analyzer corrections for Reports and Template tests

- Added the canonical Task model import to the Project Template regression test so TaskReminder and FollowUp preservation assertions compile.
- Removed the obsolete Priority-filter argument from the Report Center filter test; priority remains a report grouping/sort dimension, not a filter criterion.
- Added the Task model import to the grouped text-report test and removed an unnecessary interpolation brace flagged by Analyze.
- No product data/schema behavior changed. Local tests not run; exact-HEAD CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit E1: Report text numbering correction

- Corrected the first item index in priority-grouped plain-text reports; the counter is incremented once and rendered without an extra offset.
- This is a focused correctness follow-up to Commit E. The report grouping remains P1→P4 and stable within each group.
- Local tests not run; exact-HEAD Build CI required. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit E: Report Center priority grouping and filter contract

- Removed the existing standalone Priority filter from Report Center and TaskReportFilter; priority is no longer a report-selection criterion.
- Added canonical P1→P4 groups to the shared TaskReport projection. PDF/Print and plain-text copy/share now render the same priority-group order while preserving input order inside each group.
- TaskReportEntry now carries canonical Task priority; PDF continues to load bundled Vazirmatn regular/bold fonts and RTL page direction.
- Added projection and plain-text regression tests for P1/P2/P3/P4 grouping and a Report Center assertion that no Importance filter is exposed.
- Structured machine-readable export and full Print/Share end-to-end validation remain NOT VERIFIED. Local Flutter tests were not run; exact-HEAD CI required.
- No Task/Reminder/Follow-up data or schema changed. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit D: Safe Mid-Cycle Project Template preservation test

- Extended the real SQLite/Drift propagation test with a completed and archived existing Task carrying a Checklist, independent Reminder and historical Follow-up.
- The test now verifies all existing state/history and project membership survive propagation, while only the new template Task is appended and repeated propagation remains idempotent.
- Runtime propagation implementation was not changed; the existing transactional append-only path remains the only write path.
- Local Flutter tests were not run; exact-HEAD Build CI must validate the stronger test. main untouched; PR #3052 OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit C1: Calendar routing analyzer cleanup

- Removed the unused Follow-up helper, added the Follow-up action reminder namespace to canonical parent-Task routing, and fixed the analyzer-required control-flow braces.
- This follow-up is based on exact analyzer evidence from Build run 41618701405 on Commit C: the only analyzer findings were the unused helper and missing braces.
- The Follow-up action card remains non-exportable by swipe; the new prefix is recognized only for opening the owning Task Details.
- Exact-HEAD CI is required after this correction. No data/schema changes; main untouched; PR remains OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit C: Calendar Task Details routing and export-only swipe

- Calendar Task and Follow-up card taps now resolve the owning canonical Task and call the Task Details route; Edit remains available from the explicit Details action only.
- Calendar long-press no longer exposes Task/Follow-up Edit. Calendar horizontal swipe now performs only explicit Device Calendar export for eligible Task records; legacy edit/trash swipe settings decode to no action and are no longer offered in Settings.
- Added direct CalendarPage tap assertions, launcher-to-canonical-Task resolution coverage, and legacy swipe-setting retirement tests.
- Local Flutter tests were not run in this environment. Exact-HEAD CI must validate the new routing and settings behavior.
- No Task/Follow-up data or schema changed. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Commit B: Home filter semantics and five-filter coverage

- Home active-filter state now includes Center, so clear-filter affordances remain visible when Center is the only active filter.
- Home multi-select Tags now use OR semantics through the pure homeTaskMatchesAnySelectedTag matcher; independent filter dimensions remain AND-combined.
- Updated Home filter regression coverage to include the fifth Center control and the compact viewport.
- Added focused unit tests for OR matching and the empty-selection behavior. No persistence/schema behavior changed.
- Local Flutter tests were not run in this environment; exact-HEAD Build CI is required before treating the change as accepted.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

## 2026-11-03 — Exact-SHA 24-domain architecture/product audit

- Added docs/qa/ARVIN_MASTER_SPEC_24_DOMAIN_AUDIT_2026-11-03.md, audited directly against PR branch HEAD 469f9a5b0140bb69f6f415e1ad8ad0eee28e2983.
- The matrix records 24 owner-acceptance domains with conservative statuses, direct source/test paths, and exact-SHA CI evidence. Prior audit documents on older SHAs remain historical only.
- Confirmed active legacy references in Task/FollowUp models, Drift schema, TaskStore and Task editor. No legacy column or user data was deleted or rewritten.
- Recorded immediate independent corrections for the next code slice: Home multi-tag OR semantics and the missing Center contribution to Home active-filter state. Calendar card Tap currently routes Task/Follow-up records to Edit callbacks rather than Task Details.
- Exact-SHA evidence: Build 41614740315 Analyze + six test shards SUCCESS (APK matrix SKIPPED); Calendar Provider 41614740147 SUCCESS; File Persistence 41614740328 SUCCESS; Draft Review APK 41614740340 SUCCESS (review-only); Device Smoke 41614740157 remains IN PROGRESS with four lanes PASS, two IN PROGRESS and one QUEUED at checkpoint.
- Documentation-only Commit A. No product runtime, tests, schema, migration, dependency, main, merge, release or APK publication changed. PR #3052 remains OPEN / DRAFT / UNMERGED; release remains BLOCKED — RELEASE: NO-GO.

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


## 2026-11-03 — Priority contract audit on exact PR HEAD ec59d91

- Audited the live branch source without rewriting the existing priority implementation. New Task model default, Task Editor initialization, and Quick Capture initialization all use P2 / TaskPriority.medium; Quick Capture resets to P2 after successful save.
- Legacy JSON decoding preserves high→P1, medium→P2, low→P3, none→P4. Missing/unknown legacy values continue to fail soft to P4; this is intentionally distinct from the P2 default for newly created Tasks. P1/P2/P3/P4 colors remain red/blue/amber/grey.
- Canonical Task ordering uses P1→P4. Past ordering puts incomplete Tasks before completed Tasks, then orders within each completion group by priority and due date.
- Exact-HEAD Build run 41625892691: Analyze SUCCESS; test-0 and test-5 FAILED on three unrelated Calendar interaction assertions; test-1 through test-4 SUCCESS. The priority compatibility test, P1→P4 report grouping test, Past incomplete-first sort test, Quick Capture P2 default test, timed auto-reminder test, and manual-reminder independence test all logged PASS. No 44px chip-overflow signature appeared in the six shard logs; the specific 44px visual regression remains NOT VERIFIED because no dedicated reproducer/result was located.
- No priority production code, test assertion, scenario, or timeout was changed. The current Build is not green: calendar Task Details finder (test-0), calendar card action count, and repeat-occurrence canonical Task action (test-5) failed. Draft APK job was skipped by the Draft guard. Device Smoke run 41625892658 was QUEUED and Calendar Provider run 41625892940 was IN_PROGRESS at this checkpoint; Follow-up File Persistence run 41625892728 completed SUCCESS. These results are exact-head only and must not be transferred to a later SHA.
- Iran timestamp: 1405/08/12 14:49 (Asia/Tehran). PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; Release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-03 — Calendar acceptance root-cause corrections (PR #3052)

- Exact pre-fix SHA audited: `1fe99ebd9cf8eac084727f0507f1398ad4806240`. Build #9339 Analyze passed; test-0 and test-5 failed; test-1..4 passed. Device Smoke #6591: navigation and boot passed, other five lanes cancelled before completion. Calendar Provider #1490 was still in progress at last poll. Follow-up Persistence #513 passed. Draft Review APK #166 created and uploaded review-only staging APK artifact `13226856769` (33,032,076 bytes; SHA-256 artifact archive digest `58adf123e9504d959be38a3615e730c6ad20873796ae1509e6312bcc43b6c7b9`); workflow later concluded CANCELLED after the build/signature/package/Vazirmatn verification and upload steps had succeeded. This artifact belongs only to the old SHA and is not the final candidate.
- Root cause A (Task Details key missing): `OfficialCalendarPage` selected `snapshot.data` as the complete Calendar reminder list. When optional official/provider load returned an empty list, it replaced and discarded canonical Task reminders supplied by the launcher. CalendarPage logs showed `incomingReminderIds=[]` on the failing screen. Fixed by merging provider/official rows with canonical rows by stable ID, keeping canonical rows authoritative.
- Root cause B (expected 2 card opens, actual 1): test log showed the second `task-due` card was rendered at Offset(398,312), outside the test viewport; `tester.tap` emitted a hit-test warning and did not invoke its callback. Fixed the test to ensure the card is visible before tapping and assert the callback count increases for each individual card. No production behavior change for this issue.
- Root cause C (repeat occurrence not resolving to canonical Task): the test tapped a card but supplied only `onEditTask` and expected that callback, while the approved product contract is card tap → Task Details. Updated the regression test to supply and assert `onOpenTask` receives the exact original Task. Added the explicit long-press `ویرایش کار` action using the existing canonical `onEditTask` callback; this keeps Details as the tap behavior and edit as a separate explicit action.
- Added a short 320×520 logical-pixel RTL Report Center test with multiple active category/tag/status chips. It asserts six active chips and no Flutter layout exception. This is a reproduction guard only; until the new test runs and the historical 44px defect is specifically reproduced or its absence is established on the intended environment, the reported 44px issue remains **NOT VERIFIED**. No speculative chip layout changes were made.
- Calendar swipe behavior was not changed: configured Swipe export remains the explicit transfer to the phone calendar; card tap continues to open Details. No priority/Quick Capture implementation was changed.
- Code/test commits: `b640393` (merge canonical and optional Calendar rows), `f8aed94` (explicit Task edit action), `9501f1e` (canonical Details key), `004cc0f` (per-card tap hit-test), `86f2493` (short RTL chip viewport regression test). Full final-SHA validation is pending after documentation synchronization.
- PR remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.


## 2026-11-03 — Owner-approved Triple-Track Calendar architecture and exact-head recovery

- Recorded the product-owner decision: (1) Arvin SQLite is the canonical source for Tasks, P1–P4 priorities, categories and centers; (2) the dedicated Android Local Arvin Calendar Provider is the Arvin-owned system calendar and synchronizes Arvin Task create/update/delete; (3) third-party phone calendars are read-only projections inside Arvin. Their content/time/deletion remains owned by the source app unless the user explicitly imports an event as an independent Arvin Task.
- Interaction contract: tapping an Arvin Task/Follow-up card opens only canonical Task Details. Editing is initiated only by the explicit Edit action inside Task Details. External calendar items open in their source calendar; explicit «ثبت در آروین» remains the import path. Task-to-device-calendar transfer remains an explicit configured swipe action.
- On SHA 681251338c226f6db40bac7d9decde36c1c64d97, Build #9344 / run 41628236149 failed: Analyze PASS; test-0, test-1, test-2, test-3 PASS; test-4 and test-5 FAIL; ordinary APK matrix SKIPPED by the Draft guard. The two failures both found an unintended Task Edit action in the Calendar long-press sheet, contrary to the owner-approved Details-only edit route. The repeat-occurrence-to-canonical-Task assertion passed in test-5.
- On that same SHA, Calendar Provider #1495 / run 41628236109 SUCCESS: real emulator CREATE, NO-OP UPDATE, duplicate prevention, UPDATE on the same event ID and DELETE all PASS. Destination migration remains limited to one writable calendar. Evidence artifact 13226554993, 11,211 bytes, SHA-256 ff8bc22074718450c9ed8cb02c9888d23d7fa219431dfc04bf6cf10cca2c4288.
- Follow-up File Persistence #518 / run 41628236070 SUCCESS. Draft Review APK #171 / run 41628236095 SUCCESS: non-debuggable staging APK, signature/package/debuggable/Vazirmatn checks PASS; artifact 13226239078, 33,031,127 bytes, SHA-256 bbc79528f72843e0ad32f10c506b1ace1722caa37b64b838923f43ae2b8b4e51. Ephemeral test key; review-only, not publishable. APK Matrix remains skipped while Draft.
- Device Smoke #6596 / run 41628236041 was not a complete acceptance: Boot, Navigation, Quick Capture and Task Lifecycle PASS; Reminder/Vazirmatn and Follow-up Persistence CANCELLED; Calendar Segmented View was still running at the last inspection. No seven-lane PASS is claimed.
- Targeted correction: commit a39d9dc9d10a786f69d64f40e8f3c72f6f1c43b0 removed the Task Edit entry from Calendar long-press actions. A transient Analyze failure on that intermediate commit exposed an accidental removal of the public CalendarPage onEditTask API; commit ad11694546ed79391df27a4890b635542693f50b restored the public API while keeping the long-press Edit action absent. No assertion was removed or weakened.
- Added a Home-page short-viewport regression guard in commit f96d6f2833be7a51b73fdbb7b4484dd1a1ddb0a8: 320×520 logical viewport, RTL, five actual Home compact filter controls, horizontal scrolling and no Flutter layout exception. The separate Report Center chip-wrap test passing does not prove Home-page behavior. Historical 44px overflow remains NOT VERIFIED until this exact Home test and visual/device evidence complete.
- Exact-SHA validation for f96d6f2833be7a51b73fdbb7b4484dd1a1ddb0a8 was started: Build #9347 / run 41631273704; Device Smoke #6599 / run 41631273582; Calendar Provider #1498 / run 41631273728; Follow-up File Persistence #521 / run 41631273652; Draft Review APK #174 / run 41631273631. These were pending/in progress at documentation time; no result transfers from earlier SHAs.
- Priority and Quick Capture production logic were not rewritten. PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; no merge/release. BLOCKED — RELEASE: NO-GO.


## 2026-11-03 — Production ownership boundary caveat for Calendar Track 2

- Read-only source audit of `lib/services/calendar_provider_sync_executor.dart` and `lib/services/system_calendar_bridge.dart` found the current outbound executor requires an explicit `targetCalendarId` and performs provider CRUD against that selected system calendar. The native bridge also explicitly opens phone-owned events in the source calendar app rather than editing their contents inside Arvin.
- The Android `CalendarProvisioner` acceptance module provisions `ARVIN CI Acceptance` (test account/calendar) for instrumentation. Its CREATE/NO-OP UPDATE/UPDATE/DELETE PASS proves Provider CRUD in the CI acceptance environment; it does not prove that the production app provisions and owns a dedicated persistent Local Arvin Calendar Provider.
- Accordingly, Track 3's source-app ownership boundary is supported by the read-only/native-editor path and explicit Import action. Track 2's required dedicated production Arvin calendar and automatic Task lifecycle synchronization remain **NOT VERIFIED**. Do not promote Provider acceptance to full Track-2 product acceptance. A separate production provisioning/lifecycle design and exact-device evidence are still required.


## 2026-11-03 — Latest exact-head pipeline checkpoint (documentation baseline deaf50aa9ba380812f611d38e993d9d14b2388dd)

- PR #3052 HEAD at checkpoint: `deaf50aa9ba380812f611d38e993d9d14b2388dd`. PR OPEN / DRAFT / UNMERGED; base `main`; main HEAD remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- Build #9350 / run `41631777717`: workflow IN_PROGRESS at last poll; Analyze and all six test shards were IN_PROGRESS; ordinary APK matrix SKIPPED by the Draft guard. No shard result is claimed.
- Device Smoke #6602 / run `41631777262`: preparation SUCCESS; Boot and Navigation IN_PROGRESS; Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View, Quick Capture and Task Lifecycle QUEUED. Seven-lane result NOT VERIFIED.
- Calendar Provider #1501 / run `41631777653`: IN_PROGRESS; no final artifact/result available at checkpoint.
- Follow-up File Persistence #524 / run `41631777208`: SUCCESS on this exact SHA.
- Draft Review APK #177 / run `41631777254`: IN_PROGRESS; no artifact available at checkpoint. Do not reuse older-SHA APK artifacts as candidate evidence.
- Calendar acceptance tests on earlier SHA 681251338c226f6db40bac7d9decde36c1c64d97: Task Details callback/key test PASS and repeat-occurrence canonical Task test PASS. The per-card action-count assertion was not reached because the same test stopped earlier on the unexpected long-press Edit entry; therefore action-count acceptance remains NOT VERIFIED until the corrected exact-head Build finishes.
- The Home-specific 320×520 RTL test was added, but the f96d6f2 run was cancelled when documentation commits superseded that SHA. It has no terminal result yet. Historical 44px overflow remains NOT VERIFIED.
- Production Track 2 remains NOT VERIFIED: current outbound sync accepts a selected `targetCalendarId`; the `ARVIN CI Acceptance` provisioner is a test fixture, not proof of a dedicated production Arvin-owned Android calendar. Provider CRUD acceptance must not be described as full production Track-2 acceptance.
- The next documentation-synchronized HEAD will require its own exact-SHA Build, seven-lane Device Smoke, Provider, Persistence and Draft Review APK checks. No result above transfers to that new SHA.


## 2026-11-04 — Project continuity deployment and exact-HEAD checkpoint

- Established the durable project continuity index under docs/project-continuity/: README, CURRENT_STATE, PRODUCT_DECISIONS, ROADMAP, OPEN_ISSUES, IMPLEMENTATION_LOG and HANDOFF. These files supplement the root AI context, this changelog and the existing continuation ledger; they do not replace historical records.
- Current app/source baseline inspected before this documentation-only sequence: 33f9489b4c7f3fa6173459b6994cea2a5469f500. PR #3052 OPEN / DRAFT / UNMERGED; main unchanged.
- Build run 41805555476 SUCCESS on 33f9489; Analyze and all six test shards passed. APK matrix SKIPPED by Draft guard.
- Follow-up File Persistence run 41805555397 SUCCESS on 33f9489.
- Calendar Provider run 41805555462 FAILED before test execution because Dart Development Service failed to start while loading android_calendar_provider_acceptance_test.dart; zero tests passed. This is a runner/execution blocker, not a product-behavior failure result.
- Device Smoke run 41805555579 was QUEUED at last poll; Boot and Navigation succeeded, Quick Capture and Calendar Segmented View were in progress, remaining lanes queued. No seven-lane PASS is claimed.
- Review APK run 41805393577 was CANCELLED on older SHA b85ed7b6ac5140e877ce1bd0ece6eef2d4819b43; not current-head evidence.
- SHA transition 93a7c2b → ec4f23e contains exactly one commit, ec4f23e9a3745f1c924f8f75d84e0b943591a1d2. Build 41797850701 succeeded on ec4f23e; Device Smoke 41797850589 was CANCELLED.
- Quick Capture currently displays inline empty-title feedback plus a floating SnackBar, matching the existing two-occurrence test. One-versus-two-message UX remains awaiting explicit owner decision; no test was weakened.
- P2P QR/PIN pairing and LWW/tombstones are design proposals only. Device-local clock winner selection is not approved.
- Release remains **BLOCKED — RELEASE: NO-GO**. See docs/project-continuity/CURRENT_STATE.md and docs/project-continuity/HANDOFF.md for the current operating checkpoint.


## 2026-11-04 — Device Smoke terminal result correction
- Device Smoke run 41805555579 on source SHA 33f9489 concluded CANCELLED. Preparation, Boot, Navigation and Quick Capture succeeded; Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View and Task Lifecycle were cancelled. No seven-lane PASS is claimed.
- The earlier queued/in-progress observation in this checkpoint is superseded by this terminal result. A fresh full run is required on the latest candidate SHA.


## 2026-11-04 — Parallel UI scope reconciliation (owner directive)

- Audited exact branch HEAD `957924cd67066db06abe5fd15df2c802729aa3bb` before making changes.
- Report Center already has no independent top-level completed-Follow-up action; the report is selected inside the unified Filters sheet (`report-filter-type-completed-follow-ups`). Existing widget coverage asserts the obsolete top-level key is absent and exercises the unified path. No duplicate control was introduced.
- Home's five top filters in RTL order are already Time → Center → Project → Category → Tags (`home-filter-card-time/center/project/category/tags`). Default labels are dimension names; no standalone «همه» chip is rendered. Existing filter sheets retain their internal reset/apply behavior; that is not a top-bar chip.
- Quick Capture already uses the compact single-line title, full-form shortcut, RTL Center → Project → Category → Tag row, priority/date-time/reminder/recurrence controls and submit/cancel actions. Empty-title behavior remains inline error + SnackBar; no test or assertion was changed. No description/checklist fields are exposed in this compact form.
- These requested UI behaviors were already present at the audited HEAD, so no redundant runtime edits were made. This is a source reconciliation, not a claim that the physical-device visual review is complete.
- Exact-head Draft Review APK run `41807761597` on the same SHA completed SUCCESS; artifact `13311083215` (`arvin-review-staging-apk-957924cd67066db06abe5fd15df2c802729aa3bb`) is available and not expired. It is a review/staging APK, not a production release APK.
- Exact-head Build run `41807761390`: SUCCESS (Analyze and six test shards); APK matrix SKIPPED by Draft guard. Calendar Provider run `41807761328`: SUCCESS; Follow-up Persistence run `41807761334`: SUCCESS. Device Smoke run `41807761329` has not reached a verified terminal seven-lane conclusion at this checkpoint; partial lane results are not overall acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Local P2P Phase 1 design specification (ARVIN-EXEC-1405/08/14-LOCAL-P2P-SYNC)

- Added `docs/project-continuity/LOCAL_P2P_SYNC_SPECIFICATION.md` as a Phase 1 design-only specification for direct local Wi-Fi / hotspot synchronization between explicitly paired Arvin devices.
- Pairing UX records the requested one-time QR or four-digit PIN paths. The document explicitly treats a four-digit PIN as low entropy and requires short expiry, strict rate limiting, authenticated encrypted key establishment, peer confirmation and security review; QR/PIN alone is not treated as secure authentication.
- Defined privacy boundaries, no Internet/cloud/relay dependency in Phase 1, and a separate deferred Cloud/Dropbox Phase 2.
- Documented canonical entity boundaries, a conceptual versioned operation envelope, durable journal, idempotent receive/apply, acknowledgement/cursor rules, transactional writes, non-destructive SQLite/Drift migration, conflict visibility, revocation, retry/resume and two-device acceptance criteria.
- No application source code, database schema, tests, workflow configuration, font assets or runtime behavior was changed. No test was removed, weakened or skipped. Vazirmatn remains the official font.
- QR/PIN cryptography, discovery/transport implementation, exact schema and conflict algorithm remain design decisions requiring security/technical review. Local P2P implementation and physical acceptance remain NOT VERIFIED. LWW, tombstone policy and device-clock winner selection are not approved by this document.
- Starting branch HEAD: b299c5ccddf9123a661e8a5c52dc3b0548265d35. This is a documentation-only commit; all existing CI/device evidence remains bound to its original SHA and must not be transferred to the new documentation SHA.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details UI reference audit (PR #3052)
- Exact audited source SHA: 0f2977a26d76fbe301b27aef05270b2d7568f4d2. PR #3052 remains OPEN / DRAFT / UNMERGED; main remains unchanged.
- Identified `TaskDetailPage` in `lib/task_detail_page.dart` and `_openTaskDetail` route in `lib/main.dart`.
- Source audit confirms repeated priority and due-date presentation, repeated category/tag metadata, a fixed bottom action bar, canonical due date, independent TaskReminders, Follow-up history, multiline description editing, and related people distinct from any assignee concept.
- No dedicated assignee field was found in the inspected Task model; do not infer assignment from `Task.people`.
- Two user-referenced screenshots were not available to inspect in this audit input. Pixel-level comparison and exact reference conformity remain NOT VERIFIED. No speculative runtime UI changes were made.
- Exact-SHA Build run 41815969951 SUCCESS (Analyze and six test shards); focused Task Details tests logged PASS. APK matrix SKIPPED by Draft guard. Provider run 41815969715 SUCCESS; Follow-up File Persistence run 41815969772 SUCCESS; review-only APK run 41815969817 SUCCESS (artifact 13314402997).
- Device Smoke run 41815969732 was incomplete at last poll: Calendar Segmented View job 126526712495 remained IN_PROGRESS after the other six lanes succeeded. Do not claim seven-lane acceptance.
- Full audit and staged plan: `docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md`. Continuity snapshot refreshed in `docs/project-continuity/CURRENT_STATE.md`.
- No test or assertion was deleted, weakened, skipped or bypassed. No main write, merge or release. Release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details UI alignment
- Reorganized Task Details around a compact title/status/priority summary, separate description card, RTL metadata order, conditional template source and a single due-date card.
- Consolidated status and priority and removed P1–P4 code labels from this page; preserved all existing task actions and lower feature sections.
- Added bottom scroll clearance for the fixed action bar and focused widget tests for RTL ordering, due-date uniqueness, related-person semantics and bottom actions.
- No Task model, storage schema or migration was changed. The model has no execution-time or independent assignee field; related people are not assignees.
- Actual screenshot and pixel-level visual acceptance remain NOT VERIFIED. Exact-SHA CI is pending; PR remains Draft and release NO-GO.


## 2026-11-04 — Exact-SHA CI failure and review APK evidence (a85145de7be4b0d23854e320885f665d50eb35cc)
- Build run 41823721080: FAILURE. Analyze failed at lib/task_detail_page.dart:1158:30 with unnecessary_string_interpolations. APK matrix was SKIPPED by the Draft guard.
- Test shards: test-4 SUCCESS; test-0, test-1, test-2, test-3 and test-5 FAILURE. Do not report the suite as passing.
- Task Details evidence from task_detail_master_screen_test.dart: PASS — clone action invokes canonical handler; title and multiline description save inline; summary/metadata/due date appear once in RTL order; related people are not presented as assignees and bottom content remains clear.
- Task Details failures: independent Reminder toggle could not find key task-detail-reminder-reminder-toggle-1 (line 83); ordinary-task smart visibility could not find task-detail-add-reminder (line 110); rich-section visibility could not find task-detail-independent-reminders (line 163). Related checklist failures: task_detail_checklist_flow_test could not find task-detail-checklist (line 29), and task_detail_checklist_crud_test could not find task-detail-add-checklist (line 72). These are real assertion/finder failures, not skipped tests.
- Related Task Details flow failures: add Follow-up key task-detail-add-followup absent (task_detail_followup_flow_test lines 58 and 193); existing FollowUp edit path raised StateError: No element in ensureVisible at line 252; Today action vertical-order assertion expected >520.5 but observed 478.0 (line 403; same 478.0 vs >520.5 in task_detail_due_date_action_test line 62).
- Calendar Provider run 41823721063: SUCCESS; artifact 13318164013.
- Draft Review APK run 41823721031: SUCCESS; artifact 13317704369, 38,206,200 bytes ZIP. Extracted review APK: 76,806,159 bytes, SHA-256 f3f3efdf74bff2b239f24145c69bbd98fbcf2ac0e2f3bb043e70c6f8d9dcea57. Manifest: applicationId com.example.arvin.staging, android_debuggable=false, v2/v3 signature verified, ephemeral test-only signing key, publishable=false, release_created=false. Review/install testing only; not a production/release APK.
- Device Smoke run 41823721013: still incomplete at last poll. Boot, Navigation, Quick Capture and Task Lifecycle SUCCESS; Reminder/Vazirmatn and Calendar Segmented View IN_PROGRESS; Follow-up Persistence QUEUED. No seven-lane PASS.
- No tests/assertions were modified, removed, weakened, skipped or bypassed during this audit. No timeout workaround was applied. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.
