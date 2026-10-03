# ARVIN FINAL PRODUCT IMPLEMENTATION CONTRACT

Version: 1.0
Date: 2026-09-14

## Authority

This document is the implementation authority for final Arvin production work.

Primary references:
- Real installed Arvin application behavior.
- Approved Arvin screenshots.
- Final product decisions.

This document defines behavior, acceptance criteria and implementation rules. It is not a mockup specification.

## Conflict Resolution

1. Real approved installed behavior has priority.
2. This contract overrides older conflicting UI assumptions.
3. Existing data models, services and features must be preserved.
4. No parallel architecture may be created only to reproduce visuals.

## Product Goal

Deliver a real executable production application, not a prototype.

## Common UI Rules

- Persian RTL interface.
- VazirHarf v34.003 font.
- Primary color: #4A4CAB.
- Light background.
- White rounded cards.
- Soft shadows.
- Consistent functional icons.
- Real application data must drive UI.

## Home

Required:
- Bismillah header.
- Arvin title.
- Notification and menu placement.
- Rounded search area.
- Four grouping entry buttons:
  - Time
  - Projects
  - Categories
  - Labels

The old four statistic cards must not return to Home.

Grouping behavior:
- Time groups overdue, today and future.
- Project groups by project.
- Category groups independently from projects.
- Labels support multiple labels per task.
- No duplicated counting when a task appears in multiple groups.

## Task Card

Must show:
- Completion control.
- Title.
- Related context.
- Due date.
- Real status.
- Latest follow-up or description preview.

Tap opens details, not direct editor.

## Navigation

Fixed destinations:
- Home
- Calendar
- Notebook
- Next Action
- More

Projects and categories are not bottom navigation destinations.

## Quick Entry

Requirements:
- Bottom panel above keyboard.
- Automatic title focus.
- Optional date, time, project, category, labels, reminder and repeat.
- Full form access.

Sequential creation:
- Save does not close panel.
- Title and task-specific description clear after success.
- Focus returns to title.
- Keyboard remains ready.
- Previous selections can remain for next task.
- Duplicate saves are prevented.
- Failed saves preserve user input.

Android back behavior must protect unfinished drafts.

## Full Task Form

Supports:
- Title.
- Description.
- Project.
- Category.
- Labels.
- Priority.
- Due date.
- Reminder.
- Repeat.
- Follow-up enabled state.

Unsaved changes require protection.

## Swipe Actions

RTL tested behavior required.

Default:
- Left: complete/change date.
- Right: move/delete.

Delete moves to trash with restore support.
Permanent deletion requires confirmation.

## Follow-up Task Details

Required:
- Task context.
- Status.
- Due date.
- Reminder.
- Labels.
- Latest follow-up card.
- Follow-up history newest first.
- Add follow-up.
- Edit.
- Complete.

Adding follow-up appends history and never replaces it.

## Notebook

Supports:
- Notes.
- Checklists.
- Search.
- Categories.
- Full content editor.

Formatting tools appear only when functional.

## Calendar and Next Action

Calendar:
- Persian calendar.
- Day/week/month views.
- Separate tasks, reminders and events.
- Connected to real task data.

Next Action:
- Uses existing project logic.
- Shows reason and related task.
- No fake AI behavior.

## Settings

Must contain only working options:
- Theme.
- Font/text size.
- Notifications.
- Existing follow-up/calendar/sync features.
- Backup and restore.
- Privacy.
- Help.

## Data Protection

Reuse existing:
- Task.
- FollowUp.
- Project.
- Category.
- Label.
- Notebook.

Preserve:
- Existing tasks.
- History.
- Archive.
- Trash.
- Reminders.
- Repeating tasks.

## Delivery Evidence

Each implementation phase must provide:
- Branch.
- Commit.
- Changed files.
- Flutter analyze result.
- Tests result.
- Real Android screenshots.
- Feature status.

Final verification:
- Three sequential quick task entries.
- Data persistence after restart.
- Four real grouping views.
- Follow-up creation without history loss.
- Notebook preservation.

No completion claim without evidence.
