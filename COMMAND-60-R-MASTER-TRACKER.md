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
