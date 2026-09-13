# Arvin Home Wave 1 Code Mapping Checklist

## Purpose
Bridge the final UI reference and the real Flutter implementation before code changes.

## Rules
- Do not create parallel storage or duplicate domain models.
- Reuse existing Task, Project, Category, Label and repository layers.
- Visual similarity alone is not acceptance.

## Home Mapping

### Header
- Validate RTL layout.
- Validate title and navigation actions.
- Validate search behavior.

### Group Views
Required views:
1. Time
2. Projects
3. Categories
4. Labels

Acceptance:
- Groups use real data.
- Counts are calculated from source data.
- A task appearing in multiple groups is not duplicated.

### Task Card
Required:
- Completion control.
- Title.
- Related metadata.
- Due date/status.
- Last follow-up or description preview.
- Open details, not direct editor.

## Implementation Status

Documented: yes
Code mapping: in progress
Data validation: pending
Android verification: pending
