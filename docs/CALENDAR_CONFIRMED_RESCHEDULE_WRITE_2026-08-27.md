# Confirmed calendar reschedule write boundary — 2026-08-27

Refs #314 #313 #311 #308 #195.

## Purpose
Prepare the canonical write half of the upcoming Apply flow while the UI remains explicitly responsible for asking the user for confirmation.

## What this slice does
`CalendarRescheduleApplyService.applyConfirmed` accepts an already-resolved canonical FollowUp target plus the user-approved replacement time. It creates a replacement FollowUp with the same id, note, result and nextFollowUp, changes only `dateTime`, and delegates to the existing `FollowUpWriteCoordinator.update`.

## Why this is safe
- no automatic decision or automatic Apply;
- no new repository/storage/model/schema;
- canonical persistence remains in `FollowUpRepository` through the existing write coordinator;
- successful persistence requests the already-merged automatic alarm reschedule;
- persistence failure does not request a scheduler update;
- the original immutable FollowUp instance is not mutated.

## Remaining UI gate
This slice is intentionally not user-accessible by itself. A dependent UI slice must show current/proposed time, require explicit Persian confirmation, perform zero writes on cancel/close, and refresh/exit stale calendar state after a successful update.

## Validation
Focused tests cover metadata preservation, exact proposed date persistence, scheduler reschedule after success, original-object immutability, and no scheduler call on persistence failure.
