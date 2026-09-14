# Arvin Home Grouping Implementation Checklist Phase 1

## Objective
Implement the final Home grouping experience without changing canonical data models.

## Constraints
- Keep TaskStore as the single source of truth.
- Do not create parallel Task, Category, Label, or Project storage.
- Preserve existing data, FollowUp history, archive, trash, recurrence and reminders.

## Implementation order

### 1. Projection layer
- [ ] Create HomeGroup model.
- [ ] Create HomeGroupingService.
- [ ] Add grouping modes:
  - TIME
  - PROJECT
  - CATEGORY
  - LABEL

### 2. Time grouping
- [ ] Overdue from dueDate.
- [ ] Today from dueDate.
- [ ] Future from dueDate.
- [ ] No due date access path.
- [ ] Never use reminder or follow-up date as due date.

### 3. Project grouping
- [ ] Resolve project from ProjectStore.
- [ ] Support no-project group.
- [ ] Support adding task from group context.

### 4. Category and Label grouping
- [ ] Read canonical Task.category.
- [ ] Read canonical Task.tags.
- [ ] Do not duplicate tasks.
- [ ] Keep real counts.

### 5. Validation
- [ ] Unit tests for every grouping mode.
- [ ] Regression test existing TaskStore flows.
- [ ] Android verification after UI integration.

Status: Planning complete, implementation pending.
