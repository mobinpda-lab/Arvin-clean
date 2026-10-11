# ARVIN User Requirements Memory

Date: 2026-09-17

## Permanent Product Requirements

- Normal tasks must not receive automatic date, time, or reminder values.
- Users choose date, time, and reminder only when needed.
- Follow Up is a separate concept from Task. Follow Up Date must not be confused with Task Date.
- Follow Up items without Reminder must not appear in Calendar.
- Calendar should show scheduled items, reminder-based items, and device calendar events.
- Remove the separate Device Calendar option from the More menu.
- Arvin calendar and device calendar should support synchronization.
- Tasks/events created in Arvin with scheduling information should be added to the phone calendar.
- Device calendar events visible in Arvin should be editable and convertible into Arvin tasks.
- Today page must support creating new tasks.
- All task creation points should use a shared Quick Add flow.
- Task actions must work consistently everywhere: Complete, Snooze, Edit.
- Calendar requirements: month navigation, Persian date display, and long press on a date to create a task.
- Prayer/Prayer times functionality is currently considered fixed and should not be changed unnecessarily.

## Data Model Separation

Task, Follow Up, and Calendar Event are separate concepts and should not be mixed.

## Quick Add Requirement

A fast task capture flow should be available from all major entry points.

Requirements:

- Quick Add should open as a lightweight bottom sheet.
- User can immediately type the task title and save.
- Quick Add must not automatically assign date, time, reminder, or priority.
- Optional metadata can be selected before saving.
- A clear action should open the full task creation screen.
- Quick Add and full task creation must share the same task creation logic.

## Full Screen Task Entry Requirement

A complete task creation screen should be available for detailed input.

Requirements:

- Full screen form for creating and editing tasks.
- Title is the primary required field.
- Date, time, reminder, repeat, project, labels, checklist, and notes are optional user choices.
- Empty optional fields must remain empty.
- The interface should follow the provided visual references for spacing, hierarchy, and usability.
- Editing an existing task should use the same structure as creation.

## Goal

Arvin should manage tasks first, then add scheduling, reminders, and calendar integration only when required by the user.


## Supersession note — Snooze action (2026-10-10)

This file preserves historical planning/requirements context. Any wording above that lists Snooze as a current Reminder/Calendar action is superseded by the owner-approved AMP contract recorded in `docs/ARVIN_MASTER_EXECUTION_PROTOCOL.md`. Current runtime Calendar/task surfaces contain no Snooze action/callback/logic, and regression tests assert its absence. Do not reintroduce Snooze without a new explicit product decision. Preserve completion, Edit, manual Calendar registration, Reminder, Repeat and Follow-up behavior.


## Continuity Addendum — 2026-10-11 (Owner requirements; preserve until explicitly superseded)

- Report Center time/date filters must use Persian/Jalali dates and Persian-facing time/date controls, not Gregorian-facing calendar/time UI. The filter panel itself must be redesigned as compact, expandable Arvin RollBox/accordion sections; each section preserves its selection when collapsed.
- Report filters must support multi-select for Project, Category, Tag, task status and note type; show selected chips, selected counts, icons, expandable indicators, and domain identity colors. Required filter areas: Time, Project, Category, Tag, Note, Task Status, Tracking, Follow-up.
- Reports are read-only consumers of canonical domain data, not owners of parallel data. Sources to integrate as available: Task, Project, Category, Tag, Tracking, Follow-up, Calendar, Notes.
- Note filters/reporting should cover title, body text, note category/tag, creation/modified dates and Task association. Notebook must not become a parallel Task store; use existing canonical relationships and repositories.
- Extend the approved pastel visual language consistently across Home, Calendar, Notebook, Reports, forms, settings and detail pages. Preserve Persian RTL, VazirHarf v34.003, approved Arvin palette and existing interactions; colors must convey status/domain rather than be decoration.
- Preserve other open owner requirements recorded in the 2026-10-11 continuity checkpoint: phone-calendar events visible on Home; Calendar actions appear in one horizontal row after selecting an item; move the existing Reports icon into bottom navigation (do not create another report destination); fix Project settings add/edit persistence; Notebook Category/Tag/Project controls share one RTL row; Notebook tick/number/checklist toolbar labels must not clip and checklist must be a real persistent interactive checkbox.
- Calendar sync scope: title, date, time, description, recurrence details and reminder only. Done/Archive alone must not sync as calendar operations. Editing an unregistered phone-calendar event already works on the installed app per owner report; do not reimplement it.
- Owner decision: root Task.description remains the only root Task text field; do not add root Task.note. Existing scoped FollowUp.note and Notebook note concepts remain unchanged.
- These are owner requirements, not proof of implementation. Track each separately through code, regression tests, exact-head CI, Android/device validation and owner acceptance. Never mark complete from documentation or orchestration-only success.
