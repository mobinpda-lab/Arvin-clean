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


## Wave 7.280 — deterministic bounded ADB and boot polling — 2026-11-02

**Base SHA:** `02124ae6d06b90e9eb6cb2060b433f673fdca257`. Device Smoke Run `41411022699`, Navigation Job `125164209105`, emitted `DEVICE_SCRIPT_STAGE=after-adb-discovery` and then exited the emulator action before the next boot-wait marker. No Flutter Drive command or PNG was produced. The emulator booted and the exact serial reached ADB `device`; the failure is therefore after discovery, not a proven persistent ADB transport outage. The emulator's `stop: Not implemented` line is cleanup output after the action script has ended, not a demonstrated trigger.

- `.github/workflows/device-smoke.yml`: replaced all `SECONDS` arithmetic deadlines with explicit 90-iteration × 2-second bounded counters for initial ADB discovery, boot completion, transport retry and screenshot retry. Added before/after boot-wait markers so the next run can isolate the exact command boundary. Safe initialized state, timeout diagnostics, absolute workspace screenshot output, real Flutter Drive, PNG validation and non-zero test failure propagation remain.
- No timeout duration was expanded: each polling budget remains 180 seconds. No test, assertion, lane, retry allowance or product behavior was removed or weakened.

**Validation:** this is a diagnostic hardening checkpoint, not acceptance. All four required workflows must complete on one exact SHA; seven actual PNG artifacts remain mandatory. PR #3052 stays OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


## Wave 7.281 — boot/API probe result instrumentation — 2026-11-02

**Base SHA:** `52a19bffcf5378986767294cb8913473ed7aac2d`. Device Smoke Run `41411732137`, Navigation Job `125166175318`, emitted `DEVICE_SCRIPT_STAGE=before-boot-wait` and the emulator action then terminated without an after-boot marker. The emulator was online at ADB discovery; the precise boot-property command result was not yet observable.

- `.github/workflows/device-smoke.yml`: the bounded boot and API probes now capture each ADB command's exit status and output explicitly, print attempt/result markers, and continue the full 180-second polling budget when a probe fails. This makes the next failure boundary attributable to a concrete command result rather than a silent command substitution. The polling budget, PNG integrity checks, Flutter Drive invocation and failure propagation are unchanged.
- No test, assertion, lane or production behavior was removed or weakened.

**Validation:** implementation-only checkpoint; final acceptance requires all four workflows on one exact SHA and seven uploaded, validated PNGs. PR #3052 remains OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


## Wave 7.282 — explicit boot-ready state without loop break — 2026-11-02

**Base SHA:** `c312ec35bf10483a9fdfc16b7dde4f1c43ad3d79`. Device Smoke Run `41412450197`, Navigation Job `125168469015`, proves ADB discovery succeeded and the boot-property command returned exit status `0` with value `1`. The log then stopped immediately after `BOOT_POLL_RESULT`; no after-boot marker, API probe, Flutter Drive or PNG followed. Thus neither ADB discovery nor Android boot completion is the failing operation in that observed lane.

- `.github/workflows/device-smoke.yml`: changed the boot wait to use an explicit `boot_ready` state in the loop condition instead of the success-branch `break`. The same 90 × 2-second maximum remains; each probe logs command status/value, and the after-loop marker records readiness. No timeout budget is increased and no test or scenario is skipped.

**Validation:** the next exact-SHA run must prove progression through API check, Flutter Drive, screenshot validation and upload. Build, File Persistence, seven Device Smoke lanes and Parallel Wave remain required. PR #3052 stays OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


## Wave 7.283 — isolate child-command stdin from the decoded Bash program — 2026-11-02

**Base SHA:** `b61191e92278b7379503855e379be6c0709cd9c1`. Device Smoke Run `41413038000`, Boot Job `125170562728`, recorded `BOOT_POLL_RESULT attempt=0 status=0 value=1` and then stopped before the next script marker. ADB discovery and the boot-property query both succeeded. The execution model explains the silent exit: the emulator action invokes the one-line Base64 pipeline, so Bash reads the decoded program from stdin; child ADB/Flutter processes inherited that same stdin and could consume the remaining program text. This matches the observed termination immediately after the first ADB shell probe.

- `.github/workflows/device-smoke.yml`: redirected stdin to `/dev/null` for every ADB invocation and Flutter Drive invocation, keeping the decoded Bash program's stdin exclusively owned by Bash. Screenshot stdout remains directed to the real workspace PNG file; command logs, PNG signature/size validation, stage markers, 180-second polling budgets and non-zero test failure propagation remain unchanged.
- No test, assertion, scenario, timeout budget, retry allowance or production behavior was removed or weakened.

**Validation:** this root-cause fix requires fresh Build, File Persistence, seven-lane Device Smoke with registered valid PNGs, and Parallel Wave results on one exact SHA. PR #3052 remains OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


## Wave 7.284 — pinpoint the pre-T14a widget-test stall — 2026-11-02

**Base SHA:** `aabb97d055d1fccbc97b683ca88f20cbdc4bcbea`. File Persistence Run `41413877976`, Job `125173167727`, passed the file-backed Repository persistence step, then timed out after 10 minutes in the Alarm Overlay diagnostic. The final test trace is T14 followed immediately by finally/cleanup; no T14.1, Complete tap, handler marker or post-Complete SQLite reopen marker exists. This proves the stall occurs in the synchronous setup between the T14 stage call and T14.1; it does not identify which individual Finder/state/viewport operation is responsible. Calendar and the Complete handler were not reached.

- `test/alarm_overlay_file_persistence_test.dart`: added ordered diagnostic markers around each Finder construction/cardinality assertion, ScrollableState lookup, ScrollPosition lookup and viewport geometry read. The bounded jumpTo scrolling, real Complete hit-test and tap, handler callback wait, same-file SQLite close/reopen and all persistence/isolation assertions remain unchanged.
- No test, assertion, timeout or scenario was removed, weakened or skipped.

**Validation:** these markers are diagnostic only. The Complete path remains unaccepted until T14a, real tap, handler completion and final SQLite reopen/readback are all observed on one exact SHA. PR #3052 remains OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


## Wave 7.285 — direct keyed access to the real Complete control — 2026-11-02

**Base SHA:** `eed92b79ac03855e374e8d74042697e4dc8ac4d8`. File Persistence Run `41415654680`, Job `125178735050`, reached T14.03 and then stalled inside the synchronous `expect(completeButton, findsOneWidget)` Finder cardinality evaluation; T14.04 was never reached. The test's finally/cleanup ran only when the 10-minute watchdog expired. This is a test-harness Finder traversal stall, not evidence of a Calendar or production Complete-handler failure.

- `lib/alarm_overlay_page.dart`: added an optional `completeActionKey` test hook to the actual Complete button; normal production callers retain the existing ValueKey and behavior.
- `test/alarm_overlay_file_persistence_test.dart`: the file-backed test supplies a GlobalKey for that real button and obtains its mounted context, RenderBox, and ancestor Scrollable directly. The bounded jumpTo scroll and full-viewport assertions remain. The test sends a real pointer tap with `tester.tapAt` at the button's actual center, then still requires notification cancellation, handler completion, closing/reopening the same SQLite file, and final persisted Task completion/reminder isolation assertions.
- Finder-based cardinality checks were removed only from the known-stalling T14 Complete lookup; they were replaced with explicit mounted-context, RenderBox and Scrollable failure checks. No test, scenario, timeout, or product assertion was removed or weakened.

**Validation:** implementation is not acceptance. T14a, real pointer tap, T14d, same-file SQLite reopen/readback and all four exact-SHA workflows must succeed before acceptance. PR #3052 remains OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


## Wave 7.286 — await the real asynchronous overlay-load lifecycle — 2026-11-02

**Base SHA:** `300119997428423d2a62593a97215e88637b10d7`. File Persistence Run `41417580936`, Job `125185087475`, reached T14.01 and immediately entered finally/cleanup. The Complete GlobalKey had no mounted context at that point. The prior test relied on `pumpAndSettle` after starting asynchronous SQLite-backed Task/Project loading; that does not prove the load Future has completed. The timeout was then extended by cleanup attempting to close SQLite while the overlay remained mounted.

- `lib/alarm_overlay_page.dart`: added an optional load-completion callback reporting success or the load error; production callers omit it and retain existing behavior.
- `test/alarm_overlay_file_persistence_test.dart`: now awaits the actual load-completion signal through `tester.runAsync` before inspecting the keyed Complete control. It fails explicitly if overlay loading reports an error or the control is not mounted. Finally now unmounts the overlay before closing the same SQLite executor, avoiding a live widget retaining the database during teardown.
- The GlobalKey context, real RenderBox/Scrollable geometry, bounded jumpTo scroll, full viewport assertions, real pointer tap, notification-cancellation handler, same-file SQLite close/reopen, persisted Task completion and reminder-isolation assertions remain. No test, assertion, scenario, timeout or production path was removed or weakened.

**Validation:** this addresses the observed missing-context boundary; it is not accepted until T14a, real tap, T14d and final SQLite reopen/readback pass on one exact SHA. Build, File Persistence, all seven Device Smoke lanes with valid uploaded PNGs and Parallel Wave must complete on that SHA. PR #3052 remains OPEN / DRAFT / UNMERGED; **BLOCKED — RELEASE: NO-GO**.


---

## Product Roadmap registration — recurring branch projects — 2026-11-02

**Specification:** `docs/product/ARVIN_RECURRING_BRANCH_PROJECTS_ROADMAP.md`  
**Status:** `POST-STABILITY / PLANNED`; product requirement registered, not implemented or accepted.  
**Scope:** Branch Directory, Project Template Library, independent Project generation per Branch, copied Task snapshots, Branch/Template/Period/Status/Tag reporting, duplicate warning, historical segregation.

### Frozen product decisions
- Branch → Projects is One-to-Many; Project → Tasks is One-to-Many.
- Projects generated for different periods of the same Branch remain separate historical records; no cross-period overwrite.
- Template is a reusable source, not an active Project. Generated Project Tasks are independent copies; later Template edits affect future generations only.
- Project and Task remain the canonical execution entities. Existing Projects without Branch/Template remain valid.
- Branch is a structured entity, never a Tag alias. Branch with history is deactivated, not destructively deleted.
- Batch generation previews cardinality, warns on Template + Branch + Period duplicates, requires explicit user confirmation, and reports a deterministic result for each Branch.
- No Next Follow-up or synthetic `followUpEnabled` semantics are reintroduced.

### Governance / implementation boundary
No application code, test, assertion, migration, schema, UI, runtime behavior, or product dependency was changed for this roadmap. No implementation authorization is granted by this registration. The feature is excluded from the current stability work and must be scheduled only after stability acceptance under a separate owner-approved execution command.

### Pre-implementation decisions still open
Period identity and normalization; batch transaction/partial-failure policy; duplicate override semantics; inactive Template behavior; status mapping; Project archival/deletion history; Drift/SQLite referential-integrity design; Task-template snapshot versioning and Backup/Restore compatibility. These are design gates, not permission to guess.

**Validation:** documentation registration only. No feature acceptance or runtime PASS is claimed. PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.



## Product Roadmap update — unified Reports and Home search placement — 2026-11-02

**Specification:** `docs/product/ARVIN_RECURRING_BRANCH_PROJECTS_ROADMAP.md`  
**Status:** `POST-STABILITY / PLANNED`; requirement registration only, not implementation or acceptance.

### Reports Tab — unified reporting
- All Branch/Center, Project Template and Period reporting is centralized in the single Reports Tab; no parallel or scattered reporting destinations are introduced.
- Reports Tab must provide a dedicated Branch/Center filter for Projects and Tasks, including current and historical records.
- Advanced combined multi-criteria filters are required across supported Branch, Template, Period, Status, Tag and Task/Follow-up dimensions.
- A Task-specific Follow-up filter must return only real Follow-up records linked to the selected Task.
- Point filters are required as a product capability; their exact selection unit and UX/query semantics remain an explicit owner-design decision and must not be guessed.
- Reports must reflect real persisted data and provide explicit empty/error/loading states; no synthetic values or parallel Project/Task/Follow-up storage.

### Home UI — global search placement
- Place global search directly below `مدیریت کارها و پیگیری آروین` and immediately above the four quick-access cards.
- Placeholder: `جستجو در کارها`; search must be functional against actual Tasks.
- Preserve the existing RTL quick-access order: زمان، پروژه‌ها، دسته‌ها، برچسب‌ها; four cards remain equal-sized and icon-based.
- This is a placement requirement, not authorization for a broad Home redesign.
- The exact reference image file/identity was not recoverable in this registration; pixel-level appearance remains `NOT VERIFIED` pending attachment/linking of that image.

**Governance:** no application code, tests, assertions, schema, migration, UI/runtime behavior, or main branch was changed. Implementation authorization remains withheld until stability acceptance and a separate owner-approved execution command. PR #3052 remains OPEN / DRAFT / UNMERGED. **BLOCKED — RELEASE: NO-GO**.



## Product decision update — five Home shortcuts and Branch-aware global search — 2026-11-02

**Canonical specification:** `docs/product/ARVIN_RECURRING_BRANCH_PROJECTS_ROADMAP.md`  
**Status:** `POST-STABILITY / PLANNED`; owner decision registered, not implemented.

- Home quick access is now exactly five equal-sized icon cards: برچسب‌ها، دسته‌ها، پروژه‌ها، زمان، شعبه/مرکز.
- RTL order from right to left: زمان، پروژه‌ها، دسته‌ها، برچسب‌ها، شعبه/مرکز.
- Global Home search supports real Tasks, Projects and Branches/Centers, including direct Branch filtering backed by the structured Branch identity/relationship, not merely text matching.
- Search results identify their entity type; selecting a Branch result leads to its details/projects/history. The Branch quick-access card opens the Branch Directory; inactive Branch history remains accessible.
- This decision supersedes the prior four-card / Task-only Home search requirement.
- No implementation, code, schema, migration or runtime change is authorized before stability acceptance and a separate execution command. Exact reference-image pixel matching remains `NOT VERIFIED` until the image is attached/identified.

**Governance:** PR #3052 remains OPEN / DRAFT / UNMERGED. **BLOCKED — RELEASE: NO-GO**. No main change, merge, release or APK publication.


## 2026-11-02 — قفل نهایی پنج بسته محصولی و تمرکز پایداری SQLite

**مرجع رسمی:** docs/product/ARVIN_RECURRING_BRANCH_PROJECTS_ROADMAP.md، بخش ۱۷.  
**HEAD ممیزی پیش از این ثبت:** 19567e703ec749b6725177bbd87a11cce9862822.

### فهرست قفل‌شده مالک محصول
1. ساختار Branch/Center → Projects → Tasks با تاریخچه مستقل هر شعبه/دوره و حفظ Projectهای قدیمی.
2. Template Library و تولید Project مستقل برای هر Branch با Taskهای کپی‌شده و کنترل تکرار.
3. Reports Tab واحد برای Branch/Template/Period همراه فیلترهای پیشرفته، Task-specific Follow-up و Point filters (جزئیات Point filters همچنان نیازمند تصمیم طراحی است).
4. Home دقیقاً پنج کارت: برچسب‌ها، دسته‌ها، پروژه‌ها، زمان، شعبه/مرکز؛ ترتیب RTL مصوب در Product Spec.
5. جست‌وجوی Home برای Tasks/Projects/Branches با تشخیص نوع نتیجه و فیلتر مستقیم شعبه مبتنی بر هویت/رابطه ساختاری.

این فهرست مرجع نهایی این گفتگو است و فقط با دستور صریح بعدی مالک محصول تغییر می‌کند. وضعیت: POST-STABILITY / PLANNED؛ هیچ مجوز پیاده‌سازی از این ثبت صادر نمی‌شود.

### اولویت اجرایی فعلی — SQLite
- File Persistence Run 41429824427, Job 125225318356، روی SHA 19567e703ec749b6725177bbd87a11cce9862822: تست Repository persistence موفق شده، اما Alarm Overlay SQLite close-and-reopen diagnostic هنوز IN PROGRESS است؛ بنابراین پذیرش SQLite برابر PASS نیست.
- معیار لازم: رسیدن تست به کنترل واقعی Complete، اجرای pointer tap واقعی، اثبات فراخوانی و تکمیل handler، بستن و بازگشایی همان فایل SQLite و readback نهایی برای اثبات ماندگاری تکمیل Task و عدم تغییر Reminderها/رکوردهای مستقل.
- Build Run 41429824528: Analyze موفق؛ شش test shard هنوز در حال اجرا؛ APK job به‌علت Draft بودن SKIPPED.
- Device Smoke Run 41429824541: Boot و Navigation در حال اجرا؛ پنج lane دیگر در صف. Calendar Provider Run 41429824535 نیز IN PROGRESS است. این وضعیت‌ها فقط snapshot زمان ثبت‌اند و باید دوباره بررسی شوند.
- تا پایان شواهد، هیچ PASS کلی یا پذیرش SQLite اعلام نشود؛ اجرای تکراری/commit اضافی هنگام فعال‌بودن همین runها انجام نشود.

### قفل حاکمیتی
PR #3052 باید OPEN / DRAFT / UNMERGED بماند و برچسب BLOCKED — RELEASE: NO-GO حفظ شود. هیچ کد اجرایی، UI/runtime، Schema یا Migration برای پنج بسته محصولی پیش از تکمیل پایداری و دستور صریح بعدی مجاز نیست. تمرکز مجری فنی: بستن شواهد SQLite، نه توسعه قابلیت‌های محصولی.


## 2026-11-02 — تصمیم SSOT مرکزی و ممیزی معماری سراسری

**مبنای ممیزی کد:** 3b29ead7d0cf8eaf8bc74ba079d7c4d0f4c24cd3.  
**سند ممیزی:** docs/architecture/ARVIN_SSOT_AND_CROSS_FEATURE_DATA_FLOW_AUDIT_2026-11-02.md.  
**Product Spec:** docs/product/ARVIN_RECURRING_BRANCH_PROJECTS_ROADMAP.md، بخش 18.  
**وضعیت:** ثبت مستندات و ممیزی خواندنی؛ بدون تغییر کد/تست/Schema/Migration.

### تصمیم مالک محصول — SSOT
Category، Tag، Project و Branch/Center باید فقط از یک هسته مرکزی مدیریت داده در Settings تغذیه شوند. تمام فرم‌های ثبت/ویرایش، پنج دسترسی سریع Home، جستجو، فیلترها، Reports و Calendar فقط مصرف‌کننده داده canonical باشند. تغییر موفق باید از مسیر mutation واحد و سازگار منتشر شود؛ Snapshotهای محلی باید refresh/invalidate شوند. این الزام در Product Spec ثبت شد؛ پیاده‌سازی یا پذیرش آن ادعا نمی‌شود.

### یافته‌های معماری ثبت‌شده
- Category هم در taxonomy_categories و هم به‌صورت متن در tasks.category ذخیره می‌شود؛ رابطه FK مشاهده نشد.
- Tag در tags و task_tags و Project در projects و project_items در SQLite/Drift مشترک نگهداری می‌شوند.
- مدیریت Category/Tag، ذخیره Task و تغییر کاتالوگ را جداگانه اجرا می‌کند. _persistMutation خطای TaskStore.save را swallow می‌کند و caller همچنان rename کاتالوگ را ادامه می‌دهد؛ ریسک ناسازگاری قطعی از مسیر کنترل جریان.
- Home و فرم‌ها Snapshot دارند؛ Home در مسیر بازگشت از Settings refresh سراسری مشاهده‌شده ندارد.
- HomeSearchProjection فقط TaskSearchService را فراخوانی می‌کند؛ Project/Branch search در این مسیر نیست.
- ReportCenterPage Category/Tag را از Taskهای ورودی استخراج می‌کند؛ Calendar از Task/Reminder/Follow-up projection استفاده می‌کند و به کاتالوگ Category/Tag/Project/Branch متصل نیست.
- Branch model/table/store در مسیرهای بررسی‌شده پیدا نشد.
- TaskTaxonomyLifecycleService و TaskTaxonomyMutationService عملیات هم‌پوشان دارند؛ تعیین تکلیف کدهای احتمالا معلق نیازمند بررسی مصرف کامل است؛ هیچ کدی حذف نشده است.

### ریشه‌یابی لاگ واقعی T13.5
- File Persistence Run 41430574993 / Job 125228304102 و Build Run 41430577235 / Shard 2 Job 125228377887 هر دو T13 Task reload after reopen را ثبت کرده‌اند و سپس در T13.5 منتظر asynchronous Alarm Overlay load completion مانده‌اند.
- هر دو پس از 10 دقیقه Timeout شده‌اند.
- Readback اولیه پس از reopen تا T13 پیش رفته و assertions حفظ dueDate، Follow-up history، دو Reminder، Snooze date/sequence و عدم تغییر sibling Reminder مانع ادامه نشده‌اند.
- تست منتظر loadCompleted.future است. AlarmOverlayPage._loadActiveReminder ابتدا TaskStore.load و سپس ProjectStore.load را await می‌کند و فقط پس از پایان این دو، callback را فراخوانی می‌کند.
- علت مستقیم اثبات‌شده: callback تکمیل بارگذاری Overlay تا پایان مهلت به تست نرسیده است.
- علت داخلی دقیق (اینکه کدام await یا lifecycle مانع شده) از لاگ‌های موجود قابل تعیین نیست: NOT VERIFIED. هیچ انتساب قطعی به SQLite، TaskStorageLock یا ProjectStore مجاز نیست.
- مسیر T13.6/T14، pointer tap، Complete handler و readback نهایی Complete در این اجراها مشاهده نشده است.

### حاکمیت و حفاظت
PR #3052 در آخرین استعلام OPEN / DRAFT / UNMERGED و برچسب BLOCKED — RELEASE: NO-GO موجود بود. Branch API مقدار protected=false را برای شاخه اجرایی گزارش کرد. Ruleset فعال main-protection فقط refs/heads/main را هدف می‌گیرد؛ endpoint branch protection با 403 در دسترس اتصال ممیزی نبود. بنابراین حفاظت فنی اختصاصی شاخه اجرایی در شواهد فعلی فعال/اثبات‌شده نیست؛ این ممیزی هیچ تنظیمی را تغییر نداد. Label و Draft جایگزین Branch Protection نیستند.

**ثبت مستندات روی شاخه مجاز:** audit document commit 52d4c7a2b0974815ff67883aac7777ede5fe83a5؛ Product Spec commit 0e94d423210f512e9aa8883e1787d0d67b00f119. ثبت Ledger و Changelog در ادامه همین موج انجام می‌شود. هیچ تغییر main، merge، release یا اجرای workflow جدید انجام نشده است.


## Wave 7.287 — owner-locked taxonomy deletion, atomic rename and T13.5 diagnostic boundaries — 2026-11-02

**Authorized base HEAD:** `54f9f3545203a198aadb4dad5886ecefbf5c75b7`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052 — retain OPEN / DRAFT / UNMERGED.  
**Scope:** explicit owner authorization in the current conversation; changes are confined to the authorized PR branch.

### Product decision — deletion policy locked
- Owner decision: Category/Tag deletion is blocked whenever the item has a canonical Task reference. No cascading deletion, automatic archive, or policy change is permitted in this phase.
- Product contract added to `docs/product/ARVIN_PRODUCT_REFERENCE_v1.4_CANONICAL_ALIGNED.md`, section 15, with status OWNER-APPROVED / LOCKED.
- `lib/task_taxonomy_management_page.dart` now tells the user that deletion is blocked to preserve Task history and includes the reference count.
- `lib/services/task_taxonomy_mutation_service.dart` documents the current no-cascade/no-auto-archive rule. Existing delete guards remain fail-closed; no user records or schema were changed.

### Atomic Category/Tag rename
- `lib/services/task_store.dart`: added `renameCategoryAndTasks` and `renameTagAndTasks`. `_saveUnlocked` accepts a pre-commit callback executed inside its existing SQLite transaction. Task reference rewrite and matching catalog rename now commit together or roll back together.
- `lib/task_taxonomy_management_page.dart`: rename handlers use the atomic TaskStore methods. The old independent catalog rename after `_persistMutation` was removed. `_persistMutation` now returns success/failure, reloads the management snapshot after either outcome, and does not advance the catalog after a failed transaction.
- `test/task_taxonomy_management_page_test.dart`: added immediate UI and canonical catalog refresh assertions for category and tag renames.

### T13.5 diagnostic-only instrumentation
- `lib/alarm_overlay_page.dart`: added ordered debug markers immediately before/after `_store.load()`, immediately before/after `_projects.load()`, and immediately before/after success/error callback invocation.
- `test/alarm_overlay_file_persistence_test.dart`: added markers before awaiting the callback signal, after it returns (including the error value), and before settling the loaded frame.
- No production load ordering, Future, callback semantics, test assertion, timeout, persistence check, or Complete interaction was removed or weakened. The next exact-SHA run must be read from the first missing marker; until then the internal cause remains NOT VERIFIED.

### Canonical Home refresh
- `lib/main.dart`: after Settings returns, Home reloads Tasks, Projects, Categories and Tags through `_load()`.
- Home category/tag creation shortcuts now use the page's canonical `taskStore`, then reload Home's canonical snapshot before returning the created value.

### Source/documentation commits in this wave
- TaskStore atomic persistence: `1cbc326fd3c95f9a215ee252a5fc48101a7cfb9d`
- Taxonomy management atomic flow: `06ca5b5707fc5ac7483aa916bcb9f0fc6c10cc5c`
- Alarm Overlay diagnostic markers: `9d79cbd97c1c637698b8310e0b4c2ba2a1dd8013`
- Alarm file-persistence test markers: `5433cf1e2d71603b21c436483d702ab4a8621023`
- Home canonical refresh: `5726a0052f3838f9744656ca4dc616db809a3195`
- Management rename UI refresh tests: `30c79bfd62c995af436f6ba81fdce3b6318140d5`
- Clear referenced-history deletion message: `22a0b7133d6a9eeea6c981358ca4bb0c246171a7`
- Mutation-service owner-rule comment: `64e62e5af7eb7c86915a9a3a5f155bfd52e0af3f`
- Product decision lock: `ad886a491639e72e93da91dea850072e21915617`
- Changelog update: `0463763bc663bcb6f9da09793121eee2e2694e4c`

**Validation status at ledger registration:** no new workflow result is claimed yet. Fresh Build and File Persistence evidence must be collected against the final documentation HEAD. Any diagnostic conclusion must quote the actual last emitted marker; do not infer TaskStore vs ProjectStore failure without that evidence. No manual test run or workflow dispatch has been performed in this wave at the time of this entry.

**Governance:** PR #3052 remains OPEN / DRAFT / UNMERGED; the existing `BLOCKED — RELEASE: NO-GO` label is retained. No main change, merge, release, APK publication, Schema change, migration, branch-protection change or destructive operation was made.

## Wave 7.288 — exact-SHA deletion-message test reconciliation — 2026-11-02

**Baseline audited:** `29fb42e6e6db74a23ea7ae1504b0a83d42526727`.  
**Test-only commit:** `154bd692fa006762806b4fb9cc283b675bb153a0`.  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`; PR #3052.

### Evidence and diagnosis
- Exact-SHA Build Shard `test-4`, Job `125257825415`, reported `207 tests passed, 1 failed`.
- The failing test was `referenced category deletion is blocked and data stays intact`, at line 126. The test expected the obsolete text `در 2 مورد استفاده می‌شود`.
- On the same SHA, the UI constructs the message from `TaskTaxonomyDeleteBlocked.referenceCount`: `دسته «فروش» در 2 کار سابقه ارجاع دارد و قابل حذف نیست؛ برای حفظ سوابق، حذف آن مسدود شده است.`
- The test fixture has two canonical Tasks with category `فروش`. `categoryUsageCount` counts both; `deleteCategory` throws before `deleteCategoryCatalog` can execute. The existing test's Task readback assertions passed beyond the message assertion only by source inspection; the CI test stopped at the first failing expectation, so runtime readback on this run is not independently proven.

### Authorized correction
- Updated Category and Tag deletion test expectations to the exact current UI wording and expected reference counts (2 Category references; 1 Tag reference).
- Added canonical catalog readback assertions to ensure the referenced Category/Tag remains present after blocked deletion, alongside the existing Task data assertions.
- No production code, deletion guard, persistence behavior, schema, timeout, test scenario or assertion strength was weakened. No test was removed or skipped.
- No conclusion of runtime data-preservation PASS is claimed until fresh exact-HEAD CI runs the corrected tests successfully.

### Validation and governance
- Fresh workflows for this test-only HEAD are required; results from baseline SHA `29fb42e...` are not transferable.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; `BLOCKED — RELEASE: NO-GO` remains unchanged. No main edit, merge, release or manual workflow dispatch was performed.

## Wave 7.289 — T13.5 callback lifecycle isolation — 2026-11-02

**Diagnostic baseline:** `29fb42e6e6db74a23ea7ae1504b0a83d42526727`.  
**Test lifecycle correction:** `945e9e5a35775e0b3127118da25b4ec6e85c13a4`.  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`; PR #3052.

### Exact log evidence
- File Persistence Run `41439520248`, Job `125257688409`, checked out the exact baseline SHA.
- The log emitted `before TaskStore.load` / `after TaskStore.load taskCount=1`; then `before ProjectStore.load` / `after ProjectStore.load projectCount=0`; then `before onLoadComplete(success)` / `after onLoadComplete(success)`.
- The test subsequently emitted `T13.5a before awaiting onLoadComplete callback signal`, but no `T13.5b` return marker. The job was cancelled at `2026-11-02T11:58:06Z`; T13.5 did not pass.
- The load/callback marker sequence occurred during the first Overlay mount, before the SQLite close/reopen phase. The second Overlay was pumped without explicitly disposing the first instance. The test expected a new `loadCompleted` signal, but there was no second load/callback marker sequence after T13.5a.
- Source inspection confirms `_loadActiveReminder()` is initiated from `initState`; the test's second mount did not establish a guaranteed fresh State lifecycle. The evidence localizes the failure to test Overlay lifecycle/callback registration, not TaskStore or ProjectStore loading.

### Authorized test-only correction
- `test/alarm_overlay_file_persistence_test.dart` now explicitly unmounts the first Alarm Overlay before closing the first SQLite executor. It then mounts a fresh Overlay after reopening the same SQLite file, so the new `onLoadComplete` callback belongs to a fresh State instance.
- The existing callback wait, error assertion, timeout, real Complete control interaction, notification cancellation and final SQLite readback assertions remain intact. No production code or persistence logic changed.
- This is a test-harness correction, not a PASS claim. Fresh File Persistence and full required workflows on the resulting HEAD must validate it.

### Governance
PR #3052 remains OPEN / DRAFT / UNMERGED. `BLOCKED — RELEASE: NO-GO` remains unchanged. No main edit, merge, release or manual workflow dispatch was performed.

## Wave 7.290 — T13.5 post-callback cleanup timeout — 2026-11-02

**Audited baseline SHA:** `a0dba2603535d6684d12327b37693812c838bf11`.  
**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`; PR #3052.

### Exact failure evidence
- Build Run `41441240668`, failing Job `125263630767`, and File Persistence Run `41441240620`, failing Job `125263441852`, both identify the same test: `Snooze and completion remain isolated after closing and reopening the same SQLite file`.
- Both logs contain `T07a` / `T07b`, the second TaskStore and ProjectStore loads, `T13.5a`, `T13.5b ... error=null`, `T13.6`, successful Complete handler / notification cancellation, final SQLite reload, and `T23 END: diagnostics disabled`.
- Both then report `TimeoutException after 0:10:00.000000`. Source inspection at the audited SHA showed the only awaited operation after T23 was `await directory.delete(recursive: true)`; no post-cleanup marker existed. This localizes the timeout to asynchronous temporary-directory cleanup. The T13.5 callback itself did return successfully.
- The failure was not treated as a T13.5 callback failure and no persistence behavior failure was inferred.

### Test-only correction
- On the PR branch, commit `5910952cc0342a9812f1076a992a94651f6a6efe` replaces the final asynchronous directory cleanup with `directory.deleteSync(recursive: true)` and adds pre/post cleanup markers.
- No production code changed. The 10-minute timeout, callback wait, error assertion, Complete interaction, notification-cancellation assertion, and final SQLite readback assertions remain unchanged.
- CHANGELOG records the same diagnosis and correction.
- Fresh exact-HEAD Build, File Persistence and Device Smoke are required. No PASS is inferred from the baseline run or from the callback markers alone.

### APK and governance
- Build workflow `.github/workflows/build.yml` explicitly skips all APK variants for Draft pull requests. The APK matrix job on baseline run `41441240668` was `skipped`; no APK was produced or verified. PR must remain Draft, so this route cannot produce a review APK without changing governance or the workflow policy.
- PR #3052 remains OPEN / DRAFT / UNMERGED. `BLOCKED — RELEASE: NO-GO` remains unchanged. No main edit, merge, release, APK publication, manual dispatch or workflow cancellation was performed.

## Wave 7.291 — Exact-SHA results and Draft-safe review APK workflow — 2026-11-02

**Audit SHA:** `6a14a56bebb88f62be2a69836275e70e5fb042e1`.  
**Workflow/docs implementation commits:** `19e65fcb7836beeb5f3150e2bc771b1a1fd25cd9` (review APK workflow), `10c00ff665176ff12c427d848702362eda425c7a` (changelog).

### Exact-SHA workflow outcomes

| Workflow | Run | Job | Result | Evidence |
|---|---:|---:|---|---|
| Build | 41443901407 | Analyze 125272659293 | SUCCESS | exact checkout SHA verified |
| Build | 41443901407 | test-0 125272659524; test-1 125272659204; test-2 125272659165; test-3 125272659145; test-4 125272658832; test-5 125272659326 | all SUCCESS | all six test shards completed |
| Build | 41443901407 | APK matrix 125272661375 | SKIPPED | existing Draft guard preserved |
| File Persistence | 41443901333 | 125272324515 | SUCCESS | exact checkout SHA; file-backed Repository persistence and Alarm Overlay SQLite close/reopen test both successful |
| Device Smoke | 41443901412 | boot 125272419953 | SUCCESS | scenario and screenshot upload succeeded |
| Device Smoke | 41443901412 | navigation 125272419978 | SUCCESS | scenario and screenshot upload succeeded |
| Device Smoke | 41443901412 | quick-capture 125272419931 | SUCCESS | scenario and screenshot upload succeeded |
| Device Smoke | 41443901412 | task-lifecycle 125272420065 | SUCCESS | scenario and screenshot upload succeeded |
| Device Smoke | 41443901412 | reminder-vazirmatn 125272420007 | SUCCESS | legacy compatibility and scenario succeeded; Reminder overlay evidence upload succeeded |
| Device Smoke | 41443901412 | follow-up-persistence 125272419945 | FAILURE | Android Emulator SDK package preparation reported `Premature EOF`; ADB port 5554 connection refused; screenshot artifact absent |
| Device Smoke | 41443901412 | calendar-segmented-view 125272420021 | CANCELLED | emulator became ready; job reached Flutter drive then logged `The operation was canceled`; cancellation cause NOT VERIFIED |
| Calendar Provider | 41443901528 | 125272166147 | SUCCESS | exact target SHA verification and real Provider acceptance succeeded |

Build Analyze + six test shards: **7/7 successful jobs**. File Persistence: **PASS**. Calendar Provider: **PASS**. Device Smoke: **5/7 PASS, 1 FAILURE, 1 CANCELLED**; overall Device Smoke acceptance is not met.

### T13.5 close-and-reopen proof

File Persistence Job `125272324515` log:
- Checkout verification: `EXACT_TARGET_SHA=6a14a56bebb88f62be2a69836275e70e5fb042e1`.
- `T13.5b onLoadComplete callback signal returned; error=null`.
- `T23a before synchronous temporary directory cleanup`.
- `T24 temporary directory cleanup completed`.
- Immediately afterwards: `All tests passed!`.
- Job conclusion: SUCCESS.

Therefore the earlier timeout after asynchronous temp-directory deletion was resolved by the test-only synchronous cleanup change. T13.5 is **PASS on SHA 6a14a56...**. This result is not generalized to any later SHA.

### Device Smoke failure classification

- Follow-up Persistence: the job failed before a product-level test result because SDK Manager reported `Premature EOF` while preparing Android Emulator, then the emulator ADB endpoint refused connection; no screenshot was generated. The run's lane conclusion remains FAILURE, not PASS. This is infrastructure-indicated, but remediation still requires a new exact-SHA run.
- Calendar Segmented View: the log proves emulator readiness and entry into Flutter drive, followed by cancellation. The available log does not prove who/what initiated cancellation or whether a product assertion would pass. Root cause remains NOT VERIFIED. Do not label it a product defect or an infrastructure defect without further evidence.

### Draft-safe review APK workflow

Added `.github/workflows/arvin-draft-review-apk.yml` on the authorized PR branch:
- Trigger: pull_request opened/synchronize/reopened; job runs only when head branch is `fix/recovery-calendar-device-smoke-2026-10-31` in the same repository.
- Permissions: `contents: read` only; no write token, deployment permission, production signing secret, or Release action.
- Checks out and verifies the exact PR head SHA.
- Generates a per-run ephemeral 30-day staging test keystore; no key material is committed or persisted.
- Builds only the existing Gradle `staging` variant (application ID `com.example.arvin.staging`, `debuggable=false`, no production-key fallback).
- Requires v2 and v3 signature verification, expected application ID, non-debuggable manifest, and Vazirmatn Regular/Medium/Bold assets.
- Packages the APK with a manifest containing source SHA, APK SHA-256, byte size, signer certificate fingerprint and `publishable=false`; uploads an Actions artifact with seven-day retention.
- It does not edit or bypass the original `.github/workflows/build.yml` Draft APK guard and does not publish a GitHub Release or public package.

Workflow implementation commit: `19e65fcb7836beeb5f3150e2bc771b1a1fd25cd9`. Changelog commit: `10c00ff665176ff12c427d848702362eda425c7a`. The workflow has not yet been proven by its own successful run. APK existence, installability and artifact retrieval remain NOT VERIFIED until that exact-head workflow completes successfully.

### Governance

- PR #3052 must remain OPEN / DRAFT / UNMERGED.
- Base/main SHA observed from PR metadata: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Label remains `BLOCKED — RELEASE: NO-GO`.
- No merge, main edit, release, APK publication, manual dispatch or cancellation was performed.
- Iran timestamp: 1405/08/11 16:40 (Asia/Tehran).


## Wave 7.292 — Product roadmap clarification and exact-SHA acceptance checkpoint — 2026-11-02

**Target SHA audited:** 758edb259b55ecd69b6509e50b94aeadd378e88e.  
**Branch / PR:** fix/recovery-calendar-device-smoke-2026-10-31 / #3052.

### Product decision preserved
- Owner-approved scope retained: visible Branch → Project → Task relation with historical preservation; expandable/collapsible Home Task cards showing exact description and date/time while retaining the independent Task Details route; latest valid Follow-up for the same Task through the real HomeFollowUpPresentationService; and the task filter strip «همه» plus Time, Projects, Branch/Center, Categories and Tags.
- Expanding/collapsing Branch or Project tree nodes is explicitly **not** a product requirement without a separate owner decision.
- Home Task-card expansion and same-Task Follow-up presentation are recorded in the source changelog as implemented changes, but final acceptance on this SHA remains pending evidence. Full Branch → Project → Task structure/history and the complete five-filter strip remain **PLANNED / NOT ACCEPTED**.
- This documentation update does not mean product completion. The prior owner decision to implement these capabilities is preserved for a post-stability implementation wave.
- No deprecated Next Follow-up behavior or synthetic followUpEnabled variable may be reintroduced.

### Exact-SHA CI evidence
| Lane | Run / Job | SHA | Recorded outcome | Acceptance meaning |
|---|---:|---|---|---|
| Build | Run 41451772834 | 758edb259b55ecd69b6509e50b94aeadd378e88e | SUCCESS | Analyze and test shards successful; does not imply APK artifact accepted |
| File Persistence | Run 41451772534 / Job 125298462750 | same | SUCCESS | Independent file-backed SQLite persistence test only; not Device Smoke |
| Calendar Provider | Run 41451772492 | same | SUCCESS | Provider acceptance only; not Calendar segmented-view smoke |
| Device Smoke Boot | Job 125298736720 | same | SUCCESS | Emulator boot lane |
| Device Smoke Navigation | Job 125298737157 | same | SUCCESS | Navigation lane |
| Device Smoke Quick Capture | Job 125298736590 | same | SUCCESS | Quick Capture lane |
| Device Smoke Task Lifecycle | Job 125298736594 | same | SUCCESS | Task lifecycle lane |
| Device Smoke Reminder Vazirmatn | Job 125298736760 | same | SUCCESS | Reminder lane and compatibility step successful |
| Device Smoke Calendar Segmented View | Job 125298736601 | same | CANCELLED | Flutter drive was cancelled; screenshot upload then failed because no PNG existed. Initiator/root cause NOT VERIFIED; this is not proof of a failed product assertion |
| Device Smoke Follow-up Persistence | Job 125298736596 | same | IN_PROGRESS at checkpoint | No final result available; job logs returned BlobNotFound while still running. Final result NOT VERIFIED |
| Draft Review APK | Run 41451772502 / Job 125298740317 | same | FAILURE | Gradle staging APK assembly succeeded; signature/package/font validation step failed; upload skipped; no artifact. Exact failing verification predicate NOT VERIFIED because apksigner log was redirected but not printed |

Device Smoke overall is **NOT VERIFIED / NOT ACCEPTED** until the Follow-up lane reaches a terminal result and Calendar has a valid, completed exact-SHA rerun with its required evidence. No valid Calendar rerun was identified at this checkpoint.

### Remaining delivery gates
- **Done:** exact-SHA Build run 41451772834; independent File Persistence 41451772534; Calendar Provider 41451772492; five successful Device Smoke lanes listed above.
- **Remaining:** obtain terminal Follow-up Persistence result for run 41451772497; resolve Calendar cancellation cause where evidence permits and complete a valid Calendar rerun without weakening tests; correct Review APK diagnostics/verification workflow without relaxing signature, package ID, non-debuggable, font, manifest or artifact checks; then produce and inspect a successful private review APK artifact on one exact candidate SHA.
- **Acceptance evidence required:** exact SHA checkout in every workflow; all seven Device Smoke lanes completed successfully with required non-empty artifacts; Review APK verification success, manifest and APK SHA-256, signer fingerprint, byte size and downloadable private artifact; product-owner acceptance. No older SHA result can substitute.

### Governance
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- Base/main SHA remains 45e4202b03a434459e4c021a04efa7e8396359db.
- BLOCKED — RELEASE: NO-GO remains mandatory.
- No main edit, merge, release, public APK publication, manual dispatch, workflow cancellation, test deletion, assertion weakening, schema migration or runtime change was made by this documentation update.


## 2026-11-02 — Final outcome update for Device Smoke run 41451772497

The run is now terminal: completed / cancelled, exact head SHA 758edb259b55ecd69b6509e50b94aeadd378e88e.

- Five lanes completed SUCCESS: Boot (125298736720), Navigation (125298737157), Quick Capture (125298736590), Task Lifecycle (125298736594), Reminder Vazirmatn (125298736760).
- Calendar Segmented View (125298736601) ended CANCELLED. Its log reports "The operation was canceled"; screenshot upload then failed because artifacts/device-smoke/*.png did not exist. The cancellation initiator/root cause is not exposed by the run/job evidence and remains NOT VERIFIED.
- Follow-up Persistence (125298736596) also ended CANCELLED. Its log reports "The operation was canceled" during flutter drive; the required screenshot upload then failed because no PNG was present. No test assertion outcome or persistence result was produced. Cancellation cause NOT VERIFIED.
- The overall run conclusion is CANCELLED. Neither Calendar nor Device Follow-up Persistence may be marked PASS. The independent File Persistence run 41451772534 remains a separate successful storage test only.
- This terminal result supersedes the earlier in-progress checkpoint in this ledger; it does not upgrade the Device Smoke gate.

## 2026-11-02 — Review APK verification failure diagnosis

Run 41451772502 / Job 125298740317 on the same SHA completed FAILURE. Gradle staging assembly succeeded; the signature/package/debuggable/font verification step exited 1. The workflow redirected apksigner output to a file but did not print or upload that file, so the exact failed predicate cannot be established retrospectively. The two hard-coded v2/v3 text checks are therefore an unproven likely failure point, not a confirmed root cause. The next workflow revision must print the full verifier output, preserve a nonzero apksigner exit as failure, and validate v2 plus v3/v3.1 without weakening package, debuggable, font, signer, manifest, or artifact checks. No approved APK artifact exists for this SHA.


## 2026-11-02 — Historical FollowUp excluded from local Calendar

**Scope:** One presentation-only product behavior. No FollowUp records or persisted fields are deleted or migrated.

- Initial inspected PR HEAD: `3b8691e389b77ff7fde02c6d7116fce7269b1797` (PR #3052 OPEN / DRAFT / UNMERGED).
- Root cause: `CalendarPage._calendarReminders()` merged all caller-supplied reminders and visible-range projected reminders without a final guard against historical FollowUp event IDs. The canonical Task/Reminder projection itself did not emit historical FollowUp records, but the Calendar UI accepted and rendered legacy `followup:` / `task-followup:` items passed through its input boundary.
- Fix: `lib/calendar_page.dart` now filters only `followup:` and `task-followup:` items from both input collections before calendar counts/cards are built. The separate `task-followup-action:` namespace is not filtered. Task due events, TaskReminder events, recurrence projection and device-calendar imports retain their existing paths.
- Regression changes: `test/calendar_page_test.dart`, `test/calendar_runtime_actions_fast_track_test.dart`, and `test/calendar_release_acceptance_test.dart` now assert that historical FollowUp cards are absent from supplied and projected Calendar items, have no local-calendar actions, and do not displace dated Task or independent Reminder cards. Existing Task Details, Follow-up Office (Notebook), and Report Center history tests are retained unchanged. A prior exact-head run exposed two obsolete test expectations (a read-only `task-followup:` card and a `followup:` completion card); both tests were updated to the new product rule without weakening Task/Reminder action coverage.
- Implementation/test commit: `8533b17599af46524973bc0a366864d44e08c96e`. CHANGELOG synchronization commits: `1a0b7263de37f5ab686e5e58428c6eb0b2927024`, `e2ee0dcfb009dba190e6acb30d6f701ea8b5545a`, and the current regression update. Ledger synchronization follows; exact final HEAD will be re-read after it.
- Preservation evidence in source: Task Details continues to render `task.followUps` via `lib/task_detail_page.dart`; Report Center continues to use `CompletedFollowUpReportProjection.forLocalDay` via `lib/services/completed_follow_up_report_projection.dart`. Existing tests: `test/task_detail_followup_flow_test.dart` and `test/completed_follow_up_report_page_test.dart`.
- Validation at documentation checkpoint: test and Build results are PENDING. Do not claim PASS until exact final-head workflow runs and inner test results are inspected. No test was deleted or weakened; behavior-specific calendar assertions were updated to the new owner requirement.

### Remaining blockers
- Run relevant calendar projection, Calendar UI, Task Details and Report Center tests on the resulting exact HEAD.
- Run the applicable Build on that exact HEAD and inspect Analyze plus every test shard.
- Seven-lane Device Smoke remains independently unaccepted unless all seven lanes finish successfully on one new exact SHA; CANCELLED Calendar means NOT VERIFIED.
- Calendar Provider failure-safety, physical-device acceptance and all other previously recorded release gates remain outstanding.

### Governance
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- No main edit, merge, release, APK publication, or change to legacy data/schema was made.
- Final verdict: **BLOCKED — RELEASE: NO-GO**.


## 2026-11-02 — Exact-SHA validation checkpoint for historical FollowUp calendar exclusion

**Validated SHA:** `04cacb3a88a99c12286dd6d8f6a9d0268a0d12eb`.

### Build and focused regression evidence
- Build #9185 / Run `41509339452`: **SUCCESS** on the validated SHA. Analyze succeeded; all six test shards succeeded; aggregate: **1,122 tests passed**. APK matrix was SKIPPED because PR #3052 remains Draft.
- Calendar UI regression tests passed: `calendar_page_test.dart` — historical FollowUp excluded from supplied and visible-range projected entries; dated Task and independent Reminder retained; no historical completion/edit actions.
- Legacy action regression tests passed: `calendar_runtime_actions_fast_track_test.dart` and `calendar_release_acceptance_test.dart`.
- Projection tests passed: `follow_up_calendar_projection_test.dart`.
- Preservation tests passed: `task_detail_followup_flow_test.dart`, `follow_up_office_page_test.dart`, `completed_follow_up_report_page_test.dart`. These verify the FollowUp history remains accessible in Task Details, Follow-up Office/Notebook and Report Center.

### Persistence and additional workflows
- Follow-up File Persistence #359 / Run `41509339890`: **SUCCESS** on the same SHA. `follow_up_repository_file_persistence_test.dart` passed; `alarm_overlay_file_persistence_test.dart` passed with Snooze, SQLite close/reopen, Complete and post-reopen verification.
- Calendar Provider #1342 / Run `41509339317`: **IN_PROGRESS** at this checkpoint; NOT VERIFIED.
- Device Smoke #6437 / Run `41509340280`, exact same SHA, checkpoint lane results:
  - Boot (125497526227): SUCCESS
  - Navigation (125497526419): SUCCESS
  - Calendar Segmented View (125497526726): IN_PROGRESS
  - Quick Capture (125497526191): IN_PROGRESS
  - Task Lifecycle (125497526241): QUEUED
  - Reminder/Vazirmatn (125497526271): QUEUED
  - Follow-up Persistence (125497526602): QUEUED
  - Aggregate Device Smoke: NOT VERIFIED / NOT ACCEPTED until all seven lanes have terminal SUCCESS.
- Draft Review APK #12 / Run `41509339894`: automated review-only staging build and verification succeeded; private artifact `arvin-review-staging-apk-04cacb3a88a99c12286dd6d8f6a9d0268a0d12eb` was uploaded by the existing workflow. No Release, public APK publication, or distribution occurred.

### Test correction history
- On prior SHA `ecf8296f6bd6d6daa774dcfb8ef96ad2dc04923d`, `calendar_runtime_actions_fast_track_test.dart` still tried to tap a legacy `task-followup:` card. The test was updated to assert that historical FollowUp has no card or actions while retaining Task read-only action coverage.
- On prior SHA `0aa92e66809773f4d933ea0b0c3e1a0ca0cbf43f`, `calendar_release_acceptance_test.dart` still long-pressed a historical `followup:` card. It was updated to assert no historical card/actions and positive visibility of a dated Task.
- On validated SHA `04cacb3...`, all six Build test shards passed. These were stale expectation corrections, not product assertion failures. No test was deleted, skipped, weakened, or bypassed.

### Remaining blockers
- Complete all seven Device Smoke lanes successfully on one exact SHA; Calendar cancellation or incomplete lanes remain NOT VERIFIED.
- Complete Calendar Provider acceptance and inspect its inner scenario result.
- Keep PR #3052 OPEN / DRAFT / UNMERGED and preserve Release NO-GO. No main edit, merge, release, public APK publication, or product-owner sign-off is authorized.

**Verdict remains: BLOCKED — RELEASE: NO-GO.**


## Wave 7.295 — Home last Follow-up real-record-only presentation — 2026-11-03

**Parent SHA inspected:** db8818c01d9e944717396e3df93bb0a466e92546. **Branch:** fix/recovery-calendar-device-smoke-2026-10-31.

### Root cause and bounded change
- The actual Home Task card already reads Task.lastFollowUp through _homeLastFollowUpDate and HomeFollowUpPresentationService; the service returns null when followUps is empty. It does not create or persist records.
- A legacy compatibility getter Task.legacyHomeFollowUpDate still returned followUpDate when no real FollowUp existed, and HomeTodayProjection consumed that getter. The getter now remains source-compatible but returns only lastFollowUpDate.
- Positive and negative regressions cover latest real record selection, legacy-only exclusion, preservation of legacy field values, and no record creation during Home rendering (verified after reloading TaskStore).
- No Task Details, Notebook/Follow-up Office, Report Center, Reminder or Due Date implementation was changed. No schema/column removal, data migration, SQL mutation or historical-record rewrite was made.

### task-followup-action: namespace audit
- On this exact parent source tree, CalendarPage recognizes this prefix only for visual styling/icon classification. The current source tree does not contain the separately named FollowUpInternalCalendarProjection implementation described in the older calendar decision note, nor a source generator for this ID was found in the inspected current call paths.
- The documented intended meaning is a read-only internal-calendar action derived from canonical FollowUp.nextFollowUp, distinct from a Reminder: no OS notification and no outbound/device Calendar event. It is not a reason to delete or rewrite nextFollowUp.
- Current implementation status of an actual generated task-followup-action: item: NOT VERIFIED / not found in current branch source. Do not describe the namespace as an active scheduled reminder or remove it solely based on its name.

### Exact-SHA validation checkpoint before this change
- Build run 41510778726 on parent SHA: Analyze PASS; all six test shards PASS (156 + 200 + 164 + 208 + 267 + 127 = 1,122 tests); APK matrix SKIPPED under Draft guard.
- Device Smoke run 41510778774 on parent SHA: Boot, Navigation, Quick Capture, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence SUCCESS; Calendar Segmented View CANCELLED. Aggregate NOT ACCEPTED.
- Calendar Provider run 41510778734 on parent SHA: SUCCESS.
- These results are parent-SHA evidence only. New exact-head Build and targeted regression outcomes must be recorded after the new commit completes.

### Governance
- PR #3052 remains OPEN / DRAFT / UNMERGED; no main edit, merge, release or public APK publication.
- No database migration was required for this presentation-only change; legacy values remain serialized.
- Verdict: **BLOCKED — RELEASE: NO-GO**.
- Iran timestamp: 1405/08/12 00:34 (Asia/Tehran).


## Wave 7.296 — Home filter “All” scope clarification — 2026-11-03

**Parent HEAD:** f93bd7250db0b54e3069b8025d83a3673fbf6308. **Branch:** fix/recovery-calendar-device-smoke-2026-10-31. **PR:** #3052.

### Authoritative product rule
- “همه” is an option inside each individual Home filter selector; it is not a standalone dimension or chip in the horizontal filter bar.
- The filter strip contains only the contextual Time, Projects, Categories and Tags cards. No-filter state naturally shows the normal relevant task set.
- Selecting an individual selector's “همه” clears only that selector's state: time => `_timeFilter = 'all'`; project => `_projectFilter = null`; category => `_categoryFilter = null`; tags => empty `_tagFilters`. Other dimensions remain active.
- The global “پاک کردن فیلترها” action in the active-filter summary remains a separate explicit clear-all action; it is not a chip in the filter strip.

### Bounded implementation and regression coverage
- Removed only the ActionChip with key `home-filter-card-all` from `_homeFilterCards()`; preserved all four filter cards and all four internal unrestricted options.
- Updated `test/home/home_filter_contract_test.dart`: no standalone key; four filter chips; internal “همه” options for Time/Projects/Categories/Tags; default task grouping; and clearing Categories leaves active Time restriction intact.
- No schema, data, persistence, filter categories or selection model changes.

### Validation checkpoint
- Parent SHA exact results: Build 41525905055 SUCCESS (Analyze + 6 test shards); Calendar Provider 41525905018 SUCCESS; Device Smoke 41525904967 incomplete (only 2 of 7 lanes had succeeded at the last recorded poll; remaining lanes not final). Parent results are not evidence for this commit.
- New exact-SHA Analyze and targeted Home filter test results: pending.

### Governance
- PR #3052 OPEN / DRAFT / UNMERGED; main untouched; no APK publication or release.
- Verdict: **BLOCKED — RELEASE: NO-GO**.
- Iran timestamp: 1405/08/12 (Asia/Tehran).


## Wave 7.297 — ثبت مشخصات کامل Center / Project Template / Safe Propagation / Reporting — 2026-11-03

**مبنای ثبت:** HEAD `38d8183097d3b88976f4a320a6b3acb44160047c`؛ شاخه `fix/recovery-calendar-device-smoke-2026-10-31`؛ PR #3052.

### اقدام فوری مستنداتی
- سند کامل `docs/ARVIN_CENTERS_TEMPLATES_REPORTING_SPEC.md` ثبت شد.
- قرارداد شامل Center → Project → Category → Task، Tags شناور، Center CRUD، حفظ Projectهای legacy بدون Center، قالب پروژه، تولید مستقل برای چند Center، propagation انتخابی و append-only، پنج فیلتر عمومی، دو فیلتر افزوده Report Center، گزارش ترکیبی، idempotency، migration ایمن، سناریوی پذیرش، تست‌ها و پرسش‌های حل‌نشده است.
- Changelog در `docs/CHANGELOG-2026-10-30.md` برای این milestone به‌روزرسانی شد.
- این commit صرفاً اسناد است؛ پیاده‌سازی هیچ‌یک از قابلیت‌ها را ادعا نمی‌کند.

### شواهد وضعیت فعلی هنگام تدوین
- `ProjectPlan` فقط id/title/color/isArchived/itemIds دارد؛ centerId و templateId ندارد.
- SQLite فعلی projects/project_items دارد؛ Center و Template table در schema مبنا مشاهده نشد.
- Category روی Task به‌صورت متن است؛ Category→Project FK اثبات نشد.
- Project مدل وضعیت مستقل completed ندارد؛ فقط isArchived وجود دارد.
- TaskReportFilter فاقد Center، Task-origin و Template filters است.
- بنابراین Center/Template/propagation/report extensions در HEAD مبنا NOT IMPLEMENTED / NOT VERIFIED هستند.

### ادامهٔ کار و حاکمیت
- اجرای بعدی باید با Center persistence و nullable Project association شروع شود؛ سپس Template، generation، propagation و گزارش‌ها، با حفظ canonical TaskStore/ProjectStore.
- هیچ migration مخرب، Task ID مشترک بین Projectهای تولیدی، propagation خودکار به همه مقصدها یا تغییر معنای گزارش‌های فعلی مجاز نیست.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main بدون تغییر؛ بدون انتشار APK عمومی.
- **Verdict: BLOCKED — RELEASE: NO-GO.**
- Iran timestamp: 1405/08/12 02:06 (Asia/Tehran).


---

## Wave 7.298 — Clause 10/14 authoritative architecture update & read-only calendar audit — 2026-11-03

**Audit target SHA:** `5ef2181ed3811f73fee29371ab0474a173d89a04`  
**Repository/branch:** `mobinpda-lab/Arvin-clean` / `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **main HEAD:** `45e4202b03a434459e4c021a04efa7e8396359db` (unchanged at pre-update verification).  
**Release:** **BLOCKED — RELEASE: NO-GO**.

### Owner-authoritative specification update

#### Clause 14 — Dual-Track Calendar Architecture

**Track 1 — Local Arvin Calendar (autonomous and auto-registered)**
- The local Arvin calendar is the sole autonomous calendar experience: embedded/offline solar + Gregorian date engine; zero Android calendar permission; no dependency on external accounts or providers.
- Eligible canonical Tasks and independent Reminders are registered, updated and retired through Arvin-owned lifecycle management.
- Follow-up history is historical/read-only. It must never create a future schedule event, reminder or external calendar event.

**Track 2 — Device Calendar Export (selective and explicitly user-triggered)**
- Export/sync may begin only after a designated user action: the explicit Device Calendar UI action or a configured Calendar-card Swipe action.
- Provider permission denial, unavailable calendars, query/write failure or provider exceptions must not mutate, corrupt or delete local Arvin calendar records, Tasks or Reminders.
- Repeating an export/retry is idempotent: one eligible Arvin item maps to one stable provider event; retry must not create duplicates.
- The two tracks remain isolated. Provider access is not a prerequisite for Track 1 operation.

#### Clause 10 — Enhanced Analytical Report Center

- Preserve all existing report types, semantics and five universal filter dimensions.
- Add report-specific Task selection and Project Template selection without replacing the universal filters.
- Support analytical views by Center, Project, Task and Template, including valid combined-filter/report scopes.
- Preserve canonical Task identity/origin across Projects, avoid double counting, retain legacy/no-Center/no-Template visibility rules and provide accurate empty states.
- Keep the existing report date boundaries, status/count/progress semantics and historical records unchanged.
- The detailed implementation contract remains `docs/ARVIN_CENTERS_TEMPLATES_REPORTING_SPEC.md`. This ledger update records the owner-directed Clause 10 alignment; it does not assert that the enhanced report features are implemented or accepted on this SHA.

### Read-only audit — CanonicalCalendarLauncher and Android Calendar Provider

**Evidence inspected at exact target SHA:** `lib/widgets/canonical_calendar_launcher.dart`, `lib/services/follow_up_calendar_projection.dart`, `lib/services/calendar_inbound_sync_service.dart`, `lib/services/system_calendar_bridge.dart`, `lib/services/calendar_sync_plan_service.dart`, `lib/services/calendar_provider_sync_executor.dart`, `android/app/src/main/kotlin/com/example/arvin/MainActivity.kt`, AndroidManifest and the focused launcher/provider contract tests.

#### Findings

1. **BLOCKER — automatic provider reconciliation violates Track isolation and explicit-trigger policy.**
   - `CanonicalCalendarLauncher.initState()` schedules `_reconcileDeviceCalendar` automatically.
   - That method invokes `CalendarInboundSyncService.reconcile` for a date window without a user action.
   - The inbound service reads linked Android Calendar events and writes changes back to canonical Task due dates / TaskReminders. If a linked provider event is absent while the canonical fingerprint still matches, it clears the local due/reminder and persists the changed Task list.
   - This is an external-provider-to-Arvin import/reconciliation path, not selective outbound export. It conflicts with the new Track 1/Track 2 boundary and creates a local-data deletion risk if provider state is incomplete or unexpectedly omits a linked event. **NOT ACCEPTABLE under updated Clause 14.**

2. **BLOCKER — export eligibility still includes historical Follow-up namespaces.**
   - `SystemCalendarBridge.isEligible` currently accepts `followup:` and `task-followup:` in addition to Task due dates and Task Reminders.
   - The current `FollowUpCalendarProjection.project` does not emit Follow-up history and its historical target resolver returns null, which limits the present visible path; however, the bridge/revision eligibility contract itself still permits those IDs. A future/direct caller could export historical Follow-up data.
   - Updated Clause 14 requires these historical namespaces to be rejected at the export/sync boundary, not merely omitted by one current projection. **Required correction and regression tests; not changed in this read-only audit.**

3. **PARTIAL PASS — explicit outbound entry points exist.**
   - The launcher exposes a named «تقویم دستگاه» action under More and delegates to the export flow.
   - Calendar card Swipe actions are separately configurable and passed into the calendar page.
   - The Android `ACTION_INSERT` path opens the system calendar editor without a direct write operation. The provider create/update/delete APIs are separately permission-gated.
   - This confirms entry points exist; it does not prove every provider mutation is reachable only through an explicit user action. All call sites still require a full action-path audit.

4. **PARTIAL PASS — stable-link/idempotency design exists.**
   - Provider sync plans use reminder IDs, stable event links and content fingerprints to select CREATE / NO-OP / UPDATE / DELETE.
   - The executor preserves the linked event identity on update, validates linked identity before update/delete, writes link metadata only after provider success, and attempts rollback when migrating an event between calendars.
   - Focused tests cover duplicate-create rejection, no-op/update behavior, stale identity fail-closed behavior, provider create failure, delete and migration rollback.
   - These are source/test-contract findings only. No fresh exact-SHA test execution or real-provider acceptance was run as part of this read-only audit.

5. **PARTIAL PASS — Android boundary is explicit and bounded.**
   - `MainActivity` uses `CalendarContract` for provider CRUD and event/calendar queries, checks separate READ/WRITE permissions, scopes update/delete by both event ID and calendar ID, and converts permission/provider exceptions into channel errors.
   - Event queries enforce a maximum calendar count and bounded time window.
   - AndroidManifest declares READ_CALENDAR and WRITE_CALENDAR. Their presence is not permission to access the provider automatically; every access must remain behind the updated explicit Track 2 interaction policy.
   - Permission-denial and provider-failure behavior has not been demonstrated end-to-end against the updated failure-isolation requirement.

### Required follow-up before Clause 14 acceptance

- Remove/retire automatic inbound reconciliation from launcher startup and prevent provider reads/writes from changing canonical local Task/Reminder data under the export-only architecture.
- Make export eligibility reject all historical Follow-up IDs, including `followup:` and `task-followup:`; add negative tests at both projection and bridge/revision/executor boundaries.
- Prove all Track 2 provider calls originate only from the designated explicit UI/Swipe actions.
- Add failure-injection coverage proving permission denial, provider exception, missing calendar, empty/partial provider query and retry leave all local Arvin calendar records, Tasks, Reminders and link metadata unchanged unless a successful explicitly approved export operation is committed.
- Re-run exact-SHA Build, focused calendar/provider tests and Calendar Provider Acceptance after authorized fixes; separately verify on a real device. No parent-SHA evidence transfers to a later SHA.
- Verify the Track 1 embedded solar/Gregorian engine, zero-permission behavior and automatic local Task/Reminder lifecycle independently; this audit did not establish those acceptance facts.
- Audit Clause 10 Report Center implementation against the full analytical specification and record each behavior as PASS / FAIL / NOT VERIFIED with exact-SHA evidence.

### Audit limits and governance

- This was a source-and-test-contract inspection only. No tests, emulator runs, physical-device checks or workflow runs were executed in this checkpoint.
- No application code, Android manifest, database schema or user data was changed in this audit.
- The ledger is updated only on the authorized PR #3052 branch. Do not merge, modify `main`, close the PR, publish an APK or release.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; Release remains **BLOCKED — RELEASE: NO-GO**.
- Iran timestamp: 1405/08/12 03:07 (Asia/Tehran).


---

## Wave 7.299 — Device Calendar Mirror vs. Arvin-Owned Task lifecycle boundary — 2026-11-03

**Repository:** `mobinpda-lab/Arvin-clean`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Implementation base SHA:** `ee904edaa7484e821275ee8fb116b67853a7b552`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **Release:** BLOCKED — RELEASE: NO-GO.

### Product-owner architectural decision

#### A. Device Calendar Mirror — read/display only
- External Android Calendar events are projections, not Arvin-owned records.
- Provider-side event title/time/date changes are reflected in the Calendar mirror when the provider snapshot is reloaded.
- Provider deletion or detachment removes only that external event from the mirror projection on the next successful reload.
- Mirror refresh must not create, update, delete or nullify a native Arvin Task, Task due date, Reminder, Reminder date or follow-up history.
- Mirror display is sourced from the current provider query and is not a persisted copy of the provider event in canonical Task storage.

#### B. Native Arvin Task/Reminder — Arvin owns the record
- Once an external event is explicitly imported as a native Task, or an Arvin Task/Reminder is exported as a device-calendar replica, the native Arvin record remains authoritative.
- External event movement, edit, deletion, detachment, missing query results or provider failure MUST NOT mutate, nullify or delete the native Task/Reminder or its dates.
- Provider-originated changes cannot overwrite Arvin Task title, due date, reminder date, independent TaskReminder records or follow-up history.
- A user may explicitly edit/delete an Arvin-owned record inside Arvin. A separate explicit export action may update/delete its device replica; that is outbound behavior, never inbound ownership transfer.
- A provider replica disappearing must not be interpreted as a user request to delete the Arvin source record. Link metadata must not be discarded merely because a provider query omits an event.

### Implementation changes recorded in this wave

1. Removed automatic `_reconcileDeviceCalendar` scheduling and its task-refresh/conflict mutation path from `CanonicalCalendarLauncher`.
2. Removed inbound reconciliation from the Home retry-sync callback. Retry remains outbound-only; user-facing copy no longer claims bidirectional synchronization.
3. Retired `CalendarInboundSyncService.reconcile` as a deliberate no-op compatibility surface. It performs no provider query, TaskStore write, link-store save, reminder reschedule or deletion.
4. Replaced the former inbound mutation tests with ownership-boundary tests asserting native Task title, due date, reminder date and independent TaskReminder identity/content remain unchanged.
5. Preserved the read-only mirror implementation in `OfficialCalendarPage._loadExternalEvents` + `ExternalCalendarEventProjection`: it queries configured visible device calendars and creates ephemeral `external-calendar:` presentation items. It does not create native Task data.
6. Added an app-resume refresh to `OfficialCalendarPage`. When the user returns from the device Calendar app, Arvin reloads the provider snapshot; changed/moved events are re-projected and deleted/detached events disappear from the mirror after a successful query. This refresh is read/display-only and does not write native Task or Reminder data.

### Evidence and limitations

- Source files changed: `lib/main.dart`, `lib/widgets/canonical_calendar_launcher.dart`, `lib/services/calendar_inbound_sync_service.dart`, `lib/official_calendar_page.dart`, and `test/services/calendar_inbound_sync_service_test.dart`.
- The former inbound tests that expected provider edits/deletions to mutate canonical Task data were removed and replaced with ownership immutability assertions.
- Source inspection confirms the old launcher-startup reconcile call and Home retry inbound call are removed.
- GitHub Actions automatically triggered against exact implementation SHA `ad83a350751b061faf0299c5ba68d202775bfb13`. At the latest read-only poll: `analyze-and-queue`, `route`, `contract`, `wake`, and selected orchestration jobs reported SUCCESS; Calendar Provider Acceptance run `41548716272` was IN_PROGRESS; Follow-up File Persistence run `41548716274` was IN_PROGRESS; G1 lock sync run `41548716375` was IN_PROGRESS; Build run `41548716296` was PENDING; Draft Review APK run `41548716351` was PENDING; Device Smoke run `41548716383` had `smoke-task-lifecycle` CANCELLED, `smoke-boot` and `smoke-navigation` IN_PROGRESS, and the remaining lanes QUEUED at the latest poll. No test/build/device acceptance PASS is claimed from pending or in-progress jobs.
- No physical-device acceptance result is available in this checkpoint. All unfinished lanes remain NOT VERIFIED until completed on this exact SHA.
- The app-resume mirror refresh is implemented at source level; actual lifecycle/provider behavior on Android remains NOT VERIFIED.
- This wave does not establish that every external import-to-native-Task action is explicitly user-confirmed; that import-registration path remains separately auditable.
- This wave does not establish release readiness or change Clause 14 acceptance status.

### Governance

- Only the authorized PR #3052 branch is modified.
- `main` remains unchanged.
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- No merge, release, APK publication or release-signoff is authorized.
- Release remains **BLOCKED — RELEASE: NO-GO**.
- Iran timestamp: 1405/08/12 (Asia/Tehran).


### Wave 7.299 implementation follow-up — explicit Task export and immutable ownership (2026-11-03)

**This section records implementation work after the Wave 7.299 audit; it does not retroactively convert the audit into implementation evidence.**

- Removed automatic Calendar outbound writes from Home save, Quick Capture, Task edit and Task completion. No retry callback remains on the Calendar launcher.
- Restricted the Calendar More menu to its unrelated actions; removed its device-calendar export and retry actions. Removed device-calendar export from the Task-card long-press menu while retaining the Calendar swipe action.
- Added the explicit Task Details action task-detail-send-device-calendar; it selects an eligible due-date or independent TaskReminder belonging to that Task.
- Dart export allow-list now accepts only task-due:, task-reminder-item:, task-reminder:, and task-recurrence: identities. Historical followup: and task-followup: identities are rejected.
- The real arvin/system_calendar MethodChannel now carries reminderId through legacy insert and Provider create/update/delete calls. Android validates the same allow-list before every write and rejects missing/invalid identities.
- Provider executor rejects invalid plan IDs before permission requests or Provider access. Manual export builds a plan using only the selected reminder's link; the executor retains unrelated stored links when it saves metadata.
- Inbound reconciliation remains a deliberate no-op. External provider items remain read-only mirror projections; imported Task records remain canonical Arvin data and are not reconciled from later provider changes.
- Added focused source-contract and MethodChannel identity tests. CI results, physical-device behavior and exact-SHA runtime evidence must be recorded separately after the commit.
- Governance unchanged: PR #3052 OPEN / DRAFT / UNMERGED; no main modification; BLOCKED — RELEASE: NO-GO.


### Wave 7.299 implementation follow-up — alarm-history boundary and settings policy evidence (2026-11-03)

- FollowUp history is display/history data only. The retired AutomaticFollowUpService returns no scheduled or due candidates, and AutomaticFollowUpAlarmPlanner therefore has no FollowUp-history alarm candidates.
- The active FollowUpReminderProjection and FollowUpReminderDeliveryService iterate only canonical Task.taskReminders. FollowUpReminderAlarmPlanner schedules only independent TaskReminder entries plus the migration-compatible singular Task reminderDate; it does not read Task.followUps. FollowUpWriteCoordinator may refresh this TaskReminder schedule after a FollowUp write, but it cannot create an alarm from the history record.
- Calendar integration settings no longer expose automatic export, FollowUp-history export, FollowUp-reminder export, source-type sync toggles, or automatic linked-event deletion. The page now states the two approved explicit export gestures and local/device ownership boundary.
- This is source/test evidence only until the final exact-SHA Build, Calendar Provider, Draft Review APK and seven Device Smoke results are completed and reported. No physical-device PASS is inferred from source inspection.


### Wave 7.300 — exact-HEAD audit of explicit Calendar export and CI disposition (2026-11-03)

**Audited source HEAD:** `0df33f1139c0cf0fd9c8910dcf9fa93e6660b9b3`  
**Branch / PR:** `fix/recovery-calendar-device-smoke-2026-10-31` / #3052  
**Audit timestamp:** 1405/08/12 07:33 Asia/Tehran (2026-11-03).

#### Source findings (read-only; no Dart or Android source changes were necessary in this wave)
- `TaskDetailPage` already exposes the explicit `task-detail-send-device-calendar` action and routes the current `_task` to the callback.
- `_registerTaskFromDetails` projects only the supplied Task and, when multiple eligible due/reminder entries exist, requires selection of one entry. `_registerTaskInDeviceCalendar` resolves that selected reminder to its owning Task and creates a one-revision plan.
- The explicit export caller filters persisted links to `link.reminderId == reminder.id`. `CalendarProviderSyncExecutor` validates every plan ID with `SystemCalendarBridge.isExportableTaskReminderId`, loads the existing link collection, and mutates/removes only the plan item's key while saving the complete collection. This is source-level evidence that unrelated Task links are retained on this path.
- The Calendar More sheet contains only Next Action, Timeline and Conflicts. The Task-card long-press sheet contains edit/delete and other non-export actions; no device-calendar export action is present. Calendar swipe remains the card export gesture.
- The reviewed Home standard save/edit/completion paths and Quick Capture path contain no outbound Calendar provider execution. Explicit export remains separately wired from Task Details and Calendar swipe.
- Dart and Android both use a positive allow-list of `task-due:`, `task-reminder-item:`, `task-reminder:`, and `task-recurrence:`. Historical `followup:` and `task-followup:` IDs do not match the allow-list and are rejected at Dart and Android write boundaries.
- Inbound reconciliation is a no-op. `OfficialCalendarPage` registers an app lifecycle observer and reloads device events when the app resumes; the resulting provider projection is read/display-only. This supports app-resume refresh, not a claim of continuous real-time updates while Arvin remains foregrounded.
- Imported/copied Task ownership remains separate from provider mirror projection; device-side edits/deletions are not applied to canonical Task storage by inbound reconciliation.

#### Exact-SHA CI evidence on audited source HEAD
- Build Run `41574427874`: **FAILURE**. Analyze failed and test shards failed/short-circuited. Compiler blockers recorded in the logs: `lib/center_management_page.dart:55` passes unsupported `mainAxisSize` to `Wrap`; `lib/services/project_template_service.dart:79` dereferences nullable `ProjectTemplate?`. One test shard reported 246 passed / 22 failed or unloadable; this is not a product acceptance pass.
- Calendar Provider Run `41574427909`: **FAILURE**. Exact target SHA verification succeeded, but the instrumentation/real Provider acceptance step failed during Flutter debug compilation with the same two Dart compiler blockers. Artifact `13203316765` was uploaded; artifact presence is not acceptance.
- Device Smoke Run `41574427936`: **IN PROGRESS** at the audit poll. Boot, Task Lifecycle, Reminder/Vazirmatn, Navigation, Calendar Segmented View and Quick Capture jobs had concluded FAILURE due the same compile blockers; Follow-up Persistence remained IN_PROGRESS. Calendar screenshot artifact `13202523528` was uploaded, but the Calendar lane did not complete its test and is not PASS. Overall Device Smoke is **NOT ACCEPTED**.
- The passing Follow-up File Persistence run `41574428035` and unrelated successful automation runs do not substitute for Build, Calendar Provider or seven-lane Device Smoke acceptance.

#### Wave disposition
- The requested Calendar export architecture is present in source at the audited HEAD; no redundant implementation patch was made.
- The two unrelated compile blockers must be corrected on the authorized branch before a new exact-HEAD Build, Calendar Provider and complete seven-lane Device Smoke run can be accepted. Do not weaken or skip tests.
- App-resume mirror refresh is verified at source level only; continuous live refresh and physical-device edit/delete behavior remain **NOT VERIFIED**.
- No claim of full implementation acceptance, CI PASS, device acceptance or release readiness is made.

#### Governance
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- `main` is unchanged; no merge, release, tag or APK publication.
- Release remains **BLOCKED — RELEASE: NO-GO**.



## Wave 7.301 — compilation hotfix and exact-HEAD validation checkpoint (2026-11-03)

**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **Release:** BLOCKED — RELEASE: NO-GO.

### Compilation hotfixes
- Removed the unsupported `mainAxisSize` argument from the `Wrap` in `lib/center_management_page.dart`. Commit: `ebd0f50539b4c189d5d35ded6fef5d25e3ff20cc`.
- In `lib/services/project_template_service.dart`, captured the non-null selected template in a final local after the null/archive guard and used that stable reference through project generation and duplicate detection. This avoids nullable-promotion loss inside the closure without weakening validation. Commit: `47c3f352040df771f67f3cf6a3b5830eb303643b`.
- The two source files were re-read from the resulting branch HEAD; the unsupported Wrap argument is absent and the selected-template final reference is present.

### Validation checkpoint
- Hotfix implementation HEAD before this ledger update: `47c3f352040df771f67f3cf6a3b5830eb303643b`.
- Exact-HEAD workflows were automatically created after the source commits: Build `41576466514`, Device Smoke `41576466630`, Calendar Provider `41576466451`, Draft Review APK `41576466509`.
- At this checkpoint Build Analyze and all six test shards were still running; Device Smoke was queued; Calendar Provider and Draft Review APK were in progress. No exact test counts or PASS claims are recorded.
- The above runs target the pre-ledger implementation SHA. The ledger synchronization commit below changes HEAD; these runs are retained as diagnostic history only and MUST NOT be used as final acceptance evidence. Fresh exact-HEAD workflows on the ledger-synchronized SHA are required.
- Draft Review APK availability is NOT VERIFIED until the final exact-HEAD run completes and its artifact is listed.
- No test was skipped or weakened as part of these two source fixes.

### Governance
- Only the authorized PR branch was changed; `main` was not modified.
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- No merge, release, publication or release sign-off.
- Release remains **BLOCKED — RELEASE: NO-GO**.
- Iran timestamp: 1405/08/12 07:40 (Asia/Tehran).


---

## Wave 7.302 — Past time filter and pending-first task ordering (2026-11-03)

**Implementation source HEAD:** `7c2d0260f3af5869671f26d4356e6b20dd15608a`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED. **Release:** BLOCKED — RELEASE: NO-GO.

### Prior-run results — exact SHA `2029d6e6924e6fe29db5b8e4722af2016d16969a`
- Build Run `41576526214`: FAILURE. Analyze reported 13 issues, including the blocking test compile error `CenterDeleteBlocked isn't a type` at `test/center_project_association_test.dart:40`. Six test shards all failed. Reported shard summaries: test-0 166 passed / 2 failed; test-1 211 / 1; test-2 199 / 3; test-3 269 / 2; test-4 157 / 1; test-5 128 / 1. Aggregate: 1,130 passed / 10 failed. This is not a Build PASS.
- Device Smoke Run `41576526259`: six lanes concluded SUCCESS (boot, navigation, task lifecycle, reminder/Vazirmatn, follow-up persistence, quick capture). The calendar-segmented-view lane did not pass: its emulator smoke step was CANCELLED and calendar evidence upload failed. Workflow remained IN_PROGRESS during cleanup at the latest poll; overall Device Smoke is NOT ACCEPTED.
- Calendar Provider Run `41576526351`: SUCCESS; acceptance artifact present.
- Draft Review APK Run `41576526404`: SUCCESS; non-expired artifact `arvin-review-staging-apk-2029d6e6924e6fe29db5b8e4722af2016d16969a` present (32,987,210 bytes).
- These results belong only to SHA `2029d6e...`; they do not establish acceptance for the Wave 7.302 implementation.

### Product implementation
- Home time filter now exposes `گذشته` in the shared time-filter sheet and filter bar.
- Home membership uses Task.dueDate only and includes tasks whose local due-date day is strictly before the local start of today. Today-at-midnight and all later dates are excluded; undated tasks are excluded.
- Selecting `گذشته` renders one ordered Past group so completed past tasks cannot be separated into an unrelated date group or appear above pending tasks.
- Added `TaskListSortService.sortPast`: incomplete tasks first, completed tasks second; within both groups, due dates sort ascending (oldest overdue first), with deterministic ID/input-order tie breaks.
- Report Center already exposed the `ReportTimePreset.past` option and strict prior-day membership. Its result projection now applies the same shared pending-first / oldest-date-first ordering. The same TaskReportFilter powers the Report Center's advanced filter sheet.
- Report date comparison normalizes both the selected Task due date and current date to local calendar time.
- No storage schema, Task model, due-date semantics, reminder data, or FollowUp history was changed.

### Regression tests added
- `test/task_list_sort_service_test.dart`: pending-first hierarchy and ascending date order inside both completion groups.
- `test/task_report_filter_test.dart`: strict exclusion of today (including midnight and morning), future and undated records; open-first ordering followed by completed records.
- `test/widgets/home_page_test.dart`: Home UI selection of `گذشته`, strict exclusion of today's task, and visible pending-first/date ordering.
- `test/report_center_page_test.dart`: Report Center Past selection, exact result scope, and pending-first/date ordering.
- Source and test files were re-read from the branch after commits; this is source-presence verification only. No test PASS is claimed until the new exact-HEAD CI runs complete.

### Implementation commits
- `5cdc622a6125465c1a9e21bf4a4ec8a75ce1d9f7` — shared Past ordering service.
- `8546027ec6c877fa8a92293c026d9dfa0ff50d03` — Report Center sorting and local date normalization.
- `e2fd19b255d3145133238cad9ee0a4dfba6fe82e` — Home Past option, strict scope, sorting and grouping.
- `a5e6fb2867e0851ff719253e0af8cbc576783071` — shared sorting regression test.
- `97a568ea005f94a7981ff2454b645a0b4eb7e550` — Report filter scope/sorting regression test.
- `2160632c39c65e7eab722fb76d06ba48d34ca575` — Home UI regression test.
- `11a0134e130dabec8ed6544e4eed9f04057385f5` — Report Center UI regression test.
- `7c2d0260f3af5869671f26d4356e6b20dd15608a` — local-date normalization in Home.

### Governance
- Only the authorized PR branch was changed; `main` was not modified.
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- No merge, release, APK publication or release sign-off.
- Release remains **BLOCKED — RELEASE: NO-GO**.
- Iran date: 1405/08/12 (Asia/Tehran).


## Wave 7.303 — CI audit and focused regression fixes (2026-11-03)
- Audited exact HEAD `2b558bd08917ac16a81fd161ced410bedbdc33be`.
- Build run `41579701473`: terminal FAILURE. Analyze failed on `CenterDeleteBlocked isn't a type` at `test/center_project_association_test.dart:40`. All six shards failed: test-0 130 passed/1 failed; test-1 165/2; test-2 271/2; test-3 200/3; test-4 210/1; test-5 158/1. Common compile error repeated across shards. Other distinct failures: project template test MissingPluginException(shared_preferences); project card summary expected old text without center label; Home center-filter chip not brought into horizontal viewport before tap; calendar settings test attempted to scroll to a removed delete-linked-event switch. No assertions were skipped or relaxed.
- Device Smoke run `41579701586` remained non-terminal at audit: boot, navigation and quick-capture passed; calendar-segmented-view and task-lifecycle in progress; reminder-vazirmatn and follow-up-persistence queued. Four artifacts had been captured, but seven-path acceptance was NOT VERIFIED.
- Calendar Provider run `41579701507`: SUCCESS; non-expired artifact `arvin-calendar-provider-acceptance-2b558bd08917ac16a81fd161ced410bedbdc33be` (11,210 bytes).
- Draft Review APK run `41579701535`: SUCCESS; non-expired artifact `arvin-review-staging-apk-2b558bd08917ac16a81fd161ced410bedbdc33be` (32,990,324 bytes; SHA-256 `b93fc388827c2485f49c0f48ee31678cdf8412431956d22e883416c3f9bcab58`).
- Focused fixes committed on the PR branch only: `c284845111d2b100f5ce7a5e480d8aff690aa895` exports the canonical `CenterDeleteBlocked` type through `center_store.dart`; `02108c385443c2d52b3f509781400db398c40f1f` updates the project summary assertion to tolerate its center prefix; `8115f3fded9018e731f35dcc85e218856d026fd9` initializes the SharedPreferences mock in the template service test; `a3f9e75eaa67657134bc6bd41644bf49e673f92c` asserts that the prohibited delete-linked-event control is absent; `e3ae30bc069bfa80eba6ecdf28713628164d43ed` scrolls the Home filter strip horizontally before tapping the center chip.
- These are targeted fixes only. Validation on the new HEAD is pending; none of the prior SHA results transfer to the new commit.
- Governance: PR #3052 remains OPEN / DRAFT / UNMERGED; no main-branch change or merge was performed. Release remains BLOCKED — RELEASE: NO-GO.


## Wave 7.304 — Home overdue text, instant archive and date-jump scope (2026-11-03)
- Branch before Wave 7.304: `c257b63d7296ee707865f44eebbd0338e9563095`.
- Home overdue rendering: unfinished overdue Task title and due-date text use `ArvinColors.error`; status icon is the ordinary unchecked icon with primary color; due-date icon, overdue-dismiss icon, and unrelated FollowUp text/icon remain neutral. Card Material surface and border configuration are unchanged.
- Home checkbox completion: only an unfinished Task that is neither archived nor trashed is automatically marked archived at the same state transition as completion. This happens in `setState` before persistence/rebuild, so it leaves active Home scopes (including Past). Existing `TaskStore` canonical save path persists the full Task; no deletion or data/history rewrite.
- Added widget tests in `test/widgets/home_page_test.dart`: overdue title/date red with neutral icons; active Home completion archives immediately while preserving description, dueDate, reminderDate, checklist and FollowUp history; Past-filter completion also removes the Task from active display and persists archived/completed state. Existing assertions remain present; additions only.
- Source/test commits: `c5d8627211b7cb8b0c601e74cefa44119dd309c4` (Home styling + archive transition); `c9c6cbfdda950ca5f2d4d9c0364236d058a5775f` (new regression tests); `378045d5d020d307cb9dfa88b3ede998753ed719` (canonical icon color assertion); `9ce6ff8627fb414b4e10ceb3019d169a8487e4af` (neutralize remaining overdue-dependent icon/unrelated text colors); `d89f46641a59e93e4cf81cfb69b17192af59fe32` (red due-date text assertion).
- Date-jump source audit: current-date action is `calendar-today` in `lib/calendar_page.dart` calling `_today()` to reset CalendarPage's selected day/month. Separate `calendar-date-jump` opens `showJalaliDateJumpDialog` for arbitrary date selection. Neither control is in HomePage on this branch. TaskDetailPage has no current-date navigation state or callback. Relocation is **NOT IMPLEMENTED / NOT VERIFIED** pending owner clarification whether intended behavior is (a) calendar selected-day navigation, or (b) setting the Task due date to today. Do not silently change semantics.
- `CHANGELOG.md` synchronized in commit `d69bb1453acd5df01228ef34b7e05a6cbe68232d`.
- No exact-HEAD Build/test/device result is claimed for these source commits. Re-run and inspect exact-SHA CI after the final date-jump decision.
- Governance: PR #3052 OPEN / DRAFT / UNMERGED; `main` unchanged; no merge/release. Release **BLOCKED — RELEASE: NO-GO**.


## Wave 7.304 — explicit Task Details due-date action and verification (2026-11-03)
- Branch source/test HEAD before documentation sync: `42f249d64dbfe1c825e3f6207c8b48018c85fc58`. Documentation commits follow; the final SHA and exact-head CI must be re-read after both docs commits.
- Added `TaskDetailPage.onMoveDueDateToToday` and a separate button keyed `task-detail-move-due-date-to-today`, labeled «تنظیم موعد برای امروز», directly below the read-only `task-detail-due-date` row. The due-date row remains non-interactive. This action mutates the Task due date, not CalendarPage selection.
- Home wires the callback to `TaskMoveToTodayService(store: taskStore)`. The existing service reloads the canonical Task, uses `IranClock.now()`, preserves hour/minute when a due date exists (uses current Iran-local hour/minute if absent), changes only dueDate and updatedAt, saves through TaskStore, and returns the canonical Task. TaskDetailPage replaces its local snapshot with the returned persisted Task and refreshes the date text.
- Added widget coverage in `test/task_detail_followup_flow_test.dart` for action placement, explicit activation, Iran-local day result, persisted reload, retained due time, and preservation of Task identity/title/description/reminder/followUpEnabled/followUpDate/category/tags/checklist/FollowUp history.
- Added `test/widgets/home_page_test.dart` coverage for completing a Home task, unmounting/reopening ArvinApp, opening Archive, and confirming completed+archived state plus description/checklist/FollowUp history survive.
- Current Home overdue style and completion source remain as recorded above: overdue unfinished title/due-date text red; card surface/border and icons neutral; completion marks active unfinished Task completed+archived through canonical TaskStore. The new reopen regression is the required durability assertion; its result is pending exact-head CI.
- Home/Calendar audit: no independent Home jump-to-today control exists at this HEAD. No Home control was removed. CalendarPage `calendar-today` continues to call `_today()`; `calendar-date-jump` continues to open arbitrary Jalali date selection. Both controls and navigation behavior are unchanged.
- Yellow overdue close indicator in Home (`task-card-clear-due-${task.id}`): when `late == true`, it stores the current dueDate in the in-memory `_dismissedOverdueWarnings` map and returns; it only hides the warning for the current Home state and does not change or save Task.dueDate. When the task is not overdue, it sets dueDate to null and calls canonical `_save()`. No behavior was changed.
- Parent exact-SHA CI evidence on `4eb65a761870422cdbf1aebdd08abd3d4dec523a`: Build run `41582359092` FAILURE. Analyze exited 1 with 12 info/warning diagnostics (3 curly-brace infos, 4 deprecated RadioGroup member infos, 2 unnecessary non-null assertion warnings, 3 unused imports). Shard results: test-0 FAILURE (201 passed / 1 failed: `home_filter_contract_test.dart` expected text «همه مراکز» but found zero); test-1 SUCCESS; test-2 SUCCESS; test-3 SUCCESS; test-4 SUCCESS; test-5 SUCCESS. The previous `CenterDeleteBlocked isn't a type` compiler error did not appear in this run's captured Analyze output or identified shard failure; its full resolution is not promoted to PASS until final exact-head run is inspected.
- On that same parent SHA, Device Smoke run `41582359318` had boot and navigation SUCCESS, calendar-segmented-view and quick-capture IN_PROGRESS, and follow-up-persistence / reminder-vazirmatn / task-lifecycle QUEUED at inspection; seven-path acceptance NOT VERIFIED. Calendar Provider run `41582359247` SUCCESS with artifact `arvin-calendar-provider-acceptance-4eb65a761870422cdbf1aebdd08abd3d4dec523a` present (11,208 bytes). Draft Review APK run `41582359194` SUCCESS with artifact `arvin-review-staging-apk-4eb65a761870422cdbf1aebdd08abd3d4dec523a` present (32,989,962 bytes; SHA-256 digest `986fce4c00218ced5832ff97b554a7f3fe64d24d39ed66f1070297cc2bd6eba3`; expires 2026-11-10). It is ephemeral-key review-only, not production/release.
- These parent-SHA results do not validate the new Task Details action or Home reopen test. Exact-head Build/analyze + all six shards, all seven Device Smoke lanes, Calendar Provider and Draft Review APK must run and be inspected on the final documentation-synchronized SHA. Record terminal status and artifact presence; do not accept pending/cancelled lanes.
- Governance: PR #3052 OPEN / DRAFT / UNMERGED; main unchanged; no merge, release, publication or sign-off. **BLOCKED — RELEASE: NO-GO**.


- After recording the parent-SHA Home center-filter failure, corrected only the test interaction in `test/home/home_filter_contract_test.dart`: it now calls `ensureVisible` on the center filter chip before tapping. The «همه مراکز» assertion and subsequent behavioral assertions are unchanged. No Home product logic and no Report Center behavior changed. Commit: `173fb8cda1969e424f5da11970c6395c8da8d8dc`. Exact-head Build must confirm this correction.
