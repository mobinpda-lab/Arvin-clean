# ARVIN FINAL UI/UX CONTRACT

## Purpose

This document records the owner-approved final UI/UX execution contract for Arvin.

Repository: mobinpda-lab/Arvin-clean

The objective is to transform the Flutter Android interface into the final product experience defined by the reference images and requirements.

This is an implementation contract, not a mockup specification.

All requirements must be implemented with real Flutter behavior, real navigation, real data persistence, and existing project architecture.

## Architecture Rules

Preserve existing core systems:

- Task
- FollowUp
- Project
- Category
- Tag
- Notebook
- Calendar
- Storage
- Services

Do not create parallel Task, FollowUp, Notebook, or Storage paths.

New UI must use the existing canonical data flow.

## Visual System

- Persian RTL interface
- VazirHarf v34.003 font
- Primary color: #4A4CAB
- Background: #F8F8FB
- White rounded cards
- Subtle shadows
- Clean layout
- Large whitespace
- Functional UI only

## Home

Required structure:

- Fixed header
- "بسم الله الرحمن الرحیم"
- "مدیریت کارها و پیگیری آروین"
- Notification and menu positions preserved
- Rounded search area

Remove old statistic cards.

Replace with four functional views:

1. زمان
2. پروژه‌ها
3. دسته‌ها
4. برچسب‌ها

Each view must change real task grouping.

## Task Card

Must display:

- Completion control
- Title
- Project/category information
- Due date
- Status
- Latest FollowUp or description preview

Long text uses ellipsis.
Touch opens real task details.

## Navigation

Bottom navigation:

- خانه
- تقویم
- دفترچه
- اقدام بعدی
- بیشتر

All destinations must be real pages.

## Quick Task Entry

Quick entry and full editor share the same Task Draft and canonical save path.

Quick entry requirements:

- Real Flutter Bottom Sheet
- RTL
- Rounded white panel
- Auto focus title
- Save with title only
- Keep panel open after successful save
- Support consecutive task creation
- Preserve shared selections
- Prevent duplicate saves
- Preserve input on errors

Full editor receives the same draft and must not create another task path.

## Swipe

RTL swipe behavior:

Left:
- Complete
- Change date

Right:
- Move
- Delete

Delete moves to Trash with restore support.

## FollowUp

Task details must include FollowUp history.

Rules:

- Newest first
- Add without deleting history
- Current date/time default
- Empty text becomes "پیگیری"

## Notebook

Support:

- Notes
- Checklists
- Search
- Categories
- Full-screen editing
- Checklist progress

## Calendar

Real Persian calendar:

- Month
- Week
- Day

Separate:

- Task
- FollowUp
- Reminder

## Validation

Acceptance requires:

- Three consecutive quick task saves without closing panel
- Data survives restart
- Correct Android back behavior
- Correct RTL swipe behavior
- Keyboard safety
- flutter analyze
- Tests
- APK build when possible

## Delivery Evidence

Final delivery must include:

- Changed files
- Tests
- Remaining issues
- Real UI screenshots
- Quick entry recording evidence
- PR status

No completion claim without real execution evidence.
