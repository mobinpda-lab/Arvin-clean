# REV10 HISTORICAL RECOVERY MATRIX — MASTER EXECUTION 131-R
**Audit date:** 2026-11-21 (1405/08/30)
**Repository:** `mobinpda-lab/Arvin-clean`
**Canonical route:** PR #3495 / `recovery-02/main-based-integration`
**Audit Candidate:** `e380ffd86c4157796cecd6a0d9c4a21716344d55`
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` (READ ONLY)
**Compare:** 434 commits ahead / 0 behind
**Authority:** REV10 + `docs/rev10/REV10-OWNER-DECISIONS.md`
**Purpose:** Recover implemented work and identify the exact missing layers. A passing test or existing class does not mean the entire entity is accepted.

## 1. Status vocabulary
- **COMPLETE** — all required layers and acceptance evidence are present on the audited candidate.
- **COMPLETE / VALIDATION REQUIRED** — implementation and scoped tests exist, but a required end-to-end/device/owner validation remains.
- **INTEGRATION INCOMPLETE** — core model/store or other layers exist; one or more required consumers/relationships are not connected.
- **PARTIAL** — substantial implementation exists, but full REV10 behavior or evidence is incomplete.
- **REGRESSION** — a verified regression currently affects the candidate.
- **NOT IMPLEMENTED** — no current implementation evidence found in the canonical tree.
- **BLOCKED** — data safety, dependency, environment or required acceptance prevents progression.

## 2. Entity matrix
| Entity | Latest relevant commit / evidence | Model | Store / Database | UI | Integration / Projection | Tests | Backup / Restore | Status |
|---|---|---|---|---|---|---|---|---|
| Task | `ae9bddcdb7ec` | `lib/models/task.dart` | `lib/services/task_store.dart`, `lib/services/g1_drift_schema.dart` | `lib/task_editor_dialog.dart`, Task detail | Home, Quick Capture, Reminder, Follow-up, Reports; Center relationship not connected | `test/task_store_test.dart`, `test/task_reminders_file_backed_sqlite_test.dart`, `test/task_store_completed_at_persistence_test.dart`, six Build shards PASS | Backup codec and independent restore tests exist; complete feature parity not accepted | PARTIAL |
| Center | `6d8bb22c519c` (model/store/test chain) | `lib/models/center.dart` | `lib/services/center_store.dart`, schema-v9 `centers` / `center_projects` | No canonical Center management page found | Center↔Project M2M Store exists; Task Editor, Quick Capture, Task projection, Home filter and Reports are not wired | `test/center_store_file_persistence_test.dart` covers file-backed CRUD, archive/restore, M2M, reopen, integrity/FK | No accepted Center backup parity | INTEGRATION INCOMPLETE |
| Project | `4b83508fe7e4`, `4456ce674f4e`; file persistence test `ea08c893ea5c` | `lib/models/goal_project.dart` | `lib/services/project_store.dart`; file-backed SQLite | `lib/projects_page.dart`, `lib/widgets/project_selector_field.dart` | ProjectStore still needs canonical Center and Project↔Category M2M integration; existing `project_items` lineage must be reconciled | `test/project_store_file_persistence_test.dart`, `test/project_store_test.dart`; COMMAND 20-E ProjectStore PASS | `lib/services/project_backup_bridge.dart`; full relation parity not accepted | INTEGRATION INCOMPLETE |
| Category | `9d455fae7ae6` (hierarchy v8→v9 migration) | No standalone canonical Category model found | Schema-v9 `project_categories`; no canonical CategoryStore found | `lib/widgets/task_category_field.dart`, taxonomy management surface | Task taxonomy services exist; Project↔Category canonical Store/UI/backup connection incomplete | `test/task_category_field_test.dart`, `test/task_taxonomy_lifecycle_service_test.dart`, `test/task_editor_category_project_integration_test.dart` | Relation backup parity not accepted | INTEGRATION INCOMPLETE |
| Tags | `6dac8d49e660`, test `e62b09514683` | Task tag value contract | `lib/services/tag_store.dart`, Task/Tag persistence | Taxonomy management and Task tag selector | Home OR-within-Tags filtering implemented; complete five-dimension Home combination still blocked by Center | `test/task_taxonomy_mutation_service_test.dart`, `test/home_filter_contract_test.dart`, `test/home_list_projection_test.dart` | Full Tag restore parity not accepted | PARTIAL |
| Person | `c94f96b08470`; directory implementation `60dfbb68e1d8` | `lib/models/person_reference.dart` | G1 Person data + exclusion migration `lib/services/g1_person_directory_exclusion_v1_migration.dart` | Person Directory page and CRUD flows exist | Task identity snapshots, Follow-up history and report filters are connected; broader REV10 relationship acceptance incomplete | `test/person_directory_page_test.dart`, `test/person_directory_exclusion_migration_test.dart`, Device Smoke People PASS on Attempt 2 | Portable backup/restore lifecycle test `100b09ac3319`; broader parity remains to validate | PARTIAL |
| Reminder | `22bef008dd5b`; test `a0cf6c028d4e` | Task Reminder embedded in Task model/envelope | Existing TaskStore + reminder persistence; no parallel store required | Reminder controls exist in current Task/notification surfaces; dedicated accepted four-action Activity/controller not found | Existing scheduler/notification foundations retained; Stop Bell, Follow-up, Snooze, Complete not accepted as four independent actions | `test/task_store_reminder_persistence_test.dart`, `test/task_reminders_file_backed_sqlite_test.dart`, reminder legacy compatibility tests | Unknown fields are preserved; complete Reminder backup/lifecycle parity incomplete | INTEGRATION INCOMPLETE |
| Follow-up | `ed93d6ad30bf`; write/history tests `a3a04599fddf`, `f4c64704e514` | `lib/models/follow_up.dart` | `lib/follow_up_repository.dart`, Follow-up write coordinator | Follow-up Entry and Office pages | Follow-up reminder projection is separate from historical Follow-up metadata; legacy reminderDate must not become an independent Calendar reminder | `test/follow_up_repository_file_persistence_test.dart`, `test/follow_up_canonical_lifecycle_test.dart`; File Persistence workflow PASS | Full migrated history and restore parity remain unaccepted | PARTIAL |
| Calendar | `a18af7c2b8aa`; restart fixture `de0278d5e4ba` | External Calendar event/link models | `lib/services/external_calendar_link_store.dart` (existing serialized store); current COMMAND 20-E proves persistence across process restart | `lib/calendar_page.dart`, Calendar settings | Reminder-only projection and provider bridge; eight independent links / 32 values compare after process restart | `integration_test/command20e_calendar_restart_fixture.dart`, `test/calendar_page_test.dart`; COMMAND 20-E PASS | Calendar link backup/restore parity is not yet fully accepted | COMPLETE / VALIDATION REQUIRED |
| Notes | `c2738c8d4dec` (note-conversion regression fix) | No separate first-class Notes model found | `lib/services/canonical_notebook_repository.dart` | `lib/notebook_page.dart` | Notebook↔Project membership exists; complete Notes identity and REV10 cross-entity integration not proven | `test/canonical_notebook_repository_test.dart`, `test/notebook_page_test.dart`, `test/notebook_project_membership_test.dart` | Complete Notebook/Notes backup parity not accepted | PARTIAL |
| Templates | No runtime template implementation commit located in current canonical tree | No current template model found | No current template store/service found | No template management UI found | Historical contracts/docs exist, but runtime entity is absent from canonical source inventory | No current template lifecycle acceptance test found | No template restore proof | NOT IMPLEMENTED |
| Deep Clone | No runtime implementation commit located in current canonical tree | No clone identity/domain service found | No clone persistence transaction found | No accepted Deep Clone UI found | REV10 clone identity, fresh IDs, relation copying and history isolation not wired | No current Deep Clone acceptance test found | No clone backup proof | NOT IMPLEMENTED |
| Quick Capture | `b67ff33dd14a` / `cfc4ae6a5edb` | Reuses Task domain model | `lib/services/quick_capture_service.dart` + TaskStore | Quick Capture dialog | Project/category/tag creation and save flow exist; Center selector and full Center relation are missing | `test/quick_capture_dialog_test.dart`, `test/quick_capture_service_test.dart`; Device Smoke Quick Capture PASS | Uses Task backup path; Center relation not present | PARTIAL |
| Home | `857f687107d5`; grouping correction `6cec47dfd65d` | Task and filter state | SQL-backed Home list/projection services | `lib/home/home_filter_ui.dart`, `lib/main.dart` | Five time groups exist and grouping-service duplicate was aligned; only four filter dimensions exist (Time, Project, Category, Tags), Center is absent | `test/home_filter_contract_test.dart`, `test/home_grouping_service_test.dart`, five-group and OR-tag tests; exact-SHA Build PASS | Filter state/backup behavior not fully accepted | PARTIAL |
| Backup / Restore | `054fcfb40407`; snapshot replacement `b0d68d4de496` | Backup snapshot and envelope codecs | `lib/backup_manager.dart`, `lib/backup_service.dart`, `lib/services/backup_service.dart` | Backup page and scheduling UI | Full project snapshot replacement and rollback paths exist; entity-by-entity Center/M2M/Template/Deep Clone parity remains incomplete | `test/independent_sqlite_backup_restore_test.dart`, `test/backup_service_test.dart`, `test/project_backup_portability_test.dart`; Build shards and Device Smoke backup-restore PASS | Independent A→B, second-backup and rollback test added; physical Android SAF and all REV10 entities still require validation | PARTIAL |
| Migration | `9d455fae7ae6` (current hierarchy migration); historical V19 forensic chain includes `5d5e63d9dbe9` | Current G1 schema + legacy codecs | `lib/services/g1_drift_schema.dart`, `g1_rev10_hierarchy_v9_migration.dart`, person exclusion migration | Migration surfaced through startup/upgrade flow | Current v8→v9 hierarchy step exists; complete Main v7→REV10 sequential ledger is not accepted. Historical V19 retry, explicit-NULL and unknown-field hazards remain unresolved | Migration tests and isolated historical fixture reports exist; COMMAND 50 forensic analysis identified the retry and parity hazards | Rollback/retry and full independent restore across every supported version remain unaccepted | BLOCKED |
| Reports | `5bc882bea115`; multi-select `33ed363eba1c`, test `614b207567b5` | Report filter/projection models | `lib/services/task_report_projection.dart`, report services | `lib/report_center_page.dart` | Person/waiting-response and taxonomy filters exist; Center-aware cross-Center aggregates are not wired/accepted | `test/report_center_page_test.dart`, `test/task_report_projection_test.dart`, report filter tests | Full report reproducibility after backup/restore not accepted | PARTIAL |

## 3. Recovered implementation and regression lineage
| Area | Creation / implementation | Corrective / regression test evidence | Current disposition |
|---|---|---|---|
| Center model + Store | `05426b9f2b6696a4018f2f4a251744c3ede18903` | `c033513de5bd0067a093c59303c4071acf42f564`, `8c2423f2401ea0b1afb76e750d58a93216ff0c9f`, `6d8bb22c519c80fd51d933a08ebf4e8bd3573898` | File-backed Store proof exists; UI/integration remains open |
| Project Store | `4b83508fe7e4064cbc6407cb5955713b7d44b279`, `4456ce674f4eeb63aeebb7fc174166b199f70f16` | `ea08c893ea5c` file-backed test; `77a2f5d8232d` removes only a redundant subset test after comprehensive coverage | Preserve implementation; finish M2M integration |
| Task Reminder deletion | `10e247e7ec1645eef0af065ae613e402560ff79c` | `7b2dcc3fd02e8752c115a56a573649c79ee8eefa` covers deletion across SQLite reopen | Historical resurfacing defect corrected |
| Person Directory removal | `7a6020de6d500b8ec21ae7f325db48e7b8708131` | `100b09ac331994d4796e4d3aa4a2cf64d2f416a4`, `c94f96b0847005c6e037503455a6c1bc7c2aec7b` | Explicit removals and portable restore covered; current Device Smoke People PASS |
| Home grouping | `6cec47dfd65d4755d7ffc68c1693e0cfeffcc901` | `857f687107d54e900d51d01617d200f47be9d8a6`, `8e81070c5845df0a7bbab59cf6c7034c6c90165c` | Earlier duplicate service mismatch corrected; five filters still incomplete |
| Task envelope / unknown fields | `4895bb17e990e083aa079e751d3ab3cc39be1414`, `0bd389fcf6017b539af1a26cb04a078f664aaf86`, `ae9bddcdb7ec8c2566e1a75affedc64427473ff5` | `b2e176a2c7568b07f44b79e33328ded78b92ad28`, `03001aba80a8eb073e2abf7cf8de470f854b57a7` | Current file-backed tests pass in exact-SHA Build shards |
| TaskReminder unknown fields | `22bef008dd5bcef3aa53f49b85b858a706b9a9ff` | `a0cf6c028d4e3de6d076d7bf2765ad9fba19335c` | Preserve and extend; do not replace the existing store |
| Backup restore stale snapshot | `b0d68d4de496a0346d373b53cb34c69a0af619dc` | `054fcfb40407c4fb4219eb3ed5183d9a87586329` adds independent A→B / second-backup / rollback coverage | Scoped test suite passes; owner/device acceptance remains |
| Calendar process restart | `de0278d5e4ba0c2fa1b077547f4db7fc06dc32eb` | `a18af7c2b8aa5fb002653624b850b9587d442dec`, `cd71c169019003e183e428e24353bb3ee487e042` | COMMAND 20-E proves 8 distinct links × 4 fields across independent processes |
| Historical V19 Occurrence migration | `398971f7ebb05eb51ed39caa58df10ca67c8b185` runner lineage | COMMAND 49 failure, COMMAND 50 forensic matrix and `5d5e63d9dbe95077a1e501e69576d299897cab11` | Forensic cause identified; retry/NULL/unknown-state acceptance remains BLOCKED; do not rewrite historical installer silently |

## 4. Exact-SHA CI and evidence checkpoint
Candidate: `e380ffd86c4157796cecd6a0d9c4a21716344d55`
- Build run `44880424925`: SUCCESS.
- Governance Validation run `44880424937`: SUCCESS.
- Device Smoke run `44880424928`, Attempt 2: SUCCESS. All seven scenario jobs passed, including People; the run's evidence file records `run_attempt: 2`.
- COMMAND 20-E run `44880424929`: SUCCESS. `storage-persistence` job `136797122098` and `complete-evidence` job `136797120649` succeeded.
- COMMAND 20-E latest artifact `14699814794`: `regression_summary.json` targets the exact candidate and reports `overall: PASS`; the linked Device Smoke Attempt 2 manifest shows People SUCCESS. Older artifact `14698614096` is stale Attempt 1 evidence with People CANCELLED / NO-GO and must not override the newer attempt.
- Follow-up File Persistence run `44880424931`: SUCCESS.
- No older-SHA result is inherited. These are the current candidate's runs only.

## 5. Zero Dollar Environment Smoke — separate disposition
- Run `44876935899` was executed on older SHA `6d8bb22c519c80fd51d933a08ebf4e8bd3573898`, not the current candidate.
- Java 17, Flutter 3.47.0 / Dart 3.13.0, Android API 35 image and emulator package installation succeeded.
- KVM was unavailable on the hosted runner; the workflow selected software acceleration (`-accel off`). KVM absence is not a product failure.
- Emulator boot did not start: the emulator log reports `Unknown AVD name [arvin-zero-dollar-api35]` and no matching AVD `.ini`; `adb wait-for-device` timed out with exit 124.
- Product Calendar smoke was not reached. Result: **ENVIRONMENT BLOCKED / PRODUCT NOT TESTED**, not a product regression.
- Root-cause hypothesis: AVD-manager and emulator user/AVD-home paths were not explicitly exported and verified as one shared path. Remediation is tracked by Issue #3654: export `ANDROID_USER_HOME` and `ANDROID_AVD_HOME`, capture `avdmanager create avd` output, assert the generated `.ini` and `config.ini`, then launch software-accelerated emulator and use bounded boot checks. This is an environment workflow correction, not a change to app architecture.

## 6. Grouped execution backlog
### Group A — preserve; no rebuild
- TaskStore identity/optional-field/unknown-field preservation.
- ProjectStore file-backed persistence and transactional safeguards.
- Center model/Store and its file-backed CRUD/M2M persistence slice.
- Person Directory identity snapshots and explicit-removal tombstone behavior.
- Reminder persistence and unknown-field preservation.
- Follow-up persistence/history foundations.
- Calendar-link independent-process persistence.
- Home five time groups and OR tag semantics.
- Existing backup snapshot replacement, A→B/rollback tests.
- Report Center existing filter/projection foundation.
Add regression protection only; do not recreate these entities.

### Group B — complete existing integrations
- Center → Task Editor, Quick Capture, Task projection, Home filter, Reports, backup/restore.
- Project ↔ Category canonical M2M Store/UI and relation-safe mutations.
- Person ↔ Task/Follow-up/report and backup lifecycle parity.
- Reminder four actions using the existing Reminder/Task/scheduler foundation.
- Home Center fifth filter; preserve five independent time groups and OR/AND semantics.
- Calendar/Follow-up/Reminder projection and backup relationship parity.
- Notes/Notebook integration with the canonical REV10 data model.

### Group C — genuinely missing runtime capability
- Template entity/store/service/management and reusable template lifecycle.
- Deep Clone semantics: fresh IDs, independent relationships, cleared execution history/checklist state according to REV10.
Only start after checking the Group A/B dependencies and exact REV10 contract.

## 7. Current blockers and acceptance boundary
1. Migration safety: full sequential Main v7→REV10 migration, historical lineage reconciliation, rollback/retry and full parity are not accepted.
2. Center end-to-end integration remains incomplete although its model/Store/test foundation exists.
3. Home has four filter dimensions, not the required five; Center is missing.
4. Reminder four-action Activity/controller and lifecycle acceptance remain blocked under Issue #3646.
5. Project↔Category M2M canonical Store/UI and backup integration remain incomplete.
6. Template and Deep Clone runtime implementations are not present in the current tree.
7. Zero Dollar emulator provisioning requires Issue #3654 remediation; KVM remains optional.
8. Main ruleset does not require an approving review, CODEOWNERS approval, thread resolution or CI checks; canonical branch protection is not configured. Ruleset 20952260 applies only to Main.
9. Merge, release, deployment and production-data migration remain owner-gated.

## 8. Audit limitations / next historical pass
This matrix records the current canonical source inventory, the latest identified implementation/test/fix commits for all 17 required entities, the recovered migration evidence and the exact current-SHA acceptance results. It does **not** claim that every historical side-branch/PR commit has been individually replayed or that every deleted/closed PR has been audited in this matrix. The repository compare confirms 434 commits ahead of Main; the canonical ancestry contains additional shared history. Continue the unique-commit/branch/PR provenance audit through the existing governance inventory without deleting or rebuilding completed work.
