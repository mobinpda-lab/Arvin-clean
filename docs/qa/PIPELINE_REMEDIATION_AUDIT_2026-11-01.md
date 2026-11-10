# Pipeline Remediation Audit — 2026-11-01

## Scope and governance

- Arvin repository: `mobinpda-lab/Arvin-clean`
- Arvin branch: `fix/recovery-calendar-device-smoke-2026-10-31`
- Baseline SHA inspected before edits: `1730de18cc9fbe887f76c9fc16931de0b8c9877d`
- NIRA repository: `mobinpda-lab/NIRA`
- NIRA main SHA inspected: `7a27ee63b65d343e45c5786f782f2567611722dc`
- PR #3052 remains Draft/Open and unmerged; Issues #2102 and #823 remain Open.
- No main-branch change, merge, release, or production-signing action is authorized by this work.

## Arvin changes made on the PR branch

1. `.github/workflows/device-smoke.yml`
   - Updated Reminder compatibility and screenshot-upload conditions to use the actual seven canonical matrix identifiers.
   - Reminder legacy compatibility tests now run for `smoke-reminder-vazirmatn`.
   - Calendar interaction evidence is eligible for both calendar-related lanes because both currently execute the same combined Calendar integration test.
   - All seven jobs continue to use the single `TARGET_SHA`, check out that exact SHA, and fail on checkout mismatch.

2. `test/device_smoke_workflow_contract_test.dart`
   - Replaced stale legacy-matrix expectations with an exact seven-entry scenario-to-test mapping.
   - Retains assertions for the shared target SHA, checkout ref, actual checked-out SHA, and mismatch fail-closed behavior.
   - Checks that lane-specific conditions use current canonical identifiers.

3. `integration_test/calendar_card_interaction_test.dart`
   - Added bounded route-readiness waiting, runtime diagnostic output, and an early screenshot before the strict SegmentedButton assertion.
   - Keeps the direct `calendar-view-mode-control` / weekly option assertions strict.
   - `calendar-selected-day-list` is now only asserted structurally; scrolling resolves the Scrollable ancestor of the actual reminder card.
   - The source route is `CanonicalCalendarLauncher → IranianOfficialCalendarPage → CalendarPage`; the weekly SegmentedButton is unconditionally built in CalendarPage. The earlier runtime failure still needs a new emulator run and screenshot/log evidence to establish its precise runtime cause. No root cause is claimed yet.

4. `.github/workflows/build.yml`
   - The ephemeral Staging signing password is randomly generated and masked before being exported to later steps.
   - Staging verification now records the apksigner exit code and v1/v2/v3 results independently, records the signer certificate SHA-256 when available, and records APK debuggable status separately.
   - Raw apksigner output and a per-check JSON audit manifest are written even when a verification assertion fails.
   - An Staging APK audit-candidate artifact is uploaded whenever the APK exists, regardless of verification outcome. It is not a release artifact and remains non-publishable unless every required check passes.
   - The verification log/manifest artifact is uploaded with an always-run condition. No keystore or private key is included in artifacts.

## Canonical seven-lane interpretation

| Lane | Integration test |
|---|---|
| `smoke-boot` | `integration_test/android_home_smoke_test.dart` |
| `smoke-navigation` | `integration_test/android_people_smoke_test.dart` |
| `smoke-calendar-segmented-view` | `integration_test/calendar_card_interaction_test.dart` |
| `smoke-quick-capture` | `integration_test/android_quick_capture_smoke_test.dart` |
| `smoke-task-lifecycle` | `integration_test/android_backup_restore_sql_smoke_test.dart` |
| `smoke-reminder-vazirmatn` | `integration_test/calendar_card_interaction_test.dart` |
| `smoke-follow-up-persistence` | `integration_test/android_sql_persistence_smoke_test.dart` |

The Calendar and Reminder lanes intentionally reuse one combined test file at this point; they are not independent suites. The Reminder lane additionally runs the Reminder legacy compatibility tests. The APK font audit verifies Vazirmatn asset packaging, not pixel-perfect runtime font rendering.

## Pre-remediation CI evidence (baseline SHA only)

The following results belong to baseline `1730de18cc9fbe887f76c9fc16931de0b8c9877d`; they must not be attributed to later commits:

- Device Smoke: 6/7 lanes succeeded; `smoke-reminder-vazirmatn` failed at the strict finder for `calendar-view-mode-control`.
- The failed runtime log reported zero widgets for that key at `integration_test/calendar_card_interaction_test.dart:130`.
- Quality Shard test-2 reported 257 passing tests and one failing workflow-contract test because it still expected `run_calendar:`.
- `test/task_detail_checklist_crud_test.dart` itself passed on the baseline run, including Add/Edit/Delete and legacy follow-up timestamp preservation.
- Staging APK build step succeeded, but the verification step failed before emitting usable apksigner/manifest evidence. The prior step used early-exit shell behavior, so the raw verification output was not preserved as an artifact.
- Debug and Release APK artifacts existed, but they do not prove Staging v2/v3 signing or Staging manifest validation.

## NIRA finding — no code change made

The failed NIRA Queue Scheduler run `41270962280` attempted to create a dispatch marker comment on Issue #162 and received GitHub HTTP 403:

`Commenting is disabled on issues with more than 2500 comments`.

The inspected workflow chain confirms that comments are not merely notifications:
- `.github/workflows/nira-queue-scheduler.yml` reads comments for active leases, prior handoffs, provider feedback, and pending dispatch markers; it writes dispatch, recovery, and handoff markers.
- `.github/workflows/nira-lease.yml` validates the scheduler's pending marker from comments, records acquired lease identity/fence/expected client main SHA/TTL in comments, and writes consumed/failed handoff markers.
- `.github/workflows/nira-recovery-sweep.yml` reads acquired lease comments to recover lease identity, target repository, expected SHA, and TTL, and writes recovery/handoff markers.

The existing workflow permissions include `issues: write` and `actions: write`, but `contents: read`. The current code does not establish a durable, atomic, append-only alternative to the comment ledger. A scheduler-only substitution would leave the Lease and Recovery workflows unable to authenticate or reconstruct the handoff and lease provenance. Issue labels alone do not carry the required lease ID, fencing token, expected client SHA, and TTL.

Accordingly, no NIRA branch or code change was created. The safe next design must select and document a durable ledger with atomic/idempotent update semantics, then migrate Scheduler, Lease, Recovery, and downstream handoff readers together. No comment was posted to Issue #162.

## Validation status after these edits

These commits trigger new PR workflows. Until their exact-head runs complete:
- Updated workflow contract test: NOT VERIFIED.
- Calendar emulator diagnosis and seven-lane rerun: NOT VERIFIED.
- Checklist CRUD on the new HEAD: NOT VERIFIED (baseline test passed only).
- Quality suite on the new HEAD: NOT VERIFIED.
- Staging v2/v3, debuggable, Release Manifest and audit artifacts on the new HEAD: NOT VERIFIED.

Release remains `BLOCKED — RELEASE: NO-GO`.
