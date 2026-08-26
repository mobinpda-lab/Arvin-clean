# FollowUp write → alarm reschedule boundary — 2026-08-26

## Scope
Prepare the real write-path integration for Automatic FollowUp without putting Android platform calls inside canonical persistence.

## What changed
- Added `FollowUpWriteCoordinator` around the existing `FollowUpRepository` and `AutomaticFollowUpSchedulerAdapter`.
- A successful add/update requests scheduler rescheduling only after canonical persistence succeeds.
- Scheduler/platform failure is best-effort and does not report a successfully saved user edit as a persistence failure.
- Persistence failure never calls the scheduler.

## Why this boundary
`FollowUpRepository` remains a pure canonical storage boundary over `arvin.tasks`. The UI can later receive this coordinator while Android AlarmManager stays behind the scheduler adapter, keeping widget tests platform-independent.

## Validation
Focused tests cover add, update, scheduler failure after successful persistence, and persistence failure before scheduling.

## Dependency
This is a stacked slice on PR #188 and must not merge independently. After #187 and #188 are integrated, rebuild this slice on current main, wire it into the real FollowUp UI entry, and run fresh exact-head CI/APK.

## Guardrails
- No second repository/storage/model.
- No Android calls inside `FollowUpRepository`.
- No direct plugin dependency in widget tests.
