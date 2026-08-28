# Home/List Scopes, Sorting and Move-to-Today Core — 2026-08-28

Refs #369 #375 #358.

## Purpose

Restore the owner-approved list behavior on the current canonical `Task` foundation without waiting for the final Home visual integration.

## Delivered in this service slice

### Canonical non-date scopes
`TaskListScopeService` provides:
- all normal items;
- simple notes;
- follow-up-enabled items.

Archive and Trash remain outside normal list scopes. The service returns the same canonical Task objects and never creates a parallel list model/store.

### Sorting
`TaskListSortService` provides deterministic sorting by:
- Task due date (`dueDate`);
- latest meaningful activity across created/updated/latest FollowUp;
- title.

Every sort supports ascending/descending direction. Undated/unknown date values remain at the end instead of being promoted accidentally.

### Move to Today
`TaskMoveToTodayService` reloads the canonical Task through `TaskStore`, changes only the Task due day and `updatedAt`, saves through the same `arvin.tasks` path, and preserves:
- Task id;
- original due time when present;
- Reminder schedule;
- FollowUp history/schedule;
- category;
- checklist;
- tags and text metadata.

Archived/trashed/missing Tasks fail explicitly rather than being silently resurrected.

## Already merged foundation reused

Today/Future/Overdue projection remains owned by `TaskDueScopeService` and uses only `Task.dueDate`. Reminder or FollowUp timestamps are never hidden substitutes for the Task due date.

## Still open under #369 / #375

This slice intentionally does **not** claim final acceptance. Remaining executable work includes:
- discoverable Home/list UI for all six scopes;
- visible sort control and re-select/double-tap direction toggle;
- Settings left/right swipe mapping for Move to Today;
- Task editor/detail Jalali due-date/time UI;
- final Home/list integration and real Android evidence;
- backup/sync/report/search due-date acceptance where required.

## Guardrails

- one canonical `Task` model;
- one canonical `TaskStore/arvin.tasks` persistence path;
- no duplicate Note/FollowUp/list database;
- no silent destructive action;
- implementation lanes may continue independently while UI/CI lanes validate.
