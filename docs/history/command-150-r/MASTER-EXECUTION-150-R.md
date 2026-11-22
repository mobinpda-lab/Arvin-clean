# MASTER EXECUTION 150-R — ENTITY-CENTRIC CONTINUOUS ENGINEERING

**Date:** 2026-11-21  
**Repository:** mobinpda-lab/Arvin-clean  
**PR:** #3495  
**Canonical branch:** recovery-02/main-based-integration

---

## Live audit and execution record

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
- New metadata fingerprint golden: `ae240d3fd9e9af95cd3f503b282d58463613373585c967f4f80525e013751463`, independently computed from the historical fixture. The ac52 exact-SHA test shard advanced past this fingerprint assertion.
- The next assertion then exposed a separate fixture-test defect: `template_task_applications` has `task_id`, `template_task_id`, and `project_id`, not `id`. The test incorrectly selected `id`; it is corrected to select and assert `task_id`, preserving the application row check.

### Live CI after the correction commit
At the report preparation checkpoint, all runs below target `ac52f706a6b785a2b194a46bc97866d48c54b5e5`:
- Build `44932431149`: FAILURE at Release APK setup because Android SDK Manager download of NDK r28c ended with `Premature EOF`; Analyze passed. Test shard 2 passed the new fingerprint assertion, then failed on the invalid `id` column query described above. Other test jobs were cancelled when a newer branch update arrived.
- COMMAND 20-E `44932431140`: IN PROGRESS at last status query; no final result claimed.
- Governance `44932431141`: SUCCESS.
- Follow-up File Persistence `44932431161`: SUCCESS.
- Device Smoke `44932431155`: CANCELLED after the newer branch update; no Device Smoke acceptance on ac52.
- Zero Dollar Environment Smoke `44932427713`: CANCELLED after the newer branch update.
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
1. Complete the Historical V8 fixture test: the portable PRAGMA fingerprint now passes; correct the invalid Template Applications test query to `task_id`, then pass the exact-SHA shard with all table/column/FK/index assertions retained.
2. CenterStore search is now implemented and covered in the file-backed lifecycle test. Complete Center management UI, wire Center to Project, Task Editor and Quick Capture, and preserve the existing canonical sort order.
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


## Detailed matrices
- [Entity Acceptance Matrix](ENTITY-ACCEPTANCE-MATRIX.md)
- [Entity Relationship Matrix](ENTITY-RELATIONSHIP-MATRIX.md)


## Live Candidate and evidence rule

The source audit SHA recorded above is the code snapshot inspected for this mission. The current delivery Candidate is always the live head of PR #3495 on `recovery-02/main-based-integration`; after this report publication, resolve that SHA from GitHub before acting. Every CI, artifact, test and acceptance claim must match that exact live SHA. Any later commit invalidates acceptance transfer until its own required checks finish.


### 150-R product-gap closure — CenterStore search

- Added `CenterStore.search(query, includeArchived: false)` using the canonical `centers` table and existing name/id sort order.
- Search trims whitespace, performs case-insensitive name matching, excludes archived Centers by default and supports explicit archived inclusion.
- Extended `test/center_store_file_persistence_test.dart` to prove active/archived search, whitespace trimming, no-match behavior and ordering on the existing file-backed database lifecycle.
- This is Store-level progress only. Center management UI, Task Editor, Quick Capture, Home Center filter and Center-aware backup/restore remain incomplete.
- Exact-SHA CI for the resulting Candidate is pending.


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

## MASTER EXECUTION 152-R — evidence finalization addendum (2026-11-22)
- The prior 150-R blocker was the Calendar Device Smoke assertion on Candidate `3c72a341fc1aac785a22b6fe151c23507c16793c`. Documentation-only commits advanced to `9d8dc6cd4474818e03cc1c5a7deed4dcb3d9a974`; all five executable Calendar/test files retained identical blob SHAs.
- Fresh exact-HEAD Build `44979607579`, Device Smoke `44979607528`, Governance `44979607509`, Follow-up Persistence `44979607500` and COMMAND 20-E `44979607577` all completed SUCCESS.
- Calendar Android smoke job `137077040499` passed and produced screenshot artifact `14737792173`. The prior failure is classified as NOT REPRODUCED; its underlying transient cause is NOT VERIFIED. No product-source fix is asserted.
- COMMAND 20-E final report `14736794580` has `overall = PASS`, with all six test shards, Analyze, Debug/Release APK, ProjectStore persistence, Calendar process restart, cleanup, Follow-up persistence and seven Device Smoke scenarios passing on the exact SHA.
- Therefore 150-R exact-SHA evidence finalization is COMPLETE. This does not imply full REV10 product acceptance or release readiness.
