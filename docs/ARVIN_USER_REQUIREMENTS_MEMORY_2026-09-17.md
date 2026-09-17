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

## Goal

Arvin should manage tasks first, then add scheduling, reminders, and calendar integration only when required by the user.
