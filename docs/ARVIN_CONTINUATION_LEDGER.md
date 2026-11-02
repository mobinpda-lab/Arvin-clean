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


---

## Post-fix audit — exact-SHA results for a371baa — 2026-11-01

Target source/test SHA: `a371baa428cade623940ad218a8724b5b1489be4`.

### Build Run 41326470775 — Attempt 1
All eight jobs enumerated (Analyze + test-0..test-5 + Draft APK Guard):
- Analyze — Job `124907678663`: SUCCESS.
- test-0 — Job `124907678687`: SUCCESS.
- test-1 — Job `124907678650`: SUCCESS.
- test-2 — Job `124907678774`: CANCELLED; log ends with GitHub cancellation at 16:35:24Z. The shard had emitted passing test output before cancellation, but no completed test summary / successful job conclusion. Alarm Overlay file-persistence timeout resolution: NOT VERIFIED. Bottom-navigation assertion in this shard: NOT VERIFIED as a completed shard result.
- test-3 — Job `124907678580`: SUCCESS.
- test-4 — Job `124907678712`: SUCCESS.
- test-5 — Job `124907678400`: SUCCESS.
- Draft APK Guard — Job `124907679302`: SKIPPED (expected while PR remains Draft).
Conclusion: Build is not a full PASS because test-2 was cancelled.

### Device Smoke Run 41326470822 — Attempt 1
Seven scenario lanes:
- Boot — Job `124907668632`: SUCCESS; emulator tests reported “All tests passed”; screenshot artifact ID `13091353439`.
- Navigation — Job `124907668656`: SUCCESS; emulator tests reported “All tests passed”; screenshot artifact ID `13091458062`.
- Calendar Segmented View — Job `124907668661`: CANCELLED; screenshot upload step ran, but this is not a passing scenario.
- Reminder Vazirmatn — Job `124907668605`: CANCELLED.
- Task Lifecycle — Job `124907668650`: CANCELLED.
- Follow-up Persistence — Job `124907668672`: CANCELLED.
- Quick Capture — Job `124907668698`: CANCELLED.
- Prepare selected smoke scenarios — Job `124907647949`: SUCCESS (setup, not one of the seven acceptance lanes).
Conclusion: Device Smoke is 2/7 scenario lanes PASS, 5/7 CANCELLED; not 7/7. The corrected Boot assertion from commit `c402eefbd04c52dd0b564adf1d462a98143a8fa5` is present in the tested ancestry and Boot passed on exact SHA `a371baa...`; do not generalize this to other lanes.

### Explicit alarm timeout disposition
The Alarm Overlay test shard (Build test-2, Job `124907678774`) was cancelled before job completion. Its log contains earlier passing test output but terminates with “The operation was canceled.” Therefore the timeout fix is **NOT VERIFIED**, not PASS and not FAIL. A successful completed rerun of test-2 is required.

### Governance at audit
- Live PR #3052: OPEN / DRAFT / UNMERGED; live head at audit time: `8752886a6325dd64e7807f5616f6bf329f9ed736` (the a371baa source/test SHA is historical/superseded by documentation synchronization).
- Issues #823, #2102, #2299: OPEN.
- Release: **BLOCKED — RELEASE: NO-GO**.
- No merge, main edit, tag, release or APK publication.
- Exact-SHA evidence applies only to `a371baa...`; reruns or subsequent work must be recorded against their own exact SHA, Run ID, Attempt, Job ID and artifact/log evidence.


---

## Dual-status audit & parallel recovery checkpoint — 2026-11-01

**Audit evidence SHA:** `aa5066944b97d58ce7041bdbf61e3799974c0103`  
**Follow-up changes on authorized PR branch:**  
- Filesystem diagnostic probe: commit `3fa8798104f86ba5bfb068435989ff98aaad5e97`.
- Device Smoke screenshot capture/upload correction: commit `5889e653d3eadb1ea935ac5e0696b7adab4140ac`.
- These commits are not yet validated by CI. Their new HEAD must receive fresh exact-SHA Build and Device Smoke runs.

### Dual-status contract — Run 41337292773, Attempt 1, SHA aa506694...

| Device Smoke lane | Functional Status | Visual Evidence Status | Evidence |
|---|---|---|---|
| Boot | PASS | ARTIFACT REGISTERED | Job 124939765057; artifact 13095617340 |
| Navigation | PASS | ARTIFACT REGISTERED | Job 124939765086; artifact 13096450251 |
| Calendar Segmented View | CANCELLED | NOT FOUND | Job 124939765066; no PNG found; Driver request_data delay then operation cancelled |
| Quick Capture | PASS | ARTIFACT REGISTERED | Job 124939765073; artifact 13095699213 |
| Task Lifecycle | PASS | UPLOAD SKIPPED | Job 124939765049; screenshot upload step skipped by workflow condition |
| Reminder / Vazirmatn | PASS | ARTIFACT REGISTERED | Job 124939765112; artifact 13096880689 |
| Follow-up Persistence | PASS | UPLOAD SKIPPED | Job 124939765021; screenshot upload step skipped by workflow condition |

Functional total: **6/7 PASS, 1/7 CANCELLED**.  
Visual evidence total: **4/7 ARTIFACT REGISTERED, 2/7 UPLOAD SKIPPED, 1/7 NOT FOUND**. Functional PASS does not imply visual acceptance.

### T00b filesystem diagnosis — prior evidence and next probe

Build Run `41337292817`, Attempt 1, test-2 Job `124939702107`, SHA `aa506694...`:
- `T00 START` at 0ms; SharedPreferences mock at 2ms.
- Last marker at 3ms: immediately before `Directory.current.createTemp`, path `/home/runner/work/Arvin-clean/Arvin-clean`.
- No exists/stat/permission/disk-space output and no caught filesystem exception were recorded before the ten-minute test timeout.
- Root cause remains **NOT VERIFIED**. The historical run cannot retroactively provide runner filesystem metadata.

Commit `3fa8798...` adds bounded probes for workspace and system temp: exists, stat/type/mode, write/length/delete, createTemp, elapsed markers and full exception/stack output. The real workspace createTemp is also bounded to eight seconds. This is diagnostic instrumentation only; no DB schema, migration, or user-data change. **Await a fresh exact-HEAD CI run before drawing a root-cause conclusion.**

### Calendar cancellation investigation

Device Smoke Run `41337292773`, Attempt 1, Job `124939765066`, SHA `aa506694...`:
- Route diagnostics: navigation=1, calendarTitle=1, helpButton=1, segmentedControl=1.
- Projection diagnostics repeatedly reported `inputContainsSmokeTask=false` and empty task IDs.
- Driver then logged `VMServiceFlutterDriver: request_data message is taking a long time to complete...`; job later ended with `The operation was canceled`.
- Upload step ran but found no `artifacts/device-smoke/*.png`.
- The available log does not prove why the seeded Task was absent from the projection input or why the Driver request remained pending. Both causes remain **NOT VERIFIED**; do not conflate them.

### Screenshot upload correction

At SHA `aa506694...`, the generic Android screenshot upload condition covered only Boot, Quick Capture and Navigation. Task Lifecycle and Follow-up Persistence had no enabled screenshot upload path; their integration tests also contained no `takeScreenshot` calls. Their `UPLOAD SKIPPED` result was therefore explained by workflow configuration, not a proven upload/network failure.

Commit `5889e65...` changes the emulator script to save a final emulator screenshot under `artifacts/device-smoke/<scenario>-final.png` after a successful Flutter drive, and enables the upload step for Task Lifecycle and Follow-up Persistence. This change is **NOT VERIFIED** until the next exact-HEAD Device Smoke run confirms non-empty PNG artifacts and artifact IDs for both lanes. Calendar and Reminder retain their dedicated capture/upload paths.

### Issue #2299 synchronization

Issue #2299 was fetched live as **OPEN**. Its existing body contains historical ledger material and does not yet include this 2026-11-01 exact-SHA checkpoint. A matching audit comment is to be appended; do not close or replace the issue body.

### Governance

- PR #3052: keep OPEN / DRAFT / UNMERGED.
- Issues #823, #2102, #2299: keep OPEN.
- No main-branch edits, merge, release, tag, or APK publication.
- Official font remains Vazirmatn only.
- Release remains **BLOCKED — RELEASE: NO-GO**.
- All new commits require exact-HEAD Build, Device Smoke and relevant artifact verification. No result from SHA `aa506694...` transfers automatically to the new HEAD.


---

## Wave 7.267 live audit checkpoint — 2026-11-02

**Audit target:** PR #3052 branch `fix/recovery-calendar-device-smoke-2026-10-31`  
**Live PR HEAD:** `e4c3d57413376c41257cd2fba2499eaf2103901f`  
**PR state:** OPEN / DRAFT / UNMERGED. **Release:** BLOCKED — RELEASE: NO-GO.  
**Governing issues:** #823 OPEN; #2102 OPEN; #2299 OPEN.

### Exact-head workflow inventory — SHA e4c3d57413376c41257cd2fba2499eaf2103901f

All five run records below were fetched through the commit's workflow-run association. Attempt 1 is the inspected attempt in the available job-list/log endpoints.

| Workflow | Run / Attempt | Job | Result | Evidence / disposition |
|---|---:|---:|---|---|
| Build | 41352893022 / 1 | Analyze 124986762204 | PASS (Analyze job only) | Analyze step SUCCESS; does not make Build green |
| Build | 41352893022 / 1 | test-0 124986762420; test-1 124986762554; test-3 124986762091; test-4 124986762298; test-5 124986762308 | PASS (five shards only) | Each Test step SUCCESS |
| Build | 41352893022 / 1 | test-2 124986762410 | FAIL | 264 tests passed, 2 failed. Failures: `test/device_smoke_workflow_contract_test.dart` expected literal `alarm-overlay-*.png`; `test/alarm_overlay_file_persistence_test.dart` timed out. |
| Build | 41352893022 / 1 | APK matrix 124986763255 | SKIPPED | No APK artifact from this run. |
| Device Smoke | 41352893001 / 1 | Prepare 124986709272 | SUCCESS (setup only) | Does not count as a scenario lane |
| Device Smoke | 41352893001 / 1 | Boot 124986725361 | SUCCESS job | Emulator script reached `emulator-5554 device`; however upload warned no `artifacts/device-smoke/*.png`. Functional scenario details not independently verified from a completed drive report. |
| Device Smoke | 41352893001 / 1 | Navigation 124986725385 | SUCCESS job | Upload warned no PNG files. Scenario functional result NOT VERIFIED. |
| Device Smoke | 41352893001 / 1 | Reminder/Vazirmatn 124986725394 | SUCCESS job | Dedicated overlay upload step SUCCESS, but run artifact listing returned no registered artifacts. Functional/visual acceptance NOT VERIFIED. |
| Device Smoke | 41352893001 / 1 | Task Lifecycle 124986725358 | SUCCESS job | Upload warned no PNG files. Functional result NOT VERIFIED. |
| Device Smoke | 41352893001 / 1 | Follow-up Persistence 124986725414 | SUCCESS job | Upload warned no PNG files. Functional result NOT VERIFIED. |
| Device Smoke | 41352893001 / 1 | Quick Capture 124986725465 | SUCCESS job | Upload step SUCCESS, but no registered artifacts in run listing. Functional/visual acceptance NOT VERIFIED. |
| Device Smoke | 41352893001 / 1 | Calendar Segmented View 124986725482 | SUCCESS job | Calendar upload step SUCCESS, but no registered artifacts in run listing. Functional/visual acceptance NOT VERIFIED. |
| Follow-up SQLite | 41352892995 / 1 | 124986757900 | FAIL | Repository file persistence test passed. Alarm Overlay test stopped at T00b immediately before `Directory.systemTemp.createTemp('/tmp')`; 10-minute timeout. No temp directory, NativeDatabase, schema install, write, close/reopen, or reload evidence. Root cause NOT VERIFIED. |
| Calendar Provider | 41352892991 / 1 | 124986693330 | PASS (provider scope only) | Instrumentation `provisionsExactlyOneWritableCalendarIdempotently`: TEST_RESULT=PASS / OK (1 test); exact-head evidence artifact ID 13102051651, 11,205 bytes, URL https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41352892991/artifacts/13102051651. Does not prove Device Smoke or physical Calendar acceptance. |
| Parallel Wave | 41352892989 / 1 | 124986693460 | FAIL | Fast Lane contract reports missing literal `flutter drive --driver=test_driver/integration_test.dart` in .github/workflows/device-smoke.yml. |

### Device Smoke dual status

The workflow job conclusions are SUCCESS for all seven lanes, but the available log/artifact evidence is insufficient to claim seven functional PASS results. Initial emulator startup logged `Unable to connect to adb daemon on port: 5037`; later log lines show `emulator-5554 device` for some jobs. The seven lane logs must demonstrate completed scenario execution and their registered artifacts must be non-empty/downloadable before upgrading status.

| Lane | Functional Status | Visual Evidence Status |
|---|---|---|
| Boot | NOT VERIFIED | UPLOAD SKIPPED / NOT FOUND |
| Navigation | NOT VERIFIED | UPLOAD SKIPPED / NOT FOUND |
| Reminder/Vazirmatn | NOT VERIFIED | NOT FOUND in run artifact listing |
| Task Lifecycle | NOT VERIFIED | UPLOAD SKIPPED / NOT FOUND |
| Follow-up Persistence | NOT VERIFIED | UPLOAD SKIPPED / NOT FOUND |
| Quick Capture | NOT VERIFIED | NOT FOUND in run artifact listing |
| Calendar Segmented View | NOT VERIFIED | NOT FOUND in run artifact listing |

No artifact registered in Device Smoke run 41352893001. The job-level upload step conclusion alone is not evidence that an artifact exists. The ADB daemon startup error is observed; its underlying cause is NOT VERIFIED. Emulator readiness and the exact Flutter drive outcome remain to be proven per lane.

### Home Wave 7.267 source audit — no Home code changed in this checkpoint

- `lib/main.dart` is the real HomePage entry. It still uses `_homeFilterCards()`; the four large filter cards remain. Existing time/project/category/tag filter state and sheet handlers must be preserved during any later compact-chip conversion.
- `HomeFollowUpPresentationService` and its test exist. The test explicitly verifies no fabricated latest FollowUp when only a legacy date exists. Its connection to the real Home task card remains NOT VERIFIED / not integrated in this checkpoint.
- Existing time groups and collapse state were found in Home source; the new pastel/count/accordion requirements are not yet accepted as complete.
- The actual Home card currently navigates to Task Details; in-place accordion and scroll-direction Bottom Navigation auto-hide remain NOT IMPLEMENTED at this checkpoint.
- Quick Capture FAB, search and notification handlers remain present in the real Home source; preserve their existing routes/callbacks.
- Exact owner reference image filenames `photo_1793577657412.webp` and `photo_1793578032490.webp` were not found in repository code search; GitHub Agent visibility of the conversation attachments is NOT VERIFIED. No image-based comparison is claimed.
- No Bismillah image asset was identified by the searched exact filenames or repository code search. The currently inspected Home visual integration contains a text capsule, not an approved image asset. Full repository asset inventory and license provenance remain NOT VERIFIED.
- A dedicated Home alarm filter has no verified independent query/projection contract in this audit; record as NEEDS PRODUCT DECISION, do not add.
- Search for prior exact test paths `test/rtl_spec_test.dart` and `test/vazirmatn_font_test.dart` returned no results; this does not prove absence of all RTL/font tests. Existing relevant test inventory must be enumerated before editing.

### FollowUp / persistence contract audit

- Live source search shows `Task.followUpEnabled` and `Task.followUpDate` remain in the Task model and SQL migration writer; TaskStore still treats them as known payload keys.
- `FollowUp.nextFollowUp` and `reminderDate` references remain in active model/editor paths per repository audit results.
- Prior governance requires removal of active future-FollowUp scheduling while preserving compatibility/data. No live database contents or backup were inspected here; destructive schema changes remain prohibited. Safe conversion/rollback plan NOT VERIFIED.
- Existing test `home_follow_up_presentation_service_test.dart` verifies no synthetic FollowUp from a legacy date; this is source/test presence, not exact-head execution evidence.

### Work disposition and next gates

No source, workflow, test, or product UI file was edited in this checkpoint. No commit, push, new CI run, issue comment, merge, release, APK publication, database migration, or user-data mutation was performed. This is an evidence-led audit-only checkpoint; all open items remain open.

**P0:** resolve ADB startup/boot readiness with logs and actual device enumeration; obtain completed Flutter drive result for all seven lanes; register and download non-empty per-lane artifacts; fix the artifact-name contract without dropping `alarm-overlay-*.png`; independently root-cause the T00b temp-directory stall; rerun full Build; produce and verify a real signed APK/manifest; complete Golden Flow and device acceptance.

**P1:** implement Wave 7.267 only on the real HomePage after locating official Bismillah asset/license and owner references; compact chips with preserved filters; real-data group headers/counts; in-place task accordion with Details route preserved; wire real FollowUp presentation service; scroll-aware Bottom Navigation while preserving FAB; expand Home/RTL/Vazirmatn/viewport/empty-state tests. Decide separately whether an Alarm filter has a real product/query contract.

**P1 data safety:** reconcile active legacy `followUpEnabled`, `followUpDate`, `nextFollowUp`, and FollowUp future-scheduling fields against the current Reminder-only future scheduling baseline. Inspect real DB/backup before any migration; preserve records and provide rollback. Test independent Complete / Stop Alarm / Snooze / Save FollowUp actions across file-backed SQLite reopen.

**P2:** update product matrix and changelog only after source changes stabilize; append exact-SHA evidence to Issue #2299 only after each result is independently inspectable. Keep #823/#2102/#2299 OPEN and PR #3052 OPEN/DRAFT/UNMERGED.

**Final gate:** PR remains UNMERGED. Release remains **BLOCKED — RELEASE: NO-GO**.
