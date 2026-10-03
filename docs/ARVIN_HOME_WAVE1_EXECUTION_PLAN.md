# ARVIN Home Wave 1 Execution Plan

## Scope
Implementation preparation for the first production code wave of the canonical Arvin UI.

## Authority
The canonical UI reference and final product decisions override conflicting older UI documents.

## Home requirements

- Persian RTL interface.
- Preserve approved typography and color system.
- Remove legacy statistical cards from Home.
- Keep real task data as the single source of information.
- Provide four stable grouping modes:
  - Time
  - Projects
  - Categories
  - Labels

## Data rules

- No duplicate task records when displayed in multiple groups.
- Counts must come from actual repositories/models.
- Existing Task, Project, Category and Label data paths must be reused.

## Task card rules

- Completion control.
- Title emphasis.
- Related metadata.
- Due date and real status.
- Last follow-up or description preview.
- Open details page on tap.

## Implementation gate

A Home change is accepted only after:

1. Widget implementation.
2. Data connection verification.
3. Flutter analysis.
4. Tests.
5. Android runtime verification.

## Status

Preparation completed. Code modification begins only after final file mapping verification.
