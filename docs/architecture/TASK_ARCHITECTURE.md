# Task Architecture

**Authority:** [Master Product Operating Protocol (AMPOP)](../constitution/ARVIN_MASTER_PRODUCT_OPERATING_PROTOCOL.md), [taxonomy ADR](../ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), [execution protocol](../ARVIN_MASTER_EXECUTION_PROTOCOL.md).

## Canonical ownership
Task is the only canonical actionable entity. Existing source paths include `lib/models/task.dart` and `lib/services/task_store.dart`. UI entry paths, Home, Search, Notifications, Reports, Checklist, Repeat and Follow-up must reuse canonical Task identity and persistence.

## Task fields
The product contract includes title, description, date/time, project, category, tags, priority, checklist, repeat, tracking/follow-up, next action, history and calendar link. Field presence in this contract does not assert every flow has passed acceptance.

## Entry paths
Quick Add creates an unsaved draft for the existing Full Editor. The transition must preserve one draft ID; cancel must not persist a second Task; confirmed save creates/updates exactly one canonical Task. Current work is tracked by Issue #2593 and draft PR #2595.

## Classification
Project is a broad domain; Category is a single primary classification; Tags are multi-valued attributes. Group is not an entity. The accepted taxonomy ADR notes that physical Category-to-Project scoping is unresolved and must not be inferred from a diagram.

## Checklist, Repeat and Tracking
Checklist definition belongs to Task; execution state for a repeat belongs to its occurrence. Repeat does not clone canonical Tasks. Tracking and Follow-up remain Task capabilities, not a separate CRM. Preserve history and existing recurrence semantics; review Issue #2254 before changing the recurrence engine.

## Persistence and compatibility
Use the existing canonical store and JSON/data contracts. Before changing fields or serialization, verify older records, backup payloads, restore behavior, migration and rollback. PR #2595 introduces additive `Task.note` in the existing JSON envelope with an empty default for old records; exact-head round-trip validation remains pending.

## Validation checklist
- [ ] One stable Task ID through Quick Add → Full Editor → save/edit.
- [ ] Cancel/retry preserves the unsaved draft without mutation or duplicate.
- [ ] Project, Category, Tags, Checklist, Repeat, Follow-up, date/time and note round-trip.
- [ ] Occurrence completion does not overwrite prior history or leak checklist state.
- [ ] Backup/Restore and legacy compatibility preserve canonical identity and relations.
- [ ] Exact-head Analyze, tests, Debug/Release builds and relevant device flows pass.
