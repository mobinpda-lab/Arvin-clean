# Arvin Home Grouping Engine - Phase 2 Real Data Mapping

## Purpose
Connect the Home grouping projection layer to existing Arvin data without introducing parallel storage.

## Sources

- Time grouping: Task.dueDate
- Project grouping: ProjectStore + existing task project references
- Category grouping: Task.category
- Label grouping: Task.tags

## Rules

- TaskStore remains the source of truth.
- FollowUp and Reminder never replace due date semantics.
- Projection must not duplicate persisted tasks.
- Counts must represent real stored tasks.

## Validation Cases

1. One task with multiple labels appears in multiple label groups but remains one stored task.
2. Task without project appears in the unassigned project group.
3. Task without category appears in the unassigned category group.
4. Task without due date has a clear access path.
