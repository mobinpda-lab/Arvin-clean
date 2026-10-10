# Arvin Data Model Contract — Project / Category / Tag

**Canonical decision:** [ADR-2026-10-10-PCTADP](ADR/ADR-2026-10-10-PCTADP-project-category-tag.md)  
**Status:** Contract approved; full code/schema conformance audit is still open in Issue #2580.  
**Last updated:** 2026-10-10

## Canonical concepts

| Concept | Meaning | Task cardinality | Canonical implementation evidence |
|---|---|---:|---|
| Project | Broad domain/workspace | 0..1 per Task | `ProjectPlan`, `ProjectStore`; Project membership links canonical Task IDs |
| Category | Primary classification | 0..1 per Task | `Task.category`; `taxonomy_categories` catalog in `TaskStore` |
| Tag | Flexible multi-dimensional attribute | 0..many per Task | `Task.tags`; `tags` catalog and task-tag persistence in `TaskStore` |
| Task | Canonical actionable product entity | Core entity | `lib/models/task.dart`, canonical Task storage |

## Non-negotiable invariants

- Category and Group are one concept. `Category` is the technical name; **«دسته»** is the standard Persian UI term.
- No separate Group model/table/store/repository/manager or Group↔Category relation layer.
- Category is not Tag. Preserve separate fields, catalogs, serialization and user intent.
- Project does not replace Task; Category does not replace Task; Tag does not replace Task.
- One Task may have zero/one Project, zero/one Category and multiple Tags.
- Time and date-based display grouping are not taxonomy entities.
- Filters for Project, Category and Tag are distinct; multiple active filters combine with AND.
- Search, Report, Calendar, Repeat, Notebook, widget, Backup and Restore reuse canonical data and must not fork it.

## Important relationship caveat

The product-level semantic diagram is Project → Category → Task, with Tags describing Tasks across that structure. The current code inspected for this record stores Project membership as Project-to-Task membership (`ProjectPlan.itemIds`) and Category as a separate Task field/catalog. This documentation does not assert that a Project foreign key exists on Category or that Category is currently restricted to a Project.

Whether Category is physically scoped to Project is unresolved and must be examined in Issue #2580 before any schema/query change. No schema change is authorized merely by this documentation update.

## Backup and restore

Backup/restore acceptance must verify:
- Task Project/Category/Tag assignments survive round-trip.
- Category and Tag catalog values survive, including unused catalog values when supported by the product.
- Legacy backup compatibility, invalid/corrupt payload handling, validation-before-mutation and rollback are tested.
- No parallel taxonomy storage is introduced.

## Code review checklist

- [ ] Read the canonical ADR and link it from the Issue/PR.
- [ ] Reuse existing Task/Project/Category/Tag models and repositories.
- [ ] No Group entity or duplicate taxonomy.
- [ ] Category and Tag remain distinct.
- [ ] Filter composition is AND.
- [ ] All impacted surfaces and tests are covered.
- [ ] Persistence/backup/restore compatibility is validated where applicable.
- [ ] Any Project↔Category schema relationship is explicitly decided with evidence rather than inferred.
