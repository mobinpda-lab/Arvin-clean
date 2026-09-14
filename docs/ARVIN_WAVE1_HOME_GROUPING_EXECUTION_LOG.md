# Arvin Wave 1 - Home Grouping Execution Log

## Objective
Implement the final Home grouping architecture without changing canonical task storage.

## Source of Truth
- TaskStore remains the canonical task persistence boundary.
- Project, Category and Label views must be projections over existing data.
- No duplicate task storage is allowed.

## Execution Order

1. Add Home grouping projection layer.
2. Add TIME, PROJECT, CATEGORY and LABEL grouping modes.
3. Add unit coverage for grouping rules.
4. Connect Home UI incrementally.
5. Run Flutter analysis and regression tests.

## Acceptance Checks

- Due date drives time grouping.
- Reminder and FollowUp do not replace due date.
- A task with multiple labels appears in multiple views without duplicate storage.
- Counts represent real tasks.
- Existing archive, trash, recurrence and follow-up data remain intact.
