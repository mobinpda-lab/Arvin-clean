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
