## 2026-11-02 — Local Calendar historical FollowUp exclusion

- Product behavior: historical FollowUp records are filtered at the local Calendar display boundary. IDs with the historical `followup:` and legacy `task-followup:` namespaces are excluded from both supplied and visible-range projected Calendar items.
- Dated Task events, independent dated Reminder events, and recurrence projections remain in the existing Calendar projection. `task-followup-action:` is not filtered by this change.
- FollowUp records, Task Details history, Follow-up Notebook data, Report Center projections, Task storage, Reminder data, Due Dates, and legacy database columns are not modified or deleted.
- Implementation: `lib/calendar_page.dart`; regression coverage: `test/calendar_page_test.dart`, `test/calendar_runtime_actions_fast_track_test.dart`, and `test/calendar_release_acceptance_test.dart`. Existing projection, Task Details and Report Center tests are retained.
- Implementation/test commit: `8533b17599af46524973bc0a366864d44e08c96e`. Documentation synchronization commits follow; exact final branch HEAD and exact-head CI results must be read back before acceptance.
- Release remains **BLOCKED — RELEASE: NO-GO**. PR #3052 must remain OPEN / DRAFT / UNMERGED. No main mutation, merge, APK publication, or release is authorized.

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
