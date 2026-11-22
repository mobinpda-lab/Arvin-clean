# COMMAND 60-R — MASTER TRACKER
**Updated:** 2026-11-19  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical integration branch:** `recovery-02/main-based-integration`  
**PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Baseline verified:** `871abadc158464b6059d88350b1cb6fb48def7df`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` (read-only; unchanged in this mission)

## Current control state
- Read access: VERIFIED.
- Write access: VERIFIED by creation of five isolated work branches and this documentation update.
- No Main write, merge, release, deployment, production database migration, V19 installer edit or V7 fixture edit.
- Latest COMMAND 59 commits: `1dc43001e2572933d4cafd602641d46617f179cd`, `871abadc158464b6059d88350b1cb6fb48def7df`.
- Canonical branch HEAD at mission start: `871abadc158464b6059d88350b1cb6fb48def7df`. This tracker commit advances the branch; re-read live branch/PR SHA after commit.

## Work lanes
| Lane | Branch | Status | Current blocker / next action |
|---|---|---|---|
| A — Data safety | `command-60-r/path-a-data-safety` | IN PROGRESS | Diagnose V8→V9 test executor lifecycle, COMMAND 49 parity, COMMAND 50 forensic failures; prove V7→V20 sequential path |
| B — UI/UX | `command-60-r/path-b-ui-ux` | IN PROGRESS | Complete route/page inventory, font provenance reconciliation, design-system implementation plan |
| C — Product features | `command-60-r/path-c-product-features` | IN PROGRESS | Map REV10 features against source and #1901; build CRUD/persistence acceptance matrix |
| D — Quality | `command-60-r/path-d-quality` | IN PROGRESS | Repair test-1 Drift executor lifecycle and test-2 Person dialog contract without weakening assertions |
| E — Delivery | `command-60-r/path-e-delivery` | IN PROGRESS | Prepare physical-device checklist and release evidence; physical device remains untested |

## Exact-SHA baseline
- Build `44408378276`: FAILURE. Analyze, Debug APK, Release APK and font package audit succeeded; test-1 and test-2 failed.
- Device Smoke `44408378348`: SUCCESS on baseline SHA; seven emulator scenarios. Not physical-device acceptance.
- COMMAND 20-E `44408378416`: FAILURE at final acceptance gate; ProjectStore file persistence and SharedPreferences fresh-process persistence phase passed.
- Follow-up File Persistence `44408378334`: SUCCESS.
- Test-1 root cause: `g1_drift_schema_test.dart`, V8→V9 migration test invokes an executor before `ensureOpen()`.
- Test-2 root cause: `person_directory_page_test.dart`, expected delete-dialog text not found; 262 other tests passed.
- COMMAND 49-R: occurrence parity mismatch remains unresolved.
- COMMAND 50-R: forensic workflow success is not migration acceptance; second-install, explicit-NULL and unknown-state cases remain failing.

## REV10 source contract found
- Active canonical continuity set: `docs/project-continuity/{MASTER_GOVERNANCE,PRODUCT_DECISIONS,CURRENT_STATE,ROADMAP,OPEN_ISSUES,IMPLEMENTATION_LOG,HANDOFF}.md` plus README.
- REV10 Home: five filters — Time, Center, Project, Category, Tag; multi-select OR within dimension, AND across dimensions; five due-date groups.
- Relations: Center↔Project M2M; Project↔Category M2M; Task→Center/Project/Category each optional 0..1; Task↔Tag M2M.
- Existing governance says one active development branch; COMMAND 60-R is the newer explicit owner instruction authorizing five independent work branches. This mission records that supersession without changing Main.
- Font source conflict remains documented in PRODUCT_DECISIONS.md. Current code uses Vazirmatn v33.003. One library ZIP found: `vazirmatn-v33.003 (2).zip`; no VazirHarf v34.003 ZIP was found in Library/conversation ZIP inventory. Do not silently switch font.

## Next actions
1. Read this tracker and current live branch SHA before every continuation.
2. Complete detailed page/file inventory on lane B and feature matrix on lane C.
3. Diagnose lane A/D failures using exact test logs and preserve every assertion.
4. Record each implementation commit and exact-SHA CI before claiming TESTED.
5. Integrate lanes only into the authorized canonical branch after independent review and test evidence.
6. Keep RELEASE NO-GO until all owner acceptance gates pass, including real phone tests.

## COMMAND 60-R live documentation checkpoint
- Documentation batch commit: `a86a7f1a002d3540846a27b7ed8ccaf4e26f62ba`; all 16 requested starter files were re-read successfully from GitHub.
- Main SHA was re-fetched and remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- Five lane branches were re-listed and all five exist.
- Exact-SHA workflows triggered by documentation batch commit `a86a7f1a002d3540846a27b7ed8ccaf4e26f62ba`:
  - Build `44417450117`: PENDING at last poll (no jobs exposed yet).
  - Device Smoke `44417450005`: QUEUED/in progress; quick-capture and home running, other five scenario jobs queued at last poll.
  - COMMAND 20-E `44417449926`: storage-persistence IN PROGRESS.
  - Follow-up File Persistence `44417450260`: IN PROGRESS.
- These are new documentation-SHA runs and do not repair or replace the earlier failing baseline evidence.
- This tracker update itself creates a newer branch commit; re-fetch its SHA and exact-SHA workflows before the next status report.

## Acceptance vocabulary
NOT STARTED · IN PROGRESS · BLOCKED · IMPLEMENTED · TESTED · ACCEPTED

A document or APK alone is not product acceptance.



## Lane PRs and implementation checkpoints — 2026-11-19
Canonical branch baseline for lane PRs: `7951a9331e7c3e5e9004ea3007cf21685827b75a`.
- Lane D PR #3547 — Draft, branch `command-60-r/path-d-quality`, head `1c83db84145675aa31e67feef95c23ddd84c181c`. Changes: open executor before fixture SQL; correct exact Person deletion-dialog string. Build `44417802140` and Device Smoke `44417802091` queued at last poll; Follow-up Persistence `44417801990` SUCCESS. No merge.
- Lane B PR #3548 — Draft, branch `command-60-r/path-b-ui-ux`, head `d6c7ebe135e8422fea37a85cd22eb0927e129770`. Shared design-token foundation and primary-navigation color/radius/motion centralization. Build `44418093105`, Device Smoke `44418093228`, Follow-up Persistence `44418093199` queued at last poll. No merge.
- Lane A PR #3549 — Draft, branch `command-60-r/path-a-data-safety`, head `f5f93018a3133a0604f66cc317dbf8d664b78e01`. Adds file-backed Schema 9 Occurrence/Checklist/NULL/unknown nested metadata persistence test across three installs and fresh file reopen. No exact-SHA workflow run was visible at last poll; validation pending.
- Lane C and E branches exist; no code PRs yet.

## New source-backed product findings
- Home has four filter cards (Time, Project, Category, Tags); REV10 requires five including Center. Five due-date groups are present separately.
- Schema 9 creates Center/M2M tables, but canonical CenterStore and Center management page were not found; M2M Store/UI integration remains blocked.
- Settings text-size slider exists; font-family picker does not. Font source conflict remains unresolved.
- Main remained unchanged at `45e4202b03a434459e4c021a04efa7e8396359db`.


## Data-safety discovery and corrective lane update
- PR #3547 Build run `44417802140`: test-1 passed after executor-open correction; test-2 failed because directory removal is undone by repeated `migrateTaskPeople` hydration. This is a product/storage defect.
- Lane A PR #3549 current head: `ce9ce1d755ae994d1f2567285304dc23b07aa823`. Adds marker-versioned `person_directory_exclusions_v1`, tombstone-aware hydration, explicit re-add behavior, file-backed Person Directory lifecycle test, active Schema 9 Occurrence/Checklist envelope test, and the two test corrections. Build `44418907693`, Device Smoke `44418907517`, Follow-up Persistence `44418907531` pending at last poll.
- Lane D PR #3547 remains open and unaccepted; its test-2 failure is addressed by lane A's fix pending CI.
- Lane C blocker registered as Issue #3550: Center domain/store, M2M relations and missing Home Center filter. No Center persistence/UI implementation started.
- Lane B PR #3548 head `d6c7ebe135e8422fea37a85cd22eb0927e129770`; shared design tokens and nav centralization implemented, CI pending.


## Additional exact-SHA CI checkpoint
- Lane B PR #3548 head `d6c7ebe135e8422fea37a85cd22eb0927e129770`: Follow-up Persistence PASS; test-4 PASS; test-1 FAIL due the known V8→V9 executor lifecycle defect; test-5 and Quick Capture smoke were in progress, remaining jobs queued. Lane B must be revalidated after lane A's test fix is integrated.
- Lane D PR #3547 head `1c83db84145675aa31e67feef95c23ddd84c181c`: test-1 PASS; test-2 FAIL due Person Directory rehydration. Lane A PR #3549 addresses both storage defect and assertion correction; no merge yet.


## Latest lane activity — 2026-11-19
- Lane B PR #3548 latest head `35fad86c6b6eb5dd03ce615d7bae002093c44d6f`: shared design tokens, navigation token use, Home Bismillah capsule, physical notification-left/menu-right layout and widget assertions. Build `44419703075`, Device Smoke `44419703399`, Follow-up Persistence `44419703242` queued at last poll. Earlier head's test-1 failure was the known executor fixture issue, corrected in lane A; latest head validation is pending.
- Lane A PR #3549 head `ce9ce1d755ae994d1f2567285304dc23b07aa823`: Debug APK SUCCESS; Follow-up Persistence IN PROGRESS; Home and Quick Capture Device Smoke IN PROGRESS; remaining Build shards and smoke scenarios queued. No complete Build/Device acceptance yet.
- Lane D PR #3547 remains OPEN; its exact-head test-2 failure proved Person Directory rehydration. Lane A carries the fix and regression test.
- Lane C P0 Issue #3550 created for Center model/store, M2M graph and missing Home Center filter.
- Canonical branch latest governance commit before this update: `d3f83e906f156e5120b07b66fedd2850cf904a3b`. Main unchanged: `45e4202b03a434459e4c021a04efa7e8396359db`.


---

## COMMAND 60-R.1 — evidence-based correction and acceptance — 2026-11-19 / ۲۸ آبان ۱۴۰۵

**Canonical route:** PR #3495 / `recovery-02/main-based-integration`
**Canonical SHA at inspection:** `6d806125e91056fedb74b0644d77a273ee4b675f`
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — unchanged/read-only.
**PR #3495:** OPEN / DRAFT / UNMERGED.
**Governance:** Historical lane PRs remain evidence sources. New development/integration stays on the single canonical PR #3495; no new parallel feature PR or direct Main write.

### Lane A — Person Directory
- PR #3547 exact head `1c83db84145675aa31e67feef95c23ddd84c181c`: Analyze, five shards, Debug/Release APK and selected Device Smoke passed; test-2 failed because repeated `migrateTaskPeople` rehydrated a Person explicitly removed from the active directory. Not accepted.
- PR #3549 exact head `ce9ce1d755ae994d1f2567285304dc23b07aa823`: Analyze, all six shards, Debug/Release APK, seven emulator smoke scenarios and Follow-up File Persistence passed on that exact SHA.
- PR #3549 is 8 commits ahead / 30 behind canonical SHA (DIVERGED); no direct merge/cherry-pick.
- Its tombstone/exclusion design is promising and file-backed, but backup/restore and explicit duplicate SQL-row count acceptance remain missing. Port the reviewed change only to #3495 and test there.

### Lane B — UI / Design System
- PR #3548 current exact head `e040eab4bba72b615b0641cb95549982a73a4d18`, 20 commits ahead / 30 behind canonical (DIVERGED).
- Build `44421110716`: Analyze, Debug APK and Release APK passed; all six test shards failed.
- Device Smoke `44421110586`: six scenarios passed; Home scenario failed. Follow-up Persistence `44421111448` passed.
- Logged root failures include old Home header/finders not matching new header text, old notification key removed, old Project label mismatch, and the known v8→v9 executor-open fixture defect. Do not change expectations merely to silence these failures.
- Preserve the ArvinColors adjustments present in the UI candidate; candidate palette values are primary `#078B91`, primaryDark/header `#066F75`, primarySoft `#DDF7F5`, background `#F0FAF9`, border `#D9ECEA`. Keep the token candidate as evidence, but do not accept PR #3548 while its six shards and Home smoke fail.
- The candidate token file covers Spacing, Radius, Motion, Touch Targets and Typography. A shared Components layer and a complete cross-page literal audit remain open.

### Lane C — REV10 Home / Center
- Five due-date groups already exist in canonical Home source: overdue, today, tomorrow, future, no_date.
- Home still exposes only four filter dimensions: Time, Project, Category and Tags. Center is missing from UI state and active filter semantics.
- Schema 9 includes Center/M2M tables, but Center model, CenterStore, management page, Home integration and Backup/Restore acceptance are not present on canonical SHA.
- Issue #3550 remains the active tracking issue. Center capability is NOT ACCEPTED.

### Lane D — PR #3547 independent acceptance
- Shard 2 remains a recorded FAIL on the exact #3547 head.
- Passing tests on PR #3549 do not transfer to PR #3547.
- Re-run all six shards on the final canonical candidate after the fix is ported; never delete, skip or weaken tests.

### Lane E — Typography / other pages
- Actual ZIP `vazirmatn-v33.003 (2).zip` re-inspected: 13,047,191 bytes, SHA-256 `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`, 387 entries, ZIP CRC clean, SIL OFL 1.1, Vazirmatn static weights 100–900.
- Canonical repository still registers only 400/500/700 and contains only those three TTF files.
- Existing Settings text-size Slider is present, persists via AppSettingsService and is wired to root MediaQuery.textScaler; preserve it and verify app-wide behavior instead of recreating it.
- Other-page visual and accessibility acceptance remains open.

### Current acceptance vocabulary
- Person tombstone fix: CI TESTED on PR #3549 SHA; NOT INTEGRATED / NOT ACCEPTED.
- PR #3547: BLOCKED by test-2.
- PR #3548: BLOCKED by six failed shards and Home smoke.
- REV10 Home: five groups present; Center filter missing.
- Center: schema present; feature path incomplete.
- Vazirmatn: archive/license verified; repository weight registration and visual tests incomplete.
- Release: NO-GO. No merge, release or deployment authorized.


---

## COMMAND 60-R.1 — implementation and exact-SHA validation update — 2026-11-19 / ۲۸ آبان ۱۴۰۵

**Current code candidate SHA:** `c94f96b0847005c6e037503455a6c1bc7c2aec7b` on `recovery-02/main-based-integration` / PR #3495.
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — unchanged.
**Build:** run `44472443857` — SUCCESS on exact code SHA `c94f96b0847005c6e037503455a6c1bc7c2aec7b`.
- Analyze PASS.
- Test-0 through Test-5 PASS.
- Debug APK PASS, including font packaging audit and APK verification.
- Release APK PASS, including font packaging audit and APK verification.
- File-backed Person exclusion/reopen test PASS.
- Backup → fresh file-backed SQLite Restore → reopen → same-ID re-add test PASS (Test-4).
- Person Directory page removal contract and Schema executor lifecycle tests PASS.
**Follow-up File Persistence:** `44472443858` — SUCCESS.
**Device Smoke:** `44472443854` — at last poll Home and Quick Capture PASS; SQL Persistence and SQL Migration IN PROGRESS; Backup/Restore, People and Calendar QUEUED.
**COMMAND 20-E:** `44472443836` — SharedPreferences write/stop/fresh-process read still IN PROGRESS.

### Path A decision
The original #3547 test-2 defect was reproduced as `Expected empty / Actual PersonReference` after directory deletion. The minimal exclusion-table fix is now integrated on canonical PR #3495. The exact canonical SHA passes all six shards and Build; the new Backup/Restore regression also passes. Keep Path A IN PROGRESS until Device Smoke (especially People and Backup/Restore) and COMMAND 20-E finish. PR #3547 itself remains NOT ACCEPTED at its old SHA; no result transfers retroactively.

### Path B — Design System audit
PR #3548 head `e040eab4bba72b615b0641cb95549982a73a4d18` remains blocked: Build `44421110716` failed all six shards; Device Smoke `44421110586` failed Home. Preserve its owner-approved ArvinColors palette as the integration target, but do not merge that PR.
A targeted scan of core UI files found remaining literal color duplicates in `task_detail_page.dart`, `arvin_primary_navigation.dart`, `arvin_home_primary_add_button.dart`, `arvin_radio_box.dart`, `project_selector_field.dart`, `task_recurrence_page.dart` and `home_visual_integration.dart`. Independent radius constructors remain across Home, Calendar, Task Editor, Notebook, Reports, Navigation, Quick Capture, Date/Time pickers and other pages. Full 175-file scan and migration to shared Components tokens remain open.
The token candidate currently defines Spacing, Radii, Motion, Touch Targets and Typography; a Components token layer is still missing.

### Path C — Home and Center
Canonical `main.dart` renders five due-date groups (overdue/today/tomorrow/future/no_date), and Home contract tests verify them. A secondary `HomeGroupingService` still has only four time groups and no separate tomorrow group; it is not called by main.dart and must be reconciled to avoid a second conflicting grouping contract.
Home exposes only Time, Project, Category and Tags filters. Center is still absent from Home state/query/UI. Issue #3550 remains OPEN.
Schema 9 tables are present; Center model, CenterStore, management page, Home selection/query, Task direct assignment and Backup/Restore integration remain unimplemented/unaccepted.

### Path E — Vazirmatn
Actual archive SHA-256 `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`; 387 ZIP entries; CRC clean; Vazirmatn weights 100–900; SIL OFL 1.1. Canonical repo still packages only 400/500/700. Build font packaging audit PASS applies only to those currently registered assets, not to the full family. Settings text-size Slider remains persisted and applied by root MediaQuery.textScaler. Full font weight registration, Persian/Latin digit visual checks and cross-page typography acceptance remain open.

**Overall release:** NO-GO. No merge, deployment or release authorized.


---

## COMMAND 106-R — Root-cause repair and P0-A acceptance checkpoint
**Updated:** 2026-11-20  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Canonical branch:** `recovery-02/main-based-integration`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — read-only  
**Implementation checkpoint before this tracker-only update:** `7cbbb16fb30f137ea690bbc5f4ca066c8051ca3a`  
**P0-A:** BLOCKED — RELEASE NO-GO

### COMMAND 20-E repairs committed on the canonical branch
- `bc3d10d65df631f3c9573739b392a5c0161c958a`: KVM setup and hardware-acceleration configuration aligned with Device Smoke; no forced `-accel off`.
- `de0278d5e4ba0c2fa1b077547f4db7fc06dc32eb`: Calendar fixture expanded from two to eight independently identified ExternalCalendarEventLink records.
- `a18af7c2b8aa5fb002653624b850b9587d442dec`: restart comparison changed to eight Link IDs and 32 individual field comparisons; Process A/B PID identity is required.
- `92b0dfb86f86b744f0ef9d87eba4da7eff654be2`, `a7f381c60315068fa07a81dda0165d45b9dffbd8`, `b86554baf708a18f1b75ed1eb9eb92b293377049`, `8cd7c6ff3e208a5b943e82d1359792e19b8118d3`: explicit evidence-state parser and unit coverage for PASS, FAILURE, NOT TESTED, INCOMPLETE EVIDENCE, empty/missing files, incomplete reports and contradictory reports.
- `e1696b499fe08b346382e3283b05ba51ae6e35ef`, `53ab4cde2b3cb7a48c8d76bb3c152896210bff48`, `0f6b583ca552998cc3e9ffe76e368d118e3486ed`, `b1f212a00c18ec890eab6fb35f9ec05913193605`, `7cbbb16fb30f137ea690bbc5f4ca066c8051ca3a`: explicit test outcomes, SDK/ADB/API/ABI evidence, KVM availability enforcement, prevention of emulator launch without KVM, and tracker-change workflow trigger.

### Evidence classification and exact-SHA gate matrix
All implementation statuses below remain unaccepted until exact-SHA workflow evidence completes. Historical results do not transfer to the new candidate.

| Gate | Status | SHA | PR / Issue | Run ID | Test / Evidence | Remaining work |
|---|---|---|---|---|---|---|
| Emulator KVM configuration | TESTING | `7cbbb16fb30f137ea690bbc5f4ca066c8051ca3a` | #3495 | Pending for this SHA | `command-20c-storage-persistence.yml`; KVM required and recorded | Verify actual `/dev/kvm`, Emulator boot and ADB device |
| Calendar eight-Link fixture | TESTING | same | #3495 | Pending | `command20e_calendar_restart_fixture.dart` | Execute on Android; confirm 8 IDs and all 32 values |
| Process A/B persistence | TESTING | same | #3495 | Pending | force-stop, PID absence, fresh launch and PID comparison in `command-20e-calendar-restart.sh` | Prove distinct PIDs and compare all restored values |
| Evidence parser | TESTING | same | #3495 | Pending | `command-20e-evidence-parser.sh` and independent eight-case test script | Execute unit tests in workflow; inspect output |
| Cleanup classification | TESTING | same | #3495 | Pending | explicit execution/result markers | Verify cleanup PASS/FAILURE/NOT TESTED semantics |
| ProjectStore file persistence | NOT TESTED | same | #3495 | Pending | file-backed test | Execute on same candidate SHA |
| Build Analyze, shards 0–5, Debug/Release APK | NOT TESTED | same | #3495 | Pending | exact-SHA Build | All jobs must complete successfully |
| Device Smoke | NOT TESTED | same | #3495 | Pending | exact-SHA Android emulator scenarios | All seven scenarios must pass |
| Follow-up File Persistence | NOT TESTED | same | #3495 | Pending | exact-SHA workflow | Complete and verify artifact |
| P0-A / COMMAND 20-E acceptance | BLOCKED | same | #3495 | Pending | all above gates | No acceptance until every required gate passes |

The previously observed run `44739076355` targeted SHA `aec1e9c328b3555ee1328f9c7f02e73fafdae4a1`; it is not evidence for this checkpoint. Runs on earlier SHAs were cancelled or remain non-transferable.

### Product and data-safety blockers
| Capability | Status | Issue | Remaining work |
|---|---|---|---|
| Four-action Floating Reminder | BLOCKED | #3646 OPEN | Implement dedicated Arvin full-screen/floating Activity, four canonical actions, visual-reference match and Android lifecycle/device acceptance |
| Sequential migration v7→v20 | BLOCKED | #3495 | Prove ordered, file-backed migrations and full historical data parity |
| NULL / unknown-field preservation | NOT TESTED | #3495 | Verify every required model and relationship |
| Backup A/B, repeated restore and rollback | NOT TESTED | #3495 | Physical file-backed backup/restore and failure-injection evidence |
| SQLite Integrity / Foreign Keys | NOT TESTED | #3495 | Execute on migrated and restored databases |
| Argon2id / AES-256-GCM | NOT TESTED | #3495 | Wrong password, tampered file and key derivation tests |
| Android SAF | NOT TESTED | #3495 | Real Android document-provider export/import |
| Center / Project / Category / Tag unified management | BLOCKED | #3495 | SQLite M2M integration, CRUD UI and relation integrity |
| Five Home filters and OR/AND contract | NOT TESTED | #3495 | Real SQL-backed filter and sort acceptance |
| Task, Quick Capture, People, Follow-up, Checklist, Recurrence, Calendar, Notebook, Reports, PDF, Settings, typography, RTL and Accessibility | NOT TESTED | #3495 | Independent user scenarios, tests, artifacts and exact SHA per capability |

### Governance
- Main remains read-only.
- PR #3495 remains OPEN / DRAFT / UNMERGED.
- No merge, release, deployment or production database operation.
- No test was intentionally removed or weakened.
- P0-A is still BLOCKED. The implementation commits are not acceptance evidence.
- The tracker-only update creates a new HEAD; all required exact-SHA workflows must be rerun on that resulting HEAD before any gate can move to ACCEPTED.

---

## COMMAND 107-R — live audit and COMMAND 20-E KVM probe correction
**Updated:** 2026-11-20 / ۲۹ آبان ۱۴۰۵  
**Canonical route:** PR #3495 / recovery-02/main-based-integration  
**Main SHA:** 45e4202b03a434459e4c021a04efa7e8396359db  
**Starting exact SHA:** 3a71b06420cb72399f2664a5bafd0764ed52d8af  
**KVM correction commit:** 4bc23b1af7ef57ad165c38b87164db2f7ebb1a51  
**Current tracker update:** pending commit SHA; all exact-SHA gates must be rechecked on the resulting HEAD.

### Starting-SHA evidence (3a71b06420cb72399f2664a5bafd0764ed52d8af)
| Workflow | Run ID | Status | Scope |
|---|---:|---|---|
| Build | 44739337119 | PASS | Analyze, shards 0–5, Debug/Release APK, font audit, APK verification |
| Device Smoke | 44739337203 | PASS | Home, Quick Capture, SQL Persistence, SQL Migration, Backup/Restore, People, Calendar |
| Follow-up Persistence | 44739337210 | PASS | File-backed SQLite persistence |
| COMMAND 20-E | 44739337105 | FAILURE | KVM probe rejected access; emulator/process/calendar stages not executed |

### COMMAND 20-E failure evidence
- Parser unit tests passed.
- File-backed ProjectStore test passed, including close/reopen and SQLite integrity/foreign-key checks.
- /dev/kvm existed with displayed mode crw-rw-rw-, but the shell -r/-w check returned false.
- Process A/B was skipped because the workflow correctly gates emulator execution on KVM verification.
- Calendar Stage A/B and cleanup logs were absent; Collector classified these as NOT TESTED and the overall result was NO-GO.
- Device Smoke's KVM step applied udev rules but did not independently verify KVM API access. Its seven passing scenarios do not replace COMMAND 20-E evidence.

### Code correction
Commit 4bc23b1af7ef57ad165c38b87164db2f7ebb1a51 changes only .github/workflows/command-20c-storage-persistence.yml:
- requires the KVM character device and Android Emulator executable;
- opens /dev/kvm read/write and checks KVM_GET_API_VERSION == 12 using ioctl;
- runs Emulator -accel-check and records its output;
- fails closed; no TCG/software-emulation fallback;
- preserves API 35, x86_64 and the independent Process A/B procedure.

**Correction status:** IN PROGRESS / NOT TESTED on the corrected SHA. This is a more direct hardware-access probe, not an acceptance result. The GitHub connector currently exposes no workflow-dispatch action; exact-SHA CI dispatch/confirmation remains pending and no run is claimed for this correction.

### Product and architecture status
| Capability | Status | Issue | Evidence / next action |
|---|---|---|---|
| COMMAND 20-E / P0-A | BLOCKED | #3495 | Corrected KVM probe requires exact-SHA run; then prove real Process A/B, eight Links, 32 assertions and cleanup |
| Four-action Floating Reminder | BLOCKED | #3646 | Current branch audit found notification service only; no dedicated full-screen Activity or four-action controller. Implement canonical Task/Reminder actions and obtain owner visual reference if not in repository |
| Center / Project / Category M2M and Home | BLOCKED | #3550, #3458 | Center model/store/management and five-filter Home integration remain incomplete; preserve approved M2M semantics |
| v7→v20 migration | BLOCKED | #3495 | Build auditable sequential file-backed migrations; do not conflate v9 hierarchy migration with historical v7→v19 path |
| NULL / unknown fields / relationship parity | NOT TESTED | #3495 | Per-model round-trip and identity/relationship fixtures |
| Independent Backup/Restore, rollback and integrity | NOT TESTED | #3495 | Independent A/B databases, failure injection, repeated restore, integrity and FK checks |
| Argon2id / AES-256-GCM | NOT TESTED | #3495 | Wrong password, tampering, truncation, unknown envelope and invalid KDF tests |
| Android SAF | NOT TESTED | #3495 | Real document-provider tests on Android; mocks are insufficient |
| Remaining product features / RTL / accessibility | NOT TESTED | #3495 | End-to-end persistence, restart, edit/delete, error recovery and visual evidence |

### Governance
- Main remains read-only at 45e4202b03a434459e4c021a04efa7e8396359db.
- Development remains on the existing canonical branch and PR #3495; no parallel branch or PR created.
- No merge, release, deployment, production database operation or branch deletion.
- No status is ACCEPTED without evidence on one exact candidate SHA.
- **Release: NO-GO.**


---

## MASTER EXECUTION COMMAND 124-R — live audit checkpoint (2026-11-21)

**Canonical Candidate:** `c033513de5bd0067a093c59303c4071acf42f564` (verified live HEAD; unchanged during audit).
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` (unchanged/read-only).
**PR #3495:** OPEN / DRAFT / UNMERGED; 430 ahead / 0 behind.

### Exact-SHA CI results
- Governance run `44874825945`, job `136757113713`: SUCCESS.
- Build/Analyze run `44874825859`: all 9 jobs SUCCESS.
- Device Smoke run `44874825857`: all 8 jobs SUCCESS; CI device/emulator only, not physical phone.
- COMMAND 20-E run `44874825813`, jobs `136757113613` and `136758814805`: SUCCESS.
- Follow-up File Persistence run `44874825843`, job `136757123714`: SUCCESS.
- Zero Dollar Environment Smoke run `44874821618`: PENDING; no jobs exposed.
- Build artifacts `14695861569` (debug) and `14695327649` (release) exist. Their recorded digests are artifact archive digests, not APK SHA-256.

### Product acceptance findings
- REV10 charter is embedded in `docs/project-continuity/MASTER_GOVERNANCE.md`; no PDF exists in the canonical branch tree. The source Git blob SHA is `cdea45d11f4e25795231f2aca10cfdc1b6cde521`; source SHA-256 remains NOT CALCULATED.
- Home implementation still has four filter dimensions/cards. Center is missing from `HomeFilterDimension` and `lib/main.dart`; Home five-filter acceptance is BLOCKED.
- Center model/store and file-backed test exist, but Center management UI, Task Editor, Quick Capture, Task projection, Home and report integration remain unaccepted.
- Project↔Category table exists in schema v9; canonical Store/UI/backup integration is not accepted.
- Reminder Issue #3646 remains open; four-action Android UI and process/reboot/physical-device acceptance remain BLOCKED.
- Migration v7→v20, independent backup/restore and full parity remain INCOMPLETE EVIDENCE.

### Governance findings
- Active ruleset `20952260` protects Main against deletion and non-fast-forward and requires PRs, but has zero required approvals, CODEOWNERS review disabled, review-thread resolution disabled and no required CI checks.
- Canonical branch protection is disabled. Branch protection endpoints returned 403 to the active integration; no settings were modified.
- Main remained unchanged. No merge, release, deployment or production-data migration occurred.

### 124-R deliverables
- Added canonical baseline, owner-decision, feature-acceptance and change-control records under `docs/rev10/`.
- This tracker update records exact-SHA evidence and open acceptance boundaries. All feature statuses remain conservative; generic CI success is not product acceptance.


## MASTER EXECUTION 131-R live recovery checkpoint — 2026-11-21
- Audited Candidate: `e380ffd86c4157796cecd6a0d9c4a21716344d55`; Main: `45e4202b03a434459e4c021a04efa7e8396359db`; PR #3495 OPEN / DRAFT / UNMERGED; 434 ahead / 0 behind.
- COMMAND 20-E run `44880424929`: PASS on the exact Candidate SHA. Attempt 2 Device Smoke run `44880424928` reports People SUCCESS; stale artifact `14698614096` is superseded by latest artifact `14699814794`.
- Zero Dollar run `44876935899` is an older-SHA environment failure: KVM was unavailable but software fallback was selected; AVD was not found and product smoke was not reached. Issue #3654 tracks the workflow correction.
- Historical source-to-acceptance ledger: [REV10-HISTORICAL-RECOVERY-MATRIX.md](REV10-HISTORICAL-RECOVERY-MATRIX.md).
- Current exact-SHA CI: Build `44880424925` PASS; Governance `44880424937` PASS; Device Smoke Attempt 2 `44880424928` PASS; COMMAND 20-E `44880424929` PASS; Follow-up Persistence `44880424931` PASS.
- No Main write, merge, release, deployment or production-data operation occurred.


## Zero Dollar follow-up forensic correction — 2026-11-21
- Run `44890531184` on `1facd26252157f79904d09794eb9b0ee35f0f9a1` confirmed the shared AVD home and generated `.ini` / `config.ini` successfully.
- Emulator 37.3.10 then failed because KVM was unavailable and `-accel off` requires `ANDROID_I_WANT_MY_TCG=yes`; exact error preserved in artifact `14702045917`.
- Issue #3654 updated with this root cause. Next fix exports `ANDROID_I_WANT_MY_TCG=yes`; rerun required. Product smoke not reached; do not classify as product failure.


## MASTER EXECUTION 148-R — implementation checkpoint (2026-11-21)

- Starting Candidate: `026f1cdaeb63fe804b685cbffa0ff9da3579de0d`.
- Main baseline: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Final checkpoint in this entry: `6ac6ead1d18d3d4915a4861dc8b1b4c9273f6e8b`.
- PR #3495 remains OPEN / DRAFT / UNMERGED; branch `recovery-02/main-based-integration`; compare 451 ahead / 0 behind.
- No Main write, merge, release or deployment.

### Commits
1. `bc983d1fa21575dc26b4122545b6a6ea3e010f59` — Missing historical Center reference is recorded through the existing migration exception engine.
2. `512444b8661ba64023ed892ace0b6ffcec9b0358` — targeted migration test for missing Center reference.
3. `eb387c701875204bd219cc505866f39b21d31959` — preserve orphaned historical Center ID in `projects.legacy_center_id`, clear only the invalid FK edge, and retain the exception record.
4. `543130858812d195bba9270bf5c7930dd85cb694` — assert Project preservation, exception metadata and FK check in the targeted test.
5. `a89c6853df206c41c3193bb373ce38b295157282` — add independent historical v8 DDL fixture with all 16 source CREATE TABLE statements and the one source-defined partial unique index.
6. `540bd15e486f015a188f5deb9c0b34a3192665fc` — add an isolated SQLite fixture test and deterministic SHA-256 DDL fingerprint assertion.
7. `40f2ee47b776f715ca27353a8a0c75e60ac2471b` — document fixture scope and remaining acceptance work.
8. `6ac6ead1d18d3d4915a4861dc8b1b4c9273f6e8b` — correct the fixture test reference in the README.

### Source-backed results and limitations
- Historical source commit `874dd8b567fdceae7ed62f01a93804dcea1a5473`, blob `f4d488fa3f972c4ce123df6089b66569b9c8849c`, was fetched directly. It contains 16 CREATE TABLE definitions and one explicit partial unique index: `idx_projects_active_template_center`.
- DDL file SHA-256: `9a11f8952cf1d11bebd020a785021e7f051410580762a6b78276b7b0f89dc2ba`.
- Historical DDL fixture and a structural test have been committed. The test has NOT yet been executed; the fixture does not yet contain the full requested deterministic historical data set. Historical fixture acceptance remains PARTIAL.
- Missing Center handling now records `PROJECT_CENTER_REFERENCE_MISSING` in the existing `arvin_migration_exceptions.details_json`, with source entity/record, original Center ID, migration version, exception type, reason, original field reference and pending recovery status. The orphaned ID is retained in `legacy_center_id`; `center_id` is nulled only to remove the invalid FK edge. This code and its test are NOT YET RUN; migration acceptance remains NOT ACCEPTED.
- People source trace confirms awaited TaskPeopleService→TaskStore.mutate→transactional TaskStore persistence. The actual disappearance mechanism remains unconfirmed; no People code correction is claimed.
- Existing independent backup test uses distinct Database A/B files and covers Task/People/Follow-up payload, repeated restore and rollback. Full Center/Project/M2M/Calendar/exception parity and close/reopen acceptance remain PARTIAL.
- On final checkpoint `6ac6ead1d18d3d4915a4861dc8b1b4c9273f6e8b`, the available PR-triggered workflow-run query returned no runs and combined commit status returned no status checks. This is NOT RUN / UNVERIFIED, not PASS.
- COMMAND 20-E, Build, Analyze, six shards and Device Smoke have not been verified on this exact SHA. Historical run results are not transferable.

### Mission 148-R disposition
IN PROGRESS / BLOCKED ON EXECUTION EVIDENCE. The available GitHub integration can read and commit repository files but this execution did not provide a local Flutter/Android runner or an Actions dispatch operation. Do not accept the migration, fixture, People, Backup/Restore or overall mission until exact-SHA tests and CI complete.


## MASTER EXECUTION 149-R — live implementation and acceptance checkpoint (2026-11-21)

### Canonical revision and governance
- Mission starting Candidate: `dc1a3f797009134a52467c7e2f6a3a7f77d3e762`.
- Previous starting SHA: `026f1cdaeb63fe804b685cbffa0ff9da3579de0d`.
- Main baseline and verified Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Pre-documentation code Candidate: `1b07eb6d03689f8eb73dd94934d37061e6bc5d63`.
- PR #3495 remains OPEN / DRAFT / UNMERGED; canonical branch remains `recovery-02/main-based-integration`.
- The 148-R chain from `026f1cda...` to `dc1a3f...` was independently compared: 9 commits ahead, 0 behind. All 9 are preserved.
- Mission 149-R added 19 commits from `dc1a3f...` through the code Candidate above; compare reports 475 ahead / 0 behind Main before this tracker update.
- Main is READ-ONLY. No merge, release, deployment, force-push or history rewrite.
- Local working-tree state is not observable through the GitHub API; report as UNKNOWN, not clean.

### Mission 149-R changed files
1. `integration_test/calendar_card_interaction_test.dart`
2. `lib/services/g1_drift_schema.dart`
3. `lib/services/g1_rev10_hierarchy_v9_migration.dart`
4. `lib/services/project_store.dart`
5. `test/independent_sqlite_backup_restore_test.dart`
6. `test/services/g1_rev10_hierarchy_v9_file_migration_test.dart`
7. `test/services/historical_v8_fixture_test.dart`

### Implementation record
- Historical v8 fixture parser now removes full-line SQL comments before splitting statements, preventing semicolons inside comments from becoming executable SQL.
- Historical fixture test now executes the DDL in an independent SQLite database; calculates a normalized structural fingerprint from actual `sqlite_master` table/index definitions; checks the 16 historical table column lists and foreign-key declarations; and seeds template, template-task, template-application, project_items, active/archived Project and explicit NULL records. Golden fingerprint currently asserted as `2fdd5eb5385fc6f0933498bd70f2872d214cadb63e8909b834510142aebcba15`. This assertion is NOT YET ACCEPTED until the exact-SHA test shard passes.
- The earlier migration test's expected Project count was incorrect. The source has four Project rows at that checkpoint; the test was corrected to assert that orphaned historical Projects survive with only invalid FK edges cleared.
- Further source inspection found `legacy_center_id` was absent from the fresh destination DDL and conditionally added only when an orphan existed. It is now declared as nullable TEXT in the destination schema and added unconditionally during v8→v9 upgrade when absent.
- ProjectStore now maps the dedicated SQL `legacy_center_id` into the lossless Project envelope and writes it back on insert/upsert, enabling serialization and backup/restore retention.
- Backup/Restore regression now includes a Project with `legacyCenterId`, restores it from independent Database A into Database B, closes/reopens B, and checks the historical ID survives. This is a focused parity test, not full Backup/Restore acceptance.
- Migration fixture now includes three valid Center links, two different missing Centers and one explicit NULL Center; six Projects including active and archived records; two exception records; and failure injection at relationship transfer, before exception insertion, after exception insertion and before the completion marker. Each injected failure starts from a fresh file-backed v8 database and asserts rollback of the new column, relationship table, exception table and completion marker. Successful retry checks durable IDs, duplicate prevention and FK integrity.
- Calendar Device Smoke root cause on the starting Candidate was a lazy-list test-harness issue: the expected reminder was present in the projection and selected-day filter, but the test searched for its card key before scrolling the ListView past earlier calendar items. Integration test now scrolls until the reminder title is visible before asserting the card.
- Historical People failure Run `44909382967` is confirmed at the empty `persisted.people.single` assertion. People Device Smoke passed on starting Candidate `dc1a3f...`; no production correction is claimed because the historical failure was not reproduced there. Exact latest-Candidate People rerun remains required.

### Initial 148-R Candidate workflow evidence
On `dc1a3f797009134a52467c7e2f6a3a7f77d3e762`:
- Build `44925872319`: FAILURE; Analyze, Debug APK, Release APK and shards 0,1,3,4,5 passed, shard 2 failed with the fixture parser defect and Project-count expectation defect.
- Device Smoke `44925872346`: FAILURE; Calendar failed due lazy selected-day list lookup; People lane passed.
- COMMAND 20-E `44925872381`: FAILURE; final evidence gate did not report overall PASS.
- Governance `44925872334`: SUCCESS.
- Follow-up Persistence `44925872313`: SUCCESS.
These historical results are diagnostic only and are not transferable to the final Candidate.

### Latest exact-SHA workflow snapshot before this tracker commit
Pre-documentation code Candidate: `1b07eb6d03689f8eb73dd94934d37061e6bc5d63`.
- Build `44929930326`: RUNNING. Analyze SUCCESS; test shard 5 SUCCESS; other five shards and Debug/Release APK jobs RUNNING at checkpoint.
- Device Smoke `44929930251`: RUNNING; Home and Quick Capture RUNNING; SQL Migration, Backup/Restore, SQL Persistence, Calendar and People queued at checkpoint.
- COMMAND 20-E `44929930261`: storage-persistence job RUNNING; final evidence gate not yet produced.
- Follow-up Persistence `44929930248`: SUCCESS.
- Governance `44929930321`: SUCCESS.
- Artifact IDs for Build, Device Smoke and COMMAND 20-E: NOT YET AVAILABLE at checkpoint.
- The prior Candidate `5b828b46...` Analyze failed because `centerColumns` was scoped inside a loop; corrected in `1b07eb6d...`. Do not use the earlier Candidate's result as acceptance.

### Acceptance status at checkpoint
- Canonical HEAD / PR / Main protection: VERIFIED.
- Nine previous commits preserved: VERIFIED.
- Historical fixture execution and structural fingerprint: IMPLEMENTED / CI PENDING.
- Missing Center exception matrix and legacy ID schema: IMPLEMENTED / CI PENDING.
- Project serialization and focused backup/restore ID retention: IMPLEMENTED / CI PENDING.
- People root cause: NOT CONFIRMED; latest rerun PENDING.
- Full Backup/Restore matrix including Center entities, Migration Exceptions, all M2M relationships, Calendar Links, corruption/interrupted restore and destination preservation: PARTIAL / NOT ACCEPTED.
- COMMAND 20-E Overall: NOT YET PRODUCED.
- Build Analyze: PASS on pre-documentation code Candidate; exact final SHA rerun required after this tracker update.
- Six shards, Debug APK, Release APK, Device Smoke: IN PROGRESS / NOT ACCEPTED.
- Center management UI, Center in Task Editor/Quick Capture/Home, Project↔Category M2M product flows, Home five filters, five time groups, Reminder four actions, Calendar full product acceptance, Templates/Deep Clone, Notebook, Reports, RTL, Accessibility and Unified Design System: NOT ACCEPTED in this mission checkpoint.
- Issues #3619, #3641, #3550, #3646, #3458 and #2102 received 149-R progress comments; none was closed.

### Mission disposition
149-R remains IN PROGRESS. This tracker entry is a checkpoint, not a final acceptance certificate. After this documentation commit, all required workflows must be rerun and tied to the new exact HEAD. Anything not proven on that SHA remains PARTIAL / BLOCKED / NOT RUN / NOT ACCEPTED. Release remains NO-GO; merge and deployment are not authorized.


---

## MASTER EXECUTION 150-R — ENTITY-CENTRIC CONTINUOUS ENGINEERING (2026-11-21)

### Canonical refs and history
- Mission 150-R began from the reported 149-R Candidate `aad43e6e2dc3e1a53ef77912c7a0c1522962f64d`; the live branch HEAD at first audit matched that SHA.
- Main remained `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 remained OPEN / DRAFT / UNMERGED; canonical branch `recovery-02/main-based-integration`.
- 148-R ancestry `026f1cdaeb63fe804b685cbffa0ff9da3579de0d` → `dc1a3f797009134a52467c7e2f6a3a7f77d3e762`: 9 commits ahead / 0 behind.
- 149-R ancestry `dc1a3f797009134a52467c7e2f6a3a7f77d3e762` → `aad43e6e2dc3e1a53ef77912c7a0c1522962f64d`: 21 commits ahead / 0 behind.
- No known 148-R/149-R commit was dropped. GitHub's public API does not expose a complete branch reflog, so absence of every historical force-push event cannot be independently proven; no history rewrite is visible in the compared ancestry.
- Local working-tree state is not observable through GitHub API.

### 149-R exact-SHA CI disposition
On `aad43e6e2dc3e1a53ef77912c7a0c1522962f64d`:
- Build `44930273125`: FAILURE; Analyze, Debug/Release APK and five test shards succeeded; shard 2 failed only at Historical V8 Structural Fingerprint.
- Follow-up Persistence `44930273121`: SUCCESS.
- Governance `44930273112`: SUCCESS.
- Device Smoke `44930273117`: SUCCESS.
- COMMAND 20-E `44930273200`: FAILURE/NO-GO because the exact-SHA Build shard failed; its own ProjectStore persistence, Calendar process-restart evidence and cleanup stages passed.
- Historical V8 fixture source-file fingerprint passed; structural golden `2fdd5eb5...` differed from actual `8a757091...`. The mismatch was reproduced independently by executing the exact fixture DDL against SQLite 3.46.1; the source fixture SHA remained `9a11f8952cf1d11bebd020a785021e7f051410580762a6b78276b7b0f89dc2ba`.
- COMMAND 20-E artifact `14718475191` was downloaded and inspected. It records eight Calendar links, 32 field assertions, process stop/restart and ProjectStore file persistence as PASS. The final overall gate remained NO-GO due the Build failure.
- Release APK artifact `14718000275` was downloaded. The contained `app-release.apk` SHA-256 is `780c22af17e3f59b70e1a0140d7b62bc38424f4ac44fe9d90a297a54f1e681ab`. This is artifact verification, not release approval.
- Device Smoke screenshot artifact `14717368419` was downloaded and inspected; it shows the Calendar screen. No physical-phone acceptance is claimed.

### 150-R correction committed
- Commit `ac52f706a6b785a2b194a46bc97866d48c54b5e5` changes only `test/services/historical_v8_fixture_test.dart`.
- Structural Fingerprint now uses stable SQLite PRAGMA metadata: table columns, foreign keys, index attributes and index columns. It no longer hashes version-sensitive `sqlite_master` CREATE-statement formatting.
- Existing 16-table, column, FK and partial-index assertions remain. No assertion was removed or weakened.
- New metadata fingerprint golden: `ae240d3fd9e9af95cd3f503b282d58463613373585c967f4f80525e013751463`, independently computed from the historical fixture. Exact-SHA CI is required to accept it.

### Live CI after the correction commit
At the report preparation checkpoint, all runs below target `ac52f706a6b785a2b194a46bc97866d48c54b5e5`:
- Build `44932431149`: IN_PROGRESS.
- COMMAND 20-E `44932431140`: IN_PROGRESS.
- Governance `44932431141`: SUCCESS.
- Follow-up File Persistence `44932431161`: SUCCESS.
- Device Smoke `44932431155`: QUEUED.
- Zero Dollar Environment Smoke `44932427713`: PENDING.
No result from `aad43e6...` transfers to `ac52f706...`. The report-only commit that adds this 150-R evidence changes the Candidate again; its new exact-SHA CI must be followed separately.

### Entity and relationship audit
- The authoritative audit tables are [ENTITY-ACCEPTANCE-MATRIX.md](ENTITY-ACCEPTANCE-MATRIX.md) and [ENTITY-RELATIONSHIP-MATRIX.md](ENTITY-RELATIONSHIP-MATRIX.md).
- No entity is classified COMPLETE.
- Center has a real model, SQLite store, M2M relation methods and file-backed restart test, but no Center management page, Task Editor/Quick Capture/Home selection or backup integration.
- Home has four independent filters (Time / Project / Category / Tags), not the required five; five temporal groups remain present.
- Center↔Project join storage exists. Project↔Category join storage is created by migration but lacks canonical Store/API/UI integration.
- Task optional Center/Project/Category IDs are persisted in SQLite and tested, but Task Editor and Quick Capture do not expose Center assignment.
- The canonical Category table and legacy `taxonomy_categories` catalog coexist; TaskStore catalog operations still target the legacy string catalog.
- ProjectStore owns Project↔Task membership through `project_items`; direct `tasks.project_id` also exists. This dual representation needs one authoritative write/read contract.
- Reminder model, storage and scheduler foundations exist; the required four-action floating window is not implemented/accepted.
- Follow-up, People Directory, Notebook, Task Tags, Recurrence, Reports, Calendar and Backup have substantial existing implementation; none has full REV10 acceptance on the final Candidate.
- Templates, Template Tasks and Template Applications exist in the historical v8 fixture but have no verified current runtime model/store/UI path.
- Migration Exception rows are written transactionally to `arvin_migration_exceptions`; no complete exception-management or backup/restore path is verified.

### Data safety and backup
- The v8→v9 migration is additive and transactional. It creates Center/Project and Project/Category join tables, optional Task hierarchy FKs and an exception ledger; it preserves missing historical Center IDs in `legacy_center_id`, avoids manufacturing Centers, uses a completion marker and supports failure injection/rollback/retry.
- The file-backed migration test covers valid, missing and explicit-NULL Center references, multiple exceptions, rollback injection, retry and FK integrity.
- Historical V8 fixture contains 16 tables and one explicit partial index; its independent fixture test also asserts template tables, template tasks, applications, `project_items`, active/archived Projects and nullable historical values.
- Independent SQLite A→B backup/restore coverage includes Task, Project legacy Center ID, People, Reminder, Follow-up, unknown Task/Reminder fields, repeated restore and rollback. It does not yet prove full Center catalog, both M2M join tables, migration exceptions, corrupted backup, interrupted restore and destination preservation as one complete acceptance matrix.
- The portable backup currently includes Tasks, Projects, Calendar links, legacy Category/Tag catalogs and People. Center entities, Center↔Project, Project↔Category and Migration Exceptions are not included as canonical backup payload sections.

### Product and design findings
- `lib/arvin_colors.dart` defines Primary Blue `#4169A1`; the canonical palette and existing contract test are present.
- The active font registry and `pubspec.yaml` register Vazirmatn at weights 400, 500 and 700.
- No verified shared Action Rows or Universal Bottom Sheet component was found. Task Editor and Quick Capture contain direct modal-bottom-sheet implementations.
- No unified design-token package beyond the central color palette was found. A global 48dp touch-target audit and cross-page Auto-Save acceptance are not proven.
- Design System status: PARTIAL.

### Remaining product sequence
1. Resolve and pass the exact-SHA Historical V8 fingerprint test; retain every table/column/FK/index assertion.
2. Complete Center management UI and CenterStore search/sort; wire Center to Project, Task Editor and Quick Capture.
3. Add the fifth Home Center filter using real SQLite Task projections; preserve OR-within-dimension / AND-between-dimensions and all five time groups.
4. Implement canonical Project↔Category Store/API and transaction-safe relationship editing; reconcile legacy `project_items` and direct Task assignment semantics.
5. Implement the four Reminder actions and visual window without introducing a parallel scheduler.
6. Extend canonical Backup/Restore with Center, both M2M relations and Migration Exceptions; prove independent A→B restore, corruption/interruption rollback and destination preservation.
7. Recover runtime Templates/Template Tasks/Applications only from verified historical assets; do not infer or recreate from fixture rows.
8. Complete shared Design System components and full RTL/accessibility/48dp/Auto-Save audit.
9. Run final exact-SHA Build, all six test shards, Device Smoke, File Persistence, Governance, COMMAND 20-E and required release evidence. Keep Release NO-GO until all gates and owner approval.

### Final disposition
- Product acceptance against REV10: NO-GO / NOT ACCEPTED.
- Release: NO-GO.
- Merge, deployment and production-user-database migration: NOT AUTHORIZED.
- No progress percentage is reported: REV10 requirement weights and complete evidence coverage have not been established.
- Main was not modified. No merge, release, deployment or destructive production operation was performed.


### MASTER EXECUTION 150-R — exact-SHA follow-up after first correction (2026-11-21)
- Candidate `ac52f706a6b785a2b194a46bc97866d48c54b5e5` exact-SHA Build `44932431149` exposed two additional facts:
  - The portable PRAGMA fingerprint assertion passed; the fixture test then failed because it selected nonexistent `id` from `template_task_applications`. Historical v8 DDL defines `template_task_id`, `project_id`, and `task_id`. The assertion is corrected to select and verify `task_id`; no assertion was removed.
  - Release APK setup failed while Android SDK Manager downloaded NDK r28c: `Premature EOF`. This is an SDK download/setup failure, not a Dart/Flutter source compilation error. A fresh exact-SHA run is required.
- On the same Candidate: Analyze passed; Follow-up File Persistence `44932431161` passed; Governance `44932431141` passed. Device Smoke `44932431155` was cancelled after a newer branch update. COMMAND 20-E `44932431140` had no final conclusion at the last query.
- No Build, Device Smoke or COMMAND 20-E result from `ac52f706...` is transferred to a later Candidate.
- The next correction preserves the 16-table and application-row fixture checks and uses `task_id`, the actual historical key.


### MASTER EXECUTION 150-R — Center Store search implementation
- Added `CenterStore.search(query, includeArchived: false)` on the existing canonical SQLite Center table; it trims and case-folds the query, preserves name/id ordering, excludes archived Centers by default and supports explicit archived inclusion.
- Extended the existing file-backed Center lifecycle test to verify active/archived search, trimming, empty results and ordering.
- This does not duplicate the Center store or alter existing relationships. UI, Task Editor, Quick Capture, Home Center filter and Center-aware Backup/Restore remain open gaps.
- Exact-SHA CI is required before treating this Store improvement as accepted.


## MASTER EXECUTION 151-R — LIVE ACCEPTANCE ADDENDUM (2026-11-22)

**Audited Candidate:** `3c72a341fc1aac785a22b6fe151c23507c16793c`
**Main baseline:** `45e4202b03a434459e4c021a04efa7e8396359db`
**PR:** #3495 — OPEN / DRAFT / UNMERGED. **Release: NO-GO.**

### Exact-SHA CI
- Build `44933088338`: SUCCESS; all 9 jobs passed (Analyze, Test Shards 0–5, Debug APK, Release APK).
- Governance `44933088356`: SUCCESS.
- Follow-up File Persistence `44933088362`: SUCCESS.
- Device Smoke `44933088406`: FAILURE; Home, Quick Capture, SQL Persistence, SQL Migration, Backup/Restore and People passed; Calendar failed (6/7).
- COMMAND 20-E `44933088374`: FAILURE / NO-GO at aggregate acceptance.

### COMMAND 20-E artifact inspection
Final artifact `14719705601` and phase artifact `14718404033` were downloaded and inspected. Analyze, all six test shards, Debug/Release APK, ProjectStore file persistence, Calendar Link process restart, cleanup and Follow-up persistence passed. Process restart independently compared eight links × four fields = 32 values across distinct process PIDs 2334 and 2406. Cleanup passed without clearing app data. Aggregate NO-GO is caused by the Device Smoke Calendar failure; ProjectStore, process restart and cleanup are not the cause.

### Calendar failure boundary
The failing test is `integration_test/calendar_card_interaction_test.dart:169`. Logs prove the seeded Task was reloaded from SQLite and independent Reminder records were projected. The expected keyed Calendar card was nevertheless absent from the rendered list. The follow-on screenshot upload failed because its screenshot was not produced. Root cause is narrowed to Calendar UI/test interaction after projection; whether date selection, list construction, widget identity or test interaction is responsible remains unproven. No speculative correction is accepted.

### Entity acceptance addendum
- Center model, v9 SQLite catalog / `center_projects`, CenterStore CRUD/search/archive/restore and bidirectional M2M operations exist. File-backed Center CRUD/M2M close-reopen test exists and Build passed. Dedicated Center management UI, Project UI integration, Task Editor / Quick Capture / Details selection, portable Backup/Restore coverage and Home Center filter are not evidenced. Center remains PARTIAL.
- Center↔Project schema/store and additive idempotent link/unlink/lookups are IMPLEMENTED at storage layer; product UI and portable backup/restore relationship acceptance remain NOT ACCEPTED.
- Project↔Category join schema exists, but canonical Category model/store, relationship API/UI and accepted round-trip were not found. PARTIAL / NOT ACCEPTED.
- Home five-dimension filter contract, including Center and OR-within / AND-between semantics, remains NOT ACCEPTED.
- Reminder's four required operations (Stop Alarm, Follow-up, Snooze, Complete) are not all independently proven against canonical Task data with restart and backup/restore. PARTIAL / NOT ACCEPTED.
- Selected Backup/Restore Device Smoke passed, but independent Database A→B, repeated restore, corruption, interrupted restore, destination preservation and rollback matrix remains NOT ACCEPTED.

### Artifact IDs
Debug APK `14718821042`; Release APK `14718204892`; Smoke People `14718882016`; Smoke Home `14718517988`; Smoke Quick Capture `14718209271`; Persian Time Picker `14718612582`; COMMAND 20-E Phase `14718404033`; COMMAND 20-E Final `14719705601`.

### Disposition
150-R is NOT FINALIZED. No safe minimal Calendar source correction was committed because the root cause is not isolated. No code or tests were changed in this audit pass. No Main change, merge, release, deployment, destructive data operation, test removal or test weakening occurred.
