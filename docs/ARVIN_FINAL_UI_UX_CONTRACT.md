# ARVIN FINAL UI/UX CONTRACT

## Goal
Transform Arvin into the final Flutter Android product based on the approved visual references and real interaction requirements.

## Rules
- No mockup-only implementation.
- Existing architecture remains the source of truth.
- Preserve Task, FollowUp, Project, Category, Tag, Notebook, Calendar, Storage and Services.
- No parallel data paths.

## Design System
- Persian RTL.
- VazirHarf v34.003.
- Primary: #4A4CAB.
- Background: #F8F8FB.
- White rounded cards, subtle shadows, clean hierarchy.

## Home
Replace statistic cards with functional views:
1. Time
2. Projects
3. Categories
4. Tags

Views must change real task grouping and not be decorative.

## Quick Entry
Quick Entry and Full Editor share one Task Draft flow.

Requirements:
- Real Flutter Bottom Sheet.
- Auto focus title.
- Save with title only.
- Register multiple tasks without closing sheet.
- Preserve common selections.
- Prevent duplicate saves.
- Keep failed input on errors.
- Full Editor receives the same draft.

## Task Cards
Show:
- completion control
- title
- project/category
- due date
- status
- latest follow-up or description preview

## Navigation
Five fixed destinations:
Home, Calendar, Notebook, Next Action, More.

## Swipe RTL
Left: complete/change date.
Right: move/delete.
Delete uses trash with restore.

## FollowUp
Real history, newest first. No fake dates.

## Notebook
Notes and checklists with search, categories and real editing.

## Calendar
Real Persian calendar with task, follow-up and reminder separation.

## Validation
Required before release:
- flutter analyze
- tests
- APK build where possible
- real device audit
- three consecutive quick task registrations

No completion claim without execution evidence.
