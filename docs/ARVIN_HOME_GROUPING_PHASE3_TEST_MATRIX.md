# ARVIN Wave 1 Home Grouping Test Matrix

## Goal
Validate the Home grouping projection without changing Task storage or creating parallel data models.

## Time grouping
- Overdue tasks are grouped by `dueDate`.
- Today tasks are grouped by `dueDate`.
- Future tasks are grouped by `dueDate`.
- Tasks without a due date have a dedicated path.
- Reminder and FollowUp dates must not replace due dates.

## Project grouping
- Tasks are grouped through existing project relationships.
- Tasks without a project appear in the unassigned group.
- Grouping must not duplicate stored tasks.

## Category grouping
- Category projection reads existing task category data.
- Empty category has a visible fallback group.
- No parallel category database is introduced.

## Label grouping
- A task may appear in multiple label groups.
- Storage count remains equal to real task count.
- No duplicated task records are created.

## Regression checks
- Existing TaskStore remains the only source of truth.
- FollowUp history remains attached to the original task.
- Archive, Trash, Reminder and Recurrence behavior remain unchanged.

## Acceptance
Documented -> Implemented -> Tested -> Android verified -> Evidence recorded.
