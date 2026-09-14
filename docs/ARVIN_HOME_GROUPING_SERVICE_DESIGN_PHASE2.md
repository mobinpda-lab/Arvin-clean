# ARVIN Home Grouping Service Design Phase 2

## Goal
Implement Home grouping without changing canonical data storage.

## Source of Truth

- TaskStore remains the only Task storage authority.
- Project data is resolved through existing project services.
- Category and labels are derived from canonical Task fields.

## Proposed Flow

TaskStore
→ HomeGroupingService
→ HomeGroupProjection
→ Home UI

## Modes

- TIME
- PROJECT
- CATEGORY
- LABEL

## Required Guarantees

- No duplicated Task objects.
- Counts are calculated from canonical tasks.
- Due date is independent from reminder and follow-up.
- Existing archive, trash, recurrence and follow-up data remain unchanged.

## Next Implementation Steps

1. Add projection classes.
2. Add grouping unit tests.
3. Connect Home widgets.
4. Run Flutter analyze and regression tests.
