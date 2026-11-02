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
