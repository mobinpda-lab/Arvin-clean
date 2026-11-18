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
