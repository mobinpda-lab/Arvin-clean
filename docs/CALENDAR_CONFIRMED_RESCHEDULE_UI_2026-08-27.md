# Confirmed calendar reschedule UI — 2026-08-27

Refs #314 #317 #313 #308 #195.

## Purpose
Expose the merged safe rescheduling advice as a real user-controlled action without ever applying a change automatically.

## UX
- conflict suggestions are shown as `اعمال HH:MM` actions;
- tapping an action opens a Persian confirmation dialog;
- the dialog shows the current time and proposed time;
- `لغو` performs zero write and zero scheduler request;
- `اعمال زمان پیشنهادی` delegates to `CalendarRescheduleApplyService`;
- after success the launcher replaces only the matching in-memory FollowUp after canonical persistence succeeds, so the visible calendar immediately rebuilds from the new time;
- failure keeps the suggestion flow available and surfaces an explicit error message.

## Safety boundary
The UI never writes SharedPreferences and never calls Android directly. Canonical persistence still runs through `FollowUpWriteCoordinator` / `FollowUpRepository`, and successful writes request the existing automatic alarm reschedule. The FollowUp id, note, result and nextFollowUp are preserved by the apply service.

## Validation
Widget coverage verifies explicit confirmation, zero-write cancel, successful canonical persistence, one scheduler reschedule, visible success feedback, and persistence-failure feedback with zero scheduler calls.

## Merge gate
Keep this stacked UI lane Draft while #317 is unmerged. After #317 merges, rebuild from fresh main, require exact-head Parallel first, then full Build/APK/Device before merge and post-merge main validation before any scorecard stage-85 promotion.
