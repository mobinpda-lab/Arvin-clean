# REV10 WAVE 1 — Migration Inventory (M0 Read-Only)

**Date:** 2026-11-13  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Execution branch:** `feature/command-07-a-sqlite-contract-remediation`  
**Inspected branch HEAD:** `34f6fb1a42e5adb6255a1d56ce8c07ac7567ead2`  
**PR:** #3384 (OPEN / DRAFT / UNMERGED)  
**Main HEAD:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**G1 schema:** version 19  
**Mode:** READ-ONLY SOURCE INVENTORY; no user database was opened or changed.

> This report separates source-code facts from installed-user data. Source consumers can be enumerated from GitHub; real row counts and record IDs cannot be truthfully reported without a read-only copy of the actual SQLite database. Those values are therefore explicitly UNKNOWN, not zero.

## 1. Executive result

| Area | Source finding | Status |
|---|---|---|
| G1 schema | v19; additive/idempotent SQL installer, not a sequential Drift MigrationStrategy ledger | RED |
| Center | `centers` table and `CenterStore` exist | YELLOW |
| Project ownership | `projects.center_id` is nullable; no mandatory owner constraint | RED |
| Category ownership | Global `taxonomy_categories(name)`; no stable Category ID or Project owner | RED |
| Task → Center | `Task.centerId` is serialized in the legacy payload envelope, not a SQL FK column | RED |
| Task → Project | `project_items` is many-to-many; a Task can have multiple Projects | RED |
| Task → Category | Legacy nullable text `tasks.category`; no canonical Category FK | RED |
| Tag | SQL `tags` + `task_tags`; TagStore is a compatibility facade | YELLOW |
| Person | SQL `persons`, `person_directory`, `task_persons`, `follow_up_record_people` | YELLOW |
| Entity Management | Center management exists; unified five-entity management and Category/Person stores are not established | RED |
| Production data inventory | No production SQLite file available in this audit | GRAY / UNKNOWN |
| Destructive migration | Not run | GREEN — safety boundary respected |

## 2. Exact source baseline and blob identities

| Source | Blob SHA | Relevant evidence |
|---|---|---|
| `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | v19; tables and installer |
| `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` | Task.centerId and legacy JSON serialization |
| `lib/services/task_store.dart` | `1ecf9ca2368a8f72c86b277a6709cf389a8c9553` | Task, category, tag and Person SQL operations |
| `lib/services/project_store.dart` | `5197479665880e5f3ee2250ee733f4f451749090` | Project and project_items reader/writer |
| `lib/services/tag_store.dart` | `a7409383bf54d3b714a33e4322ac8e00ae8f82dc` | TaskStore compatibility facade |
| `lib/services/center_store.dart` | `91b13c2de013ddd29148bed8e819c77c2c4eb69c` | Center CRUD/archive/delete |
| `lib/services/task_taxonomy_mutation_service.dart` | `62246ad7e55819623c8b903caf3ffbe9a8bf183e` | Category/Tag domain mutation and delete protection |
| `lib/services/task_taxonomy_lifecycle_service.dart` | `cddfbe3c0d41ee3c32f4eaafa402c3d3b82cad79` | In-memory Category/Tag lifecycle validation |
| `lib/services/sql_project_migration_writer.dart` | `06744ad0220f9bd901d3fbe1a71f7ee8add4eca9` | Legacy Project preferences → SQL |
| `lib/services/sql_task_migration_writer.dart` | `5cc43f1e200a975838792c9762546266dc97991f` | Legacy Task preferences → SQL |
| `docs/architecture/COMMAND_07_A2_45_CANONICAL_SCHEMA_MIGRATION_DESIGN.md` | `502d0dc752e2183d2df07a96cf1741d31bec818d` | Migration phases, target schema and ownership proposal |

All rows above refer to the inspected execution branch. They do not imply production-data counts.

## 3. Consumer inventory

### 3.1 `project_items`

Confirmed production readers/writers:

1. `lib/services/project_store.dart`
   - `load()` reads Task IDs per Project.
   - `save()` deletes and rebuilds `project_items` and Projects transactionally.
   - `_insertProject()` writes each Project membership.
2. `lib/services/task_store.dart`
   - `_saveUnlocked()` snapshots all `project_items` rows before replacing Task rows.
   - It deletes and restores those memberships to satisfy Task foreign keys.
3. `lib/services/sql_project_migration_writer.dart`
   - Imports legacy Project `itemIds` into `project_items`.
   - Validates membership order and payload parity.

Schema and test consumers:

- `lib/services/g1_drift_schema.dart` creates the relation with primary key `(project_id, task_id)`; this prevents duplicate membership in one Project but does not enforce one Project per Task.
- `test/services/sql_project_migration_writer_test.dart`
- `test/services/g1_drift_schema_test.dart`

**Disposition:** retain the table and all rows until every Project/Task/template/filter/report consumer has moved to the canonical optional Task FK and parity has been proven. Never select one Project automatically when a Task has multiple memberships.

### 3.2 Task Center

- `Task.centerId` is a model field.
- `Task.toJson()` serializes non-empty `centerId` into the Task payload.
- `Task.fromJson()` restores it.
- `TaskStore` reads the payload envelope in `_decodeTask()`; the SQL `tasks` table has no `center_id` column in v19.
- Project ownership is separately represented by nullable `projects.center_id`.
- `CenterStore` reads/writes the `centers` table.

**Risk:** Task's direct Center and Project membership can disagree because they are stored independently and no production SQL cross-parent trigger validates them. Full call-site closure for all Home, editor, filter, calendar and report consumers remains an active sub-inventory; the production schema fact is already conclusive.

### 3.3 Category and `taxonomy_categories`

Confirmed production usage:

- `G1DriftSchema` creates `taxonomy_categories(name PRIMARY KEY, created_at)`.
- `TaskStore.loadCategories()` reads the global catalog.
- `TaskStore.createCategory()`, `mergeCatalogs()`, `renameCategoryCatalog()`, `deleteCategoryCatalog()` mutate it.
- `TaskStore._seedCategoryCatalog()` seeds names from `tasks.category`.
- `TaskStore._saveUnlocked()` keeps Task category names in the global catalog.
- `TaskStore` checks Task and Template references before Category deletion.
- `TaskTaxonomyMutationService`, `TaskTaxonomyLifecycleService` and `TaskTaxonomyManagementPage` provide additional domain/UI paths.
- Template tables also carry Category text (`task_templates.category`, `project_template_tasks.category`).

**Risk:** a global name cannot identify the owning Project. Equal names in different Projects cannot safely be collapsed into one Category identity. Category rows with no Project owner are structural legacy records, not automatically orphaned records.

### 3.4 Project lifecycle

- `ProjectStore.load/save/clear` is the canonical SQL Project boundary.
- `ProjectStore.save()` is a transactional full collection rewrite; it preserves Project legacy payload fields and template application rows.
- `ProjectStore` reads legacy `arvin.projects` only through `SqlProjectMigrationWriter` when the migration marker is absent.
- Project archive state is stored in `projects.is_archived`.
- Project Center is currently nullable.
- Template application and template Project services also reference Projects.

**Required inventory extension:** enumerate every UI/service call site for create, rename, archive, restore, delete, reorder and Center reassignment before changing Project mutation APIs. Do not infer that a UI archive action is equivalent to permanent deletion.

### 3.5 Tag ownership

- SQL tables: `tags` and `task_tags`.
- `TaskStore` owns Tag catalog reads, creation, rename, dependency counts and deletion.
- `TaskStore._writeRelations()` writes Task–Tag relations.
- `TagStore` delegates to TaskStore and does not write SharedPreferences.
- `TaskStore._migrateLegacyTagCatalog()` reads legacy key `arvin.tags` once, inserts SQL Tags and writes the SQL migration marker `legacy_tags_migrated` in one transaction.
- The old SharedPreferences value is deliberately retained as recovery evidence; it is not the active Tag writer.
- Template Tag references are separately counted before deletion.

**Disposition:** keep TagStore as a compatibility facade until all call sites are migrated. Do not delete Tags with Task or Template references. Check duplicate names/IDs and orphan `task_tags` records in the real database.

### 3.6 Person and Follow-up

Confirmed SQL ownership:

- `persons(id, name, created_at, updated_at)`
- `person_directory(person_id)`
- `task_persons(task_id, person_id, ordinal)`
- `follow_up_record_people(follow_up_id, person_id, ordinal)`

Current service boundaries:

- `TaskStore` owns active Person directory load/save/merge and Task Person relation writes.
- `TaskPeopleService` delegates Task-facing Person changes through TaskStore.
- `FollowUp` stores stable Person IDs; Follow-up relations are written by TaskStore/migration code.
- `PersonReference` is the application identity/display model.
- Backup manager carries Person directory and Task records in its portable backup payload.

**Risk:** the active directory and historical relations are different concepts. Removing a Person from the active directory must not delete the Person row or Task/Follow-up history. The migration code can seed a Person row with an empty display name when a Follow-up relation contains only an ID; these rows need classification and must not be silently renamed or removed.

**Ownership gap:** a dedicated `PersonStore` is not established in this inspected source. Person SQL ownership currently sits inside TaskStore.

### 3.7 Parallel taxonomy services

- `TaskTaxonomyMutationService` contains mutation/domain operations and dependency-aware deletion behavior.
- `TaskTaxonomyLifecycleService` separately derives names, counts references, validates deletion and mutates in-memory Task collections.
- Both operate on overlapping Category/Tag concerns, but neither is the canonical SQL repository.
- `TaskStore` already has SQL-aware rename/delete/catalog operations.

**Disposition:** overlap is confirmed. Do not delete either service yet. Build a method-by-method consumer map, move persistence to one canonical mutation boundary, retain pure validation only where it has distinct callers, and then deprecate the compatibility surface.

## 4. Schema and migration inventory

- `G1DriftSchema.version = 19`.
- The installer uses `ensureOpen`, idempotent `CREATE TABLE IF NOT EXISTS` and conditional `ALTER TABLE ADD COLUMN`.
- It does not currently expose a sequential Drift `MigrationStrategy` ledger matching the requested versioned migration model.
- The installer temporarily runs `PRAGMA foreign_keys = OFF`, opens a transaction, performs schema/data maintenance, checks foreign-key violations and re-enables foreign keys.
- Existing SQL relations include Task reminders, Follow-ups, Persons, Centers, Projects, Project memberships, Tags, Task-Tags, checklist, recurrence and occurrence history.
- Project and Task legacy writers read `arvin.projects` and `arvin.tasks` from SharedPreferences when their SQL migration markers are absent.
- Tag legacy migration reads `arvin.tags` and commits a one-time marker.
- These legacy preferences are migration inputs; the inspected TagStore itself is a SQL facade.

**Risk:** schema installation, one-way legacy migration and regular CRUD are distinct paths. They must not be conflated into one migration acceptance result.

## 5. Backup and Restore inventory

- `ArvinBackupManager` coordinates Task, Project, Category, Tag, Person, settings and calendar-link backup data.
- `ArvinBackupService` produces a portable JSON document (optionally encrypted) and writes it through Android SAF; optional cloud transport is separate.
- Restore has a multi-stage rollback wrapper that captures a recovery backup and invokes rollback if a later stage fails.
- Project and Task stores are applied through their canonical stores during backup/restore orchestration.
- Existing tests include canonical backup manager, project backup bridge, SQLite backup/restore file tests and Android backup/restore smoke coverage.

**Acceptance distinction:** portable JSON backup/restore is not, by itself, proof of a physical SQLite database backup. D04 still requires a real SQLite file backup, restore into a different file, close/reopen, integrity check, foreign-key check and parity.

## 6. Legacy record classification matrix

The following are the required row-level classifications. Counts and IDs are UNKNOWN until M0 runs against an actual database copy.

| Legacy condition | Classification | Safe recommendation |
|---|---|---|
| Project has NULL or unknown `center_id` | NEEDS_OWNER_DECISION / ORPHANED if non-NULL target missing | Preserve Project ID and payload; do not assign a Center by name or guess |
| Task has zero `project_items` memberships | VALID / LEGACY | Keep Task independent; canonical `project_id = NULL` |
| Task has one valid Project membership | VALID if all other evidence agrees | Candidate for exact mapping; preserve source relation until parity |
| Task has multiple Project memberships | AMBIGUOUS | Preserve all source memberships; do not choose one |
| Category catalog row has no Project owner | LEGACY | Preserve name and references; owner mapping requires unique evidence |
| Task Category text is NULL/blank | VALID optional relation | Canonical `category_id = NULL`; no exception solely for absence |
| Task Category text maps to more than one possible Project | AMBIGUOUS | Preserve text and record candidates; no automatic parent |
| Task legacy Center conflicts with its Project's Center | AMBIGUOUS | Preserve both source values and all IDs; owner resolution required |
| Task has invalid Project/Category/Center reference | ORPHANED | Preserve source payload and relation evidence; repair only with explicit mapping |
| Duplicate Project/Task membership or duplicate stable IDs | DUPLICATE | Record every source key and payload; no silent deduplication |
| Tag relation references missing Tag/Task | ORPHANED | Preserve relation evidence; do not cascade-delete |
| Duplicate Tag names or generated ID collisions | DUPLICATE / NEEDS_OWNER_DECISION | Preserve IDs and names; apply an explicit merge policy only after review |
| Person relation has no corresponding Person row | ORPHANED / LEGACY | Preserve relation; reconstruct only from authoritative source identity |
| Person exists only in historical Follow-up relation | LEGACY | Keep Person and history; do not remove because absent from active directory |
| Person row has blank display name | NEEDS_OWNER_DECISION | Preserve stable ID and source links; do not fabricate a display name |
| Record has no stable ID or malformed payload | NEEDS_OWNER_DECISION | Preserve raw bytes/payload and source position/hash; no generated replacement ID during inventory |

## 7. Counts, record IDs and evidence availability

| Metric | Result |
|---|---|
| Schema version | 19 |
| Confirmed production `project_items` consumer files | 3 |
| Confirmed `project_items` test/schema files | 2 |
| Confirmed Category/Tag service layers | TaskStore + TagStore facade + two taxonomy domain/lifecycle services |
| Confirmed CenterStore | 1 |
| Confirmed dedicated CategoryStore | Not found |
| Confirmed dedicated PersonStore | Not found |
| Actual Center row count / IDs | UNKNOWN — no user DB supplied |
| Actual Project row count / IDs | UNKNOWN — no user DB supplied |
| Actual Task row count / IDs | UNKNOWN — no user DB supplied |
| Actual Category row count / IDs | UNKNOWN — no user DB supplied |
| Actual `project_items` row count / duplicate IDs | UNKNOWN — no user DB supplied |
| Actual Tag / Task-Tag counts and orphans | UNKNOWN — no user DB supplied |
| Actual Person / Task-Person / Follow-up-Person counts | UNKNOWN — no user DB supplied |
| Actual malformed/duplicate/orphan records | UNKNOWN — no user DB supplied |

The three confirmed production `project_items` consumer files are ProjectStore, TaskStore and SqlProjectMigrationWriter. The two additional confirmed files are the schema and its migration/schema tests. These are source-file counts, not counts of individual SQL call sites or stored rows.

## 8. Read-only database inventory still required

Run only against a byte-for-byte copy of an explicitly supplied/exported SQLite file. Do not open the live app database in write mode. The inventory runner must emit the source file SHA256, SQLite version, schema SQL, table row counts, stable ID lists, duplicate/orphan queries, raw exception payloads and a deterministic report SHA256.

Minimum query groups:

1. `PRAGMA integrity_check` and `PRAGMA foreign_key_check`.
2. Counts and ID lists for centers, projects, tasks, taxonomy_categories, tags, persons, follow_up_records.
3. Project ownership: NULL/missing Center references.
4. Task membership cardinality: zero, exactly one and more than one `project_items` row per Task.
5. Task legacy Center versus each Project's Center.
6. Task Category text versus Project membership candidates.
7. Duplicate IDs, duplicate relation pairs, missing parent rows and malformed JSON payloads.
8. Tag and Person orphan links.
9. Person directory membership versus historical Task/Follow-up relations.
10. Template Category/Tag references and template application links.
11. Backup/restore source metadata and row/identity parity.

The runner must be read-only (SQLite URI `mode=ro`), must not call application store constructors that run `G1DriftSchema.install`, and must not set a migration marker or change `user_version`.

## 9. Required next implementation steps

1. Complete a full consumer/call-site map for every Project, Task Center, Category, Tag, Person, Template, Home, Calendar, Report, Backup and Restore read/write path.
2. Obtain a copy of a representative legacy database before claiming row-level inventory completion.
3. Implement a standalone read-only inventory runner with deterministic output and SHA256 manifest.
4. Add the canonical schema incrementally to the real G1 schema: required Project Center FK, Project-owned Category table, nullable Task Center/Project/Category FKs, indexes and SQL-level cross-parent triggers.
5. Keep `project_items`, `taxonomy_categories`, legacy payloads and migration sources intact through isolated candidate tests.
6. Adapt the existing optional-relationship tests to the real G1 schema. The current COMMAND 07-A.2.47 prototype creates miniature tables and is not production-schema acceptance.
7. Prove all-null, partial, consistent and inconsistent relationships directly against file-backed SQLite with foreign keys enabled.
8. Run D01–D05 independently, including repeat migration, injected interruption, rollback, five reopen cycles and physical SQLite backup/restore.
9. Only after consumer closure and parity may service facades or legacy structures be deprecated.

## 10. Exact-SHA CI evidence observed during inventory

For execution SHA `34f6fb1a42e5adb6255a1d56ce8c07ac7567ead2`:

- Build run `43432000089`: staging APK job SUCCESS; debug APK job SUCCESS; visual/PDF job SUCCESS; test shard 0 FAILURE (245 passed, 8 failed); analyze job FAILURE; release APK job was still IN_PROGRESS at the time of inspection; remaining test shards were queued/in progress.
- Device Smoke run `43432000260`: seven-lane matrix preparation SUCCESS; all seven device lanes were QUEUED at the time of inspection.
- Optional-relationship prototype run `43432000391`: SUCCESS on this exact SHA. It checks an isolated miniature schema, not the real G1 schema; it does not close D01 or Wave 1 schema acceptance.
- The Build run published staging/debug APK and PDF artifacts. Their existence does not override the failed Analyze/Test jobs or establish release readiness.
- No combined commit statuses were returned for the execution SHA; workflow jobs are the direct evidence.

No historical PASS has been transferred to this SHA.

## 11. Acceptance boundary

- Source schema/consumer inventory: PARTIAL; confirmed high-risk paths listed above.
- Actual user-data inventory: NOT RUN / UNKNOWN.
- Row-level IDs and counts: UNKNOWN.
- Canonical hierarchy schema: NOT IMPLEMENTED.
- Real-G1 optional relationship acceptance: NOT PROVEN.
- Migration/rollback/recovery: NOT ACCEPTED for the new hierarchy.
- D01–D05: NOT ACCEPTED.
- Merge / Release / Deployment: NOT AUTHORIZED.

This document is an evidence-led M0 checkpoint. It is not a claim that the migration inventory or production schema has been completed.


## COMMAND 07-A.2.55 — LIVE RECOVERY CHECKPOINT (2026-11-13 17:42 Asia/Tehran)

- Live Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db` (unchanged during this checkpoint).
- Execution branch: `feature/command-07-a-sqlite-contract-remediation`.
- PR #3384: OPEN / DRAFT / UNMERGED; base `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.
- Current code-only remediation commit: `32159f4f2ca13e78bcd2a383c5f384a1a4bd3905`; changed only `test/services/g1_hierarchy_candidate_schema_test.dart` to replace three string-concatenated file paths with interpolation after exact-SHA analyzer output identified three lint findings. Assertions and test semantics were unchanged. The new commit was re-fetched and confirmed; no workflow run or status was yet returned for this SHA, so the change is IMPLEMENTED, NOT RETESTED.
- Main-to-candidate comparison is not a valid PR diff: PR #3384 is intentionally based on the separate Wave 3 repair branch. Exact PR-base comparison before the lint-only commit was 167 commits ahead / 0 behind; after it, 168 ahead / 0 behind. Do not retarget or merge as part of this checkpoint.

### Exact-SHA CI evidence observed on predecessor candidate

Candidate `e017eeadf85f3043fb3fdfbb456486fd8e07bc10`:
- Run `43438369612`, SQLite A-D snapshots: SUCCESS; artifact `14044636632`, digest `sha256:025dcd3113669574f49c2605c228be55bcc61987e9c9c4b203c327a45c4c605b`.
- Run `43438369355`, optional Task links / G1 hierarchy candidate: SUCCESS; artifact `14045530922`, digest `sha256:5a1e5030bfcf9494f79608cc86a798f1d42f4aa3eb4ff4734d9e89c551c7c45e`.
- Build run `43438369432`: analyzer job failed with three info-level interpolation lints in the candidate-schema test; test shards reported 9, 7, 8 and 10 failures respectively (34 shard-reported failures; unique count not established). At observation, release APK was IN_PROGRESS and one test shard QUEUED. Device Smoke run `43438369594` was QUEUED. These are observations for `e017...`, not results for the new commit.
- Failure log examples include Home filter/layout assertions, Task Details/Person UI expectations, calendar interactions, recurrence and reminder behavior. Each failure remains UNRESOLVED pending root-cause and current-contract review; no assertion was weakened.

### Recovered source architecture facts (execution branch)

- Production `G1DriftSchema.version` is 19. It remains an additive/idempotent installer, not a sequential migration ledger.
- The production schema still has nullable `projects.center_id`; Categories remain global `taxonomy_categories(name)`; Task Center is in `legacy_payload_json`; Project membership is many-to-many through `project_items`; Task Category is legacy nullable text. These do not yet satisfy the approved Center → Project → Category → Task ownership/cardinality contract.
- `G1HierarchyCandidateSchema` is isolated and explicitly not called by production startup. Its passing test workflow and file-backed test artifact validate only the candidate fixture/test scope, not production migration acceptance.
- Existing source includes CenterStore/CenterManagementPage, ProjectStore, TaskStore, TagStore as a TaskStore facade, ProjectTemplateStore/ProjectTemplateService and TaskTemplateStore. A `task_template_service.dart` path was not present on this branch; broader history/consumer search is still required before classifying a TaskTemplateService as NOT FOUND.
- The REV10 migration inventory's earlier inspected SHA `34f6fb1a42e5adb6255a1d56ce8c07ac7567ead2` is historical and must not be treated as current. Current checkpoint supersedes its live-state pointers only; its source findings remain useful pending re-audit.

### Acceptance boundary

D01–D05 remain NOT ACCEPTED. No production startup switch, destructive migration, Main write, merge, release, deployment, branch deletion or history rewrite occurred. Cross-Center reporting and complete Deep Clone acceptance remain unverified. Continue from the exact branch HEAD and re-run targeted analyzer/schema tests before any broader acceptance claim.


## COMMAND 07-A.2.57 — Evidence Ledger and Product Recovery Addendum (2026-11-13)

### Live source pointer
The current source checkpoint for this addendum is `13a09af3815d7271ffb11e67eeac7b2592eb18bd`. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. Older inspected SHAs in this document remain historical and must not be presented as current.

### Four independent status dimensions
IMPLEMENTED means source behavior exists; TESTED means a test was executed on the cited SHA; VERIFIED means its relevant behavior and dependencies were examined with sufficient evidence; ACCEPTED means the Product Owner's acceptance gates are met. A source file or test file alone is not proof of the later statuses.

| Capability | IMPLEMENTED | TESTED on 13a09af | VERIFIED | ACCEPTED | Current evidence / gap |
|---|---|---|---|---|---|
| Center storage | Yes | Partial | Partial | No | CenterStore and SQL table; hierarchy ownership gate pending |
| Project storage | Yes | Partial | Partial | No | ProjectStore; owner is nullable in production schema |
| Category | Legacy only | No current exact-SHA result | No | No | taxonomy_categories is global; Candidate categories table is isolated |
| Tag | Yes | Partial | Partial | No | tags/task_tags exist; TagStore is compatibility facade |
| Person | SQL entities/relations | Snapshot tested | Partial | No | persons and Task/Follow-up relations preserved in snapshot; no independent repo |
| Unified Entity Management | Partial screens | No | No | No | Five-entity single management flow not proven |
| Home filters | Implemented | Not run in current checkpoint | No | No | Contract tests exist; exact-SHA CI result pending |
| Task Details | Implemented | Not run in current checkpoint | No | No | Full editor contract and autosave/reopen acceptance pending |
| Task autosave | Partial | Not accepted | No | No | Full-field durability after reopen not proven |
| Reminder / Follow-up | Existing implementation | Follow-up persistence SUCCESS | Partial | No | Snapshot records and file-persistence run; complete D03 remains open |
| Checklist / Notebook | Existing implementation | No current exact-SHA result | No | No | Full regression and persistence acceptance pending |
| Project Template | Existing | No current exact-SHA result | No | No | Store and service exist; independent deep clone not proven |
| Task Template | Existing store | No current exact-SHA result | No | No | Store and application table exist; service/consumer graph needs review |
| Cross-Center reporting | Partial infrastructure | No | No | No | templateTaskId filter/projection exists; E2E across two Centers absent |
| Production SQLite schema | Implemented v19 | Snapshot tested | Partial | No | Additive installer; does not satisfy new hierarchy |
| Isolated hierarchy candidate | Implemented | G1 workflow queued | No | No | Not called at production startup |
| Backup / Restore | Existing paths | Snapshot only | No | No | Same-file reopen is not independent restore |
| D05 rollback/recovery | Candidate tests exist | No current run result | No | No | Need exact-SHA injected-failure and retry evidence |
| PDF / Vazirmatn | Existing path | Historical evidence only | Partial | No | APK font packaging and device RTL checks pending |
| Android APK / Device Smoke | Build workflow exists | Pending/queued | No | No | Debug/Staging/Release and device scenarios not accepted |

### Current-SHA artifact ledger
- Run 43441067604; job 131938478464; artifact 14046601552.
- ZIP SHA256: `da890a5b7fbc5b8da0f4dbf86103b6671f35e8fe037cccaa5b192dcaf8f074c1`.
- JSON SHA256: `6ee103c73c74ace68bbc208af7c765e5f5ae81c81c97290ad33febb01af301fb`.
- Source SHA: `13a09af3815d7271ffb11e67eeac7b2592eb18bd`.
- Database kind: temporary file-backed SQLite, same file reopened five times.
- Verified scope: snapshot A/B/C/D equality for selected Task metadata, Reminder rows, Follow-up rows/order, Person links/identities, schema catalog, FK definitions and FK integrity.
- Explicit non-coverage: independent backup/restore into a separately created DB; full four-state Missing/NULL/FALSE/TRUE matrix; production hierarchy cutover; full D01–D05 acceptance.

### Known source duplication / consolidation queue
- `TaskTaxonomyMutationService` and `TaskTaxonomyLifecycleService` both exist. No removal until all consumers and behavior are mapped.
- TaskStore currently owns category/tag catalog operations; TagStore remains compatibility facade. No second writer.
- Category and Person repository paths were not found on this branch; historical NOT FOUND is not asserted.
- `TaskReportFilter.templateTaskId`, `TaskReportProjection`, `ProjectTemplateStore`, `TaskTemplateStore`, `ProjectTemplateService` and `template_task_applications` already exist. Extend rather than replace.
