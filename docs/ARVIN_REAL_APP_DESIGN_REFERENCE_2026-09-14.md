# Arvin Real Application Design Reference

Date: 2026-09-14

## Authority

This document records the final design reference based on real installed Arvin application screenshots and approved product decisions.

The screenshots are execution evidence, not mockups. They define visual direction, placement, interaction patterns and expected behavior.

This document must be considered together with the canonical UI contracts. Conflicting old UI assumptions must not be restored.

## Core Rules

- Persian RTL interface.
- VazirHarf v34.003 remains the canonical font.
- Indigo identity color and light card-based design remain consistent.
- Existing Task, FollowUp, Project, Category, Tag and Notebook models must be reused.
- No parallel storage or fake UI behavior.

## Home

Reference behavior:

- Header and greeting area.
- Search.
- Four real grouping modes:
  - Time
  - Projects
  - Categories
  - Tags
- Selected grouping state must be visible.
- Data comes from real application models.

Deprecated statistical cards must not return where superseded by final Home decisions.

## Quick Entry

Required behavior:

- Bottom panel above keyboard.
- Automatic title focus.
- Continuous task creation without closing panel.
- Preserve selected metadata after save.
- Prevent duplicate submissions.
- Protect unsaved drafts.
- Quick entry and full form share one save path.

Optional data:

- Due date
- Reminder
- Repeat
- Project
- Category
- Tags

## Notebook

Required:

- Notes list.
- Checklist mode.
- Full content editor.
- Category support.
- Real persistence.
- Checklist progress calculation.

## Calendar

Required:

- Real Jalali calendar.
- Month/week/day views.
- Separate tasks, reminders and events.
- Existing data connection.

## Next Action

Must use real project logic. No simulated AI output. Recommendations require clear reasons and access to source tasks.

## Follow-up Tasks

Required:

- Task details.
- Latest follow-up display.
- Follow-up history.
- Add follow-up without deleting history.
- Update cards after successful operations.

## Acceptance

A feature is complete only after:

- implementation exists,
- data flow works,
- Android execution is verified,
- screenshots are from real execution,
- regressions are checked.
