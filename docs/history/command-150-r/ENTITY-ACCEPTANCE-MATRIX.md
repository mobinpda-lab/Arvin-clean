# ENTITY ACCEPTANCE MATRIX — ARVIN REV10 / MASTER EXECUTION 150-R

**Repository:** `mobinpda-lab/Arvin-clean`  
**PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Canonical branch:** `recovery-02/main-based-integration`  
**Source audit SHA:** `ac52f706a6b785a2b194a46bc97866d48c54b5e5`  
**Main baseline:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Decision authority:** REV10 and approved 2026-11-14 Center–Project / Project–Category M2M ADR

> This matrix distinguishes source implementation from product acceptance. A model, SQL table, passing isolated test or successful APK does not make an entity COMPLETE. All statuses below are based on the inspected canonical source at the Source audit SHA. Exact-SHA CI after the report commit remains independently required.

## Status legend

- **COMPLETE** — every applicable REV10 requirement and acceptance evidence is present.
- **IMPLEMENTED** — implementation is present, but complete acceptance is not established.
- **PARTIAL** — a material part of the entity or its product path is missing.
- **BLOCKED** — a concrete technical dependency prevents progress.
- **NOT IMPLEMENTED** — no current runtime implementation was found.
- **NOT VERIFIED** — source/evidence is insufficient to determine the implementation.
- **NOT ACCEPTED** — implementation exists but the required acceptance gate has not passed.

## Primary entities

| Entity | Model / serialization | SQLite / schema | Store / operations | Relations | UI / consumers | Persistence / backup | Tests / exact evidence | Status |
|---|---|---|---|---|---|---|---|---|
| Task | `lib/models/task.dart`; known keys, explicit NULL presence and extensionData | `tasks`, `follow_ups`, `checklist_items`, `task_tags`, `task_people`; optional `center_id`, `project_id`, `category_id` added by v9 migration | `lib/services/task_store.dart`: load/save/mutate, relations, reminders, Follow-ups, tags and people | Center/Project/Category optional direct links; Tags/People M2M; Follow-up 1:N; Reminder embedded; Notebook classification | Task Editor, Task Detail, Quick Capture, Home | File-backed Task/Reminder/Follow-up tests; Task JSON included in portable backup | `test/task_center_relation_persistence_test.dart`, `test/task_reminders_file_backed_sqlite_test.dart`, `test/task_store_followup_test.dart`; Build 149-R blocked by V8 fingerprint | **PARTIAL** |
| Project | `lib/models/goal_project.dart` ProjectPlan; `ProjectPlanCodec`; unknown legacyFields | `projects`, `project_items`, `legacy_center_id` | `lib/services/project_store.dart`: load, additive upsert, explicit delete, archive state, membership | Center M2M not read/written by ProjectStore; Project↔Category API absent; Project↔Task legacy membership plus direct Task.projectId | Projects page/launcher, selector, Quick Capture, Notebook and backup bridge | File-backed SQLite; portable backup carries Projects and legacyCenterId, not Center M2M or ProjectCategory edges | `test/project_store_file_persistence_test.dart`, `test/project_backup_portability_test.dart`, `test/independent_sqlite_backup_restore_test.dart`; 149-R ProjectStore evidence PASS | **PARTIAL** |
| Center | `lib/models/center.dart` | `centers`, `center_projects`; direct Task FK `tasks.center_id` | `lib/services/center_store.dart`: create/load/find/search/rename/archive/restore/delete-safe/link/unlink/replaceProjectLinks/bidirectional lookup | Center↔Project M2M store operations; Task direct optional Center FK | Dedicated Center management page implemented in lib/center_management_page.dart with Settings entry; no Center selector in Task Editor or Quick Capture; no Home Center filter | Center and CenterProject are not in canonical portable backup payload | `test/center_store_file_persistence_test.dart` now verifies active/archived search, trimmed query, no-match and stable ordering; transactional scoped replacement/rollback regression added in 154-R; `test/task_center_relation_persistence_test.dart`; 154-R exact-SHA Build pending | **PARTIAL** |
| Category | No canonical Category domain model/store found; Task retains legacy string plus optional categoryId | Both `taxonomy_categories` (legacy string catalog) and `categories` / `project_categories` (v9 canonical tables) | TaskStore CRUD/rename/delete operates on `taxonomy_categories`; no canonical ProjectCategory store/API | Project↔Category join table exists but no product relationship management; Task.categoryId FK exists | Legacy category selector/filter; no canonical Category entity management path proven | Task and legacy category strings are backed up; canonical Category catalog and ProjectCategory edges are not | Migration tests cover legacy Category identity transfer and unresolved Project–Category exceptions; no full M2M acceptance test | **PARTIAL** |
| Tags | Task tag values are serialized in Task; no standalone Tag domain model found | `tags`, `task_tags` | TaskStore load/create/rename/delete/merge catalog and Task relation persistence | Task↔Tag M2M | Home Tags filter, Task Editor and existing taxonomy surfaces | Task tags and tag catalog included in portable backup | Existing TaskStore, editor and backup tests; no complete standalone Tag acceptance certificate on final SHA | **IMPLEMENTED** |
| People | `lib/models/person_reference.dart`; stable ID + displayName; TaskPersonContext | `people`, `task_people`, `follow_up_people`; directory-exclusion migration table | TaskStore directory load/save/merge; relation snapshots remain with Task/Follow-up | Task↔People M2M; Follow-up↔People M2M | Person Directory page, Task People UI, Follow-up consumers | Directory and Task/Follow-up references included in backup; PersonReference does not expose a general unknown-field extension map | `test/person_directory_page_test.dart`, `test/person_reference_contract_test.dart`, `test/person_directory_exclusion_migration_test.dart`; Device Smoke People passed on 149-R SHA only | **IMPLEMENTED** |
| Reminder | `TaskReminder` in `lib/models/task.dart`; extensionData | Reminder collection is stored in Task envelope/legacy payload; no independent canonical reminders table | TaskStore serializes TaskReminder collection; Android scheduler/notification services exist | Task 1:N embedded Reminder records; Calendar links keyed by reminder identity | Task Editor and notification/scheduler surfaces; required four-action floating window not present/accepted | Task backup carries reminders and unknown Reminder fields; file-backed persistence tests exist | `test/task_reminders_file_backed_sqlite_test.dart`, `test/task_store_reminder_persistence_test.dart`; four-action issue #3646 remains OPEN | **PARTIAL** |
| Follow-up | `FollowUp` in Task model; extensionData preserves unknown JSON fields | `follow_ups`, `follow_up_people`; Task FK and ordinal uniqueness | TaskStore reads/writes Follow-ups transactionally with Task data | Task 1:N Follow-up; Follow-up↔People M2M | Follow-up entry/detail, Task Detail, timeline and reminder consumers | Task/Follow-up payload travels through portable Task backup | `test/follow_up_repository_file_persistence_test.dart`, `test/follow_up_canonical_lifecycle_test.dart`; Run 44930273121 PASS on 149-R SHA | **IMPLEMENTED** |
| Calendar / Calendar Links | ExternalCalendarEventLink model and Calendar projections | Provider-link metadata remains in SharedPreferences JSON, not canonical SQLite | `ExternalCalendarLinkStore`, inbound/outbound sync services and provider executor | Reminder ↔ external provider event link; provider identity and fingerprint guard writes | Calendar page, event sync, navigation and reschedule flows | Backup manager includes Calendar links; process-restart proof exists | Run 44930273117 Device Smoke PASS and Run 44930273200 Calendar restart evidence PASS on 149-R SHA; final SHA pending | **PARTIAL** |
| Notebook | Reuses Task model with `notebookKind`; no duplicate Note entity | Same canonical `tasks` table and checklist rows | `CanonicalNotebookRepository` delegates to TaskStore and Project assignment service | Notebook item is a Task classification; Project membership uses canonical Project path | Notebook page, note/checklist create/edit/restore, category/tag/project consumers | Included as Task records in portable backup | `test/canonical_notebook_repository_test.dart`, `test/notebook_page_test.dart`, `test/notebook_project_membership_test.dart` | **IMPLEMENTED** |
| Templates | No current runtime Template model/store found | Historical v8 fixture has `project_templates`; current v9 installer does not provide a verified runtime template catalog | No current Template store/API found | Legacy Project.template_id is historical payload only; no verified current Project↔Template path | No verified runtime Template management page | Historical fixture DDL is not a backup/restore implementation | Historical V8 fixture test verifies source table shape only; no runtime Template acceptance test | **NOT IMPLEMENTED** |
| Template Tasks | No current runtime TemplateTask model/store found | Historical v8 fixture has `project_template_tasks`; not in current canonical v9 base schema | No current CRUD/read/write path found | Historical FK TemplateTask→Template | No verified runtime Template Task UI | No current portable restore path verified | Historical fixture structural test only | **NOT IMPLEMENTED** |
| Template Applications | No current runtime application model/store found | Historical v8 fixture has `template_task_applications`; not in current canonical v9 base schema | No current application writer/reader found | Historical join table between Template Task, Project and Task | No verified application UI | No current portable restore path verified | Historical fixture structural test only | **NOT IMPLEMENTED** |
| Reports | Report projections/adapters/renderers; no single Report domain entity | Read projections over Task/Project data; no Center report relation | Report services and renderers; mostly query/projection responsibilities | Project/Center report association not complete; Center query path absent | Report Center, Task report, PDF/text and specialized reports | Task/Project data is sourced from canonical stores; full cross-Center backup/report parity not accepted | `test/report_center_page_test.dart`, report projection/PDF tests; no full REV10 report acceptance | **PARTIAL** |
| Migration Exceptions | No standalone domain model/reader found | `arvin_migration_exceptions` with unique migration/entity/code key and JSON details | v8→v9 migration writes ledger transactionally; no full exception management Store | Polymorphic entity_type/entity_id reference to historical records | No verified exception review/recovery UI | Exception ledger not included in portable backup payload | `test/services/g1_rev10_hierarchy_v9_file_migration_test.dart` covers exception insert, rollback, retry and FK checks; exact-SHA Build pending | **PARTIAL** |

## Additional schema-backed supporting entities

| Supporting entity | Source / storage | Implementation | Acceptance status | Status |
|---|---|---|---|---|
| Checklist Items | Task.checklist, `checklist_items`, TaskStore | Persisted with Task; editor and recurring checklist state exist | File-backed Task coverage and model tests exist; full product acceptance not complete | **IMPLEMENTED** |
| Recurrence | `RecurrenceRule`, Task.recurrence / recurrence_json, recurrence repository | Canonical Task-owned recurrence state and projection | Dedicated recurrence/persistence tests exist; complete REV10 acceptance not established | **IMPLEMENTED** |
| Person Directory Exclusion | `person_directory_exclusions`, versioned migration | Explicit directory removals survive legacy Person hydration | `test/person_directory_exclusion_migration_test.dart` | **IMPLEMENTED** |
| Storage Metadata | `arvin_storage_meta` | Migration completion markers and idempotent cutover boundary | Covered by schema/migration tests; not a user-facing entity | **IMPLEMENTED** |

## Acceptance summary

- **COMPLETE:** none.
- **IMPLEMENTED, but not accepted as complete:** Tags, People, Follow-up, Notebook, Checklist Items, Recurrence, Person Directory Exclusion, Storage Metadata.
- **PARTIAL:** Task, Project, Center, Category, Reminder, Calendar / Calendar Links, Reports, Migration Exceptions.
- **BLOCKED:** no separate hard technical blocker was established beyond the concrete missing product/store paths listed above; those are classified PARTIAL rather than overstated as BLOCKED.
- **NOT IMPLEMENTED:** Templates, Template Tasks, Template Applications.
- **NOT VERIFIED:** no primary entity is marked NOT VERIFIED where direct source inspection established either presence or absence. Unproven acceptance claims remain NOT ACCEPTED.
- **Progress percentage:** deliberately not calculated. REV10 requirement weights and full exact-SHA evidence coverage are not yet defined.


## 150-R post-audit implementation delta

- Added `CenterStore.search(query, includeArchived: false)` over the canonical Center table. It trims and case-folds the query, reuses the store's name/id ordering, excludes archived Centers by default, and permits explicit archived inclusion.
- Extended the existing file-backed Center CRUD/M2M/restart test to verify search results for active and archived Centers, whitespace trimming, no-match behavior and ordering.
- This closes the Store-level search gap only. It does not claim a Center management UI, Task Editor/Quick Capture/Home integration or backup acceptance.


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

## MASTER EXECUTION 152-R — exact-SHA evidence refresh (2026-11-22)
- Candidate `9d8dc6cd4474818e03cc1c5a7deed4dcb3d9a974` was validated by Build `44979607579`, Device Smoke `44979607528`, Follow-up Persistence `44979607500`, Governance `44979607509` and COMMAND 20-E `44979607577`; all completed SUCCESS on the same SHA.
- Calendar lane `137077040499` passed; the target Task and both independent Reminder records appeared in the selected-day projection and the edit/persistence flow passed.
- COMMAND 20-E final artifact `14736794580` reports `overall: PASS`; exact target/checkout SHA matched. This closes the prior 150-R CI evidence blocker only; it does not accept the remaining REV10 product gaps.
- Five executable source/test blobs compared between `3c72a341` and `9d8dc6cd` are byte-identical. The prior Calendar failure was not reproduced; no source correction is claimed and the historical root cause remains NOT VERIFIED.
- Entity status remains separate from CI: Center UI, Center Task selectors, Home five-filter data path, Project↔Category store/UI, full Backup/Restore matrix and Reminder four-operation acceptance remain NOT ACCEPTED.


## MASTER EXECUTION 153-R — source revalidation (2026-11-22)
**Audited source Candidate:** `6fb78dee3d236385df8045149f8c929df076ae78` (PR #3495 canonical branch).

| Entity / capability | Implementation | Tested on 153-R Candidate | Product acceptance |
|---|---|---|---|
| Center model | EXISTING — reused `lib/models/center.dart` | Existing store persistence test; 153-R UI tests are pending exact-SHA Build | NOT ACCEPTED |
| CenterStore | EXISTING — reused `lib/services/center_store.dart`; no duplicate store/table | Existing file-backed test exists; 153-R UI suite pending | NOT ACCEPTED as full entity |
| Center Management UI | IMPLEMENTED — new independent page, CRUD name, search, sort, archive/restore, empty/loading/error states, details and Settings entry | Widget tests added; Build/Analyze still running when recorded | NOT YET TESTED / NOT ACCEPTED |
| Center↔Project | Existing transactional M2M API reused; Center page displays linked Projects and supports per-Center relationship editing | Store persistence test exists; new UI relationship test pending | NOT ACCEPTED — portable backup parity missing |
| Center↔Task | Optional FK and TaskStore persistence exist | Existing file-backed relation test | PARTIAL — Task Editor, Details and Quick Capture UI absent |
| Home five filters | Four existing dimensions only: Time, Project, Category, Tags | Existing four-dimension source; no fifth-dimension regression | NOT IMPLEMENTED / NOT ACCEPTED |
| Project↔Category | Schema-v9 join table exists | No canonical relationship Store/UI acceptance evidence | PARTIAL / NOT ACCEPTED |
| Calendar | Existing source retained; no rewrite | Candidate afad663 Device Smoke Calendar job passed; current 6fb Device Smoke is in progress | PARTIAL — no full product acceptance |
| Reminder four actions | Existing reminder/follow-up foundations retained | No new exact-SHA four-action acceptance | PARTIAL / NOT ACCEPTED |

### Source-contract boundary
- Current Center model exposes ID, name, created/updated timestamps and archive status only. Description/color are not represented by the existing model/store contract; no temporary fields or Schema changes were introduced.
- Center↔Project editing calls the existing `replaceProjectLinks` API for one Center only; it does not replace relationships belonging to other Centers.
- No Task persistence, Schema, migration, Backup/Restore or protected query contract was modified.
- Lane A remains BLOCKED / NOT ACCEPTED. Historical v8 SQL DDL fixture is not a full historical data fixture; v8→v9 migration, explicit NULL/unknown metadata parity, complete rollback/retry and independent SQLite A→B restore are not all accepted.

### Exact-SHA CI observation
For 153-R source Candidate `6fb78dee3d236385df8045149f8c929df076ae78` at the time of this amendment:
- Governance run `44985238078`: SUCCESS.
- Follow-up File Persistence run `44985238063`: SUCCESS.
- Build run `44985238060`: IN PROGRESS (Analyze/Test Shards 0–5/Debug+Release APK not yet complete).
- Device Smoke run `44985238066`: IN PROGRESS (Home and Quick Capture running; remaining scenarios queued).
- COMMAND 20-E run `44985238070`: IN PROGRESS.
No pending result is represented as PASS. Recheck exact SHA after all workflows finish.

### Delivery state
PR #3495 remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. No merge, release, deployment or destructive migration is authorized.


## MASTER EXECUTION 154-R — Center management and transactional regression addendum (2026-11-22)

- Canonical Center model, CenterStore and SQLite schema were reused; no duplicate entity/store/table was created.
- Dedicated Center Management UI is IMPLEMENTED in lib/center_management_page.dart with Settings integration, search, sort, archive/restore, details and Center↔Project editing.
- Task Editor, Task Details and Quick Capture still have no Center user-facing integration.
- Task Editor reconstructs Task without passing existing centerId; editing a Center-assigned Task can drop that relationship. Track as P0 defect and preserve omitted-vs-explicit-NULL semantics in remediation.
- Home remains four filter dimensions; Center is absent from Home selection state and SQL-backed projection. Five time groups remain implemented in the canonical Home route.
- Commit e9573107b1194f1e0b978f2254d456674f3db22f adds file-backed tests for Center-scoped Project replacement, unrelated Center-edge preservation, FK failure rollback and close/reopen integrity. The exact-SHA Build was still pending at the recorded checkpoint.
- Center remains PARTIAL / NOT ACCEPTED as a complete REV10 entity; portable Backup/Restore parity and Task/Home integration are not accepted.


## MASTER EXECUTION 155-R — live acceptance addendum (2026-11-22)

**Code Candidate:** `5c567e8370dacfced5bb218c51897f2cad7b912a`  
**Starting Candidate:** `4bb1860f29403be4d1fd7e8d7aebd8a3026c6dc8`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**PR:** #3495 OPEN / unmerged; Release NO-GO.

- Task Editor save now carries forward existing `centerId`, `projectId`, `categoryId` and `extensionData` (commit `aaefe268994c6c73ebc8d50aafec321801f66809`). Regression tests cover existing links, unknown metadata, explicit NULL and absent fields (commit `5c567e8370dacfced5bb218c51897f2cad7b912a`). This closes the source-level loss-on-unrelated-edit defect only; Center selection/change/clear UI and exact-SHA acceptance remain pending.
- Center Management widget test helper now waits for the page's post-mount SQLite load and relationship reads before asserting (commit `3e00daa78b4db23bd245798b8898c7c7ee482d5f`). Original assertions are retained.
- Exact Candidate CI: Build `44989444175` IN PROGRESS; Device Smoke `44989444131` queued/in progress; Governance `44989444105` SUCCESS; Follow-up Persistence `44989444082` SUCCESS; COMMAND 20-E `44989444099` IN PROGRESS. No PASS is claimed for pending workflows.
- Prior Candidate `4bb1860f` Build `44986909172` failed in Shard 0 at `center_management_page_test.dart:54` (expected one “مرکز الف”, found zero); Shards 1–5, Analyze, Debug/Release APK and Device Smoke 7/7 passed. COMMAND 20-E artifact `14739764622` is overall NO-GO solely because Build Shard 0 failed.
- Task, Project, Center, Category, Tags, People, Reminder, Follow-up, Calendar, Home, Notebook, Templates, Reports, Backup/Restore and Migration remain individually unaccepted as complete. See the 155-R mission report for the implementation/testing/acceptance matrix.
- Lane A remains BLOCKED / NOT ACCEPTED. No Schema/Migration change or real user database operation occurred.
