# Arvin Final Visual Reference

## Status
Canonical visual and interaction reference for Arvin product UI.

This document defines the final target output based on real installed Arvin runtime evidence, owner-approved screenshots, and existing canonical contracts.

It is a binding design reference, not only an image archive.

## Authority

Priority order:

1. Real installed Arvin application behavior and approved runtime screenshots.
2. Canonical UI contracts.
3. Product contract matrix and recovery decisions.
4. Historical documents only for traceability.

Conflicting old UI documents must not redirect implementation.

## Global Visual Language

- Persian RTL first.
- Calm productivity design.
- Light surfaces.
- Indigo/purple identity.
- Rounded cards.
- Clear hierarchy.
- Low visual noise.
- Consistent typography and icon weight.

## Home Screen

Required structure:

- Identity header.
- Bismillah block.
- Arvin title.
- Notification and menu actions.
- Search.
- Statistics cards.
- Current work cards.
- Fast action.
- Bottom navigation.

Home must preserve approved hierarchy and avoid deprecated layouts.

## Navigation

Primary areas:

- خانه
- تقویم
- دفترچه
- اقدام بعدی
- بیشتر

Must preserve RTL order, icons, selected state and user flow.

## Quick Entry

Quick creation is a core workflow:

- Fast title entry.
- Project selection.
- Category selection.
- Tag selection.
- Optional date/time.
- Save quickly.
- Expand to complete task when needed.

Quick entry and full task creation share one canonical task model.

## Task Detail and Follow-up

Required:

- Task information.
- Status.
- Reminder.
- Follow-up state.
- Follow-up history.
- Add follow-up action.

Follow-ups append to existing history and never erase previous records.

## Notebook

Two clear modes:

### Simple Note
- Content focused editor.
- Categories.
- Move/delete actions.

### Checklist
- Checklist items.
- Completion state.

Both use canonical storage foundations.

## Projects, Categories, Tags

Required:

- Clear grouping.
- Color identity.
- Icon identity.
- Easy filtering.
- Consistent placement.

## Calendar

Required:

- Jalali calendar support.
- Task connection.
- Follow-up connection.
- Clear date selection.

## Acceptance Criteria

A screen is complete only when:

- Appearance matches the approved reference.
- Behavior matches the approved workflow.
- Existing architecture is reused.
- RTL is verified.
- Device screenshots are compared.
- Regression tests pass.

## Migration Rule

Before any UI change:

1. Read this document.
2. Read ARVIN_UI_CANONICAL.md.
3. Check Product Contract Matrix.
4. Resolve obsolete conflicts.
5. Implement through existing architecture.

Target: production-ready Arvin, not a prototype.
