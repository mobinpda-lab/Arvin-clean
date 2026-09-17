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

## Notes Module Requirement

Task and Note are separate concepts.

Rules:

- Creating a Task must not automatically create a Note.
- Notes are created only by explicit user action.
- A Note may optionally be linked to a Task.
- Automatic Task-to-Note creation is prohibited.

The Notes interface should follow the provided visual reference:

- Clean and minimal layout.
- Independent Notes module.
- Clear title and editing area.
- High readability.
- Support for text editing and structured note content.

## Persian Date and Time Mandatory Rule

This is an immutable product rule.

The Arvin user interface must never display Gregorian dates or western time formats.

Applies to:

- Tasks
- Calendar
- Reminders
- Follow Ups
- Notes
- History
- Reports
- Notifications
- Date pickers
- Time pickers

Required:

- All user-visible dates must be Persian/Shamsi.
- All user-visible times must use the Persian-compatible display format.
- AM/PM and Gregorian date display are prohibited in the UI.

Internal storage may use technical date formats, but conversion to Persian display is mandatory before presenting data to users.

## Visual Reference Priority

For Quick Add:

- The first provided reference image is the primary visual reference.
- Quick Add should keep its lightweight, fast capture experience.
- The Full Form button is required and opens the complete task entry screen.

For Full Screen Task Entry:

- The provided references define the expected hierarchy, spacing, and usability direction.
- The final product should remain close to the reference experience.

## Goal

Arvin should manage tasks first, then add scheduling, reminders, calendar integration, and notes only according to explicit user choices.
