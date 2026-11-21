# ADR-001 — Project Execution Model
- Status: APPROVED PRODUCT DECISION — NOT YET IMPLEMENTED/ACCEPTED
- Recorded: 2026-11-18 | References: COMMAND 37-R, 38-R, 39-R; REV10 | PR #3495

## Context
Project is a shared identity. Execution state must not be conflated across Centers. The audited storage has competing Task↔Project relation paths and does not yet implement the required per-Center execution entity.

## Decision
1. Project is a shared activity identity.
2. Center and Project have a many-to-many relationship.
3. `project_executions` represents one Project's independent execution in one Center.
4. Enforce `UNIQUE(project_id, center_id)`, unless a later approved product contract explicitly changes this.
5. Task's primary project-scoped execution relationship is to `project_executions`, not directly to shared Project identity.
6. A Task may exist without Project, Center, or Category.
7. Execution status, progress, and performance are independent per Center.
8. Category has an independent reusable identity and is not duplicated per Center.
9. Tags have one authoritative SQLite source; parallel SharedPreferences storage for the same Tag data is prohibited.
10. Aggregate and per-Center reporting are required.
11. Aggregate reports count each Task identity once, even if visible through multiple relationship paths.
12. Preserve valuable historical records and IDs. No legacy table/column is removed before complete transfer is proven.

## Relationship ownership
The canonical Task→Project execution relation must have one owner only. Existing `tasks.project_id`, `project_items`, and the new execution relation must not simultaneously own the same semantic relationship. Inventory existing Task/Project membership tables before selecting the canonical representation. Category cardinality per Task must be derived from existing product contracts and consumers; do not assume one or many.

## Consequences
Final schema, models, stores, reports, and backup format must implement this contract consistently. This ADR records an approved product decision, not completed implementation. Migration, Store consolidation, reports, backup/restore, and acceptance remain subject to COMMAND 38-R's NO-GO until independently verified.

## Acceptance evidence required
Historical SQLite upgrade fixtures; FK and uniqueness checks; multi-Center execution-isolation; Task without Project/Center/Category; no-duplicate aggregate reporting; independent SQLite backup/restore with ID, relation, row-count and FK validation; one-SHA Analyze, unit tests, APK build and device smoke.