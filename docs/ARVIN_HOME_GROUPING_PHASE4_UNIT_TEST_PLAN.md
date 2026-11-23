# Arvin Wave 1 - Home Grouping Unit Test Plan

## Purpose
Validate the Home grouping projection before connecting the final UI.

## Required test areas

### Time grouping
- Uses Task due date only.
- Covers overdue, today, future and no due date.
- Reminder and FollowUp must not replace due date.

### Project grouping
- Uses existing project relationship.
- Covers tasks without a project.
- Does not duplicate Task records.

### Category grouping
- Uses existing Task category data.
- Covers tasks without category.

### Label grouping
- A task with multiple labels can appear in multiple groups.
- Stored task count remains unchanged.

## Regression targets
- TaskStore
- FollowUp history
- Archive
- Trash
- Reminder
- Recurrence

## Acceptance
No UI integration is accepted until these projection rules are verified.
