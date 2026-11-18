# Waiting for Response — user-facing flow — 2026-08-26

## Scope
This slice advances the merged Waiting for Response contract from core stage to a real user-facing Follow-up Office flow.

## What changed
- `FollowUpEntryPage` exposes a Persian `منتظر پاسخ دیگران` switch.
- When enabled, save persists the existing canonical `waiting_for_response` token through the current FollowUp repository path.
- Existing waiting entries open with the switch enabled; disabling it allows a normal result to replace the waiting state without creating another FollowUp.
- `FollowUpOfficePage` adds a `فقط منتظر پاسخ` filter.
- The filter evaluates only each task's latest FollowUp result, so an older waiting result does not keep a task waiting after a newer resolved FollowUp exists.
- Waiting rows display a Persian `منتظر پاسخ` chip instead of exposing the internal canonical token.

## Persistence boundary
No new persistence path was created. Add/edit continues through `FollowUpRepository`, and the waiting state remains in the existing `FollowUp.result` field defined by the merged contract.

## Regression coverage
Widget tests verify:
1. UI switch → canonical token persistence.
2. Waiting result is shown as a user-friendly chip.
3. Waiting-only filter uses the latest FollowUp for each task.
4. A task with an old waiting result and a newer resolved result is excluded.
5. Editing an existing waiting FollowUp preserves stable identity and can clear waiting state into a normal result.

## Progress impact
After this slice is merged and exact-head validation is green, the official scorecard can promote roadmap feature #10 from stage 40 (core) to stage 70 (real UI wired to canonical persistence). Stage 85 still requires release/post-merge validation evidence under the official metric.

## Guardrails
- No new Task status field.
- No new database/storage/repository.
- No parallel CRM model.
- `FollowUps[]` remains the source of truth.
