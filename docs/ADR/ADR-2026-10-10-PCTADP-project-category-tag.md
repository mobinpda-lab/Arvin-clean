# ADR-2026-10-10-PCTADP — Project / Category-Group / Tag

- **Status:** Accepted as the product/domain vocabulary contract; implementation-conformance audit remains open.
- **Decision date:** 2026-10-10
- **Decision owner:** Arvin product owner
- **Scope:** Task, Project, Category/Group, Tag, filters, search, reports, calendar, recurrence, backup/restore, Notebook and all UI/documentation surfaces.
- **Tracking:** Issue #2582; related #524 and #2580; implementation-related PRs #2577, #2578, #2579, #2581.

## 1. Context

Arvin needs one stable vocabulary for organizing canonical Tasks. Historical documents and UI wording have sometimes treated Group as if it were a fourth concept, or confused category-like organization with tags. This ADR prevents parallel taxonomies, divergent meanings and feature-specific models.

## 2. Decision

Arvin's organization model has exactly three taxonomy concepts:

1. **Project** — a broad life/work domain or workspace, e.g. home, work, finance, learning, travel or personal.
2. **Category** — the primary section/classification used to organize Tasks inside the user's workflow. **Group is a synonym/legacy label for Category, not another entity.** The canonical technical name is `Category`.
3. **Tag** — a flexible, multi-dimensional attribute that can be applied to Tasks, e.g. urgent, monthly or shopping.

**Task remains Arvin's core actionable entity.** Project, Category and Tag classify or describe a Task; none replaces Task or becomes a parallel task system.

### 2.1 Category / Group unification

- Exactly one canonical Category concept/model/catalog.
- No independent Group entity, identifier, table, store, repository, manager, relationship layer or migration namespace.
- Do not create a Group↔Category mapping layer.
- Technical names use `Category` / `category`.
- The Persian UI's canonical term is **«دسته»**. Do not show «دسته» and «گروه» as two different choices or concepts. «گروه» may be mentioned only in developer/history documentation to explain the synonym or legacy wording, not as a second user-facing taxonomy term.
- “Grouping” that only arranges displayed items (e.g. Home sections by date) is presentation behavior, not a taxonomy entity.

### 2.2 Task cardinality

A canonical Task may have:
- zero or one Project;
- zero or one Category;
- zero or many Tags.

Category and Tag are distinct and must remain distinct in the model, serialization, UI, filtering, searching, reporting and backup/restore. A Tag must not substitute for Category; do not create excessive Categories to represent transient attributes better represented by Tags.

### 2.3 Intended semantic hierarchy

The product vocabulary is **Project → Category → Task**, with Tags describing Tasks across that structure. Project answers “which broad domain?”, Category answers “which main section?”, and Tag answers “which attributes apply?”.

This semantic hierarchy does **not**, by itself, assert that the current database enforces a Category-to-Project foreign key. Current code inspection found Project membership represented through Project-to-canonical-Task membership, while the Category catalog is stored separately and `Task.category` is its own field. Whether Categories must be physically scoped to a Project, or remain a shared catalog assignable alongside a Project, is an explicit implementation-conformance question to resolve in the audit before any schema/query change. Do not silently claim that the current schema already enforces Project → Category → Task.

### 2.4 Filters and queries

- Project filter selects the broad domain.
- Category filter selects the main classification.
- Tag filter selects one or more attributes.
- When multiple filters are active, combine them with **AND** semantics.
- Time is a separate filter/view, not a fourth taxonomy entity.
- Search, Report Center, Calendar/Repeat projections, Notebook, widgets and all Task surfaces must use the canonical data and must not introduce a second taxonomy or parallel query engine.

### 2.5 Persistence, backup and restore

- All surfaces reuse canonical Task, Project, Category and Tag foundations.
- Serialization and backup/restore must preserve both Task assignments and the canonical Category/Tag catalogs, including values not currently assigned to a Task where those catalogs are part of the supported product state.
- Before schema, migration or backup format changes, inspect actual current schema, old formats, runtime data assumptions, rollback and restore behavior. The owner's preference is a correct final architecture over retaining a known-wrong duplicate structure; this is not permission to make unverified destructive changes or silently lose data.

## 3. Alternatives rejected

- A fourth independent Group entity.
- Separate Category and Group catalogs or a Category↔Group translation layer.
- Using Tags as Categories, or Categories as Tags.
- Feature-specific Project/Category/Tag models or alternate stores for Search, Reports, Calendar, Repeat, Notebook, widgets or Backup.
- Treating date-based Home display grouping as a data entity.

## 4. Consequences

- All new features must reuse the canonical concepts and stores.
- UI wording is simplified to «پروژه»، «دسته» and «برچسب».
- Existing code/docs/tests that contradict the contract must be audited and corrected in focused changes.
- A physical Category-to-Project relation, if required, needs a separately evidenced schema/design proposal and tests; it must not be inferred from a diagram alone.
- The broader conformance audit remains tracked by Issue #2580. This ADR registration does not mark that audit, related PRs or release gates complete.

## 5. Required pre-change checklist

Before any change touching **Task, Project, Category/Group, Tag, Filter, Search, Report, Calendar, Repeat or Backup/Restore**:

1. Read this ADR and Issue #2582.
2. Inspect current `main`, existing Issues/PRs, canonical model/store/query paths and tests; update existing work rather than creating duplicates.
3. State the intended domain semantics and whether the change alters cardinality, relationships, persistence or serialization.
4. Confirm no Group entity/catalog/store or parallel taxonomy is introduced.
5. Confirm Project, Category and Tag remain separate and combined filters preserve AND semantics.
6. Validate Search, Report, Calendar/Repeat projections and all applicable surfaces.
7. Validate backup/restore, catalog preservation, compatibility, migration/rollback and no-data-loss behavior when persistence is affected.
8. Add focused regression tests and exact-head CI evidence.
9. Link the ADR and Issue #2582 in the relevant Issue/PR description.
10. Do not report completion without evidence; keep unresolved conformance questions explicit.

## 6. Implementation evidence at decision registration

- `lib/models/task.dart`: `Task.category` and `Task.tags` are distinct and serialized separately.
- `lib/models/goal_project.dart`: canonical Project lifecycle model.
- `lib/services/task_store.dart`: separate Category and Tag catalogs.
- `lib/services/project_store.dart`: canonical Project persistence and Task membership.
- `lib/task_taxonomy_management_page.dart`: existing Category/Tag manager; no new Group manager is authorized.

These are source snapshots, not a claim that every UI surface or backup path has passed conformance testing.

## 7. Change control

This is the canonical architecture decision record. Future conflicting conversation text, old documentation or PR wording does not silently supersede it. A change requires an explicit owner-approved replacement/amendment, updated ADR status/history, related issue/PR links and implementation evidence.

## 8. Related records

- Issue #2582 — formal PCTADP registration and acceptance tracking.
- Issue #524 — existing product contract.
- Issue #2580 — repository-wide ontology/conformance audit.
- PR #2577 — Notebook Category catalog.
- PR #2578 — Home Category/Tag catalogs.
- PR #2579 — unified Settings entry.
- PR #2581 — terminology/documentation alignment.
- `docs/DATA_MODEL_PROJECT_CATEGORY_TAG.md` — implementation-oriented model reference.
- `docs/ARVIN_MASTER_EXECUTION_PROTOCOL.md` — execution and pre-change governance.
