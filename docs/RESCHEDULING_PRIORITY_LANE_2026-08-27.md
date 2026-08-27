# Safe Rescheduling Priority Lane — 2026-08-27

Refs #285 #284 #288 #195.

## Purpose
Provide deterministic replacement-time suggestions after a scheduling conflict is known, without creating a second scheduling engine or silently moving user data.

## Current foundation
- `ScheduleConflictService` is already merged to `main` through #288 and remains the single overlap engine.
- `ReschedulingPlanner` consumes that engine and searches a caller-provided time window for conflict-free suggestions.
- Suggestions are ordered deterministically and can use an explicit duration, step and result limit.

## Safety boundary
- suggestion only; no automatic Task or Calendar mutation;
- no storage, repository, notification or background scheduler write;
- no duplicate overlap algorithm;
- any future write must be user-confirmed and use the existing canonical Task/FollowUp path.

## Validation gate
This branch was reconciled onto post-#288 `main`. Fresh exact-head Parallel Fast CI is required before promotion to full Build/Device validation. User-facing integration is a later slice after this foundation is green.