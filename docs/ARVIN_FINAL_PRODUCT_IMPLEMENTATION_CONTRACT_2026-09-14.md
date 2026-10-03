# ARVIN FINAL PRODUCT IMPLEMENTATION CONTRACT

Version: 1.0
Date: 2026-09-14

## Purpose

This document is the implementation authority for completing Arvin as a real production Android application.
It complements ARVIN_FINAL_UI_VISUAL_REFERENCE and defines behavior, data rules, acceptance criteria and delivery requirements.

## Authority

1. Real installed Arvin application behavior and approved screenshots are primary references.
2. This contract overrides conflicting old UI assumptions.
3. Existing data models and services must be preserved.
4. No mockups or fake capabilities are acceptable as completion evidence.

## Product Scope

Arvin includes:
- Tasks
- Follow ups
- Projects
- Categories
- Labels
- Notebook
- Calendar
- Next actions
- Settings

## Shared UI Rules

- Persian RTL interface.
- VazirHarf v34.003.
- Primary color #4A4CAB.
- Light background.
- White rounded cards.
- Soft shadows.
- Consistent semantic icons.
- Real application data must drive all displays.

## Home Contract

Required header:
- بسم الله الرحمن الرحیم
- مدیریت کارها و پیگیری آروین
- Notification left side.
- Menu right side.
- Rounded search below title.

Old four statistic cards must not return.

Home grouping controls:
1. Time
2. Projects
3. Categories
4. Labels

Order is fixed RTL.
Selection changes real grouping, not mock filtering.

## Grouping Rules

Time:
- Overdue
- Today
- Future
- No due date access

Projects:
- Project groups
- No project
- Add task from group inherits project

Categories:
- Independent category grouping.
- Category creation, color and icon selection.

Labels:
- Multiple labels per task.
- No duplicated task counting.

## Task Card

Must show:
- Completion control
- Title
- Related project/category
- Due date
- Real status
- Latest follow up or description preview

Tap opens details, not editor.

## Navigation

Five fixed destinations:
- Home
- Calendar
- Notebook
- Next actions
- More

Projects and categories are not extra bottom tabs.

## Quick Entry

Quick entry is a bottom panel above keyboard.

Required:
- Auto focus title.
- Optional date/time/project/category/label/reminder/repeat.
- Separate menus for date, reminder and repeat.
- Full form access.

Save behavior:
- Panel remains open after successful save.
- Title and task-specific description reset.
- Focus returns to title.
- Keyboard remains ready.
- Previous selections can remain for repeated entry.
- Duplicate saves prevented.
- Errors preserve user input.

## Full Task Form

Supports:
- Title
- Description
- Project
- Category
- Labels
- Priority
- Due date
- Reminder
- Repeat
- Follow-up state

Unsaved changes require protection.

## Swipe Actions

RTL tested.
Default:
- Left: complete/change date.
- Right: move/delete.

Delete moves to trash and supports restore.
Permanent delete requires confirmation.

## Follow-up Task Details

Required:
- Task context
- Latest follow up card
- History timeline
- Add follow up
- Edit
- Complete

Adding follow up appends history; it never replaces previous history.

## Notebook

Two modes:
- Notes
- Checklists

Requirements:
- Search
- Categories
- Full editor
- Real checklist progress
- Preserve existing Notebook storage

## Calendar and Next Actions

Calendar:
- Persian calendar.
- Day/week/month views.
- Tasks, follow ups, reminders and events separated.

Next actions:
- Use existing project logic.
- Show reason for suggestion.
- No fake AI responses.

## Settings

Must provide only working options:
- Theme
- Font/text size
- Notifications
- Existing tracking/calendar/sync features
- Backup and restore
- Privacy
- Help

## Data Safety

Reuse existing:
- Task
- FollowUp
- Project
- Category
- Label
- Notebook

No parallel storage architecture for visual similarity.

Preserve:
- History
- Archive
- Trash
- Repetition
- Reminders

## Delivery Acceptance

Each implementation stage must provide:
- Branch
- Commit SHA
- Changed files
- PR link
- flutter analyze result
- Tests result
- Real Android screenshots
- Capability status

Final verification:
- Three consecutive quick task entries.
- App restart data persistence.
- Four real grouping modes.
- Follow up addition without deleting history.
- Notebook preservation.

No completion claim without real evidence.
