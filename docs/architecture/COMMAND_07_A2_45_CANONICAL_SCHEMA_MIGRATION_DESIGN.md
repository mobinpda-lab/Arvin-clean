# COMMAND 07-A.2.45 — Canonical Data Model & Safe SQLite Migration Design

**Status:** DESIGN RECORDED — NOT IMPLEMENTED / NOT MIGRATED  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Design branch:** `feature/command-07-a-sqlite-contract-remediation`  
**Design base HEAD:** `b79f8d60e2a3b72630cf6d34095ecc30af340c6d`  
**Schema source inspected:** `lib/services/g1_drift_schema.dart`, declared version 19  
**Product contract:** Center → Project → Category → Task; Tags remain cross-cutting  
**Merge / Release / Deployment:** NOT AUTHORIZED

This document records the proposed target schema and migration protocol before any schema implementation. It is not evidence of a completed migration or of production data inventory.

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

### 2.2 Task hierarchy constraints

Add canonical `project_id` and `category_id` columns to `tasks`.

The required composite constraint is:

```sql
FOREIGN KEY (project_id, category_id)
  REFERENCES categories(project_id, id)
  ON UPDATE RESTRICT ON DELETE RESTRICT
```

This prevents a Task from referencing a Category owned by a different Project. Since Category has a restrictive FK to Project and Project has a non-null restrictive FK to Center, the Task's Center is derived through the same validated chain; no separately editable Task Center is needed.

The final accepted schema requires both Task columns NOT NULL. During the safe staging phase only, both may be NULL together for explicitly quarantined legacy exceptions. A CHECK must reject half-populated pairs. A `task_hierarchy_migration_exceptions` row must reference each staged Task lacking a resolvable hierarchy. This transitional allowance is not acceptance of an unassigned Task. Final NOT NULL rebuild is prohibited until the exception set is empty or the product owner explicitly approves a separately specified exception policy.

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
- Create new parent/category structures and staging hierarchy columns.
- Preserve all original tables and payload envelopes.
- Add exception tables and deterministic mapping audit rows.
- Do not drop or rename legacy relations in this phase.

**M2 — Deterministic backfill**
- Backfill Center/Project/Category/Task hierarchy only from unambiguous stable IDs and exact legacy Category values.
- Preserve every unresolved record and source relation in exception evidence.
- Do not assign a default Center, Project or Category.

**M3 — Integrity and parity**
- Compare row counts and identity sets before/after for every entity and relation.
- Compare Task payloads, Tag links, Person links, Follow-up metadata and ordering.
- Run `PRAGMA foreign_key_check`, `PRAGMA integrity_check`, and explicit cross-parent mismatch queries.
- Verify invalid cross-Center Project selection and cross-Project Category selection fail at SQL level.
- Verify moving Task parents is atomic and rollback restores the prior hierarchy.

**M4 — Repeatability and recovery**
- Run migration twice; second run must be a no-op with identical row counts and identities.
- Force a failure after writes but before commit; verify full rollback and unchanged source.
- Close/reopen the same database file at least five times and compare canonical snapshots.
- Test independent backup and restore into a different SQLite file, then reopen and re-run integrity/FK checks.

**M5 — Cutover (not authorized by this design document)**
- Only after all exception rows have explicit resolution, parity and D01–D05 pass, and the owner approves.
- Rebuild final tables with required NOT NULL constraints.
- Move all application reads/writes to the canonical hierarchy.
- Retire `project_items` only after all consumers are proven migrated; do not remove compatibility paths merely because a new schema exists.
- Preserve rollback/restore artifact and prior schema compatibility.

## 5. Index plan

At minimum evaluate and test:
- `projects(center_id, is_archived, storage_ordinal)`
- `categories(project_id, is_archived, name)`
- `tasks(project_id, category_id, due_date, completed, archived, trashed)`
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

## 7. Independent acceptance gates

- **D01 Schema Compatibility:** old supported DB shapes open and migrate; schema catalog, constraints and indexes match the approved design.
- **D02 Missing / NULL / FALSE / TRUE:** all four states round-trip distinctly where semantically applicable; no defaulting or key-presence loss.
- **D03 Follow-up Metadata / Person Relations:** Follow-up rows, metadata, Person identities, directory state and relation links preserve identity and order.
- **D04 Independent Backup / Restore:** a physical backup restores into a distinct SQLite file; close/reopen and integrity/FK checks pass.
- **D05 Atomicity / Rollback / Recovery:** injected failure rolls back every related write; source remains unchanged; retry is idempotent.

Each gate requires a dedicated test invocation, run ID, actual checkout SHA, test result, artifact ID and SHA256. A successful snapshot/reopen test is supporting evidence only, not a substitute for D01–D05.

## 8. Current blockers / owner decisions

The following require inventory or explicit owner resolution; they must not be guessed:
- Which existing Center should own each legacy Project with `center_id = NULL`.
- How to resolve Task records with no Project membership or multiple memberships.
- How to resolve Tasks with no Category or conflicting Center/Project evidence.
- Whether category name normalization is case-sensitive and how Persian ZWNJ/Arabic-vs-Persian character variants are handled.
- Whether a Project may ever be moved between Centers after it has generated cross-Center Template instances.

## 9. Evidence boundary at design commit

This commit records the proposal only. No schema, migration writer, production database, backup or user data is changed. No D01–D05 gate is declared passed by this document. Implementation requires a separate reviewed change after inventory and exception policy are agreed.
