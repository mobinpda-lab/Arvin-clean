# ARVIN Continuation Ledger

## Purpose
This document preserves the implementation context extracted from the long ARVIN review conversation. It is a continuity reference; completion must always be proven by code, tests, builds, and evidence.

## Source of Truth
GitHub code + PR + tests + APK/device evidence are authoritative.

## Home
- Keep canonical visual shell.
- Validate against reference screenshots.
- Verify cards, RTL, typography, spacing, search, and primary add action.
- Expected flow:

Home Card -> Task Detail -> Edit / FollowUp

## Task Flow
All creation and editing paths must converge:

Quick Entry / Create / Edit -> Unified Task Editor -> Canonical Repository -> arvin.tasks

Avoid parallel models, stores, or write paths.

## Task Detail
Required:
- Task information
- FollowUp Timeline
- Add FollowUp
- Edit flow

## FollowUp
Required:
- Multiple followups per task
- History preservation
- Latest FollowUp projection
- Persian/Jalali handling
- Empty states

## Quick Entry
Quick capture must use the same canonical task path and not create a separate storage model.

## Notebook
Simple Note and Checklist must respect canonical architecture. Avoid duplicate storage paths.

## Calendar
Validate:
- No date means no calendar event
- Date only means all-day behavior
- Date plus time means timed event

## Visual Validation Gate
Before release:
1. Code
2. Tests
3. Build
4. Install
5. Screenshot comparison
6. Evidence

## Execution Order
1. Audit remaining Home routes and Task navigation.
2. Verify Unified Editor paths.
3. Verify FollowUp evidence.
4. Run tests.
5. Build APK.
6. Record evidence.

## Rule
Do not report a feature as completed without a GitHub artifact (commit/PR/test/build/evidence).

---

## Durable continuation checkpoint — 2026-11-01 16:34 UTC

**Current audited PR SHA at checkpoint:** `43c342c275e03d7139ab60f878706aedbd7daad0` (documentation-only commit after source/test SHA `a371baa428cade623940ad218a8724b5b1489be4`). Always re-read branch HEAD before continuing.

### Non-negotiable governance
- Work only on `fix/recovery-calendar-device-smoke-2026-10-31` through PR #3052.
- PR #3052 must remain OPEN / DRAFT / UNMERGED. No merge to main, no main edits, no tag, no Release, no APK publication.
- Issues #823, #2102 and #2299 must remain OPEN.
- Release decision: **BLOCKED — RELEASE: NO-GO**.
- Vazirmatn is the only official app font; system-default fallback is prohibited.
- Never weaken/delete acceptance assertions to obtain green CI. No fake PASS, stale SHA or inferred success.

### Latest source/test checkpoint
- Source/test SHA: `a371baa428cade623940ad218a8724b5b1489be4`.
- Navigation test correction: `5f17184923a1da6883e3f3d76eee4cf7eb166aea` (`خانه` → `امروز`).
- Boot assertion correction: `c402eefbd04c52dd0b564adf1d462a98143a8fa5` (actual Home subtitle).
- Alarm Overlay file-persistence test DB injection correction: `a371baa428cade623940ad218a8724b5b1489be4` (shared file-backed executor in TaskStore and ProjectStore).
- Follow-up persistence workflow passed: Run `41326470829`, Attempt 1, Job `124907362840`, exact source/test SHA `a371baa...`. This does not prove Alarm Overlay's own file-backed widget test.

### Exact-SHA workflow checkpoint (source/test SHA a371baa..., Attempt 1)
- Build Run `41326470775`: Analyze, test-0, test-1, test-3, test-4, test-5 SUCCESS; test-2 Job `124907678774` IN PROGRESS; APK matrix Job `124907679302` SKIPPED. Run still IN PROGRESS. Test-2 log endpoint returned BlobNotFound at checkpoint; result NOT VERIFIED.
- Device Smoke Run `41326470822`: Prepare SUCCESS; Boot Job `124907668632` SUCCESS; Navigation `124907668656` IN PROGRESS; Calendar Segmented View `124907668661` IN PROGRESS; Reminder `124907668605`, Task Lifecycle `124907668650`, Follow-up Persistence `124907668672`, Quick Capture `124907668698` QUEUED. Not 7/7.
- Calendar Provider Run `41326470720`, Job `124907350144`: IN PROGRESS.
- Follow-up file persistence Run `41326470829`, Job `124907362840`: SUCCESS.
- Build/device/provider results above are snapshots and must be re-polled before claiming completion.

### Calendar source-filter implementation at a371baa...
`lib/calendar_page.dart` has four source choices: `همه`, `تقویم گوشی`, `یادآورها`, `انجام‌نشده`. Device Calendar matches `external-calendar:`; timed Reminder filter matches task reminder/due/recurrence prefixes but excludes all-day; Unfinished matches `!completed`. Selected-day list sorts all-day first, then timed chronologically. Widget coverage exists in `test/calendar_page_test.dart`. This is source/test presence only; exact-SHA CI and physical-device interaction are required.

### Outstanding work — persistent checklist
1. Complete Build Run 41326470775; specifically test-2 Alarm Overlay file persistence and bottom-navigation contract. Capture all job IDs and APK Draft Guard SKIPPED.
2. Complete all seven Device Smoke lanes in Run 41326470822 on one exact SHA; inspect artifacts/screenshots, especially Calendar Segmented View, Reminder/Vazirmatn, Boot and Alarm Overlay.
3. Complete Calendar Provider Run 41326470720; separately validate physical device and two writable calendars.
4. Prove four alarm actions remain isolated end-to-end: complete Task via canonical TaskStore; stop only active notification lifecycle; snooze only the same Reminder; save Follow-up only after explicit Save. Audio stop, recurrence, foreground/background/cold-start notification delivery, reboot/timezone/permission and TalkBack remain NOT VERIFIED.
5. Calendar: test all four filters; Activity Dot for monthly all-day entries; all-day first in selected-day list; all-day excluded from timed Reminder filter; incomplete all-day remains Overdue after day-end. Device interaction and screenshot review pending.
6. Typography: Vazirmatn across every screen/overlay, Persian digits, missing glyphs, fallback guard, semantics, compact/large text and accessibility.
7. Home: compare exact-SHA screenshots to the owner reference. Reference WEBP was unavailable; pixel comparison NOT VERIFIED.
8. Device Calendar: same-event edit, no duplicate, link recovery, permissions, reboot, physical device and two writable calendars.
9. Data safety: safe legacy-schema migration/compatibility; Reminder FK and last-delete/reopen persistence; Backup/Restore links and history; recurrence snapshots; Checklist/Quick Capture canonical write path; Trash/restore/hard-delete policy.
10. Output/release: PDF font embedding/shaping; production certificate/signing; apksigner v2/v3; Release Manifest with exact SHA, byte size, SHA-256 and 7/7 device proof. All NOT VERIFIED; no APK while Draft.
11. Reconcile Issues #823/#2102/#2299 after each meaningful gate; keep all OPEN and PR #3052 Draft/Unmerged.

### Resume protocol
At the start of every new conversation/account: read this file and `docs/qa/ARVIN_FULL_PRODUCT_AUDIT_2026-11-01.md`, fetch live PR #3052 and branch HEAD, read Issues #823/#2102/#2299, poll exact-SHA workflow runs and compare them with this ledger. Update this file, the full audit, changelog and Issue #2299 whenever the ledger changes. GitHub repository records are the continuity source; chat memory is not.
