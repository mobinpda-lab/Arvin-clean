# COMMAND 07-A.2.45 — Canonical Data Model & Safe SQLite Migration Design

**Status:** DESIGN RECORDED — OFFICIAL OPTIONAL TASK RELATIONSHIP CONTRACT INCORPORATED — NOT IMPLEMENTED / NOT MIGRATED  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Design branch:** `feature/command-07-a-sqlite-contract-remediation`  
**Design base HEAD:** `b79f8d60e2a3b72630cf6d34095ecc30af340c6d`  
**Schema source inspected:** `lib/services/g1_drift_schema.dart`, declared version 19  
**Product contract:** Center → Projects → Categories → Tasks; Task links to Center / Project / Category are independently optional (0..1 each); Tags are independently many-to-many (0..N)  
**Merge / Release / Deployment:** NOT AUTHORIZED

This document records the proposed target schema and migration protocol before any schema implementation. The official cardinality and optional relationship contract supplied after the initial design supersedes any earlier proposal that made Task hierarchy fields mandatory. It is not evidence of a completed migration or of production data inventory.

## 1. Current schema facts

At the inspected design base:

- `centers` exists.
- `projects.center_id` exists but is nullable.
- `tasks.category` is a nullable text field; Task has no canonical `project_id` or `category_id` columns.
- `taxonomy_categories` is a global name catalog and has no Project ownership.
- `project_items(project_id, task_id, ordinal)` is a many-to-many membership table; its key prevents duplicate membership in one Project but does not prevent one Task from belonging to multiple Projects.
- `task_tags` and `task_persons` are normalized relation tables.
- `follow_up_record_people` preserves historical Person links.
- `template_task_applications(template_task_id, project_id, task_id)` is the existing stable Template Task origin relation.
- Schema installation is implemented as idempotent SQL in `G1DriftSchema.install`; it declares version 19 but does not use a sequential Drift MigrationStrategy/user_version ledger. The installer currently toggles foreign keys off during its transaction and checks them before commit.

## 2. Proposed canonical target

### 2.1 Parent tables

**centers**
- `id TEXT PRIMARY KEY`
- `name TEXT NOT NULL`
- archive/lifecycle metadata
- normalized-name uniqueness policy to be confirmed; never merge existing IDs based on equal names.

**projects**
- `id TEXT PRIMARY KEY`
- `center_id TEXT NOT NULL REFERENCES centers(id) ON DELETE RESTRICT`
- existing title, order, color, archive and template snapshot fields retained
- index `(center_id, is_archived, storage_ordinal)`

**categories**
- `id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE RESTRICT`
- `name TEXT NOT NULL`
- archive/order/timestamp fields
- `UNIQUE(project_id, id)` to provide a composite parent key
- `UNIQUE(project_id, normalized_name)` (normalization algorithm must be fixed and tested before implementation)
- index `(project_id, is_archived, name)`

### 2.2 Official Task cardinality and optional relationship constraints

The Task-side links are independently optional and must remain nullable in the final schema:

- `tasks.center_id`: `NULL` or one existing Center.
- `tasks.project_id`: `NULL` or one existing Project.
- `tasks.category_id`: `NULL` or one existing Category.
- `task_tags`: zero or more Tag links.

No Task requires any of these links to be created, saved, reopened or edited. The all-null Task is a valid canonical state. A Task may also have only Center, only Project, only Category, or only Tags. Do not add a CHECK that requires Project and Category to be populated together, and do not make any Task hierarchy column NOT NULL.

Use independent nullable foreign keys for existence:

```sql
FOREIGN KEY (center_id) REFERENCES centers(id)
  ON UPDATE RESTRICT ON DELETE RESTRICT,
FOREIGN KEY (project_id) REFERENCES projects(id)
  ON UPDATE RESTRICT ON DELETE RESTRICT,
FOREIGN KEY (category_id) REFERENCES categories(id)
  ON UPDATE RESTRICT ON DELETE RESTRICT
```

These FKs validate that each selected entity exists. They do not by themselves validate cross-parent consistency. Add SQLite `BEFORE INSERT` and `BEFORE UPDATE OF center_id, project_id, category_id` validation triggers (or an equivalently strong constraint design supported by the actual Drift schema) with the following rules:

1. If `center_id` and `project_id` are both non-NULL, the selected Project must belong to that Center.
2. If `project_id` and `category_id` are both non-NULL, the selected Category must belong to that Project.
3. If `center_id` and `category_id` are both non-NULL while `project_id` is NULL, the Category's owning Project must belong to that Center.
4. If all three are non-NULL, all three ownership links must match.
5. If only Project is supplied, accept it and derive its Center for display/reporting; do not force-write `center_id` onto the Task.
6. If only Category is supplied, accept it and derive its Project and Center for display/reporting; do not force-write either derived value onto the Task.
7. If any one or all three are NULL, that absence is valid. A non-NULL reference must still satisfy its FK.

This permits explicit optional direct selections while preserving the ownership chain. The effective/derived Center and Project used by filters and reports must be resolved by joins without silently materializing extra Task-side selections. Keep the distinction between a directly selected value and an ancestor derived through ownership.

The parent ownership rules remain mandatory: every Project has exactly one Center and every Category has exactly one Project. Optionality applies only to Task-to-parent links. Use RESTRICT for parent deletion; do not cascade-delete Tasks or hierarchy records.

When a user selects a new parent in the UI, any now-incompatible child selection must be surfaced explicitly. The application must not silently erase a selected relation or silently rewrite it. Offer a clear keep-compatible / clear-child / cancel decision, and perform any accepted update atomically.

Migration exceptions are for ambiguous legacy evidence, not for the valid all-null or partially populated Task states. Never create placeholder Center, Project or Category rows to fill nullable fields.

### 2.3 Tags, People and shared activity identity

- Keep `tags` and `task_tags` independent of the Center hierarchy. Preserve many-to-many links and add/verify indexes in both traversal directions.
- Keep `persons`, `person_directory`, `task_persons` and `follow_up_record_people`; do not collapse active directory membership and historical relations.
- Preserve `template_task_applications` as the stable shared-activity identity bridge. Each generated Task remains a unique Task row; a shared `template_task_id` identifies the common activity across Project/Center instances. Add/verify indexes for `(template_task_id, project_id)` and `task_id`.
- Do not implement cross-Center aggregate reporting as part of this migration. The schema only prepares a reliable projection source.

### 2.4 Referential and lifecycle policy

- All hierarchy FKs use RESTRICT; archive/restore is the non-destructive lifecycle.
- Parent deletion with children is rejected at database level and surfaced as a domain error.
- Moving a Task changes its Project and Category together in one transaction. The destination Category must belong to the destination Project.
- Moving a Project to another Center is an explicit Project-level operation; it must not rewrite Task identity, Template origin or history.
- No cascade may delete Task, Tag, Person, Follow-up, Reminder or Template history.

## 3. Legacy inventory and deterministic mapping

Before writes, an inventory job must produce a machine-readable report and SHA256 manifest with counts for Centers, Projects, Tasks, Category strings, Project memberships, Tags, Task-Tag links, Persons, Task-Person links, Follow-up records and Follow-up-Person links.

The inventory must classify:

1. Project with missing/unknown Center.
2. Task with zero Project memberships.
3. Task with more than one Project membership.
4. Task with exactly one membership but missing/blank Category.
5. Task whose legacy `centerId` conflicts with its Project's Center.
6. Task whose Project or Category reference is invalid.
7. Duplicate IDs, malformed records and duplicate membership rows.
8. Legacy Category values that differ only under the proposed normalization.
9. Orphan Tag/Person links and duplicate or missing Person identities.

Safe automatic mapping is limited to:
- a Task with exactly one existing Project membership;
- a non-empty legacy Category string;
- no conflicting legacy Center evidence;
- an existing Project identity;
- an exact, deterministic Category mapping scoped to that Project.

A distinct Category ID is created per Project even when two Projects use the same display name. No mapping is inferred from Project/Center names. No Center is fabricated. Zero/multiple Project memberships, missing Category, missing Center and conflicting evidence are recorded as migration exceptions with original Task/Project IDs and the complete source payload preserved.

Real installed-user data counts remain **UNKNOWN** until a read-only inventory is run against an explicitly supplied/exported database. CI fixtures and snapshot artifacts must not be represented as the user's production inventory.

## 4. Migration phases

**M0 — Read-only inventory**
- Capture source DB copy, schema catalog, row counts, relation counts and hashes.
- Validate source integrity and foreign keys.
- Produce `migration-inventory.json` and `migration-exceptions.json`.
- No source writes.

**M1 — Isolated candidate schema**
- Copy the source database to a temporary file-backed test database.
- Create new parent/category structures and nullable Task `center_id`, `project_id`, and `category_id` columns.
- Add independent FKs and cross-parent validation triggers; verify enforcement with foreign keys enabled on every connection.
- Preserve all original tables and payload envelopes.
- Add exception tables and deterministic mapping audit rows for ambiguous legacy data only.
- Do not drop or rename legacy relations in this phase.

**M2 — Deterministic backfill**
- Backfill each Task-side optional link independently only where the legacy source proves that exact relationship.
- A legacy Task with no relationship remains valid with NULL in the corresponding canonical column; do not treat absence as a migration error.
- Preserve every ambiguous or contradictory legacy record and source relation in exception evidence.
- Do not infer a Center from a name, invent a Project, or create a Category merely to populate a nullable Task field.

**M3 — Integrity and parity**
- Compare row counts and identity sets before/after for every entity and relation.
- Compare Task payloads, Tag links, Person links, Follow-up metadata and ordering.
- Run `PRAGMA foreign_key_check`, `PRAGMA integrity_check`, and explicit cross-parent mismatch queries.
- Verify invalid Center/Project, Project/Category, and Center/Category combinations fail at SQL level.
- Verify valid all-null, Center-only, Project-only, Category-only, Tag-only and valid paired/triple combinations succeed.
- Verify moving Task parents is atomic and rollback restores the prior hierarchy.
- Verify clearing all optional Task links and reopening SQLite preserves the all-null state.

**M4 — Repeatability and recovery**
- Run migration twice; second run must be a no-op with identical row counts and identities.
- Force a failure after writes but before commit; verify full rollback and unchanged source.
- Close/reopen the same database file at least five times and compare canonical snapshots.
- Test independent backup and restore into a different SQLite file, then reopen and re-run integrity/FK checks.

**M5 — Cutover (not authorized by this design document)**
- Only after all exception rows have explicit resolution, parity and D01–D05 pass, and the owner approves.
- Enforce NOT NULL only on mandatory parent ownership (`projects.center_id`, `categories.project_id`). Task-side `center_id`, `project_id`, and `category_id` remain nullable permanently under this contract.
- Move all application reads/writes to the canonical hierarchy.
- Retire `project_items` only after all consumers are proven migrated; do not remove compatibility paths merely because a new schema exists.
- Preserve rollback/restore artifact and prior schema compatibility.

## 5. Index plan

At minimum evaluate and test:
- `projects(center_id, is_archived, storage_ordinal)`
- `categories(project_id, is_archived, name)`
- `tasks(center_id, project_id, category_id, due_date, completed, archived, trashed)`
- `categories(project_id, id)` and `projects(center_id, id)` unique parent keys if required by the selected composite-FK/trigger implementation
- `task_tags(tag_id, task_id)` and `task_tags(task_id, tag_id)`
- `task_persons(person_id, task_id)` and `task_persons(task_id, person_id)`
- `follow_up_record_people(person_id, follow_up_id)`
- `template_task_applications(template_task_id, project_id)` and `template_task_applications(task_id)`
- indexes for report filters on Center/Project/Category, due date, status and stable Template Task identity.

Query plans and real fixture cardinalities must justify final index selection; avoid speculative redundant indexes.

## 6. One canonical writer per domain — target ownership

| Component | Target responsibility |
|---|---|
| CenterStore | Center CRUD and lifecycle |
| ProjectStore | Project identity, metadata, Center ownership |
| TaskStore | Task CRUD, Task→Project→Category assignment, Tags and Person relations |
| TagStore | Compatibility Facade delegating to TaskStore; never a separate SharedPreferences writer |
| TaskPeopleService | Application service delegating Person operations to TaskStore |
| TaskTaxonomyMutationService | Pure deterministic domain operations; no persistence |
| TaskTaxonomyLifecycleService | Pure reference/lifecycle validation; no persistence |

Project membership writes must converge into one Task hierarchy assignment boundary. ProjectStore's current `itemIds` compatibility API may remain temporarily, but must delegate to that boundary; it must not independently maintain a competing membership truth. Consumer inventory is required before retiring any old service/API.

## 7. Independent optional-relationship acceptance matrix

These cases are independent required tests and must run against the file-backed candidate SQLite database with foreign keys enabled:

1. Create/save/reopen a Task with no Center, Project, Category or Tag.
2. Task with Center only.
3. Task with Project only; effective Center is derived from Project without writing a direct Task Center.
4. Task with Category only; effective Project and Center are derived through ownership without writing direct Task ancestors.
5. Task with Tag(s) only and no hierarchy links.
6. Task with Center + Project where the Project belongs to that Center.
7. Task with Project + Category where the Category belongs to that Project.
8. Task with Center + Project + Category where the complete chain is consistent.
9. Task with multiple Tags, including shared Tags used by Tasks in different Centers.
10. Clear all optional selections, save, close/reopen SQLite, and verify all three Task-side links remain NULL and Tag links match the explicit user action.

Additional negative cases must reject: Center + unrelated Project; Project + Category owned by another Project; Center + Category whose owning Project belongs to another Center; and any non-existent FK target. These failures must be tested at database level, not only through UI validation.

UI acceptance must independently verify a visible empty/clear-selection affordance for Center, Project and Category. When a parent change conflicts with a selected child, the UI must explain the conflict and obtain an explicit user choice to clear the child, keep the prior parent, or cancel. No relationship may be silently removed or rewritten. A Task with all four organization fields empty must save successfully.

## 7. Independent acceptance gates

- **D01 Schema Compatibility:** old supported DB shapes open and migrate; schema catalog, constraints and indexes match the approved design.
- **D02 Missing / NULL / FALSE / TRUE:** all four states round-trip distinctly where semantically applicable; no defaulting or key-presence loss.
- **D03 Follow-up Metadata / Person Relations:** Follow-up rows, metadata, Person identities, directory state and relation links preserve identity and order.
- **D04 Independent Backup / Restore:** a physical backup restores into a distinct SQLite file; close/reopen and integrity/FK checks pass.
- **D05 Atomicity / Rollback / Recovery:** injected failure rolls back every related write; source remains unchanged; retry is idempotent.

Each gate requires a dedicated test invocation, run ID, actual checkout SHA, test result, artifact ID and SHA256. A successful snapshot/reopen test is supporting evidence only, not a substitute for D01–D05.

## 8. Current blockers / owner decisions

The official optional Task relationship contract is accepted as the governing product rule; no further decision is needed to keep Task links nullable. The following legacy-data questions still require inventory or explicit owner resolution and must not be guessed:
- Which existing Center should own each legacy Project with `center_id = NULL`; Project ownership itself remains mandatory.
- How to resolve legacy Tasks with zero or multiple `project_items` memberships when mapping historical membership into the new optional direct `project_id` field. Zero membership is not an error and may map to NULL; multiple memberships are ambiguous and must be preserved for owner review.
- How to resolve Tasks with missing Category text or conflicting Center/Project/Category evidence. Missing Category may legitimately map to NULL; conflicting evidence must be preserved as an exception.
- Whether category name normalization is case-sensitive and how Persian ZWNJ/Arabic-vs-Persian character variants are handled.
- Whether a Project may ever be moved between Centers after it has generated cross-Center Template instances.

## 9. Evidence boundary at design commit

This commit records the proposal and the official optional Task relationship correction only. No schema, migration writer, production database, backup or user data is changed. No D01–D05 gate is declared passed by this document. Implementation requires a separate reviewed change after inventory and exception policy are agreed.


---

## REV10 authorization and live production-schema audit — 2026-11-13

**Authority:** ARVIN MASTER PRODUCT, DESIGN & GOVERNANCE CHARTER REV10  
**Latest inspected product SHA:** `3f471e6b88764446eabd33752d0aa3d820f52628`  
**Disposition:** controlled implementation and non-destructive migration work are AUTHORIZED; destructive cutover, legacy retirement and acceptance remain gated.

REV10 supersedes the earlier sentence that treated all implementation as awaiting a separate authorization. It does not waive the safety conditions in M0–M4, D01–D05, migration exception resolution, exact-SHA evidence or the explicit restrictions on irreversible production operations.

### Live source facts at the inspected SHA

1. `G1DriftSchema.version` is 19.
2. The canonical `tasks` table has no normalized `center_id`, `project_id` or `category_id` columns. It has a nullable legacy `category` text column.
3. `Task.centerId` exists in the Dart model and is serialized by `Task.toJson()`; `TaskStore._decodeTask()` reads it from `legacy_payload_json`. It is not currently a normalized SQL foreign-key relation.
4. The Task model has no direct `projectId` or `categoryId` fields in the inspected model contract.
5. `projects.center_id` exists but is nullable; therefore mandatory Project → Center ownership is not yet enforced.
6. `taxonomy_categories(name)` is a global name catalog. It has no stable Category ID or Project owner.
7. `project_items(project_id, task_id, ordinal)` is the current many-to-many Project/Task membership relation. It permits a Task to be linked to multiple Projects and is not equivalent to the REV10 0..1 Task → Project contract.
8. `task_tags`, `task_persons` and `follow_up_record_people` are normalized SQL relation tables. Person records are persisted in `persons`; active directory membership is separate in `person_directory`.
9. `TaskTaxonomyManagementPage` manages Category and Tag catalogs; it is not the REV10 five-entity Entity Management Center.
10. `ProjectStore.save()` rewrites Project and `project_items` rows transactionally and preserves selected legacy payload fields. It remains an active consumer that must be migrated before retiring `project_items`.

### Consequence

The current code is Local-First and uses SQLite for canonical core tables, but the REV10 hierarchy is **NOT IMPLEMENTED** in the normalized schema. The optional-relationship prototype workflow uses a test-created miniature schema; it does not instantiate or validate the real G1 production schema. Its eventual PASS can prove the SQL constraint prototype only, not the production cutover.

### Required safe sequence

- M0: inventory actual source schemas and all consumers; no writes.
- M1: add canonical Category ownership and nullable Task FKs in an isolated candidate; preserve old tables/payloads.
- M2: map only exact, unambiguous legacy relationships; record all ambiguous cases as exceptions.
- M3: parity, ownership triggers, direct SQLite positive/negative tests and rollback checks.
- M4: repeatability, independent physical backup/restore and recovery.
- Update all writers/readers, filters, reports, templates and tests to one canonical relationship boundary.
- Only after D01–D05 and explicit exception resolution may legacy membership/catalog retirement be considered. No destructive production cutover is authorized by this audit.

### High-risk unresolved data questions

- Existing Projects with `center_id IS NULL` cannot be assigned to a Center by name or guess.
- Tasks with zero `project_items` memberships are valid unorganized Tasks.
- Tasks with more than one Project membership are ambiguous under the new 0..1 contract; preserve all old memberships and request resolution rather than choosing one.
- Legacy Category text without a uniquely evidenced owning Project cannot be converted into a canonical Project-owned Category automatically.
- Category normalization and Project movement policy remain unresolved.

This addendum is a source audit and authorization reconciliation. It does not claim schema implementation, migration, production-data inventory or D01–D05 acceptance.
