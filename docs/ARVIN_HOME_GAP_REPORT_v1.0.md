# ARVIN HOME GAP REPORT v1.0

## Purpose

This document defines the audit baseline for completing the Arvin Home product surface.

It does not declare implementation completion. It defines the acceptance checks required before Home can be considered complete.

## Source of Truth

Current GitHub code and runtime evidence remain authoritative.

Product rules:

- One canonical Task record.
- Home views are projections, not duplicated data.
- Due Date is the source for time grouping.
- Changes require test and evidence.

## Home Structure Contract

Expected model:

Home

- Time View
- Project View
- Category View
- Tag View

All views must operate on the same underlying Task records.

## Time View Checks

Required:

- Overdue
- Today
- Future

Rules:

- Grouping uses Due Date.
- FollowUp is not a replacement for scheduling.
- No Task duplication.

## Project View Checks

Required:

- All projects.
- Selected project.
- Tasks without project.
- Create task from project context.

## Category View Checks

Required:

- Independent category grouping.
- Uncategorized group.
- Real category persistence.

## Tag View Checks

Required:

- Multiple tags per task.
- Real filtering.
- No copied task records.

## Task Card Acceptance

Each card should support:

- Completion control.
- Title display.
- Project/category context.
- Due date.
- FollowUp preview or description preview.

Card tap opens task detail.

## Quick Add Acceptance

Required validation:

- Rapid task creation.
- Context preservation.
- No duplicate creation.
- No data loss on errors.

## Evidence Gate

Home completion requires:

- Code evidence.
- Test evidence.
- Build verification.
- Runtime evidence.

Status:

Audit baseline created.
Implementation status requires repository and runtime verification.
