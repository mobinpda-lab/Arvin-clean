# Arvin Home Grouping Implementation Specification

## Purpose

Define the production implementation contract for the Home grouping engine without changing canonical data models.

## Data authority

- TaskStore remains the single Task source.
- ProjectStore remains the project membership authority.
- No duplicate Task, Category, Label, or Project storage is allowed.

## Group modes

### TIME
Source: Task.dueDate
Groups:
- Overdue
- Today
- Future
- No due date

Reminder and FollowUp dates must not replace due date.

### PROJECT
Source:
- ProjectStore memberships
- Canonical Task references

Required groups:
- All projects
- Selected project
- Without project

### CATEGORY
Source:
- Task.category

Required:
- Group by category
- Without category

### LABEL
Source:
- Task.tags

Required:
- Multiple labels per task
- No task duplication in persistence
- Without label group

## Output contract

Home projection should return display groups only:

- title
- icon
- color
- task references
- real count

The projection layer must not mutate data.

## Validation scenarios

1. Task with multiple labels appears in multiple label groups but remains one Task.
2. Task without due date has a visible access path.
3. Task with FollowUp does not move between time groups.
4. Project grouping does not create projectId fields inside Task.
