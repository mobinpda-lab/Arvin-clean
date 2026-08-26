# FollowUp write → alarm reschedule boundary — 2026-08-26

## Scope
Connect real FollowUp add/edit writes to the merged Automatic FollowUp scheduler without putting Android platform calls inside canonical persistence.

## What changed
- Added `FollowUpWriteCoordinator` around the existing `FollowUpRepository` and `AutomaticFollowUpSchedulerAdapter`.
- A successful add/update requests scheduler rescheduling only after canonical persistence succeeds.
- Scheduler/platform failure is best-effort and does not report a successfully saved user edit as a persistence failure.
- Persistence failure never calls the scheduler.
- `FollowUpOfficePage` now routes its real add/edit writes through the coordinator.
- Production defaults to the merged `AndroidAutomaticFollowUpScheduler`; tests can inject a scheduler adapter without invoking Android.

## Why this boundary
`FollowUpRepository` remains a pure canonical storage boundary over `arvin.tasks`. Android AlarmManager stays behind the scheduler adapter while the UI owns orchestration through the coordinator. No domain data is duplicated.

## Validation
Focused service tests cover add, update, scheduler failure after successful persistence, and persistence failure before scheduling.

A widget regression test additionally verifies that a real FollowUp Office add flow persists the FollowUp and requests exactly one alarm reschedule through an injected adapter.

## Dependency state
PR #188 is merged on main as `68107046e5a7b1969e834df3554203bdf6533346`. This slice is rebuilt on that merged scheduler and now owns the real write-path integration.

## Merge gate
Require exact-head `Arvin Build` + `Arvin Parallel Wave`, then successful post-merge main Build before considering the automatic FollowUp trigger/write path validated.

## Guardrails
- No second repository/storage/model.
- No Android calls inside `FollowUpRepository`.
- No duplicate scheduler package.
- Widget tests can inject the scheduler boundary.
