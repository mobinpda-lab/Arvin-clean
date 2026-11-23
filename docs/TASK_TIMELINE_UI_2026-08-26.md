# Task Timeline UI — 2026-08-26

## Scope
This slice advances roadmap feature #3 `Timeline کامل هر موضوع` from the existing canonical projection toward a real user-facing UI.

## What changed
- Added `TaskTimelinePage` over the existing `TaskTimelineService`.
- Renders canonical creation, reminder, FollowUp, and update events in chronological order.
- FollowUp note/result text is shown without creating a second history source.
- Persian RTL presentation and Persian digits are used.
- An explicit empty state is shown when the Task has no persisted timeline evidence.

## Validation
Widget tests cover chronological rendering, FollowUp notes/results, Persian labels, and the empty state.

## Current boundary
This PR adds the reusable user-facing page, but it does not yet wire the page into Home/task-detail navigation. Therefore it must not be credited as a fully delivered Timeline feature or Stage 70 until a real product entry point is merged and validated.

## Guardrails
- Reuses canonical `Task + FollowUps[]` and `TaskTimelineService`.
- No new model, repository, storage key, database, or second history store.
- No mutation or fabricated historical events.
- Product PRs #183 and documentation PR #182 remain independent.
