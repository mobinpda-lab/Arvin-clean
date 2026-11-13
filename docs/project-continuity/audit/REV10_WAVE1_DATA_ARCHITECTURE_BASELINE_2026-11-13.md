# REV10 WAVE 1 — Live Data Architecture Baseline
**Date:** 2026-11-13  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Inspected product SHA:** `3f471e6b88764446eabd33752d0aa3d820f52628`  
**Status:** SOURCE AUDIT COMPLETE FOR THE FILES LISTED; TARGET ARCHITECTURE NOT IMPLEMENTED / NOT ACCEPTED.

## 1. Inspected files and exact blob evidence

| File | Blob SHA | What it establishes |
|---|---|---|
| `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | G1 schema v19; current table/column definitions and migration sequence |
| `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` | Task model has Center reference but no direct Project/Category IDs in the inspected model |
| `lib/services/task_store.dart` | `1ecf9ca2368a8f72c86b277a6709cf389a8c9553` | Task persistence, category catalog, project membership consumers and normalized Tag/Person relations |
| `lib/services/project_store.dart` | `5197479665880e5f3ee2250ee733f4f451749090` | Project ownership and `project_items` read/write path |
| `lib/task_taxonomy_management_page.dart` | `6bba54f16163b1c988f49adacfb4d4d3cdfbc34b` | Existing Category/Tag management UI scope |
| `test/diagnostics/command_07_a2_47_optional_relationship_sqlite_test.dart` | `5a4f0fed72faef812cce88c9f4169a9b0ed8835e` | Isolated miniature SQLite prototype, not the production G1 schema |
| `docs/architecture/COMMAND_07_A2_45_CANONICAL_SCHEMA_MIGRATION_DESIGN.md` | `b8dfd130337c500746438c51686a872b7d3b2caa` | Existing migration target, phases, exceptions and acceptance design |

## 2. Actual schema vs REV10 target

| Area | Actual inspected implementation | REV10 target | Status |
|---|---|---|---|
| Center | SQL table exists | Canonical Center entity | PARTIAL |
| Project → Center | `projects.center_id` nullable | Exactly one Center | RED |
| Category | Global `taxonomy_categories(name)` | Stable Category ID owned by one Project | RED |
| Task → Center | Model field serialized in `legacy_payload_json`; no SQL FK column | Optional 0..1 SQL relation | RED |
| Task → Project | `project_items` many-to-many | Optional 0..1 direct relation | RED |
| Task → Category | Legacy category text | Optional 0..1 Category FK | RED |
| Tags | `tags` + `task_tags` SQL relation | Independent 0..N relation | PARTIAL / source exists |
| Person | `persons`, `person_directory`, `task_persons`, `follow_up_record_people` | Real reusable SQL entity and relationships | PARTIAL / source exists |
| Entity Management Center | Existing Category/Tag page | Unified Center/Project/Category/Tag/Person environment | RED |
| Cross-parent SQL integrity | No production hierarchy triggers observed in the inspected schema | FK + trigger/equivalent checks | RED |

## 3. Root findings

1. **Task Center is not normalized.** The Dart model exposes `centerId`, but `Task.toJson()` writes it into the payload envelope and `TaskStore._decodeTask()` restores it from `legacy_payload_json`. This is not a canonical SQL foreign-key relation.
2. **Project membership cardinality is wrong for REV10.** `project_items` allows one Task to belong to multiple Projects. REV10 requires at most one direct Task → Project relationship.
3. **Category ownership is missing.** A global category name cannot establish which Project owns it. Same-name Categories in different Projects must have distinct stable identities.
4. **Project ownership is not mandatory.** Existing `projects.center_id` is nullable and the schema does not yet prove every Project belongs to exactly one Center.
5. **The existing optional-link diagnostic is a prototype.** It creates its own Center/Project/Category/Task tables and triggers. It does not run against `G1DriftSchema`; a green result would not prove the production schema.
6. **Person and Tag persistence already have SQL relation tables**, but the user-facing five-entity management experience and all lifecycle requirements are not established by those tables alone.

## 4. Data safety constraints before migration

- Do not assign a Center to an existing Project whose owner is NULL without source evidence or Mobin's explicit resolution.
- A Task with zero Project memberships is valid and must remain unorganized.
- A Task with multiple Project memberships is ambiguous under the new 0..1 contract. Preserve the complete source relation and record an exception; do not choose one automatically.
- A legacy Category string can become a Project-owned Category only when the owning Project is unambiguous. Otherwise preserve the string and exception evidence.
- Keep `project_items` and `taxonomy_categories` until all consumers are inventoried, canonical reads/writes are migrated, parity is proven and removal is safe.
- Keep Person and Tag relation histories intact.
- No production data is available in this source audit; installed-user inventory is UNKNOWN.

## 5. Work authorized next

1. Inventory all consumers of `project_items`, `Task.centerId`, `Task.category`, taxonomy categories and Center/Project selection.
2. Build a read-only migration inventory with row counts, identity sets, relation counts, malformed/orphan records and a SHA256 manifest.
3. Implement the additive candidate schema and migration behind a controlled boundary; do not cut over or drop legacy tables.
4. Add real-G1 file-backed tests for nullable Task links, required parent ownership, invalid combinations, migration exceptions, rollback, repeatability and reopen.
5. Migrate a single canonical writer/reader boundary before changing UI/filter/report consumers.
6. Re-run D01–D05 independently on the final candidate SHA.

## 6. Acceptance boundary

- Wave 1 source audit: completed for the listed files.
- REV10 data hierarchy: NOT IMPLEMENTED.
- Production migration: NOT EXECUTED.
- User-data inventory: UNKNOWN.
- D01–D05: NOT ACCEPTED.
- Product acceptance: BLOCKED.

This report is an evidence-led baseline, not a claim of completed architecture consolidation.
