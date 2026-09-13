# ARVIN FINAL PRODUCT IMPLEMENTATION CONTRACT

Version: 1.0
Date: 2026-09-14

## Authority

This document is the implementation authority for Arvin product completion.

Primary references:
- Real installed Arvin application behavior.
- Approved real application screenshots.
- ARVIN_FINAL_UI_VISUAL_REFERENCE.md for visual system.

Conflicting old UI requirements must not redirect implementation.

## Goal

Deliver a real working production application. This contract is for code implementation, testing and acceptance, not mockups.

## Preservation Rules

Existing Task, FollowUp, Project, Category, Label and Notebook models and services must be reused.
No parallel storage or duplicate architecture may be created only for visual similarity.
Existing data, history, reminders, recurrence, archive and trash behavior must remain safe.

# Global UI Contract

- Persian RTL interface.
- Approved VazirHarf font.
- Primary identity color: #4A4CAB.
- Light background.
- White rounded cards.
- Soft shadows.
- Consistent functional icons.
- Real data must drive all counts and states.

# Home

Required:
- Bismillah header.
- Arvin title.
- Notification and menu placement.
- Rounded search.
- Four grouping entry buttons:
  - Time
  - Projects
  - Categories
  - Labels

Old four statistic cards (total, active, completed, overdue) must not return to Home.

## Grouping behavior

Time:
- Overdue, today and future groups.
- Future includes tomorrow, this week and later.
- Undated tasks remain accessible.
- Due date, reminder and follow-up dates remain independent.

Projects:
- Tasks grouped by project.
- Support all projects, single project, no project.
- Create/edit project.

Categories:
- Independent category grouping.
- Project filter.
- Category creation, icon and color selection.

Labels:
- Multiple labels per task.
- Label colors.
- No duplicate counting when a task appears in multiple groups.

# Task Card

Must show:
- Completion control.
- Title.
- Related context.
- Due date.
- Real status.
- Last follow-up summary when available.

Opening a card goes to details, not directly edit.

# Navigation

Fixed five destinations RTL:
- Home
- Calendar
- Notebook
- Next Action
- More

Projects and categories are not sixth tabs.

# Quick Entry

Requirements:
- Bottom sheet above keyboard.
- Automatic title focus.
- Title is enough for save.
- Optional date, time, project, category, label, reminder and recurrence.
- Separate menus for date/reminder/recurrence.
- Full form access.

After successful save:
- Sheet remains open.
- Title and task-specific text clear.
- Focus returns to title.
- Keyboard remains ready.
- Selected context can persist for next entries.
- Duplicate taps cannot create duplicate tasks.
- Save errors preserve input.

Android back behavior must protect drafts.

# Full Task Form

Supports:
- Title.
- Description.
- Project.
- Category.
- Labels.
- Priority.
- Due date.
- Reminder.
- Recurrence.
- Follow-up enabled state.

Unsaved changes require protection.

# Swipe Actions

Default:
- Left: complete/change date.
- Right: move/delete.

RTL behavior must be tested.
Normal delete goes to trash with restore.
Permanent delete requires confirmation.

# Follow-up Task Details

Required:
- Task context.
- Status.
- Description.
- Due date.
- Reminder.
- Labels.
- Latest follow-up card.
- History timeline newest first.
- Add follow-up.
- Edit.
- Complete.

Adding follow-up appends history; never replaces it.

# Notebook

Supports:
- Notes.
- Checklists.
- Search.
- Categories.
- Full-screen editor.
- Real checklist progress.

Formatting tools appear only when functional.

# Calendar and Next Action

Calendar:
- Real Persian calendar.
- Day/week/month views.
- Tasks, reminders, follow-ups and events separated.

Next Action:
- Use existing project logic.
- Explain why an item is suggested.
- No fake AI capability.

# Settings

Include only functional options:
- Theme.
- Font.
- Text size.
- Swipe behavior.
- Notifications.
- Existing follow-up/calendar/sync features.
- Backup and restore.
- Privacy.
- Help.

# Quality Acceptance

Required validation:
- Empty states.
- Errors.
- Loading.
- Long text.
- Keyboard behavior.
- Large text sizes.
- Real Android testing.

Final flow tests:
- Three consecutive quick task entries without closing panel.
- Return to home.
- Data survives restart.
- Four real grouping modes.
- Follow-up addition preserves history.
- Notebook data remains.

Delivery evidence:
- Branch and commit.
- Changed files.
- flutter analyze result.
- Tests.
- Real Android screenshots.
- Remaining limitations.

No completion claim without evidence.
