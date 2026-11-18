# Calendar Conflict Advice UI — 2026-08-27

Refs #307 #301 #302 #284 #285 #288 #291 #294.

## Purpose
Expose the already-merged conflict detection and safe rescheduling advice through Arvin's real Home-accessible canonical calendar without creating another scheduling engine or automatic write path.

## User path
`Home -> CanonicalCalendarLauncher -> تداخل‌ها`

The launcher projects the existing canonical Task FollowUps into the existing CalendarReminder model, then calls the merged `CalendarReschedulingAdvisor` for each active timed reminder.

If no conflict exists, the sheet reports that no time conflict was found. If a real conflict exists, the Persian bottom sheet shows each affected reminder and up to three deterministic replacement-time suggestions for the remainder of that day.

## Safety boundary
- no duplicate conflict or rescheduling algorithm;
- no Calendar/Task/FollowUp model or storage;
- no persistence/repository/notification/background scheduler mutation;
- no automatic reschedule action;
- suggestions are informational only;
- official holiday/prayer provider rows are not treated as canonical Task busy records by this launcher check;
- any future Apply action must require explicit user confirmation and write through the existing canonical path.

## Validation
Focused widget coverage verifies that two canonical FollowUps at the same time are detected from the real launcher, their titles appear in the conflict sheet, deterministic Persian-time suggestions are shown, and the UI explicitly states that no automatic change is applied.

This lane starts as Draft and uses Parallel Fast CI first. Full Build/APK/Device validation is required only after the exact head is green and reconciled to current main.
