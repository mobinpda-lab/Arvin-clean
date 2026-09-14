# ARVIN Home Project Grouping Mapping Decision

## Purpose
Define the production-safe connection between Home project grouping and the existing Arvin project architecture.

## Rules

- Home must not add `projectId` to Task.
- Task data remains canonical.
- Project membership remains owned by ProjectStore / ProjectPlan.itemIds.
- Home grouping reads the relationship and creates a display projection only.

## Implementation target

Task + Project membership service

```
TaskStore
   +
ProjectStore
   ↓
HomeGroupingService
   ↓
Project Groups
```

## Acceptance tests

- Task assigned to one project appears under that project.
- Task without a project appears in "بدون پروژه".
- Removing a project assignment does not modify Task content.
- Display grouping never duplicates stored tasks.

## Current status

TIME: implemented
CATEGORY: implemented
LABEL: implemented
PROJECT: pending integration with ProjectStore
