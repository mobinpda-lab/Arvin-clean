# Canonical Next Action — 2026-08-26

## Scope
This slice advances the Next Action lane in Issue #92 using only fields that already exist on canonical `Task`.

## What changed
- Added `TaskNextActionService` as a pure, local ranking service.
- Completed, archived, and trashed tasks are excluded.
- Overdue actionable tasks rank first, then future scheduled tasks, then active tasks without a schedule.
- The actionable time is the earliest of the existing Reminder time and the latest FollowUp's `nextFollowUp`.
- Transitional `followUpDate` is considered only when canonical FollowUp history is empty.
- Unscheduled tasks are ordered deterministically by recent activity and stable id.

## Product boundary
This is deterministic local prioritization, not an external AI model. A future UI can consume the ranked suggestions without introducing another task store or changing persistence.

## Validation
Focused tests cover overdue/future/unscheduled ordering, inactive-task exclusion, canonical next-follow-up selection, competing due times, legacy compatibility, and deterministic unscheduled ordering.

## Guardrails
- No new database or storage key.
- No parallel Task repository.
- No network/AI dependency.
- No UI rewrite.
- Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` validation.
