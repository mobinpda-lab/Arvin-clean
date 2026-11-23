# Next Action product UI — 2026-08-26

## Scope
Expose the already-merged deterministic `TaskNextActionService` through a real user-facing path without creating a second model, storage path, ranking service, router, or AI subsystem.

## What changed
- Added `TaskNextActionPage` over canonical `List<Task>`.
- Reuses `TaskNextActionService.rank` for overdue → scheduled → unscheduled ordering.
- Completed, archived and trashed Tasks remain excluded by the existing canonical service.
- Adds a visible `اقدام بعدی` entry beside Timeline in `CanonicalCalendarLauncher`, which Home already reaches and which already receives canonical Tasks.
- Displays an explicit empty state when no open task can be suggested.

## Validation
Tests cover:
- deterministic visible ordering;
- exclusion of completed work;
- reason labels and empty state;
- real navigation from the existing Home-accessible canonical launcher.

## Architecture guard
- No new Task model or storage.
- No new ranking service.
- No AI/network dependency.
- No Home rewrite or second router.
- Existing Timeline entry remains intact.

## Score boundary
This slice is a Stage 70 candidate only after exact-head CI/APK, merge, and successful post-merge main validation. Higher stages still require the roadmap Definition of Done and official Scorecard/handoff evidence.
