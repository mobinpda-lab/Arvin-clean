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


---

## Wave 7.270 implementation checkpoint — 2026-11-02

**Authorized target:** `mobinpda-lab/Arvin-clean`, branch `fix/recovery-calendar-device-smoke-2026-10-31`, PR #3052.  
**PR state at checkpoint start:** OPEN / DRAFT / UNMERGED. Release remains **BLOCKED — RELEASE: NO-GO**.

### Changes committed on the PR branch

- `tool/validate_fast_lane.py`: Fast Lane now extracts the Base64 payload from the emulator action's `printf "%s" ... | base64 --decode | bash` form, decodes it as UTF-8, and validates the actual executable shell for the required `flutter drive --driver=test_driver/integration_test.dart` command and screenshot directory. It still requires the workflow's Base64 decode pipeline and the seven canonical scenario mapping; no emulator command or driver requirement was removed.
- `.github/workflows/device-smoke.yml`: retained an explicit `alarm-overlay-*.png` fallback marker in the Reminder artifact step comment while preserving the actual artifact glob.
- `lib/main.dart`: implemented in-place expansion state for Home task cards; the card tap expands/collapses in place while a distinct Details icon retains `_openTaskDetail`. Expanded content shows description and exact due date/time. The real `HomeFollowUpPresentationService` now projects only `task.lastFollowUp`; the legacy date is not used to fabricate a FollowUp. Actual history is displayed in a soft green presentation with exact time and relative elapsed label.
- `lib/main.dart`: added a Home list ScrollController and direction-aware Bottom Navigation visibility animation. The Scaffold FAB remains a separate Scaffold slot and is not placed inside the navigation animation. The compact-screen add action remains in the body.
- `lib/main.dart`: Bismillah is centered and rendered as Vazirmatn text with stronger legibility; no external image was introduced.
- Home and Device Smoke contract tests were updated for the actual compact-chip labels, no-counter design, accordion/real-history rendering, and Base64 validator contract.

### Exact-head CI evidence before the Wave 7.270 commits

These runs targeted SHA `073664dbb69f0c1aea96ebd074a97a158b5c1699`; they do not validate the later Wave 7.270 commits.

| Workflow | Run / Attempt | Job | Result | Evidence |
|---|---:|---:|---|---|
| Parallel Wave | 41367890508 / 1 | contract 125031871982 | FAIL | Validator searched for plaintext driver command, but workflow executes the Base64-decoded script. This is the P0 issue addressed by the validator change. |
| Build | 41367890590 / 1 | Analyze 125031959175 | FAIL | Analyzer found unused `_homeCountLabel`; removed in the Home implementation commit. |
| Build | 41367890590 / 1 | test-0 125031959215 | FAIL | Old assertions expected `دسته‌ها`; current compact chip label is `دسته‌بندی‌ها`. |
| Build | 41367890590 / 1 | test-1 125031959340 | FAIL | Old Home test expected the removed four-card/counter behavior and `دسته‌ها`; assertions updated to compact chips without counters. |
| Build | 41367890590 / 1 | test-2 125031959323 | FAIL | Old test expected `دسته‌ها` and literal `alarm-overlay-*.png`; test labels/contract updated and workflow marker retained. The file-backed Alarm Overlay test also timed out at T14. |
| Build | 41367890590 / 1 | test-3 125031959257 | SUCCESS | One shard only; not an overall Build PASS. |
| Build | 41367890590 / 1 | test-4 125031959025 | FAIL | `home_stat_filters_test.dart` grouping/storage test failed; same old Home label contract. |
| Build | 41367890590 / 1 | test-5 125031959217 | FAIL | Old Home labels and summary-card count expectations. |
| Build | 41367890590 / 1 | APK 125031959959 | SKIPPED | No APK artifact from this run. |
| Follow-up File Persistence | 41367890598 / 1 | 125031889378 | FAIL | `createTempSync`, NativeDatabase, schema install, initial write, Snooze, close/reopen and reload all completed. Timeout occurred after marker T14, before the Complete action returned. No `[COMPLETE]` diagnostic marker appeared; exact reason the Complete tap did not progress is NOT VERIFIED. |
| Device Smoke | 41367890540 / 1 | seven scenario jobs | SUCCESS job conclusions | All seven jobs ended SUCCESS, but screenshot upload steps reported no files for the observed lanes. No registered non-empty per-lane artifacts were established; visual acceptance remains NOT VERIFIED. Job SUCCESS alone is not promoted to functional 7/7 PASS. |

### Wave 7.270 validation status

- The new validator and Home changes are committed, but no new exact-head Parallel Wave or Build result has yet been inspected at this ledger update.
- The new Home widget test is source-level coverage only until its exact-head Build shard completes.
- The file-backed persistence timeout is no longer attributable to temp-directory creation: the synchronous temp directory and SQLite reopen path completed. The remaining T14/Complete-action stall requires separate root-cause work; do not increase timeout or remove the Complete assertion to mask it.
- No local Flutter/Dart test was run in this environment.
- No APK from the inspected Build run; no release artifact is accepted.

### Governance and remaining work

- Keep PR #3052 OPEN / DRAFT / UNMERGED.
- Keep Issues #823, #2102 and #2299 OPEN.
- Preserve SQLite and all Task/FollowUp records; no destructive schema migration was attempted.
- Keep the four independent Reminder actions and five-tab navigation behavior intact.
- Require fresh exact-HEAD Build, Parallel Wave, Device Smoke and file-backed persistence evidence after the Wave 7.270 commits.
- Release remains **BLOCKED — RELEASE: NO-GO**.


---

## Wave 7.271 live audit checkpoint — 2026-11-02

**Audited revision:** `2cf461c69bbbeda1b86eaf76a04e2a1036a9d011`  
**PR #3052:** OPEN / DRAFT / UNMERGED.  
**Release:** BLOCKED — RELEASE: NO-GO.

### Live workflow outcomes

| Workflow | Run | Job evidence | Outcome |
|---|---:|---|---|
| Build #9095 | 41370612040 | Analyze 125040150620 SUCCESS; test-0 125040150319 FAILURE; test-1 125040150555 SUCCESS; test-2 125040150755 FAILURE; test-3 125040150513 FAILURE; test-4 125040150625 SUCCESS; test-5 125040150591 SUCCESS; APK 125040151453 SKIPPED | Overall FAILURE |
| Parallel Wave | 41370611960 | contract 125040075984 SUCCESS; log: `Arvin Fast Lane workflow contract: OK` | PASS for validator contract only |
| Follow-up File Persistence | 41370611969 | Job 125040146456 FAILURE | T14 timeout |
| Device Smoke #6356 | 41370611971 | seven scenario jobs all SUCCESS | No artifact files registered |

### Build failure detail

- Analyzer log explicitly reports `No issues found!`.
- test-0 fails `test/widgets/home_page_test.dart` canonical Home shell assertion: expected old search placeholder text, no matching widget found.
- test-3 fails `test/home/home_filter_contract_test.dart`: expected key `task-card-details-legacy-only`, actual finder returned zero widgets. Earlier assertions in that same test had progressed beyond the first-card accordion/description/time and real FollowUp checks; full accordion contract is not accepted.
- test-2 fails `test/device_smoke_workflow_contract_test.dart`: expected non-null canonical lane match, actual null. The same shard reports 265 tests passed and two failed, including the file-backed Alarm Overlay persistence timeout.
- test-1, test-4, test-5 passed in this run.
- APK matrix was skipped by an explicit workflow condition: `if: github.event_name != 'pull_request' || !github.event.pull_request.draft`. PR #3052 is Draft, so the APK job is intentionally excluded. This is a governance gate, not a Gradle/APK compile failure. Do not change PR state or dispatch a release build without explicit authorization.

### File-backed SQLite / Complete action

- Run 41370611969, Job 125040146456 reached T14 after temp directory creation, first SQLite save, Snooze, close/reopen, second schema install, reload and persisted-state assertions completed.
- T14 immediately precedes `await tester.tap(find.byKey(ValueKey('alarm-overlay-complete')))`.
- Log then records T22 cleanup and T23 diagnostics shutdown, followed by the 10-minute test timeout.
- No `[COMPLETE] before TaskStore.mutate` marker appears. Thus the handler body was not observably entered; there is no evidence of a failed SQLite completion write or Calendar sync invocation.
- Root cause of the tap/interaction not entering the handler remains **NOT VERIFIED**. A likely widget-test interaction/presentation issue is only a hypothesis, not an established cause. Do not claim a database defect or alter assertions/timeouts until the interaction is instrumented and reproduced.

### Device Smoke artifacts

- All seven scenario jobs (Boot, Task Lifecycle, Quick Capture, Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View, Navigation) concluded SUCCESS.
- Artifact listing for Run 41370611971 is empty.
- All seven job logs report no files matching `artifacts/device-smoke/*.png`; no screenshot/video artifacts are available.
- Therefore functional scenario completion is not independently accepted from job conclusions alone; visual evidence is NOT VERIFIED. No video evidence was returned.

### Product documentation

- `CHANGELOG.md` contains a Wave 7.270 section documenting the Fast Lane decoder, Home accordion, actual FollowUp projection, scroll-aware navigation with separate FAB, Vazirmatn Bismillah and tests, with an explicit statement that CI acceptance is pending.
- This Ledger records the Wave 7.270 implementation and now includes this Wave 7.271 live audit.
- The UI changes are recorded in both documents; these records do not imply acceptance.

### Next actions

1. Fix the two source/test contract failures: update the canonical Home search assertion to the actual product copy; correct the second-card fixture/visibility and preserve its independent Details route assertion.
2. Investigate the Device Smoke contract test's null lane match against the actual seven-lane workflow source; retain all seven lane checks.
3. Instrument the Complete button's actual render bounds, visibility, hit-test result and callback entry in the widget test. Establish why the callback is not entered before changing production behavior. Preserve all SQLite reopen and completion assertions.
4. Diagnose why scenario jobs produce no screenshot files and make each lane write a non-empty artifact at the declared path; do not convert empty artifacts into success.
5. APK build is intentionally gated while the PR is Draft. Keep that policy intact until explicit product-owner authorization to ready a build candidate.
6. Re-run Build, Parallel Wave, Device Smoke and file-backed persistence on one exact new HEAD after fixes.

No issue closed, no PR merge, no main change, no schema migration. Release remains **BLOCKED — RELEASE: NO-GO**.


---

## Wave 7.272 implementation checkpoint — 2026-11-02

**Scope:** Home test contract, real Complete-button interaction, Device Smoke contract and screenshot artifact integrity. Changes are confined to `fix/recovery-calendar-device-smoke-2026-10-31`.

### Changes committed
- `test/widgets/home_page_test.dart`: expected search hint corrected to the exact current Home copy (`دسته‌ها`); product UI unchanged.
- `test/home/home_filter_contract_test.dart`: scrolls the legacy-only second card into view before tap and Details assertion. Retains the negative assertion that no FollowUp presentation is created from legacy `followUpDate`.
- `test/alarm_overlay_file_persistence_test.dart`: T14 now asserts Complete control exists, scrolls it into view, settles, verifies hit-testability, logs T14a, and taps the actual control. Completion persistence/reopen assertions remain unchanged.
- `test/device_smoke_workflow_contract_test.dart`: Base64 shell extraction now matches the real encoded command pipeline; exact seven scenario mappings and driver assertions remain required.
- `.github/workflows/device-smoke.yml`: screenshot output is written to an absolute workspace artifact path and validated for non-empty size and PNG signature before the existing per-scenario upload steps.

### Acceptance status
No PASS is inferred from source changes. Fresh exact-HEAD runs are required for all six Build shards + Analyzer, Parallel Wave, file-backed SQLite completion, and all seven Device Smoke lanes with individually registered PNG artifacts. APK matrix remains skipped while PR #3052 is Draft by design. PR must remain OPEN/DRAFT/UNMERGED and Release remains BLOCKED — RELEASE: NO-GO.

- Added real Home-surface screenshot capture to the Task Lifecycle and Follow-up Persistence integration lanes after their data assertions; each now emits a named screenshot through the host-side integration driver rather than manufacturing an image in the workflow.


---

## Wave 7.272 — final exact-SHA evidence settlement — 2026-11-02

**Target branch SHA:** `8ccbc90ebfdcd797d5c18f6ab7a6cb6cff2de358`. The following outcomes are tied to this exact SHA only.

### Build — Run 41382008848
- Aggregate conclusion: **FAILURE**.
- Analyze Job `125074920574`: **FAILURE**. Two compile/analyzer errors: undefined name `tester` at `integration_test/android_backup_restore_sql_smoke_test.dart:443:15` and `:446:15`.
- Test shards: test-0 `125074920667` SUCCESS; test-1 `125074920573` SUCCESS; test-2 `125074920682` FAILURE; test-3 `125074920556` SUCCESS; test-4 `125074920407` SUCCESS; test-5 `125074920744` SUCCESS. Result: **5/6 shards SUCCESS; test-2 FAILURE**.
- APK matrix Job `125074921501`: SKIPPED under the Draft PR guard. This is intentional and is not an APK build result.

### Alarm Overlay file-backed SQLite — Run 41382008771
- Job `125074713868`: **FAILURE**. The first repository-level file-backed persistence test passed. The alarm-overlay close/reopen diagnostic timed out after 10 minutes.
- Last emitted stage: T14, “before Complete action; awaiting full completion + Calendar sync path”. No T14a, Complete callback/handler marker, TaskStore completion mutation marker, or Calendar sync marker was emitted.
- Therefore the requested interaction did **not** reach an evidenced handler entry. Database completion persistence and Calendar sync are **NOT VERIFIED**; do not call them failed or passed. Root cause remains **NOT VERIFIED**.
- Build test-2 independently shows the same boundary: T02, T04, T07, T11, T13, T14; then 10-minute timeout, without T14a or handler entry.

### Device Smoke — Run 41382008923
- All seven jobs concluded SUCCESS: Boot `125074796302`; Navigation `125074796385`; Quick Capture `125074796286`; Calendar Segmented View `125074796335`; Reminder/Vazirmatn `125074796280`; Follow-up Persistence `125074796343`; Task Lifecycle `125074796382`.
- Artifact API listing returned **zero artifacts**. Upload logs for all seven lanes contain warnings that no files matched `artifacts/device-smoke/*.png`. Some lane-specific upload steps were skipped or also reported missing files.
- Conclusion: **7/7 smoke job conclusions SUCCESS, but 0 verifiable uploaded PNG artifacts**. No filenames or file sizes exist in the returned artifact inventory. Screenshot/visual acceptance is **NOT VERIFIED**; job success alone is insufficient.

### Parallel Wave — Run 41382008837
- Contract Job `125074647025`: **SUCCESS**; log output: `Arvin Fast Lane workflow contract: OK`.
- Important scope note: this workflow checked out PR merge ref `b6dd35a273b537ea9319ea4d17cdd3a004b35b82`, rather than branch head `8ccbc90...`. It validates the Fast Lane contract in the PR merge checkout; it is not an exact branch-head runtime test.

### Governance and next steps
- PR #3052 remains OPEN / DRAFT / UNMERGED. No main edit, merge, APK publication or release.
- Release remains **BLOCKED — RELEASE: NO-GO**.
- Fix the two undefined `tester` references in the integration test without removing its app launch or screenshot assertions; diagnose why T14a/Complete handler are not reached without relaxing timeout/assertions; make each smoke lane create and upload a non-empty valid PNG, then inspect artifact names, sizes and PNG signatures.
- Any documentation commit advances the branch HEAD. All Build, SQLite, Device Smoke and Parallel Wave evidence above remains historical for SHA `8ccbc90...` and must not be carried forward to the new SHA.


## Wave 7.273 — source remediation checkpoint — 2026-11-02

**Base SHA:** `b5e4d9a37879631c8e903b5508a390d77ba78f1d`. This section records source/workflow changes only; runtime acceptance is pending on the final documentation HEAD.

- `integration_test/android_backup_restore_sql_smoke_test.dart`: converted the portable backup file round-trip case from plain `test` to `testWidgets((tester) async {...})`. The existing actual file write/read/restore assertions remain; the final app launch, Home assertion and `task-lifecycle` screenshot now use the WidgetTester in scope.
- `test/alarm_overlay_file_persistence_test.dart`: retained the actual keyed Complete button, visibility and hit-test assertions, and real tap. Replaced the second global `pumpAndSettle` after `ensureVisible` with one 200ms frame pump before hit-test. This avoids waiting for unrelated repeating animations while preserving the actual hit-test and callback path; T14a and post-tap/database reopen assertions remain. Whether this resolves the observed T14 stall is **NOT VERIFIED** until the test runs.
- `.github/workflows/device-smoke.yml`: retained the canonical relative output `artifacts/device-smoke/${SMOKE_SCENARIO}-final.png`; after ADB screencap the script now validates non-empty size (>1000 bytes), PNG signature `89504e470d0a1a0a`, and logs filename/byte count/signature. Upload actions now use `if-no-files-found: error` instead of warning. Seven lane mapping is unchanged.
- No tests, assertions, lanes, or timeout limits were removed or weakened. No APK build was enabled.
- Exact final SHA and workflow outcomes must be recorded after the documentation commit; previous SHA evidence does not transfer.

**Governance:** PR #3052 remains OPEN/DRAFT/UNMERGED; release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 7.274 — consolidated remediation — 2026-11-02

**Base implementation revision:** `4f7afad460463b4ecf0353deaf4d5dc33c433be4`. The following source changes are committed on `fix/recovery-calendar-device-smoke-2026-10-31`; runtime acceptance is pending on the final documentation SHA.

- `integration_test/android_sql_persistence_smoke_test.dart`: removed only the unused `package:flutter/material.dart` import flagged by Analyzer. Test behavior and assertions are unchanged.
- `.github/workflows/device-smoke.yml`: the encoded emulator script now waits for the selected ADB device immediately before capture, verifies it remains in `device` state, creates `artifacts/device-smoke`, and writes the direct `adb exec-out screencap -p` stream to the scenario PNG. Before upload, it enumerates every PNG and logs path, byte size and PNG signature; every file must exceed 1000 bytes and carry the PNG magic signature, and at least one valid PNG must exist. The seven scenario matrix and upload error policy remain intact.
- `test/alarm_overlay_file_persistence_test.dart`: retains the actual visible/hit-testable Complete control, actual tap, Task completion and close/reopen SQLite assertions. After the tap it no longer calls global `pumpAndSettle`; it pumps at most 50 bounded 100ms frames until the real notification-cancellation callback proves the handler reached its final stage. New T14b/T14c/T14d markers delimit tap dispatch, bounded handler wait and handler completion. The test will still fail if the handler does not complete within the bounded window.
- No timeout was increased; no test, assertion, scenario, or acceptance requirement was removed or weakened. No production handler or persistence semantics were bypassed.

**Validation:** no workflow result is claimed by this source checkpoint. Build, File Persistence, seven-lane Device Smoke and Parallel Wave must all report fresh results against one identical final SHA. Device screenshots are accepted only when the run artifact inventory contains the per-lane files and their logs confirm valid PNG signatures and sizes.

**Governance:** PR #3052 remains OPEN / DRAFT / UNMERGED. No main change, merge, APK Matrix build or release. Release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 7.275 — bounded Complete interaction and ADB recovery — 2026-11-02

**Base SHA:** `f9c30440b4efad500aee790d48e6bc0c680602f0`. Source/workflow remediation only; runtime acceptance is pending on the final exact HEAD.

- `test/alarm_overlay_file_persistence_test.dart`: removed the awaited `tester.ensureVisible` Future from the T14 path. The test now immediately asserts that the actual Complete button is hit-testable, records T14a, taps the real control, waits only through the existing bounded 50 × 100ms pump loop for the real notification-cancellation callback, then closes/reopens SQLite and verifies persisted completion and reminder isolation. No handler, storage, assertion, or timeout was bypassed. A visibility failure now fails promptly rather than hanging before T14a.
- Root-cause qualification: on the base SHA, the live log reached T14 and then entered cleanup without T14a. CalendarOutboundSyncService is invoked only after the Complete tap and TaskStore mutation; therefore the available evidence does not support Calendar Sync as the cause of this particular timeout. The awaited visibility Future is the first unresolved operation at the observed boundary; this is the targeted test-side correction. Production Calendar Sync behavior is unchanged.
- `.github/workflows/device-smoke.yml`: the encoded emulator script now explicitly restarts the host ADB daemon, waits for emulator serial `emulator-5554`, and verifies the device state before running the lane. ADB-related Flutter Drive failures receive one retry after ADB recovery; screenshot capture receives one retry after ADB recovery. Direct `adb exec-out screencap -p` remains the source of the PNG, and the existing PNG signature and >1000-byte checks remain mandatory before upload.
- `test/device_smoke_workflow_contract_test.dart`: contract assertions now require the daemon restart, wait-for-device, both one-retry paths, and direct screencap command while preserving the seven canonical lane mappings.
- No production storage or notification semantics were changed. No APK matrix was enabled. No main-branch change or merge was made.

**Validation status:** source changes are committed; Build (Analyze + test-0…test-5), File Persistence, all seven Device Smoke lanes with registered PNG artifacts, and Parallel Wave must complete against this same final SHA. No PASS is inferred from this implementation commit.

**Governance:** PR #3052 remains OPEN / DRAFT / UNMERGED. Main changes, APK matrix build, publication and release remain blocked. **BLOCKED — RELEASE: NO-GO**.


## Wave 7.276 — exact log-driven persistence and emulator transport correction — 2026-11-02

**Base SHA:** `7fee44dd512ee6543ace29d236e6cca06c1753ca`. This remediation is limited to the failing test harness, device-smoke workflow and its contract; product behavior is unchanged.

- **Build #41402881551 / test-2:** two failing tests were confirmed. The workflow-contract assertion expected the literal substring `adb exec-out screencap -p`, while the actual decoded command is `adb -s "$device" exec-out screencap -p`. The assertion now matches the actual serial-qualified command; the seven canonical scenario mappings remain required.
- **File Persistence #41402881330 and Build test-2:** both logs stop after T14 and enter cleanup without T14a; the ten-minute test timeout is explicit. T00–T13 prove initial save, Snooze, SQLite close/reopen, Schema install and Task reload complete. The Complete control is still required to be present, fully visible, tapped, and followed by the real notification-cancellation callback and final SQLite reopen assertions. The test now performs bounded real viewport drags and checks the button rectangle is fully inside the viewport before tapping; no handler or persistence assertion is skipped. The prior logs do not prove a production Calendar Sync defect.
- **Device Smoke #41402881315:** all seven lanes show the same transport failure signature: ADB daemon connection on port 5037, then the selected emulator is offline/not registered. The previous script killed the emulator-runner-managed ADB server after emulator startup; the revised script never kills that server, idempotently starts it, polls the exact serial until it is online and boot-complete, and reconnects only offline transports. The one transport-only Flutter Drive retry remains; assertion failures are not retried. Screenshot capture is still a direct serial-qualified `adb exec-out screencap -p`, with PNG signature and >1000-byte checks. It now attempts to preserve a valid screenshot artifact even when the integration test fails, while returning the original test failure status.
- No test, assertion, scenario, timeout, production behavior, legacy field or storage contract was removed or weakened. No deprecated Next Follow-up field or synthetic `followUpEnabled` value was introduced.

**Validation:** source remediation is not acceptance. Build, File Persistence, all seven Device Smoke lanes and Parallel Wave must report fresh results on one exact final SHA; screenshots must be present as actual run artifacts and validated by their logs.

**Governance:** PR #3052 remains OPEN / DRAFT / UNMERGED. No main changes, merge, APK Matrix build or release. **BLOCKED — RELEASE: NO-GO**.


## Wave 7.277 — analyzer correction for literal shell contract — 2026-11-02

**Base SHA:** `c9bb9a6cd21accbaca930130cc951cbfde95924e`. The first Wave 7.276 Build Analyze run identified one Dart test-source error: the shell token `$device` inside a normal Dart string was treated as Dart interpolation (`undefined_identifier`, `test/device_smoke_workflow_contract_test.dart:125:46`). The assertion now uses a raw Dart string so it checks the literal serial-qualified shell command. No workflow behavior, product code, test, assertion, or scenario was removed.

**Validation:** this correction requires a fresh Build, File Persistence, seven-lane Device Smoke and Parallel Wave result on the new exact SHA. The earlier Parallel Wave contract result does not replace Build Analyze evidence.

**Governance:** PR #3052 remains OPEN / DRAFT / UNMERGED. Release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 7.278 — deterministic viewport interaction and resilient Device Smoke diagnostics — 2026-11-02

**Base SHA:** `0322a91b3326f04caa2eb06129dcdcd376dfbe08`. This checkpoint changes only the Device Smoke runner script, the file-backed Alarm Overlay test interaction, and this audit documentation.

- `.github/workflows/device-smoke.yml`: replaced the embedded Bash payload with a single initialized-state flow. ADB discovery state, device listing, boot property and API level have safe defaults; timeout diagnostics use safe expansions under `set -u`, print the complete device listing and attempt a real diagnostic screenshot only when the emulator transport is online. The screenshot path is anchored to `GITHUB_WORKSPACE/artifacts/device-smoke`, while the upload contract remains the existing workspace-relative path. Flutter Drive logs remain captured; the single transport-only retry remains; screenshot capture/PNG signature/size checks remain independent of test outcome, and a failed integration test still exits non-zero.
- `test/alarm_overlay_file_persistence_test.dart`: replaced gesture-based scrolling in the T14–T14a gate with bounded, non-animated `ScrollPosition.jumpTo` increments and one finite 100ms frame pump per increment. Added T14.1–T14.5 markers to identify the exact interaction boundary. The actual keyed Complete control must still be fully inside the viewport and is still tapped; the real notification cancellation, handler completion, same-file SQLite close/reopen, and persisted Task completion/reminder-isolation assertions remain mandatory.
- No test, scenario, assertion, timeout limit, production handler, schema, or persistence requirement was removed, weakened, or skipped. No legacy Next Follow-up or `followUpEnabled` field was introduced.

**Validation:** source and workflow changes are not acceptance evidence. Build, File Persistence, all seven Device Smoke lanes with registered valid PNG artifacts, and Parallel Wave must complete on this exact new SHA. PR #3052 remains OPEN / DRAFT / UNMERGED; main, merge, APK Matrix and Release remain blocked. **BLOCKED — RELEASE: NO-GO**.


## Wave 7.279 — inline ADB discovery and explicit execution-stage tracing — 2026-11-02

**Base SHA:** `282fffcbb20a750c2c9ac31ffb4bead7866c0aeb`. Device Smoke Run `41410116463`, Boot Job `125161154388`, reached `ADB_DEVICE_READY` after the emulator reported boot complete, but the action terminated immediately afterward: no `ADB_DEVICE`, Flutter Drive, screenshot-capture marker or PNG artifact was emitted. The emulator's later `stop: Not implemented` message occurred during action cleanup and is not treated as the initiating cause.

- `.github/workflows/device-smoke.yml`: moved initial ADB serial discovery out of the helper-function return path and into an explicit bounded loop. Added stage markers after ADB discovery, boot completion, API validation, Flutter Drive and screenshot capture. Device state and diagnostic fields remain initialized and safe under `set -u`; timeout paths preserve ADB listings and best-effort diagnostic screenshots. The transport-only retry and non-zero propagation of integration-test failures remain intact. Screenshot output stays anchored to the workspace artifact directory and is still checked for PNG signature and size.
- The new stage markers are intended to prove whether the action proceeds beyond the previously observed ADB-ready boundary; they do not themselves constitute test or screenshot acceptance.
- No tests, assertions, scenarios, retry policy, timeout limit, production behavior or persistence checks were removed or weakened. No deprecated Next Follow-up or `followUpEnabled` field was added.

**Validation:** Build, File Persistence, seven-lane Device Smoke with actual uploaded PNGs, and Parallel Wave must all finish on one exact final SHA. PR #3052 remains OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.
